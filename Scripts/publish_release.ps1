param (
    [string]$AppVersion
)
$ErrorActionPreference = 'Stop'

Write-Host "Generating PDF Documentation..."
$mdFiles = Get-ChildItem -Filter "*.md" | Select-Object -ExpandProperty FullName
$mdContent = ""
foreach ($f in $mdFiles) {
    $mdContent += (Get-Content $f -Raw) + "

<hr>

"
}
$mdContent | Out-File temp_docs.md
$html = (ConvertFrom-Markdown -Path temp_docs.md).Html
$fullHtml = "<html><head><style>body{font-family:Segoe UI, sans-serif; margin: 2em; line-height: 1.6;} h1, h2, h3{color:#003366;} hr{margin-top:2em;margin-bottom:2em;}</style></head><body>$html</body></html>"
$fullHtml | Out-File temp_docs.html
& "C:\Program Files\supermium\chrome.exe" --headless --print-to-pdf="$PWD\ResourceAlchemyHacker_Documentation.pdf" "$PWD\temp_docs.html"
Start-Sleep -Seconds 3
Remove-Item temp_docs.md, temp_docs.html -ErrorAction SilentlyContinue

Write-Host "Packaging x64 ZIP..."
$x64Dir = "ResourceAlchemyHacker_x64"
New-Item -ItemType Directory -Force -Path $x64Dir
Copy-Item ".\x64\Release\ResourceAlchemyHacker_CLI.exe" -Destination $x64Dir
Copy-Item ".\x64\Release\ResourceAlchemyHacker_GUI.exe" -Destination $x64Dir
Copy-Item ".\x64\Release\ResourceAlchemyHacker_ShellExt.dll" -Destination $x64Dir
Copy-Item "ResourceAlchemyHacker_Documentation.pdf" -Destination $x64Dir
Copy-Item ".\Installer\ResourceAlchemyHacker_Installer_x64_$AppVersion.exe" -Destination $x64Dir
$x64Zip = "ResourceAlchemyHacker_x64.zip"
if (Test-Path $x64Zip) { Remove-Item $x64Zip }
Compress-Archive -Path "$x64Dir\*" -DestinationPath $x64Zip
Remove-Item -Recurse -Force $x64Dir

Write-Host "Packaging x86 ZIP..."
$x86Dir = "ResourceAlchemyHacker_x86"
New-Item -ItemType Directory -Force -Path $x86Dir
Copy-Item ".\Release\ResourceAlchemyHacker_CLI.exe" -Destination $x86Dir
Copy-Item ".\Release\ResourceAlchemyHacker_GUI.exe" -Destination $x86Dir
Copy-Item ".\Release\ResourceAlchemyHacker_ShellExt.dll" -Destination $x86Dir
Copy-Item "ResourceAlchemyHacker_Documentation.pdf" -Destination $x86Dir
Copy-Item ".\Installer\ResourceAlchemyHacker_Installer_x86_$AppVersion.exe" -Destination $x86Dir
$x86Zip = "ResourceAlchemyHacker_x86.zip"
if (Test-Path $x86Zip) { Remove-Item $x86Zip }
Compress-Archive -Path "$x86Dir\*" -DestinationPath $x86Zip
Remove-Item -Recurse -Force $x86Dir

Write-Host "Committing and Pushing to Git..."
git add .
git commit -m "Auto-build and release v$AppVersion"
git push -u origin master

Write-Host "Compiling Release Notes..."
$readmeTemplate = Get-Content "README.md" -Raw
$changelogBlock = ""
if (Test-Path "changelog.md") {
    $cl = Get-Content "changelog.md" -Raw
    if ($cl -match '(?s)(## v' + $AppVersion + '.*?)(?=## v|\z)') {
        $changelogBlock = $matches[1]
    }
}
$releaseNotes = $readmeTemplate + "`r`n`r`n## Changelog`r`n" + $changelogBlock
Set-Content "release_notes.md" -Value $releaseNotes

Write-Host "Creating GitHub Release..."
gh release create "v$AppVersion" "$x64Zip" "$x86Zip" ".\Installer\ResourceAlchemyHacker_Installer_x64_$AppVersion.exe" ".\Installer\ResourceAlchemyHacker_Installer_x86_$AppVersion.exe" --title "Resource Alchemy Hacker v$AppVersion" --notes-file "release_notes.md"
Remove-Item "release_notes.md" -Force -ErrorAction SilentlyContinue

Write-Host "Release publishing complete!"

