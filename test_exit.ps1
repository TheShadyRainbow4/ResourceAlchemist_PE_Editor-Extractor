Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
}
"@
$proc = Start-Process ".\x64\Release\ResourceAlchemyHacker_GUI.exe" -PassThru
Start-Sleep 2
$hwnd = [Win32]::FindWindow("ResourceAlchemyHackerGUI", "Resource Alchemy Hacker")
Write-Host "hwnd: $hwnd"
[Win32]::PostMessage($hwnd, 0x0111, [IntPtr]301, [IntPtr]::Zero) | Out-Null
Start-Sleep 2
Write-Host "HasExited: $($proc.HasExited)"
Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
