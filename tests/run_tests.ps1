$ErrorActionPreference = 'Stop'

# EliteSoftware Integration Test Suite for ResourceAlchemist
Write-Host "=========================================================="
Write-Host "   EliteSoftware ResourceAlchemist - Integration Tests    "
Write-Host "=========================================================="

try {
    # 1. Resolve current directory and CLI path
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) {
        $scriptDir = Get-Location
    }
    Set-Location $scriptDir
    Write-Host "[+] Running in test directory: $scriptDir"

    $cliPath = "C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\x64\Release\ResourceAlchemyHacker_CLI.exe"
    if (-not (Test-Path $cliPath)) {
        throw "ResourceAlchemist CLI executable not found at $cliPath. Did the build script run, or is the compiler on strike?"
    }
    Write-Host "[+] Found target CLI executable: $cliPath"

    # Ensure tests subdirectory exists (so tests\extracted_string.txt works when run from script root)
    if (-not (Test-Path "tests")) {
        New-Item -ItemType Directory -Path "tests" | Out-Null
    }

    # 2. Write dummy data files
    Write-Host "[+] Preparing test data files..."
    $originalData = "Hello, this is original data! Designed by EliteSoftware."
    $replacementData = "Hello, this is replacement data! Transferred successfully."
    $replacementData2 = "Hello, this is the second replacement data! Dynamic update verified."

    $originalData | Out-File -FilePath "original_data.txt" -Encoding ascii -NoNewline
    $replacementData | Out-File -FilePath "replacement_data.txt" -Encoding ascii -NoNewline
    $replacementData2 | Out-File -FilePath "replacement_data2.txt" -Encoding ascii -NoNewline

    # Copy files inside the "tests" folder to support relative path commands matching the user spec
    $originalData | Out-File -FilePath "tests\original_data.txt" -Encoding ascii -NoNewline
    $replacementData | Out-File -FilePath "tests\replacement_data.txt" -Encoding ascii -NoNewline
    $replacementData2 | Out-File -FilePath "tests\replacement_data2.txt" -Encoding ascii -NoNewline

    # 3. Create dummy C++ source file and resource file
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

    # 4. Locate Visual Studio Build Tools to compile target
    Write-Host "[+] Locating MSVC build tools environment..."
    $vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -property installationPath
    if (-not $vsPath) {
        throw "Visual Studio build tools not detected. vswhere.exe came back empty-handed. Are you running on a calculator?"
    }
    $vcvars = "$vsPath\VC\Auxiliary\Build\vcvarsall.bat"
    if (-not (Test-Path $vcvars)) {
        throw "Could not locate vcvarsall.bat at $vcvars. Compiler toolchain appears to be incomplete."
    }

    # Clean old artifacts
    Remove-Item "test_target.exe" -ErrorAction SilentlyContinue
    Remove-Item "test_target.res" -ErrorAction SilentlyContinue
    Remove-Item "test_target.obj" -ErrorAction SilentlyContinue

    Write-Host "[+] Compiling dummy target PE..."
    $compileCmd = @"
