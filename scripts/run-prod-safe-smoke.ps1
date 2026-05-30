param(
    [ValidateSet('local', 'staging', 'production')]
    [string] $Environment = 'production',

    [string] $TestMetadataPath,

    [string] $SyntheticUsersPath,

    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
Import-Module $modulePath -Force

if ([string]::IsNullOrWhiteSpace($TestMetadataPath)) {
    $TestMetadataPath = Join-Path $repoRoot 'testdata/prod-safety-tests.example.json'
}
if ([string]::IsNullOrWhiteSpace($SyntheticUsersPath)) {
    $SyntheticUsersPath = Join-Path $repoRoot 'testdata/synthetic-users.example.json'
}

$allTests = Read-TestMetadataFile -Path $TestMetadataPath
function Test-HasSuite {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Test,

        [Parameter(Mandatory = $true)]
        [string] $Suite
    )

    $property = $Test.PSObject.Properties['suites']
    if ($null -eq $property) {
        return $false
    }

    return @($property.Value) -contains $Suite
}

$smokeTests = @($allTests | Where-Object { Test-HasSuite -Test $_ -Suite 'prod-safe-smoke' })
$unsafeInSmoke = @($smokeTests | Where-Object { $_.classification -ne 'PROD_SAFE' })

if ($unsafeInSmoke.Count -gt 0) {
    throw 'Prod-safe smoke metadata contains non-PROD_SAFE smoke tests.'
}

if ($smokeTests.Count -eq 0) {
    throw 'No PROD_SAFE tests are available for prod-safe smoke.'
}

$syntheticUsers = Read-SyntheticUsersConfig -Path $SyntheticUsersPath
$result = Invoke-ProdGuard -Tests $smokeTests -Environment $Environment -SyntheticUsers $syntheticUsers -DryRun:$DryRun

$result | ConvertTo-Json -Depth 8

if (-not $result.passed) {
    throw 'Prod-safe smoke guard rejected the requested run.'
}

if (-not $DryRun) {
    Write-Host 'Guard passed. M0 does not implement real app execution; no production action was performed by this script.'
}
