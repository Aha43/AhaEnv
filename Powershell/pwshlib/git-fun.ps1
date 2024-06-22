# function that list only git local and branches
function lb {
    $branches = git branch --format='%(refname:short)' --sort=-committerdate
    $localBranches = $branches | Where-Object { $_ -notlike 'origin/*' }
    return $localBranches
}




