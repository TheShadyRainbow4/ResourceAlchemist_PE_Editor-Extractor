$vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
if (-not $vsPath) {
    Write-Error "Visual Studio not found."
    exit 1
}

$vcvars = "$vsPath\VC\Auxiliary\Build\vcvarsall.bat"
if (-not (Test-Path $vcvars)) {
    Write-Error "vcvarsall.bat not found at $vcvars"
    exit 1
}

$buildCmd = @"
call "$vcvars" x64
cd ResourceAlchemyHacker_CLI
cl.exe /EHsc /MD /O2 /Fe"ResourceAlchemyHacker_CLI.exe" main.cpp User32.lib
"@

$buildCmd | Out-File "build.bat" -Encoding ASCII
cmd.exe /c build.bat
