# Project: Resource Alchemy Hacker Build, Test, and Installer System

## Architecture
Resource Alchemy Hacker consists of three core components:
1. **CLI Engine (`ResourceAlchemyHacker_CLI.exe`)**: Reads, extracts, and replaces resources (like icons, strings, etc.) in PE files.
2. **GUI Client (`ResourceAlchemyHacker_GUI.exe`)**: Classic native Win32 GUI client wrapped in Windows aesthetics.
3. **Shell Extension DLL (`ResourceAlchemyHacker_ShellExt.dll`)**: A COM Shell Extension that provides right-click context menu integration and custom property sheet tabs for PE binaries.

The automated build, test, and installer system needs to:
- Build the solution and all 3 components using MSBuild/Visual Studio.
- Verify CLI features (resource extraction, replacement, and backup creation) via an automated integration test script.
- Build a standard InnoSetup installer executable that installs CLI, GUI, and ShellExt, registers the COM DLL, and cleanly uninstalls everything (including DLL unregistration).

## Code Layout
- `/ResourceAlchemyHacker_CLI/` - Source for CLI engine
- `/ResourceAlchemyHacker_GUI/` - Source for GUI app
- `/ResourceAlchemyHacker_ShellExt/` - Source for Shell Extension DLL
- `/tests/` - Directory for test scripts and test binaries (to be created)
- `/Installer/` - InnoSetup script and assets (to be created)

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | Explore & Compile | Inspect environment, verify MSBuild/compiler tools, build CLI, GUI, and ShellExt DLL. | None | DONE |
| 2 | CLI Integration Tests | Create integration test script and mock binaries to test `/extract`, `/replace`, and backups. | M1 | DONE |
| 3 | Shell Extension & GUI Compliance | Verify or implement ShellExt self-registration (`DllRegisterServer`/`DllUnregisterServer`) and GUI compliant options. | M1 | DONE |
| 4 | Installer & COM Registration | Build InnoSetup installer to copy files, register DLL, and cleanly unregister/uninstall. | M2, M3 | DONE |
| 5 | E2E Testing & Hardening | Complete full E2E testing of build, test, and installation cycle. Run Forensic Auditor. | M4 | DONE |

## Interface Contracts
- **CLI Commands**:
  - `ResourceAlchemyHacker_CLI.exe /list <target_exe>` - Lists resources.
  - `ResourceAlchemyHacker_CLI.exe /extract <target_exe> <type> <name> <lang> <outpath>` - Extracts resource.
  - `ResourceAlchemyHacker_CLI.exe /replace <target_exe> <type> <name> <lang> <inpath>` - Replaces resource, producing backup `<target_exe>_1.bak` or next index.
- **COM registration**:
  - `regsvr32.exe /s ResourceAlchemyHacker_ShellExt.dll` to register context menus and property pages.
  - `regsvr32.exe /u /s ResourceAlchemyHacker_ShellExt.dll` to unregister context menus and property pages.
