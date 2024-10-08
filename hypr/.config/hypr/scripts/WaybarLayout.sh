#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for waybar layout or configs

set -euo pipefail
IFS=$'\n\t'

# Define directories
waybar_layouts="$CURRENT_CONFIG_DIR/waybar/configs"
waybar_config="$CURRENT_CONFIG_DIR/waybar/config"
SCRIPTSDIR="$CURRENT_CONFIG_DIR/hypr/scripts"
rofi_config="$CURRENT_CONFIG_DIR/rofi/config-waybar-layout.rasi"

# Function to display menu options
menu() {
    options=()
    while IFS= read -r file; do
        options+=("$(basename "$file")")
    done < <(find "$waybar_layouts" -maxdepth 1 -type f -exec basename {} \; | sort)

    printf '%s\n' "${options[@]}"
}

# Apply selected configuration
apply_config() {
    ln -sf "$waybar_layouts/$1" "$waybar_config"
    #restart_waybar_if_needed
    "${SCRIPTSDIR}/Refresh.sh" &
}

# Main function
main() {
    choice=$(menu | rofi -i -dmenu -config "$rofi_config")

    if [[ -z "$choice" ]]; then
        echo "No option selected. Exiting."
        exit 0
    fi

    case $choice in
        "no panel")
            pgrep -x "waybar" && pkill waybar || true
            ;;
        *)
            apply_config "$choice"
            ;;
    esac
}

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

main
