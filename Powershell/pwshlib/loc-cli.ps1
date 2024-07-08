
<#
.SYNOPSIS
Gets the directory where location information is stored

.DESCRIPTION
Gets the directory where location information is stored by joining the home directory with the .locations directory
#>
function Get-LocationDirectory {
    $retVal = Join-Path -Path $HOME -ChildPath ".locations"
    if (-not (Test-Path -Path $retVal)) {
        New-Item -Path $retVal -ItemType Directory
    }
    return $retVal
}

function Test-ValidLocationName {
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

function Get-LocationCount {
    $locationsDir = Get-LocationDirectory
    $locations = Get-ChildItem -Path $locationsDir
    return $locations.Length
}

function Get-LocationNameAtPosition {
    param (
        [int]$position
    )

    $locationsDir = Get-LocationDirectory
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

function Add-Location {
    param(
        [string]$name,
        [string]$description
    )
    if (-not (Test-ValidLocationName -identifier $name)) {
        Write-Host "Invalid location name. Must start with a letter or underscore and contain only letters, numbers, and underscores" -ForegroundColor Red
        return
    }

    $path = (get-location).Path 
    $locationsDir = Get-LocationDirectory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    if (-not (Test-Path -Path $locationDir)) {
        [void](New-Item -Path $locationDir -ItemType Directory)
        $locFile = Join-Path -Path $locationDir -ChildPath "path.txt"
        $path | Out-File -FilePath $locFile
        $descFile = Join-Path -Path $locationDir -ChildPath "description.txt"
        $description | Out-File -FilePath $descFile   
    }
    else {
        Write-Host "Location named '$name' already added" -ForegroundColor Red
    }
}

function update-location-path {
    param(
        [string]$name
    )
    $locationsDir = Get-LocationDirectory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    if (Test-Path -Path $locationDir) {
        $locFile = Join-Path -Path $locationDir -ChildPath "path.txt"
        $path = (get-location).Path
        $path | Out-File -FilePath $locFile
    }
    else {
        Write-Host "Location '$name' does not exist" -ForegroundColor Red
    }
}

function rename-location {
    param(
        [string]$name,
        [string]$newName
    )
    if (-not (Test-ValidLocationName -identifier $newName)) {
        Write-Host "Invalid new location name. Must start with a letter or underscore and contain only letters, numbers, and underscores" -ForegroundColor Red
        return
    }

    $locationsDir = Get-LocationDirectory
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
    $locationsDir = Get-LocationDirectory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    if (Test-Path -Path $locationDir) {
        $descFile = Join-Path -Path $locationDir -ChildPath "description.txt"
        $description | Out-File -FilePath $descFile
    }
    else {
        Write-Host "Location '$name' does not exist" -ForegroundColor Red
    }
}

function do-location-exist([string]$name) {
    $locationsDir = Get-LocationDirectory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    $pathFile = Join-Path -Path $locationDir -ChildPath "path.txt"
    $path = Get-Content -Path $pathFile
    return (Test-Path -Path $path)
}

function list-locations {
    $locationsDir = Get-LocationDirectory
    $locations = Get-ChildItem -Path $locationsDir
    [int]$pos = 0
    Write-Host
    $locations | ForEach-Object {
        $name = $_.Name
        [bool]$exist = do-location-exist -name $name
        $descFile = Join-Path -Path $_.FullName -ChildPath "description.txt"
        $description = Get-Content -Path $descFile
        $pathFile = Join-Path -Path $_.FullName -ChildPath "path.txt"
        $path = Get-Content -Path $pathFile
        if (-not $exist) {
            Write-Host "$pos" -NoNewline -ForegroundColor Red
            Write-Host " - $name" -NoNewline -ForegroundColor Red
            Write-Host " - $description" -NoNewline -ForegroundColor Red
            Write-Host " - $path" -ForegroundColor Red
        }
        else {
            Write-Host "$pos" -NoNewline -ForegroundColor Yellow
            Write-Host " - $name" -NoNewline -ForegroundColor Cyan
            Write-Host " - $description" -NoNewline -ForegroundColor Green
            Write-Host " - $path" -ForegroundColor Cyan
        }
        $pos++
    }
    Write-Host
}

function wash-locations {
    $locationsDir = Get-LocationDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $locations | ForEach-Object {
        $pathFile = Join-Path -Path $_.FullName -ChildPath "path.txt"
        $path = Get-Content -Path $pathFile
        if (-not (Test-Path -Path $path)) {
            Remove-Item -Path $_.FullName -Recurse
        }
    }
}

function remove-location {
    param(
        [string]$name
    )
    $locationsDir = Get-LocationDirectory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    if (Test-Path -Path $locationDir) {
        Remove-Item -Path $locationDir -Recurse
    }
    else {
        Write-Host "Location '$name' does not exist" -ForegroundColor Red
    }
}

function Remove-ThisLocation {
    $path = (get-location).Path
    $locationsDir = Get-LocationDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $locations | ForEach-Object {
        $pathFile = Join-Path -Path $_.FullName -ChildPath "path.txt"
        $locPath = Get-Content -Path $pathFile
        if ($path -eq $locPath) {
            Remove-Item -Path $_.FullName -Recurse
        }
    }
}

function Mount-Location {
    param(
        [string]$name
    )
    $pos = Convert-ToUnsignedInt -inputString $name
    if ($pos -gt -1) {
        $count = Get-LocationCount
        if ($pos -ge $count) {
            Write-Host "Location '$name' does not exist" -ForegroundColor Red
            return
        }

        $name = Get-LocationNameAtPosition -position $pos    
    }

    $locationsDir = Get-LocationDirectory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    if (Test-Path -Path $locationDir) {
        $locFile = Join-Path -Path $locationDir -ChildPath "path.txt"
        $path = Get-Content -Path $locFile
        if (-not (Test-Path -Path $path)) {
            Write-Host "Location '$name' does not physical exist ('$path' probably deleted)" -ForegroundColor Red
            return
        }
        Set-Location -Path $path
        $host.UI.RawUI.WindowTitle = $name
    }
    else {
        Write-Host "Location '$name' does not exist" -ForegroundColor Red
    }
}

function Get-LocationWhereIAm {
    $locationsDir = Get-LocationDirectory
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

function Get-LocAddHelp {
    Write-Host
    Write-Host "Usage: loc add <name> <description>" -ForegroundColor Green
    Write-Host "Add the current working directory as a location with the given name and description" -ForegroundColor Green
    Write-Host
}

function Get-LocUpdateHelp {
    Write-Host
    Write-Host "Usage: loc update <name>" -ForegroundColor Green
    Write-Host "Update the path of a location with the given name to the current working directory" -ForegroundColor Green
    Write-Host
}

function Get-LocRenameHelp {
    Write-Host
    Write-Host "Usage: loc rename <name> <new-name>" -ForegroundColor Green
    Write-Host "Rename a location with the given name to the new name" -ForegroundColor Green
    Write-Host
}

function Get-LocEditHelp {
    Write-Host
    Write-Host "Usage: loc edit <name> <description>" -ForegroundColor Green
    Write-Host "Edit the description of a location with the given name" -ForegroundColor Green
    Write-Host
}

function Get-LocListHelp {
    Write-Host
    Write-Host "Usage: loc list" -ForegroundColor Green
    Write-Host "List all locations" -ForegroundColor Green
    Write-Host "You can also use 'loc ls' or 'loc l' to list all locations" -ForegroundColor Green
    Write-Host
}

function Get-LocRemoveHelp {
    Write-Host
    Write-Host "Usage: loc remove <name>" -ForegroundColor Green
    Write-Host "Remove a location with the given name" -ForegroundColor Green
    Write-Host
}

function Get-LocRemoveThisHelp {
    Write-Host
    Write-Host "Usage: loc remove-this" -ForegroundColor Green
    Write-Host "Remove the location you are currently at (do not worry the physical directory not deleted)" -ForegroundColor Green
    Write-Host
}

function Get-LocWashHelp {
    Write-Host
    Write-Host "Usage: loc wash" -ForegroundColor Green
    Write-Host "Remove locations that do not physically exist" -ForegroundColor Green
    Write-Host
}

function Get-LocGotoHelp {
    Write-Host
    Write-Host "Usage: loc goto <name | pos>" -ForegroundColor Green
    Write-Host "Go to the location with the given name (or position in location list)" -ForegroundColor Green
    Write-Host "You can also use 'loc go <name | pos>' to go to a location" -ForegroundColor Green
    Write-Host "Finally, you can use 'loc <name | pos>' to go to a location" -ForegroundColor Green
    Write-Host
}

function Get-LocWhereHelp {
    Write-Host
    Write-Host "Usage: loc where" -ForegroundColor Green
    Write-Host "Show the location you are currently at" -ForegroundColor Green
    Write-Host
}

function Get-LocCliActions {
    $commands = @(
        "add",
        "update",
        "rename",
        "edit",
        "list",
        "remove",
        "remove-this",
        "wash",
        "goto",
        "where"
    )
    return $commands
}

function Get-LocCliHelp {
    $actions = (Get-LocCliActions) -join ", "
    Write-Host
    Write-Host "loc - A location management and navigation command line interface" -ForegroundColor Green
    Write-Host 
    Write-Host "Usage: loc <action> ..." -ForegroundColor Green
    Write-Host "Actions: $actions" -ForegroundColor Green
    Write-Host
    Write-Host "Use 'loc help <action>' for more information on a specific action" -ForegroundColor Green
    Write-Host
}

# cli
function Loc {
    if ($args.Length -lt 1) {
        Write-Host
        Write-Host "Usage: loc <action> ..." -ForegroundColor Red
        Write-Host "For more help: loc help" -ForegroundColor Red
        Write-Host
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
        Add-Location -name $name -description $description
    }
    elseif ($action -eq "update") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc update <name>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        update-location-path -name $name
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
    elseif ($action -eq "list" -or $action -eq "ls" -or $action -eq "l") {
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
    elseif ($action -eq "remove-this") {
        Remove-ThisLocation
    }
    elseif ($action -eq "wash") {
        wash-locations
    }
    elseif ($action -eq "goto" -or $action -eq "go") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc goto <name>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        Mount-Location -name $name
    }
    elseif ($action -eq "where") {
        Get-LocationWhereIAm
    }
    elseif ($action -eq "help") {
        if ($args.Length -lt 2) {
            Get-LocCliHelp
            return
        }

        $subAction = $args[1]
        if ($subAction -eq "add") {
            Get-LocAddHelp
        }
        elseif ($subAction -eq "update") {
            Get-LocUpdateHelp
        }
        elseif ($subAction -eq "rename") {
            Get-LocRenameHelp
        }
        elseif ($subAction -eq "edit") {
            Get-LocEditHelp
        }
        elseif ($subAction -eq "list") {
            Get-LocListHelp
        }
        elseif ($subAction -eq "remove") {
            Get-LocRemoveHelp
        }
        elseif ($subAction -eq "remove-this") {
            Get-LocRemoveThisHelp
        }
        elseif ($subAction -eq "wash") {
            Get-LocWashHelp
        }
        elseif ($subAction -eq "goto") {
            Get-LocGotoHelp
        }
        elseif ($subAction -eq "where") {
            Get-LocWhereHelp
        }
        else {
            Write-Host
            Write-Host "Invalid sub-action '$subAction'" -ForegroundColor Red
            Write-Host "For more help: loc help" -ForegroundColor Red
            Write-Host
        }
    }
    else {
        loc go $action
    }
}
