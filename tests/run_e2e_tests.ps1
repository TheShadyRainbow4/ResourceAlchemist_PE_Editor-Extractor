$ErrorActionPreference = 'Stop'

# EliteSoftware End-to-End Test Suite for ResourceAlchemist
Write-Host "=========================================================="
Write-Host "     EliteSoftware ResourceAlchemist - E2E Tests          "
Write-Host "=========================================================="

try {
    # 1. Resolve current directory
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) {
        $scriptDir = Get-Location
    }
    Set-Location $scriptDir
    Write-Host "[+] Running in E2E test directory: $scriptDir"

    # Verify log path
    $logPath = "$env:SystemDrive\EliteSoftware\Logs\ResourceAlchemist.log"
    if (-not (Test-Path -LiteralPath $logPath)) {
        throw "Log file was not found at $logPath! Did the system even attempt to log, or is it trying to keep secrets?"
    }
    $initialLineCount = (Get-Content -Path $logPath).Count
    Write-Host "[+] Initial log line count: $initialLineCount"

    # 2. Verify registry values for CLSID
    Write-Host "[+] Validating shell extension CLSID registration..."
    $clsidPath = "Registry::HKEY_CLASSES_ROOT\CLSID\{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}\InprocServer32"
    if (-not (Test-Path -LiteralPath $clsidPath)) {
        throw "Error E001: Shell extension CLSID registry key does not exist! It seems the installer forgot its main purpose."
    }
    
    $dllPath = Get-ItemPropertyValue -LiteralPath $clsidPath -Name "(default)" -ErrorAction SilentlyContinue
    $expectedDll = "C:\Program Files\EliteSoftware\Resource Alchemy Hacker\ResourceAlchemyHacker_ShellExt.dll"
    if ($dllPath -ne $expectedDll) {
        throw "Error E002: CLSID registry points to '$dllPath' instead of the installed DLL path '$expectedDll'!"
    }
    
    $threadingModel = Get-ItemPropertyValue -LiteralPath $clsidPath -Name "ThreadingModel" -ErrorAction SilentlyContinue
    if ($threadingModel -ne "Apartment") {
        throw "Error E003: ThreadingModel in registry is '$threadingModel', expected 'Apartment' for GUI safety."
    }
    Write-Host "[+] CLSID Registry validation passed successfully!"

    # 3. Verify Context Menu and Property Sheet registrations
    Write-Host "[+] Validating context menu and property sheet handlers..."
    $handlers = @(
        "Registry::HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ResourceAlchemyHacker",
        "Registry::HKEY_CLASSES_ROOT\exefile\shellex\ContextMenuHandlers\ResourceAlchemyHacker",
        "Registry::HKEY_CLASSES_ROOT\*\shellex\PropertySheetHandlers\ResourceAlchemyHacker",
        "Registry::HKEY_CLASSES_ROOT\exefile\shellex\PropertySheetHandlers\ResourceAlchemyHacker"
    )

    foreach ($handler in $handlers) {
        if (-not (Test-Path -LiteralPath $handler)) {
            throw "Error E004: Expected registry key '$handler' was not found! The shell lacks context."
        }
        $val = Get-ItemPropertyValue -LiteralPath $handler -Name "(default)" -ErrorAction SilentlyContinue
        if ($val -ne "{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}") {
            throw "Error E005: Expected default value for '$handler' to be '{A1B2C3D4-E5F6-7890-1234-567890ABCDEF}', but got: '$val'"
        }
    }
    Write-Host "[+] Context menu and property sheet handlers validation passed!"

    # 4. Locate installed CLI executable
    $cliPath = "C:\Program Files\EliteSoftware\Resource Alchemy Hacker\ResourceAlchemyHacker_CLI.exe"
    if (-not (Test-Path -LiteralPath $cliPath)) {
        throw "Error E006: Installed ResourceAlchemist CLI executable not found at $cliPath!"
    }
    Write-Host "[+] Found installed target CLI executable: $cliPath"

    # Ensure tests subdirectory exists
    if (-not (Test-Path -LiteralPath "tests")) {
        New-Item -ItemType Directory -Path "tests" | Out-Null
    }

    # 5. Write dummy data files
    Write-Host "[+] Preparing E2E test data files..."
    $originalData = "Hello, this is original data! Designed by EliteSoftware."
    $replacementData = "Hello, this is replacement data! Transferred successfully."
    $replacementData2 = "Hello, this is the second replacement data! Dynamic update verified."

    $originalData | Out-File -FilePath "original_data.txt" -Encoding ascii -NoNewline
    $replacementData | Out-File -FilePath "replacement_data.txt" -Encoding ascii -NoNewline
    $replacementData2 | Out-File -FilePath "replacement_data2.txt" -Encoding ascii -NoNewline

    $originalData | Out-File -FilePath "tests\original_data.txt" -Encoding ascii -NoNewline
    $replacementData | Out-File -FilePath "tests\replacement_data.txt" -Encoding ascii -NoNewline
    $replacementData2 | Out-File -FilePath "tests\replacement_data2.txt" -Encoding ascii -NoNewline

    # 6. Create dummy C++ source file and resource file
    Write-Host "[+] Generating dummy target source and resource files..."
    @"
