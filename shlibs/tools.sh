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

