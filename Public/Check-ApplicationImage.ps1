function Check-ApplicationImage {
    <#
    .SYNOPSIS
    Checks for the presence of any PNG image in the program folder.

    .DESCRIPTION
    This function looks for any PNG image in the folder where the program resides. If found, it assigns the image path to the variable `$Prg_img`. If no image is found, a default template image is assigned. The function returns an object containing the image path.

    .PARAMETER Prg
    The program object containing metadata like the program ID.

    .PARAMETER Prg_Path
    The path to the program folder where the PNG image is searched.

    .EXAMPLE
    $imageDetails = Check-ApplicationImage -Prg $Prg -Prg_Path "C:\Repo\MyApp"
    Checks for any PNG image in the folder and returns the image details.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Provide the program object.")]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$Prg,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the path to the program folder.")]
        [ValidateNotNullOrEmpty()]
        [string]$Prg_Path
    )

    Begin {
        Write-EnhancedLog -Message "Starting Check-ApplicationImage function for program: $($Prg.id)" -Level "INFO"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            # Search for any .png file in the program folder
            $imageFiles = Get-ChildItem -Path $Prg_Path -Filter "*.png" -ErrorAction Stop

            if ($imageFiles.Count -gt 0) {
                # Use the first PNG found in the folder
                $Prg_img = $imageFiles[0].FullName
                Write-EnhancedLog -Message "Application image found: $Prg_img" -Level "INFO"
            }
            else {
                # Assign default image if no PNG found
                $Prg_img = Join-Path -Path $Repo_Path -ChildPath "resources\template\winget\winget-managed.png"
                Write-EnhancedLog -Message "No PNG found. Using default image: $Prg_img" -Level "INFO"
            }

            # Return the image path details as an object
            $imageDetails = [pscustomobject]@{
                ProgramID  = $Prg.id
                ImagePath  = $Prg_img
                ImageFound = ($imageFiles.Count -gt 0)
            }

            return $imageDetails
        }
        catch {
            Write-EnhancedLog -Message "Error occurred during image check: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }

    End {
        Write-EnhancedLog -Message "Completed Check-ApplicationImage function for program: $($Prg.id)" -Level "INFO"
    }
}



# # Run Check-ApplicationImage and store the returned object
# $imageDetails = Check-ApplicationImage -Prg $Prg

# # Access the properties of the returned object
# Write-Host "Program ID: $($imageDetails.ProgramID)"
# Write-Host "Image Path: $($imageDetails.ImagePath)"
# Write-Host "Image Found: $($imageDetails.ImageFound)"

