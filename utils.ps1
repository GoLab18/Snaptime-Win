<#
.SYNOPSIS
    Utility functions used by snapshot and cleanup scripts.

.DESCRIPTION
    Contains helper functions like Require-Admin which checks for administrator rights
    and exits the script if the current user lacks sufficient privileges.
    Also contains a helper to test if diskshadow.exe is available.
#>

function Require-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)

    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This script must be run as Administrator."
        exit 1
    }
}

function Test-DiskShadowAvailable {
    $dsPath = Join-Path $env:WINDIR "System32\diskshadow.exe"
    return (Test-Path $dsPath)
}
