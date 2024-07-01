
# This file contains functions that are useful for development work.

function dev-help {
    Write-Host
    Write-Host "Development functions:"
    Write-Host "    dev-help:                       Show this help"
    Write-Host "    csln:                           Clear a solution of all build artifacts"
    Write-Host
}

# Clears a solution of all build artifacts.
function csln {
    if (-not (Test-Path "*.sln")) {
        Write-Host "No solution file found in the current directory."
        return
    }

    Get-ChildItem -Recurse -Filter "obj" | Remove-Item -Recurse -Force
    Get-ChildItem -Recurse -Filter "bin" | Remove-Item -Recurse -Force
}
