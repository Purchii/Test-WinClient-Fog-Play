param(
    [string] $PolicyPath,

    [switch] $DryRun,

    [switch] $AllowProductionAction,

    [switch] $AllowCredentials,

    [switch] $AllowRuntimeUserData,

    [switch] $ReportOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot 'src/TestFramework/TestabilityGaps/TestabilityGaps.psm1'
Import-Module $modulePath -Force

if ([string]::IsNullOrWhiteSpace($PolicyPath)) {
    $PolicyPath = Join-Path $repoRoot 'testdata/testability-gaps.example.json'
}

if (-not $DryRun) {
    throw 'Testability gaps gate is dry-run only.'
}
if ($AllowProductionAction) {
    throw 'Production actions are forbidden in testability gap tracking.'
}
if ($AllowCredentials) {
    throw 'Credentials are forbidden in testability gap tracking.'
}
if ($AllowRuntimeUserData) {
    throw 'Runtime user data reads are forbidden in testability gap tracking.'
}

$policy = Read-TestabilityGapsPolicy -Path $PolicyPath
$result = Test-TestabilityGapsPolicy -Policy $policy -DryRun:$DryRun
$result | ConvertTo-Json -Depth 10

$failFindings = @($result.findings | Where-Object { $_.severity -eq 'fail' })
if ($failFindings.Count -gt 0 -and -not $ReportOnly) {
    throw "Testability gaps gate failed with $($failFindings.Count) fail finding(s)."
}
