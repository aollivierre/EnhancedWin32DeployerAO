function Create-DetectionRule {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prg_Path
    )

    Write-EnhancedLog -Message "Creating detection rule..." -Level "WARNING"
    $detectionScriptPath = Join-Path -Path $Prg_Path -ChildPath "check.ps1"
    if (-not (Test-Path -Path $detectionScriptPath)) {
        Write-Warning "Detection rule script file does not exist at path: $detectionScriptPath"
    }
    else {
        $DetectionRule = New-IntuneWin32AppDetectionRuleScript -ScriptFile $detectionScriptPath -EnforceSignatureCheck $false -RunAs32Bit $false
    }
    Write-EnhancedLog -Message "Detection rule set (calling New-IntuneWin32AppDetectionRuleScript) - done" -Level "INFO"

    return $DetectionRule
}