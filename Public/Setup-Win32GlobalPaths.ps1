function Setup-Win32GlobalPaths {
    <#
    .SYNOPSIS
    Sets up the global paths based on the environment.

    .DESCRIPTION
    This function sets the global paths dynamically based on whether the environment is running inside Docker or not. It uses environment variables when in Docker, otherwise defaults to the script root path or a provided script path.

    .PARAMETER scriptpath
    The path to the script that is being executed, used to determine the base paths.

    .EXAMPLE
    Setup-Win32GlobalPaths -scriptpath "C:\path\to\script.ps1"
    Sets up the global paths using the provided script path.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, HelpMessage = "Provide the path to the script being executed.")]
        [ValidateNotNullOrEmpty()]
        [string]$scriptpath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Setup-Win32GlobalPaths function" -Level "INFO"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            if ($env:DOCKER_ENV -eq $true) {
                Write-EnhancedLog -Message "Docker environment detected." -Level "INFO"
                $global:scriptBasePath = $env:SCRIPT_BASE_PATH
                Write-EnhancedLog -Message "Docker script base path: $global:scriptBasePath" -Level "INFO"
            }
            else {
                Write-EnhancedLog -Message "Non-Docker environment detected." -Level "INFO"

                # Use provided scriptpath if available, otherwise default to $PSScriptRoot
                if ($scriptpath) {
                    $global:scriptBasePath = Split-Path -Path $scriptpath -Parent
                    Write-EnhancedLog -Message "Using provided script path: $global:scriptBasePath" -Level "INFO"
                }
                else {
                    $global:scriptBasePath = $PSScriptRoot
                    Write-EnhancedLog -Message "Using PSScriptRoot as script base path: $global:scriptBasePath" -Level "INFO"
                }
            }
        }
        catch {
            Write-EnhancedLog -Message "Error occurred during Setup-Win32GlobalPaths: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }

    End {
        Write-EnhancedLog -Message "Completed Setup-Win32GlobalPaths function." -Level "INFO"
    }
}
