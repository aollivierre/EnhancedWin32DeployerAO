function Upload-IntuneWinPackage {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Prg,

        [Parameter(Mandatory = $true)]
        [string]$Prg_Path,

        [Parameter(Mandatory = $true)]
        [string]$Prg_img,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$config,

        [Parameter(Mandatory = $true)]
        [string]$IntuneWinFile,

        [Parameter(Mandatory = $true)]
        [string]$InstallCommandLine,

        [Parameter(Mandatory = $true)]
        [string]$UninstallCommandLine
    )

    try {
        $DisplayName = "$($Prg.Name)"
        Write-EnhancedLog -Message "DisplayName set: $DisplayName" -Level "INFO"

        $DetectionRule = Create-DetectionRule -Prg_Path $Prg_Path
        $RequirementRule = Create-RequirementRule
        $Icon = Set-AppIcon -Prg_img $Prg_img

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

        # Log-Params -Params $IntuneAppParams

        # Create a copy of $IntuneAppParams excluding the $Icon
        $IntuneAppParamsForLogging = $IntuneAppParams.Clone()
        $IntuneAppParamsForLogging.Remove('Icon')

        Log-Params -Params $IntuneAppParamsForLogging

        Write-EnhancedLog -Message "Calling Add-IntuneWin32App with IntuneAppParams - in progress" -Level "WARNING"
        $Win32App = Add-IntuneWin32App @IntuneAppParams
        Write-EnhancedLog -Message "Win32 app added successfully. App ID: $($Win32App.id)" -Level "INFO"

        Write-EnhancedLog -Message "Assigning Win32 app to all users..." -Level "WARNING"
        Add-IntuneWin32AppAssignmentAllUsers -ID $Win32App.id -Intent "available" -Notification "showAll" -Verbose
        Write-EnhancedLog -Message "Assignment completed successfully." -Level "INFO"
    }
    catch {
        Write-EnhancedLog -Message "Error during IntuneWin32 app process: $_" -Level "ERROR"
        Write-Host "Error during IntuneWin32 app process: $_" -ForegroundColor Red
        exit
    }
}