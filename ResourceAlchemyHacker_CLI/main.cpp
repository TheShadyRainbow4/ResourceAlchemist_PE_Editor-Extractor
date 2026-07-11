#include <windows.h>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
#include <iomanip>

#pragma pack(push, 1)
struct ICONDIR {
    WORD idReserved;
    WORD idType;
    WORD idCount;
};
struct ICONDIRENTRY {
    BYTE bWidth;
    BYTE bHeight;
    BYTE bColorCount;
    BYTE bReserved;
    WORD wPlanes;
    WORD wBitCount;
    DWORD dwBytesInRes;
    DWORD dwImageOffset;
};
struct GRPICONDIRENTRY {
    BYTE bWidth;
    BYTE bHeight;
    BYTE bColorCount;
    BYTE bReserved;
    WORD wPlanes;
    WORD wBitCount;
    DWORD dwBytesInRes;
    WORD nId;
};
#pragma pack(pop)

using namespace std;

void EliteLog(const wstring& msg) {
    wchar_t sysDrive[MAX_PATH];
    GetEnvironmentVariableW(L"SystemDrive", sysDrive, MAX_PATH);
    wstring logDir = wstring(sysDrive) + L"\\EliteSoftware\\Logs";
    CreateDirectoryW((wstring(sysDrive) + L"\\EliteSoftware").c_str(), NULL);
    CreateDirectoryW(logDir.c_str(), NULL);
    
    wstring logFile = logDir + L"\\ResourceAlchemist.log";
    
    SYSTEMTIME st;
    GetLocalTime(&st);
    
    wofstream out(logFile, ios::app);
    if (out.is_open()) {
        out << L"[" << setfill(L'0') << setw(4) << st.wYear << L"-" << setw(2) << st.wMonth << L"-" << setw(2) << st.wDay
            << L" " << setw(2) << st.wHour << L":" << setw(2) << st.wMinute << L":" << setw(2) << st.wSecond << L"] "
            << msg << endl;
    }
}

void LogWin32Error(const wstring& context, DWORD errCode = GetLastError()) {
    wstring witty;
    switch (errCode) {
        case ERROR_ACCESS_DENIED: witty = L"Windows slammed the door in our face. Are you running as Admin, or just pretending?"; break;
        case ERROR_SHARING_VIOLATION: witty = L"The file is currently being held hostage by another process. Kill it and try again."; break;
        case ERROR_FILE_NOT_FOUND: witty = L"File not found. Did it vanish into the void, or did you make a typo?"; break;
        case ERROR_RESOURCE_DATA_NOT_FOUND: witty = L"Resource not found. You're hunting ghosts in this binary."; break;
        default: witty = L"A technical anomaly occurred. Blame the gremlins."; break;
    }
    
    wstringstream ss;
    ss << context << L" - Error " << errCode << L": " << witty;
    EliteLog(ss.str());
}

wstring GetResIdOrName(LPCWSTR val) {
    if (IS_INTRESOURCE(val)) {
        return to_wstring((USHORT)(ULONG_PTR)val);
    }
    return wstring(val);
}

struct EnumCtx {
    HMODULE hMod;
    wstring typeName;
    wstring resName;
};

BOOL CALLBACK EnumResLangProc(HMODULE hModule, LPCWSTR lpszType, LPCWSTR lpszName, WORD wIDLanguage, LONG_PTR lParam) {
    EnumCtx* ctx = (EnumCtx*)lParam;
    HRSRC hRes = FindResourceExW(hModule, lpszType, lpszName, wIDLanguage);
    DWORD size = hRes ? SizeofResource(hModule, hRes) : 0;
    
    wcout << L"TYPE:" << ctx->typeName << L" | RES:" << ctx->resName << L" | LANG:" << wIDLanguage << L" | SIZE:" << size << endl << flush;
    return TRUE;
}

BOOL CALLBACK EnumResNameProc(HMODULE hModule, LPCWSTR lpszType, LPWSTR lpszName, LONG_PTR lParam) {
    EnumCtx* ctx = (EnumCtx*)lParam;
    ctx->resName = GetResIdOrName(lpszName);
    EnumResourceLanguagesW(hModule, lpszType, lpszName, EnumResLangProc, lParam);
    return TRUE;
}

BOOL CALLBACK EnumResTypeProc(HMODULE hModule, LPWSTR lpszType, LONG_PTR lParam) {
    EnumCtx ctx;
    ctx.hMod = hModule;
    ctx.typeName = GetResIdOrName(lpszType);
    EnumResourceNamesW(hModule, lpszType, EnumResNameProc, (LONG_PTR)&ctx);
    return TRUE;
}

