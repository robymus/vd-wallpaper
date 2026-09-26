#!/usr/bin/env bash
# Install or upgrade the plugin for the current user (~/.local/share/plasma/wallpapers).
#   ./install.sh            install/upgrade
#   ./install.sh --restart  also restart plasmashell so the new code is loaded
#   ./install.sh --remove   uninstall
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

PLUGIN_ID=local.vdwallpaper
KPT=(kpackagetool6 --type Plasma/Wallpaper)

usage() { sed -n '2,5s/^# \{0,1\}//p' "$0"; }

restart=false
case "${1:-}" in
    "") ;;
    --restart) restart=true ;;
    --remove)
        "${KPT[@]}" --remove "$PLUGIN_ID"
        echo "Removed. Containments still set to $PLUGIN_ID will show an error until you pick another wallpaper."
        exit 0
        ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
esac

if "${KPT[@]}" --show "$PLUGIN_ID" >/dev/null 2>&1; then
    "${KPT[@]}" --upgrade package
else
    "${KPT[@]}" --install package
fi

if $restart; then
    systemctl --user restart plasma-plasmashell.service
    echo "plasmashell restarted."
else
    echo "Restart plasmashell to load changes into running wallpapers:"
    echo "  systemctl --user restart plasma-plasmashell.service"
fi
