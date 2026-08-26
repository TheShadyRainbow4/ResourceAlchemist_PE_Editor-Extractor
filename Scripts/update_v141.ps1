$content = Get-Content -Path "generate_sln.ps1" -Raw
$content = $content -replace "<PlatformToolset>v143</PlatformToolset>", "<PlatformToolset>v141_xp</PlatformToolset>`n    <MinimumRequiredVersion>6.00</MinimumRequiredVersion>"
$content | Out-File -FilePath "generate_sln.ps1" -Encoding UTF8
