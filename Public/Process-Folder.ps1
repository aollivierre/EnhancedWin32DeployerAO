function Process-Folder {
    <#
    .SYNOPSIS
    Processes a folder by handling printer installations and Win32 app configurations.

    .DESCRIPTION
    This function processes a folder by checking for the presence of a printer configuration file (`printer.json`) and, if found, processes the printer installation. It also processes Win32 app configurations based on the provided folder and configuration object. The function returns an object with details about the folder processing and prints a summary report at the end with counts and color-coded statuses.

    .PARAMETER Folder
    The folder to be processed, which may contain a `printer.json` file for printer installation.

    .PARAMETER config
    The configuration object required for Win32 app processing.

    .PARAMETER Repo_winget
    The path to the repository (winget) where the program source resides.

    .PARAMETER scriptpath
    The path to the script that is being executed.

    .EXAMPLE
    $folderDetails = Process-Folder -Folder (Get-Item "C:\Apps\MyApp") -config $config -Repo_winget "C:\Repo\winget" -scriptpath "C:\path\to\script"
    Processes the folder and returns the folder processing details.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Provide the folder to be processed.")]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo]$Folder,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the configuration for the Win32 app.")]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$config,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the path to the winget repository.")]
        [ValidateNotNullOrEmpty()]
        [string]$Repo_winget,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the path to the script being executed.")]
        [ValidateNotNullOrEmpty()]
        [string]$scriptpath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Process-Folder function for folder: $($Folder.Name)" -Level "INFO"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters

        # Initialize counters and app status list
        $totalApps = 0
        $successfulApps = 0
        $failedApps = 0
        $appStatuses = [System.Collections.Generic.List[PSCustomObject]]::new()
    }

    Process {
        try {
            # Initialize a variable to track if printer installation was processed
            $printerProcessed = $false
            $printerCommands = $null

            # Create a copy of the config object to modify
            $localConfig = $config.PSObject.Copy()

            # Construct the path to the printer.json within the current folder
            $printerConfigPath = Join-Path -Path $Folder.FullName -ChildPath "printer.json"
            $appConfigPath = Join-Path -Path $Folder.FullName -ChildPath "config.json"

            if (Test-Path -Path $printerConfigPath) {
                Write-EnhancedLog -Message "printer.json found in folder: $($Folder.Name). Processing printer installation." -Level "INFO"
                $printerCommands = Process-PrinterInstallation -PrinterConfigPath $printerConfigPath -AppConfigPath $appConfigPath
                Write-EnhancedLog -Message "Processed printer installation for folder: $($Folder.Name)" -Level "INFO"
                $printerProcessed = $true

                # Update the config object with printer-specific commands if printer installation was processed
                if ($printerProcessed -and $printerCommands) {
                    Write-EnhancedLog -Message "Setting printer-specific install command: $($printerCommands.InstallCommand)" -Level "INFO"
                    Write-EnhancedLog -Message "Setting printer-specific uninstall command: $($printerCommands.UninstallCommand)" -Level "INFO"
                    
                    $localConfig | Add-Member -NotePropertyName 'InstallCommandLine' -NotePropertyValue $printerCommands.InstallCommand -Force
                    $localConfig | Add-Member -NotePropertyName 'UninstallCommandLine' -NotePropertyValue $printerCommands.UninstallCommand -Force
                    $localConfig | Add-Member -NotePropertyName 'PrinterInstall' -NotePropertyValue $true -Force
                }
            }
            else {
                Write-EnhancedLog -Message "printer.json not found in folder: $($Folder.Name)" -Level "WARNING"
            }

            # Process Win32 app and get the details
            Write-EnhancedLog -Message "Processing Win32 app configuration for folder: $($Folder.Name)" -Level "INFO"
            $totalApps++

            try {
                # Pass the modified config object to Process-Win32App
                $appDetails = Process-Win32App -Folder $Folder -config $localConfig -Repo_winget $Repo_winget -scriptpath $scriptpath
                Write-EnhancedLog -Message "Successfully processed Win32 app: $($Folder.Name)" -Level "INFO"
                $successfulApps++
                $appStatuses.Add([pscustomobject]@{ AppName = $Folder.Name; Status = "Success" })
            }
            catch {
                Write-EnhancedLog -Message "Failed to process Win32 app: $($Folder.Name)" -Level "ERROR"
                $failedApps++
                $appStatuses.Add([pscustomobject]@{ AppName = $Folder.Name; Status = "Failed" })
            }

            # Build the return object
            $folderDetails = [pscustomobject]@{
                FolderName       = $Folder.Name
                PrinterProcessed = $printerProcessed
                PrinterCommands  = $printerCommands
                AppDetails       = $appDetails
            }

            return $folderDetails
        }
        catch {
            Write-EnhancedLog -Message "Error occurred during folder processing: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }

    End {
        Write-EnhancedLog -Message "Completed Process-Folder function for folder: $($Folder.Name)" -Level "INFO"

        # Print final summary report
        Write-Host "Final Summary Report" -ForegroundColor Green
        Write-Host "---------------------" -ForegroundColor Green
        Write-Host "Total Apps Processed: $totalApps" -ForegroundColor Green
        Write-Host "Successful Apps: $successfulApps" -ForegroundColor Green
        Write-Host "Failed Apps: $failedApps" -ForegroundColor Red

        foreach ($appStatus in $appStatuses) {
            if ($appStatus.Status -eq "Success") {
                Write-Host "App: $($appStatus.AppName) - Status: $($appStatus.Status)" -ForegroundColor Green
            }
            else {
                Write-Host "App: $($appStatus.AppName) - Status: $($appStatus.Status)" -ForegroundColor Red
            }
        }
    }
}

# Example Usage:
# $folderDetails = Process-Folder -Folder (Get-Item "C:\Apps\MyApp") -config $config -Repo_winget "C:\Repo\winget" -scriptpath "C:\path\to\script"

