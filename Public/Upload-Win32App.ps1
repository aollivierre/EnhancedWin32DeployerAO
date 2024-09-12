function Upload-Win32App {
    <#
    .SYNOPSIS
    Uploads a Win32 application to Intune.

    .DESCRIPTION
    The Upload-Win32App function uploads a Win32 application package to Intune, prepares paths, creates the IntuneWin package, and uploads it along with the install and uninstall command lines. It validates that the script is running in PowerShell 5 before proceeding.

    .PARAMETER Prg
    The application object with necessary details for the upload.

    .PARAMETER Prg_Path
    The path to the application being uploaded.

    .PARAMETER Prg_img
    The image associated with the application (optional).

    .PARAMETER Win32AppsRootPath
    The root path where the Win32 apps are stored (optional).

    .PARAMETER linetoadd
    Additional lines to add (optional).

    .PARAMETER config
    Configuration object containing necessary details for installation commands.

    .EXAMPLE
    $params = @{
        Prg = [pscustomobject]@{ name = 'ExampleApp'; id = 'exampleApp' }
        Prg_Path = "C:\Programs\ExampleApp"
        config = [pscustomobject]@{ InstallCommand = 'install.ps1' }
    }
    Upload-Win32App @params
    Uploads the specified Win32 app to Intune.
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Provide the application object containing necessary details.")]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$Prg,
    
        [Parameter(Mandatory = $true, HelpMessage = "Specify the path to the program.")]
        [ValidateNotNullOrEmpty()]
        [string]$Prg_Path,
    
        [Parameter(HelpMessage = "Specify the image associated with the application (optional).")]
        [string]$Prg_img,
    
        [Parameter(HelpMessage = "Specify the root path where the Win32 apps are stored (optional).")]
        [string]$Win32AppsRootPath,
    
        [Parameter(HelpMessage = "Provide any additional lines to add (optional).")]
        [string]$linetoadd,
    
        [Parameter(Mandatory = $true, HelpMessage = "Provide the configuration object for command lines.")]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$config
    )
    

    Begin {
        Write-EnhancedLog -Message "Starting Upload-Win32App function" -Level "Notice"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters

        # Check if running in PowerShell 5
        if ($PSVersionTable.PSVersion.Major -ne 5) {
            Write-EnhancedLog -Message "This script must be run in PowerShell 5. Please switch to PowerShell 5 and rerun the script." -Level "ERROR"
            throw "PowerShell 5 is required for this operation. Halting script execution."
        }

        Write-EnhancedLog -Message "Validated PowerShell 5 environment" -Level "INFO"
    }

    Process {
        try {
            if ($PSCmdlet.ShouldProcess("Win32 app: $($Prg.name)", "Upload to Intune")) {
                Write-EnhancedLog -Message "Uploading: $($Prg.name)" -Level "WARNING"
    
                # Set the install and uninstall command lines
                $InstallCommandLines = Set-InstallCommandLine -config $config
    
                # Log parameters
                Log-Params -Params @{
                    Prg      = $Prg
                    Prg_Path = $Prg_Path
                    Prg_img  = $Prg_img
                }
    
                # Prepare paths for the application
                $paths = Prepare-Paths -Prg $Prg -Prg_Path $Prg_Path -Win32AppsRootPath $Win32AppsRootPath
    
                # Splatting for Create-IntuneWinPackage
                $createIntuneWinParams = @{
                    Prg             = $Prg
                    Prg_Path        = $Prg_Path
                    destinationPath = $paths.destinationPath
                }
                $IntuneWinFile = Create-IntuneWinPackage @createIntuneWinParams
    
                # Splatting for Upload-IntuneWinPackage
                $uploadParams = @{
                    Prg                  = $Prg
                    Prg_Path             = $Prg_Path
                    Prg_img              = $Prg_img
                    config               = $config
                    IntuneWinFile        = $IntuneWinFile
                    InstallCommandLine   = $InstallCommandLines.InstallCommandLine
                    UninstallCommandLine = $InstallCommandLines.UninstallCommandLine
                }
                Upload-IntuneWinPackage @uploadParams
            }
            else {
                Write-EnhancedLog -Message "Operation skipped due to WhatIf or confirmation." -Level "INFO"
            }
        }
        catch {
            Write-EnhancedLog -Message "Error during Upload-Win32App: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
        finally {
            Write-EnhancedLog -Message "Exiting Upload-Win32App function" -Level "Notice"
        }
    }
    

    End {
        Write-EnhancedLog -Message "Upload-Win32App completed successfully for $($Prg.name)" -Level "INFO"
    }
}
