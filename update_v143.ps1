$content = Get-Content -Path "generate_sln.ps1" -Raw
$content = $content -replace "<PlatformToolset>v141_xp</PlatformToolset>", "<PlatformToolset>v143</PlatformToolset>"
if ($content -notmatch "<MinimumRequiredVersion>6.00</MinimumRequiredVersion>") {
    $content = $content -replace "<SubSystem>Console</SubSystem>", "<SubSystem>Console</SubSystem>`n      <MinimumRequiredVersion>6.00</MinimumRequiredVersion>"
    $content = $content -replace "<SubSystem>Windows</SubSystem>", "<SubSystem>Windows</SubSystem>`n      <MinimumRequiredVersion>6.00</MinimumRequiredVersion>"
}
$content | Out-File -FilePath "generate_sln.ps1" -Encoding UTF8
