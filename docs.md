# Resource Alchemy Hacker

EliteSoftwareTech Co. - Antigravity Suite

## Description
Resource Alchemy Hacker is a native C++ application for viewing, extracting, and replacing resources in Windows executables (PE files).
It serves as a modernized clone of Resource Hacker and includes three main components:
1. **CLI Engine (`ResourceAlchemyHacker_CLI`)**: The backend worker executable that performs all resource extraction and injection using Win32 API.
2. **GUI Application (`ResourceAlchemyHacker_GUI`)**: The frontend Win32 application adhering to EliteSoftware GUI guidelines (Native Win32 aesthetics, Client Edge, Chin, 3D inset, etc.).
3. **Shell Extension (`ResourceAlchemyHacker_ShellExt`)**: A native C++ COM Shell Extension. It provides:
   - Cascading context menus for quick extraction/viewing.
   - A property sheet tab for executable files that lists resources (e.g., icons) like the native icon picker, and allows on-the-fly replacement of resources in system files (using backup renaming strategies).

## Project Structure
- `/ResourceAlchemyHacker_CLI/` - Backend command line tool
- `/ResourceAlchemyHacker_GUI/` - Main Win32 application
- `/ResourceAlchemyHacker_ShellExt/` - COM Shell Extension (replaces old SharpShell implementation)
- `/Installer/` - InnoSetup script for deployment

## Development Guidelines
- Strictly follows EliteSoftwareTech Co. guidelines for native Win32/WinForms aesthetics.
- Visual Styles must always be explicitly enabled.
- Title banner and 3D Inset Area.
- Dynamic Icon Targeting.

## Features (v1.4.0.0 Update)
- **Advanced Resource Previews:**
  - Full Image rendering (Icons, Bitmaps, Cursors, Cursor Groups, Icon Groups).
  - Native AVI and WAV audio playback seamlessly integrated into the GUI.
  - Interactive Text Previews for Manifests, String Tables, Version Info, and Dialogs.
- **Resource Replacement & Extraction:**
  - Intuitive "Replace Resource" dialog with side-by-side graphical previews of original and new resources.
  - Seamless extraction and deletion of resources.
  - Accelerated hotkeys (Ctrl+R) and Context Menu support within the TreeView.
- **Enhanced UI & Aesthetics:**
  - Deep system-level icons dynamically loaded for all specific resource types in the TreeView (Audio, Images, XML, Manifests, Menus).
  - Legacy horizontal scrollbars hidden for a cleaner look (`TVS_NOHSCROLL`).
  - Strict adherence to EliteSoftwareTech Co. guidelines (Client Edge, 3D inset).
  - Registry-based persistence of Window dimensions and settings across sessions.
- **Full Menu Parity:**
  - 25+ classic Resource Hacker functions accessible via native Win32 dropdown menus (`File`, `Edit`, `View`, `Action`, `Help`).

## Detailed Component Documentation

### 1. CLI Engine (`ResourceAlchemyHacker_CLI`)
The CLI is a headless command-line tool that performs resource modifications on PE files.
It is designed to be called programmatically by scripts, build tools, or the GUI.

**Syntax:**
`ResourceAlchemyHacker_CLI.exe <action> <target_file> [type] [name] [lang] [file]`

**Actions:**
- `/list`: Outputs a structured listing of all resources in `<target_file>`.
  - Example: `ResourceAlchemyHacker_CLI.exe /list C:\app.exe`
- `/extract`: Extracts a specific resource to an output file.
  - Example: `ResourceAlchemyHacker_CLI.exe /extract C:\app.exe #14 #1 1033 out.ico`
- `/replace`: Replaces an existing resource with data from `<file>`.
  - Example: `ResourceAlchemyHacker_CLI.exe /replace C:\app.exe #14 #1 1033 new_icon.ico`
- `/add`: Adds a new resource from `<file>`.
  - Example: `ResourceAlchemyHacker_CLI.exe /add C:\app.exe #2 #100 1033 image.bmp`
- `/delete`: Deletes a specific resource.
  - Example: `ResourceAlchemyHacker_CLI.exe /delete C:\app.exe #2 #100 1033`

*Note: Types and Names can be strings (e.g. `ICON`) or integers prefixed with `#` (e.g. `#14` for RT_GROUP_ICON). Language should be a numeric LCID (e.g. 1033 for English-US).*

### 2. Shell Extension (`ResourceAlchemyHacker_ShellExt`)
The Shell Extension integrates Resource Alchemy Hacker directly into Windows Explorer using a native C++ COM implementation.
- **Context Menus:** Right-clicking any PE file (.exe, .dll, .sys, etc.) provides quick shortcuts to Extract All Resources or Open in Resource Alchemy Hacker.
- **Property Sheet Tab:** Right-clicking a PE file and selecting "Properties" displays a new "Resources" tab.
  - The tab lists resources in a graphical grid (similar to the Windows icon picker).
  - Users can view and extract resources directly from the properties window without opening the full application.

### Important Note on MUI and MUN Files
Modern Windows (Vista and later) frequently uses Multilingual User Interface (MUI) files and MUN files (in `C:\Windows\SystemResources`) to store localized resources (like icons, strings, and dialogs) separate from the main binary.
- When opening a system DLL (e.g. `imageres.dll`), the GUI will display resources dynamically loaded from its associated `.mui` or `.mun` file.
- **Warning:** Saving modifications to the original `.dll` file using this tool **will only write to the `.dll`**. It will **not** modify the `.mui` or `.mun` file. Because of strict core Windows `UpdateResource` API limitations, attempting to modify an icon or resource on a "stub" DLL that forwards to an MUI/MUN file may fail with **Error 50 (ERROR_NOT_SUPPORTED)**.
- **Solution:** To effectively modify system resources and avoid "Error 50", you must explicitly open and edit the actual `.mun` or `.mui` file directly (e.g., `C:\Windows\SystemResources\imageres.dll.mun`), rather than attempting to edit the base stub DLL.

## Version
Document Version: 1.3.1.0


<hr>


