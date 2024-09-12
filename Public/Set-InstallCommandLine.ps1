function Set-InstallCommandLine {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$config
    )

    if ($config.serviceUIPSADT -eq $true) {
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