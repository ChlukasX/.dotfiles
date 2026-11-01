#!/bin/bash

set -euo pipefail

DOTFILES="$HOME/.dotfiles"
CONFIG="$HOME/.config"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
info()  { echo -e "${GREEN}[info]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $*"; }
error() { echo -e "${RED}[error]${NC} $*"; }
plan()  { echo -e "${BLUE}[plan]${NC}  $*"; }

OS=""
WM=""
NVIDIA=false
DRY_RUN=false
EXCLUDE=()

usage() {
    cat <<EOF
Usage: $0 (--linux | --macos) [options]

Exactly one OS flag is required:
  --linux                      Configure for Linux
  --macos                      Configure for macOS

Options:
  --wm=<i3|hypr|sway>          Window manager to link (Linux only)
  --nvidia                     Install sway-nvidia session (Linux + --wm=sway only)
  --exclude=<name>[,<name>…]   Skip named steps/links (repeatable, comma-separated)
  --dry-run, -n                 Print what would run without making changes
  -h, --help                    Show this help

Excludable names:
  shared:  repo, packages, nvim, wezterm, tmux, zsh
  linux:   i3, i3status, hypr, waybar, sway, swaylock, wofi, dunst, nvidia
  macos:   homebrew, aerospace
EOF
}

is_excluded() {
    local name="$1" e
    for e in "${EXCLUDE[@]:-}"; do
        [ "$e" = "$name" ] && return 0
    done
    return 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        --linux)
            [ -n "$OS" ] && { error "Only one of --linux/--macos may be set."; exit 1; }
            OS="linux"
            ;;
        --macos)
            [ -n "$OS" ] && { error "Only one of --linux/--macos may be set."; exit 1; }
            OS="macos"
            ;;
        --wm=*)     WM="${1#--wm=}" ;;
        --nvidia)   NVIDIA=true ;;
        --exclude=*)
            IFS=',' read -ra parts <<< "${1#--exclude=}"
            EXCLUDE+=("${parts[@]}")
            ;;
        --dry-run|-n) DRY_RUN=true ;;
        -h|--help)  usage; exit 0 ;;
        *)
            error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

if [ -z "$OS" ]; then
    error "Must specify exactly one of --linux or --macos."
    usage
    exit 1
fi

if [ -n "$WM" ] && [ "$OS" != "linux" ]; then
    error "--wm is only valid with --linux"
    exit 1
fi

if [ "$WM" != "" ] && [ "$WM" != "i3" ] && [ "$WM" != "hypr" ] && [ "$WM" != "sway" ]; then
    error "Unknown --wm value: $WM (expected i3, hypr, or sway)"
    exit 1
fi

if $NVIDIA && { [ "$OS" != "linux" ] || [ "$WM" != "sway" ]; }; then
    error "--nvidia is only valid with --linux --wm=sway"
    exit 1
fi

safe_link() {
    local name="$1" src="$2" dst="$3"

    if is_excluded "$name"; then
        info "Excluded: $name ($dst)"
        return
    fi

    if $DRY_RUN; then
        plan "link   [$name] $dst -> $src"
        return
    fi

    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        info "Already linked: $dst"
        return
    fi

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        local backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
        warn "Backing up: $dst → $backup"
        mv "$dst" "$backup"
    fi

    if [ -L "$dst" ]; then
        warn "Removing stale symlink: $dst"
        rm "$dst"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    info "Linked: $dst → $src"
}

run_step() {
    local name="$1" desc="$2"; shift 2

    if is_excluded "$name"; then
        info "Excluded: $name"
        return
    fi

    if $DRY_RUN; then
        plan "step   [$name] $desc"
        return
    fi

    "$@"
}

update_repo() {
    info "Updating dotfiles..."
    cd "$DOTFILES"
    git fetch --quiet
    git pull --quiet --ff-only || warn "Could not fast-forward; skipping pull."
}

detect_pkg_manager() {
    if command -v pacman &>/dev/null; then echo "pacman"
    elif command -v apt &>/dev/null;   then echo "apt"
    elif command -v dnf &>/dev/null;   then echo "dnf"
    else echo "unknown"; fi
}

