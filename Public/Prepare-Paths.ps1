function Prepare-Paths {
    <#
    .SYNOPSIS
    Prepares the necessary paths for Win32 app deployment.

    .DESCRIPTION
    This function checks for and creates the required directories for a given program. It returns the destination path as part of an object.

    .PARAMETER Prg
    The program object containing metadata like the name of the program.

    .PARAMETER Prg_Path
    The source path where the program files are located.

    .PARAMETER Win32AppsRootPath
    The root path for storing the Win32 apps.

    .EXAMPLE
    $paths = Prepare-Paths -Prg $Prg -Prg_Path "C:\Programs\MyApp" -Win32AppsRootPath "C:\Win32AppsRoot"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Provide the program object.")]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$Prg,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the source path of the program.")]
        [ValidateNotNullOrEmpty()]
        [string]$Prg_Path,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the root path for Win32 apps.")]
        [ValidateNotNullOrEmpty()]
        [string]$Win32AppsRootPath
    )

    # Check if the source path exists, create if it doesn't
    if (-not (Test-Path -Path $Prg_Path)) {
        Write-EnhancedLog -Message "Source path $Prg_Path does not exist. Creating it." -Level "INFO"
        New-Item -Path $Prg_Path -ItemType Directory -Force
    }
    
    # Prepare the destination root path and app-specific destination path
    $destinationRootPath = Join-Path -Path $Win32AppsRootPath -ChildPath "Win32Apps"
    if (-not (Test-Path -Path $destinationRootPath)) {
        New-Item -Path $destinationRootPath -ItemType Directory -Force
    }

    $destinationPath = Join-Path -Path $destinationRootPath -ChildPath $Prg.name
    if (-not (Test-Path -Path $destinationPath)) {
        New-Item -Path $destinationPath -ItemType Directory -Force
    }

    Write-EnhancedLog -Message "Destination path created: $destinationPath" -Level "INFO"

    # Return an object with the paths
    return [pscustomobject]@{
        Prg              = $Prg.name
        SourcePath       = $Prg_Path
        DestinationRoot  = $destinationRootPath
        DestinationPath  = $destinationPath
    }
}


# # Prepare paths and store the returned object
# $paths = Prepare-Paths -Prg $Prg -Prg_Path "C:\Programs\MyApp" -Win32AppsRootPath "C:\Win32AppsRoot"

# # Access the properties of the returned object
# Write-Host "Program Name: $($paths.Prg)"
# Write-Host "Source Path: $($paths.SourcePath)"
# Write-Host "Destination Root: $($paths.DestinationRoot)"
# Write-Host "Destination Path: $($paths.DestinationPath)"


# Program Name: MyApp
# Source Path: C:\Programs\MyApp
# Destination Root: C:\Win32AppsRoot\Win32Apps
# Destination Path: C:\Win32AppsRoot\Win32Apps\MyApp

