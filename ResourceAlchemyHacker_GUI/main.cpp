#include <windows.h>
#include <commctrl.h>
#include <string>

#pragma comment(lib, "comctl32.lib")

// EliteSoftware GUI Guidelines enforce Native Win32 aesthetics with visual styles.
#pragma comment(linker,"\"/manifestdependency:type='win32' \
name='Microsoft.Windows.Common-Controls' version='6.0.0.0' \
processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);

int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPWSTR lpCmdLine, int nCmdShow) {
    INITCOMMONCONTROLSEX icex;
    icex.dwSize = sizeof(INITCOMMONCONTROLSEX);
    icex.dwICC = ICC_WIN95_CLASSES | ICC_STANDARD_CLASSES;
    InitCommonControlsEx(&icex);

    const wchar_t CLASS_NAME[] = L"ResourceAlchemyHackerGUI";

    WNDCLASSW wc = { };
    wc.lpfnWndProc   = WndProc;
    wc.hInstance     = hInstance;
    wc.lpszClassName = CLASS_NAME;
    wc.hbrBackground = (HBRUSH)(COLOR_BTNFACE + 1);

    RegisterClassW(&wc);

    HWND hwnd = CreateWindowExW(
        WS_EX_CLIENTEDGE, // Client edge
        CLASS_NAME,
        L"Resource Alchemy Hacker - EliteSoftwareTech Co.",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 800, 600,
        NULL,
        NULL,
        hInstance,
        NULL
    );

    if (hwnd == NULL) {
        return 0;
    }

    ShowWindow(hwnd, nCmdShow);

    MSG msg = { };
    while (GetMessage(&msg, NULL, 0, 0) > 0) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return 0;
}

LRESULT CALLBACK WndProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
    case WM_PAINT:
        {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);
            
            // Draw Banner
            RECT rect;
            GetClientRect(hwnd, &rect);
            RECT bannerRect = rect;
            bannerRect.bottom = 60; // Banner height
            
            HBRUSH hBannerBrush = CreateSolidBrush(RGB(50, 50, 100)); // Darkish banner
            FillRect(hdc, &bannerRect, hBannerBrush);
            DeleteObject(hBannerBrush);
            
            SetTextColor(hdc, RGB(255, 255, 255));
            SetBkMode(hdc, TRANSPARENT);
            
            HFONT hFont = CreateFontW(24, 0, 0, 0, FW_SEMIBOLD, FALSE, FALSE, FALSE, DEFAULT_CHARSET, OUT_OUTLINE_PRECIS,
                CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, VARIABLE_PITCH, L"Segoe UI");
            SelectObject(hdc, hFont);
            
            DrawTextW(hdc, L"Resource Alchemy Hacker", -1, &bannerRect, DT_SINGLELINE | DT_VCENTER | DT_CENTER);
            DeleteObject(hFont);
            
            // Draw Chin
            RECT chinRect = rect;
            chinRect.top = rect.bottom - 40;
            HBRUSH hChinBrush = CreateSolidBrush(RGB(200, 200, 200));
            FillRect(hdc, &chinRect, hChinBrush);
            DeleteObject(hChinBrush);

            EndPaint(hwnd, &ps);
        }
        return 0;

    case WM_CREATE:
        {
            // Add native win32 elements
            HWND hBtn = CreateWindowW(
                L"BUTTON",  L"Okay",
                WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
                680, 530, 80, 25,
                hwnd, (HMENU)1, (HINSTANCE)GetWindowLongPtr(hwnd, GWLP_HINSTANCE), NULL);
        }
        return 0;

    case WM_COMMAND:
        if (LOWORD(wParam) == 1) {
            PostQuitMessage(0);
        }
        return 0;

    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}
