$ErrorActionPreference = 'Stop'

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
}
"@

$process = Start-Process -FilePath ".\x64\Release\ResourceAlchemyHacker_GUI.exe" -PassThru
Start-Sleep -Seconds 3

$hwnd = [Win32]::FindWindow("ResourceAlchemyHackerGUI", "Resource Alchemy Hacker")
[Win32]::SetForegroundWindow($hwnd)

Write-Host "Sending DELETE..."
[Win32]::PostMessage($hwnd, 0x0111, [IntPtr]212, [IntPtr]::Zero) | Out-Null
Start-Sleep 1

Write-Host "Sending ESC..."
$wshell = New-Object -ComObject wscript.shell
$wshell.SendKeys("{ESC}")
Start-Sleep 1

Write-Host "Sending EXIT..."
[Win32]::PostMessage($hwnd, 0x0111, [IntPtr]301, [IntPtr]::Zero) | Out-Null
Start-Sleep 2

Write-Host "HasExited: $($process.HasExited)"
Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
