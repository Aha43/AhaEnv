
function get-location-directory {
    $retVal = Join-Path -Path $HOME -ChildPath ".locations"
    if (-not (Test-Path -Path $retVal)) {
        New-Item -Path $retVal -ItemType Directory
    }
    return $retVal
}

function add-location {
    param(
        [string]$name,
        [string]$description
    )
    $path = (get-location).Path 
    $locationsDir = get-location-directory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    if (-not (Test-Path -Path $locationDir)) {
        New-Item -Path $locationDir -ItemType Directory
        $locFile = Join-Path -Path $locationDir -ChildPath "path.txt"
        $path | Out-File -FilePath $locFile
        $descFile = Join-Path -Path $locationDir -ChildPath "description.txt"
        $description | Out-File -FilePath $descFile   
    }
    else {
        Write-Host "Location named $name already added"
    }
}

function rename-location {
    param(
        [string]$name,
        [string]$newName
    )
    $locationsDir = get-location-directory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    $newLocationDir = Join-Path -Path $locationsDir -ChildPath $newName
    if (Test-Path -Path $locationDir) {
        Move-Item -Path $locationDir -Destination $newLocationDir
    }
    else {
        Write-Host "Location does not exist"
    }
}

function list-locations {
    $locationsDir = get-location-directory
    $locations = Get-ChildItem -Path $locationsDir
    Write-Host
    $locations | ForEach-Object {
        $name = $_.Name
        $descFile = Join-Path -Path $_.FullName -ChildPath "description.txt"
        $description = Get-Content -Path $descFile
        $pathFile = Join-Path -Path $_.FullName -ChildPath "path.txt"
        $path = Get-Content -Path $pathFile
        Write-Host "$name" -NoNewline -ForegroundColor Red
        Write-Host " - $description" -NoNewline -ForegroundColor Green
        Write-Host " - $path" -ForegroundColor Cyan
    }
    Write-Host
}

function remove-location {
    param(
        [string]$name
    )
    $locationsDir = get-location-directory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    if (Test-Path -Path $locationDir) {
        Remove-Item -Path $locationDir -Recurse
    }
    else {
        Write-Host "Location does not exist"
    }
}

function goto-location {
    param(
        [string]$name
    )
    $locationsDir = get-location-directory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    if (Test-Path -Path $locationDir) {
        $locFile = Join-Path -Path $locationDir -ChildPath "path.txt"
        $path = Get-Content -Path $locFile
        Set-Location -Path $path
        $host.UI.RawUI.WindowTitle = $name
    }
    else {
        Write-Host "Location does not exist"
    }
}

function loc-where-am-i {
    $locationsDir = get-location-directory
    $locations = Get-ChildItem -Path $locationsDir
    $path = (get-location).Path
    [bool]$found = $false
    if ($locations.Length -gt 0) {
        $locations | ForEach-Object {
            $name = $_.Name
            $pathFile = Join-Path -Path $_.FullName -ChildPath "path.txt"
            $locPath = Get-Content -Path $pathFile
            if ($path -eq $locPath) {
                $descFile = Join-Path -Path $_.FullName -ChildPath "description.txt"
                $description = Get-Content -Path $descFile
                Write-Host
                Write-Host "Where: You are at location '$name'" -ForegroundColor Green
                Write-Host "What: $description" -ForegroundColor Cyan
                Write-Host
                $found = $true
            }
        }
    }
    
    if (-not $found) {
        Write-Host
        Write-Host "You are not at any registered location" -ForegroundColor Red
        Write-Host "Use 'loc add <name> <description>' to add current working direction as a location" -ForegroundColor Green
        Write-Host
    }
}

function loc-add-help {
    Write-Host
    Write-Host "Usage: loc add <name> <description>" -ForegroundColor Green
    Write-Host "Add the current working directory as a location with the given name and description" -ForegroundColor Green
    Write-Host
}

function loc-rename-help {
    Write-Host
    Write-Host "Usage: loc rename <name> <new-name>" -ForegroundColor Green
    Write-Host "Rename a location with the given name to the new name" -ForegroundColor Green
    Write-Host
}

function loc-list-help {
    Write-Host
    Write-Host "Usage: loc list" -ForegroundColor Green
    Write-Host "List all locations" -ForegroundColor Green
    Write-Host
}

function loc-remove-help {
    Write-Host
    Write-Host "Usage: loc remove <name>" -ForegroundColor Green
    Write-Host "Remove a location with the given name" -ForegroundColor Green
    Write-Host
}

function loc-goto-help {
    Write-Host
    Write-Host "Usage: loc goto <name>" -ForegroundColor Green
    Write-Host "Go to the location with the given name" -ForegroundColor Green
    Write-Host
}

function loc-where-help {
    Write-Host
    Write-Host "Usage: loc where" -ForegroundColor Green
    Write-Host "Show the location you are currently at" -ForegroundColor Green
    Write-Host
}

function loc-help {
    Write-Host
    Write-Host "loc - Location management and navigation" -ForegroundColor Green
    Write-Host 
    Write-Host "Usage: loc <action> ..." -ForegroundColor Green
    Write-Host "Actions: add, rename, list, remove, goto, where" -ForegroundColor Green
    Write-Host
    Write-Host "Use 'loc help <action>' for more information on a specific action" -ForegroundColor Green
    Write-Host
}

# cli
function loc {
    if ($args.Length -lt 1) {
        Write-Host "Usage: loc <action> ..." -ForegroundColor Red
        Write-Host "Actions: add, rename, list, remove, goto, where" -ForegroundColor Red
        return
    }

    $action = $args[0]
    
    if ($action -eq "add") {
        if ($args.Length -lt 3) {
            Write-Host "Usage: loc add <name> <description>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        $description = $args[2]
        add-location -name $name -description $description
    }
    elseif ($action -eq "rename") {
        if ($args.Length -lt 3) {
            Write-Host "Usage: loc rename <name> <new-name>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        $newName = $args[2]
        rename-location -name $name -newName $newName
    }
    elseif ($action -eq "list") {
        list-locations
    }
    elseif ($action -eq "remove") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc remove <name>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        remove-location -name $name
    }
    elseif ($action -eq "goto") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc goto <name>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        goto-location -name $name
    }
    elseif ($action -eq "where") {
        loc-where-am-i
    }
    elseif ($action -eq "help") {
        if ($args.Length -lt 2) {
            loc-help
            return
        }

        $subAction = $args[1]
        if ($subAction -eq "add") {
            loc-add-help
        }
        elseif ($subAction -eq "rename") {
            loc-rename-help
        }
        elseif ($subAction -eq "list") {
            loc-list-help
        }
        elseif ($subAction -eq "remove") {
            loc-remove-help
        }
        elseif ($subAction -eq "goto") {
            loc-goto-help
        }
        elseif ($subAction -eq "where") {
            loc-where-help
        }
        else {
            Write-Host "Invalid sub-action $subAction" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Invalid action $action" -ForegroundColor Red
    }
}
