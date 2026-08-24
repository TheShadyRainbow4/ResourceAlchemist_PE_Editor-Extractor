# Resource Alchemy Hacker — Detailed Exploration & Analysis Report

## 1. Executive Summary
This report documents the results of the read-only exploration of the Resource Alchemy Hacker codebase and build environment. It details the paths to all required compilation and setup tools, analyzes the CLI, GUI, and ShellExt projects, and provides detailed designs for addressing the Shell Extension DLL registration issues, completing the CLI icon replacement (deconstruction) functionality, compiling the solution, and implementing integration testing.

---

## 2. Compilation and Scripting Tools Discovery
We scanned the local file system and identified the following tools:

### A. MSBuild (Visual Studio Build Tools)
*   **VS 2022 Build Tools (Targeting PlatformToolset v143)**:
    `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe`
    *Note: The 64-bit compiler MSBuild is located at `...\Bin\amd64\MSBuild.exe`*
*   **VS 2019 Build Tools (Targeting PlatformToolset v141 / v142)**:
    `C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe`

### B. C++ Compiler (cl.exe)
*   **MSVC v143 Compiler (VS 2022)**:
    `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\cl.exe`
*   **MSVC v141 Compiler (VS 2019)**:
    `C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.16.27023\bin\HostX64\x64\cl.exe`

### C. Resource Compiler (rc.exe)
*   **Windows 10 SDK (Version 10.0.22621.0)**:
    `C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\rc.exe`
*   **Windows 10 SDK (Version 10.0.19041.0)**:
    `C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64\rc.exe`

### D. Inno Setup Compiler (ISCC.exe)
*   **Inno Setup 6 Command-Line Compiler**:
    `C:\Program Files\Antigravity IDE\resources\app\node_modules\innosetup\bin\ISCC.exe`
    *(Verified executable and responsive, Version 6)*

---

## 3. Project Inspections & Required Changes

### A. Shell Extension DLL (`ResourceAlchemyHacker_ShellExt`)
The shell extension DLL currently implements the `IShellExtInit`, `IContextMenu`, and `IShellPropSheetExt` COM interfaces but completely lacks DLL registration functions.

#### **Issues to Address**:
1.  **Missing Registration Exports**: The DLL does not export `DllRegisterServer` or `DllUnregisterServer`.
2.  **Lack of Registry Keys**: No logic is present to write CLSID keys or context menu / property sheet handler registrations.
3.  **GUI Invocation Placeholder**: In `CResourceAlchemyHackerExt::InvokeCommand` (lines 76-80), a message box is shown instead of launching the GUI process.

#### **Technical Proposals**:
1.  **Self-Registration Implementation**: Add `DllRegisterServer` and `DllUnregisterServer` to `main.cpp`.
    *   **CLSID**: `{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}`
    *   **Registry Keys to Create/Remove**:
        *   `HKEY_CLASSES_ROOT\CLSID\{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}` (Default: `"Resource Alchemy Hacker Shell Extension"`)
        *   `HKEY_CLASSES_ROOT\CLSID\{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}\InprocServer32` (Default: `[Path to DLL]`, `ThreadingModel`: `"Apartment"`)
        *   `HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ResourceAlchemyHacker` (Default: `"{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}"`)
        *   `HKEY_CLASSES_ROOT\exefile\shellex\PropertySheetHandlers\ResourceAlchemyHacker` (Default: `"{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}"`)
        *   `HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved` (Value name: `"{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}"`, Data: `"Resource Alchemy Hacker Shell Extension"`)
2.  **Export Directives**: Rather than modifying the `.vcxproj` linker settings or adding a separate `.def` file, add linker comments directly inside `main.cpp`:
    ```cpp
    #pragma comment(linker, "/EXPORT:DllGetClassObject,PRIVATE")
    #pragma comment(linker, "/EXPORT:DllCanUnloadNow,PRIVATE")
    #pragma comment(linker, "/EXPORT:DllRegisterServer,PRIVATE")
    #pragma comment(linker, "/EXPORT:DllUnregisterServer,PRIVATE")
    ```
3.  **GUI Process Launch**: Store the DLL module instance (`hModule`) at `DLL_PROCESS_ATTACH` in a global `HINSTANCE g_hInst`. In `InvokeCommand`, determine the DLL's directory via `GetModuleFileNameW(g_hInst, ...)` and build the path to `ResourceAlchemyHacker_GUI.exe` in the same directory. Start it using `CreateProcessW` passing `m_szSelectedFile` as a command-line parameter:
    ```cpp
    // Launch: ResourceAlchemyHacker_GUI.exe "[SelectedFilePath]"
    wstring cmdLine = L"\"" + guiPath + L"\" \"" + m_szSelectedFile + L"\"";
    STARTUPINFOW si = { sizeof(si) };
    PROCESS_INFORMATION pi;
    CreateProcessW(NULL, &cmdLine[0], NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi);
    ```

---

### B. CLI Engine (`ResourceAlchemyHacker_CLI`)
The CLI engine parses and processes PE resource modifications. 
*   **`/list`**: Uses `EnumResourceTypesW` / `EnumResourceNamesW` / `EnumResourceLanguagesW` to list all resources in a target executable.
*   **`/extract`**: Extracts resource data. If the type is `14` (`RT_GROUP_ICON`), it calls `ExtractIconGroup`, which parses `RT_GROUP_ICON` to locate individual `RT_ICON` resource IDs and reconstructs a standalone `.ico` binary file.
*   **`/replace`**: Replaces resource data. It currently takes the input file and replaces the resource target in one chunk. However, for `RT_GROUP_ICON` (type `14`), standard simple replacement fails because an `.ico` file must be parsed and split into individual `RT_ICON` resources and a restructured group directory directory.

