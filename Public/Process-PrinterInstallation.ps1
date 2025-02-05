function Process-PrinterInstallation {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PrinterConfigPath,
        
        [Parameter(Mandatory = $true)]
        [string]$AppConfigPath
    )

    # Clear any existing global variables
    Remove-Variable -Name "InstallCommandLine" -Scope Global -ErrorAction SilentlyContinue
    Remove-Variable -Name "UninstallCommandLine" -Scope Global -ErrorAction SilentlyContinue

    # Read and parse the printer configuration
    $printerConfig = Get-Content -Path $PrinterConfigPath -Raw | ConvertFrom-Json

    # Construct the install and uninstall commands
    $installCommand = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -File `"install.ps1`" " +
        "-PrinterName `"$($printerConfig.PrinterName)`" " +
        "-PrinterIPAddress `"$($printerConfig.PrinterIPAddress)`" " +
        "-PortName `"$($printerConfig.PortName)`" " +
        "-DriverName `"$($printerConfig.DriverName)`" " +
        "-InfPathRelative `"$($printerConfig.InfPathRelative)`" " +
        "-InfFileName `"$($printerConfig.InfFileName)`" " +
        "-DriverIdentifier `"$($printerConfig.DriverIdentifier)`""

    $uninstallCommand = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -File `"uninstall.ps1`" " +
        "-PrinterName `"$($printerConfig.PrinterName)`" " +
        "-PrinterIPAddress `"$($printerConfig.PrinterIPAddress)`" " +
        "-PortName `"$($printerConfig.PortName)`" " +
        "-DriverName `"$($printerConfig.DriverName)`" " +
        "-InfPathRelative `"$($printerConfig.InfPathRelative)`" " +
        "-InfFileName `"$($printerConfig.InfFileName)`" " +
        "-DriverIdentifier `"$($printerConfig.DriverIdentifier)`""

    # Set the global variables for the install and uninstall commands
    $global:InstallCommandLine = $installCommand
    $global:UninstallCommandLine = $uninstallCommand

    Write-EnhancedLog -Message "Setting printer-specific command lines" -Level "INFO"
    Write-EnhancedLog -Message "Install Command: $installCommand" -Level "INFO"
    Write-EnhancedLog -Message "Uninstall Command: $uninstallCommand" -Level "INFO"

    # Return the commands object for compatibility with existing code
    return @{
        InstallCommand = $installCommand
        UninstallCommand = $uninstallCommand
    }
}