
# add the bin directory in user home to path
$env:Path += ";$env:USERPROFILE\bin"

Add-Type -AssemblyName System.Windows.Forms

function help {
    Write-Host 
    Write-Host "Utilities functions"
    Write-Host "  help: Display this help message"
    Write-Host "  hello: Display the welcome message"
    Write-Host "  week: Week of the year"
    Write-Host "  title: Set the title of the terminal"
    Write-Host "  genpwd: Generate a password"
    Write-Host "  quote: Display a random quote (if have quote file)"
    Write-Host "  psv: Display the PowerShell version"
    Write-Host
    Write-Host "Functions of use when developing this profile (run in dir with profile file)"
    Write-Host "  pub: Copy the profile to the current profile"
    Write-Host "  propath: Display the profile path"
    Write-Host "  propaths: Display the profile paths"
    Write-Host
    Write-Host "Directory and file functions:"
    Write-Host "  csln: Clean the dotnet solution"
    Write-Host "  mcd: Create a directory and change to it"
    Write-Host "  killdir: Remove a directory recursively using force"
    Write-Host "  dirastitle: Set the title of the terminal to the current directory"
    Write-Host "  go: Change to a directory and set the title of the terminal to the directory name"
    Write-Host "  dllfullname: Get the full name of a DLL file"
    Write-Host "  crf: Create a file if it does not exist"
    Write-Host "  c: Clear the terminal"
    Write-Host
    Write-Host "Git functions for every hour git work"
    Write-Host "  clonecd: Clone a git repository and change working directory to it"
    Write-Host "  a: 'git add .'"
    Write-Host "  s: 'git status'"
    Write-Host "  co: 'git commit -m args[0]' (if no message given message will be 'wip')"
    Write-Host "  p: 'git push'"
    Write-Host "  gurl: shows the git remote urls"
    Write-Host
    Write-Host "Prompt functions:"
    Write-Host "  short: Toggle if the prompt to display the current directory only or complete path"
    Write-Host "  bshort: Set the prompt to display the current branch name only"
    Write-Host "  blong: Set the prompt to display the full branch name"
    Write-Host "  time: Toggle if displaying the time in the prompt"
    Write-Host "  notime: Do not display the time in the prompt"
    Write-Host "  nobranch: Do not display the branch in the prompt"
    Write-Host "  branch: Display the branch in the prompt"
    Write-Host "  remote: Toggle if to indicate with * branch not remote (it is a bit slugish, default is on)"
    Write-Host "  naken: Only > prompt"
    Write-Host "  default: Set the prompt to display the time and branch"
    Write-Host
    Write-Host "Tips:"
    Write-Host "  The prompt can be customized using the prompt functions"
    Write-Host "  The ^ symbol (after branch name in the prompt) indicates that the branch is ahead of the remote branch"
    Write-Host "  explorer . : If on windows open the current directory in the file explorer"
    Write-Host 
}

#
# directory and file functions
#

function csln {
    if (-not (Test-Path "*.sln")) {
        Write-Host "No solution file found in the current directory."
        return
    }

    Get-ChildItem -Recurse -Filter "obj" | Remove-Item -Recurse -Force
    Get-ChildItem -Recurse -Filter "bin" | Remove-Item -Recurse -Force
}

function mcd {
    if ($args.Length -eq 0) {
        Write-Host "No arguments provided."
    } else {
        New-Item -ItemType Directory -Path $args[0] -Force
        Set-Location -Path $args[0]
    }
}

function killdir {
    if ($args.Length -eq 0) {
        Write-Host "No arguments provided."
    } else {
        Remove-Item -Path $args[0] -Recurse -Force
    } 
}

function go {
    if ($args.Length -eq 0) {
        Write-Host "No arguments provided."
    } else {
        Set-Location -Path $args[0]
        dtitle
    }
}

function dtitle {
    $dir = Get-Location
    $lastDir = $dir | Split-Path -Leaf
    $host.UI.RawUI.WindowTitle = $lastDir
}

function dllfullname {
    # open file dialog
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    # set the filter
    $openFileDialog.Filter = "DLL Files (*.dll)|*.dll"
    # show the dialog
    $openFileDialog.ShowDialog() | Out-Null
    $path = $openFileDialog.FileName
    ([system.reflection.assembly]::loadfile($path)).FullName
}

function crf([string]$filename) {
    if (-not (Test-Path $filename)) {
        New-Item -ItemType File -Path $filename -Force
    }
}

#
# git functions
#

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

function s {
    git status
}

function a {
    git add .
}

function co {
    $cm = "wip"
    if ($args.Length -eq 1) {
        $cm = $args[0]
    }
    
    git commit -m $cm
}

function p  {
    git push
}

function gurl {
    git remote -v
}

#
# functions of use when developing this profile
#

