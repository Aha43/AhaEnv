# Location Management Command Line Interface (CLI) - README

## Overview

This CLI tool provides an easy way to manage and navigate to various bookmarked locations within your filesystem. It allows you to add, update, rename, and remove locations, as well as add notes to each location. This tool is implemented using PowerShell functions.

## Installation

1. Copy the provided PowerShell script into a `.ps1` file, e.g., `locations.ps1`.
2. Open your PowerShell profile script (you can find the path using `$PROFILE`).
3. Add the following line to your profile script to load the functions on PowerShell startup:
    ```powershell
    . "Path\To\Your\locations.ps1"
    ```
4. Restart your PowerShell session or run the `. $PROFILE` command to reload the profile.

## Usage

### Basic Command Structure

The main command for interacting with the locations CLI is `loc`. It supports various subcommands to perform different actions. The general syntax is:

```powershell
loc <action> [parameters]
```

### Actions

Here is a list of all available actions and their usage:

#### Add a Location

```powershell
loc add <name> <description>
```
Adds the current working directory as a location with the specified name and description.

#### Add a Note to a Location

```powershell
loc note <name> <note>
```
Adds a note to the specified location.

#### Show Notes for a Location

```powershell
loc notes <name>
```
Displays all notes for the specified location.

#### Update a Location Path

```powershell
loc update <name>
```
Updates the path of the specified location to the current working directory.

#### Rename a Location

```powershell
loc rename <name> <new-name>
```
Renames the specified location to a new name.

#### Edit a Location Description

```powershell
loc edit <name> <description>
```
Edits the description of the specified location.

#### List All Locations

```powershell
loc list
```
Lists all saved locations.

#### Remove a Location

```powershell
loc remove <name>
```
Removes the specified location.

#### Remove the Current Location

```powershell
loc remove-this
```
Removes the location that points to the current working directory.

#### Repair Locations

```powershell
loc repair
```
Removes locations that no longer exist in the filesystem.

#### Go to a Location

```powershell
loc goto <name | pos>
```
Changes the current directory to the specified location. You can also use:
- `loc go <name | pos>`
- `loc <name | pos>`

#### Show the Current Location

```powershell
loc where
```
Displays the name and description of the location corresponding to the current directory.

### Help

To get help for a specific action, use the following command:

```powershell
loc help <action>
```

For example, to get help on the `add` action, run:

```powershell
loc help add
```

## Example Usage

1. **Add a Location**: 
    ```powershell
    loc add myProject "My project directory"
    ```
    This adds the current directory as a location named `myProject` with the description `My project directory`.

2. **List Locations**: 
    ```powershell
    loc list
    ```
    Displays all saved locations.

3. **Go to a Location**: 
    ```powershell
    loc myProject
    ```
    Changes the current directory to the location named `myProject`.

4. **Add a Note to a Location**: 
    ```powershell
    loc note myProject "Remember to update the README"
    ```
    Adds a note to the `myProject` location.

5. **Show Notes for a Location**: 
    ```powershell
    loc notes myProject
    ```
    Displays all notes for the `myProject` location.

6. **Remove a Location**: 
    ```powershell
    loc remove myProject
    ```
    Removes the `myProject` location.

## Additional Information

- The locations are stored in a hidden `.locations` directory in your home directory.
- Each location has a `path.txt` file storing the path and a `description.txt` file storing the description.
- Notes are stored in a `notes` directory within each location directory, with each note saved in a separate file named with a timestamp.

This CLI tool simplifies the management of frequently used directories, making it easy to navigate and maintain notes for each location.