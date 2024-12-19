
function ut-help {
    Write-Host
    Write-Host "Utility functions:"
    Write-Host "    envs:                           List all environment variables"
    Write-Host "    ut-help:                        Show this help"
    Write-Host "    week:                           Get the current week number"
    Write-Host "    title <title>:                  Set the terminal title"
    Write-Host "    genpwd:                         Generate a random password"
    Write-Host "    psv:                            Show the PowerShell version"
    Write-Host "    quote:                          how a random quote"
    Write-Host
}

function week { get-date -UFormat %V }

function envs {
    Get-ChildItem Env: | Sort-Object Name
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

function Get-SunTimes {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Location,
        
        [Parameter(Mandatory = $false)]
        [datetime]$Date = (Get-Date)
    )

    # Get coordinates for the location
    $geoData = Invoke-RestMethod -Uri "https://nominatim.openstreetmap.org/search?q=$Location&format=json&limit=1" -Method Get

    if (!$geoData) {
        Write-Error "Location not found. Please provide a valid location."
        return
    }

    $latitude = $geoData[0].lat
    $longitude = $geoData[0].lon

    # Format the date
    $formattedDate = $Date.ToString("yyyy-MM-dd")

    # Call the Sunrise-Sunset API
    $apiUrl = "https://api.sunrise-sunset.org/json?lat=$latitude&lng=$longitude&date=$formattedDate&formatted=0"
    $sunData = Invoke-RestMethod -Uri $apiUrl -Method Get

    if ($sunData.status -ne "OK") {
        Write-Error "Failed to retrieve sunrise and sunset data."
        return
    }

    # Parse and keep full precision
    $sunriseUTC = [datetime]$sunData.results.sunrise
    $sunsetUTC = [datetime]$sunData.results.sunset
    $sunriseLocal = $sunriseUTC.ToLocalTime()
    $sunsetLocal = $sunsetUTC.ToLocalTime()

    # Output the results with full precision
    [PSCustomObject]@{
        Location = $Location
        Date = $Date.ToShortDateString()
        Sunrise = $sunriseLocal.ToString("HH:mm:ss")
        Sunset = $sunsetLocal.ToString("HH:mm:ss")
    }
}

function Compare-SunsetTimes {
    param (
        [Parameter(Mandatory = $false)]
        [int]$DaysAgo = 1  # Default to comparing yesterday
    )

    # Use the environment variable for the location
    $Location = $env:MyLocation

    if (-not $Location) {
        Write-Error "Environment variable 'MyLocation' is not set. Please set it before using this function."
        return
    }

    # Get today's and comparison date
    $today = Get-Date
    $comparisonDate = $today.AddDays(-$DaysAgo)

    # Get sunset times for today and the comparison date
    $todaySunTimes = Get-SunTimes -Location $Location -Date $today
    $comparisonSunTimes = Get-SunTimes -Location $Location -Date $comparisonDate

    if (!$todaySunTimes -or !$comparisonSunTimes) {
        Write-Error "Could not retrieve sunset times."
        return
    }

    # Parse sunset times
    $todaySunset = [datetime]::Parse($todaySunTimes.Sunset)
    $comparisonSunset = [datetime]::Parse($comparisonSunTimes.Sunset)

    # Calculate the difference in sunset times
    $difference = $todaySunset - $comparisonSunset
    $differenceMinutes = [math]::Floor($difference.TotalMinutes)
    $differenceSeconds = [math]::Round($difference.TotalSeconds % 60)

    # Determine whether it sets earlier or later
    $trend = if ($difference.TotalSeconds -gt 0) { "later" } else { "earlier" }

    # Format the difference string
    $formattedDifference = "{0} minutes and {1} seconds {2}" -f `
        [math]::Abs($differenceMinutes), `
        [math]::Abs($differenceSeconds), `
        $trend

    # Generate the output string
    $output = "Today in $Location, the sun sets at $($todaySunTimes.Sunset). That is $formattedDifference compared to $DaysAgo day(s) ago."
    return $output
}
