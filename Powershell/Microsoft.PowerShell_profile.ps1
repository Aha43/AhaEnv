
# add the bin directory in user home to path
$env:Path += ";$env:USERPROFILE\bin"

$ProfileDir = Split-Path -Parent $PROFILE
$LibDir = Join-Path -Path $ProfileDir -ChildPath "pwshlib"

#Loading functions
if (Test-Path $LibDir) {
    $funfiles = Get-ChildItem -Path $LibDir -Filter "*.ps1"
    foreach ($file in $funfiles) {
        Write-Host ("Loading functions from: " + $file.FullName) -ForegroundColor Yellow
        . $file.FullName
    }
} else {
    Write-Host "Directory not found: $LibDir" -ForegroundColor Red
}

# Loading user specified stuff
function Run-UserPsFile {
    $UserPsFile = Join-Path -Path $HOME -ChildPath ".myps.ps1"
    Write-Host "UserPsFile: $UserPsFile"
    if (Test-Path $UserPsFile) {
        Write-Host "Running user specified file: $UserPsFile"
        . $UserPsFile
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

function help {
    Write-Host
    Write-Host "General functions:"
    Write-Host "    help:                           Show this help"
    Write-Host "    pub:                            Publish the current profile to the current profile"
    Write-Host "    propath:                        Show the current profile path"
    Write-Host "    propaths:                       Show the properties of the current profile"
    Write-Host
    Write-Host "Prompt functions:"
    Write-Host "    hello:                          Clear the screen and show the prompt header"
    Write-Host "    c:                              Clear the screen and show the prompt header"
    Write-Host "    time:                           Toggle the display of the time in the prompt"
    Write-Host "    branch:                         Toggle the display of the branch in the prompt"
    Write-Host "    bdots:                          Toggle the display of ... after the truncated branch name in the prompt"
    Write-Host "    bshort:                         Toggle the display of the branch name in the prompt"
    Write-Host "    btrunc <length>:                Truncate the branch name to the specified length"
    Write-Host "    pc <count>:                     Display the specified number of path components in the prompt"
    Write-Host "    short:                          Toggle the display of the current directory only in the prompt"
    Write-Host "    unix:                           Toggle the use of / as path separator in the prompt"
    Write-Host "    default:                        Reset the prompt to the default settings"
    Write-Host "    naken:                          Remove all prompt elements"
    Write-Host
    Write-Host "More help:"
    Write-Host "    ps-help:                        Show PowerShell functions"
    Write-Host "    dev-help:                       Show development functions"
    Write-Host "    git-help:                       Show git functions"
    Write-Host "    fs-help:                        Show file system functions"
    Write-Host "    ut-help:                        Show utility functions"
    Write-Host "    ji-help:                        Show Jira functions"
    Write-Host "    loc-help:                       Show location management and navigation commands help, the loc cli"
    Write-Host
}

# functions of use when developing this profile

function pub {
    $SourcePath = Join-Path -Path "." -ChildPath "Microsoft.PowerShell_profile.ps1"
    if (-not (Test-Path $SourcePath)) {
        Write-Host "Source profile file not found: $SourcePath" -ForegroundColor Red
        return
    }

    #read profile content into a variable
    $profileContent = Get-Content -Path $SourcePath

    #write the content to the current profile
    Set-Content -Path $PROFILE -Value $profileContent -Force

    #modify the branch variable in the profile so that it is set to the current branch
    $Branch = bname
    Add-Content -Path $PROFILE -Value "`$TheBranch = '$Branch'"
    
    Add-Content -Path $PROFILE -Value "hello"

    $LibSourcePath = Join-Path -Path "." -ChildPath "pwshlib"
    if (-not (Test-Path $LibSourcePath)) {
        Write-Host "Directory not found: $LibSourcePath"
        return
    }

    if (Test-Path $LibDir) {
        Write-Host "Deletes the lib directory: $LibDir" -ForegroundColor Yellow
        Remove-Item -Path $LibDir -Recurse -Force
    }

    if (-not (Test-Path $LibDir)) {
        Write-Host "Creates the lib directory: $LibDir" -ForegroundColor Yellow
        [void](New-Item -Path $LibDir -ItemType Directory)
    }

    Write-Host "Copies files from $LibSourcePath to $ProfileDir" -ForegroundColor Yellow
    Copy-Item -Path $LibSourcePath -Destination $ProfileDir -Recurse -Force 
}

function propath  { $PROFILE }
function propaths { $PROFILE | Get-Member -Type NoteProperty | Format-List }

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

<<<<<<< HEAD
Set-PSReadLineOption -Colors @{ Command = 'Green' }
=======
Run-UserPsFile
>>>>>>> 8f1e451 (now run a file .myps.ps1 if exist in users home dir)
