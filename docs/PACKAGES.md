# 📦 Package List

## Categories

### Shell & Terminal
| Package | Description |
|---------|-------------|
| zsh | Z Shell — modern shell with plugins |
| tmux | Terminal multiplexer |
| starship | Cross-shell prompt |
| fzf | Fuzzy finder |

### Development
| Package | Description |
|---------|-------------|
| git | Version control |
| vim | Text editor |
| make/gcc | Build tools |
| python3 | Python runtime |
| nodejs/npm | JavaScript runtime |
| gh | GitHub CLI |

### Networking & Sysadmin
| Package | Description |
|---------|-------------|
| openssh-server | SSH daemon |
| net-tools | ifconfig, netstat |
| traceroute | Network path tracing |
| dnsutils/bind-utils | dig, nslookup |
| lsof | List open files/ports |
| curl/wget | HTTP clients |

### Modern CLI Tools
| Package | Description |
|---------|-------------|
| ripgrep | Fast grep replacement |
| fd-find | Fast find replacement |
| bat | cat with syntax highlighting |
| eza | Modern ls replacement |
| ncdu | Disk usage analyzer |
| jq | JSON processor |
| tldr | Simplified man pages |
| htop | Interactive process viewer |

## Distro Differences

Some packages have different names:
- **DNS tools**: `dnsutils` (Debian) vs `bind-utils` (RHEL)
- **Build tools**: `build-essential` (Debian) vs `gcc-c++` (RHEL)
- **eza**: Available in Ubuntu 24.04+, may need cargo on older systems
