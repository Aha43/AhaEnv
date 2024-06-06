
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
        dirasttitle
    }
}

function dirasttitle() {
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
        dirasttitle
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

# Aha functions

function aha-help() {
    Write-Host "Aha prefix functions:"
    Write-Host "  aha-help: Display this help message"
    Write-Host "  aha-profilepath: Display the profile path"
    Write-Host "  aha-profilepaths: Display the profile paths"
    Write-Host "  aha-ttitle: Set the title of the terminal"
    Write-Host "  aha-publishprofile: Copy the profile to the current profile"
    Write-Host "  aha-gennewpwd: Generate a new password"

    Write-Host "dir functions:"
    Write-Host "  cleanso: Clean the solution directory"
    Write-Host "  mkdircd: Create a directory and change to it"
    Write-Host "  killdir: Remove a directory recursively using force"
    Write-Host "  dirasttitle: Set the title of the terminal to the current directory"
    Write-Host "  gitclonecd: Clone a git repository and change to it"
    Write-Host "  goto: Change to a directory and set the title of the terminal to the directory name"

    Write-Host "dll functions:"
    Write-Host "  dllfullname: Get the full name of a DLL file"

    Write-Host "Aliases:"
    Write-Host "  c: clear terminal"

    Write-Host "Tips:"
    Write-Host "  explorer . : Open the current directory in the file explorer"
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

function aha-ttitle() {
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

# Aliases
Set-Alias -Name c -Value clear


# write random line from a list of text lines
function randomline() {
    $lines = @(Get-Content $args[0])
    $lines | Get-Random
}

# if quotes file exists in user home directory, write a random quote
$quotesFile = "$env:USERPROFILE\quotes.txt"
if (Test-Path $quotesFile) {
    Write-Host
    randomline $quotesFile
    Write-Host
}