function pub {
    $SourcePath = Join-Path -Path "." -ChildPath "Microsoft.PowerShell_profile.ps1"
    if (-not (Test-Path $SourcePath)) {
        Write-Host "File not found: $SourcePath"
        return
    }
    Copy-Item -Path $SourcePath -Destination $PROFILE -Force
}

function propath  {
    $PROFILE
}

function propaths {
    $PROFILE | Get-Member -Type NoteProperty | Format-List
}

#
# utilities functions
#

function week {
    get-date -UFormat %V
}

function title {
    if ($args.Length -eq 0) {
        Write-Host "No arguments provided."
    } else {
        $host.UI.RawUI.WindowTitle = $args[0] 
    }
}

function genpwd {
    $length = 16
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    $password = -join ((0..$length) | ForEach-Object { $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)] })
    Write-Host $password
}

function psv {
    $PSVersionTable
}

function quote {
    $quotesFile = "$env:USERPROFILE\quotes.txt"
    if (Test-Path $quotesFile) {
        Write-Host
        $lines = @(Get-Content $quotesFile)
        $lines | Get-Random
        Write-Host
    }
}

#
# functions and code related to the prompt
#

function hello {
    Clear-Host
    quote
    _promptheader
}

function c {
    Clear-Host
    _promptheader
}

function _promptheader {
    $Date = Get-Date -Format "dd.MM.yy"
    $Week = week
    $Wday = (Get-Date).DayOfWeek
    $User = whoami
    Write-Host "[$Date][$Week][$Wday] ($User)" -ForegroundColor Cyan
}

$env:prompt_time = "true"
$env:prompt_branch = "true"
$env:prompt_wd = "true"
$env:short_prompt = "false"
$env:short_bprompt = "false"
$env:prompt_remote = "true"

function _dirforprompt {
    if ($env:short_prompt -eq "true") {
        $dir = Get-Location
        $lastDir = $dir | Split-Path -Leaf
        return $lastDir
    }
    else {
        return $PWD
    }
}

function short {
    if ($env:short_prompt -eq "false") {
        $env:short_prompt = "true"
        return
    }
    $env:short_prompt = "false"
}

function bshort {
    $env:short_bprompt = "true"
}

function blong {
    $env:short_bprompt = "false"
}

function time {
    if ($env:prompt_time -eq "false") {
        $env:prompt_time = "true"
        return
    }
    $env:prompt_time = "false"
}

function nobranch {
    $env:prompt_branch = "false"
}

function branch {
    $env:prompt_branch = "true"
}

function remote {
    if ($env:prompt_remote -eq "false") {
        $env:prompt_remote = "true"
        return
    }
    $env:prompt_remote = "false"
}

function default {
    $env:prompt_time = "true"
    $env:prompt_branch = "true"
    $env:prompt_wd = "true"
    $env:short_prompt = "false"
    $env:short_bprompt = "false"
    $env:prompt_remote = "true"
}

function naken {
    $env:prompt_time = "false"
    $env:prompt_branch = "false"
    $env:prompt_wd = "false"
}

function _remote {
    if ($env:prompt_remote -eq "false") {
        return ""
    }

    # Get the remote name
    $remote = git remote 2>&1

    # Check if the branch exists on the remote
    $remoteBranch = git ls-remote --heads $remote $args[0] 2>&1

    if ($remoteBranch) {
        return ""
    } else {
        return "*"
    }
}

function _ahead {
    $status = git status -b
    if ($status -match "ahead") {
        return "^"
    }
    return ""
}

function _branch {
    $branch = & git rev-parse --abbrev-ref HEAD 2> $null
    if ($branch) {
        $rem = ""
        $ahead = _ahead
        if (-not $ahead) {
            $rem = _remote $branch
        }
        if ($env:short_bprompt -eq "true") {
            if ($branch.Length -gt 10) {
                $shortBranch = $branch.Substring(0, 10)
                return ($shortBranch + "...") 
            }
        }
        
        return ($branch + $ahead + $rem)
    }
    return ""
}

function prompt {
    [bool]$dospace = $false

    if ($env:prompt_time -eq "true") {
        $Time = Get-Date -Format "HH:mm:ss"
        Write-Host "[$Time]" -NoNewline -ForegroundColor Cyan
        $dospace = $true
    }
    
    if ($env:prompt_branch -eq "true") {
        $dospace = $true
        $branch = _branch
        if ($branch) {
            $status = git status --porcelain 
            if ([string]::IsNullOrWhiteSpace($status)) {
                Write-Host "{$branch}" -NoNewline -ForegroundColor Green
            } else {
                Write-Host "{$branch}" -NoNewline -ForegroundColor Red
            } 
        }
    }

    if ($env:prompt_wd -eq "true") {
        $p = _dirforprompt
    }

    [string]$space = ""
    if ($dospace) {
        $space = " "
    }
    Write-Host $space -NoNewline
    Write-Host "$p>" -NoNewline
    
    return " "
}

hello # Display the welcome message on session start
