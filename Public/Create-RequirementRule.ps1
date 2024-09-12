function Create-RequirementRule {
    Write-EnhancedLog -Message "Setting minimum requirements..." -Level "WARNING"
    $RequirementRule = New-IntuneWin32AppRequirementRule -Architecture "x64" -MinimumSupportedWindowsRelease "W10_1607"
    Write-EnhancedLog -Message "Minimum requirements set - done" -Level "INFO"

    return $RequirementRule
}