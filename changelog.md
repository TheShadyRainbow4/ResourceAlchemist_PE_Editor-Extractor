# Resource Alchemy Hacker - Continuous Changelog

This document provides a highly granular, step-by-step breakdown of planning, development steps, and file operations performed during the development of Resource Alchemy Hacker.

## Legacy Backported History (v1.0.0 -> v1.4.0.4)

### Commit: c291970 - Set up Native C++ project structure and boilerplates
- **Step 1:** `README.md` | Edited file | **What:** Initialized project documentation. **How:** Added markdown sections detailing the goal to clone Resource Hacker functionality using native C++ without .NET dependencies. **Why:** To establish a clear project roadmap and technical constraints (Win32 API only) for future contributors and AI agents.
- **Step 2:** `ResourceAlchemyHacker.sln` | Created file | **What:** Bootstrapped the Visual Studio solution. **How:** Configured MSBuild to link the CLI, GUI, and ShellExt projects into a single unified build tree. **Why:** To allow seamless compilation of all three distinct components with a single build command.
- **Step 3:** `ResourceAlchemyHacker_CLI/main.cpp` | Created file | **What:** Scaffolded the CLI entry point. **How:** Included `<windows.h>` and initialized a basic `wmain` function for headless argument parsing. **Why:** To provide the architectural foundation for the headless resource extraction/replacement engine that scripts and the GUI will eventually hook into.
- **Step 4:** `ResourceAlchemyHacker_GUI/main.cpp` | Created file | **What:** Scaffolded the Win32 GUI application. **How:** Registered a `WNDCLASSW`, created a standard overlapping window with a message loop (`GetMessage`, `DispatchMessage`), and implemented a basic `WndProc`. **Why:** To lay the groundwork for the graphical interface without relying on bloated modern frameworks, ensuring legacy OS compatibility and maximum performance.
- **Step 5:** `ResourceAlchemyHacker_ShellExt/main.cpp` | Created file | **What:** Scaffolded the Windows Explorer Context Menu COM extension. **How:** Set up the initial `IContextMenu` and `IShellExtInit` COM interfaces. **Why:** To eventually allow users to right-click `.exe` or `.dll` files in Windows Explorer and directly open them in Resource Alchemy Hacker.
- **Step 6:** `build.ps1` | Created file | **What:** Created the master build script. **How:** Wrote PowerShell logic to locate `MSBuild.exe` via `vswhere` and sequentially compile the `.sln` file for both x86 and x64 architectures. **Why:** To eliminate manual compilation steps and ensure a consistent, reproducible build environment.

### Summary (v1.0.0)
+ **Initial Project Setup:** Created the foundational multi-component architecture separating the GUI, CLI, and Shell Extension into distinct native C++ projects.
+ **Build Pipeline:** Implemented `build.ps1` to automate compilation across all tools.

---

### Commit: d946bc8 - Update toolchains and setup MinGW for Windows Vista compatibility
- **Step 7:** `ResourceAlchemyHacker_CLI/ResourceAlchemyHacker_CLI.vcxproj` (and GUI/ShellExt) | Edited file | **What:** Updated platform toolsets. **How:** Changed the `<PlatformToolset>` tag from `v143` to `v141_xp` inside the MSBuild XML configurations. **Why:** Modern MSBuild toolchains drop support for older operating systems. Reverting to the `v141_xp` toolset ensures the resulting binaries can execute natively on Windows Vista and Windows 7 without throwing missing DLL errors.
- **Step 8:** `install_mingw.ps1` | Created file | **What:** Added an automated MinGW installer. **How:** Wrote a script that downloads the MinGW-w64 toolchain, extracts it, and registers it to the system `PATH`. **Why:** To provide a fallback, open-source C++ compilation path in case the user does not have the massive 20GB+ Visual Studio Build Tools installed.

### Summary (v1.1.0)
+ **Legacy OS Support:** Downgraded the target platform toolsets to explicitly support Windows Vista and Windows 7 via `v141_xp`.
+ **Alternative Toolchains:** Integrated MinGW installation scripts.

---

### Commit: b96a1a3 - Implement full CLI backend engine features (Enumerate, Extract, Replace, Log)
- **Step 9:** `ResourceAlchemyHacker_CLI/main.cpp` | Edited file | **What:** Engineered the core resource manipulation logic. **How:** Utilized the native Win32 `EnumResourceNamesW`, `EnumResourceTypesW`, `UpdateResourceW`, and `BeginUpdateResourceW` APIs to traverse the PE header. Implemented command-line parsing to route `/extract`, `/replace`, and `/delete` flags to these Win32 functions. **Why:** To fully implement the backend engine that actually parses the PE file bytes and modifies them, serving as the computational backbone of the entire project.

