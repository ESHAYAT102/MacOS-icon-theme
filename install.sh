#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$SCRIPT_DIR/MacOS"
THEME_NAME="MacOS Icons"
INSTALL_DIR="$HOME/.local/share/icons/$THEME_NAME"

echo "=== MacOS Icons Theme Installer ==="
echo ""

# Check dependencies
for cmd in gtk-update-icon-cache; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: Required command '$cmd' not found."
        echo "Install it with your package manager."
        exit 1
    fi
done

# Check theme exists
if [[ ! -d "$THEME_DIR" ]]; then
    echo "ERROR: Theme directory not found: $THEME_DIR"
    echo "Run './build-icons.sh' first to generate the theme."
    exit 1
fi

# Backup existing theme
if [[ -d "$INSTALL_DIR" ]]; then
    BACKUP="$INSTALL_DIR.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing theme to: $BACKUP"
    mv "$INSTALL_DIR" "$BACKUP"
fi

# Install
echo "Installing theme to: $INSTALL_DIR"
mkdir -p "$(dirname "$INSTALL_DIR")"
cp -r "$THEME_DIR" "$INSTALL_DIR"

# Rebuild icon cache
echo "Rebuilding icon cache..."
gtk-update-icon-cache -f -t "$INSTALL_DIR" 2>/dev/null || true

# Apply theme to GTK
apply_gtk_settings() {
    local ini="$1"
    if [[ -f "$ini" ]]; then
        sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=$THEME_NAME/" "$ini"
        echo "  Updated: $ini"
    fi
}

echo "Applying theme to GTK settings..."
apply_gtk_settings "$HOME/.config/gtk-3.0/settings.ini"
apply_gtk_settings "$HOME/.config/gtk-4.0/settings.ini"

# Apply to xsettingsd
XSETTINGSD="$HOME/.config/xsettingsd/xsettingsd.conf"
if [[ -f "$XSETTINGSD" ]]; then
    sed -i "s|Net/IconThemeName \".*\"|Net/IconThemeName \"$THEME_NAME\"|" "$XSETTINGSD"
    echo "  Updated: $XSETTINGSD"
fi

# Apply to dconf
if command -v dconf &>/dev/null; then
    dconf write /org/gnome/desktop/interface/icon-theme "'$THEME_NAME'" 2>/dev/null || true
    echo "  Updated dconf"
fi

echo ""
echo "=== Installation complete! ==="
echo "Theme '$THEME_NAME' has been installed and applied."
echo ""
echo "To undo, run: ./uninstall.sh"
