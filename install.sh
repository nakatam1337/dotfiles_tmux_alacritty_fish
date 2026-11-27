# Deploy the dotfiles in this repo into $HOME
# Usage: ./install.sh            (copies)
#        ./install.sh --link     (symlinks instead)
set -eu

REPO="$(cd "$(dirname "$0")" && pwd)"
MODE="copy"
[ "${1:-}" = "--link" ] && MODE="link"

install_file() {
    src="$REPO/$1"
    dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ "$MODE" = "link" ]; then
        ln -sfn "$src" "$dst"
        printf 'linked   %s -> %s\n' "$dst" "$src"
    else
        if [ -f "$dst" ] && ! cmp -s "$src" "$dst"; then
            cp "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
            printf 'backup   %s\n' "$dst"
        fi
        cp "$src" "$dst"
        printf 'copied   %s -> %s\n' "$src" "$dst"
    fi
}

install_file tmux/.tmux.conf            "$HOME/.tmux.conf"
install_file fish/config.fish           "$HOME/.config/fish/config.fish"
install_file alacritty/alacritty.toml   "$HOME/.config/alacritty/alacritty.toml"
install_file helix/config.toml          "$HOME/.config/helix/config.toml"
install_file helix/languages.toml       "$HOME/.config/helix/languages.toml"
install_file helix/themes/custom.toml   "$HOME/.config/helix/themes/custom.toml"

# The Alacritty config imports a theme from the community
# alacritty-theme collection. Clone it once if it's missing:
THEMES="$HOME/.config/alacritty/themes"
if [ ! -d "$THEMES/themes" ]; then
    printf 'note     theme collection missing, cloning alacritty-theme...\n'
    git clone --depth 1 https://github.com/alacritty/alacritty-theme "$THEMES"
fi

printf '\nDone. Reload tmux with Alt+r, fish with `exec fish`.\n'
printf 'Helix picks up its config on next start.\n'
