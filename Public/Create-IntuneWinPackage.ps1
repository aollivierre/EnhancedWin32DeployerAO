function Create-IntuneWinPackage {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Prg,

        [Parameter(Mandatory = $true)]
        [string]$Prg_Path,

        [Parameter(Mandatory = $true)]
        [string]$destinationPath
    )
    try {
        Write-EnhancedLog -Message "Creating .intunewin package..." -Level "INFO"

        $setupFile = "install.ps1"
        # $Win32AppPackage = New-IntuneWin32AppPackage -SourceFolder $Prg_Path -SetupFile $setupFile -OutputFolder $destinationPath -Verbose -Force:$true

        # using New-IntuneWinPackage instead of New-IntuneWin32AppPackage because it creates a .intunewin file in a cross-platform way both on Windows and Linux
        New-IntuneWinPackage -SourcePath $Prg_Path -DestinationPath $destinationPath -SetupFile $setupFile -Verbose
        # Write-Host "Package creation completed successfully." -ForegroundColor Green
        Write-EnhancedLog -Message "Package creation completed successfully." -Level "INFO"

        $IntuneWinFile = Join-Path -Path $destinationPath -ChildPath "install.intunewin"
        
        # $IntuneWinFile = $Win32AppPackage.Path
        Write-EnhancedLog -Message "IntuneWinFile path set: $IntuneWinFile" -Level "INFO"
        return $IntuneWinFile
    }
    catch {
        Write-EnhancedLog -Message "Error creating .intunewin package: $_" -Level "ERROR"
        Write-Host "Error creating .intunewin package: $_" -ForegroundColor Red
        exit
    }
}