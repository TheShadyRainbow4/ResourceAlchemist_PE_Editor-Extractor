$vsWherePath = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
if (Test-Path $vsWherePath) {
    $vsPath = & $vsWherePath -latest -property installationPath
    Write-Host 'Visual Studio installation path found:' $vsPath
    if ($vsPath) {
        $msbuild = Get-ChildItem -Path $vsPath -Filter 'MSBuild.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
        Write-Host 'MSBuild locations:'
        $msbuild | ForEach-Object { Write-Host " -$PSItem" }
        $cl = Get-ChildItem -Path $vsPath -Filter 'cl.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
        Write-Host 'cl.exe locations:'
        $cl | ForEach-Object { Write-Host " -$PSItem" }
    }
} else {
    Write-Host 'vswhere.exe not found.'
}

# Search PATH for msbuild and cl
$pathMsbuild = Get-Command msbuild.exe -ErrorAction SilentlyContinue
if ($pathMsbuild) { Write-Host 'MSBuild in PATH:' $pathMsbuild.Source }
$pathCl = Get-Command cl.exe -ErrorAction SilentlyContinue
if ($pathCl) { Write-Host 'cl.exe in PATH:' $pathCl.Source }

# Search for Inno Setup (ISCC.exe)
$pathIscc = Get-Command ISCC.exe -ErrorAction SilentlyContinue
if ($pathIscc) {
    Write-Host 'ISCC.exe in PATH:' $pathIscc.Source
} else {
    Write-Host 'Searching disk for ISCC.exe...'
    $iscc = Get-ChildItem -Path 'C:\Program Files', 'C:\Program Files (x86)' -Filter 'ISCC.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    if ($iscc) {
        Write-Host 'ISCC.exe found:'
        $iscc | ForEach-Object { Write-Host " -$PSItem" }
    } else {
        Write-Host 'ISCC.exe not found.'
    }
}
