$ErrorActionPreference = 'Stop'

Write-Host "=========================================================="
Write-Host " EliteSoftware ResourceAlchemist - GUI UI Automation Test"
Write-Host "=========================================================="

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    public const uint WM_COMMAND = 0x0111;
}
"@

$process = Start-Process -FilePath "..\x64\Release\ResourceAlchemyHacker_GUI.exe" -PassThru

Write-Host "[+] Waiting for GUI to initialize..."
Start-Sleep -Seconds 3

$hwnd = [Win32]::FindWindow("ResourceAlchemyHackerGUI", "Resource Alchemy Hacker")
if ($hwnd -eq [IntPtr]::Zero) {
    Stop-Process -Id $process.Id -Force
    throw "Could not find main GUI window!"
}

Write-Host "[+] Found Main Window: $hwnd"
[Win32]::SetForegroundWindow($hwnd)

$commands = @(
    @{ Name = "IDM_TEST_LOAD"; ID = 2000; Modal = $false },
    @{ Name = "IDC_BTN_LIST"; ID = 204; Modal = $false },
    @{ Name = "IDM_HELP_CONTENTS"; ID = 302; Modal = $true },
    @{ Name = "IDM_HELP_ABOUT"; ID = 303; Modal = $true },
    @{ Name = "IDC_BTN_SETTINGS"; ID = 207; Modal = $true },
    @{ Name = "IDC_BTN_EXTRACT"; ID = 211; Modal = $true },
    @{ Name = "IDC_BTN_REPLACE"; ID = 205; Modal = $true },
    @{ Name = "IDC_BTN_ADD"; ID = 213; Modal = $true },
    @{ Name = "IDC_BTN_DELETE"; ID = 212; Modal = $true }
)

foreach ($cmd in $commands) {
    Write-Host "[+] Testing Command: $($cmd.Name) (ID: $($cmd.ID))"
    
    if ($cmd.Modal) {
        [Win32]::PostMessage($hwnd, [Win32]::WM_COMMAND, [IntPtr]$cmd.ID, [IntPtr]::Zero) | Out-Null
        Start-Sleep -Milliseconds 500
        
        $wshell = New-Object -ComObject wscript.shell
        $wshell.SendKeys("{ESC}")
        Start-Sleep -Milliseconds 500
    } else {
        [Win32]::PostMessage($hwnd, [Win32]::WM_COMMAND, [IntPtr]$cmd.ID, [IntPtr]::Zero) | Out-Null
        Start-Sleep -Milliseconds 500
    }
}

Write-Host "[+] Testing IDM_FILE_EXIT to close application normally"
[Win32]::PostMessage($hwnd, [Win32]::WM_COMMAND, [IntPtr]301, [IntPtr]::Zero) | Out-Null

Start-Sleep -Seconds 2

if (-not $process.HasExited) {
    Write-Host "[-] Process did not exit gracefully. Force killing..."
    Stop-Process -Id $process.Id -Force
    exit 1
}

Write-Host "[+] SUCCESS: All GUI functions tested via message routing."
