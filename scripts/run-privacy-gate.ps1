param(
    [string] $ArtifactRoot = 'C:\Program Files\MTC Fog Play',

    [string] $PatternsPath,

    [switch] $DryRun,

    [switch] $FailOnFindings,

    [switch] $ExpectFindings
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PatternsPath)) {
    $PatternsPath = Join-Path $repoRoot 'testdata/privacy-patterns.example.json'
}

function Add-Finding {
    param(
        [Parameter(Mandatory = $true)][string] $Id,
        [Parameter(Mandatory = $true)][string] $Severity,
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][int] $LineNumber
    )

    return [pscustomobject]@{
        id = $Id
        severity = $Severity
        path = $Path
        line = $LineNumber
        message = 'Sanitized privacy pattern match found.'
    }
}

function Get-RelativeArtifactPath {
    param(
        [Parameter(Mandatory = $true)][string] $Root,
        [Parameter(Mandatory = $true)][string] $Path
    )

    $rootFull = [IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    $pathFull = [IO.Path]::GetFullPath($Path)
    if ($pathFull.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase)) {
        return $pathFull.Substring($rootFull.Length) -replace '\\', '/'
    }
    return $pathFull
}

if (-not (Test-Path -LiteralPath $ArtifactRoot -PathType Container)) {
    throw "Artifact root not found: $ArtifactRoot"
}
if (-not (Test-Path -LiteralPath $PatternsPath -PathType Leaf)) {
    throw "Privacy patterns config not found: $PatternsPath"
}

$policy = Get-Content -LiteralPath $PatternsPath -Raw | ConvertFrom-Json
$textExtensions = @($policy.textFileExtensions | ForEach-Object { [string]$_ })
$maxTextFileBytes = [int64]$policy.maxTextFileBytes
$findings = @()
$scannedFiles = 0
$skippedLargeFiles = 0

$files = @(Get-ChildItem -LiteralPath $ArtifactRoot -Recurse -Force -File -ErrorAction SilentlyContinue)
foreach ($file in $files) {
    if (-not ($textExtensions -contains $file.Extension.ToLowerInvariant())) {
        continue
    }

    if ($file.Length -gt $maxTextFileBytes) {
        $skippedLargeFiles += 1
        continue
    }

    $scannedFiles += 1
    $lines = @(Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue)
    if ($null -eq $lines) {
        continue
    }

    for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($pattern in @($policy.patterns)) {
            if ([regex]::IsMatch([string]$lines[$i], [string]$pattern.pattern)) {
                $findings += Add-Finding -Id ([string]$pattern.id) -Severity ([string]$pattern.severity) -Path (Get-RelativeArtifactPath -Root $ArtifactRoot -Path $file.FullName) -LineNumber ($i + 1)
            }
        }
    }
}

$failFindings = @($findings | Where-Object { $_.severity -eq 'fail' })
$result = [pscustomobject]@{
    gate = 'Privacy'
    artifactRoot = $ArtifactRoot
    dryRun = [bool]$DryRun
    passed = ($failFindings.Count -eq 0)
    fileCount = $files.Count
    scannedTextFiles = $scannedFiles
    skippedLargeFiles = $skippedLargeFiles
    findings = $findings
}

$result | ConvertTo-Json -Depth 8

if ($ExpectFindings -and $findings.Count -eq 0) {
    throw 'Expected privacy gate findings, but none were produced.'
}

if ($FailOnFindings -and $failFindings.Count -gt 0) {
    throw "Privacy gate failed with $($failFindings.Count) fail finding(s)."
}
