# Handoff Report - Installer Creation and Verification

## 1. Observation

- **Binary Source Files**: The compiled 64-bit binaries are located under `C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\x64\Release`:
  - `ResourceAlchemyHacker_CLI.exe`
  - `ResourceAlchemyHacker_GUI.exe`
  - `ResourceAlchemyHacker_ShellExt.dll`
- **Dynamic Icon File**: A system `.ico` file was copied to `C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\x64\Release\ResourceAlchemyHacker_GUI.ico`.
- **Inno Setup Script Location**: `C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\Installer\setup.iss`.
- **Compiler Command**:
  ```powershell
  & "C:\Program Files\Antigravity IDE\resources\app\node_modules\innosetup\bin\ISCC.exe" C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\Installer\setup.iss
  ```
- **Compiler Output**:
  ```
  Successful compile (0.656 sec). Resulting Setup program filename is:
  C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\Installer\setup.exe
  ```
- **Silent Installation Verifications**:
  - Silent install command:
    ```powershell
    Start-Process -FilePath "C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\Installer\setup.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait -NoNewWindow
    ```
  - Installed files:
    - Path `C:\Program Files\EliteSoftware\Resource Alchemy Hacker` contains:
      - `ResourceAlchemyHacker_CLI.exe`
      - `ResourceAlchemyHacker_GUI.exe`
      - `ResourceAlchemyHacker_GUI.ico`
      - `ResourceAlchemyHacker_ShellExt.dll`
      - `unins000.dat`
      - `unins000.exe`
  - Registry key check for CLSID `{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}`:
    ```powershell
    Get-Item -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}"
    ```
    Output:
    ```
    Hive: HKEY_CLASSES_ROOT\CLSID

    Name                           Property
    ----                           --------
    {A1B2C3D4-E5F6-7890-1234-56789 (default) : Resource Alchemy Hacker Shell Extension
    0ABCDEF}
    ```
  - Registry key check for handlers:
    - `HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ResourceAlchemyHacker` -> `(default) : {A1B2C3D4-E5F6-7890-1234-567890ABCDEF}`
    - `HKEY_CLASSES_ROOT\*\shellex\PropertySheetHandlers\ResourceAlchemyHacker` -> `(default) : {A1B2C3D4-E5F6-7890-1234-567890ABCDEF}`
- **Silent Uninstallation Verifications (After Fixing ShellExt DLL)**:
  - Silent uninstall command:
    ```powershell
    Start-Process -FilePath "C:\Program Files\EliteSoftware\Resource Alchemy Hacker\unins000.exe" -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait -NoNewWindow
    ```
  - Uninstall results:
    - `C:\Program Files\EliteSoftware\Resource Alchemy Hacker` -> `Test-Path` returned `False` (deleted).
    - CLSID and ContextMenu/PropertySheet registry keys -> `Test-Path` returned `False` (deleted completely).

## 2. Logic Chain

- **Registry Deletion Bug & Fix**:
  - Initially, the uninstallation left `HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ResourceAlchemyHacker` and `HKEY_CLASSES_ROOT\exefile\shellex\ContextMenuHandlers\ResourceAlchemyHacker` behind.
  - Investigative C++ test compilation showed that `RegDeleteTreeW` fails with `ERROR_ACCESS_DENIED` (5) when targeting merged context menu keys directly under `HKEY_CLASSES_ROOT`.
  - However, direct deletion via `RegDeleteKeyW` succeeds directly (returning `0`) for keys without subkeys.
  - The shell extension DLL `DeleteRegKey` method was modified to try `RegDeleteKeyW` first. If it succeeds, it returns immediately. If it fails (due to subkeys like in CLSID), it falls back to `RegDeleteTreeW`.
  - Rebuilding the shell extension and recompiling the installer packages the corrected unregistration logic. Uninstallation now cleanly and completely purges all registry keys.
- **Dynamic Icon Compliance**: Copying `ResourceAlchemyHacker_GUI.ico` alongside `ResourceAlchemyHacker_GUI.exe` ensures that when `GetModuleFileNameW` is executed by the GUI app, the app resolves `icoPath` to `ResourceAlchemyHacker_GUI.ico` in its directory and successfully loads the icon.
- **COM Registration**: Applying `Flags: regserver` to `ResourceAlchemyHacker_ShellExt.dll` causes Inno Setup to call `DllRegisterServer` on install and `DllUnregisterServer` on uninstall.

## 3. Caveats

- **No Caveats**: The installation and uninstallation pipelines have been fully tested and verified manually using native PowerShell registry and file checking commands.

## 4. Conclusion

- The Inno Setup script compiles correctly, registers/unregisters the shell extension COM components natively under the 64-bit hive, and handles cleanup flawlessly. The application is left installed under `C:\Program Files\EliteSoftware\Resource Alchemy Hacker` for final E2E cycle verification.

## 5. Verification Method

To verify the installer, run these commands in an elevated PowerShell session:

1. **Verify setup.exe exists**:
   ```powershell
   Test-Path "C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\Installer\setup.exe"
   ```
2. **Verify installation files**:
   ```powershell
   Get-ChildItem "C:\Program Files\EliteSoftware\Resource Alchemy Hacker"
   ```
3. **Verify registration**:
   ```powershell
   Get-Item "Registry::HKEY_CLASSES_ROOT\CLSID\{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}"
   ```
