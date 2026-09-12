#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICONS_DIR="$SCRIPT_DIR/MacOS"
DOWNLOADS_DIR="${1:-$SCRIPT_DIR/icons}"

# Map: download filename (without extension) -> list of target SVG names (without extension)
declare -A ICON_MAP=(
    ["Chrome"]="google-chrome com.google.Chrome chrome"
    ["Files"]="org.gnome.Nautilus nautilus org.gnome.files io.elementary.files org.gnome.Files"
    ["Ghostty"]="com.mitchellh.ghostty"
    ["LocalSend"]="org.localsend.localsend_app localsend"
    ["Minecraft"]="minecraft com.mojang.Minecraft minecraft-launcher"
    ["Obsidian"]="md.obsidian.Obsidian obsidian Obsidian"
    ["OBS"]="com.obsproject.Studio obs"
    ["Settings"]="system-settings org.gnome.Settings gnome-settings"
    ["Spotify"]="spotify Spotify com.spotify.Client spotify-client eu.tiliado.NuvolaAppSpotify nuvolaplayer3_spotify"
    ["Telegram"]="telegram org.telegram.desktop telegram-desktop telegram-classic telegram-desktop-bin goa-account-telegram unity-webapps-telegram web-telegram"
    ["Zed"]="zed dev.zed.Zed zed-preview"
    ["Zen"]="zen-browser zen_browser app.zen_browser.zen zen-icon"
    ["ChatGPT"]="chatgpt com.openai.ChatGPT"
    ["VLC"]="vlc org.videolan.VLC"
)

png_to_svg() {
    local png_file="$1"
    local svg_file="$2"
    local size="${3:-1024}"

    local b64
    b64=$(base64 -w0 "$png_file")

    cat > "$svg_file" <<SVGEOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     viewBox="0 0 $size $size" width="$size" height="$size">
  <image width="$size" height="$size" xlink:href="data:image/png;base64,$b64"/>
</svg>
SVGEOF
}

resize_png() {
    local src="$1"
    local dst="$2"
    local size="$3"
    convert "$src" -resize "${size}x${size}" "$dst"
}

echo "=== Building custom icons ==="

for name in "${!ICON_MAP[@]}"; do
    png="$DOWNLOADS_DIR/${name}.png"
    if [[ ! -f "$png" ]]; then
        echo "  SKIP: $png not found"
        continue
    fi

    targets="${ICON_MAP[$name]}"
    echo "  Processing: $name -> $targets"

    for target in $targets; do
        # scalable (1024px SVG)
        svg="$ICONS_DIR/apps/scalable/${target}.svg"
        png_to_svg "$png" "$svg" 1024

        # @2x scalable
        svg_2x="$ICONS_DIR/apps@2x/scalable/${target}.svg"
        png_to_svg "$png" "$svg_2x" 2048

        # Generate sized PNGs then convert to SVG for each size dir
        for size_dir in 16 22 32; do
            tmp="/tmp/icon_resize_${name}_${size_dir}.png"
            resize_png "$png" "$tmp" "$size_dir"

            # 1x
            out="$ICONS_DIR/apps/${size_dir}/${target}.svg"
            png_to_svg "$tmp" "$out" "$size_dir"

            # @2x
            out_2x="$ICONS_DIR/apps@2x/${size_dir}/${target}.svg"
            png_to_svg "$tmp" "$out_2x" "$((size_dir * 2))"

            rm -f "$tmp"
        done
    done
done

echo "=== Rebuilding icon cache ==="
gtk-update-icon-cache -f -t "$ICONS_DIR" 2>/dev/null || true

echo "=== Done! ==="
echo "Theme built at: $ICONS_DIR"
