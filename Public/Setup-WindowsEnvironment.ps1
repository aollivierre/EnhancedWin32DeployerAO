function Setup-WindowsEnvironment {
    <#
    .SYNOPSIS
    Sets up the Windows environment by configuring necessary paths and logging the setup process.

    .DESCRIPTION
    This function dynamically constructs the necessary paths for the Windows environment using the provided script path. It logs the setup process and returns an object with the relevant paths.

    .PARAMETER scriptpath
    The path to the script that is being executed, used to determine the base paths for the setup.

    .EXAMPLE
    $envDetails = Setup-WindowsEnvironment -scriptpath "C:\path\to\script.ps1"
    Initializes the Windows environment using the provided script path and returns the paths.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Provide the path to the script being executed.")]
        [ValidateNotNullOrEmpty()]
        [string]$scriptpath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Setup-WindowsEnvironment function" -Level "INFO"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters

        try {
            # Set base paths from script path
            Write-EnhancedLog -Message "Script base path: $scriptpath" -Level "INFO"

            # Construct the paths dynamically using the base path
            $AOscriptDirectory = Join-Path -Path $scriptpath -ChildPath "Win32Apps-Source"
            $directoryPath = Join-Path -Path $scriptpath -ChildPath "Win32Apps-Source"
            $Repo_winget = Join-Path -Path $scriptpath -ChildPath "Win32Apps-Source"

            # Log the dynamically constructed paths
            Log-Params -Params @{

                AOscriptDirectory = $AOscriptDirectory
                directoryPath     = $directoryPath
                Repo_Path         = $scriptpath
                Repo_winget       = $Repo_winget
            }

            Write-EnhancedLog -Message "Paths set up successfully." -Level "INFO"

            # Return the constructed paths as an object
            return [pscustomobject]@{
                AOscriptDirectory = $AOscriptDirectory
                directoryPath     = $directoryPath
                Repo_Path         = $scriptpath
                Repo_winget       = $Repo_winget
            }
        }
        catch {
            Write-EnhancedLog -Message "Error occurred during Setup-WindowsEnvironment: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }

    End {
        Write-EnhancedLog -Message "Completed Setup-WindowsEnvironment function." -Level "INFO"
    }
}


# # Run Setup-WindowsEnvironment and store the returned object
# $envDetails = Setup-WindowsEnvironment -scriptpath "C:\path\to\script.ps1"

# # Access the properties of the returned object
# Write-Host "AO Script Directory: $($envDetails.AOscriptDirectory)"
# Write-Host "Directory Path: $($envDetails.directoryPath)"
# Write-Host "Repository Path: $($envDetails.Repo_Path)"
# Write-Host "Winget Path: $($envDetails.Repo_winget)"

# AO Script Directory: C:\path\to\Win32Apps-Source
# Directory Path: C:\path\to\Win32Apps-Source
# Repository Path: C:\path\to\script.ps1
# Winget Path: C:\path\to\Win32Apps-Source
