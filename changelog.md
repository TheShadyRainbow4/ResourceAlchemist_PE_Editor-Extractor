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
