
function fs-help {
    Write-Host 
    Write-Host "Filesystem functions:"
    Write-Host "    fs-help:                        Show this help"
    Write-Host "    findf:                          Find files by name in the current directory and its subdirectories"
    Write-Host "    mcd:                            Create a directory and change to it"
    Write-Host "    killdir:                        Remove a directory recursively using force"
    Write-Host "    go:                             Change to a directory and set the title of the terminal to the directory name"
    Write-Host "    dtitle:                         Set the title of the terminal to the current directory"
    Write-Host "    crf:                            Create a file if it does not exist"
    Write-Host
}

# Find files by name in the current directory and its subdirectories
function findf {
    if ($args.Length -ne 1) {
        Write-Host "Usage: findf <name>"
        return
    }
    $name = $args[0]
    $path = Get-Location

    Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ilike "*$name*" } | Select-Object -ExpandProperty FullName
}

# Create a directory and change to it
function mcd {
    if ($args.Length -eq 0) {
        Write-Host "Usage: mcd <directory name>"
    } else {
        New-Item -ItemType Directory -Path $args[0] -Force
        Set-Location -Path $args[0]
    }
}

# Remove a directory and all its contents
function killdir {
    if ($args.Length -eq 0) {
        Write-Host "Usage: killdir <directory name>"
    } else {
        Remove-Item -Path $args[0] -Recurse -Force
    } 
}

# Change to a directory and update the title bar
function go {
    if ($args.Length -eq 0) {
        Write-Host "Usage: go <directory name>"
    } else {
        Set-Location -Path $args[0]
        dtitle
    }
}

# Set the title of the terminal to the current directory
function dtitle {
    $dir = Get-Location
    $lastDir = $dir | Split-Path -Leaf
    $host.UI.RawUI.WindowTitle = $lastDir
}

# Create a file if it does not exist
function crf([string]$filename) {
    if ($filename -eq "") {
        Write-Host "Usage: crf <filename>"
        return
    }
    if (-not (Test-Path $filename)) {
        New-Item -ItemType File -Path $filename -Force
    }
}
