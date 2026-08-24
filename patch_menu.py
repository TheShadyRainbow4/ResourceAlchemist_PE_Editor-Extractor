import re

with open("ResourceAlchemyHacker_GUI/main.cpp", "r", encoding="utf-8") as f:
    code = f.read()

# 1. Update View menu
view_menu_replacement = """            HMENU hView = CreatePopupMenu();
            AppendMenuW(hView, MF_STRING, 5401, L"Expand Tree Node\\tCtrl+E");
            AppendMenuW(hView, MF_STRING, 5402, L"Collapse Tree Node\\tCtrl+C");
            AppendMenuW(hView, MF_SEPARATOR, 0, NULL);
            AppendMenuW(hView, MF_STRING, 5403, L"Expand All Nodes\\tCtrl+Shift+E");
            AppendMenuW(hView, MF_STRING, 5404, L"Collapse All Nodes\\tCtrl+Shift+C");"""
code = re.sub(r'            HMENU hView = CreatePopupMenu\(\);\s*AppendMenuW\(hView, MF_STRING, 5401, L"Expand Tree Node\\tCtrl\+E"\);\s*AppendMenuW\(hView, MF_STRING, 5402, L"Collapse Tree Node\\tCtrl\+C"\);', view_menu_replacement, code)

# 2. Update WM_CONTEXTMENU
context_menu_replacement = """                    HTREEITEM hParent = (HTREEITEM)SendMessageW(hTree, TVM_GETNEXTITEM, TVGN_PARENT, (LPARAM)ht.hItem);
                    HMENU hMenu = CreatePopupMenu();
                    
                    if (hParent == NULL) {
                        AppendMenuW(hMenu, MF_STRING, 5004, L"Export All Resources of Type...");
                    } else {
                        AppendMenuW(hMenu, MF_STRING, 5001, L"Extract Resource...");
                        AppendMenuW(hMenu, MF_STRING, 5003, L"Replace Resource...");
                        AppendMenuW(hMenu, MF_STRING, 5002, L"Delete Resource");
                    }
                    
                    int cmd = TrackPopupMenu(hMenu, TPM_RETURNCMD | TPM_NONOTIFY, pt.x, pt.y, 0, hwnd, NULL);
                    DestroyMenu(hMenu);
                    
                    if (cmd == 5001) {
                        SendMessageW(GetParent(hwnd), WM_COMMAND, MAKEWPARAM(IDC_BTN_EXTRACT, BN_CLICKED), 0);
                    } else if (cmd == 5003) {
                        SendMessageW(GetParent(hwnd), WM_COMMAND, MAKEWPARAM(IDC_BTN_REPLACE, BN_CLICKED), 0);
                    } else if (cmd == 5002) {
                        SendMessageW(GetParent(hwnd), WM_COMMAND, MAKEWPARAM(IDC_BTN_DELETE, BN_CLICKED), 0);
                    } else if (cmd == 5004) {
                        SendMessageW(GetParent(hwnd), WM_COMMAND, MAKEWPARAM(5004, BN_CLICKED), (LPARAM)ht.hItem);
                    }"""
code = re.sub(r'                    HMENU hMenu = CreatePopupMenu\(\);\s*AppendMenuW\(hMenu, MF_STRING, 5001, L"Extract Resource\.\.\."\);\s*AppendMenuW\(hMenu, MF_STRING, 5002, L"Delete Resource"\);\s*int cmd = TrackPopupMenu.*?if \(cmd == 5001\) \{.*?\}.*?\} else if \(cmd == 5002\) \{.*?\}.*?\}', context_menu_replacement, code, flags=re.DOTALL)

