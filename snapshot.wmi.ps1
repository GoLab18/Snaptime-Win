<#
.SYNOPSIS
    Creates Volume Shadow Copy snapshots using WMI (Win32_ShadowCopy).

.DESCRIPTION
    For each volume specified in the configuration, creates a snapshot using the WMI Win32_ShadowCopy interface.
    Works on both Windows Client and Windows Server.
    Requires Administrator privileges.
#>

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\utils.ps1"

Require-Admin

$class = Get-CimClass Win32_ShadowCopy

foreach ($vol in $Volumes) {
    Write-Host "Creating VSS snapshot for $vol using WMI"

    $result = Invoke-CimMethod `
        -CimClass $class `
        -MethodName Create `
        -Arguments @{
            Volume  = "$vol\"
            Context = "ClientAccessible"
        }

    if ($result.ReturnValue -eq 0) {
        Write-Host "Snapshot created successfully. ShadowID = $($result.ShadowID)"
    } else {
        Write-Error "Snapshot creation failed for $vol (code $($result.ReturnValue))"
    }
}
