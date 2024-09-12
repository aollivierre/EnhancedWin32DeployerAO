function Compile-Win32_intunewin {
    <#
    .SYNOPSIS
    Compiles a Win32 app into an Intune Win format for deployment.

    .DESCRIPTION
    This function compiles a Win32 application into an Intune Win32 format. It checks for an existing application image, downloads the latest IntuneWinAppUtil if necessary, and uploads the compiled application.

    .PARAMETER Prg
    The application object with details needed for compilation.

    .PARAMETER Repo_winget
    The repository path for winget.

    .PARAMETER Repo_Path
    The repository path for storing resources.

    .PARAMETER Prg_Path
    The path to the program being compiled.

    .EXAMPLE
    $params = @{
        Prg = [pscustomobject]@{ id = 'exampleApp'; name = 'Example' }
        Repo_winget = "https://example.com/winget"
        Repo_Path = "C:\Repos"
        Prg_Path = "C:\Programs\ExampleApp"
    }
    Compile-Win32_intunewin @params
    Compiles the Win32 app and uploads it to Intune.
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Provide the application object containing necessary details.")]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$Prg,
    
        [Parameter(Mandatory = $true, HelpMessage = "Specify the Winget repository URL.")]
        [ValidateNotNullOrEmpty()]
        [string]$Repo_winget,
    
        [Parameter(Mandatory = $true, HelpMessage = "Specify the path to the repository for storing resources.")]
        [ValidateNotNullOrEmpty()]
        [string]$Repo_Path,
    
        [Parameter(Mandatory = $true, HelpMessage = "Provide the path to the program.")]
        [ValidateNotNullOrEmpty()]
        [string]$Prg_Path
    )
    
    

    Begin {
        Write-EnhancedLog -Message "Starting Compile-Win32_intunewin function" -Level "Notice"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters

        # Check for the program image
        Write-EnhancedLog -Message "Checking for program image for $($Prg.id)" -Level "INFO"
        $Prg_img = if (Test-Path -Path (Join-Path -Path $Prg_Path -ChildPath "$($Prg.id).png")) {
            Join-Path -Path $Prg_Path -ChildPath "$($Prg.id).png"
        }
        else {
            "$Repo_Path\resources\template\winget\winget-managed.png"
        }
    }

    Process {
        if ($PSCmdlet.ShouldProcess("Win32 App Compilation for $($Prg.id)", "Uploading to Intune")) {
            try {
                Write-EnhancedLog -Message "Processing Win32 app: $($Prg.id)" -Level "INFO"
                # Log the program path and image path
                Write-EnhancedLog -Message "Program path: $Prg_Path" -Level "INFO"
                Write-EnhancedLog -Message "Program image: $Prg_img" -Level "INFO"
    
                # Upload the Win32 app
                Write-EnhancedLog -Message "Uploading Win32 app to Intune" -Level "INFO"
                # Upload-Win32App -Prg $Prg -Prg_Path $Prg_Path -Prg_img $Prg_img

                # Calling Upload-Win32App inside PowerShell 5
                Invoke-CommandInPS5 -Command "Upload-Win32App -Prg $Prg -Prg_Path $Prg_Path -Prg_img $Prg_img"
            }
            catch {
                Write-EnhancedLog -Message "Error during Win32 app processing: $($_.Exception.Message)" -Level "ERROR"
                Handle-Error -ErrorRecord $_
                throw
            }
        }
        else {
            Write-EnhancedLog -Message "Operation skipped due to WhatIf or confirmation." -Level "INFO"
        }
    }
    

    End {
        Write-EnhancedLog -Message "Exiting Compile-Win32_intunewin function" -Level "Notice"
    }
}
