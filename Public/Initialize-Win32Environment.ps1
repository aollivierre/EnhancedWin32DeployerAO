function Initialize-Win32Environment {
    <#
    .SYNOPSIS
    Initializes the Win32 environment by setting up platform-specific configurations.

    .DESCRIPTION
    This function detects the platform (Windows or Unix) and sets up the environment accordingly. It throws an error if the operating system is unsupported, with proper error handling. The function returns an object containing platform details and the environment setup results.

    .PARAMETER scriptpath
    The path to the script being executed, used for logging or module setup purposes.

    .EXAMPLE
    $envInitialization = Initialize-Win32Environment -scriptpath "C:\path\to\your\script.ps1"
    Initializes the Win32 environment for the specified script path and returns initialization details.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Provide the path to the script being executed.")]
        [ValidateNotNullOrEmpty()]
        [string]$scriptpath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Initialize-Win32Environment function" -Level "INFO"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            $platform = Get-Platform
            $envDetails = $null

            if ($platform -eq 'Win32NT' -or $platform -eq [System.PlatformID]::Win32NT) {
                Write-EnhancedLog -Message "Detected platform: Windows (Win32NT)" -Level "INFO"
                $envDetails = Setup-WindowsEnvironment -scriptpath $scriptpath
            }
            elseif ($platform -eq 'Unix' -or $platform -eq [System.PlatformID]::Unix) {
                Write-EnhancedLog -Message "Detected platform: Unix" -Level "INFO"
                # Setup-LinuxEnvironment (commented out for now)
                $envDetails = [pscustomobject]@{ Platform = "Unix"; Setup = "Not implemented" }
            }
            else {
                Write-EnhancedLog -Message "Unsupported operating system detected: $platform" -Level "ERROR"
                throw "Unsupported operating system: $platform"
            }

            # Return the platform and environment setup details as an object
            return [pscustomobject]@{
                Platform   = $platform
                EnvDetails = $envDetails
            }
        }
        catch {
            Write-EnhancedLog -Message "Error occurred during environment initialization: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }

    End {
        Write-EnhancedLog -Message "Environment initialization completed for script: $scriptpath" -Level "INFO"
    }
}


# Run Initialize-Win32Environment and store the returned object
# $envInitialization = Initialize-Win32Environment -scriptpath "C:\path\to\your\script.ps1"

# Access the properties of the returned object
# Write-Host "Platform: $($envInitialization.Platform)"
# Write-Host "Environment Details: $($envInitialization.EnvDetails)"


# Platform: Win32NT
# Environment Details: @{AOscriptDirectory=C:\path\to\Win32Apps-DropBox; directoryPath=C:\path\to\Win32Apps-DropBox; Repo_Path=C:\path\to; Repo_winget=C:\path\to\Win32Apps-DropBox}



# # Run Initialize-Win32Environment and store the returned object
# $envInitialization = Initialize-Win32Environment -scriptpath "C:\path\to\your\script.ps1"

# # Access the properties of the EnvDetails object
# $AOscriptDirectory = $envInitialization.EnvDetails.AOscriptDirectory
# $directoryPath     = $envInitialization.EnvDetails.directoryPath
# $Repo_Path         = $envInitialization.EnvDetails.Repo_Path
# $Repo_winget       = $envInitialization.EnvDetails.Repo_winget

# # Output the extracted values
# Write-Host "AO Script Directory: $AOscriptDirectory"
# Write-Host "Directory Path: $directoryPath"
# Write-Host "Repository Path: $Repo_Path"
# Write-Host "Winget Path: $Repo_winget"
