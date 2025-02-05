function Check-ApplicationImage {
    <#
    .SYNOPSIS
    Checks for the presence of any PNG image in the program folder and handles missing icons with user interaction.

    .DESCRIPTION
    This function looks for any PNG image in the folder where the program resides. If no image is found, it prompts the user to:
    1. Browse for a PNG file
    2. Use a default template image
    3. Skip the icon
    The function returns an object containing the image path and related details.

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
            # Validate program path
            if (-not (Test-Path -Path $Prg_Path)) {
                Write-EnhancedLog -Message "Program path does not exist: $Prg_Path" -Level "ERROR"
                throw "Program path does not exist: $Prg_Path"
            }

            # Look for PNG image with program ID first
            $imagePath = Join-Path -Path $Prg_Path -ChildPath "$($Prg.id).png"
            $imageFound = Test-Path -Path $imagePath

            # If not found, search for any PNG
            if (-not $imageFound) {
                $imageFiles = Get-ChildItem -Path $Prg_Path -Filter "*.png" -ErrorAction Stop
                if ($imageFiles.Count -gt 0) {
                    $imagePath = $imageFiles[0].FullName
                    $imageFound = $true
                    Write-EnhancedLog -Message "Found alternative PNG image: $imagePath" -Level "INFO"
                }
            }

            if ($imageFound) {
                Write-EnhancedLog -Message "Application image found: $imagePath" -Level "INFO"
            }
            else {
                Write-EnhancedLog -Message "No icon found for application: $($Prg.id)" -Level "WARNING"
                
                # Prompt user for action
                $title = "Application Icon Missing"
                $message = "No icon (.png) found for application: $($Prg.id)`n`nWould you like to:"
                $options = [System.Management.Automation.Host.ChoiceDescription[]] @(
                    New-Object System.Management.Automation.Host.ChoiceDescription "&Browse", "Browse for a PNG file"
                    New-Object System.Management.Automation.Host.ChoiceDescription "&Default", "Use default icon"
                    New-Object System.Management.Automation.Host.ChoiceDescription "&Skip", "Skip icon and continue"
                )
                
                $result = $host.UI.PromptForChoice($title, $message, $options, 1)
                
                switch ($result) {
                    0 { # Browse for PNG
                        Add-Type -AssemblyName System.Windows.Forms
                        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
                        $openFileDialog.Filter = "PNG files (*.png)|*.png|All files (*.*)|*.*"
                        $openFileDialog.Title = "Select an icon for $($Prg.id)"
                        $openFileDialog.InitialDirectory = [Environment]::GetFolderPath('MyPictures')
                        
                        if ($openFileDialog.ShowDialog() -eq 'OK') {
                            # Copy selected file to app directory with correct name
                            $selectedFile = $openFileDialog.FileName
                            $imagePath = Join-Path -Path $Prg_Path -ChildPath "$($Prg.id).png"
                            Copy-Item -Path $selectedFile -Destination $imagePath -Force
                            Write-EnhancedLog -Message "Custom image copied to: $imagePath" -Level "INFO"
                            $imageFound = $true
                        }
                        else {
                            Write-EnhancedLog -Message "User cancelled file selection, using default icon" -Level "INFO"
                            $imagePath = Join-Path -Path $Repo_Path -ChildPath "resources\template\winget\winget-managed.png"
                            $imageFound = $false
                        }
                    }
                    1 { # Use default
                        $imagePath = Join-Path -Path $Repo_Path -ChildPath "resources\template\winget\winget-managed.png"
                        Write-EnhancedLog -Message "Using default image at: $imagePath" -Level "INFO"
                        $imageFound = $false
                    }
                    2 { # Skip
                        Write-EnhancedLog -Message "User chose to skip icon" -Level "INFO"
                        $imagePath = $null
                        $imageFound = $false
                    }
                }
            }

            # Return the image details as an object
            $imageDetails = [PSCustomObject]@{
                ProgramID     = $Prg.id
                ImagePath     = $imagePath
                ImageFound    = $imageFound
                IsCustomIcon  = ($imageFound -and $imagePath -notlike "*\resources\template\winget\*")
                IsDefaultIcon = ($imagePath -like "*\resources\template\winget\*")
                IsSkipped     = ($null -eq $imagePath)
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

