
# add the bin directory in user home to path
$env:Path += ";$env:USERPROFILE\bin"

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
    Write-Host "  Test-CommandExists: Test if a command exists"
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
    Write-Host "  crf: Create a file if it does not exist"
    Write-Host "  c: Clear the terminal"
    Write-Host
    Write-Host "Git functions for every hour git work"
    Write-Host "  clonecd: Clone a git repository and change working directory to it"
    Write-Host "  a: 'git add .'"
    Write-Host "  s: 'git status'"
    Write-Host "  co: 'git commit -m args[0]' (if no message given message will be 'wip')"
    Write-Host "  p: 'git push'"
    Write-Host "  b: 'git branch'"
    Write-Host "  gurl: shows the git remote urls"
    Write-Host "  bname: Display the current branch"
    Write-Host
    Write-Host "Prompt functions:"
    Write-Host "  short: Toggle if the prompt to display the current directory only or complete path"
    Write-Host "  bshort: Set the prompt to display the current branch name truncated"
    Write-Host "  time: Toggle if displaying the time in the prompt"
    Write-Host "  btrunc: Truncate the branch name to the given length"
    Write-Host "  branch: Toggle displaying the branch in the prompt"
    Write-Host "  naken: Only > prompt"
    Write-Host "  default: Set the prompt to display the time and branch"
    Write-Host "  pc: Set the number of path components to display in the prompt when short_prompt is true"
    Write-Host "  bdots: Toggle if to display ... after the truncated branch name in the prompt when short_bprompt is true"
    Write-Host "  unix: Toggle if to use / as path separator in the prompt"
    Write-Host 
}

Function Test-CommandExists($command)
{
    $oldPreference = $ErrorActionPreference

    $ErrorActionPreference = 'stop'

    try {
        if (Get-Command $command) {
            return $true
        }
        return $false
    }

    Catch {
        return $false
    }

    Finally {
        $ErrorActionPreference=$oldPreference
    }
}

