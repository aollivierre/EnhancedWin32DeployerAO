function Copy-InvokeAzureStorageBlobUploadFinalize {
    param (
        [string]$sourceFile = "C:\Code\IntuneWin32App\Private\Invoke-AzureStorageBlobUploadFinalize.ps1",
        [string[]]$destinationPaths = @(
            # "C:\Users\Administrator\Documents\PowerShell\Modules\IntuneWin32App\1.4.4\Private\Invoke-AzureStorageBlobUploadFinalize.ps1",
            "C:\Program Files\WindowsPowerShell\Modules\IntuneWin32App\1.4.4\Private\Invoke-AzureStorageBlobUploadFinalize.ps1"
        )
    )

    begin {
        Write-EnhancedLog -Message "Starting the file copy process..." -Level "INFO"
    }

    process {
        foreach ($destination in $destinationPaths) {
            try {
                Write-EnhancedLog -Message "Copying file to $destination" -Level "INFO"
                Copy-Item -Path $sourceFile -Destination $destination -Force
                Write-EnhancedLog -Message "Successfully copied to $destination" -Level "INFO"
            }
            catch {
                Write-EnhancedLog -Message "Failed to copy to $destination. Error: $_" -Level "ERROR"
                Handle-Error -ErrorRecord $_
            }
        }
    }

    end {
        Write-EnhancedLog -Message "File copy process completed." -Level "INFO"
    }
}