$ErrorActionPreference = 'Stop'
$msbuild = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"

Write-Host "Building x64..."
& $msbuild ResourceAlchemyHacker.sln /p:Configuration=Release /p:Platform=x64
if ($LASTEXITCODE -ne 0) { Write-Error "Build x64 failed."; exit 1 }

Write-Host "Building x86..."
& $msbuild ResourceAlchemyHacker.sln /p:Configuration=Release /p:Platform=x86
if ($LASTEXITCODE -ne 0) { Write-Error "Build x86 failed."; exit 1 }

$sdkRoot = "C:\Program Files (x86)\Windows Kits"
$signtool = ""
if (Test-Path $sdkRoot) {
    $versions = Get-ChildItem -Path (Join-Path $sdkRoot "10\bin") -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
    foreach ($v in $versions) {
        $p = Join-Path $v.FullName "x64\signtool.exe"
        if (Test-Path $p) { $signtool = $p; break }
    }
}
if (!$signtool) { $signtool = "signtool.exe" }
$pfx = "C:\EliteSoftware PE TOOLS\Elite-EasySigner\EliteSoftware_Special.pfx"
$pass = "Minecraft145!!"

Write-Host "Signing executable binaries (x64)..."
& $signtool sign /f $pfx /p $pass /fd SHA256 /v ".\x64\Release\ResourceAlchemyHacker_CLI.exe"
& $signtool sign /f $pfx /p $pass /fd SHA256 /v ".\x64\Release\ResourceAlchemyHacker_GUI.exe"
& $signtool sign /f $pfx /p $pass /fd SHA256 /v ".\x64\Release\ResourceAlchemyHacker_ShellExt.dll"

Write-Host "Signing executable binaries (x86)..."
& $signtool sign /f $pfx /p $pass /fd SHA256 /v ".\Release\ResourceAlchemyHacker_CLI.exe"
& $signtool sign /f $pfx /p $pass /fd SHA256 /v ".\Release\ResourceAlchemyHacker_GUI.exe"
& $signtool sign /f $pfx /p $pass /fd SHA256 /v ".\Release\ResourceAlchemyHacker_ShellExt.dll"

# Sync version numbers
$appVersion = "1.4.0.0"
$versionContent = Get-Content -Path "version.h" -Raw
if ($versionContent -match '#define RAH_VERSION L"(.*?)"') {
    $appVersion = $matches[1]
}

Write-Host "Creating Inno Setup Installers..."
$issBase = Get-Content "Installer\setup.iss" -Raw
$issX64 = $issBase -replace 'OutputBaseFilename=.*', "OutputBaseFilename=ResourceAlchemyHacker_Installer_x64_$appVersion" -replace 'AppVersion=.*', "AppVersion=$appVersion"
$issX64 | Set-Content "Installer\setup_x64.iss"

$issX86 = $issBase -replace 'ArchitecturesInstallIn64BitMode=x64compatible
', '' -replace 'ArchitecturesAllowed=x64compatible
', '' -replace 'OutputBaseFilename=.*', "OutputBaseFilename=ResourceAlchemyHacker_Installer_x86_$appVersion" -replace 'AppVersion=.*', "AppVersion=$appVersion" -replace '\\x64\\Release\\', '\Release\'
$issX86 | Set-Content "Installer\setup_x86.iss"

& "S:\Projects\Inno Setup 6\iscc.exe" "Installer\setup_x64.iss"
& "S:\Projects\Inno Setup 6\iscc.exe" "Installer\setup_x86.iss"

Write-Host "Signing Installers..."
& $signtool sign /f $pfx /p $pass /fd SHA256 /v ".\Installer\ResourceAlchemyHacker_Installer_x64_$AppVersion.exe"
& $signtool sign /f $pfx /p $pass /fd SHA256 /v ".\Installer\ResourceAlchemyHacker_Installer_x86_$AppVersion.exe"

Write-Host "Invoking Release Publisher..."
& .\publish_release.ps1 -AppVersion $appVersion
