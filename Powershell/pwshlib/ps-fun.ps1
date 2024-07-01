
# Functions that follows powershell naming conventions

function ps-help {
    Write-Host
    Write-Host "PowerShell functions:"
    Write-Host "    ps-help:                        Show this help"
    Write-Host "    Test-CommandExists <command>:   Check if a command exists"    
    Write-Host
}

# Function to check if a command exists
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

