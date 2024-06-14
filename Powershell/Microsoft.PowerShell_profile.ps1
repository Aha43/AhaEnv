
# add the bin directory in user home to path
$env:Path += ";$env:USERPROFILE\bin"

Add-Type -AssemblyName System.Windows.Forms

# Dir functions

function cleanso() {
    if (-not (Test-Path "*.sln")) {
        Write-Host "No solution file found in the current directory."
        return
    }

    Get-ChildItem -Recurse -Filter "obj" | Remove-Item -Recurse -Force
    Get-ChildItem -Recurse -Filter "bin" | Remove-Item -Recurse -Force
}

function mkdircd() {
    if ($args.Length -eq 0) {
        Write-Host "No arguments provided."
    } else {
        New-Item -ItemType Directory -Path $args[0] -Force
        Set-Location -Path $args[0]
    }
}

function killdir() {
    if ($args.Length -eq 0) {
        Write-Host "No arguments provided."
    } else {
        Remove-Item -Path $args[0] -Recurse -Force
    } 
}

function goto() {
    if ($args.Length -eq 0) {
        Write-Host "No arguments provided."
    } else {
        Set-Location -Path $args[0]
        dirastitle
    }
}

function dirastitle() {
    $dir = Get-Location
    $lastDir = $dir | Split-Path -Leaf
    $host.UI.RawUI.WindowTitle = $lastDir
}

function gitclonecd() {
    if ($args.Length -eq 0) {
        Write-Host "No arguments provided."
    } else {
        git clone $args[0]
        $dir = $args[0].Split("/")[-1].Split(".")[0]
        Set-Location -Path $dir
        dirastitle
    }
}

function dllfullname() {
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

# Aha functions

function aha-help() {
    Write-Host 
    Write-Host "Aha prefix functions:"
    Write-Host "  aha-help: Display this help message"
    Write-Host "  aha-profilepath: Display the profile path"
    Write-Host "  aha-profilepaths: Display the profile paths"
    Write-Host "  aha-title: Set the title of the terminal"
    Write-Host "  aha-publishprofile: Copy the profile to the current profile"
    Write-Host "  aha-gennewpwd: Generate a new password"
    Write-Host "  aha-quotes: Display a random quote"
    Write-Host "  aha-v: Display the PowerShell version"
    Write-Host "  aha-hello: Display the welcome message"
    Write-Host "  aha-prompt: Toggle options for the prompt"
    Write-Host
    Write-Host "Directory and file functions:"
    Write-Host "  cleanso: Clean the dotnet solution"
    Write-Host "  mkdircd: Create a directory and change to it"
    Write-Host "  killdir: Remove a directory recursively using force"
    Write-Host "  dirastitle: Set the title of the terminal to the current directory"
    Write-Host "  gitclonecd: Clone a git repository and change to it"
    Write-Host "  goto: Change to a directory and set the title of the terminal to the directory name"
    Write-Host "  dllfullname: Get the full name of a DLL file"
    Write-Host "  crf: Create a file if it does not exist"
    Write-Host "  c: Clear the terminal"
    Write-Host
    Write-Host "Prompt functions:"
    Write-Host "  short: Set the prompt to display the current directory only"
    Write-Host "  long: Set the prompt to display the full path of the current directory"
    Write-Host "  bshort: Set the prompt to display the current branch name only"
    Write-Host "  blong: Set the prompt to display the full branch name"
    Write-Host "  time: Display the time in the prompt"
    Write-Host "  notime: Do not display the time in the prompt"
    Write-Host "  nobranch: Do not display the branch in the prompt"
    Write-Host "  branch: Display the branch in the prompt"
    Write-Host "  default: Set the prompt to display the time and branch"
    Write-Host
    Write-Host "Tips:"
    Write-Host "  The prompt can be customized using the prompt functions"
    Write-Host "  The ^ symbol (after branch name in the prompt) indicates that the branch is ahead of the remote branch"
    Write-Host "  explorer . : If on windows open the current directory in the file explorer"
    Write-Host 
}

function aha-publishprofile() {
    $SourcePath = Join-Path -Path "." -ChildPath "Microsoft.PowerShell_profile.ps1"
    if (-not (Test-Path $SourcePath)) {
        Write-Host "File not found: $SourcePath"
        return
    }
    Copy-Item -Path $SourcePath -Destination $PROFILE -Force
    
}

function aha-profilepath()  {
    $PROFILE
}

function aha-profilepaths() {
    $PROFILE | Get-Member -Type NoteProperty | Format-List
}

function aha-title() {
    if ($args.Length -eq 0) {
        Write-Host "No arguments provided."
    } else {
        $host.UI.RawUI.WindowTitle = $args[0] 
    }
}

function aha-gennewpwd() {
    $length = 16
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    $password = -join ((0..$length) | ForEach-Object { $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)] })
    Write-Host $password
}

function aha-quotes() {
    $quotesFile = "$env:USERPROFILE\quotes.txt"
    if (Test-Path $quotesFile) {
        Write-Host
        $lines = @(Get-Content $quotesFile)
        $lines | Get-Random
        Write-Host
    }
}

function aha-v {
    # Display the PowerShell version
    $PSVersionTable
}

#
# Code related to the prompt
#

# Write something upon terminal session start
function aha-hello {
    Clear-Host
    aha-quotes
    _promptheader
}

function _promptheader() {
    $Date = Get-Date -Format "dd.MM.yy"
    $Wday = (Get-Date).DayOfWeek
    $User = whoami
    Write-Host "[$Date][$Wday] ($User)" -ForegroundColor Cyan
}

function c {
    Clear-Host
    _promptheader
}

$env:prompt_time = "true"
$env:prompt_branch = "true"
$env:short_prompt = "false"
$env:short_bprompt = "false"

function dirforprompt() {
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
    $env:short_prompt = "true"
}

function long {
    $env:short_prompt = "false"
}

function bshort {
    $env:short_bprompt = "true"
}

function blong {
    $env:short_bprompt = "false"
}

function time {
    $env:prompt_time = "true"
}

function notime {
    $env:prompt_time = "false"
}

function nobranch {
    $env:prompt_branch = "false"
}

function branch {
    $env:prompt_branch = "true"
}

function default {
    $env:prompt_time = "true"
    $env:prompt_branch = "true"
    $env:short_prompt = "false"
    $env:short_bprompt = "false"
}

function get-ahead {
    $status = git status -b
    if ($status -match "ahead") {
        return "^"
    }
    return ""
}

function _get-branch-name {
    $branch = & git rev-parse --abbrev-ref HEAD 2> $null
    if ($branch) {
        if ($env:short_bprompt -eq "true") {
            if ($branch.Length -gt 10) {
                $shortBranch = $branch.Substring(0, 10)
                return ($shortBranch + "...") 
            }
        }
        $ahead = get-ahead
        return ($branch + $ahead)
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
        $branch = _get-branch-name
        if ($branch) {
            $status = git status --porcelain 
            if ([string]::IsNullOrWhiteSpace($status)) {
                Write-Host "{$branch}" -NoNewline -ForegroundColor Green
            } else {
                Write-Host "{$branch}" -NoNewline -ForegroundColor Red
            } 
        }
    }

    [string]$p = dirforprompt
    if ($dospace) {
        $p = " $p"
    }
    Write-Host "$p>" -NoNewline
    return " "
}

aha-hello # Display the welcome message
