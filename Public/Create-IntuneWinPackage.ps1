function Create-IntuneWinPackage {
    <#
    .SYNOPSIS
    Creates a .intunewin package for a specified program.

    .DESCRIPTION
    This function creates a .intunewin package by packaging the source folder and setup file. It logs the process and handles errors. The resulting package path is returned.

    .PARAMETER Prg
    The program object containing metadata like the program name.

    .PARAMETER Prg_Path
    The path to the program source folder.

    .PARAMETER destinationPath
    The destination path where the .intunewin package will be created.

    .EXAMPLE
    $IntuneWinFile = Create-IntuneWinPackage -Prg $Prg -Prg_Path "C:\Path\To\Program" -destinationPath "C:\Path\To\Destination"
    Creates the .intunewin package and returns the file path.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Provide the program object.")]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$Prg,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the program source path.")]
        [ValidateNotNullOrEmpty()]
        [string]$Prg_Path,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the destination path for the package.")]
        [ValidateNotNullOrEmpty()]
        [string]$destinationPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Create-IntuneWinPackage function for program: $($Prg.Name)" -Level "INFO"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            Write-EnhancedLog -Message "Creating .intunewin package..." -Level "INFO"

            $setupFile = "install.ps1"



            #Option 1: using SvRooij.ContentPrep.Cmdlet Module

            # Use New-IntuneWinPackage to create the package
            # New-IntuneWinPackage -SourcePath $Prg_Path -DestinationPath $destinationPath -SetupFile $setupFile -Verbose



            #Option 2: using IntuneWin32App Module

            # Splatting for New-IntuneWin32AppPackage
            $NewIntuneWinPackageParams = @{
                SourceFolder = $Prg_Path
                SetupFile    = $setupFile
                OutputFolder = $destinationPath
                Verbose      = $true
                Force        = $true
            }

            # Use New-IntuneWin32AppPackage to create the package
            $Win32AppPackage = New-IntuneWin32AppPackage @NewIntuneWinPackageParams

            Write-EnhancedLog -Message "Package creation completed successfully." -Level "INFO"

            # Set the IntuneWin file path
            $IntuneWinFile = Join-Path -Path $destinationPath -ChildPath "install.intunewin"
            Write-EnhancedLog -Message "IntuneWinFile path set: $IntuneWinFile" -Level "INFO"

            # Return the path of the created package
            return $IntuneWinFile
        }
        catch {
            Write-EnhancedLog -Message "Error creating .intunewin package: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            Write-Host "Error creating .intunewin package: $($_.Exception.Message)" -ForegroundColor Red
            throw
        }
    }

    End {
        Write-EnhancedLog -Message "Completed Create-IntuneWinPackage function for program: $($Prg.Name)" -Level "INFO"

        # Print summary report
        Write-Host "Summary Report" -ForegroundColor Green
        Write-Host "-----------------" -ForegroundColor Green
        Write-Host "Program Name: $($Prg.Name)" -ForegroundColor Green
        Write-Host "Source Path: $Prg_Path" -ForegroundColor Green
        Write-Host "Destination Path: $destinationPath" -ForegroundColor Green
        Write-Host "IntuneWinFile: $IntuneWinFile" -ForegroundColor Green
    }
}