#include <windows.h>
#include <iostream>

int main() {
    std::cout << "EliteSoftware Dummy Test Target PE" << std::endl;
    return 0;
}
"@ | Out-File -FilePath "test_target.cpp" -Encoding ascii

    "101 MYTYPE `"original_data.txt`"" | Out-File -FilePath "test_target.rc" -Encoding ascii

    # 7. Locate Visual Studio Build Tools to compile target
    Write-Host "[+] Locating MSVC build tools environment..."
    $vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -property installationPath
    if (-not $vsPath) {
        throw "Error E007: Visual Studio build tools not detected. compiler environment is missing."
    }
    $vcvars = "$vsPath\VC\Auxiliary\Build\vcvarsall.bat"
    if (-not (Test-Path -LiteralPath $vcvars)) {
        throw "Error E008: Could not locate vcvarsall.bat at $vcvars."
    }

    # Clean old artifacts
    Remove-Item "test_target.exe" -ErrorAction SilentlyContinue
    Remove-Item "test_target.res" -ErrorAction SilentlyContinue
    Remove-Item "test_target.obj" -ErrorAction SilentlyContinue
    Remove-Item "test_target_1.bak" -ErrorAction SilentlyContinue
    Remove-Item "test_target_2.bak" -ErrorAction SilentlyContinue
    Remove-Item "tests\extracted_string.txt" -ErrorAction SilentlyContinue

    Write-Host "[+] Compiling dummy target PE..."
    $compileCmd = @"
call "$vcvars" x64
rc.exe test_target.rc
cl.exe /EHsc /MD /O2 /Fe"test_target.exe" test_target.cpp test_target.res User32.lib
"@
    $compileCmd | Out-File -FilePath "compile.bat" -Encoding ascii
    cmd.exe /c compile.bat
    Remove-Item "compile.bat" -ErrorAction SilentlyContinue

    if (-not (Test-Path -LiteralPath "test_target.exe")) {
        throw "Error E009: Failed to compile test_target.exe."
    }
    Write-Host "[+] Successfully compiled test_target.exe"

    # Get original hash for verification
    $originalHash = (Get-FileHash -Path "test_target.exe" -Algorithm SHA256).Hash
    Write-Host "[+] Original test_target.exe SHA-256: $originalHash"

    # 8. Run /list
    Write-Host "[+] Testing /list command..."
    $listOutput = & $cliPath /list "test_target.exe"
    $listExit = $LASTEXITCODE
    Write-Host "List Output: `n$listOutput"
    if ($listExit -ne 0) {
        throw "Error E010: /list command failed with exit code $listExit."
    }
    if ($listOutput -notmatch "MYTYPE" -or $listOutput -notmatch "101") {
        throw "Error E011: Expected resource type 'MYTYPE' and ID '101' in /list output, but got: $listOutput"
    }

    # 9. Run /extract of original data
    Write-Host "[+] Testing /extract command for original resource..."
    & $cliPath /extract "test_target.exe" "MYTYPE" "101" "1033" "tests\extracted_string.txt"
    $extractExit = $LASTEXITCODE
    if ($extractExit -ne 0) {
        throw "Error E012: /extract command failed with exit code $extractExit."
    }
    if (-not (Test-Path -LiteralPath "tests\extracted_string.txt")) {
        throw "Error E013: Extraction file tests\extracted_string.txt was not created."
    }

    $extractedContent = Get-Content -Raw -Path "tests\extracted_string.txt"
    Write-Host "Extracted Content: $extractedContent"
    if ($extractedContent -ne $originalData) {
        throw "Error E014: Extracted data does not match original data! Expecting '$originalData', got '$extractedContent'."
    }
    Write-Host "[+] Assertion Passed: Extracted original data matches exactly."

    # 10. Run /replace with replacement_data.txt
    Write-Host "[+] Testing /replace command..."
    & $cliPath /replace "test_target.exe" "MYTYPE" "101" "1033" "tests\replacement_data.txt"
    $replaceExit = $LASTEXITCODE
    if ($replaceExit -ne 0) {
        throw "Error E015: /replace command failed with exit code $replaceExit."
    }

    # Verify backup file test_target_1.bak
    if (-not (Test-Path -LiteralPath "test_target_1.bak")) {
        throw "Error E016: Safety Backup check failed: test_target_1.bak was not created."
    }
    $bak1Hash = (Get-FileHash -Path "test_target_1.bak" -Algorithm SHA256).Hash
    Write-Host "[+] Backup file test_target_1.bak SHA-256: $bak1Hash"
    if ($bak1Hash -ne $originalHash) {
        throw "Error E017: Safety integrity violation: test_target_1.bak is not identical to the original test_target.exe!"
    }
    Write-Host "[+] Assertion Passed: test_target_1.bak is identical to original."

    # 11. Verify resource is replaced
    Write-Host "[+] Verifying replaced resource content..."
    Remove-Item "tests\extracted_string.txt" -ErrorAction SilentlyContinue

    & $cliPath /extract "test_target.exe" "MYTYPE" "101" "1033" "tests\extracted_string.txt"
    $extractReplacedExit = $LASTEXITCODE
    if ($extractReplacedExit -ne 0) {
        throw "Error E018: /extract of replaced resource failed with exit code $extractReplacedExit."
    }

    $replacedContent = Get-Content -Raw -Path "tests\extracted_string.txt"
    Write-Host "Extracted Replaced Content: $replacedContent"
    if ($replacedContent -ne $replacementData) {
        throw "Error E019: Transplant failed: Resource content does not match replacement_data.txt!"
    }
    Write-Host "[+] Assertion Passed: Modified test_target.exe contains the replacement data."

    # 12. Run /replace again with another data file (replacement_data2.txt)
    Write-Host "[+] Testing second /replace to verify backup indexing and update..."
    $preSecondReplaceHash = (Get-FileHash -Path "test_target.exe" -Algorithm SHA256).Hash

    & $cliPath /replace "test_target.exe" "MYTYPE" "101" "1033" "tests\replacement_data2.txt"
    $replace2Exit = $LASTEXITCODE
    if ($replace2Exit -ne 0) {
        throw "Error E020: Second /replace command failed with exit code $replace2Exit."
    }

    # Verify test_target_2.bak is created
    if (-not (Test-Path -LiteralPath "test_target_2.bak")) {
        throw "Error E021: Backup check failed: test_target_2.bak was not created."
    }
    $bak2Hash = (Get-FileHash -Path "test_target_2.bak" -Algorithm SHA256).Hash
    Write-Host "[+] Backup file test_target_2.bak SHA-256: $bak2Hash"
    if ($bak2Hash -ne $preSecondReplaceHash) {
        throw "Error E022: Safety integrity violation: test_target_2.bak is not identical to the file state before the second replacement!"
    }
    Write-Host "[+] Assertion Passed: test_target_2.bak is identical to the first replaced version."

    # Verify the final replaced content
    Remove-Item "tests\extracted_string.txt" -ErrorAction SilentlyContinue
    & $cliPath /extract "test_target.exe" "MYTYPE" "101" "1033" "tests\extracted_string.txt"
    $finalContent = Get-Content -Raw -Path "tests\extracted_string.txt"
    Write-Host "Final Extracted Content: $finalContent"
    if ($finalContent -ne $replacementData2) {
        throw "Error E023: Second transplant failed: Resource content does not match replacement_data2.txt!"
    }
    Write-Host "[+] Assertion Passed: Modified test_target.exe contains the second replacement data."

    # Clean up compilation objects to keep the dir clean
    Remove-Item "test_target.obj" -ErrorAction SilentlyContinue
    Remove-Item "test_target.res" -ErrorAction SilentlyContinue

    # 13. Test GUI executable
    Write-Host "[+] Testing GUI executable..."
    $guiPath = "C:\Program Files\EliteSoftware\Resource Alchemy Hacker\ResourceAlchemyHacker_GUI.exe"
    if (-not (Test-Path -LiteralPath $guiPath)) {
        throw "Error E024: Installed ResourceAlchemist GUI executable not found at $guiPath!"
    }
    $guiProcess = Start-Process -FilePath $guiPath -PassThru
    Write-Host "[+] GUI process started with PID: $($guiProcess.Id). Sleeping 2 seconds..."
    Start-Sleep -Seconds 2
    if ($guiProcess.HasExited) {
        throw "Error E025: GUI process exited prematurely with exit code: $($guiProcess.ExitCode)!"
    }
    Write-Host "[+] Stopping GUI process..."
    Stop-Process -Id $guiProcess.Id -Force
    Start-Sleep -Seconds 1
    if (-not $guiProcess.HasExited) {
        throw "Error E026: GUI process failed to stop when requested."
    }
    Write-Host "[+] GUI validation passed cleanly."

    # 14. Verify log file updates
    Write-Host "[+] Verifying log file updates..."
    $finalLineCount = (Get-Content -Path $logPath).Count
    Write-Host "[+] Final log line count: $finalLineCount"
    if ($finalLineCount -le $initialLineCount) {
        throw "Error E027: Log integrity check failed. No new log entries were written to $logPath during CLI execution!"
    }
    Write-Host "[+] Log validation passed! Found $($finalLineCount - $initialLineCount) new entries."

    Write-Host "=========================================================="
    Write-Host "       All E2E Tests Passed Successfully!                 "
    Write-Host "=========================================================="
    exit 0
} catch {
    Write-Host "=========================================================="
    Write-Error "E2E TEST FAILURE: $_"
    Write-Host "=========================================================="
    exit 1
}
