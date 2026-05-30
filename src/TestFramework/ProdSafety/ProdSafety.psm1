Set-StrictMode -Version Latest

$script:AllowedClassifications = @(
    'PROD_SAFE',
    'PROD_CONDITIONAL',
    'PROD_FORBIDDEN',
    'NON_PROD_ONLY'
)

function ConvertTo-BooleanFlag {
    param(
        [AllowNull()]
        [object] $Value
    )

    if ($null -eq $Value) {
        return $false
    }

    if ($Value -is [bool]) {
        return $Value
    }

    $text = [string]$Value
    return $text.Trim().ToLowerInvariant() -in @('1', 'true', 'yes', 'y', 'on', 'enabled')
}

function Get-ProdSafetyClassificationValues {
    return $script:AllowedClassifications
}

function Get-MetadataValue {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Metadata,

        [Parameter(Mandatory = $true)]
        [string] $Name,

        [AllowNull()]
        [object] $Default = $null
    )

    $property = $Metadata.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $Default
    }

    return $property.Value
}

function New-TestMetadata {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,

        [AllowNull()]
        [string] $Classification,

        [string] $RequiresSyntheticUserAlias,

        [bool] $StartsGameSession = $false,

        [bool] $MutatesState = $false,

        [bool] $RequiresCleanupVerification = $false
    )

    return [pscustomobject]@{
        name = $Name
        classification = $Classification
        requiresSyntheticUserAlias = $RequiresSyntheticUserAlias
        startsGameSession = $StartsGameSession
        mutatesState = $MutatesState
        requiresCleanupVerification = $RequiresCleanupVerification
    }
}

function Read-TestMetadataFile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Test metadata file not found: $Path"
    }

    $data = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    if ($null -eq $data.tests) {
        throw "Test metadata file must contain a top-level 'tests' array: $Path"
    }

    return @($data.tests)
}

function Read-SyntheticUsersConfig {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Synthetic users config not found: $Path"
    }

    $data = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    if ($null -eq $data.syntheticUsers) {
        throw "Synthetic users config must contain a top-level 'syntheticUsers' array: $Path"
    }

    return @($data.syntheticUsers)
}

function Read-ProdResourceBudget {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Resource budget config not found: $Path"
    }

    $content = Get-Content -LiteralPath $Path -Raw
    $budget = [ordered]@{}
    $inBudget = $false
    $currentListKey = $null

    foreach ($rawLine in ($content -split "`r?`n")) {
        $line = $rawLine.TrimEnd()
        if ([string]::IsNullOrWhiteSpace($line) -or $line.TrimStart().StartsWith('#')) {
            continue
        }

        if ($line -eq 'prodResourceBudget:') {
            $inBudget = $true
            continue
        }

        if (-not $inBudget) {
            continue
        }

        if ($line -match '^\s{2}([A-Za-z0-9_]+):\s*(.*)$') {
            $key = $Matches[1]
            $value = $Matches[2].Trim()
            $currentListKey = $null

            if ($value -eq '') {
                $budget[$key] = @()
                $currentListKey = $key
                continue
            }

            if ($value -match '^\d+$') {
                $budget[$key] = [int]$value
            }
            elseif ($value.ToLowerInvariant() -in @('true', 'false')) {
                $budget[$key] = [bool]::Parse($value)
            }
            else {
                $budget[$key] = $value
            }
            continue
        }

        if ($line -match '^\s{4}-\s*(.+)$' -and $null -ne $currentListKey) {
            $budget[$currentListKey] = @($budget[$currentListKey]) + $Matches[1].Trim()
            continue
        }
    }

    if ($budget.Count -eq 0) {
        throw "Resource budget config must contain 'prodResourceBudget': $Path"
    }

    return [pscustomobject]$budget
}

function Test-KillSwitch {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('local', 'staging', 'production')]
        [string] $Environment,

        [switch] $AllowProdConditional,

        [switch] $DryRun
    )

    $errors = @()
    if ($Environment -eq 'production' -and -not $DryRun) {
        if (-not (ConvertTo-BooleanFlag $env:PROD_AUTOMATION_ENABLED)) {
            $errors += 'PROD_AUTOMATION_ENABLED must be enabled for non-dry-run production automation.'
        }

        if ($AllowProdConditional -and -not (ConvertTo-BooleanFlag $env:QA_PROD_CANARY_ENABLED)) {
            $errors += 'QA_PROD_CANARY_ENABLED must be enabled for non-dry-run PROD_CONDITIONAL automation.'
        }
    }

    return [pscustomobject]@{
        passed = ($errors.Count -eq 0)
        errors = $errors
    }
}

