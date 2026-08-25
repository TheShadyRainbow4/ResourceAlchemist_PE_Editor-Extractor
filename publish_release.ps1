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
$x64Zip = "ResourceAlchemyHacker_x64.zip"
Remove-Item $x64Zip -ErrorAction SilentlyContinue
Compress-Archive -Path ".\x64\Release\*", "ResourceAlchemyHacker_Documentation.pdf" -DestinationPath $x64Zip -CompressionLevel Optimal -Force

Write-Host "Packaging x86 ZIP..."
$x86Zip = "ResourceAlchemyHacker_x86.zip"
Remove-Item $x86Zip -ErrorAction SilentlyContinue
Compress-Archive -Path ".\Release\*", "ResourceAlchemyHacker_Documentation.pdf" -DestinationPath $x86Zip -CompressionLevel Optimal -Force

Write-Host "Committing and Pushing to Git..."
git add .
git commit -m "Auto-build and release v$AppVersion"
git push -u origin master

Write-Host "Creating GitHub Release..."
gh release create "v$AppVersion" "$x64Zip" "$x86Zip" "Installer\ResourceAlchemyHacker_Installer_$($AppVersion).exe" "ResourceAlchemyHacker_Documentation.pdf" --title "Resource Alchemy Hacker v$AppVersion" --notes "Automated Build and Release v$AppVersion"

Write-Host "Release publishing complete!"