# 3. Add WM_COMMAND handlers
handlers = """            } else if (ctrlId == 5401) {
                HTREEITEM hSel = (HTREEITEM)SendMessageW(g_hwndListBox, TVM_GETNEXTITEM, TVGN_CARET, 0);
                if (hSel) SendMessageW(g_hwndListBox, TVM_EXPAND, TVE_EXPAND, (LPARAM)hSel);
            } else if (ctrlId == 5402) {
                HTREEITEM hSel = (HTREEITEM)SendMessageW(g_hwndListBox, TVM_GETNEXTITEM, TVGN_CARET, 0);
                if (hSel) SendMessageW(g_hwndListBox, TVM_EXPAND, TVE_COLLAPSE, (LPARAM)hSel);
            } else if (ctrlId == 5403) {
                HTREEITEM hRoot = (HTREEITEM)SendMessageW(g_hwndListBox, TVM_GETNEXTITEM, TVGN_ROOT, 0);
                while (hRoot) {
                    SendMessageW(g_hwndListBox, TVM_EXPAND, TVE_EXPAND, (LPARAM)hRoot);
                    hRoot = (HTREEITEM)SendMessageW(g_hwndListBox, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)hRoot);
                }
            } else if (ctrlId == 5404) {
                HTREEITEM hRoot = (HTREEITEM)SendMessageW(g_hwndListBox, TVM_GETNEXTITEM, TVGN_ROOT, 0);
                while (hRoot) {
                    SendMessageW(g_hwndListBox, TVM_EXPAND, TVE_COLLAPSE, (LPARAM)hRoot);
                    hRoot = (HTREEITEM)SendMessageW(g_hwndListBox, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)hRoot);
                }
            } else if (ctrlId == 5004) {
                HTREEITEM hRootNode = (HTREEITEM)lParam;
                if (!hRootNode) break;
                
                wchar_t typeBuf[256] = {0};
                TVITEMW tvi = {0};
                tvi.hItem = hRootNode;
                tvi.mask = TVIF_TEXT;
                tvi.pszText = typeBuf;
                tvi.cchTextMax = 256;
                SendMessageW(g_hwndListBox, TVM_GETITEMW, 0, (LPARAM)&tvi);
                std::wstring typeName = typeBuf;
                
                // Get folder to save to
                BROWSEINFOW bi = { 0 };
                bi.hwndOwner = hwnd;
                bi.lpszTitle = L"Select Folder to Export All Resources...";
                bi.ulFlags = BIF_RETURNONLYFSDIRS | BIF_USENEWUI;
                LPITEMIDLIST pidl = SHBrowseForFolderW(&bi);
                if (pidl) {
                    wchar_t outFolder[MAX_PATH];
                    if (SHGetPathFromIDListW(pidl, outFolder)) {
                        CoTaskMemFree(pidl);
                        
                        HTREEITEM hChild = (HTREEITEM)SendMessageW(g_hwndListBox, TVM_GETNEXTITEM, TVGN_CHILD, (LPARAM)hRootNode);
                        int count = 0;
                        while (hChild != NULL) {
                            wchar_t nameBuf[256] = {0};
                            tvi.hItem = hChild;
                            tvi.mask = TVIF_TEXT | TVIF_PARAM;
                            tvi.pszText = nameBuf;
                            tvi.cchTextMax = 256;
                            SendMessageW(g_hwndListBox, TVM_GETITEMW, 0, (LPARAM)&tvi);
                            std::wstring resName = nameBuf;
                            int origin = (int)tvi.lParam;
                            
                            // strip [Base] etc.
                            if (resName.length() >= 7 && resName.substr(resName.length() - 7) == L" [Base]") resName = resName.substr(0, resName.length() - 7);
                            else if (resName.length() >= 6 && resName.substr(resName.length() - 6) == L" [MUN]") resName = resName.substr(0, resName.length() - 6);
                            else if (resName.length() >= 6 && resName.substr(resName.length() - 6) == L" [MUI]") resName = resName.substr(0, resName.length() - 6);
                            
                            std::wstring lang = L"0";
                            
                            std::wstring originPath = GetFileFromOrigin(origin);
                            size_t slash = originPath.find_last_of(L"\\\\/");
                            std::wstring baseName = (slash != std::wstring::npos) ? originPath.substr(slash + 1) : originPath;
                            
                            std::wstring dynamicFolderName = baseName + L"-" + typeName;
                            // Clean up dynamic folder name chars
                            for (wchar_t& c : dynamicFolderName) {
                                if (c == L' ' || c == L':' || c == L'*' || c == L'?' || c == L'\"' || c == L'<' || c == L'>' || c == L'|') c = L'_';
                            }
                            
                            std::wstring targetDir = std::wstring(outFolder) + L"\\\\" + dynamicFolderName;
                            CreateDirectoryW(targetDir.c_str(), NULL);
                            
                            std::wstring ext = L".bin";
                            if (typeName == L"Icon Group") ext = L".ico";
                            else if (typeName == L"Bitmap") ext = L".bmp";
                            else if (typeName == L"XML" || typeName == L"Manifest") ext = L".xml";
                            
                            // Clean up resource name for file name
                            std::wstring safeResName = resName;
                            for (wchar_t& c : safeResName) {
                                if (c == L' ' || c == L'/' || c == L'\\\\' || c == L':' || c == L'*' || c == L'?' || c == L'\"' || c == L'<' || c == L'>' || c == L'|') c = L'_';
                            }
                            
                            std::wstring targetFile = targetDir + L"\\\\" + safeResName + ext;
                            
                            // We need real type to pass to extract
                            std::wstring realType = typeName;
                            if (typeName == L"Icon Group") realType = L"#14";
                            else if (typeName == L"Icon") realType = L"#3";
                            else if (typeName == L"Bitmap") realType = L"#2";
                            else if (typeName == L"Cursor") realType = L"#1";
                            else if (typeName == L"Group Cursor") realType = L"#12";
                            else if (typeName == L"Dialog") realType = L"#5";
                            else if (typeName == L"String Table") realType = L"#6";
                            else if (typeName == L"Version Info") realType = L"#16";
                            else if (typeName == L"Manifest") realType = L"#24";
                            
                            RunCLIAction(L"/extract", originPath, realType, resName, lang, targetFile);
                            count++;
                            
                            hChild = (HTREEITEM)SendMessageW(g_hwndListBox, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)hChild);
                        }
                        
                        wchar_t msgBuf[256];
                        wsprintfW(msgBuf, L"Exported %d resources successfully to\\n%s", count, outFolder);
                        MessageBoxW(hwnd, msgBuf, L"Export Successful", MB_OK | MB_ICONINFORMATION);
                    }
                }
            } else if (ctrlId == IDC_BTN_SETTINGS) {"""
code = code.replace("            } else if (ctrlId == IDC_BTN_SETTINGS) {", handlers)

with open("ResourceAlchemyHacker_GUI/main.cpp", "w", encoding="utf-8") as f:
    f.write(code)
