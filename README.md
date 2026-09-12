# MacOS Icons

A custom macOS Tahoe-style icon theme for Linux with a Nord dark color scheme and personalized app icons.

Based on [MacTahoe-icon-theme](https://github.com/vinceliuice/MacTahoe-icon-theme) by Vince Liuice, with custom icons for popular applications.

## Included Custom Icons

| App | Icon Name(s) |
|-----|--------------|
| Chrome | `google-chrome`, `com.google.Chrome`, `chrome` |
| Files | `org.gnome.Nautilus`, `nautilus`, `org.gnome.files` |
| Ghostty | `com.mitchellh.ghostty` |
| LocalSend | `org.localsend.localsend_app`, `localsend` |
| Minecraft | `minecraft`, `com.mojang.Minecraft` |
| Obsidian | `md.obsidian.Obsidian`, `obsidian` |
| OBS Studio | `com.obsproject.Studio`, `obs` |
| Settings | `system-settings`, `org.gnome.Settings` |
| Spotify | `spotify`, `com.spotify.Client` |
| Telegram | `telegram`, `org.telegram.desktop` |
| Zed | `zed`, `dev.zed.Zed` |
| Zen Browser | `zen-browser`, `zen_browser` |
| ChatGPT | `chatgpt`, `com.openai.ChatGPT` |

## Requirements

- `gtk-update-icon-cache` (part of GTK)
- `imagemagick` or `magick` (for building from PNGs)
- A GTK-based desktop environment (GNOME, XFCE, KDE Plasma, etc.)

## Installation

### Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/MacOS Icons.git
cd MacOS Icons
./install.sh
```

### Manual Install

```bash
cp -r MacOS ~/.local/share/icons/MacOS Icons
gtk-update-icon-cache -f -t ~/.local/share/icons/MacOS Icons
```

Then set the icon theme in your desktop settings, or:

```bash
# GTK 3
sed -i 's/gtk-icon-theme-name=.*/gtk-icon-theme-name=MacOS Icons/' ~/.config/gtk-3.0/settings.ini

# GTK 4
sed -i 's/gtk-icon-theme-name=.*/gtk-icon-theme-name=MacOS Icons/' ~/.config/gtk-4.0/settings.ini

# dconf (GNOME)
dconf write /org/gnome/desktop/interface icon-theme "'MacOS Icons'"
```

## Uninstallation

```bash
./uninstall.sh
```

This will:
- Remove the theme from `~/.local/share/icons/`
- Reset GTK settings to the `hicolor` fallback
- Offer to restore any previous backup

## Adding Your Own Icons

1. Place your PNG icons (1024x1024 recommended) in the `icons/` directory:

2. Edit `build-icons.sh` and add your app to the `ICON_MAP`:

```bash
declare -A ICON_MAP=(
    ["YourApp"]="com.your.App your-app-icon"
    # ... other entries
)
```

3. The mapping format is:
   - Key: PNG filename without extension (e.g., `YourApp` for `YourApp.png`)
   - Value: Space-separated list of target SVG names (the icon names apps request)

4. Run the build script:

```bash
./build-icons.sh
```

5. Install:

```bash
./install.sh
```

## Rebuilding After Changes

```bash
./build-icons.sh   # Rebuild icons
./install.sh       # Reinstall
```

## Project Structure

```
MacOS Icons/
├── install.sh             # Install the theme
├── uninstall.sh           # Remove the theme
├── build-icons.sh         # Convert PNGs to theme icons
├── icons/                 # Source PNG icons
├── README.md              # This file
└── MacOS/                 # The icon theme
    ├── index.theme        # Theme metadata
    ├── apps/              # App icons (scalable/, 16/, 22/, 32/)
    ├── apps@2x/           # HiDPI app icons
    ├── actions/           # UI action icons
    ├── categories/        # Category icons
    ├── devices/           # Device icons
    ├── emblems/           # Emblem icons
    ├── emotes/            # Emoticon icons
    ├── mimes/             # MIME type icons
    ├── places/            # Folder/location icons
    ├── preferences/       # Settings icons
    └── status/            # Status icons
```

## License

GPL v3 - See [COPYING](MacOS/COPYING) for details.

## Credits

- [WhiteSur-icon-theme](https://github.com/vinceliuice/WhiteSur-icon-theme) - Original base theme
- [MacTahoe-icon-theme](https://github.com/vinceliuice/MacTahoe-icon-theme) - macOS Tahoe adaptation