void DoList(const wstring& target) {
    EliteLog(L"Starting enumeration scan on " + target);
    HMODULE hMod = LoadLibraryExW(target.c_str(), NULL, LOAD_LIBRARY_AS_DATAFILE | LOAD_LIBRARY_AS_IMAGE_RESOURCE);
    if (!hMod) {
        LogWin32Error(L"Failed to load target for enumeration");
        return;
    }
    EnumResourceTypesW(hMod, EnumResTypeProc, 0);
    FreeLibrary(hMod);
    EliteLog(L"Enumeration completed.");
}

bool ExtractIconGroup(HMODULE hMod, LPCWSTR resName, WORD lang, const wstring& outPath) {
    HRSRC hResGroup = FindResourceExW(hMod, RT_GROUP_ICON, resName, lang);
    if (!hResGroup) return false;
    HGLOBAL hMemGroup = LoadResource(hMod, hResGroup);
    void* pGroup = LockResource(hMemGroup);
    if (!pGroup) return false;

    ICONDIR* pGrpDir = (ICONDIR*)pGroup;
    GRPICONDIRENTRY* pGrpEntries = (GRPICONDIRENTRY*)((BYTE*)pGroup + sizeof(ICONDIR));

    ofstream out(outPath, ios::binary);
    if (!out) return false;

    // Write file header
    out.write((char*)pGrpDir, sizeof(ICONDIR));

    DWORD imageOffset = sizeof(ICONDIR) + (pGrpDir->idCount * sizeof(ICONDIRENTRY));
    vector<void*> iconData(pGrpDir->idCount);
    vector<DWORD> iconSizes(pGrpDir->idCount);

    // Write entries
    for (int i = 0; i < pGrpDir->idCount; ++i) {
        ICONDIRENTRY entry;
        entry.bWidth = pGrpEntries[i].bWidth;
        entry.bHeight = pGrpEntries[i].bHeight;
        entry.bColorCount = pGrpEntries[i].bColorCount;
        entry.bReserved = pGrpEntries[i].bReserved;
        entry.wPlanes = pGrpEntries[i].wPlanes;
        entry.wBitCount = pGrpEntries[i].wBitCount;
        entry.dwBytesInRes = pGrpEntries[i].dwBytesInRes;
        entry.dwImageOffset = imageOffset;

        out.write((char*)&entry, sizeof(ICONDIRENTRY));

        HRSRC hIconRes = FindResourceExW(hMod, RT_ICON, MAKEINTRESOURCEW(pGrpEntries[i].nId), lang);
        HGLOBAL hIconMem = LoadResource(hMod, hIconRes);
        iconData[i] = LockResource(hIconMem);
        iconSizes[i] = SizeofResource(hMod, hIconRes);
        imageOffset += iconSizes[i];
    }

    // Write pixel data
    for (int i = 0; i < pGrpDir->idCount; ++i) {
        if (iconData[i]) {
            out.write((char*)iconData[i], iconSizes[i]);
        }
    }

    out.close();
    return true;
}

void DoExtract(const wstring& target, const wstring& typeStr, const wstring& nameStr, WORD lang, const wstring& outPath) {
    EliteLog(L"Extracting resource " + typeStr + L"/" + nameStr + L" from " + target);
    HMODULE hMod = LoadLibraryExW(target.c_str(), NULL, LOAD_LIBRARY_AS_DATAFILE | LOAD_LIBRARY_AS_IMAGE_RESOURCE);
    if (!hMod) {
        LogWin32Error(L"Failed to load target for extraction");
        return;
    }

    LPCWSTR type = typeStr.c_str();
    if (typeStr == L"14" || typeStr.find(L"RT_GROUP_ICON") != wstring::npos) {
        if (ExtractIconGroup(hMod, MAKEINTRESOURCEW(_wtoi(nameStr.c_str())), lang, outPath)) {
            EliteLog(L"Successfully reconstructed and extracted RT_GROUP_ICON to " + outPath);
            FreeLibrary(hMod);
            return;
        }
    }

    if (typeStr.find(L"#") == 0) type = MAKEINTRESOURCEW(_wtoi(typeStr.c_str() + 1));
    else if (_wtoi(typeStr.c_str()) != 0) type = MAKEINTRESOURCEW(_wtoi(typeStr.c_str()));

    LPCWSTR name = nameStr.c_str();
    if (nameStr.find(L"#") == 0) name = MAKEINTRESOURCEW(_wtoi(nameStr.c_str() + 1));
    else if (_wtoi(nameStr.c_str()) != 0) name = MAKEINTRESOURCEW(_wtoi(nameStr.c_str()));

    HRSRC hRes = FindResourceExW(hMod, type, name, lang);
    if (!hRes) {
        LogWin32Error(L"FindResourceExW failed");
        FreeLibrary(hMod);
        return;
    }

    HGLOBAL hMem = LoadResource(hMod, hRes);
    void* pData = LockResource(hMem);
    DWORD dwSize = SizeofResource(hMod, hRes);

    if (pData && dwSize > 0) {
        ofstream out(outPath, ios::binary);
        if (out) {
            out.write((char*)pData, dwSize);
            EliteLog(L"Successfully dumped raw resource to " + outPath);
        } else {
            LogWin32Error(L"Failed to open output file");
        }
    } else {
        LogWin32Error(L"Failed to lock resource data");
    }
    FreeLibrary(hMod);
}

