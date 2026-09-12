#!/usr/bin/env bash
set -euo pipefail

THEME_NAME="MacOS Icons"
INSTALL_DIR="$HOME/.local/share/icons/$THEME_NAME"
FALLBACK_THEME="hicolor"

echo "=== MacOS Icons Theme Uninstaller ==="
echo ""

# Check if installed
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "Theme '$THEME_NAME' is not installed."
    exit 0
fi

# Remove theme
echo "Removing theme from: $INSTALL_DIR"
rm -rf "$INSTALL_DIR"

# Rebuild icon cache
echo "Rebuilding icon cache..."
if command -v gtk-update-icon-cache &>/dev/null; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons" 2>/dev/null || true
fi

# Reset GTK settings to fallback
reset_gtk_settings() {
    local ini="$1"
    if [[ -f "$ini" ]]; then
        sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=$FALLBACK_THEME/" "$ini"
        echo "  Reset: $ini"
    fi
}

echo "Resetting GTK settings to '$FALLBACK_THEME'..."
reset_gtk_settings "$HOME/.config/gtk-3.0/settings.ini"
reset_gtk_settings "$HOME/.config/gtk-4.0/settings.ini"

# Reset xsettingsd
XSETTINGSD="$HOME/.config/xsettingsd/xsettingsd.conf"
if [[ -f "$XSETTINGSD" ]]; then
    sed -i "s|Net/IconThemeName \".*\"|Net/IconThemeName \"$FALLBACK_THEME\"|" "$XSETTINGSD"
    echo "  Reset: $XSETTINGSD"
fi

# Reset dconf
if command -v dconf &>/dev/null; then
    dconf write /org/gnome/desktop/interface/icon-theme "'$FALLBACK_THEME'" 2>/dev/null || true
    echo "  Reset dconf"
fi

# Restore backup if it exists
BACKUP=$(find "$HOME/.local/share/icons" -maxdepth 1 -name "${THEME_NAME}.bak.*" -type d 2>/dev/null | sort -r | head -1)
if [[ -n "$BACKUP" ]]; then
    echo ""
    echo "Backup found: $BACKUP"
    read -rp "Restore backup? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        mv "$BACKUP" "$INSTALL_DIR"
        echo "Restored backup."
    fi
fi

echo ""
echo "=== Uninstallation complete! ==="
echo "Theme '$THEME_NAME' has been removed."
