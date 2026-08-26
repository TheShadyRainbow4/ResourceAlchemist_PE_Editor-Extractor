std::wstring ParseResourceToText(LPCWSTR typeId, void* data, DWORD size) {
    if (size == 0 || !data) return L"";
    
    // Check if typeId is an integer resource type
    bool isIntResource = IS_INTRESOURCE(typeId);
    
    if (isIntResource && (typeId == RT_VERSION || typeId == RT_STRING || typeId == RT_DIALOG || typeId == RT_MENU || typeId == RT_MESSAGETABLE)) {
        std::wstring out;
        wchar_t* ptr = (wchar_t*)data;
        DWORD wchars = size / 2;
        std::wstring currentStr;
        for (DWORD i = 0; i < wchars; ++i) {
            wchar_t c = ptr[i];
            if (c >= 32 && c <= 126 || c > 127) { // Basic printable check
                currentStr += c;
            } else {
                if (currentStr.length() >= 3) {
                    out += currentStr + L"\r\n";
                }
                currentStr.clear();
            }
        }
        if (currentStr.length() >= 3) out += currentStr + L"\r\n";
        if (out.empty()) out = L"(Binary data, no strings found)";
        return out;
    } else if (isIntResource && (typeId == RT_MANIFEST || typeId == RT_HTML)) {
        int wLen = MultiByteToWideChar(CP_UTF8, 0, (char*)data, size, NULL, 0);
        std::wstring out(wLen, 0);
        MultiByteToWideChar(CP_UTF8, 0, (char*)data, size, &out[0], wLen);
        return out;
    }
    
    // Fallback: Hex Dump for unknown binary data to prevent Mojibake
    std::wstring out;
    unsigned char* p = (unsigned char*)data;
    wchar_t buf[256];
    for (DWORD i = 0; i < size && i < 1024; i += 16) {
        swprintf(buf, 256, L"%08X  ", i);
        out += buf;
        for (DWORD j = 0; j < 16; ++j) {
            if (i + j < size) {
                swprintf(buf, 256, L"%02X ", p[i + j]);
                out += buf;
            } else {
                out += L"   ";
            }
        }
        out += L" ";
        for (DWORD j = 0; j < 16; ++j) {
            if (i + j < size) {
                unsigned char c = p[i + j];
                if (c >= 32 && c <= 126) {
                    out += (wchar_t)c;
                } else {
                    out += L".";
                }
            }
        }
        out += L"\r\n";
    }
    if (size > 1024) {
        out += L"\r\n... (Truncated for preview) ...\r\n";
    }
    return out;
}
