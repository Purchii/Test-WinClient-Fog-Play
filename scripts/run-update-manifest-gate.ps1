param(
    [string] $PolicyPath,

    [switch] $DryRun,

    [switch] $AllowNetwork,

    [switch] $AllowExecution,

    [switch] $AllowRollback,

    [switch] $AllowCredentials,

    [switch] $ReportOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot 'src/TestFramework/UpdateManifest/UpdateManifest.psm1'
Import-Module $modulePath -Force

if ([string]::IsNullOrWhiteSpace($PolicyPath)) {
    $PolicyPath = Join-Path $repoRoot 'testdata/update-manifest.example.json'
}

if (-not $DryRun) {
    throw 'Update manifest gate is dry-run only.'
}
if ($AllowNetwork) {
    throw 'Network downloads are forbidden in update manifest validation.'
}
if ($AllowExecution) {
    throw 'Updater or installer execution is forbidden in update manifest validation.'
}
if ($AllowRollback) {
    throw 'Rollback execution is forbidden in update manifest validation.'
}
if ($AllowCredentials) {
    throw 'Credentials are forbidden in update manifest validation.'
}

$policy = Read-UpdateManifestPolicy -Path $PolicyPath
$result = Test-UpdateManifestPolicy -Policy $policy -DryRun:$DryRun
$result | ConvertTo-Json -Depth 10

$failFindings = @($result.findings | Where-Object { $_.severity -eq 'fail' })
if ($failFindings.Count -gt 0 -and -not $ReportOnly) {
    throw "Update manifest gate failed with $($failFindings.Count) fail finding(s)."
}
