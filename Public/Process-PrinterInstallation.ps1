function Process-PrinterInstallation {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PrinterConfigPath
    )

    $commands = Invoke-PrinterInstallation -PrinterConfigPath $PrinterConfigPath -AppConfigPath $configPath
    Write-EnhancedLog -Message "Install Command: $($commands.InstallCommand)"
    Write-EnhancedLog -Message "Uninstall Command: $($commands.UninstallCommand)"
    
    $global:InstallCommandLine = $commands.InstallCommand
    $global:UninstallCommandLine = $commands.UninstallCommand
}