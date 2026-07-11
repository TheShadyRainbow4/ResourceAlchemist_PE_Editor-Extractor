$mingwUrl = "https://github.com/niXman/mingw-builds-binaries/releases/download/13.2.0-rt_v11-rev1/x86_64-13.2.0-release-posix-seh-ucrt-rt_v11-rev1.7z"
$zDrive = "Z:\BuildTools"
if (-not (Test-Path $zDrive)) { New-Item -ItemType Directory -Path $zDrive | Out-Null }
$zipPath = "$zDrive\mingw.7z"

Write-Host "Downloading MinGW-w64..."
Invoke-WebRequest -Uri $mingwUrl -OutFile $zipPath

Write-Host "Extracting to $zDrive\MinGW..."
# We will use 7z if available, otherwise just warn
$7z = "C:\Program Files\7-Zip\7z.exe"
if (Test-Path $7z) {
    & $7z x $zipPath -o"$zDrive" -y | Out-Null
    
    $mingwPath = "$zDrive\mingw64\bin"
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $sysPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($userPath -notlike "*$mingwPath*") { [Environment]::SetEnvironmentVariable("Path", "$userPath;$mingwPath", "User") }
    if ($sysPath -notlike "*$mingwPath*") { [Environment]::SetEnvironmentVariable("Path", "$sysPath;$mingwPath", "Machine") }
    
    Write-Host "MinGW-w64 installed and added to PATH."
} else {
    Write-Warning "7-Zip not found. Please extract $zipPath manually."
}
