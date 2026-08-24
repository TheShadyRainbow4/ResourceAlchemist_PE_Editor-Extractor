# Original User Request

## Initial Request — 2026-07-10T20:54:36-04:00

Build an automated build, test, and installer system for the Resource Alchemy Hacker project (CLI, GUI, ShellExt). The system must compile the components, run verification tests, and provide a clean installation and uninstallation experience for the end user.

Working directory: C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker
Integrity mode: development

## Requirements

### R1. Programmatic Integration Tests
Create an automated script that tests the compiled `ResourceAlchemyHacker_CLI.exe` by extracting a resource from a sample executable and replacing it, verifying the output.

### R2. Installer Generation
Create a standard Windows Installer (MSI) or an InnoSetup executable that packages the compiled CLI, GUI, and ShellExt DLL.

### R3. Shell Extension Registration
The installer must correctly register the Shell Extension COM DLL (`ResourceAlchemyHacker_ShellExt.dll`) during installation and cleanly unregister it during uninstallation.

## Acceptance Criteria

### Testing
- [ ] A test script exists and successfully executes the CLI `/extract` command on a target executable, producing a valid output file on disk.
- [ ] The test script executes the CLI `/replace` command and verifies the `_1.bak` backup is created and the target executable is updated.

### Installation
- [ ] Running the installer build process produces a single executable setup file (e.g., `.msi` or `.exe`).
- [ ] Installing the setup file copies the CLI, GUI, and DLL to a designated Program Files directory.
- [ ] The installer successfully registers the Shell Extension with the Windows Registry.
- [ ] Running the uninstaller cleanly removes the installed files and unregisters the Shell Extension.