function Test-SyntheticUserGuard {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Metadata,

        [object[]] $SyntheticUsers,

        [Parameter(Mandatory = $true)]
        [ValidateSet('local', 'staging', 'production')]
        [string] $Environment
    )

    $errors = @()
    $testName = [string](Get-MetadataValue -Metadata $Metadata -Name 'name' -Default '<unnamed>')
    $classification = [string](Get-MetadataValue -Metadata $Metadata -Name 'classification' -Default '')
    $startsGameSession = [bool](Get-MetadataValue -Metadata $Metadata -Name 'startsGameSession' -Default $false)
    $targetRegion = [string](Get-MetadataValue -Metadata $Metadata -Name 'targetRegion' -Default '')
    $targetGame = [string](Get-MetadataValue -Metadata $Metadata -Name 'targetGame' -Default '')
    $mutatesState = [bool](Get-MetadataValue -Metadata $Metadata -Name 'mutatesState' -Default $false)
    $requiresCleanupVerification = [bool](Get-MetadataValue -Metadata $Metadata -Name 'requiresCleanupVerification' -Default $false)
    $alias = [string](Get-MetadataValue -Metadata $Metadata -Name 'requiresSyntheticUserAlias' -Default '')
    if ([string]::IsNullOrWhiteSpace($alias)) {
        if ($classification -eq 'PROD_CONDITIONAL' -or $startsGameSession -or $mutatesState -or $requiresCleanupVerification) {
            $errors += "Test '$testName' requires an allowlisted synthetic user."
        }
        return $errors
    }

    $match = @($SyntheticUsers | Where-Object { $_.alias -eq $alias })
    if ($match.Count -ne 1) {
        $errors += "Synthetic user alias '$alias' is not allowlisted for test '$testName'."
        return $errors
    }

    $user = $match[0]
    if ($Environment -eq 'production' -and -not (@($user.allowedEnvironments) -contains 'production')) {
        $errors += "Synthetic user alias '$alias' is not allowed in production."
    }

    if ($startsGameSession -and $user.canStartGameSession -ne $true) {
        $errors += "Synthetic user alias '$alias' is not allowed to start game sessions."
    }

    return $errors
}

function Test-ResourceBudget {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Metadata,

        [object] $Budget,

        [switch] $AllowProdConditional
    )

    $errors = @()
    $testName = [string](Get-MetadataValue -Metadata $Metadata -Name 'name' -Default '<unnamed>')
    $classification = [string](Get-MetadataValue -Metadata $Metadata -Name 'classification' -Default '')
    $startsGameSession = [bool](Get-MetadataValue -Metadata $Metadata -Name 'startsGameSession' -Default $false)
    $targetRegion = [string](Get-MetadataValue -Metadata $Metadata -Name 'targetRegion' -Default '')
    $targetGame = [string](Get-MetadataValue -Metadata $Metadata -Name 'targetGame' -Default '')

    if (-not $startsGameSession -and $classification -ne 'PROD_CONDITIONAL') {
        return $errors
    }

    if ($null -eq $Budget) {
        $errors += "Test '$testName' requires a resource budget."
        return $errors
    }

    $maxSessionsPerRun = [int](Get-MetadataValue -Metadata $Budget -Name 'maxSessionsPerRun' -Default 0)
    $maxParallelSessions = [int](Get-MetadataValue -Metadata $Budget -Name 'maxParallelSessions' -Default 0)
    $maxSessionDurationSeconds = [int](Get-MetadataValue -Metadata $Budget -Name 'maxSessionDurationSeconds' -Default 0)
    $maxRunsPerHour = [int](Get-MetadataValue -Metadata $Budget -Name 'maxRunsPerHour' -Default 0)
    $allowedRegions = @(Get-MetadataValue -Metadata $Budget -Name 'allowedRegions' -Default @())
    $allowedGames = @(Get-MetadataValue -Metadata $Budget -Name 'allowedGames' -Default @())
    $requireCleanupVerification = [bool](Get-MetadataValue -Metadata $Budget -Name 'requireCleanupVerification' -Default $false)
    $requireExplicitConditionalFlag = [bool](Get-MetadataValue -Metadata $Budget -Name 'requireExplicitConditionalFlag' -Default $false)

    if ($maxSessionsPerRun -ne 1) {
        $errors += 'prodResourceBudget.maxSessionsPerRun must be exactly 1 for M0.'
    }
    if ($maxParallelSessions -ne 1) {
        $errors += 'prodResourceBudget.maxParallelSessions must be exactly 1 for M0.'
    }
    if ($maxSessionDurationSeconds -lt 1 -or $maxSessionDurationSeconds -gt 120) {
        $errors += 'prodResourceBudget.maxSessionDurationSeconds must be between 1 and 120 for M0.'
    }
    if ($maxRunsPerHour -lt 1 -or $maxRunsPerHour -gt 3) {
        $errors += 'prodResourceBudget.maxRunsPerHour must be between 1 and 3 for M0.'
    }
    if ($allowedRegions.Count -lt 1) {
        $errors += 'prodResourceBudget.allowedRegions must contain at least one allowlisted region.'
    }
    if ([string]::IsNullOrWhiteSpace($targetRegion)) {
        $errors += "Test '$testName' requires an explicit targetRegion for resource budget validation."
    }
    elseif (-not ($allowedRegions -contains $targetRegion)) {
        $errors += "Test '$testName' targetRegion '$targetRegion' is not allowlisted in prodResourceBudget.allowedRegions."
    }
    if ($startsGameSession -and $allowedGames.Count -lt 1) {
        $errors += 'prodResourceBudget.allowedGames must contain at least one allowlisted game for game-session tests.'
    }
    if ($startsGameSession) {
        if ([string]::IsNullOrWhiteSpace($targetGame)) {
            $errors += "Game-session test '$testName' requires an explicit targetGame for resource budget validation."
        }
        elseif (-not ($allowedGames -contains $targetGame)) {
            $errors += "Game-session test '$testName' targetGame '$targetGame' is not allowlisted in prodResourceBudget.allowedGames."
        }
    }
    if ($requireCleanupVerification -ne $true) {
        $errors += 'prodResourceBudget.requireCleanupVerification must be true.'
    }
    if ($requireExplicitConditionalFlag -ne $true) {
        $errors += 'prodResourceBudget.requireExplicitConditionalFlag must be true.'
    }
    return $errors
}

