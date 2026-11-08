#!/bin/bash
# validate.sh — Runs the same repository validation locally and in CI.
#
# Checks every tracked shell script with `bash -n` and shellcheck, parses any
# tracked Python script, verifies executable bits, and checks whitespace in the
# working tree, index and an optional committed range.
#
# Usage: ./tests/validate.sh [--base-ref <git-ref>]
#   --base-ref <ref>  Also check committed whitespace between <ref> and HEAD.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_REF=""

while [ $# -gt 0 ]; do
    case "$1" in
        --base-ref)
            [ $# -ge 2 ] || { echo "--base-ref requires a value" >&2; exit 2; }
            BASE_REF="$2"
            shift 2
            ;;
        --help|-h)
            sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 2
            ;;
    esac
done

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
success() { printf '\033[1;32m[ OK ]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; }

cd "$REPO_ROOT"

command -v shellcheck >/dev/null 2>&1 || {
    error "shellcheck is required (https://www.shellcheck.net/). Install it with your package manager."
    exit 1
}

# Tracked and non-ignored new files, classified by extension or by shebang.
mapfile -t candidates < <(git ls-files --cached --others --exclude-standard | sort -u)
scripts=()
python_files=()
for file in "${candidates[@]}"; do
    [ -f "$file" ] || continue
    case "$file" in
        *.sh) scripts+=("$file") ;;
        *.py) python_files+=("$file") ;;
        *)
            if head -n 1 "$file" 2>/dev/null | grep -Eq '^#!.*\b(ba)?sh\b'; then
                scripts+=("$file")
            elif head -n 1 "$file" 2>/dev/null | grep -Eq '^#!.*\bpython3?\b'; then
                python_files+=("$file")
            fi
            ;;
    esac
done

info "Checking syntax of ${#scripts[@]} shell scripts..."
for file in "${scripts[@]}"; do
    bash -n "$file"
done
success "Syntax check passed."

info "Running shellcheck..."
shellcheck -x "${scripts[@]}"
success "shellcheck passed."

if [ ${#python_files[@]} -gt 0 ]; then
    info "Parsing ${#python_files[@]} Python scripts..."
    if command -v python3 >/dev/null 2>&1; then
        python3 -I -c 'import ast, sys
for path in sys.argv[1:]:
    with open(path, "rb") as handle:
        ast.parse(handle.read(), path)' "${python_files[@]}"
        success "Python parse passed."
    else
        error "python3 is required to parse: ${python_files[*]}"
        exit 1
    fi
fi

info "Checking executable bits on scripts..."
missing_exec=()
for file in "${scripts[@]}" "${python_files[@]}"; do
    if head -n 1 "$file" 2>/dev/null | grep -q '^#!'; then
        mode=$(git ls-files -s -- "$file" | awk '{print $1}')
        if [ -n "$mode" ] && [ "$mode" != "100755" ]; then
            missing_exec+=("$file")
        fi
    fi
done
if [ ${#missing_exec[@]} -gt 0 ]; then
    error "Scripts with a shebang are not executable in the index: ${missing_exec[*]} (fix with: git update-index --chmod=+x <file>)"
    exit 1
fi
success "Executable bits are consistent."

info "Checking whitespace..."
git diff --check
git diff --cached --check
mapfile -t untracked < <(git -c core.quotepath=false ls-files --others --exclude-standard)
for file in "${untracked[@]}"; do
    # --no-index implies --exit-code: 1 means added content, 2+ includes whitespace errors.
    status=0
    git diff --no-index --check -- /dev/null "$file" >/dev/null 2>&1 || status=$?
    if [ "$status" -gt 1 ]; then
        error "Untracked-file whitespace validation failed: $file"
        exit 1
    fi
done
if [ -n "$BASE_REF" ]; then
    git diff --check "$BASE_REF" HEAD
fi
success "Whitespace check passed."

success "Validation passed."
