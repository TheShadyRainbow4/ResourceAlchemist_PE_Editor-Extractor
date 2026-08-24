$versionFile = "C:\Users\Administrator\Desktop\Resource_Alchemy_Hacker\ResourceAlchemyHacker\version.h"
$content = Get-Content $versionFile
$newContent = @()
$major = 1
$minor = 4
$patch = 0
$build = 0

foreach ($line in $content) {
    if ($line -match "^#define RAH_VERSION_MAJOR (\d+)") {
        $major = [int]$matches[1]
        $newContent += $line
    } elseif ($line -match "^#define RAH_VERSION_MINOR (\d+)") {
        $minor = [int]$matches[1]
        $newContent += $line
    } elseif ($line -match "^#define RAH_VERSION_PATCH (\d+)") {
        $patch = [int]$matches[1]
        $newContent += $line
    } elseif ($line -match "^#define RAH_VERSION_BUILD (\d+)") {
        $build = [int]$matches[1] + 1
        $newContent += "#define RAH_VERSION_BUILD $build"
    } elseif ($line -match "^#define RAH_VERSION L`".*`"") {
        $newContent += "#define RAH_VERSION L`"$major.$minor.$patch.$build`""
    } else {
        $newContent += $line
    }
}
Set-Content $versionFile $newContent
Write-Host "Bumped version to $major.$minor.$patch.$build"