function Test-CleanupVerifier {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Metadata,

        [switch] $CleanupVerified
    )

    $errors = @()
    $testName = [string](Get-MetadataValue -Metadata $Metadata -Name 'name' -Default '<unnamed>')
    $mutatesState = [bool](Get-MetadataValue -Metadata $Metadata -Name 'mutatesState' -Default $false)
    $startsGameSession = [bool](Get-MetadataValue -Metadata $Metadata -Name 'startsGameSession' -Default $false)
    $requiresCleanupVerification = [bool](Get-MetadataValue -Metadata $Metadata -Name 'requiresCleanupVerification' -Default $false)

    if (($mutatesState -or $startsGameSession -or $requiresCleanupVerification) -and -not $CleanupVerified) {
        $errors += "Test '$testName' requires cleanup verification."
    }
    return $errors
}

function Invoke-ProdGuard {
    param(
        [Parameter(Mandatory = $true)]
        [object[]] $Tests,

        [Parameter(Mandatory = $true)]
        [ValidateSet('local', 'staging', 'production')]
        [string] $Environment,

        [object[]] $SyntheticUsers = @(),

        [object] $ResourceBudget,

        [switch] $AllowProdConditional,

        [switch] $DryRun,

        [switch] $CleanupVerified
    )

    $results = @()
    $killSwitch = Test-KillSwitch -Environment $Environment -AllowProdConditional:$AllowProdConditional -DryRun:$DryRun

    foreach ($test in $Tests) {
        $errors = @()
        $testName = [string](Get-MetadataValue -Metadata $test -Name 'name' -Default '<unnamed>')
        $classification = [string](Get-MetadataValue -Metadata $test -Name 'classification' -Default '')

        if ($Environment -eq 'production') {
            if ([string]::IsNullOrWhiteSpace($classification)) {
                $errors += "Test '$testName' is unclassified and cannot run on production."
            }
            elseif (-not ($script:AllowedClassifications -contains $classification)) {
                $errors += "Test '$testName' has invalid classification '$classification'."
            }
            elseif ($classification -eq 'PROD_FORBIDDEN') {
                $errors += "Test '$testName' is PROD_FORBIDDEN and cannot run on production."
            }
            elseif ($classification -eq 'NON_PROD_ONLY') {
                $errors += "Test '$testName' is NON_PROD_ONLY and cannot run on production."
            }
            elseif ($classification -eq 'PROD_CONDITIONAL' -and -not $AllowProdConditional) {
                $errors += "Test '$testName' is PROD_CONDITIONAL and requires an explicit conditional flag."
            }
        }
        elseif (-not [string]::IsNullOrWhiteSpace($classification) -and -not ($script:AllowedClassifications -contains $classification)) {
            $errors += "Test '$testName' has invalid classification '$classification'."
        }

        if ($Environment -eq 'production') {
            $errors += @(Test-SyntheticUserGuard -Metadata $test -SyntheticUsers $SyntheticUsers -Environment $Environment)
            $errors += @(Test-ResourceBudget -Metadata $test -Budget $ResourceBudget -AllowProdConditional:$AllowProdConditional)
            $errors += @(Test-CleanupVerifier -Metadata $test -CleanupVerified:$CleanupVerified)
            $errors += @($killSwitch.errors)
        }

        $results += [pscustomobject]@{
            name = $testName
            classification = $classification
            allowed = ($errors.Count -eq 0)
            errors = $errors
        }
    }

    return [pscustomobject]@{
        environment = $Environment
        dryRun = [bool]$DryRun
        allowProdConditional = [bool]$AllowProdConditional
        passed = (@($results | Where-Object { -not $_.allowed }).Count -eq 0)
        results = $results
    }
}

Export-ModuleMember -Function `
    Get-ProdSafetyClassificationValues, `
    New-TestMetadata, `
    Read-TestMetadataFile, `
    Read-SyntheticUsersConfig, `
    Read-ProdResourceBudget, `
    Test-KillSwitch, `
    Test-SyntheticUserGuard, `
    Test-ResourceBudget, `
    Test-CleanupVerifier, `
    Invoke-ProdGuard
