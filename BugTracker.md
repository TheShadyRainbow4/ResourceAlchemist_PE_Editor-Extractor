# Resource Alchemy Hacker - Bug & Feature Tracker

## Known Bugs
1. **Initial Layout Scaling Issue**
   - **Symptom:** UI elements (main active area, toolbar, status bar) do not automatically scale or refresh to fit the window size on launch. Only fixes itself after manual window resizing.
   - **Cause:** `WM_SIZE` event is likely not propagating correctly to all child controls (like `g_hwndInset`, `g_hwndStatus`) *after* they are fully initialized during `WM_CREATE` or in `WinMain`.
   - **Planned Fix:** Explicitly post or send a `WM_SIZE` message to the main window handle immediately after all UI initialization is complete in `WinMain`, forcing a complete layout recalculation.

2. **TreeView Icon Previews**
   - **Symptom:** Navigation tree fails to show individual previews for Icons or Icon Groups. It displays the custom root node icon for all child items instead of their actual icon.
   - **Planned Fix:** Update `GuiListResources` or TreeView image list logic to dynamically extract and assign the correct `HBITMAP`/`HICON` indices to child nodes corresponding to `RT_ICON` and `RT_GROUP_ICON` resources.

3. **"Version Info" Text Rendering & Word Wrap**
   - **Symptom:** "Version Info" text sometimes shows broken mojibake characters (e.g., "䀁ᶰ?"). Text wraps between lines, which breaks syntax for scripts. No line numbers.
   - **Cause:** Encoding mismatch (e.g., trying to render UTF-16LE data as ASCII/ANSI, or misaligned byte length). Edit control is missing `WS_HSCROLL` and `ES_AUTOHSCROLL` window styles.
   - **Planned Fix:** Force proper Unicode string conversion for Version Info resource data. Add horizontal scroll styles to the multi-line edit control, and implement a custom side-panel or gutter for line numbers.

4. **"Extract Monolithic" Behavior**
   - **Symptom:** Currently saves a broken DLL/EXE instead of extracting all resources to folders.
   - **Planned Fix:** Rewrite the "Extract Monolithic" action to iterate over all resources, create a structured folder hierarchy (e.g., `OutputDir/Icon Groups/`, `OutputDir/Bitmaps/`), and dump each resource as its native file type. Ignore the raw "Icons" section to avoid duplication, relying solely on "Icon Groups".

5. **Right-Click Node Extraction (Context Menu)**
   - **Symptom:** Missing ability to right-click a specific tree node (e.g., "Bitmaps") and extract all items under that specific node type.
   - **Planned Fix:** Add a context menu handler for the TreeView (`WM_CONTEXTMENU`), detect the node type, and iterate its children to extract them all into a user-specified folder.

6. **Action Menu Items Non-Functional**
   - **Symptom:** Menu options in the "Action" menubar don't do anything or are confusingly separated by type.
   - **Planned Fix:** Wire up the `WM_COMMAND` handlers for the Action menu to intelligently detect the currently selected resource in the TreeView, contextually applying the action (Replace/Extract) without needing separate confusing entries.

7. **"Add from resource script res / rc" Broken**
   - **Symptom:** Menu option does nothing.
   - **Planned Fix:** Implement the file dialog and CLI backend invocation to parse and compile `.rc`/`.res` files and inject them into the PE.

8. **Settings Dialog Aesthetic Clipping**
   - **Symptom:** Checkboxes and fields clip or are poorly positioned. Missing the matching title banner color gradient.
   - **Planned Fix:** Adjust `SettingsDlgProc` dialog resources and apply the same `WM_PAINT` banner gradient logic used in the main window.

9. **Drag and Drop Missing Functionality**
   - **Symptom:** Dragging a DLL onto the GUI executable only opens the GUI but doesn't load the file.
   - **Planned Fix:** Parse command-line arguments (`__argc`, `__argv` / `lpCmdLine`) in `WinMain`. If an argument is a valid PE file path, automatically call the open file routine during startup.

10. **Target File Corruption by Past AI Agent**
    - **Symptom:** `main.cpp` was recently overwritten with JSON log transcripts by an AI agent resulting in severe codebase corruption. 
    - **Planned Fix:** Fully restore `main.cpp` using local diff patches or git history before applying further logic fixes.

## Planned Improvements & New Features
1. **Auto-Backup System (`.bak` iteration)**
   - When saving, rename the original file to `.1.bak`, `.2.bak`, counting upwards automatically to prevent data loss.

2. **File Browser Style Viewer Tab**
   - A new view mode to see icon-sized previews of a selected tree node in a grid (similar to Windows Explorer large icons view), rather than just a list.

3. **"Demo File!" Update**
   - Rename "Test Imageres" button to "Demo File!".
   - Target `C:\Windows\SystemResources\shell32.dll.mun` (or `shell32.mun`).
   - Automatically copy it to the working directory before opening to prevent system file corruption.

4. **Intelligent Image Conversion on Replace**
   - When replacing an image asset, automatically convert formats (PNG <-> ICO, BMP, JPG).
   - If a PNG is provided for an Icon Group, auto-scale to multiple sizes (16, 24, 32, 48, 64, 96, 128, 256) and build an ICO container dynamically.
   - Attempt background removal (pink, gray, black) for imported BMPs.

5. **Configurable Tree Icon Sizes**
   - Add options in the Settings dialog to toggle TreeView icon sizes between 16x16, 24x24, and 32x32.

6. **State Persistence**
   - Remember window position, dimensions, and maintain a history of the last 30 opened files via Registry or config file.

7. **Interactive Dialog Previews**
   - Enable clicking a button or double-clicking a dialog resource to render and preview the actual Win32 Dialog box.
