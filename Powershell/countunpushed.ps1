function UnpushedCount() {
    # get the current git branch name
    $branchName = git rev-parse --abbrev-ref HEAD
    # get git log for the current branch and count the number of commits
    $commitCount = git log --oneline -- $branchName | Measure-Object | Select-Object -ExpandProperty Count
    Write-Host "Unpushed commits: $commitCount"
    
}