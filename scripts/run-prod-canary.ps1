param(
    [ValidateSet('local', 'staging', 'production')]
    [string] $Environment = 'production',

    [string] $TestMetadataPath,

    [string] $SyntheticUsersPath,

    [string] $ResourceBudgetPath,

    [switch] $AllowProdConditional,

    [switch] $CleanupVerified,

    [switch] $DryRun,

    [switch] $ExpectFailure
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
if ([string]::IsNullOrWhiteSpace($ResourceBudgetPath)) {
    $ResourceBudgetPath = Join-Path $repoRoot 'testdata/prod-resource-budget.example.yaml'
}

if (-not $DryRun) {
    throw 'Prod canary runner is dry-run only. Pass -DryRun to validate guard metadata without production action.'
}

function Assert-ProdCanaryInputPathSafe {
    param(
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $true)][string] $Path
    )

    if ($Path -match '(?i)AppData|Cookies|cookie|\.log|logs|crash|dump|Local Storage|IndexedDB|\.db') {
        throw "Prod canary runner must not read unsafe runtime input path '$Name'."
    }
}

Assert-ProdCanaryInputPathSafe -Name 'TestMetadataPath' -Path $TestMetadataPath
Assert-ProdCanaryInputPathSafe -Name 'SyntheticUsersPath' -Path $SyntheticUsersPath
Assert-ProdCanaryInputPathSafe -Name 'ResourceBudgetPath' -Path $ResourceBudgetPath

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

$canaryTests = @($allTests | Where-Object { Test-HasSuite -Test $_ -Suite 'prod-canary' })
$unsafeInCanary = @($canaryTests | Where-Object { $_.classification -ne 'PROD_CONDITIONAL' })
if ($unsafeInCanary.Count -gt 0) {
    throw 'Prod canary metadata contains non-PROD_CONDITIONAL canary tests.'
}
if ($canaryTests.Count -eq 0) {
    throw 'No PROD_CONDITIONAL canary tests are available.'
}

$syntheticUsers = Read-SyntheticUsersConfig -Path $SyntheticUsersPath
$budget = Read-ProdResourceBudget -Path $ResourceBudgetPath

$result = Invoke-ProdGuard `
    -Tests $canaryTests `
    -Environment $Environment `
    -SyntheticUsers $syntheticUsers `
    -ResourceBudget $budget `
    -AllowProdConditional:$AllowProdConditional `
    -CleanupVerified:$CleanupVerified `
    -DryRun:$DryRun

$result | ConvertTo-Json -Depth 8

if ($ExpectFailure) {
    if ($result.passed) {
        throw 'Expected canary guard rejection, but the guard passed.'
    }
    Write-Host 'Expected canary guard rejection observed.'
    exit 0
}

if (-not $result.passed) {
    throw 'Prod canary guard rejected the requested run.'
}
