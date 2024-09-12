function Process-Win32App {
    <#
    .SYNOPSIS
    Processes a Win32 app folder and uploads the app to Intune.

    .DESCRIPTION
    This function processes the Win32 app by defining the program's ID, name, and description based on the folder's name. It checks for a valid application image, defines the source path, and uploads the application to Intune using PowerShell 5. The function returns an object with details about the processed Win32 app.

    .PARAMETER Folder
    The folder containing the Win32 app to be processed.

    .PARAMETER config
    The configuration object required for uploading the Win32 app.

    .PARAMETER Repo_winget
    The path to the repository (winget) where the program source resides.

    .PARAMETER scriptpath
    The path to the script that is being executed.

    .EXAMPLE
    $appDetails = Process-Win32App -Folder (Get-Item "C:\Programs\MyApp") -config $config -Repo_winget "C:\Repo\winget" -scriptpath "C:\path\to\script"
    Processes the Win32 app and returns the app details.
    #>

    [CmdletBinding(ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Provide the folder containing the Win32 app.")]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo]$Folder,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the configuration for the Win32 app.")]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$config,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the path to the winget repository.")]
        [ValidateNotNullOrEmpty()]
        [string]$Repo_winget,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the path to the script being executed.")]
        [ValidateNotNullOrEmpty()]
        [string]$scriptpath
    )

    Begin {
        # Create the program object based on the folder's name
        $Prg = [PSCustomObject]@{
            id          = $Folder.Name
            name        = $Folder.Name
            Description = $Folder.Name
        }

        Write-EnhancedLog -Message "Program ID: $($Prg.id)" -Level "INFO"
        Write-EnhancedLog -Message "Program Name: $($Prg.name)" -Level "INFO"
        Write-EnhancedLog -Message "Description: $($Prg.Description)" -Level "INFO"

        # Ensure that Program ID matches Program Name
        if ($Prg.id -ne $Prg.name) {
            throw "Error: Program ID ('$($Prg.id)') does not match Program Name ('$($Prg.name)')."
        }
    }

    Process {
        # Define the source path for the program and check for the application image
        $sourcePathDetails = Define-SourcePath -Repo_winget $Repo_winget -Prg $Prg
        $Prg_Path = $sourcePathDetails.SourcePath
        $imageDetails = Check-ApplicationImage -Prg_Path $Prg_Path -Prg $Prg

        # Define the splatted parameters for Upload-Win32App
        $UploadWin32AppParams = @{

            Prg               = $Prg
            Prg_Path          = $sourcePathDetails.SourcePath
            Prg_img           = $imageDetails.ImagePath
            Win32AppsRootPath = $scriptpath
            config            = $config
        }
        Upload-Win32App @UploadWin32AppParams

        # Build the return object with details of the Win32 app
        $appDetails = [pscustomobject]@{
            ProgramID       = $Prg.id
            ProgramName     = $Prg.name
            SourcePath      = $sourcePathDetails.SourcePath
            Config          = $config
        }

        # Return the app details object
        return $appDetails
    }

    End {
        Write-EnhancedLog -Message "Completed processing of Win32 app: $($Prg.name)" -Level "INFO"
    }
}

# Example Usage:
# $appDetails = Process-Win32App -Folder (Get-Item "C:\Programs\MyApp") -config $config -Repo_winget "C:\Repo\winget" -scriptpath "C:\path\to\script"





# # Run Process-Win32App and store the returned object
# $appDetails = Process-Win32App -Folder (Get-Item "C:\Programs\MyApp") -config $config

# # Access the properties of the returned object
# Write-Host "Program ID: $($appDetails.ProgramID)"
# Write-Host "Program Name: $($appDetails.ProgramName)"
# Write-Host "Source Path: $($appDetails.SourcePath)"

# Program ID: MyApp
# Program Name: MyApp
# Source Path: C:\path\to\Win32Apps-DropBox\MyApp
