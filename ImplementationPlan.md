# Resource Alchemy Hacker - Implementation Plan

This checklist outlines a safe, step-by-step approach to fixing all bugs and implementing new features. As requested, we will execute these items **two at a time**, pausing for testing and feedback before proceeding to the next batch.

### Phase 1: Source Code Restoration & UI Stabilization
- [ ] **1. Restore `main.cpp`:** Extract the uncorrupted C++ source code from the local `diff.txt` patch and permanently restore `ResourceAlchemyHacker_GUI/main.cpp`.
- [ ] **2. Fix UI Layout Scaling:** Inject a `WM_SIZE` trigger inside `WinMain` immediately after window creation to ensure the TreeView, Preview Pane, and Status Bar snap into correct alignment on launch without requiring manual resizing.

### Phase 2: Text Rendering & Aesthetic Fixes
- [ ] **3. Fix "Version Info" Rendering & Wrapping:** Update the text preview edit control to include `WS_HSCROLL | ES_AUTOHSCROLL`, and ensure extracted UTF-16 text is correctly parsed to avoid mojibake characters.
- [ ] **4. Settings Dialog Aesthetic Overhaul:** Fix the layout clipping of checkboxes in the Settings Dialog and apply the main window's custom gradient title banner logic.

### Phase 3: TreeView Previews & Configurable Sizes
- [ ] **5. Dynamic TreeView Icons:** Update the `GuiListResources` routine to dynamically extract `RT_ICON` / `RT_GROUP_ICON` images from the target PE file and bind them to the TreeView's ImageList so each item displays its actual icon.
- [ ] **6. Configurable Icon Sizes:** Add functionality to the Settings Dialog allowing the user to toggle TreeView icon sizes between 16x16, 24x24, and 32x32, persisting the choice.

### Phase 4: Safe Extraction & "Demo File" Logic
- [ ] **7. Implement "Demo File!" Button:** Rename the "Test Imageres" button. Implement logic to securely copy `C:\Windows\SystemResources\shell32.dll.mun` to the local working directory and open the copy.
- [ ] **8. Fix "Extract Monolithic" & Context Menus:** Rewrite the extraction logic to iterate through resources, create correctly named sub-folders (e.g., `Icon Groups`, `Bitmaps`), and save them as their native extensions. Add right-click extraction support to the TreeView.

### Phase 5: Smart Resource Replacement & File Baking
- [ ] **9. Intelligent Image Conversion:** Implement GDI+ logic in the "Replace Resource" routine so that replacing an Icon Group with a PNG automatically scales it into a multi-resolution `.ico` file, and BMP imports automatically detect and remove pink/gray backgrounds.
- [ ] **10. Auto-Backup System:** Update the save routine to intelligently iterate and generate `.1.bak`, `.2.bak` files for the original executable before writing any modifications.

### Phase 6: UX Enhancements & Final Polish
- [ ] **11. Drag and Drop Support:** Add `__argc`/`__argv` parsing to `WinMain` so dragging a PE file onto the executable icon automatically loads the file on startup.
- [ ] **12. File Viewer Tab & Dialog Previews:** Add a new tab/mode to visualize resources in an icon grid (like a file browser) and implement a renderer to preview actual Win32 dialog boxes from `RT_DIALOG` resources.
- [ ] **13. State Persistence:** Save the window position, window size, and a history of the last 30 opened files to the registry or a local config file to be reloaded on launch.
- [ ] **14. Action Menu Wire-Up:** Connect the remaining unimplemented Action Menu and "Add from resource script (.rc)" options to their respective backend logic.

- [x] **Feature:** Add a "Whats New" Dialog window to the menubar About section. Retain the last 3 versions "Whats New" paragraph. (Update this simultaneously with version updates).
- [x] **Bug:** Expand all and collapse all TreeView nodes menubar buttons do nothing.
- [x] **Bug:** Replace dialog is not populating any information or previews and is non-functional.



