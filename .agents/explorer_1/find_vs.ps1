Write-Host 'Searching C:\Program Files and C:\Program Files (x86) for MSBuild.exe...'
$msbuild = Get-ChildItem -Path "C:\Program Files", "C:\Program Files (x86)" -Filter "MSBuild.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
if ($msbuild) {
    Write-Host 'Found MSBuild.exe:'
    $msbuild | ForEach-Object { Write-Host " -$PSItem" }
} else {
    Write-Host 'MSBuild.exe not found in Program Files.'
}

Write-Host 'Searching C:\Program Files and C:\Program Files (x86) for cl.exe...'
$cl = Get-ChildItem -Path "C:\Program Files", "C:\Program Files (x86)" -Filter "cl.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
if ($cl) {
    Write-Host 'Found cl.exe:'
    $cl | ForEach-Object { Write-Host " -$PSItem" }
} else {
    Write-Host 'cl.exe not found in Program Files.'
}