void BackupFile(const wstring& target) {
    wstring base = target;
    size_t extPos = base.find_last_of(L".");
    if (extPos != wstring::npos) base = base.substr(0, extPos);
    
    int index = 1;
    while (true) {
        wstring backupPath = base + L"_" + to_wstring(index) + L".bak";
        if (GetFileAttributesW(backupPath.c_str()) == INVALID_FILE_ATTRIBUTES) {
            if (CopyFileW(target.c_str(), backupPath.c_str(), TRUE)) {
                EliteLog(L"EliteSoftware Safety Backup Protocol: Created " + backupPath);
                return;
            } else {
                LogWin32Error(L"Safety Backup failed on CopyFileW");
                exit(3); // Abort
            }
        }
        index++;
    }
}

void DoReplace(const wstring& target, const wstring& typeStr, const wstring& nameStr, WORD lang, const wstring& inPath) {
    EliteLog(L"Replacing resource in " + target);
    BackupFile(target);

    HANDLE hUpdate = BeginUpdateResourceW(target.c_str(), FALSE);
    if (!hUpdate) {
        LogWin32Error(L"BeginUpdateResourceW failed");
        return;
    }

    ifstream in(inPath, ios::binary | ios::ate);
    if (!in) {
        EliteLog(L"Failed to read input file: " + inPath);
        EndUpdateResourceW(hUpdate, TRUE);
        return;
    }
    streamsize size = in.tellg();
    in.seekg(0, ios::beg);
    vector<char> buffer(size);
    in.read(buffer.data(), size);

    LPCWSTR type = typeStr.c_str();
    if (typeStr == L"14" || typeStr.find(L"RT_GROUP_ICON") != wstring::npos) {
        // Icon Deconstruction logic required here. For now, simple standard replace.
        // TODO: Full ICO deconstruction into RT_ICON and RT_GROUP_ICON
        EliteLog(L"Injecting pre-processed RT_GROUP_ICON or raw payload");
    }

    if (typeStr.find(L"#") == 0) type = MAKEINTRESOURCEW(_wtoi(typeStr.c_str() + 1));
    else if (_wtoi(typeStr.c_str()) != 0) type = MAKEINTRESOURCEW(_wtoi(typeStr.c_str()));

    LPCWSTR name = nameStr.c_str();
    if (nameStr.find(L"#") == 0) name = MAKEINTRESOURCEW(_wtoi(nameStr.c_str() + 1));
    else if (_wtoi(nameStr.c_str()) != 0) name = MAKEINTRESOURCEW(_wtoi(nameStr.c_str()));

    if (!UpdateResourceW(hUpdate, type, name, lang, buffer.data(), (DWORD)size)) {
        LogWin32Error(L"UpdateResourceW failed");
        EndUpdateResourceW(hUpdate, TRUE);
        return;
    }

    if (!EndUpdateResourceW(hUpdate, FALSE)) {
        LogWin32Error(L"EndUpdateResourceW failed to commit changes");
        return;
    }
    EliteLog(L"Successfully replaced resource.");
}

int wmain(int argc, wchar_t* argv[]) {
    if (argc < 3) {
        wcout << L"Syntax: ResourceAlchemistCLI.exe [ACTION] [TARGET_EXE] [OPTIONS]" << endl;
        wcout << L"Actions: /list, /extract, /replace" << endl;
        return 1;
    }

    wstring action = argv[1];
    wstring target = argv[2];

    if (action == L"/list") {
        DoList(target);
    } else if (action == L"/extract" && argc >= 7) {
        // /extract target type name lang outpath
        DoExtract(target, argv[3], argv[4], (WORD)_wtoi(argv[5]), argv[6]);
    } else if (action == L"/replace" && argc >= 7) {
        // /replace target type name lang inpath
        DoReplace(target, argv[3], argv[4], (WORD)_wtoi(argv[5]), argv[6]);
    } else {
        EliteLog(L"Invalid arguments provided.");
        return 2;
    }

    return 0;
}
