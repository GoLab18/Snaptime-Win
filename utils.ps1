<#
.SYNOPSIS
    Utility functions used by snapshot and cleanup scripts.

.DESCRIPTION
    Contains helper functions like Require-Admin which checks for administrator rights
    and exits the script if the current user lacks sufficient privileges.
#>

function Require-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "Must be run as administrator!"
        exit 1
    }
}
