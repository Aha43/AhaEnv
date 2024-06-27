function clonecd {
    if ($args.Length -eq 0) {
        Write-Host "No arguments provided."
    } else {
        git clone $args[0]
        $dir = $args[0].Split("/")[-1].Split(".")[0]
        Set-Location -Path $dir
        dtitle
    }
}

function s { git status }
function a { git add . }
function p  { git push }
function b { git branch }
    
function gurl { git remote -v }

function co {
    $cm = "wip"
    if ($args.Length -eq 1) {
        $cm = $args[0]
    }
    
    git commit -m $cm
}

function bname {
    $branch = & git rev-parse --abbrev-ref HEAD 2> $null
    if ($branch) {
        return $branch
    }
    return ""
}

function help-git {
    Write-Host
    Write-Host "clonecd <url> - clone a git repo and cd into it"
    Write-Host "s - git status"
    Write-Host "a - git add ."
    Write-Host "p - git push"
    Write-Host "b - git branch"
    Write-Host "gurl - git remote -v"
    Write-Host "co <message> - git commit -m <message>"
    Write-Host "bname - get the current branch name"
    Write-Host "help-git - show this help"
    Write-Host
}