install_packages_linux() {
    local pkgfile=""
    local mgr
    mgr=$(detect_pkg_manager)

    case "$mgr" in
        pacman) pkgfile="$DOTFILES/packages/pkgs.pacman" ;;
        apt)    pkgfile="$DOTFILES/packages/pkgs.apt"    ;;
        dnf)    pkgfile="$DOTFILES/packages/pkgs.dnf"    ;;
        *)      warn "Unknown package manager, skipping package install."; return ;;
    esac

    if [ ! -f "$pkgfile" ]; then
        warn "No package list found at $pkgfile — skipping."
        return
    fi

    info "Installing packages via $mgr..."
    case "$mgr" in
        pacman) sudo pacman -S --needed - < "$pkgfile" ;;
        apt)    xargs sudo apt install -y < "$pkgfile"  ;;
        dnf)    xargs sudo dnf install -y < "$pkgfile"  ;;
    esac
}

install_homebrew() {
    if command -v brew &>/dev/null; then
        info "Homebrew already installed. Updating..."
        brew update --quiet
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
}

install_brew_packages() {
    local brewfile="$DOTFILES/Brewfile"
    if [ -f "$brewfile" ]; then
        info "Installing packages from Brewfile..."
        brew bundle install --file="$brewfile" --no-lock
    else
        warn "No Brewfile found at $brewfile — skipping."
        warn "Run: brew bundle dump --file=$brewfile"
    fi
}

install_sway_nvidia() {
    info "Installing sway-nvidia launcher to /bin for greeter PATH access (sudo)"
    sudo cp "$DOTFILES/config/sway/nvidia/start.sh" "/bin/sway-nvidia"
    sudo chmod +x "/bin/sway-nvidia"
    info "Installing sway-nvidia desktop entry to /usr/share/wayland-sessions (sudo)"
    sudo cp "$DOTFILES/config/sway/nvidia/sway-nvidia.desktop" \
        /usr/share/wayland-sessions/sway-nvidia.desktop
    info "Removing leftover local session entry"
    rm -f "$HOME/.local/share/wayland-sessions/sway-nvidia.desktop"
    info "NVIDIA Sway session added"
}

link_wm() {
    case "$WM" in
        i3)
            safe_link "i3"       "$DOTFILES/config/i3"       "$CONFIG/i3"
            safe_link "i3status" "$DOTFILES/config/i3status" "$CONFIG/i3status"
            ;;
        hypr)
            safe_link "hypr"   "$DOTFILES/config/hypr"   "$CONFIG/hypr"
            safe_link "waybar" "$DOTFILES/config/waybar" "$CONFIG/waybar"
            ;;
        sway)
            safe_link "sway"     "$DOTFILES/config/sway"     "$CONFIG/sway"
            safe_link "waybar"   "$DOTFILES/config/waybar"   "$CONFIG/waybar"
            safe_link "swaylock" "$DOTFILES/config/swaylock" "$CONFIG/swaylock"
            safe_link "wofi"     "$DOTFILES/config/wofi"     "$CONFIG/wofi"
            safe_link "dunst"    "$DOTFILES/config/dunst"    "$CONFIG/dunst"

            if $NVIDIA; then
                run_step "nvidia" "install sway-nvidia launcher + wayland session entry" install_sway_nvidia
            fi
            ;;
        "")
            warn "No WM specified (--wm=i3|hypr|sway). Skipping WM config."
            ;;
    esac
}

link_configs() {
    info "Linking configs..."
    safe_link "nvim"    "$DOTFILES/config/nvim"            "$CONFIG/nvim"
    safe_link "wezterm" "$DOTFILES/config/wezterm"         "$CONFIG/wezterm"
    safe_link "tmux"    "$DOTFILES/config/tmux/.tmux.conf" "$HOME/.tmux.conf"
    safe_link "zsh"     "$DOTFILES/config/zsh/.zshrc"      "$HOME/.zshrc"

    if [ "$OS" = "macos" ]; then
        safe_link "aerospace" "$DOTFILES/config/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"
    fi
}

main() {
    if $DRY_RUN; then
        plan "Dry run — no changes will be made."
        plan "OS=$OS WM=${WM:-none} NVIDIA=$NVIDIA EXCLUDE=(${EXCLUDE[*]:-none})"
    fi

    run_step "repo" "git fetch + pull --ff-only" update_repo

    if [ "$OS" = "linux" ]; then
        run_step "packages" "install packages via detected package manager (pacman/apt/dnf)" install_packages_linux
        link_wm
    else
        run_step "homebrew" "install/update Homebrew" install_homebrew
        run_step "packages" "brew bundle install from Brewfile" install_brew_packages
    fi

    link_configs

    if $DRY_RUN; then
        info "Dry run complete — no changes made."
    else
        info "Done!"
    fi
}

main