function _promptheader {
    $Date = Get-Date -Format "dd.MM.yy"
    $Week = week
    $Wday = (Get-Date).DayOfWeek
    $User = whoami
    $Os = os
    $BranchInfo = ""
    $ShellVersion = $PSVersionTable.PSVersion.ToString()
    $TheShell = "PowerShell"
    if ($TheBranch) {
        $BranchInfo = " {$TheBranch}"
    }
    Write-Host "[$Date][$Week][$Wday] ($User) <$Os> <$TheShell $ShellVersion>$BranchInfo" -ForegroundColor Cyan
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

#
# functions of use when developing this profile
#

function pub {
    $SourcePath = Join-Path -Path "." -ChildPath "Microsoft.PowerShell_profile.ps1"
    if (-not (Test-Path $SourcePath)) {
        Write-Host "File not found: $SourcePath"
        return
    }

    #read profile content into a variable
    $profileContent = Get-Content -Path $SourcePath

    #write the content to the current profile
    Set-Content -Path $PROFILE -Value $profileContent -Force

    $Branch = bname
    #append to the current profile a veriable having value of $Branch
    Add-Content -Path $PROFILE -Value "`$TheBranch = '$Branch'"
    Add-Content -Path $PROFILE -Value "hello"
}

function propath  { $PROFILE }
function propaths { $PROFILE | Get-Member -Type NoteProperty | Format-List }

#
# utilities functions
#

function week { get-date -UFormat %V }

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

function psv { $PSVersionTable }

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

$env:prompt_time = "true" # display the time
$env:prompt_branch = "true" # display the branch
$env:prompt_wd = "true" # display the current directory
$env:short_prompt = "true" # display the current directory only
$env:short_bprompt = "true" # truncate the branch name
$env:prompt_btruncate = 15 # truncate the branch name to this length
$env:prompt_bdots = "true" # display ... after the truncated branch name in the prompt when short_bprompt is true
$env:prompt_path_component_count = 2 # number of path components to display in the prompt when short_prompt is true
$env:unix_path_separator = "true" # use / as path separator in the prompt (if on windows)

function IsThisWindows {
    $os = os
    if ($os -ne "Windows") {
        return $false
    }
    return $true
}

function unix {
    $OnWindows = IsThisWindows
    if ($OnWindows -eq $false) {
        Write-Host "You don't need this since you must be on a Unix type system."
        return
    }

    if ($env:unix_path_separator -eq "false") {
        $env:unix_path_separator = "true"
        return
    }
    $env:unix_path_separator = "false"
}

function pc([int]$count) {
    if ($count -lt 1) {
        Write-Host "Count must be greater than 0."
        return
    } 

    $env:prompt_path_component_count = $count
    $env:short_prompt = "true"
}

function short {
    if ($env:short_prompt -eq "false") {
        $env:short_prompt = "true"
        return
    }
    $env:short_prompt = "false"
}

function bshort {
    if ($env:short_bprompt -eq "false") {
        $env:short_bprompt = "true"
        return
    }
    $env:short_bprompt = "false"
}

function btrunc([int]$length) {
    if ($length -lt 1) {
        Write-Host "Length must be greater than 0."
        return
    }
    $env:prompt_btruncate = $length
    $env:prompt_branch = "true"
    $env:short_bprompt = "true"
}

function time {
    if ($env:prompt_time -eq "false") {
        $env:prompt_time = "true"
        return
    }
    $env:prompt_time = "false"
}

function branch {
    if ($env:prompt_branch -eq "false") {
        $env:prompt_branch = "true"
        return
    }
    $env:prompt_branch = "false"
}

function bdots {
    if ($env:prompt_bdots -eq "false") {
        $env:prompt_bdots = "true"
        return
    }
    $env:prompt_bdots = "false"
}

function default {
    $env:prompt_time = "true"
    $env:prompt_branch = "true"
    $env:prompt_wd = "true"
    $env:short_prompt = "false"
    $env:short_bprompt = "false"
}

function naken {
    $env:prompt_time = "false"
    $env:prompt_branch = "false"
    $env:prompt_wd = "false"
}

function _ahead {
    $status = git status -b
    if ($status -match "ahead") {
        return "^"
    }
    return ""
}

#function to get the current branch
function bname {
    $branch = & git rev-parse --abbrev-ref HEAD 2> $null
    if ($branch) {
        return $branch
    }
    return ""
}

function _branch {
    $branch = bname
    if ($branch) {
        $ahead = _ahead
        if ($env:short_bprompt -eq "true") {
            if ($branch.Length -gt $env:prompt_btruncate) {
                $shortBranch = $branch.Substring(0, $env:prompt_btruncate)
                if ($env:prompt_bdots -eq "true") {
                    return ($shortBranch + " ..." + $ahead) 
                }
                return ($shortBranch + $ahead) 
            }
        }
        
        return ($branch + $ahead)
    }
    return ""
}

function os {
    if ($IsLinux) {
        return "Linux"
    }
    if ($IsMacOS) {
        return "macOS"
    }
    return "Windows"
}

function _path_dir_separator_char {
    if ($IsLinux -or $IsMacOS) {
        return '/'
    }
    return '\\'
}

function _path_dir_separator_str {
    if ($IsLinux -or $IsMacOS) {
        return "/"
    }
    return "\"
}

function _prompt_path {
    $sep_char = _path_dir_separator_char
    $sep_str = _path_dir_separator_str

    if ($env:short_prompt -eq "false") {       
        return $PWD
    }

    $dir = Get-Location
    $path = $dir -split $sep_char
    $count = $path.Length
    if ($count -le $env:prompt_path_component_count) {
        return $dir
    }

    $start = $count - $env:prompt_path_component_count
    $path = $path[$start..($count - 1)] -join $sep_str

    return $path
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
        $p = _prompt_path
        
        $os = os
        if ($os -eq "Windows") {
            if ($env:unix_path_separator -eq "true") {
                $p = $p -replace '\\', '/'
            }
        }
    }

    [string]$space = ""
    if ($dospace) {
        $space = " "
    }
    Write-Host $space -NoNewline
    Write-Host "$p>" -NoNewline
    
    return " "
}
