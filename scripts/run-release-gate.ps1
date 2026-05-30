param(
    [string] $ArtifactRoot = 'C:\Program Files\MTC Fog Play',

    [string] $PolicyPath,

    [switch] $DryRun,

    [switch] $FailOnFindings,

    [switch] $ExpectFindings,

    [switch] $ReportOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PolicyPath)) {
    $PolicyPath = Join-Path $repoRoot 'testdata/release-gate-policy.example.json'
}

if (-not $DryRun) {
    throw 'Release gate runner is dry-run only. Pass -DryRun to perform local artifact validation.'
}

function ConvertTo-NormalizedRelativePath {
    param([Parameter(Mandatory = $true)][string] $Path)
    return ($Path -replace '/', [IO.Path]::DirectorySeparatorChar)
}

function Add-Finding {
    param(
        [Parameter(Mandatory = $true)][string] $Id,
        [Parameter(Mandatory = $true)][string] $Severity,
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][string] $Message
    )

    return [pscustomobject]@{
        id = $Id
        severity = $Severity
        path = $Path
        message = $Message
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

function Test-TextPattern {
    param(
        [Parameter(Mandatory = $true)][IO.FileInfo] $File,
        [Parameter(Mandatory = $true)] $Pattern,
        [int64] $MaxBytes
    )

    if ($File.Length -gt $MaxBytes) {
        return $false
    }

    $text = Get-Content -LiteralPath $File.FullName -Raw -ErrorAction Stop
    if ($null -eq $text) {
        return $false
    }

    return [regex]::IsMatch($text, [string]$Pattern.pattern)
}

if (-not (Test-Path -LiteralPath $ArtifactRoot -PathType Container)) {
    throw "Artifact root not found: $ArtifactRoot"
}
if (-not (Test-Path -LiteralPath $PolicyPath -PathType Leaf)) {
    throw "Release gate policy not found: $PolicyPath"
}

$policy = Get-Content -LiteralPath $PolicyPath -Raw | ConvertFrom-Json
$findings = @()
$signatureResults = @()
$versionResults = @()

foreach ($required in @($policy.requiredFiles)) {
    $relative = ConvertTo-NormalizedRelativePath -Path ([string]$required)
    $path = Join-Path $ArtifactRoot $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $findings += Add-Finding -Id 'missing-required-file' -Severity 'fail' -Path ([string]$required) -Message 'Required release artifact file is missing.'
    }
}

foreach ($check in @($policy.signatureChecks)) {
    $relative = ConvertTo-NormalizedRelativePath -Path ([string]$check.path)
    $path = Join-Path $ArtifactRoot $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        continue
    }

    $signature = Get-AuthenticodeSignature -LiteralPath $path
    $signatureResults += [pscustomobject]@{
        path = [string]$check.path
        status = [string]$signature.Status
        signer = if ($null -ne $signature.SignerCertificate) { [string]$signature.SignerCertificate.Subject } else { '' }
        issuer = if ($null -ne $signature.SignerCertificate) { [string]$signature.SignerCertificate.Issuer } else { '' }
        notAfter = if ($null -ne $signature.SignerCertificate) { $signature.SignerCertificate.NotAfter.ToString('o') } else { '' }
    }

    if ($check.required -eq $true -and $signature.Status -ne 'Valid') {
        $findings += Add-Finding -Id 'invalid-signature' -Severity 'fail' -Path ([string]$check.path) -Message "Authenticode signature is $($signature.Status)."
    }
}

foreach ($check in @($policy.versionMetadata)) {
    $relative = ConvertTo-NormalizedRelativePath -Path ([string]$check.path)
    $path = Join-Path $ArtifactRoot $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        continue
    }

    $item = Get-Item -LiteralPath $path
    $version = $item.VersionInfo
    $versionResults += [pscustomobject]@{
        path = [string]$check.path
        productVersion = [string]$version.ProductVersion
        fileVersion = [string]$version.FileVersion
        companyName = [string]$version.CompanyName
        productName = [string]$version.ProductName
    }

    foreach ($field in @('ProductVersion', 'FileVersion', 'CompanyName', 'ProductName')) {
        $requireFieldName = "require$field"
        $required = $check.PSObject.Properties[$requireFieldName]
        if ($null -ne $required -and $required.Value -eq $true -and [string]::IsNullOrWhiteSpace([string]$version.$field)) {
            $findings += Add-Finding -Id 'missing-version-metadata' -Severity 'fail' -Path ([string]$check.path) -Message "Version metadata field '$field' is missing."
        }
    }
}

$files = @(Get-ChildItem -LiteralPath $ArtifactRoot -Recurse -Force -File -ErrorAction Stop)
$forbiddenExtensions = @($policy.forbiddenExtensions | ForEach-Object { [string]$_ })
foreach ($file in $files) {
    if ($forbiddenExtensions -contains $file.Extension.ToLowerInvariant()) {
        $findings += Add-Finding -Id 'forbidden-extension' -Severity 'fail' -Path (Get-RelativeArtifactPath -Root $ArtifactRoot -Path $file.FullName) -Message "Forbidden release artifact extension '$($file.Extension)' found."
    }
}

$textExtensions = @($policy.textFileExtensions | ForEach-Object { [string]$_ })
$maxTextFileBytes = [int64]$policy.maxTextFileBytes
foreach ($file in $files) {
    if (-not ($textExtensions -contains $file.Extension.ToLowerInvariant())) {
        continue
    }

    if ($file.Length -gt $maxTextFileBytes) {
        $findings += Add-Finding -Id 'text-file-too-large' -Severity 'fail' -Path (Get-RelativeArtifactPath -Root $ArtifactRoot -Path $file.FullName) -Message "Text-like artifact exceeds scan limit of $maxTextFileBytes bytes."
        continue
    }

    foreach ($pattern in @($policy.forbiddenTextPatterns)) {
        try {
            if (Test-TextPattern -File $file -Pattern $pattern -MaxBytes $maxTextFileBytes) {
                $findings += Add-Finding -Id ([string]$pattern.id) -Severity ([string]$pattern.severity) -Path (Get-RelativeArtifactPath -Root $ArtifactRoot -Path $file.FullName) -Message 'Sanitized pattern match found.'
            }
        }
        catch {
            $findings += Add-Finding -Id 'unreadable-file' -Severity 'fail' -Path (Get-RelativeArtifactPath -Root $ArtifactRoot -Path $file.FullName) -Message 'Text-like artifact could not be read.'
            break
        }
    }
}

$failFindings = @($findings | Where-Object { $_.severity -eq 'fail' })
$result = [pscustomobject]@{
    gate = 'Release'
    artifactRoot = $ArtifactRoot
    dryRun = [bool]$DryRun
    passed = ($failFindings.Count -eq 0)
    fileCount = $files.Count
    signatureResults = $signatureResults
    versionResults = $versionResults
    findings = $findings
}

$result | ConvertTo-Json -Depth 8

if ($ExpectFindings -and $findings.Count -eq 0) {
    throw 'Expected release gate findings, but none were produced.'
}

if ($failFindings.Count -gt 0 -and -not $ExpectFindings -and -not $ReportOnly) {
    throw "Release gate failed with $($failFindings.Count) fail finding(s)."
}

if ($FailOnFindings -and $failFindings.Count -gt 0) {
    throw "Release gate failed with $($failFindings.Count) fail finding(s)."
}
