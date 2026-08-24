# Context Checklist - Resource Alchemy Hacker

## Current Context
- Target OS: Windows (WinForms / Native Win32)
- Target framework: .NET Framework 4.6 / Visual C++ 2017/2022 (v141/v143)
- Working directory: `C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker`
- Components:
  - `ResourceAlchemyHacker_CLI` (C++ Win32 PE Resource Editor CLI)
  - `ResourceAlchemyHacker_GUI` (C++ Win32 GUI client)
  - `ResourceAlchemyHacker_ShellExt` (C++ COM Shell Extension DLL)

## Requirements Checklist
- [ ] Programmatic Integration Tests: Test script verifying CLI `/extract` and `/replace` functions and backup creation (`_1.bak`).
- [ ] Installer Generation: Packaged EXE/MSI using InnoSetup.
- [ ] Shell Extension Registration: Registrations of ShellExt DLL on install, unregister on uninstall.
- [ ] EliteSoftwareTech Guidelines:
  - Visual Styles enabled
  - Title banner, 3D inset, Chin, client edge, Grayscale hex colors
  - Segoe UI font
  - Dynamic icon targeting
  - Hover tooltips for interactive elements
  - Premium feel loading delay
  - Logs directory and text link to open notepad
