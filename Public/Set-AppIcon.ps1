
function Set-AppIcon {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prg_img
    )

    $Icon = New-IntuneWin32AppIcon -FilePath $Prg_img
    Write-EnhancedLog -Message "App icon set - done" -Level "INFO"

    return $Icon
}
