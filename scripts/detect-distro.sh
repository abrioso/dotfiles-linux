#!/bin/bash
# detect-distro.sh — Detect the Linux distribution family
# Outputs: debian | rhel | arch | unknown
set -euo pipefail

detect_distro() {
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        case "${ID:-}" in
            ubuntu|debian|linuxmint|pop) echo "debian" ;;
            rhel|centos|almalinux|rocky|fedora|ol) echo "rhel" ;;
            arch|manjaro|endeavouros) echo "arch" ;;
            *) echo "unknown" ;;
        esac
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

# If sourced, provide the function; if executed, print result
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_distro
fi
