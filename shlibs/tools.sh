# Function to set keyboard backlight color, brightness, or on/off
# Usage: kcol <color> [brightness] | kcol + | kcol - | kcol
# color: supported colors: red, green, blue, yellow, cyan, white
# brightness: optional, 0-10, default 10
# +: turn on backlight
# -: turn off backlight
# no args: show current status and help
kcol() {
    if [ $# -eq 0 ]; then
        # Show current status
        local state=$(cat /sys/devices/platform/clevo_xsm_wmi/kb_state 2>/dev/null || echo "unknown")
        local color=$(cat /sys/devices/platform/clevo_xsm_wmi/kb_color 2>/dev/null || echo "unknown")
        local brightness=$(cat /sys/devices/platform/clevo_xsm_wmi/kb_brightness 2>/dev/null || echo "unknown")
        echo "Current keyboard backlight status:"
        echo "  State: $state (1=on, 0=off)"
        echo "  Color: $color"
        echo "  Brightness: $brightness (0-10)"
        echo ""
        echo "Usage: kcol <color> [brightness] | kcol + | kcol -"
        echo "Colors: red, green, blue, yellow, cyan, white, magenta"
        echo "Examples: kcol blue 5, kcol +, kcol -"
        return 0
    fi

    local arg="$1"

    if [ "$arg" = "+" ]; then
        # Turn on backlight
        if ! sudo sh -c "echo 1 > /sys/devices/platform/clevo_xsm_wmi/kb_state" 2>/dev/null; then
            echo "Error: Failed to turn on backlight."
            return 1
        fi
        echo "Keyboard backlight turned on"
    elif [ "$arg" = "-" ]; then
        # Turn off backlight
        if ! sudo sh -c "echo 0 > /sys/devices/platform/clevo_xsm_wmi/kb_state" 2>/dev/null; then
            echo "Error: Failed to turn off backlight."
            return 1
        fi
        echo "Keyboard backlight turned off"
    else
        # Set color and brightness
        local color="$arg"
        local brightness="${2:-2}"  # Default brightness to 10 if not provided

        # Validate brightness range
        if ! [[ "$brightness" =~ ^[0-9]+$ ]] || [ "$brightness" -lt 0 ] || [ "$brightness" -gt 10 ]; then
            echo "Error: Brightness must be a number between 0 and 10"
            return 1
        fi

        # Set the color
        if ! sudo sh -c "echo '$color' > /sys/devices/platform/clevo_xsm_wmi/kb_color" 2>/dev/null; then
            echo "Error: Failed to set color. Check if the device is available."
            return 1
        fi

        # Set the brightness
        if ! sudo sh -c "echo '$brightness' > /sys/devices/platform/clevo_xsm_wmi/kb_brightness" 2>/dev/null; then
            echo "Error: Failed to set brightness. Check if the device is available."
            return 1
        fi

        echo "Keyboard backlight set to $color with brightness $brightness"
    fi
}


# adx: Android Debug Bridge utility for managing connections and listing packages.
#
# Usage: adx [command]
#
# Commands:
#   (no args): Show connected devices
#   x: Disconnect all devices
#   l: List packages on connected device
#   l <nr>: List packages on device at ADB_IP_PREFIX.<nr>
#   <nr>: Connect to device at ADB_IP_PREFIX.<nr>
#   <nr> <str>: List packages on device <nr> filtered by <str>
#   <str>: List packages on connected device filtered by <str>
#
# Parameters:
#   nr: Device number (1-255)
#   str: Filter string for package names
#
# Example:
#   adx 5  # Connect to 192.168.178.5
#   adx l browser  # List packages containing 'browser' on connected device
adx () {
    if ! command -v adb >/dev/null 2>&1; then
        echo "Error: adb command not found. Please install Android Debug Bridge." >&2
        return 1
    fi

    if [ "$#" -eq 0 ]; then
        adb devices
    else
        if [ "$1" = 'x' ]; then
            adb disconnect
        else
            if [ "$1" = 'l' ]; then
                if [ "$#" -eq 1 ]; then
                    adb shell pm list packages
                else
                    adb -s "192.168.178.$2" shell pm list packages
                fi
            else
                if [[ "$1" =~ ^[0-9]+$ ]]; then
                    if [ "$#" -eq 1 ]; then
                        adb connect "$ADB_IP_PREFIX$1"
                    else
                        adb -s "$ADB_IP_PREFIX$1" shell pm list packages | grep -i "$2"
                    fi
                else
                    adb shell pm list packages | grep -i "$1"
                fi
            fi
        fi
    fi
}


# RANDOM_EMOJI: Returns a random emoji from the EMOJIS array.
#
# Usage: RANDOM_EMOJI
#
# Description: Selects a random emoji from the predefined EMOJIS array.
# Used for terminal prompt customization.
#
# Example:
#   RANDOM_EMOJI  # Outputs a random emoji like 🐧 or 🤖
EMOJIS=(🐧 🤐 🥴 🤢 🤮 🤧 😷 🤒 🤕 🤑 🤠 😈 👿 👹 👺 🤡 💩 👻 💀 ☠️ 👽 👾 🤖 🎃 😺 😸 😹 😻 )
RANDOM_EMOJI() { echo "${EMOJIS[$RANDOM % ${#EMOJIS[@]}]}"; }

