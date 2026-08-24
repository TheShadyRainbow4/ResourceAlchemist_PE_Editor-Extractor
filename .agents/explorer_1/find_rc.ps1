Write-Host 'Searching C:\Program Files and C:\Program Files (x86) for rc.exe...'
$rc = Get-ChildItem -Path "C:\Program Files", "C:\Program Files (x86)" -Filter "rc.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
if ($rc) {
    Write-Host 'Found rc.exe:'
    $rc | ForEach-Object { Write-Host " -$PSItem" }
} else {
    Write-Host 'rc.exe not found.'
}
