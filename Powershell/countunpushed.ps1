function UnpushedCount() {
    # get the current git branch name
    $branchName = git rev-parse --abbrev-ref HEAD
    Write-Host $branchName
    $branchName = "origin/$branchName"
    $tofrom = "$branchName..HEAD"
    $log = git log $tofrom --oneline

    Write-Host $tofrom
    Write-Host "LOG"
    Write-Host $log
    # get git log for the current branch and count the number of commits
    $commitCount = git log $tofrom --oneline | Measure-Object | Select-Object -ExpandProperty Count
    Write-Host "Unpushed commits: $commitCount"
    
}