call "$vcvars" x64
rc.exe test_target.rc
cl.exe /EHsc /MD /O2 /Fe"test_target.exe" test_target.cpp test_target.res User32.lib
"@
    $compileCmd | Out-File -FilePath "compile.bat" -Encoding ascii
    cmd.exe /c compile.bat
    Remove-Item "compile.bat" -ErrorAction SilentlyContinue

    if (-not (Test-Path "test_target.exe")) {
        throw "Failed to compile test_target.exe. The compiler rejected our C++ code. Check the build outputs."
    }
    Write-Host "[+] Successfully compiled test_target.exe"

    # Get original hash for verification
    $originalHash = (Get-FileHash -Path "test_target.exe" -Algorithm SHA256).Hash
    Write-Host "[+] Original test_target.exe SHA-256: $originalHash"

    # 5. Run /list
    Write-Host "[+] Testing /list command..."
    $listOutput = & $cliPath /list "test_target.exe"
    $listExit = $LASTEXITCODE
    Write-Host "List Output: `n$listOutput"
    if ($listExit -ne 0) {
        throw "/list command failed with exit code $listExit. Our CLI has stage fright."
    }
    if ($listOutput -notmatch "MYTYPE" -or $listOutput -notmatch "101") {
        throw "Expected resource type 'MYTYPE' and ID '101' in /list output, but got: $listOutput"
    }

    # 6. Run /extract of original data
    Write-Host "[+] Testing /extract command for original resource..."
    Remove-Item "tests\extracted_string.txt" -ErrorAction SilentlyContinue
    
    & $cliPath /extract "test_target.exe" "MYTYPE" "101" "1033" "tests\extracted_string.txt"
    $extractExit = $LASTEXITCODE
    if ($extractExit -ne 0) {
        throw "/extract command failed with exit code $extractExit."
    }
    if (-not (Test-Path "tests\extracted_string.txt")) {
        throw "Extraction file tests\extracted_string.txt was not created."
    }

    $extractedContent = Get-Content -Raw -Path "tests\extracted_string.txt"
    Write-Host "Extracted Content: $extractedContent"
    if ($extractedContent -ne $originalData) {
        throw "Extracted data does not match original data! Expecting '$originalData', got '$extractedContent'."
    }
    Write-Host "[+] Assertion Passed: Extracted original data matches exactly."

    # 7. Run /replace with replacement_data.txt
    Write-Host "[+] Testing /replace command..."
    Remove-Item "test_target_1.bak" -ErrorAction SilentlyContinue

    & $cliPath /replace "test_target.exe" "MYTYPE" "101" "1033" "tests\replacement_data.txt"
    $replaceExit = $LASTEXITCODE
    if ($replaceExit -ne 0) {
        throw "/replace command failed with exit code $replaceExit."
    }

    # Verify backup file test_target_1.bak
    if (-not (Test-Path "test_target_1.bak")) {
        throw "Safety Backup check failed: test_target_1.bak was not created."
    }
    $bak1Hash = (Get-FileHash -Path "test_target_1.bak" -Algorithm SHA256).Hash
    Write-Host "[+] Backup file test_target_1.bak SHA-256: $bak1Hash"
    if ($bak1Hash -ne $originalHash) {
        throw "Safety integrity violation: test_target_1.bak is not identical to the original test_target.exe!"
    }
    Write-Host "[+] Assertion Passed: test_target_1.bak is identical to original."

    # 8. Verify resource is replaced
    Write-Host "[+] Verifying replaced resource content..."
    Remove-Item "tests\extracted_string.txt" -ErrorAction SilentlyContinue

    & $cliPath /extract "test_target.exe" "MYTYPE" "101" "1033" "tests\extracted_string.txt"
    $extractReplacedExit = $LASTEXITCODE
    if ($extractReplacedExit -ne 0) {
        throw "/extract of replaced resource failed with exit code $extractReplacedExit."
    }

    $replacedContent = Get-Content -Raw -Path "tests\extracted_string.txt"
    Write-Host "Extracted Replaced Content: $replacedContent"
    if ($replacedContent -ne $replacementData) {
        throw "Transplant failed: Resource content does not match replacement_data.txt!"
    }
    Write-Host "[+] Assertion Passed: Modified test_target.exe contains the replacement data."

    # 9. Run /replace again with another data file (replacement_data2.txt)
    Write-Host "[+] Testing second /replace to verify backup indexing and update..."
    $preSecondReplaceHash = (Get-FileHash -Path "test_target.exe" -Algorithm SHA256).Hash
    Remove-Item "test_target_2.bak" -ErrorAction SilentlyContinue

    & $cliPath /replace "test_target.exe" "MYTYPE" "101" "1033" "tests\replacement_data2.txt"
    $replace2Exit = $LASTEXITCODE
    if ($replace2Exit -ne 0) {
        throw "Second /replace command failed with exit code $replace2Exit."
    }

    # Verify test_target_2.bak is created
    if (-not (Test-Path "test_target_2.bak")) {
        throw "Backup check failed: test_target_2.bak was not created."
    }
    $bak2Hash = (Get-FileHash -Path "test_target_2.bak" -Algorithm SHA256).Hash
    Write-Host "[+] Backup file test_target_2.bak SHA-256: $bak2Hash"
    if ($bak2Hash -ne $preSecondReplaceHash) {
        throw "Safety integrity violation: test_target_2.bak is not identical to the file state before the second replacement!"
    }
    Write-Host "[+] Assertion Passed: test_target_2.bak is identical to the first replaced version."

    # Verify the final replaced content
    Remove-Item "tests\extracted_string.txt" -ErrorAction SilentlyContinue
    & $cliPath /extract "test_target.exe" "MYTYPE" "101" "1033" "tests\extracted_string.txt"
    $finalContent = Get-Content -Raw -Path "tests\extracted_string.txt"
    Write-Host "Final Extracted Content: $finalContent"
    if ($finalContent -ne $replacementData2) {
        throw "Second transplant failed: Resource content does not match replacement_data2.txt!"
    }
    Write-Host "[+] Assertion Passed: Modified test_target.exe contains the second replacement data."

    # Clean up compilation objects to keep the dir clean (optional, keeping the executables and bak files as requested)
    Remove-Item "test_target.obj" -ErrorAction SilentlyContinue
    Remove-Item "test_target.res" -ErrorAction SilentlyContinue

    Write-Host "=========================================================="
    Write-Host "       All Integration Tests Passed Successfully!         "
    Write-Host "=========================================================="
    exit 0
} catch {
    Write-Host "=========================================================="
    Write-Error "ERROR: $_"
    Write-Host "=========================================================="
    exit 1
}
