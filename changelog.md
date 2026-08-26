# Resource Alchemy Hacker - Continuous Changelog

This document provides a highly granular, step-by-step breakdown of planning, development steps, and file operations performed during the development of Resource Alchemy Hacker.

## v1.4.0.5 - Ongoing Development

### Task: Implement What's New Dialog
- **Step 1:** Defined IDM_HELP_WHATSNEW (304) in ResourceAlchemyHacker_GUI\main.cpp.
- **Step 2:** Added WhatsNewDlgProc callback handler in ResourceAlchemyHacker_GUI\main.cpp using the native Win32 API, integrating a read-only multi-line edit control and EliteSoftware's custom GradientFill banner logic.
- **Step 3:** Attached IDM_HELP_WHATSNEW to the hHelp dropdown menu in ResourceAlchemyHacker_GUI\main.cpp.
- **Step 4:** Added WM_COMMAND message routing to spawn the WhatsNewDlgProc modal dialog in ResourceAlchemyHacker_GUI\main.cpp.
- **Step 5:** Updated WM_MENUSELECT in ResourceAlchemyHacker_GUI\main.cpp to display a status bar hint when hovering over the "What's New" menu item.
- **Step 6:** Populated the WhatsNewDlgProc with the historical changelogs for the last 3 versions (v1.4.0.3, v1.4.0.4, v1.4.0.5).

### Task: Fix CI/CD Pipeline Timestamp Error
- **Step 1:** Identified that signtool.exe was failing to reach the Digicert timestamp server (http://timestamp.digicert.com), causing the build scripts to output errors.
- **Step 2:** Modified uild.ps1 to remove the /t timestamp flag entirely to ensure offline or restrictive network environments do not fail the Authenticode signing process.
- **Step 3:** Corrected a variable interpolation bug in publish_release.ps1 (changed $() to $AppVersion) to ensure Inno Setup installers were successfully packaged into the final ZIP releases.

### Task: Create 2010-Era Landing Page & Documentation Sync
- **Step 1:** Created index.html in the root directory featuring a high-density, 2010-2011 era design language (top nav, gradient banners, sidebars, mini stacked boxes).
- **Step 2:** Updated eadme.md to reflect the latest 1.4.0.5 feature set.
- **Step 3:** Updated GEMINI.md to enforce the synchronization of eadme.md and index.html.
- **Step 4:** Pushed the newly created static assets to the master branch for GitHub Pages deployment.


### Task: Link Changelog in Documentation
- **Step 1:** Modified eadme.md to include a direct markdown link to changelog.md under the Project Structure section.
- **Step 2:** Modified index.html to include a direct hyperlink to the GitHub-hosted changelog.md file within the left-hand Navigation sidebar under Resources.

### Task: Implement Prompt Logging & Context Gathering Rules
- **Step 1:** Modified GEMINI.md to include rules for maintaining a Prompt_Outputs directory.
- **Step 2:** Modified GEMINI.md to include a rule enforcing global context gathering (reading all .md and .txt files) before starting main tasks.
- **Step 3:** Created the Prompt_Outputs directory in the project root.
- **Step 4:** Backfilled the Prompt_Outputs directory with the last 3 prompt/response interactions to bootstrap the new logging system.

### Task: Elevate Documentation Standards to Global Rules
- **Step 1:** Abstracted the versioning, changelog, sync, prompt logging, and context gathering rules from the local project scope into a generalized, project-agnostic <RULE[user_global_documentation_standards]> block.
- **Step 2:** Injected the generalized global rules into the core Antigravity configuration file at C:\Users\Administrator\.gemini\GEMINI.md.
- **Step 3:** Synchronized the new global documentation rules across the primary system drives by appending them to C:\GEMINI.md and Z:\GEMINI.md, and initializing a new M:\GEMINI.md file.
- **Step 4:** Synchronized the core EliteSoftware GUI Development Guidelines and legacy aesthetic rules from the global Antigravity configuration to C:\GEMINI.md and Z:\GEMINI.md to guarantee environment-wide policy parity.

### Task: Standardize Universal Project Structure
- **Step 1:** Scanned the C:\, Z:\, and M:\ drives to analyze the architectural layouts of existing EliteSoftware tools (Elite-Taskbar, IconExplorer, Local_APK_Store, ResourceAlchemyHacker, etc.).
- **Step 2:** Synthesized the recurring patterns into a formalized <RULE[user_global_project_structure]> template, defining strict separation of GUI, CLI, and Shell components, alongside mandatory testing and release folders.
- **Step 3:** Appended this new structural rule template to all global GEMINI.md configuration files (~/.gemini, C:\, Z:\, and M:\).

### Task: Fix Expand/Collapse Menubar Actions (BugTracker Chunk 3)
- **Step 1:** Injected WM_COMMAND routing logic in ResourceAlchemyHacker_GUI\main.cpp for menu IDs 5401 and 5402 to handle TreeView node expansion and collapsing.
- **Step 2:** Added conditional fallback to iterate and expand/collapse all root nodes using TVM_GETNEXTITEM and TVM_EXPAND if no specific node is currently selected by the user.
- **Step 3:** Bound Ctrl+E and Ctrl+C in the HACCEL accelerator table to physically wire the hotkeys to the menu actions.

### Task: Fix Replace Dialog GUI Layout (BugTracker Chunk 4)
- **Step 1:** Completely refactored ReplaceDlgProc inside ResourceAlchemyHacker_GUI\main.cpp to correctly apply the standard legacy Win32/WinForms aesthetics (custom WM_PAINT gradient banner, top/bottom BDR_SUNKENOUTER client edge, and 3D chin).
- **Step 2:** Added text control parsing to accurately display the g_replaceName and g_replaceType in a FW_SEMIBOLD font header, dynamically populating the UI based on the selected target node.
- **Step 3:** Centered the preview icon coordinate extraction inside the owner-drawn bounding box and fixed missing fonts causing the buttons to render out of style.
- **Step 4:** Increased modal dialog dimension boundary from 340 to 420 to accommodate the newly injected title banner layout.

### Task: Automate Version Bump (1.4.0.6)
- **Step 1:** Bumped ersion.h to 1.4.0.6 and synced WhatsNewDlgProc in main.cpp.
- **Step 2:** Re-triggered master build/release pipeline for x64 and x86.