#### **Technical Proposals**:
1.  **Implement Icon Deconstruction**: Write `ReplaceIconGroup(...)` to split a `.ico` file back into PE resources:
    *   **ICO Parse**: Read the `.ico` file's `ICONDIR` header and the array of `ICONDIRENTRY` structures.
    *   **Delete Old Icons**: To avoid bloat, first read the existing `RT_GROUP_ICON` of the target. Loop through the old entries and delete all associated `RT_ICON` resource IDs by calling `UpdateResourceW(hUpdate, RT_ICON, MAKEINTRESOURCEW(oldId), lang, NULL, 0)`.
    *   **Write New Icons**: For each image in the `.ico` file, extract its raw image bytes (using `dwImageOffset` and `dwBytesInRes`) and write them as a separate `RT_ICON` resource (using sequential IDs `1`, `2`, ..., `idCount`).
    *   **Write Group Directory**: Reconstruct the `GRPICONDIR` and `GRPICONDIRENTRY` structures pointing to the new `nId` resource IDs, and write them to `RT_GROUP_ICON`.
2.  **Safety Backup Protocol**:
    *   The existing `BackupFile` function correctly inspects files by checking if `<base>_<index>.bak` exists, starting with index `1` (`_1.bak`, `_2.bak`, etc.).
    *   It copies the target file to the first free slot. This logic works and preserves backup history.

---

### C. GUI Client (`ResourceAlchemyHacker_GUI`)
The GUI currently consists of a simple Win32 skeleton window with a colored banner and an "Okay" button.

#### **Issues to Address (Compliance with EliteSoftware Guidelines)**:
1.  **Menu Bar & Dialogs**: Create a menu bar using native styles with:
    *   `Help` -> `Help Contents` -> Shows a Help Dialog with native information icon (`?`) in the title bar, taskbar, and banner, detailing tool operations.
    *   `Help` -> `About` -> Shows an About Dialog with native information blue circle (`i`) in the title bar, taskbar, and banner. The dialog must include a dropdown expand button to show detailed system/application information.
    *   `File` -> `Exit` -> Exits the application.
2.  **Dynamic Icon Targeting**:
    *   The app must query its own path, look for a `.ico` file of the same name (e.g. `ResourceAlchemyHacker_GUI.ico`) in its directory, and load it for the Title Bar, Taskbar, and Banner.
    *   If not found, it must fall back to resource ID `1` of the executable itself.
3.  **UI Layout Elements**:
    *   **Title Banner**: A distinct top banner containing the application title and a larger application icon.
    *   **3D Inset Area**: Use `WS_EX_CLIENTEDGE` to host the main content area (such as a tree view of listed resources and a details pane).
    *   **Chin**: The bottom area behind the buttons must be colored with standard grey hex values (e.g., `RGB(200, 200, 200)`) to anchor the interface.
    *   **Status Bar**: Include a status bar at the bottom with a resize grab handle on the bottom-right corner.
    *   **Settings Dialog**: A separate dialog accessible via a settings toolbar button to manage configurations.
    *   **Log View Link**: A clickable link control (e.g. `View Logs`) that opens notepad.exe to display the log file at `%SystemDrive%\EliteSoftware\Logs\ResourceAlchemist.log`.
4.  **Asynchronous Execution**:
    *   Scanning PE resources and running CLI tasks must occur on a background thread so the GUI does not freeze.

---

## 4. Compilation Verification
The solution targets `v143` PlatformToolset by default (associated with Visual Studio 2022). We verified that the solution compiles successfully using the local MSBuild installation:

### **Build Command**:
```powershell
& "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe" ResourceAlchemyHacker.sln /t:Clean,Build /p:Configuration=Release /p:Platform=x64 /p:PlatformToolset=v143
```
*Note: This command builds all three projects (CLI, GUI, and ShellExt) and outputs the compiled binaries to `C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\x64\Release`.*

---

## 5. Integration Testing Strategy (Milestone 2)
To verify `/extract`, `/replace`, and safety backup creation, we will implement an automated PowerShell script `tests/run_tests.ps1`:

1.  **Target Mock Compilation**:
    *   Create a simple C++ file `test_target.cpp` and a resource script `test_target.rc` containing a dummy string resource and manifest.
    *   Compile the resource:
        `rc.exe /v test_target.rc`
    *   Compile and link the target executable:
        `cl.exe /EHsc test_target.cpp test_target.res`
2.  **CLI Command Assertions**:
    *   Run `ResourceAlchemyHacker_CLI.exe /list test_target.exe` and assert that the resources are enumerated.
    *   Run `/extract` to dump the string resource, then assert that the output matches the original string.
    *   Run `/replace` to inject a new string/icon, and assert that:
        *   `test_target_1.bak` is created.
        *   `test_target_1.bak` is identical to the original compilation.
    *   Run `/replace` again with a second modification, and assert that `test_target_2.bak` is created.
    *   Run `/extract` on the final modified binary, and assert that the newly extracted resource matches the replacement source data exactly.
