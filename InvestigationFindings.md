# Resource Alchemy Hacker - Investigation Findings

This document outlines the findings from my initial analysis of the project's state, source code, and logic. Our primary goal is to address the bugs and requested features efficiently while maintaining the established C++ Win32 architecture and "EliteSoftware" legacy aesthetics, without destroying or overwriting any functional work.

## 1. The `main.cpp` Corruption Anomaly
**Finding:** Upon initial investigation, the physical file at `ResourceAlchemyHacker_GUI/main.cpp` was found to be corrupted, overwritten by a truncated JSON conversation log from a past AI agent's session.
**Mitigation Strategy:** Fortunately, I located a complete patch file (`diff.txt`) in the root directory which contains the uncorrupted, 2,897-line source code. I have successfully extracted this source code to a temporary scratch directory. Our first implementation step will be to securely restore this code to `main.cpp` so that normal compilation can resume.

## 2. Initial Layout Scaling Issue
**Finding:** The GUI application is a classic C++ Win32 application. When the main window (`g_hwndMain`) is created, Windows automatically sends a `WM_SIZE` message. However, the custom child elements (like the tree view, preview pane, and status bar) are instantiated *after* or *during* this initial layout pass, meaning their internal `WM_SIZE` layout algorithms are never explicitly triggered after all elements exist. 
**Mitigation Strategy:** Inside `WinMain`, immediately before the `GetMessageW` loop begins, we can inject a manual `PostMessageW(g_hwndMain, WM_SIZE, ...)` or `SendMessageW` to force a complete and correct layout pass after everything has been instantiated. This will instantly snap the UI into place without manual resizing.

## 3. TreeView Icon Previews
**Finding:** The `GuiListResources` function parses the PE file but likely assigns a static image index to the `TreeView` nodes. To get Resource Hacker-like previews, the application needs to dynamically extract `RT_ICON` or `RT_GROUP_ICON` resources into an `HICON`, append them to the TreeView's `HIMAGELIST`, and assign that specific image index to the newly created TreeView node.
**Mitigation Strategy:** We will modify `GuiListResources` to intercept `RT_ICON` / `RT_GROUP_ICON` iteration. Using Win32 APIs like `CreateIconFromResourceEx`, we can generate the `HICON` dynamically, add it to the TreeView's ImageList (`ImageList_AddIcon`), and set the `iImage` and `iSelectedImage` struct members for the `TVITEM`.

## 4. "Version Info" Rendering & Line Wrapping
**Finding:** The "Version Info" resource is typically stored as a `VS_VERSIONINFO` struct containing UTF-16LE text. When extracted, if it's blindly dumped into an ANSI `EDIT` control, you get Mojibake ("䀁ᶰ?"). Furthermore, Win32 `EDIT` controls word-wrap by default unless explicitly given `WS_HSCROLL` and `ES_AUTOHSCROLL`.
**Mitigation Strategy:** 
1. Convert the extracted binary buffer from UTF-16 to a standard `std::wstring` and use `SetWindowTextW`.
2. Modify the `CreateWindowEx` call for the text preview pane to include `WS_HSCROLL | ES_AUTOHSCROLL | WS_VSCROLL | ES_MULTILINE`.
3. For line numbers, we will need to inject a custom drawing routine (subclassing the edit control or using a RichEdit control) or a side-panel `STATIC` control synced to the edit control's scrolling.

## 5. "Extract Monolithic" & Export Logic
**Finding:** The current export logic seems to just execute a raw file copy or dumping the PE headers, resulting in a broken binary. The goal is to extract resources into folders (e.g., `Export/Icon Groups/`, `Export/Bitmaps/`).
**Mitigation Strategy:** We will write a recursive extraction function in the CLI (or GUI) that iterates over `EnumResourceTypesW` and `EnumResourceNamesW`. For each resource, we generate a valid file extension (`.ico`, `.bmp`, `.manifest`) and write the raw binary blob to disk inside a dynamically created directory named after the resource type.

## 6. Smart File Overwrite & Backups (.bak iteration)
**Finding:** Saving currently overwrites files blindly or with a hardcoded `_1.bak`.
**Mitigation Strategy:** Before writing to the target file, we will implement a loop utilizing `PathFileExistsW` (or `std::filesystem`). It will check for `file.1.bak`, `file.2.bak`, etc., incrementing the counter until a free slot is found, and then execute a safe `CopyFileW` before allowing the modification to occur.

## 7. Action Menus & Context Menus
**Finding:** The "Action" menus and "Add from resource script" are disconnected from the command router (`WM_COMMAND`).
**Mitigation Strategy:** We will implement `WM_CONTEXTMENU` for the TreeView. Based on the selected node (`TreeView_GetSelection`), we will dynamically populate the Action menu. The "Add from resource script" will invoke `rc.exe` (if available via Windows SDK) or implement a basic resource compiler wrapper.

## 8. Smart Image Replacement (Format Conversion)
**Finding:** The user wants to feed the tool any image (PNG, BMP, JPG) and have it automatically converted or scaled to the correct resource type (e.g., building a multi-size `.ico` container from a `.png`).
**Mitigation Strategy:** We will utilize GDI+ (`GdiplusStartup`) to load arbitrary image formats. If replacing an Icon Group, we will use GDI+ to rescale the image to `16, 24, 32, 48, 64, 128, 256` sizes and manually construct an `ICONDIR` and `ICONDIRENTRY` structure in memory to inject a perfect ICO file.

## Conclusion & Next Steps
None of the planned fixes will destroy existing work. We will proceed methodically, addressing the corruption first, followed by the UI scaling and text rendering issues. We will implement these changes two at a time as requested, ensuring the user can thoroughly test each batch.
