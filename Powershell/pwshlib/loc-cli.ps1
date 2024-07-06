
function get-location-directory {
    $retVal = Join-Path -Path $HOME -ChildPath ".locations"
    if (-not (Test-Path -Path $retVal)) {
        New-Item -Path $retVal -ItemType Directory
    }
    return $retVal
}

function is-valid-locationName {
    param (
        [string]$identifier
    )

    $regex = '^[a-zA-Z_][a-zA-Z0-9_]*$'
    
    if ($identifier -match $regex) {
        return $true
    } else {
        return $false
    }
}

function Convert-ToUnsignedInt {
    param (
        [string]$inputString
    )

    # Try to convert the input string to an integer
    [int]$number = 0
    if (-not [int]::TryParse($inputString, [ref]$number)) {
        return -1
    }

    # Check if the number is negative
    if ($number -lt 0) {
        return -1
    }

    return [uint32]$number
}

function get-location-count {
    $locationsDir = get-location-directory
    $locations = Get-ChildItem -Path $locationsDir
    return $locations.Length
}

function get-location-name-at-position {
    param (
        [int]$position
    )

    $locationsDir = get-location-directory
    $locations = Get-ChildItem -Path $locationsDir
    $retVal = $null
    if ($locations.Length -gt 0) {
        $index = 0
        $locations | ForEach-Object {
            if ($index -eq $position) {
                $retVal = $_.Name
            }
            $index++
        }
    }
    return $retVal
}

function add-location {
    param(
        [string]$name,
        [string]$description
    )
    if (-not (is-valid-locationName -identifier $name)) {
        Write-Host "Invalid location name. Must start with a letter or underscore and contain only letters, numbers, and underscores" -ForegroundColor Red
        return
    }

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
        Write-Host "Location named '$name' already added" -ForegroundColor Red
    }
}

function rename-location {
    param(
        [string]$name,
        [string]$newName
    )
    if (-not (is-valid-locationName -identifier $newName)) {
        Write-Host "Invalid new location name. Must start with a letter or underscore and contain only letters, numbers, and underscores" -ForegroundColor Red
        return
    }

    $locationsDir = get-location-directory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    $newLocationDir = Join-Path -Path $locationsDir -ChildPath $newName

    if (Test-Path -Path $newLocationDir) {
        Write-Host "Location named '$newName' to rename to already exists" -ForegroundColor Red
        return
    }

    if (Test-Path -Path $locationDir) {
        Move-Item -Path $locationDir -Destination $newLocationDir
    }
    else {
        Write-Host "Location to rename '$name' does not exist" -ForegroundColor Red
    }
}

function edit-description {
    param(
        [string]$name,
        [string]$description
    )
    $locationsDir = get-location-directory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    if (Test-Path -Path $locationDir) {
        $descFile = Join-Path -Path $locationDir -ChildPath "description.txt"
        $description | Out-File -FilePath $descFile
    }
    else {
        Write-Host "Location '$name' does not exist" -ForegroundColor Red
    }
}

function list-locations {
    $locationsDir = get-location-directory
    $locations = Get-ChildItem -Path $locationsDir
    [int]$pos = 0
    Write-Host
    $locations | ForEach-Object {
        $name = $_.Name
        $descFile = Join-Path -Path $_.FullName -ChildPath "description.txt"
        $description = Get-Content -Path $descFile
        $pathFile = Join-Path -Path $_.FullName -ChildPath "path.txt"
        $path = Get-Content -Path $pathFile
        Write-Host "$pos" -NoNewline -ForegroundColor Yellow
        Write-Host " - $name" -NoNewline -ForegroundColor Cyan
        Write-Host " - $description" -NoNewline -ForegroundColor Green
        Write-Host " - $path" -ForegroundColor Cyan
        $pos++
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
        Write-Host "Location '$name' does not exist" -ForegroundColor Red
    }
}

function goto-location {
    param(
        [string]$name
    )
    $pos = Convert-ToUnsignedInt -inputString $name
    if ($pos -gt -1) {
        $count = get-location-count
        if ($pos -ge $count) {
            Write-Host "Location '$name' does not exist" -ForegroundColor Red
            return
        }

        $name = get-location-name-at-position -position $pos    
    }

    $locationsDir = get-location-directory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    if (Test-Path -Path $locationDir) {
        $locFile = Join-Path -Path $locationDir -ChildPath "path.txt"
        $path = Get-Content -Path $locFile
        Set-Location -Path $path
        $host.UI.RawUI.WindowTitle = $name
    }
    else {
        Write-Host "Location '$name' does not exist" -ForegroundColor Red
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

function loc-edit-help {
    Write-Host
    Write-Host "Usage: loc edit <name> <description>" -ForegroundColor Green
    Write-Host "Edit the description of a location with the given name" -ForegroundColor Green
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
    Write-Host "Usage: loc goto <name | pos>" -ForegroundColor Green
    Write-Host "Go to the location with the given name (or position in location list)" -ForegroundColor Green
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
    Write-Host "Actions: add, rename, edit, list, remove, goto, where" -ForegroundColor Green
    Write-Host
    Write-Host "Use 'loc help <action>' for more information on a specific action" -ForegroundColor Green
    Write-Host
}

# cli
function loc {
    if ($args.Length -lt 1) {
        Write-Host "Usage: loc <action> ..." -ForegroundColor Red
        Write-Host "Actions: add, rename, edit, list, remove, goto, where" -ForegroundColor Red
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
    elseif ($action -eq "edit") {
        if ($args.Length -lt 3) {
            Write-Host "Usage: loc edit <name> <description>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        $description = $args[2]
        edit-description -name $name -description $description
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
        elseif ($subAction -eq "edit") {
            loc-edit-help
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
            Write-Host "Invalid sub-action '$subAction'" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Invalid action '$action'" -ForegroundColor Red
    }
}
