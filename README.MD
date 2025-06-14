# ForkLift Direct Copy & Extract Tool

This file provides instructions for setting up and using a custom Bash script as a tool within ForkLift (a dual-pane file manager for macOS). This tool allows you to perform direct file and folder copies, including extracting `.zip` archives, bypassing ForkLift's default "Activities" progress UI.

## What the Script Does

The `direct-copy-extract-zip.sh` script is designed to enhance your workflow in ForkLift by:

- **Direct Copying:** It instantly copies selected files and folders from the source pane to the target pane using the macOS `ditto` command.

- **Automatic Zip Extraction:** If a selected item in the source pane is a `.zip` archive, the script will automatically extract its contents to a temporary location first, and then copy those extracted contents to your designated target folder.

- **Bypassing ForkLift's Activity UI:** Unlike ForkLift's built-in copy operations, processes initiated by this script will **not** appear in ForkLift's "Activities" pane. This provides a sense of instantaneous completion for successful transfers and can run at the same time as other ForkLift acitivies are running (for example you have queued up some operations in Activities, but you need this to complete instantly and not at the end of the Activities list; keep in mind that if your current operation performed by this tools is a big/resource busy one, such as copying or extracting large files, especially to remote locations, it would still take the necessary time needed for it to complete, so the context of the term 'instant' needs to account for that!)

## Safety Information

This script is designed with safety in mind, particularly concerning temporary files:

- **Temporary File Cleanup:** Whenever the script extracts a `.zip` file, it creates a unique, temporary directory using `mktemp -d`. A `trap` command is set at the beginning of the script to guarantee that all such temporary directories are automatically and securely removed (`rm -rf`) when the script finishes execution, whether successfully or due to an error. This prevents temporary files from accumulating and cluttering your system.

- **Isolated Operation:** The script operates only on the paths explicitly passed to it by ForkLift. It does not access or modify any other files or processes on your system, nor does it interfere with ForkLift's internal operations or other temporary files created by other applications.

## Setup Instructions

Follow these steps to set up the script as a custom tool in ForkLift:

1. **Save the Script:**

   - Copy the complete content of the `forklift-direct-copy-extract-zip-tool`.

   - Open a plain text editor (e.g., TextEdit, VS Code, Sublime Text).

   - Paste the script content into the editor.

   - Save the file with a `.sh` extension (e.g., `direct-copy-extract-zip.sh`) in a convenient location, such as `~/Documents/ForkLift-Scripts/` (you might need to create this folder).

2. **Make the Script Executable:**

   - Open the macOS Terminal application (Applications > Utilities > Terminal).

   - Run the following command, replacing `~/Documents/ForkLift-Scripts/direct-copy-extract-zip.sh` with the actual path where you saved your script:

     ```
     chmod +x ~/Documents/ForkLift-Scripts/direct-copy-extract-zip.sh

     ```

3. **Add to ForkLift as a Custom Tool:**

   - Open ForkLift.

   - Go to the menu bar: **Commands > Manage Tools...**

   - Click the **"+"** button at the bottom-left of the "Tools" window to add a new tool.

   - In the "Tool Name" field, enter a descriptive name, for example: `Direct Copy & Extract`.

   - For "Type," select **"Script."** (if asked, some ForkLift versions wouldn't ask)

   - Click the **"Choose..."** button next to the "Script" field and navigate to select your `direct-copy-extract-zip.sh` file, or if Scripts are not in the ForkLift UI paste in the path to your script file, for example:

   ```
   ~/Documents/ForkLift-Scripts/direct-copy-extract-zip.sh "$SOURCE_SELECTION_PATHS" "$TARGET_PATH"
   ```

   - **Crucially, in the "Arguments" field, you must enter the following exactly as shown, including the double-quotes:**

     ```
     "$SOURCE_SELECTION_PATHS" "$TARGET_PATH"

     ```

   - Enable the option **Enable for remote files** if you want to use this with networks shares etc.

   - Enable the option **Run for every selected file** (available in ForkLift 4+ at the time of writing) if you want to use the script when multiple files are selected as source.

   - Click **"Save."**

## How to Use the Tool

1. **Prepare Panes:**

   - In one ForkLift pane (your "source" pane), navigate to and select the file(s) or folder(s) you wish to copy.

     - **For regular files/folders:** Simply select them.

     - **For `.zip` archives:** Select the `.zip` file itself. **Do NOT double-click into the `.zip` to browse its contents** if you want this tool to handle the extraction. This tool is designed to take the `.zip` file as its input.

   - In the other ForkLift pane (your "target" pane), navigate to and open the destination directory where you want the copied/extracted items to appear.

2. **Run the Tool:**

   - Go to the ForkLift menu bar: **Commands > Direct Copy & Extract** (or whatever you named your tool).

   - Alternatively, if you've added it to your toolbar, click its icon.

The script will execute the copy/extraction in the background. You will not see a progress bar in ForkLift's Activities pane. If an error occurs, a message will be displayed in ForkLift's log or console output.

## Assigning a Keyboard Shortcut (e.g., CTRL+X)

For even quicker access, you can assign a keyboard shortcut to your new tool:

1. **Open ForkLift Settings:**

   - Go to the ForkLift menu bar: **ForkLift > Settings...**

2. **Navigate to Shortcuts:**

   - In the Settings window, click on **"Shortcuts"** in the sidebar.

3. **Find Your Tool:**

   - In the list of commands, scroll down to the "Tools" section. You should see your "Direct Copy & Extract" tool listed there.

4. **Assign the Shortcut:**

   - Click on the empty "Shortcut" field next to your "Direct Copy & Extract" tool.

   - Press the desired keyboard combination, e.g., **Control (⌃) + X**.

   - Make sure this shortcut doesn't conflict with any existing ForkLift shortcuts. If it does, ForkLift might warn you or it might not work as expected. You may need to choose an alternative or modify the conflicting shortcut.

5. **Close Settings:**

   - Close the Settings window. Your shortcut is now active.

Now you can simply select your source items (including `.zip` files) and the target folder, then press `Control + X` to trigger the direct copy/extraction.