### Summary (v1.2.0)
+ **CLI Engine Complete:** The headless CLI engine is now fully functional, capable of extracting, deleting, and replacing Win32 resources (`RT_ICON`, `RT_STRING`, etc.) directly from PE binaries.
* **Logging System:** Added verbose logging capabilities.

---

### Commit: 61d17a7 - Resource_Editor+Extractor Inspired by ResourceHacker
- **Step 10:** `ResourceAlchemyHacker_GUI/main.cpp` | Edited file | **What:** Implemented the main TreeView UI layout. **How:** Created a `SysTreeView32` child window control and populated it by calling the custom `GuiListResources` function, which maps the enumerated PE resource types (Icons, Strings, Dialogs) into hierarchical tree nodes. **Why:** To provide a visual, user-friendly interface mirroring the classic Resource Hacker application, allowing users to intuitively navigate the internal structure of executable files.

### Summary (v1.3.0)
+ **GUI TreeView Binding:** Connected the native C++ GUI to the resource enumerator, allowing users to visually navigate PE resource trees.

---

### Commit: 393542e - Auto-build and release v1.4.0.0
- **Step 11:** `publish_release.ps1` | Created file | **What:** Implemented the CI/CD pipeline. **How:** Wrote a PowerShell script that invokes `gh release create`, uploads the compiled artifacts, and triggers Inno Setup (`ISCC.exe`) to build the installers. **Why:** To automate the deployment process, ensuring that every master commit seamlessly generates a downloadable release for end-users.
- **Step 12:** `version.h` | Created file | **What:** Centralized versioning. **How:** Created a C++ header file containing `#define RAH_VERSION "1.4.0.0"`. **Why:** To maintain a single source of truth for the application's version number, allowing both the GUI runtime and the build scripts to read the exact same version string.

### Summary (v1.4.0.0)
+ **CI/CD Pipeline:** Fully automated the compilation, Authenticode signing, and GitHub release packaging processes.

---

### Commit: 8c5ff91 - Auto-build and release v1.4.0.4
- **Step 13:** `ResourceAlchemyHacker_GUI/main.cpp` | Edited file | **What:** Refactored the Save dialog and wired the Replace Resource modal. **How:** Added a standard `GetSaveFileNameW` dialog for extracting resources to disk, and initialized a custom dialog (`DialogBoxW`) for the Replace action. **Why:** To allow users to actually save the resources they find, and to prepare the UI framework for injecting new resources.
- **Step 14:** `BugTracker.md` | Created file | **What:** Centralized issue tracking. **How:** Logged known bugs (like TreeView selection bugs) into a markdown file. **Why:** To keep future development organized and focused on high-priority fixes.
- **Step 15:** `ImplementationPlan.md` | Created file | **What:** Created a roadmap. **How:** Outlined phases 1 through 6 for upcoming features. **Why:** To provide a strict architectural plan for the AI to follow in sequential chunks.

### Summary (v1.4.0.4)
* **Bug Fixes:** Resolved TreeView node rendering bugs and initialized the Replace Resource modal.
+ **Documentation Tracking:** Formalized the `BugTracker.md` and `ImplementationPlan.md` to guide future agents.

---
### Commit: (Pending) - GUI Fixes Chunk 5 (Settings, Fonts, Extraction)

- **Step 29:** ResourceAlchemyHacker_GUI\main.cpp | Edited file | Fixed ParseResourceToText by preserving \r, \n, \t to prevent text layout mojibake.
- **Step 30:** ResourceAlchemyHacker_GUI\main.cpp | Edited file | Renamed "Test imageres" button to "Demo File!" and wired up logic to dynamically copy and load shell32.dll.mun to temp workspace.
- **Step 31:** ResourceAlchemyHacker_GUI\main.cpp | Edited file | Overhauled SettingsDlgProc to include a native gradient WM_PAINT handler and properly apply Segoe UI fonts to all children controls to fix clipping.
- **Step 32:** ersion.h | Edited file | Incremented version to 1.4.0.7.
- **Step 33:** ImplementationPlan.md | Edited file | Checked off items 3, 4, 7 and the previous bottom checklist items.
- **Step 34:** BugTracker.md | Edited file | Checked off the bottom checklist items.

### Summary of v1.4.0.6 Release
This version successfully resolved the non-functional Expand/Collapse TreeView menubar buttons by wiring up native Win32 TVM_EXPAND messages to Ctrl+E and Ctrl+C accelerator keys. Furthermore, it completely overhauled the broken Replace Dialog, restoring the legacy visual styles (gradient banners, 3D client edge) and fixing the missing resource preview information. A global project structure rule was formalized and distributed across all drive endpoints. Finally, the remote git repository was thoroughly scrubbed and secured via an aggressively tuned .gitignore, ensuring intermediate objects, prompt outputs, and internal test folders remain strictly localized and invisible on the public branch.












