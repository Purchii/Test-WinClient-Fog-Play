param(
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host 'Release gate is documented but not implemented in M0.'
if (-not $DryRun) {
    Write-Host 'No release artifacts were inspected or modified.'
}
