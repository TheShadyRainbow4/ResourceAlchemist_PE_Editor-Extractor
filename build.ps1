$ErrorActionPreference = 'Stop'
$vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -property installationPath
if (-not $vsPath) { Write-Error "Visual Studio not found."; exit 1 }

$msbuild = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe
if (-not $msbuild) { Write-Error "MSBuild not found."; exit 1 }

Write-Host "Building x64..."
& $msbuild ResourceAlchemyHacker.sln /p:Configuration=Release /p:Platform=x64
if ($LASTEXITCODE -ne 0) { Write-Error "Build x64 failed."; exit 1 }

Write-Host "Building x86..."
& $msbuild ResourceAlchemyHacker.sln /p:Configuration=Release /p:Platform=x86
if ($LASTEXITCODE -ne 0) { Write-Error "Build x86 failed."; exit 1 }

$signtool = ".\SignTool\signtool.exe"
$pfx = ".\SignTool\EliteSoftware_Special.pfx"
$pass = "Minecraft145!!"

Write-Host "Signing executable binaries (x64)..."
& $signtool sign /f $pfx /p $pass /fd SHA256 /t http://timestamp.digicert.com /v ".\x64\Release\ResourceAlchemyHacker_CLI.exe"
& $signtool sign /f $pfx /p $pass /fd SHA256 /t http://timestamp.digicert.com /v ".\x64\Release\ResourceAlchemyHacker_GUI.exe"
& $signtool sign /f $pfx /p $pass /fd SHA256 /t http://timestamp.digicert.com /v ".\x64\Release\ResourceAlchemyHacker_ShellExt.dll"

Write-Host "Signing executable binaries (x86)..."
& $signtool sign /f $pfx /p $pass /fd SHA256 /t http://timestamp.digicert.com /v ".\Release\ResourceAlchemyHacker_CLI.exe"
& $signtool sign /f $pfx /p $pass /fd SHA256 /t http://timestamp.digicert.com /v ".\Release\ResourceAlchemyHacker_GUI.exe"
& $signtool sign /f $pfx /p $pass /fd SHA256 /t http://timestamp.digicert.com /v ".\Release\ResourceAlchemyHacker_ShellExt.dll"

# Sync version numbers
$appVersion = "1.4.0.0"
$versionContent = Get-Content -Path "version.h" -Raw
if ($versionContent -match '#define RAH_VERSION_ANSI "(.*)"') {
    $appVersion = $matches[1]
    (Get-Content -Path "Installer\setup.iss") -replace "^AppVersion=.*", "AppVersion=$appVersion" -replace "^OutputBaseFilename=.*", "OutputBaseFilename=ResourceAlchemyHacker_Installer_$appVersion" | Set-Content -Path "Installer\setup.iss"
    (Get-Content -Path "README.md") -replace "## Features \(v.* Update\)", "## Features (v$appVersion Update)" | Set-Content -Path "README.md"
}

& "S:\Projects\Inno Setup 6\iscc.exe" "Installer\setup.iss"

Write-Host "Signing Installer..."
& $signtool sign /f $pfx /p $pass /fd SHA256 /t http://timestamp.digicert.com /v ".\Installer\ResourceAlchemyHacker_Installer_$().exe"

Write-Host "Invoking Release Publisher..."
& .\publish_release.ps1 -AppVersion $appVersion
