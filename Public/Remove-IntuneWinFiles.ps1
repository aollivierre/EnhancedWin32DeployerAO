function Remove-IntuneWinFiles {
    <#
    .SYNOPSIS
    Removes all *.intuneWin files from a specified directory.

    .DESCRIPTION
    This function searches for all files with the .intuneWin extension
    in the specified directory and removes them. It logs actions taken
    and any errors encountered using the Write-EnhancedLog function.

    .PARAMETER DirectoryPath
    The path to the directory from which *.intuneWin files will be removed.

    .EXAMPLE
    Remove-IntuneWinFiles -DirectoryPath "d:\Users\aollivierre\AppData\Local\Intune-Win32-Deployer\apps-winget"
    Removes all *.intuneWin files from the specified directory and logs the actions.

    .NOTES
    Ensure you have the necessary permissions to delete files in the specified directory.
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Provide the directory path from which *.intuneWin files will be removed.")]
        [ValidateNotNullOrEmpty()]
        [string]$DirectoryPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting to remove *.intuneWin files from $DirectoryPath recursively." -Level "INFO"

        # Validate directory existence
        if (-not (Test-Path -Path $DirectoryPath)) {
            Write-EnhancedLog -Message "Directory not found: $DirectoryPath" -Level "ERROR"
            throw "Directory not found: $DirectoryPath"
        }
    }

    Process {
        try {
            # Get the list of *.intuneWin files recursively
            Write-EnhancedLog -Message "Searching for *.intuneWin files in $DirectoryPath..." -Level "INFO"
            $files = Get-ChildItem -Path $DirectoryPath -Filter "*.intuneWin" -Recurse -ErrorAction Stop

            if ($files.Count -eq 0) {
                Write-EnhancedLog -Message "No *.intuneWin files found in $DirectoryPath." -Level "INFO"
            }
            else {
                foreach ($file in $files) {
                    if ($PSCmdlet.ShouldProcess($file.FullName, "Remove *.intuneWin file")) {
                        Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                        Write-EnhancedLog -Message "Removed file: $($file.FullName)" -Level "INFO"
                    }
                }
            }
        }
        catch {
            Write-EnhancedLog -Message "Error removing *.intuneWin files: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw $_  # Re-throwing the error for further handling
        }
    }

    End {
        Write-EnhancedLog -Message "Completed removal of *.intuneWin files from $DirectoryPath." -Level "INFO"
    }
}