# Orchestration Plan - Resource Alchemy Hacker

This document outlines the detailed steps to automate the build, test, and installer system for the Resource Alchemy Hacker project.

## Milestones

1. **Milestone 1: Compile CLI, GUI, and ShellExt**
   - Ensure all components (CLI, GUI, Shell Extension) build successfully.
   - Investigate compiler tools (MSBuild, InnoSetup, SignTool, etc.).
   - Verify layout and compilation outputs.

2. **Milestone 2: CLI Integration Tests**
   - Create a test script (PowerShell or batch) that executes the CLI.
   - Run `/extract` on a sample PE binary and check output file exists.
   - Run `/replace` on the sample PE binary, check `_1.bak` is created, and verify changes are applied.

3. **Milestone 3: Installer & Registration**
   - Create InnoSetup script or MSI installer.
   - Ensure the CLI, GUI, and ShellExt DLL are packaged.
   - The installer must register `ResourceAlchemyHacker_ShellExt.dll` using `regsvr32.exe` (or similar COM registration) upon install.
   - The installer must cleanly unregister `ResourceAlchemyHacker_ShellExt.dll` during uninstallation.
   - Ensure the GUI and installer follow EliteSoftwareTech guidelines (3D inset, Chin, Segoe UI, About box, Help box, tooltip, Grayscale chin, dynamic icon targeting, premium feel loading delay if applicable).

4. **Milestone 4: E2E Verification & Forensic Audit**
   - E2E testing of the installer: install, verify files, verify registry entries, verify context menu integration if possible, uninstall, verify cleanup.
   - Run Forensic Auditor to guarantee no hardcoding/cheating.

## Execution Model
- We will spawn subagents for each step (Explorer -> Worker -> Reviewer -> Challenger -> Auditor).
- Monitor progress and handle failures.
