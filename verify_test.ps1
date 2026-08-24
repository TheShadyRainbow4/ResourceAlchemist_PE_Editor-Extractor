$ErrorActionPreference = 'Stop'

Write-Host "=========================================================="
Write-Host " EliteSoftware ResourceAlchemist - Automated Test & Verify"
Write-Host "=========================================================="

$cli = ".\x64\Release\ResourceAlchemyHacker_CLI.exe"
$target = "TEST_imageres_mun.dll"
$sandbox = "TEST_sandbox.dll"
$final = "TEST_final.dll"

Write-Host "[+] Creating sandbox copy (simulating GUI in-memory edits)..."
Copy-Item -Path $target -Destination $sandbox -Force

# Create dummy replacement data
$dummyData1 = "EliteSoftware Dummy Data 1: Version Info Override!"
$dummyData1 | Out-File -FilePath "dummy1.bin" -Encoding ascii -NoNewline

Write-Host "[+] Extracting a valid PNG to use as dummy replacement (PNG 5021)..."
& $cli /extract $target PNG 5021 1033 "dummy_png.png"

Write-Host "[+] Replacing Resource 1 (TYPE:16, RES:1, LANG:1033) with dummy text..."
& $cli /replace $sandbox 16 1 1033 "dummy1.bin"

Write-Host "[+] Replacing Resource 2 (TYPE:PNG, RES:5024, LANG:1033) with dummy_png.png..."
& $cli /replace $sandbox PNG 5024 1033 "dummy_png.png"

Write-Host "[+] Simulating GUI Save Action..."
Copy-Item -Path $sandbox -Destination $final -Force

Write-Host "[+] Validating outputs from saved file..."
& $cli /extract $final 16 1 1033 "extracted_dummy1.bin"
& $cli /extract $final PNG 5024 1033 "extracted_png.png"

$out1 = Get-Content "extracted_dummy1.bin" -Raw
$pngSize = (Get-Item "extracted_png.png").Length
$dummyPngSize = (Get-Item "dummy_png.png").Length

if ($out1 -eq $dummyData1 -and $pngSize -eq $dummyPngSize) {
    Write-Host "[+] SUCCESS: Both resources were successfully kept in memory and saved to disk correctly!"
    Write-Host "    -> TYPE:16 correctly verified against expected text."
    Write-Host "    -> TYPE:PNG correctly verified against expected image size ($pngSize bytes)."
} else {
    Write-Host "[-] FAILED: Extracted data does not match the replacements."
    exit 1
}

Write-Host "[+] Cleaning up..."
Remove-Item "dummy1.bin", "dummy_png.png", "extracted_dummy1.bin", "extracted_png.png", $sandbox, $final -Force
Write-Host "[+] All tests passed!"
