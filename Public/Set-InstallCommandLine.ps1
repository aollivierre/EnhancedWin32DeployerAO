function Set-InstallCommandLine {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$config
    )

    # Check if we have printer-specific command lines set
    if ($Global:InstallCommandLine -and $Global:UninstallCommandLine) {
        Write-EnhancedLog -Message "Using printer-specific command lines" -Level "INFO"
        Write-EnhancedLog -Message "Install Command: $Global:InstallCommandLine" -Level "INFO"
        Write-EnhancedLog -Message "Uninstall Command: $Global:UninstallCommandLine" -Level "INFO"
        
        $result = @{
            InstallCommandLine   = $Global:InstallCommandLine
            UninstallCommandLine = $Global:UninstallCommandLine
        }

        # Clear the global variables after using them
        Remove-Variable -Name "InstallCommandLine" -Scope Global -ErrorAction SilentlyContinue
        Remove-Variable -Name "UninstallCommandLine" -Scope Global -ErrorAction SilentlyContinue

        return $result
    }
    # Otherwise use the standard command lines
    elseif ($config.serviceUIPSADT -eq $true) {
        $InstallCommandLine = "ServiceUI.exe -process:explorer.exe Deploy-Application.exe -DeploymentType install -Deploymode Interactive"
        $UninstallCommandLine = "ServiceUI.exe -process:explorer.exe Deploy-Application.exe -DeploymentType Uninstall -Deploymode Interactive"
    }
    elseif ($config.PSADT -eq $true) {
        $InstallCommandLine = "Deploy-Application.exe -DeploymentType install -DeployMode Interactive"
        $UninstallCommandLine = "Deploy-Application.exe -DeploymentType Uninstall -DeployMode Interactive"
    }
    else {
        $InstallCommandLine = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -command .\install.ps1"
        $UninstallCommandLine = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -command .\uninstall.ps1"
    }

    return @{
        InstallCommandLine   = $InstallCommandLine
        UninstallCommandLine = $UninstallCommandLine
    }
}