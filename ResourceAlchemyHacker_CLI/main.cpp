#include <windows.h>
#include <iostream>
#include <string>
#include <vector>
#include <fstream>

// ResourceAlchemyHacker_CLI
// Backend worker for extracting and injecting resources.

using namespace std;

void PrintUsage() {
    cout << "ResourceAlchemyHacker_CLI" << endl;
    cout << "Usage:" << endl;
    cout << "  list <file>" << endl;
    cout << "  extract <file> <type> <name> <output_file>" << endl;
    cout << "  replace <file> <type> <name> <language> <input_file>" << endl;
}

BOOL CALLBACK EnumResNameProc(HMODULE hModule, LPCWSTR lpszType, LPWSTR lpszName, LONG_PTR lParam) {
    if (IS_INTRESOURCE(lpszName)) {
        wcout << L"  Name: " << (USHORT)lpszName << endl;
    } else {
        wcout << L"  Name: " << lpszName << endl;
    }
    return TRUE;
}

BOOL CALLBACK EnumResTypeProc(HMODULE hModule, LPWSTR lpszType, LONG_PTR lParam) {
    if (IS_INTRESOURCE(lpszType)) {
        wcout << L"Type: " << (USHORT)lpszType << endl;
    } else {
        wcout << L"Type: " << lpszType << endl;
    }
    EnumResourceNamesW(hModule, lpszType, EnumResNameProc, 0);
    return TRUE;
}

void ListResources(const wstring& file) {
    HMODULE hModule = LoadLibraryExW(file.c_str(), NULL, LOAD_LIBRARY_AS_DATAFILE);
    if (!hModule) {
        wcerr << L"Failed to load file for listing: " << file << endl;
        return;
    }
    wcout << L"Resources in " << file << L":" << endl;
    EnumResourceTypesW(hModule, EnumResTypeProc, 0);
    FreeLibrary(hModule);
}

bool ExtractResourceToFile(const wstring& file, const wstring& type, const wstring& name, const wstring& output) {
    HMODULE hModule = LoadLibraryExW(file.c_str(), NULL, LOAD_LIBRARY_AS_DATAFILE);
    if (!hModule) {
        wcerr << L"Failed to load file: " << file << endl;
        return false;
    }

    LPCWSTR resType = type.c_str();
    if (type.find(L"#") == 0) resType = MAKEINTRESOURCEW(_wtoi(type.c_str() + 1));
    
    LPCWSTR resName = name.c_str();
    if (name.find(L"#") == 0) resName = MAKEINTRESOURCEW(_wtoi(name.c_str() + 1));

    HRSRC hResInfo = FindResourceW(hModule, resName, resType);
    if (!hResInfo) {
        wcerr << L"Resource not found." << endl;
        FreeLibrary(hModule);
        return false;
    }

    HGLOBAL hResData = LoadResource(hModule, hResInfo);
    if (!hResData) {
        wcerr << L"Failed to load resource data." << endl;
        FreeLibrary(hModule);
        return false;
    }

    DWORD resSize = SizeofResource(hModule, hResInfo);
    void* pRes = LockResource(hResData);

    ofstream outFile(output, ios::binary);
    if (outFile.is_open()) {
        outFile.write(reinterpret_cast<const char*>(pRes), resSize);
        outFile.close();
        wcout << L"Extracted " << resSize << L" bytes to " << output << endl;
    } else {
        wcerr << L"Failed to open output file: " << output << endl;
    }

    FreeLibrary(hModule);
    return true;
}

bool ReplaceResourceInFile(const wstring& file, const wstring& type, const wstring& name, WORD language, const wstring& input) {
    ifstream inFile(input, ios::binary | ios::ate);
    if (!inFile.is_open()) {
        wcerr << L"Failed to open input file: " << input << endl;
        return false;
    }
    streamsize size = inFile.tellg();
    inFile.seekg(0, ios::beg);
    vector<char> buffer(size);
    if (!inFile.read(buffer.data(), size)) {
        wcerr << L"Failed to read input file." << endl;
        return false;
    }

    HANDLE hUpdate = BeginUpdateResourceW(file.c_str(), FALSE);
    if (!hUpdate) {
        wcerr << L"Failed to begin update resource on file: " << file << endl;
        return false;
    }

    LPCWSTR resType = type.c_str();
    if (type.find(L"#") == 0) resType = MAKEINTRESOURCEW(_wtoi(type.c_str() + 1));
    
    LPCWSTR resName = name.c_str();
    if (name.find(L"#") == 0) resName = MAKEINTRESOURCEW(_wtoi(name.c_str() + 1));

    if (!UpdateResourceW(hUpdate, resType, resName, language, buffer.data(), (DWORD)size)) {
        wcerr << L"Failed to update resource." << endl;
        EndUpdateResourceW(hUpdate, TRUE); // Discard
        return false;
    }

    if (!EndUpdateResourceW(hUpdate, FALSE)) {
        wcerr << L"Failed to save updated file." << endl;
        return false;
    }

    wcout << L"Successfully replaced resource." << endl;
    return true;
}

int wmain(int argc, wchar_t* argv[]) {
    if (argc < 2) {
        PrintUsage();
        return 1;
    }

    wstring cmd = argv[1];
    if (cmd == L"list" && argc == 3) {
        ListResources(argv[2]);
    } else if (cmd == L"extract" && argc == 6) {
        ExtractResourceToFile(argv[2], argv[3], argv[4], argv[5]);
    } else if (cmd == L"replace" && argc == 7) {
        ReplaceResourceInFile(argv[2], argv[3], argv[4], (WORD)_wtoi(argv[5]), argv[6]);
    } else {
        PrintUsage();
        return 1;
    }

    return 0;
}
