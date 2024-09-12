function Define-SourcePath {
    <#
    .SYNOPSIS
    Defines the source path for a given program.

    .DESCRIPTION
    This function dynamically constructs the source path for a program using the provided `Repo_winget` path and the program's ID. It logs the path and returns the path as part of an object.

    .PARAMETER Prg
    The program object containing metadata like the ID of the program.

    .PARAMETER Repo_winget
    The path to the repository (winget) where the program source resides.

    .EXAMPLE
    $sourcePathDetails = Define-SourcePath -Prg $Prg -Repo_winget "C:\Repo\winget"
    Defines the source path for the program and returns the path details.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Provide the program object.")]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$Prg,

        [Parameter(Mandatory = $true, HelpMessage = "Provide the path to the winget repository.")]
        [ValidateNotNullOrEmpty()]
        [string]$Repo_winget
    )

    Begin {
        Write-EnhancedLog -Message "Starting Define-SourcePath function for program: $($Prg.id)" -Level "INFO"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            # Construct the source path using the program ID and the Repo_winget path
            $sourcePath = Join-Path -Path $Repo_winget -ChildPath $Prg.id
            $Prg_Path = $sourcePath

            # Log the source path
            Write-EnhancedLog -Message "Source path defined: $Prg_Path" -Level "INFO"

            # Return the source path as part of an object
            return [pscustomobject]@{
                ProgramID   = $Prg.id
                SourcePath  = $sourcePath
            }
        }
        catch {
            Write-EnhancedLog -Message "Error occurred during Define-SourcePath: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }

    End {
        Write-EnhancedLog -Message "Completed Define-SourcePath function." -Level "INFO"
    }
}




# # Run Define-SourcePath and store the returned object
# Example usage of the Define-SourcePath function
# $sourcePathDetails = Define-SourcePath -Prg $Prg -Repo_winget "C:\Repo\winget"

# # Access the returned object properties
# Write-Host "Program ID: $($sourcePathDetails.ProgramID)"
# Write-Host "Source Path: $($sourcePathDetails.SourcePath)"


# Program ID: MyProgram
# Source Path: C:\path\to\Win32Apps-DropBox\MyProgram
