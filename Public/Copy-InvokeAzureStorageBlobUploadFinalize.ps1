function Copy-InvokeAzureStorageBlobUploadFinalize {
    <#
    .SYNOPSIS
    Copies the AzureStorageBlobUploadFinalize script to specified destination paths.

    .DESCRIPTION
    This function copies the `Invoke-AzureStorageBlobUploadFinalize.ps1` script from the source path to multiple destination paths. It logs the success or failure of each copy operation and returns an object containing the result of each file copy. At the end, it provides a summary report with color-coded statuses.

    .PARAMETER sourceFile
    The path to the source file that needs to be copied.

    .PARAMETER destinationPaths
    An array of destination paths where the source file will be copied.

    .EXAMPLE
    $copyResults = Copy-InvokeAzureStorageBlobUploadFinalize -sourceFile "C:\Code\IntuneWin32App\Private\Invoke-AzureStorageBlobUploadFinalize.ps1" -destinationPaths @("C:\Path1", "C:\Path2")
    Processes the file copy and returns the results with a summary report.
    #>

    [CmdletBinding()]
    param (
        [string]$sourceFile = "C:\Code\IntuneWin32App\Private\Invoke-AzureStorageBlobUploadFinalize.ps1",
        [string[]]$destinationPaths = @(
            "C:\Program Files\WindowsPowerShell\Modules\IntuneWin32App\1.4.4\Private\Invoke-AzureStorageBlobUploadFinalize.ps1"
        )
    )

    Begin {
        Write-EnhancedLog -Message "Starting the file copy process..." -Level "INFO"

        # Initialize counters and status list
        $totalCopies = 0
        $successfulCopies = 0
        $failedCopies = 0
        $copyStatuses = [System.Collections.Generic.List[PSCustomObject]]::new()  # Efficient list initialization
    }

    Process {
        foreach ($destination in $destinationPaths) {
            try {
                Write-EnhancedLog -Message "Copying file to $destination" -Level "INFO"
                $totalCopies++

                # Splatting Copy-Item parameters
                $CopyItemParams = @{
                    Path        = $sourceFile
                    Destination = $destination
                    Force       = $true
                }

                Copy-Item @CopyItemParams
                Write-EnhancedLog -Message "Successfully copied to $destination" -Level "INFO"
                $successfulCopies++
                $copyStatuses.Add([pscustomobject]@{ Destination = $destination; Status = "Success" })
            }
            catch {
                Write-EnhancedLog -Message "Failed to copy to $destination. Error: $_" -Level "ERROR"
                Handle-Error -ErrorRecord $_
                $failedCopies++
                $copyStatuses.Add([pscustomobject]@{ Destination = $destination; Status = "Failed" })
            }
        }
    }

    End {
        Write-EnhancedLog -Message "File copy process completed." -Level "INFO"

        # Return object with summary of copy operations
        $copyResults = [pscustomobject]@{
            TotalCopies       = $totalCopies
            SuccessfulCopies  = $successfulCopies
            FailedCopies      = $failedCopies
            CopyStatuses      = $copyStatuses
        }

        # Print final summary report
        Write-Host "Final Summary Report" -ForegroundColor Green
        Write-Host "---------------------" -ForegroundColor Green
        Write-Host "Total Copies: $totalCopies" -ForegroundColor Green
        Write-Host "Successful Copies: $successfulCopies" -ForegroundColor Green
        Write-Host "Failed Copies: $failedCopies" -ForegroundColor Red

        # Loop through copyStatuses for detailed report
        foreach ($copyStatus in $copyStatuses) {
            if ($copyStatus.Status -eq "Success") {
                Write-Host "Destination: $($copyStatus.Destination) - Status: $($copyStatus.Status)" -ForegroundColor Green
            }
            else {
                Write-Host "Destination: $($copyStatus.Destination) - Status: $($copyStatus.Status)" -ForegroundColor Red
            }
        }

        return $copyResults
    }
}

# Example Usage:
# $copyResults = Copy-InvokeAzureStorageBlobUploadFinalize -sourceFile "C:\Code\IntuneWin32App\Private\Invoke-AzureStorageBlobUploadFinalize.ps1" -destinationPaths @("C:\Path1", "C:\Path2")
# Write-Host "Total Copies: $($copyResults.TotalCopies)"
