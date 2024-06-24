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
