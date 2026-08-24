with open("ResourceAlchemyHacker_GUI/main.cpp", "r", encoding="utf-8") as f:
    code = f.read()

# 1. Add Export All to Action Menu
action_menu_replacement = """            HMENU hAction = CreatePopupMenu();
            AppendMenuW(hAction, MF_STRING, 5105, L"Export All Resources...");
            AppendMenuW(hAction, MF_SEPARATOR, 0, NULL);
            AppendMenuW(hAction, MF_STRING, 5301, L"Add a single binary or image resource...");"""
code = code.replace("            HMENU hAction = CreatePopupMenu();\n            AppendMenuW(hAction, MF_STRING, 5301, L\"Add a single binary or image resource...\");", action_menu_replacement)


# 2. Add handler for 5105
handler_5105 = """            } else if (ctrlId == 5105) {
                // Get folder to save to
                BROWSEINFOW bi = { 0 };
                bi.hwndOwner = hwnd;
                bi.lpszTitle = L"Select Root Folder to Export All Resources...";
                bi.ulFlags = BIF_RETURNONLYFSDIRS | BIF_USENEWUI;
                LPITEMIDLIST pidl = SHBrowseForFolderW(&bi);
                if (pidl) {
                    wchar_t outFolder[MAX_PATH];
                    if (SHGetPathFromIDListW(pidl, outFolder)) {
                        CoTaskMemFree(pidl);
                        
                        int count = 0;
                        HTREEITEM hRootNode = (HTREEITEM)SendMessageW(g_hwndListBox, TVM_GETNEXTITEM, TVGN_ROOT, 0);
                        while (hRootNode) {
                            wchar_t typeBuf[256] = {0};
                            TVITEMW tvi = {0};
                            tvi.hItem = hRootNode;
                            tvi.mask = TVIF_TEXT;
                            tvi.pszText = typeBuf;
                            tvi.cchTextMax = 256;
                            SendMessageW(g_hwndListBox, TVM_GETITEMW, 0, (LPARAM)&tvi);
                            std::wstring typeName = typeBuf;
                            
                            HTREEITEM hChild = (HTREEITEM)SendMessageW(g_hwndListBox, TVM_GETNEXTITEM, TVGN_CHILD, (LPARAM)hRootNode);
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
                            hRootNode = (HTREEITEM)SendMessageW(g_hwndListBox, TVM_GETNEXTITEM, TVGN_NEXT, (LPARAM)hRootNode);
                        }
                        
                        wchar_t msgBuf[256];
                        wsprintfW(msgBuf, L"Exported %d resources successfully to\\n%s", count, outFolder);
                        MessageBoxW(hwnd, msgBuf, L"Export Successful", MB_OK | MB_ICONINFORMATION);
                    }
                }
            } else if (ctrlId == IDC_BTN_SETTINGS) {"""
code = code.replace("            } else if (ctrlId == IDC_BTN_SETTINGS) {", handler_5105)

with open("ResourceAlchemyHacker_GUI/main.cpp", "w", encoding="utf-8") as f:
    f.write(code)
