#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for waybar styles

set -euo pipefail
IFS=$'\n\t'

# Define directories
waybar_styles="$CURRENT_CONFIG_DIR/waybar/style"
waybar_style="$CURRENT_CONFIG_DIR/waybar/style.css"
SCRIPTSDIR="$CURRENT_CONFIG_DIR/hypr/scripts"
rofi_config="$CURRENT_CONFIG_DIR/rofi/config-waybar-style.rasi"

# Function to display menu options
menu() {
    options=()
    while IFS= read -r file; do
        if [ -f "$waybar_styles/$file" ]; then
            options+=("$(basename "$file" .css)")
        fi
    done < <(find "$waybar_styles" -maxdepth 1 -type f -name '*.css' -exec basename {} \; | sort)
    
    printf '%s\n' "${options[@]}"
}

# Apply selected style
apply_style() {
    ln -sf "$waybar_styles/$1.css" "$waybar_style"
    "${SCRIPTSDIR}/Refresh.sh" &
}

# Main function
main() {
    choice=$(menu | rofi -i -dmenu -config "$rofi_config")

    if [[ -z "$choice" ]]; then
        echo "No option selected. Exiting."
        exit 0
    fi

    apply_style "$choice"
}

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

main
