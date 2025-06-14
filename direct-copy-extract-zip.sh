#!/bin/bash

# ForkLift App Tool: Direct Copy & Extract Zip
# This script directly copies selected files and folders to the target pane.
# If a selected item is a .zip file, it extracts its contents to a temporary
# location and then copies those extracted contents to the target.
#
# This tool is designed to bypass ForkLift's internal activity tracking,
# meaning operations performed by this script will NOT appear in the
# "Activities" list.
#
# SAFETY NOTE: This script is designed to be safe regarding temporary files.
# It creates unique temporary directories for extraction and ensures their
# automatic deletion upon script completion, preventing leftover clutter.
# It operates only on paths explicitly passed to it and does not interfere
# with other system files or processes.
#
# Usage in ForkLift Tools:
# Set "Arguments" to: "$SOURCE_SELECTION_PATHS" "$TARGET_PATH"
#
# Parameters passed by ForkLift:
# $1: SOURCE_SELECTION_PATHS (space-separated list of absolute paths to selected files/folders)
# $2: TARGET_PATH (absolute path of the directory open in the target pane)

# --- Script Start ---

# Trap to ensure temporary directories are cleaned up even if the script exits unexpectedly.
# This mechanism guarantees that any temporary directories created by this script
# for zip extraction are automatically removed upon script exit, whether it's
# a successful completion or an error. This prevents temporary files from
# accumulating on your system.
declare -a TEMP_DIRS_TO_CLEANUP
trap 'for dir in "${TEMP_DIRS_TO_CLEANUP[@]}"; do rm -rf "$dir"; done' EXIT

# Check if the correct number of arguments are provided.
# This is crucial for the script to function as intended.
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments provided by ForkLift." >&2
    echo "This script requires exactly 2 arguments (selected source paths and target path)." >&2
    echo "Please ensure you have items selected in the source pane AND a directory open in the target pane." >&2
    echo "The issue may stem from how ForkLift populates \$SOURCE_SELECTION_PATHS or \$TARGET_PATH for external scripts." >&2
    exit 1
fi

# Assign the passed parameters to descriptive variables
SOURCE_SELECTION_PATHS_PARAM="$1"
TARGET_PATH_PARAM="$2"

# Validate that the parameters are not empty after assignment
if [ -z "$SOURCE_SELECTION_PATHS_PARAM" ]; then
    echo "Error: Source selection paths parameter is empty. No items were passed to copy." >&2
    exit 1
fi

if [ -z "$TARGET_PATH_PARAM" ]; then
    echo "Error: Target path parameter is empty. No destination was specified." >&2
    exit 1
fi

# Save original IFS
OLDIFS=$IFS
# Set IFS to handle spaces in filenames correctly when iterating over SOURCE_SELECTION_PATHS_PARAM
# This will split the single string argument into individual paths based on whitespace.
IFS=$'\n' # Use newline as IFS to handle paths containing spaces, assuming ForkLift separates with newlines or spaces.

# Loop through each path provided in SOURCE_SELECTION_PATHS_PARAM.
for SOURCE_ITEM in $SOURCE_SELECTION_PATHS_PARAM; do
    # Remove leading/trailing whitespace from SOURCE_ITEM
    SOURCE_ITEM=$(echo "$SOURCE_ITEM" | xargs)

    # Check if the source item is a regular file/directory that exists.
    # This covers items selected directly from the file system.
    if [ -e "$SOURCE_ITEM" ]; then
        # Check if the SOURCE_ITEM is a .zip file.
        if [[ "$SOURCE_ITEM" == *.zip ]]; then
            # Create a temporary directory for extraction
            # `mktemp -d` creates a unique and secure temporary directory,
            # preventing name collisions and unauthorized access.
            TEMP_DIR=$(mktemp -d -t forklift_zip_extract_XXXXXX)
            if [ $? -ne 0 ]; then
                echo "Error: Failed to create temporary directory for '$SOURCE_ITEM'. Skipping." >&2
                continue # Skip to the next item
            fi
            TEMP_DIRS_TO_CLEANUP+=("$TEMP_DIR") # Add to list for global cleanup trap

            # Use 'unzip' to extract the entire zip file.
            # -q: quiet mode (suppress verbose output)
            # -d: destination directory
            unzip -q "$SOURCE_ITEM" -d "$TEMP_DIR"
            UNZIP_STATUS=$?

            if [ "$UNZIP_STATUS" -ne 0 ]; then
                echo "Error: Failed to extract '$SOURCE_ITEM' (unzip exit code: $UNZIP_STATUS). Skipping." >&2
                continue # Skip to the next item
            fi

            # Now, copy the *contents* of the temporary directory to the final target.
            # This handles cases where unzip creates a top-level folder inside TEMP_DIR
            # or extracts directly into TEMP_DIR.
            ditto "$TEMP_DIR"/ "$TARGET_PATH_PARAM"
            DITTO_STATUS=$?

            if [ "$DITTO_STATUS" -ne 0 ]; then
                echo "Error: Failed to copy extracted contents from '$TEMP_DIR' to '$TARGET_PATH_PARAM'. Skipping." >&2
                continue # Skip to the next item
            fi

        else
            # --- Handle copying of regular files/folders ---
            ditto "$SOURCE_ITEM" "$TARGET_PATH_PARAM"
            DITTO_STATUS=$?
            if [ "$DITTO_STATUS" -ne 0 ]; then
                echo "Error: Failed to copy '$SOURCE_ITEM' to '$TARGET_PATH_PARAM'." >&2
                exit 1 # Exit on first error for regular file copy
            fi
        fi
    else
        echo "Error: Source item '$SOURCE_ITEM' does not exist or is not directly accessible. Skipping." >&2
        # This error likely indicates an issue with ForkLift passing virtual paths
        # or the selected item not being a real file system path.
        continue
    fi
done

# Restore original IFS
IFS=$OLDIFS

exit 0
