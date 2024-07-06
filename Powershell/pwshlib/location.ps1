# Define the path to the JSON file
$jsonFilePath = "C:\Users\arne.halvorsen\locations.json"

# Function to read metadata from JSON file
function Get-LocationMetadata {
    param (
        [string]$jsonFilePath
    )

    Write-Output "Reading location metadata from JSON file: $jsonFilePath"

    # Check if the JSON file exists
    if (-Not (Test-Path $jsonFilePath)) {
        Write-Error "The JSON file at path $jsonFilePath does not exist."
        return
    }

    # Read the content of the JSON file
    $jsonContent = Get-Content -Path $jsonFilePath -Raw

    # Convert the JSON content to a PowerShell object
    $locations = $jsonContent | ConvertFrom-Json

    # Process each location
    foreach ($location in $locations) {
        Write-Output "Name: $($location.name)"
        Write-Output "Path: $($location.path)"
        Write-Output "Description: $($location.description)"
        Write-Output "-----------------------------------"
    }
}

# Function to add an entry for the current directory
function Add-LocationMetadata {
    param (
        [string]$name,
        [string]$description = ""
    )

    Write-Output "Adding new location metadata: Name=$name, Description=$description"

    # Get the current directory path
    $currentPath = Get-Location
    Write-Output "Current directory path: $currentPath"

    # Create a new location object
    $newLocation = [PSCustomObject]@{
        name        = $name
        path        = $currentPath.Path.ToString()
        description = $description
    }

    # Check if the JSON file exists
    if (Test-Path $jsonFilePath) {
        # Read existing content and convert to PowerShell object
        $jsonContent = Get-Content -Path $jsonFilePath -Raw
        $locations = $jsonContent | ConvertFrom-Json

        # Append the new location to the existing locations
        $locations += $newLocation
    } else {
        # If file does not exist, create a new array with the new location
        $locations = @($newLocation)
    }

    # Convert the updated locations back to JSON
    Write-Host "Generate new jsons"
    $updatedJsonContent = $locations | ConvertTo-Json

    # Save the updated JSON content back to the file
    Write-Host "Update file: $jsonFilePath"
    $updatedJsonContent | Set-Content -Path $jsonFilePath

    Write-Output "Added new location metadata for '$name' at path '$currentPath'."
}

# Function to change directory based on name key in the JSON
function Switch-Location {
    param (
        [string]$name
    )

    Write-Output "Switching to location: $name"

    # Check if the JSON file exists
    if (-Not (Test-Path $jsonFilePath)) {
        Write-Error "The JSON file at path $jsonFilePath does not exist."
        return
    }

    # Read the content of the JSON file
    $jsonContent = Get-Content -Path $jsonFilePath -Raw

    # Convert the JSON content to a PowerShell object
    $locations = $jsonContent | ConvertFrom-Json

    # Find the location with the specified name
    $location = $locations | Where-Object { $_.name -eq $name }

    if ($null -eq $location) {
        Write-Error "No location found with the name '$name'."
        return
    }

    Write-Output "Changing directory to: $($location.path)"
    
    # Change directory to the path of the found location
    Set-Location -Path $location.path

    # Set the terminal title to the name
    $host.UI.RawUI.WindowTitle = $name

    Write-Output "Changed directory to '$($location.path)' and set terminal title to '$name'."
}

# Function to remove an entry based on the name key in the JSON
function Remove-LocationMetadata {
    param (
        [string]$name
    )

    Write-Output "Removing location metadata: $name"

    # Check if the JSON file exists
    if (-Not (Test-Path $jsonFilePath)) {
        Write-Error "The JSON file at path $jsonFilePath does not exist."
        return
    }

    # Read the content of the JSON file
    $jsonContent = Get-Content -Path $jsonFilePath -Raw

    # Convert the JSON content to a PowerShell object
    $locations = $jsonContent | ConvertFrom-Json

    # Find the location with the specified name
    $location = $locations | Where-Object { $_.name -eq $name }

    if ($null -eq $location) {
        Write-Error "No location found with the name '$name'."
        return
    }

    # Remove the location from the array
    $locations = $locations | Where-Object { $_.name -ne $name }

    # Convert the updated locations back to JSON
    $updatedJsonContent = $locations | ConvertTo-Json -Depth 10

    # Save the updated JSON content back to the file
    $updatedJsonContent | Set-Content -Path $jsonFilePath

    Write-Output "Removed location metadata for '$name'."
}

# Main function to parse CLI-like commands
function location {
    # param (
    #     [string[]]$args
    # )

    Write-Output "Executing command: location $($args -join ' ')"

    if ($args.Length -eq 0) {
        Write-Output "Usage: location <command> [<args>]"
        Write-Output "Commands:"
        Write-Output "  add <name> [description] - Add a new location metadata entry for the current directory"
        Write-Output "  delete <name>            - Remove a location metadata entry by name"
        Write-Output "  go <name>                - Change to a directory by name and set terminal title"
        Write-Output "  list                     - List all location metadata entries"
        return
    }

    $command = $args[0]
    switch ($command) {
        "add" {
            if ($args.Length -lt 2) {
                Write-Error "Usage: location add <name> [description]"
                return
            }
            $name = $args[1]
            $description = if ($args.Length -ge 3) { $args[2..($args.Length-1)] -join ' ' } else { "" }
            Add-LocationMetadata -name $name -description $description
        }
        "delete" {
            if ($args.Length -lt 2) {
                Write-Error "Usage: location delete <name>"
                return
            }
            $name = $args[1]
            Remove-LocationMetadata -name $name
        }
        "go" {
            if ($args.Length -lt 2) {
                Write-Error "Usage: location go <name>"
                return
            }
            $name = $args[1]
            Switch-Location -name $name
        }
        "list" {
            Get-LocationMetadata -jsonFilePath $jsonFilePath
        }
        default {
            Write-Error "Unknown command: $command"
            Write-Output "Usage: location <command> [<args>]"
            Write-Output "Commands:"
            Write-Output "  add <name> [description] - Add a new location metadata entry for the current directory"
            Write-Output "  delete <name>            - Remove a location metadata entry by name"
            Write-Output "  go <name>                - Change to a directory by name and set terminal title"
            Write-Output "  list                     - List all location metadata entries"
        }
    }
}

# Call the main function with command-line arguments
#location $args
