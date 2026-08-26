# Gemini Operational Rules & Project Architecture

This file tracks specific instructions, workflow behaviors, and architectural overviews that Gemini (and other AI assistants) must follow when working on the `Local_APK_Store` project. This ensures a smooth development process and provides a clear map of how the ecosystem functions.

## 1. Core Operational Rules

### Version Control & History (Auto-Pushing)
- **Rule:** Every time a file is modified, created, or any change is applied to the project, Gemini **must** immediately `git add .`, `git commit -m "..."`, and `git push -u origin master` to push the changes to `origin`.
- **Reasoning:** A constant, unbroken change history is required so the user doesn't need to manually worry about pushing, and we have a reliable log of all actions regardless of whether the specific code actually worked on the first try.

### Line Endings (CRLF)
- **Rule:** Ensure all source files use `CRLF` (Windows style) line endings.
- **Reasoning:** Standardization across the Windows-based EliteSoftware ecosystem. Enforced via `.gitattributes`.

### Continuous Changelog
- **Rule:** A `changelog.md` file must be continuously updated whenever things are changed or added to the project.
- **Reasoning:** Provides a human-readable, centralized history of new features, bug fixes, and architectural changes over time.

### Elite App Marketplace Scope & Signatures
- **Rule (App Name):** The Android Client must strictly be named **"Elite App Marketplace"**.
- **Rule (APK Signing):** All processed APKs, including the Elite App Marketplace APK itself, must be signed using the master certificate located at `C:\Users\Administrator\Desktop\Local_APK_Store\Elite-EasySigner\EliteSoftware_Special.pfx` (Password: `Minecraft145!!`).
- **Rule (Client Features):** The marketplace client must support categorization, tagging, user reviews/comments, and the ability to download the `EliteSoftware_Special.cer` root certificate directly to the Android device via its internal Settings menu.

---

## 2. Project Architecture & Components

The project is split into two primary components: the **Windows Server Manager** and the **Android Client**. 

### A. Windows Server Manager (`/Manager_App/`)
This is a monolithic C++ Win32 desktop application that acts as both a GUI management tool and an HTTP server for the Android clients.
- `main.cpp`: The core C++ source file containing the Win32 GUI event loop and the `httplib` web server endpoints. It handles uploading APKs, modifying database entries, and serving files to the Android app.
- `db.json`: The database file holding all metadata (App Names, Package Names, Icons, Screenshots, Reviews) for every APK available in the marketplace.
- `apks/` and `images/`: Directories storing the physical `.apk` files and their corresponding icons/screenshots.
- `build.bat`: The primary build script for compiling the server and initiating the full pipeline (detailed below).

### B. Android Client (`/Client_App/`)
This is the standard Android Studio project for the "Elite App Marketplace" app. It connects to the C++ Windows Server.
- Built using Java/Android SDK.
- Connects to the local server (via IP address configured by the user) to fetch the JSON app catalog, download APKs, and submit new apps/updates.
- Contains an `UploadActivity.java` which parses metadata (Package Name, Version, App Name) dynamically directly from the selected `.apk` file using Android's native `PackageManager`.

---

## 3. The Automated Build & Release Pipeline

The project features a **fully automated**, end-to-end continuous integration and deployment pipeline that spans building the C++ server, building the Android APK, signing it, updating the database, pushing to git, and creating a GitHub release.

**How to trigger a full build & release:**
You simply execute `build.bat` in the `Manager_App` directory.
```powershell
cmd.exe /c "build.bat"
```

**Step-by-Step Breakdown of the Pipeline:**
1. **`Manager_App\build.bat` (The Entry Point):**
   - Kills any running instances of the server.
   - Cleans old binaries.
   - Compiles the C++ source using `g++` and `windres` (statically linked).
   - If the C++ compilation is **successful**, it automatically calls `..\publish_release.ps1` to execute the rest of the pipeline.

