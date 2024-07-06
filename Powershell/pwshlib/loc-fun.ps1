
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
        Write-Host "Location at $locationDir already added"
    }
}

function list-locations {
    $locationsDir = get-location-directory
    $locations = Get-ChildItem -Path $locationsDir
    $locations | ForEach-Object {
        $name = $_.Name
        $descFile = Join-Path -Path $_.FullName -ChildPath "description.txt"
        $description = Get-Content -Path $descFile
        Write-Host "$name - $description"
    }
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
    }
    else {
        Write-Host "Location does not exist"
    }
}

# cli
function loc {
    if ($args.Length -lt 1) {
        Write-Host "Usage: loc <action> [name] [description]"
        Write-Host "Actions: add, list, remove, goto"
        return
    }

    $action = $args[0]
    
    if ($action -eq "add") {
        if ($args.Length -lt 3) {
            Write-Host "Usage: loc add <name> <description>"
            return
        }

        $name = $args[1]
        $description = $args[2]
        add-location -name $name -description $description
    }
    elseif ($action -eq "list") {
        list-locations
    }
    elseif ($action -eq "remove") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc remove <name>"
            return
        }

        $name = $args[1]
        remove-location -name $name
    }
    elseif ($action -eq "goto") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc goto <name>"
            return
        }

        $name = $args[1]
        goto-location -name $name
    }
    else {
        Write-Host "Invalid action $action"
    }
}
