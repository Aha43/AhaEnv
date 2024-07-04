
function ji-help {
    Write-Host
    Write-Host "Jira functions:"
    Write-Host "    ji-help:                        Show this help"
    Write-Host "    ji-inprogress:                  Show issues in progress assigned to you"
    Write-Host
}

function ji-inprogress {
    $email = git config user.email
    jira issues list -s"In Progress" -a"$email" 
}
