function Upload-IntuneWinPackage {
    <#
    .SYNOPSIS
    Uploads the Win32 Intune package and assigns it to all users.

    .DESCRIPTION
    This function uploads a specified Win32 Intune package, logs the process, and assigns the app to all users. It handles errors and logs all parameters excluding sensitive data like the app icon.

    .PARAMETER Prg
    The program object containing metadata like the name of the program.

    .PARAMETER Prg_Path
    The path where the program resides.

    .PARAMETER Prg_img
    The path to the program's image.

    .PARAMETER config
    The configuration object required for uploading the Win32 Intune package.

    .PARAMETER IntuneWinFile
    The path to the .intunewin file.

    .PARAMETER InstallCommandLine
    The command line to install the app.

    .PARAMETER UninstallCommandLine
    The command line to uninstall the app.

    .EXAMPLE
    Upload-IntuneWinPackage -Prg $Prg -Prg_Path "C:\Path\To\App" -Prg_img "C:\Path\To\Image.png" -config $config -IntuneWinFile "C:\Path\To\Package.intunewin" -InstallCommandLine "install.cmd" -UninstallCommandLine "uninstall.cmd"
    Uploads the Win32 Intune package and assigns it to all users.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Provide the program object.")]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$Prg,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the program path.")]
        [ValidateNotNullOrEmpty()]
        [string]$Prg_Path,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the program image.")]
        [ValidateNotNullOrEmpty()]
        [string]$Prg_img,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the configuration object.")]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$config,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the IntuneWin file path.")]
        [ValidateNotNullOrEmpty()]
        [string]$IntuneWinFile,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the install command line.")]
        [ValidateNotNullOrEmpty()]
        [string]$InstallCommandLine,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the uninstall command line.")]
        [ValidateNotNullOrEmpty()]
        [string]$UninstallCommandLine
    )

    Begin {
        Write-EnhancedLog -Message "Starting Upload-IntuneWinPackage function for program: $($Prg.Name)" -Level "INFO"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            # Set display name
            $DisplayName = "$($Prg.Name)"
            Write-EnhancedLog -Message "DisplayName set: $DisplayName" -Level "INFO"

            # Create detection rule, requirement rule, and set app icon
            $DetectionRule = Create-DetectionRule -Prg_Path $Prg_Path
            $RequirementRule = Create-RequirementRule
            $Icon = Set-AppIcon -Prg_img $Prg_img

            # Splatting for Intune app parameters
            $IntuneAppParams = @{
                FilePath                 = $IntuneWinFile
                Icon                     = $Icon
                DisplayName              = "$DisplayName ($($config.InstallExperience))"
                Description              = "$DisplayName ($($config.InstallExperience))"
                Publisher                = $config.Publisher
                AppVersion               = $config.AppVersion
                Developer                = $config.Developer
                Owner                    = $config.Owner
                CompanyPortalFeaturedApp = [System.Convert]::ToBoolean($config.CompanyPortalFeaturedApp)
                InstallCommandLine       = $InstallCommandLine
                UninstallCommandLine     = $UninstallCommandLine
                InstallExperience        = $config.InstallExperience
                RestartBehavior          = $config.RestartBehavior
                DetectionRule            = $DetectionRule
                RequirementRule          = $RequirementRule
                InformationURL           = $config.InformationURL
                PrivacyURL               = $config.PrivacyURL
                Verbose                  = $true
            }

            # Log the parameters excluding the Icon
            $IntuneAppParamsForLogging = [ordered]@{}
            foreach ($key in $IntuneAppParams.Keys) {
                if ($key -ne 'Icon') {
                    $IntuneAppParamsForLogging[$key] = $IntuneAppParams[$key]
                }
            }
            Log-Params -Params $IntuneAppParamsForLogging

            Write-EnhancedLog -Message "Calling Add-IntuneWin32App with IntuneAppParams - in progress" -Level "WARNING"
            $Win32App = Add-IntuneWin32App @IntuneAppParams
            Write-EnhancedLog -Message "Win32 app added successfully. App ID: $($Win32App.id)" -Level "INFO"

            Write-EnhancedLog -Message "Assigning Win32 app to all users..." -Level "WARNING"
            Add-IntuneWin32AppAssignmentAllUsers -ID $Win32App.id -Intent "available" -Notification "showAll" -Verbose
            Write-EnhancedLog -Message "Assignment completed successfully." -Level "INFO"
        }
        catch {
            Write-EnhancedLog -Message "Error during IntuneWin32 app process: $($_.Exception.Message)" -Level "ERROR"
            Write-Host "Error during IntuneWin32 app process: $($_.Exception.Message)" -ForegroundColor Red
            exit
        }
    }

    End {
        Write-EnhancedLog -Message "Completed Upload-IntuneWinPackage function for program: $($Prg.Name)" -Level "INFO"
    }
}
