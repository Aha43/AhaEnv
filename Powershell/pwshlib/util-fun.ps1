
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

function help-utilities {
    Write-Host
    Write-Host "week - get the current week number"
    Write-Host "title <title> - set the terminal title"
    Write-Host "genpwd - generate a random password"
    Write-Host "psv - show the PowerShell version"
    Write-Host "quote - show a random quote"
    Write-Host "utilities - show this help"
    Write-Host
}