2. **`publish_release.ps1` (The Automator):**
   - **Auto-Versioning:** It reads `Manager_App/db.json` to find the latest version of the Elite App Marketplace client and increments the patch number automatically (e.g., `v1.0.53` -> `v1.0.54`).
   - **Android Versioning:** Updates `versionCode` and `versionName` inside `Client_App/app/build.gradle` to match the newly generated version.
   - **Android Compilation:** Triggers `Client_App\build_apk.ps1` to run the Gradle tasks (`assembleDebug` / `assembleRelease`) to compile the `.apk`.
   - **APK Signing:** Uses the `apksigner` build-tool to sign the output APK securely with the `EliteSoftware_Special.pfx` certificate.
   - **Database Injection:** Automatically copies the newly signed APK into the `Manager_App\apks\` folder and updates `Manager_App/db.json` to register the new version. (This allows existing clients to see and download the update immediately).
   - **Git Push:** Stages all changes, commits them as "Auto-build and release v1.0.x", and pushes directly to the `master` branch.
   - **GitHub Release:** Uses the GitHub CLI (`gh release create`) to push a new versioned release, attaching both the Windows `Elite_App_Marketplace-Server.exe` and the `Elite_App_Marketplace-Client_v[version].apk`.
   - **Restart:** Automatically launches the newly compiled Windows Server Executable.

**CRITICAL RULE:** Never separate the build and publish steps. `build.bat` must always remain the entry point, and it must always seamlessly trigger `publish_release.ps1` upon a successful compile.

**Build Logging Details:**
- `build.bat` uses a self-logging pattern to prevent it from hanging in the background and keeping the terminal process stuck. 
- When executed, the outer script intercepts execution, creates a `build_log.txt` file (wiping the old one cleanly), pipes the entire compilation run into the log file, and immediately calls `exit` when finished to gracefully close the parent process. 

## 4. Android Client Self-Update Architecture
The Elite App Marketplace Android application contains built-in self-updating architecture that must handle edge cases when the Android OS attempts to kill the package while it's being updated.
- **Root/Shizuku Path:** Automated background installations via Shizuku (`pm install`) *must* include the `-r` flag (`pm install -r -S <size>`) so that the package manager knows to overwrite the existing APK, rather than throwing an `INSTALL_FAILED_ALREADY_EXISTS` exception.
- **Standard Fallback Path:** For non-rooted updates, we do not use `Intent.ACTION_VIEW` targeting a local `FileProvider` because Android violently kills the running app during the self-update process, terminating the `FileProvider` mid-stream and corrupting the install. Instead, the application invokes the **PackageInstaller Session API** to stream the raw APK payload directly into the Android OS's staging area *before* committing the install.
# Original User Request

## 2026-08-04T20:28:23-04:00

# Teamwork Project Prompt — Draft

> Status: Launched
> Goal: Craft prompt → get user approval → delegate to teamwork_preview

Fix UI rendering and functional issues in the Local APK Store application, automatically extract and display internal APK icons, and add a connected client list to the server monitor.

Working directory: C:\Users\Administrator\Desktop\Local_APK_Store
Integrity mode: development

## Requirements

### R1. UI Rendering Fixes (Windows App)
Ensure no UI elements have custom backfill colors (they must rely entirely on the OS/Visual Styles, strictly adhering to legacy Windows aesthetics). Fix any overlapping elements and ensure the listview is properly anchored/docked so it resizes dynamically with the window. Do not add any modern UI designs or change the core existing design layout. The Windows app must build upon the existing C++ (or C#/PowerShell depending on existing foundation) codebase without rewriting the underlying structure.

### R2. Automatic APK Icon Extraction & Display
Automatically extract the internal icon from APK files and display it within the Windows application's listview. This extraction must be fully integrated into the server and client apps directly, avoiding external tools/binaries unless absolutely required. Ensure this internal icon is also served and displayed correctly on the Android store application's UI, respecting its existing foundation.

### R3. Server Monitor Updates
Update the server monitor interface to display a real-time list of connected clients. The list must show both the IP Address and the Device Name of each connected client.

## Acceptance Criteria

### UI Rendering
- [ ] Programmatic/Visual Verification: No buttons or controls specify a custom background color; they default to OS styling.
- [ ] Programmatic/Visual Verification: No elements overlap when the main window is initialized at default size.
- [ ] Programmatic/Visual Verification: Resizing the window correctly resizes the listview without breaking the layout or obscuring other controls.

### APK Icons
- [ ] Programmatic Verification: The server logic successfully reads the internal APK icon for an uploaded/available APK.
- [ ] Visual Verification: The Windows app listview displays the correct internal icon.
- [ ] Visual Verification: The Android store UI successfully fetches and displays the internal APK icon.

### Server Monitor
- [ ] Programmatic Verification: When a client connects, the server UI updates to show their IP address and Device Name.
- [ ] Programmatic Verification: Disconnected clients are appropriately managed/removed from the list.

# Test Infrastructure & Strategy Documentation — Local APK Store

## 1. Test Philosophy & Design Principles
The End-to-End (E2E) testing framework for **Local APK Store** is designed around opaque-box, contract-driven, requirement-verified validation.

- **Non-Invasive Verification**: Tests validate observable APIs, network protocols, data structures, and file system states without relying on internal function mocks or fake test assertions.
- **Independence & Isolation**: Every test creates its own temporary environment (isolated ports, isolated temporary directories, synthetic APK archives, isolated mock client connections) and cleans up resources immediately after execution.
- **Strict Verification Rules**: All test cases use authoritative verification derived directly from `ORIGINAL_REQUEST.md` and `PROJECT.md`. No hardcoded dummy passing tests.
- **Multi-Tiered Coverage Layout**: Organizes test suites into Tiers 1-4, moving from individual feature requirement validation up to multi-client end-to-end real-world workflows.

---

## 2. Feature Inventory & Mapping Matrix

| Feature ID | Feature Name | Target Scope / Requirements | Test File |
|------------|--------------|-----------------------------|-----------|
| **R1** | Win32 UI Rendering & Aesthetic Compliance | R1.1 Custom Backfill Brush Removal<br>R1.2 Non-Overlapping Control Geometry<br>R1.3 SysListView32 Conversion & Dynamic WM_SIZE<br>R1.4 Segoe UI Font, Dialogs, Tooltips, Chin Panel, 3D Inset<br>R1.5 Log File Creation & Logger Link | `tests/test_tier1_feature_coverage.py`<br>`tests/test_tier2_boundary_corner.py`<br>`tests/test_tier3_cross_feature.py`<br>`tests/test_tier4_real_world.py` |
| **R2** | APK Icon Extraction & Display | R2.1 Server ZIP Internal PNG Extraction<br>R2.2 Extraction Fallback (Adaptive XML / Default Image)<br>R2.3 HTTP Endpoint `GET /images/<icon>` Serving<br>R2.4 Win32 HIMAGELIST Image Loading & ListView Binding<br>R2.5 Android Client Intent Extra Alignment & HTTP Icon URL | `tests/test_tier1_feature_coverage.py`<br>`tests/test_tier2_boundary_corner.py`<br>`tests/test_tier3_cross_feature.py`<br>`tests/test_tier4_real_world.py` |
| **R3** | Server Monitor & Connected Clients | R3.1 Client Heartbeat Registration (`POST /api/heartbeat`)<br>R3.2 Repeat Heartbeat Timestamp Updates (No Duplicates)<br>R3.3 Disconnect Protocol (`POST /api/disconnect`)<br>R3.4 15-Second Inactive Client Timeout Purge Thread<br>R3.5 Server Monitor SysListView32 UI Timer Refresh | `tests/test_tier1_feature_coverage.py`<br>`tests/test_tier2_boundary_corner.py`<br>`tests/test_tier3_cross_feature.py`<br>`tests/test_tier4_real_world.py` |

---

## 3. Architecture & Test Directory Structure

```
C:\Users\Administrator\Desktop\Local_APK_Store\
├── tests/
│   ├── __init__.py                            # Package initialization
│   ├── test_tier1_feature_coverage.py          # Tier 1: Feature Coverage (15 tests: R1=5, R2=5, R3=5)
│   ├── test_tier2_boundary_corner.py           # Tier 2: Boundary & Corner Cases (15 tests: R1=5, R2=5, R3=5)
│   ├── test_tier3_cross_feature.py             # Tier 3: Pairwise & Multi-Feature Interactions (4 tests)
│   ├── test_tier4_real_world.py               # Tier 4: Real-World Workflow Scenarios (5 tests)
│   ├── run_e2e_tests.py                       # Native Python Test Runner & Reporter
│   └── run_e2e_tests.ps1                      # PowerShell Test Execution Wrapper
├── TEST_INFRA.md                              # Test Strategy & Infrastructure Manual
└── TEST_READY.md                              # Suite Status, Execution Command & Verification Metrics
```

---

## 4. Runner Invocation & Commands

### PowerShell Invocation (Standard Windows Execution)
```powershell
powershell -ExecutionPolicy Bypass -File tests\run_e2e_tests.ps1
```

### Python Direct Invocation
```cmd
python tests/run_e2e_tests.py
```

### Individual Tier Execution
```cmd
python -m unittest tests/test_tier1_feature_coverage.py
python -m unittest tests/test_tier2_boundary_corner.py
python -m unittest tests/test_tier3_cross_feature.py
python -m unittest tests/test_tier4_real_world.py
```

---

## 5. Coverage Thresholds & Quality Gates

- **Total Test Count Minimum**: 39 Tests
  * Tier 1 (Feature Coverage): >= 15 tests (5 R1, 5 R2, 5 R3)
  * Tier 2 (Boundary & Corner Cases): >= 15 tests (5 R1, 5 R2, 5 R3)
  * Tier 3 (Cross-Feature Pairwise Interactions): >= 4 tests (R1+R2, R2+R3, R1+R3, R1+R2+R3)
  * Tier 4 (Real-World Scenarios): >= 5 tests
- **Pass Threshold**: 100% Pass Rate required (0 Failures, 0 Errors)
- **Execution Code Gate**: Runner exits with code `0` on 100% pass, `1` on any failure.

# E2E Test Suite Status & Readiness Report — Local APK Store

> **STATUS: READY / COMPLETE**  
> **SUITE VERIFICATION PASS RATE: 100% (39/39 Tests Passing)**  
> **DATE: 2026-08-04**

---

## 1. Test Suite Summary Table

| Test Tier | Scope & Focus | Required Tests | Executed Tests | Passed | Failed | Status |
|-----------|---------------|----------------|----------------|--------|--------|--------|
| **Tier 1** | Feature Coverage (R1, R2, R3) | >= 15 | 15 | 15 | 0 | **PASSED** |
| **Tier 2** | Boundary & Corner Cases (R1, R2, R3) | >= 15 | 15 | 15 | 0 | **PASSED** |
| **Tier 3** | Pairwise & Multi-Feature Interactions | >= 4 | 4 | 4 | 0 | **PASSED** |
| **Tier 4** | Real-World End-to-End Workflows | >= 5 | 5 | 5 | 0 | **PASSED** |
| **TOTAL** | **Full Opaque-Box E2E Coverage** | **>= 39** | **39** | **39** | **0** | **PASSED (Code 0)** |

---

## 2. Official Runner Invocation Command

To execute the complete E2E test suite across Tiers 1-4 and verify results:

```powershell
powershell -ExecutionPolicy Bypass -File tests\run_e2e_tests.ps1
```

*(Alternatively via Python directly: `python tests/run_e2e_tests.py`)*

---

## 3. Detailed Feature Verification Checklist

### Feature R1: Win32 UI Rendering & Aesthetic Compliance
- [x] **R1.1 OS Visual Styles & Backfill Brush**: Verified `InitCommonControlsEx`, manifest dependency for Common-Controls 6.0, and `WM_CTLCOLORSTATIC` static background handling defaulting to OS styling.
- [x] **R1.2 Non-Overlapping Control Geometry**: Verified mathematical bounding box calculations for 850x600 window layout with zero bounding rect intersections.
- [x] **R1.3 SysListView32 Control & Dynamic WM_SIZE**: Verified listview creation with `SysListView32` class and dynamic `WM_SIZE` client area recalculation using `TCM_ADJUSTRECT`.
- [x] **R1.4 Segoe UI Font, Dialogs & Aesthetic Compliance**: Verified Segoe UI font initialization (Semibold/Regular), Menubar, Toolbar, About/Help/Settings dialog classes, Tooltips, 3D inset frame, and Chin panel styling.
- [x] **R1.5 Log File Path & Viewer Launch**: Verified `%SystemDrive%\EliteSoftware\Logs\Manager_App.log` path logger creation, formatting, appending, and log viewer launching.

### Feature R2: APK Icon Extraction & Display
- [x] **R2.1 ZIP Internal PNG Extraction**: Verified extraction of internal icon PNG files from APK archives into `Manager_App/images/<package_name>_icon.png`.
- [x] **R2.2 XML Adaptive & Missing Icon Fallbacks**: Verified fallback resolution when primary icon is vector XML (`ic_launcher.xml`) or missing, using secondary raster PNG or default fallback image.
- [x] **R2.3 HTTP `/images/<icon>` Endpoint**: Verified image file serving via HTTP GET `/images/`, returning status 200 OK, `Content-Type: image/png`, and correct image byte stream.
- [x] **R2.4 Win32 HIMAGELIST & ListView Binding**: Verified GDI+ image loading, HBITMAP conversion, `HIMAGELIST` creation (`ImageList_Create`), and `SysListView32` icon assignment (`LVM_SETIMAGELIST`).
- [x] **R2.5 Android Client Intent Extra Alignment**: Verified Intent extra parameter alignment (`"app_data"` JSON payload containing `"icon"`, `"name"`, `"package_name"`) in `MainActivity.java` and `AppDetailActivity.java`.

### Feature R3: Server Monitor & Connected Clients
- [x] **R3.1 Heartbeat Endpoint (`POST /api/heartbeat`)**: Verified registration of client IP address, device name, client_id, and last active timestamp in server session map.
- [x] **R3.2 Repeat Heartbeat Timestamp Updates**: Verified duplicate heartbeats from single client update `last_active` timestamp without creating duplicate client list entries.
- [x] **R3.3 Disconnect Endpoint (`POST /api/disconnect`)**: Verified immediate removal of client session from server memory database upon disconnect request.
- [x] **R3.4 15-Second Inactive Timeout Purge**: Verified background cleanup logic purging clients inactive for > 15 seconds.
- [x] **R3.5 Server Monitor SysListView32 UI Refresh**: Verified Server Monitor client list UI (`hwndClientList`) rendering columns (IP Address, Device Name, Last Active) on 1-second `WM_TIMER` tick.

---

## 4. Test Files Inventory
- `tests/test_tier1_feature_coverage.py`: Tier 1 Feature Unit/Integration Tests
- `tests/test_tier2_boundary_corner.py`: Tier 2 Edge Case & Stress Tests
- `tests/test_tier3_cross_feature.py`: Tier 3 Cross-Feature Pairwise Interaction Tests
- `tests/test_tier4_real_world.py`: Tier 4 Real-World Scenario Workflow Tests
- `tests/run_e2e_tests.py`: Python Execution Runner
- `tests/run_e2e_tests.ps1`: PowerShell Execution Script


## Version Updates & What's New Protocol
- **Rule:** Whenever the version number is updated throughout the source files, the "Whats New" Dialog window (accessible via the menubar About section) must also be updated simultaneously.
- **Rule:** The "Whats New" Dialog must retain the "Whats New" paragraphs for the last 3 versions.


## Documentation Synchronization
- **Rule:** The eadme.md file and index.html (the high-density landing page hosted via GitHub Pages) must always be kept in sync and updated together when adding new features or documentation.



## Continuous Changelog
- **Rule:** A `changelog.md` file must be continuously updated whenever things are changed or added to the project. This file must outline planning and development steps broken down into tiny, singular-focused lists of changes and the steps to complete them.
- **Rule:** You must append to `changelog.md` immediately after every single file operation or task, rather than waiting until the end of the prompt. If you write to a CPP file, you must immediately document that and the specific changes implemented into `changelog.md` before continuing your work.
- **Rule:** The `changelog.md` file must be linked inside `readme.md` and `index.html` so users can easily navigate to it.
