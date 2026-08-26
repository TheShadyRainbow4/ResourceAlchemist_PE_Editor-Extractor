# Resource Alchemy Hacker - Continuous Changelog

This document provides a highly granular, step-by-step breakdown of planning, development steps, and file operations performed during the development of Resource Alchemy Hacker.

## Legacy Backported History (v1.0.0 -> v1.4.0.4)

### Commit: c291970 - Set up Native C++ project structure and boilerplates
- **Step 1:** `README.md` | Edited file | Initialized project documentation outlining the scope of the native C++ Resource Alchemy Hacker.
- **Step 2:** `ResourceAlchemyHacker.sln` | Created file | Bootstrapped the Visual Studio solution to link the CLI, GUI, and ShellExt projects.
- **Step 3:** `ResourceAlchemyHacker_CLI/main.cpp` | Created file | Scaffolded the headless command-line interface entry point.
- **Step 4:** `ResourceAlchemyHacker_GUI/main.cpp` | Created file | Scaffolded the Win32 GUI application entry point and base window.
- **Step 5:** `ResourceAlchemyHacker_ShellExt/main.cpp` | Created file | Scaffolded the Windows Explorer Context Menu COM extension.
- **Step 6:** `build.ps1` | Created file | Created the master build script to orchestrate MSBuild compilation for all components.

### Summary (v1.0.0)
+ **Initial Project Setup:** Created the foundational multi-component architecture separating the GUI, CLI, and Shell Extension into distinct native C++ projects.
+ **Build Pipeline:** Implemented `build.ps1` to automate compilation across all tools.

---

### Commit: d946bc8 - Update toolchains and setup MinGW for Windows Vista compatibility
- **Step 7:** `ResourceAlchemyHacker_CLI/ResourceAlchemyHacker_CLI.vcxproj` | Edited file | Updated MSBuild platform toolsets to `v141_xp` for legacy Vista/Win7 compatibility.
- **Step 8:** `install_mingw.ps1` | Created file | Added automated MinGW installer script for fallback GCC compilation paths.

### Summary (v1.1.0)
+ **Legacy OS Support:** Downgraded the target platform toolsets to explicitly support Windows Vista and Windows 7 via `v141_xp`.
+ **Alternative Toolchains:** Integrated MinGW installation scripts.

---

### Commit: b96a1a3 - Implement full CLI backend engine features (Enumerate, Extract, Replace, Log)
- **Step 9:** `ResourceAlchemyHacker_CLI/main.cpp` | Edited file | Engineered the core C++ resource manipulation logic (`EnumResourceNamesW`, `UpdateResourceW`). Implemented CLI arguments (`/extract`, `/replace`, `/delete`) and structured logging.

### Summary (v1.2.0)
+ **CLI Engine Complete:** The headless CLI engine is now fully functional, capable of extracting, deleting, and replacing Win32 resources (`RT_ICON`, `RT_STRING`, etc.) directly from PE binaries.
* **Logging System:** Added verbose logging capabilities.

---

### Commit: 61d17a7 - Resource_Editor+Extractor Inspired by ResourceHacker
- **Step 10:** `ResourceAlchemyHacker_GUI/main.cpp` | Edited file | Implemented the main TreeView UI layout, binding `GuiListResources` to visually map PE headers.

### Summary (v1.3.0)
+ **GUI TreeView Binding:** Connected the native C++ GUI to the resource enumerator, allowing users to visually navigate PE resource trees.

---

### Commit: 393542e - Auto-build and release v1.4.0.0
- **Step 11:** `publish_release.ps1` | Created file | Implemented the automated GitHub release pipeline with Inno Setup packaging.
- **Step 12:** `version.h` | Created file | Centralized versioning logic for C++ binaries.

### Summary (v1.4.0.0)
+ **CI/CD Pipeline:** Fully automated the compilation, Authenticode signing, and GitHub release packaging processes.

---

### Commit: 8c5ff91 - Auto-build and release v1.4.0.4
- **Step 13:** `ResourceAlchemyHacker_GUI/main.cpp` | Edited file | Refactored the Save dialog and wired the Replace Resource GUI modal.
- **Step 14:** `BugTracker.md` | Created file | Migrated known issues to a centralized tracker.
- **Step 15:** `ImplementationPlan.md` | Created file | Created a structured roadmap for future bug fixes.

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










