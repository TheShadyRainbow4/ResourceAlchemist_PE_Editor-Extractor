# Progress - Resource Alchemy Hacker Installer

**Last visited**: 2026-07-11T01:11:30Z

## Completed Steps
1. **Initial Assessment**: Verified existence of the compiled binaries in `C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\x64\Release`.
   - `ResourceAlchemyHacker_CLI.exe`
   - `ResourceAlchemyHacker_GUI.exe`
   - `ResourceAlchemyHacker_ShellExt.dll`
2. **Icon Copying**: Copied a system `.ico` file to `x64\Release\ResourceAlchemyHacker_GUI.ico` to enable dynamic icon loading alongside the GUI app.
3. **Inno Setup Script**: Wrote `setup.iss` in the `Installer` directory configuring metadata, files to copy, the `regserver` registry flag for COM DLL registration, and shortcuts.
4. **Initial Installer Compilation**: Compiled `setup.iss` using `ISCC.exe` to produce `setup.exe` successfully.
5. **Silent Installation Verification**:
   - Ran `setup.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART`.
   - Verified that files were correctly copied to `C:\Program Files\EliteSoftware\Resource Alchemy Hacker`.
   - Verified that the COM registration registry keys for `{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}` under `HKEY_CLASSES_ROOT\CLSID` and shell handlers were successfully created.
6. **Silent Uninstallation Verification & Fix**:
   - Discovered that context menu handler keys under `HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers` and `HKEY_CLASSES_ROOT\exefile\shellex\ContextMenuHandlers` remained after silent uninstallation.
   - Identified that the shell extension's `DeleteRegKey` method failed with `ERROR_ACCESS_DENIED` (5) when using `RegDeleteTreeW` on these merged key paths under `HKEY_CLASSES_ROOT`.
   - Modified `DeleteRegKey` in `ResourceAlchemyHacker_ShellExt\main.cpp` to call `RegDeleteKeyW` first (which succeeds directly for these keys since they don't have subkeys), falling back to `RegDeleteTreeW` only if it fails.
   - Recompiled the entire Visual Studio solution using MSBuild.
   - Rebuilt the installer with `ISCC.exe`.
   - Re-verified silent uninstallation and confirmed that **all** registry keys (including context menu handlers and property sheet handlers) are now cleanly and completely removed (returning `False` on all checks).
7. **Final Installation**:
   - Re-installed the components silently to leave the application in a clean, fully-functioning, and verified installed state for subsequent E2E testing.
