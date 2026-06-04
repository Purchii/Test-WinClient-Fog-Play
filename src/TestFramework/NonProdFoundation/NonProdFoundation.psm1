Set-StrictMode -Version Latest

function Add-NonProdFoundationFinding {
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

function Get-NonProdFoundationArray {
    param(
        [Parameter(Mandatory = $true)][object] $Object,
        [Parameter(Mandatory = $true)][string] $Name
    )

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) {
        return @()
    }

    return @($property.Value)
}

function Get-NonProdFoundationValue {
    param(
        [Parameter(Mandatory = $true)][object] $Object,
        [Parameter(Mandatory = $true)][string] $Name,
        [AllowNull()][object] $Default = $null
    )

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $Default
    }

    return $property.Value
}

function Read-NonProdFoundationPlan {
    param([Parameter(Mandatory = $true)][string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Non-prod foundation plan not found: $Path"
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Test-NonProdFoundationSchema {
    param([AllowNull()][object] $Schema)

    if ($null -eq $Schema) {
        return $false
    }

    $type = Get-NonProdFoundationValue -Object $Schema -Name 'type' -Default ''
    if ([string]::IsNullOrWhiteSpace([string]$type)) {
        return $false
    }

    if ([string]$type -eq 'object' -and @(Get-NonProdFoundationArray -Object $Schema -Name 'required').Count -eq 0) {
        return $false
    }

    return $true
}

function Get-NonProdFoundationMissingRequiredProperties {
    param([AllowNull()][object] $Schema)

    if ($null -eq $Schema) {
        return @()
    }

    $required = @(Get-NonProdFoundationArray -Object $Schema -Name 'required')
    if ($required.Count -eq 0) {
        return @()
    }

    $properties = Get-NonProdFoundationValue -Object $Schema -Name 'properties'
    $propertyNames = @()
    if ($null -ne $properties) {
        $propertyNames = @($properties.PSObject.Properties | ForEach-Object { [string]$_.Name })
    }

    $missing = @()
    foreach ($requiredName in $required) {
        $name = [string]$requiredName
        if ([string]::IsNullOrWhiteSpace($name) -or $propertyNames -notcontains $name) {
            $missing += $name
        }
    }

    return $missing
}

function Test-NonProdFoundationUnsafeText {
    param([AllowNull()][object] $Value)

    $text = [string]$Value
    return $text -match '(?i)authorization|bearer|cookie|token|secret|password|sessionHeader|client_secret|AppData|Cookies|\.log|logs|crash|dump|Local Storage|IndexedDB|\.db|https?://'
}

function Test-NonProdFoundationPlan {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Plan,

        [switch] $DryRun
    )

    $findings = @()
    $checks = @()

    $policyChecks = @(
        @{ Name = 'dryRunFlag'; Passed = [bool]$DryRun; Id = 'dry-run-flag-required'; Message = 'M6 non-prod foundation validator must be invoked with -DryRun.' },
        @{ Name = 'dryRunOnly'; Passed = (Get-NonProdFoundationValue -Object $Plan -Name 'dryRunOnly' -Default $false) -eq $true; Id = 'policy-not-dry-run-only'; Message = 'M6 non-prod foundation must be dry-run only.' },
        @{ Name = 'executionDisabled'; Passed = (Get-NonProdFoundationValue -Object $Plan -Name 'executionDisabled' -Default $false) -eq $true; Id = 'execution-not-disabled'; Message = 'M6 must not execute future non-prod systems.' },
        @{ Name = 'clientLaunchDisabled'; Passed = (Get-NonProdFoundationValue -Object $Plan -Name 'clientLaunchDisabled' -Default $false) -eq $true; Id = 'client-launch-not-disabled'; Message = 'M6 must not launch the installed client.' },
        @{ Name = 'webViewDebugDisabled'; Passed = (Get-NonProdFoundationValue -Object $Plan -Name 'webViewDebugDisabled' -Default $false) -eq $true; Id = 'webview-debug-not-disabled'; Message = 'M6 must not enable WebView debug or CDP.' },
        @{ Name = 'networkCallsDisabled'; Passed = (Get-NonProdFoundationValue -Object $Plan -Name 'networkCallsDisabled' -Default $false) -eq $true; Id = 'network-not-disabled'; Message = 'M6 must not perform backend, streaming or replay network calls.' },
        @{ Name = 'authDisabled'; Passed = (Get-NonProdFoundationValue -Object $Plan -Name 'authDisabled' -Default $false) -eq $true; Id = 'auth-not-disabled'; Message = 'M6 must not authenticate or use credentials.' },
        @{ Name = 'runtimeDataReadsDisabled'; Passed = (Get-NonProdFoundationValue -Object $Plan -Name 'runtimeDataReadsDisabled' -Default $false) -eq $true; Id = 'runtime-data-read-not-disabled'; Message = 'M6 must not read AppData, logs, cookies, DBs or dumps.' },
        @{ Name = 'ciCdDisabled'; Passed = (Get-NonProdFoundationValue -Object $Plan -Name 'ciCdDisabled' -Default $false) -eq $true; Id = 'cicd-not-disabled'; Message = 'M6 must not enable CI/CD automation.' }
    )

    foreach ($policyCheck in $policyChecks) {
        $checks += [pscustomobject]@{
            type = 'policy-safety'
            name = $policyCheck.Name
            passed = $policyCheck.Passed
        }
        if (-not $policyCheck.Passed) {
            $findings += Add-NonProdFoundationFinding -Id $policyCheck.Id -Severity 'fail' -Path '<policy>' -Message $policyCheck.Message
        }
    }

    foreach ($runtimePath in @(Get-NonProdFoundationArray -Object $Plan -Name 'runtimePaths')) {
        if (Test-NonProdFoundationUnsafeText -Value $runtimePath) {
            $findings += Add-NonProdFoundationFinding -Id 'unsafe-runtime-path' -Severity 'fail' -Path '<policy>' -Message 'M6 must not reference user runtime paths, logs, cookies, DBs or dumps.'
        }
    }

    foreach ($endpoint in @(Get-NonProdFoundationArray -Object $Plan -Name 'productionEndpoints')) {
        if (-not [string]::IsNullOrWhiteSpace([string]$endpoint)) {
            $findings += Add-NonProdFoundationFinding -Id 'production-endpoint-defined' -Severity 'fail' -Path '<policy>' -Message 'M6 local foundation must not define production endpoints or URLs.'
        }
    }

    foreach ($component in @(Get-NonProdFoundationArray -Object $Plan -Name 'components')) {
        $name = [string](Get-NonProdFoundationValue -Object $component -Name 'name' -Default '<unnamed>')
        $path = "components/$name"
        $type = [string](Get-NonProdFoundationValue -Object $component -Name 'type' -Default '')
        $classification = [string](Get-NonProdFoundationValue -Object $component -Name 'classification' -Default '')
        $schemaOnly = (Get-NonProdFoundationValue -Object $component -Name 'schemaOnly' -Default $false) -eq $true
        $executionEnabled = (Get-NonProdFoundationValue -Object $component -Name 'executionEnabled' -Default $true) -eq $true
        $usesProduction = (Get-NonProdFoundationValue -Object $component -Name 'usesProduction' -Default $true) -eq $true
        $requiresCredentials = (Get-NonProdFoundationValue -Object $component -Name 'requiresCredentials' -Default $true) -eq $true
        $mutatesState = (Get-NonProdFoundationValue -Object $component -Name 'mutatesState' -Default $true) -eq $true
        $startsGameSession = (Get-NonProdFoundationValue -Object $component -Name 'startsGameSession' -Default $true) -eq $true
        $contractSchema = Get-NonProdFoundationValue -Object $component -Name 'contractSchema'
        $validSchema = Test-NonProdFoundationSchema -Schema $contractSchema
        $missingRequiredContractProperties = @(Get-NonProdFoundationMissingRequiredProperties -Schema $contractSchema)

        $checks += [pscustomobject]@{
            type = 'non-prod-foundation-component'
            name = $name
            componentType = $type
            classification = $classification
            passed = (
                $name -match '^[a-z][a-z0-9.-]*$' -and
                $type -in @('fake-backend', 'fake-signaling', 'replay-server', 'network-shaper', 'hardware-matrix', 'update-rollback-lab') -and
                $classification -eq 'NON_PROD_ONLY' -and
                $schemaOnly -and
                -not $executionEnabled -and
                -not $usesProduction -and
                -not $requiresCredentials -and
                -not $mutatesState -and
                -not $startsGameSession -and
                $validSchema -and
                $missingRequiredContractProperties.Count -eq 0
            )
        }

        if ($name -notmatch '^[a-z][a-z0-9.-]*$') {
            $findings += Add-NonProdFoundationFinding -Id 'invalid-component-name' -Severity 'fail' -Path $path -Message 'Component name must be a stable lower-case identifier.'
        }
        if ($type -notin @('fake-backend', 'fake-signaling', 'replay-server', 'network-shaper', 'hardware-matrix', 'update-rollback-lab')) {
            $findings += Add-NonProdFoundationFinding -Id 'invalid-component-type' -Severity 'fail' -Path $path -Message 'Component type must be one of the approved M6 future-foundation types.'
        }
        if ($classification -ne 'NON_PROD_ONLY') {
            $findings += Add-NonProdFoundationFinding -Id 'non-nonprod-classification' -Severity 'fail' -Path $path -Message 'M6 future foundation components must be classified as NON_PROD_ONLY.'
        }
        if (-not $schemaOnly) {
            $findings += Add-NonProdFoundationFinding -Id 'component-not-schema-only' -Severity 'fail' -Path $path -Message 'M6 components must be schema/config placeholders only.'
        }
        if ($executionEnabled) {
            $findings += Add-NonProdFoundationFinding -Id 'component-execution-enabled' -Severity 'fail' -Path $path -Message 'M6 components must not execute fake, replay, network or hardware systems.'
        }
        if ($usesProduction) {
            $findings += Add-NonProdFoundationFinding -Id 'component-uses-production' -Severity 'fail' -Path $path -Message 'M6 components must not target production.'
        }
        if ($requiresCredentials) {
            $findings += Add-NonProdFoundationFinding -Id 'component-requires-credentials' -Severity 'fail' -Path $path -Message 'M6 components must not require credentials.'
        }
        if ($mutatesState) {
            $findings += Add-NonProdFoundationFinding -Id 'component-mutates-state' -Severity 'fail' -Path $path -Message 'M6 components must not mutate state.'
        }
        if ($startsGameSession) {
            $findings += Add-NonProdFoundationFinding -Id 'component-starts-game-session' -Severity 'fail' -Path $path -Message 'M6 components must not start game sessions.'
        }
        if (-not $validSchema) {
            $findings += Add-NonProdFoundationFinding -Id 'missing-contract-schema' -Severity 'fail' -Path $path -Message 'M6 components must define a local contract schema.'
        }
        if ($missingRequiredContractProperties.Count -gt 0) {
            $missingList = $missingRequiredContractProperties -join ', '
            $findings += Add-NonProdFoundationFinding -Id 'required-contract-property-missing' -Severity 'fail' -Path $path -Message "M6 contractSchema.required entries must exist in contractSchema.properties: $missingList"
        }
        foreach ($value in @(Get-NonProdFoundationArray -Object $component -Name 'forbiddenReferences')) {
            if (Test-NonProdFoundationUnsafeText -Value $value) {
                $findings += Add-NonProdFoundationFinding -Id 'unsafe-component-reference' -Severity 'fail' -Path $path -Message 'M6 components must not reference URLs, credentials or runtime user data.'
            }
        }
    }

    if (@(Get-NonProdFoundationArray -Object $Plan -Name 'components').Count -eq 0) {
        $findings += Add-NonProdFoundationFinding -Id 'missing-components' -Severity 'fail' -Path '<policy>' -Message 'M6 plan must define at least one future foundation component.'
    }

    $failFindings = @($findings | Where-Object { $_.severity -eq 'fail' })
    return [pscustomobject]@{
        gate = 'NonProdFoundation'
        dryRun = [bool]$DryRun
        processStarted = $false
        debugPortUsed = $false
        networkCallAttempted = $false
        authAttempted = $false
        gameSessionStarted = $false
        readRuntimeUserData = $false
        ciCdEnabled = $false
        dependencyChanged = $false
        passed = ($failFindings.Count -eq 0)
        checks = $checks
        findings = $findings
    }
}

Export-ModuleMember -Function `
    Read-NonProdFoundationPlan, `
    Test-NonProdFoundationPlan
