$commits = git log --reverse --format="%h|%s" 0977c1e..8c5ff91

$changelog = ""
$step = 1

foreach ($line in $commits) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line.Split('|')
    $hash = $parts[0]
    $msg = $parts[1]
    
    $changelog += "### Commit: $hash - $msg`r`n"
    
    $files = git diff-tree --no-commit-id --name-status -r $hash
    foreach ($f in $files) {
        if ([string]::IsNullOrWhiteSpace($f)) { continue }
        $fParts = $f -split '\s+', 2
        $status = $fParts[0]
        $file = $fParts[1]
        
        # Filter out intermediate files for brevity
        if ($file -match '\.(obj|iobj|ipdb|pdb|tlog|idb|ilk|res|lastbuildstate|recipe|log|FileListAbsolute.txt|exe|dll|zip|pdf|bak|bin|rtf|png|ico)$|/Release/|/x64/|\.vs/') { continue }
        
        $action = switch ($status) {
            'A' { 'Created file' }
            'M' { 'Edited file' }
            'D' { 'Deleted file' }
            default { 'Modified file' }
        }
        
        $changelog += "- **Step $($step):** ``$file`` | $action | Backported from git history.`r`n"
        $step++
    }
    $changelog += "`r`n"
}
Set-Content -Path "backport.md" -Value $changelog
