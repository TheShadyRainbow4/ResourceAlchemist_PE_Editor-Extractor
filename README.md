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

## Version
Document Version: 1.2.0.0
