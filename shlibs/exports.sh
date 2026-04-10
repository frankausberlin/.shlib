# exportfolder: Exports environment variables from files in SHLIB_EXPORTS_DIR.
#
# Usage: exportfolder [--dry-run]
#
# Parameters:
#   --dry-run: Preview what would be exported without actually exporting.
#
# Description: Reads all files in SHLIB_EXPORTS_DIR, where filename is variable name and content is value.
# Exports them and displays a formatted list.
#
# Examples:
#   exportfolder  # Export variables from ~/.config/_exports/
#   exportfolder --dry-run  # Preview what would be exported
exportfolder () {
    local dry_run=false
    if [ "$1" = "--dry-run" ]; then
        dry_run=true
    fi

    # use all files in $HOME/.config/_exports as environment variables
    # each file's name is the variable name and the file's content is the variable value

    # check if the directory exists
    if [ ! -d "$SHLIB_EXPORTS_DIR" ]; then
        echo "Directory $SHLIB_EXPORTS_DIR does not exist. No variables exported."
        return 1
    fi

    # Loop through all files in the directory
    count=-1
    for file in "$SHLIB_EXPORTS_DIR"/*; do
        ((count++)); ((count % 5 == 0 && count != 0)) && echo -n $'\n'
        # Check if it's a regular file
        if [ -f "$file" ]; then
        # Extract the filename without the path
        var_name=$(basename "$file")
        # Read the file content
        var_value=$(cat "$file")
        # Export the variable or preview
        if [ "$dry_run" = true ]; then
            printf "Would export %-28s = %s\n" "$var_name" "$var_value"
        else
            export "$var_name"="$var_value"
            # Print a message (optional)
            printf "%-28s " "$var_name"
        fi
        fi
    done
}

for f in "$SHLIB_EXPORTS_DIR"/*; do [ -f "$f" ] && export "$(basename "$f")"="$(cat "$f")"; done

for file in "$SHLIB_EXPORTS_DIR"/*; do
    # Check if it's a regular file
    if [ -f "$file" ]; then
    # Export the variable or preview
    export $(basename "$file")=$(cat "$file")
    fi
done

# exportadd: Adds a path to an environment variable, ensuring uniqueness.
#
# Usage: exportadd <PATH> [VARIABLE_NAME] [Position] [--dry-run]
#
# Parameters:
#   PATH: The directory path to be added (required).
#   VARIABLE_NAME: The name of the environment variable (default: PATH).
#   Position: 'append' (to the end) or 'prepend' (to the beginning, default).
#   --dry-run: Preview changes without applying them.
#
# Description: Checks if the path exists and is not already in the variable before adding.
# Uses colon-separated paths for accurate matching.
#
# Examples:
#   exportadd /usr/local/bin  # Prepend to PATH
#   exportadd /opt/bin LD_LIBRARY_PATH append  # Append to LD_LIBRARY_PATH
#   exportadd /home/user/bin --dry-run  # Preview adding to PATH
exportadd() {
    # 1. Parameter Check: Ensure a path was provided
    if [ -z "$1" ]; then
        echo "Error: A path must be specified (Parameter 1)." >&2
        return 1
    fi

    local target_path="$1"
    local var_name="${2:-PATH}" # Takes P2 or defaults to 'PATH'
    local mode="${3:-prepend}"  # Takes P3 or defaults to 'prepend'
    local dry_run=false

    if [ "$4" = "--dry-run" ]; then
        dry_run=true
    fi

    # Validate variable name
    if ! [[ "$var_name" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
        echo "Error: Invalid variable name '$var_name'." >&2
        return 1
    fi

    # Validate mode
    if [ "$mode" != "append" ] && [ "$mode" != "prepend" ]; then
        echo "Error: Position must be 'append' or 'prepend'." >&2
        return 1
    fi

    # Dynamically fetch the current value of the environment variable using indirect expansion
    local current_var_value="${!var_name}"

    # 2. Existence Check: Optional but recommended for PATH-like variables
    if [ ! -d "$target_path" ]; then
        # Silent return if the directory does not exist.
        return 0
    fi

    # 3. Duplication Check: Check if the path is already contained in the variable
    # We add colons to the search string to ensure clean matches (e.g., prevents matching "a/bin" in "b/a/bin")
    case ":$current_var_value:" in
        *":$target_path:"*)
            # Path already present
            if [ "$dry_run" = true ]; then
                echo "Dry-run: Path '$target_path' already in $var_name"
            fi
            return 0
            ;;
        *)
            # Path not found, now add it
            if [ "$dry_run" = true ]; then
                if [ "$mode" = "append" ]; then
                    echo "Dry-run: Would append '$target_path' to $var_name"
                else
                    echo "Dry-run: Would prepend '$target_path' to $var_name"
                fi
            else
                if [ "$mode" = "append" ]; then
                    # Append the path to the END: VAR=OLD_VALUE:NEW_PATH
                    export "$var_name"="$current_var_value:$target_path"
                else
                    # Prepend the path to the BEGINNING (Default): VAR=NEW_PATH:OLD_VALUE
                    export "$var_name"="$target_path:$current_var_value"
                fi
            fi
            return 0
            ;;
    esac
}




# ==============================================================================
# @description Cleans up a colon-separated path variable (e.g. PATH).
# Removes non-existent directories, deletes duplicates and 
# automatically creates a backup of the original variable.
#
# @param $1 The name of the environment variable to be cleaned up (e.g. PATH).
#
# @return 0 on successful cleanup.
#1 if the variable passed is empty or not set.
#
# @example repair_path "PATH"
# repair_path "LD_LIBRARY_PATH"
# ==============================================================================
repair_path() {
    local var_name="$1"
    
    # Read the original value of the variable (indirect expansion)
    local original_val="${!var_name}"
    
    [[ -z "$original_val" ]] && return 1

    # Create a backup of the original variable (e.g. PATH_backup)
    export "${var_name}_backup"="$original_val"

    # Filter out redundant and non-existent paths
    local new_path=""
    local IFS=':'
    
    for dir in $original_val; do
        # Check if the directory exists
        if [[ -d "$dir" ]]; then
            # Check if the path is NOT already included in new_path
            # (String matching is safer than `=~` if paths contain "+" or ".")
            if [[ ":$new_path:" != *":$dir:"* ]]; then
                # Appends the path. Automatically sets the colon, 
                # if new_path is no longer empty.
                new_path="${new_path:+$new_path:}$dir"
            fi
        fi
    done
    
    # Export repaired variable
    export "$var_name"="$new_path"

    return 0
}
