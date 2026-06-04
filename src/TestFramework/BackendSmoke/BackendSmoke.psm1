Set-StrictMode -Version Latest

function Add-BackendSmokeFinding {
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

function Get-BackendSmokePolicyArray {
    param(
        [Parameter(Mandatory = $true)][object] $Policy,
        [Parameter(Mandatory = $true)][string] $Name
    )

    $property = $Policy.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) {
        return @()
    }

    return @($property.Value)
}

function Read-BackendSmokePolicy {
    param([Parameter(Mandatory = $true)][string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Backend smoke policy not found: $Path"
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Test-BackendSmokeSchema {
    param([AllowNull()][object] $Schema)

    if ($null -eq $Schema) {
        return $false
    }

    $type = $Schema.PSObject.Properties['type']
    if ($null -eq $type -or [string]::IsNullOrWhiteSpace([string]$type.Value)) {
        return $false
    }

    if ([string]$type.Value -eq 'object') {
        $properties = $Schema.PSObject.Properties['properties']
        if ($null -eq $properties -or $null -eq $properties.Value) {
            return $false
        }
    }

    return $true
}

function Test-BackendSmokePolicy {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Policy,

        [switch] $DryRun
    )

    $findings = @()
    $checks = @()

    if (-not $DryRun) {
        $findings += Add-BackendSmokeFinding -Id 'dry-run-flag-required' -Severity 'fail' -Path '<runner>' -Message 'M4 backend smoke validator requires the dry-run flag.'
    }

    $dryRunOnlyProperty = $Policy.PSObject.Properties['dryRunOnly']
    $dryRunOnly = $null -ne $dryRunOnlyProperty -and $dryRunOnlyProperty.Value -eq $true
    $checks += [pscustomobject]@{
        type = 'policy-safety'
        name = 'dryRunOnly'
        passed = $dryRunOnly
    }
    if (-not $dryRunOnly) {
        $findings += Add-BackendSmokeFinding -Id 'policy-not-dry-run-only' -Severity 'fail' -Path '<policy>' -Message 'M4 backend smoke policy must be dry-run only.'
    }

    $networkDisabledProperty = $Policy.PSObject.Properties['networkDisabled']
    $networkDisabled = $null -ne $networkDisabledProperty -and $networkDisabledProperty.Value -eq $true
    $checks += [pscustomobject]@{
        type = 'policy-safety'
        name = 'networkDisabled'
        passed = $networkDisabled
    }
    if (-not $networkDisabled) {
        $findings += Add-BackendSmokeFinding -Id 'network-not-disabled' -Severity 'fail' -Path '<policy>' -Message 'M4 backend smoke must disable real network calls by default.'
    }

    foreach ($runtimePath in (Get-BackendSmokePolicyArray -Policy $Policy -Name 'runtimePaths')) {
        $runtimePathText = [string]$runtimePath
        if ($runtimePathText -match '(?i)AppData|Cookies|cookie|\.log|logs|crash|dump|Local Storage|IndexedDB|\.db') {
            $findings += Add-BackendSmokeFinding -Id 'unsafe-runtime-path' -Severity 'fail' -Path '<policy>' -Message 'M4 backend smoke must not read user runtime paths, logs, cookies, DBs or dumps.'
        }
    }

    foreach ($header in (Get-BackendSmokePolicyArray -Policy $Policy -Name 'headers')) {
        $headerText = [string]$header
        if ($headerText -match '(?i)authorization|bearer|cookie|token|secret|password|session') {
            $findings += Add-BackendSmokeFinding -Id 'unsafe-header' -Severity 'fail' -Path '<policy>' -Message 'M4 backend smoke must not define auth, cookie, token, secret or session headers.'
        }
    }

    foreach ($endpoint in (Get-BackendSmokePolicyArray -Policy $Policy -Name 'endpoints')) {
        $name = [string]$endpoint.name
        $path = "endpoints/$name"
        $method = [string]$endpoint.method
        $classification = [string]$endpoint.classification
        $requestPath = [string]$endpoint.path
        $validName = $name -match '^[a-z][a-z0-9.-]*$'
        $readOnlyMethod = $method -eq 'GET'
        $prodSafe = $classification -eq 'PROD_SAFE'
        $noAuth = $endpoint.requiresAuth -eq $false
        $noMutation = $endpoint.mutatesState -eq $false
        $validPath = $requestPath -match '^/[a-zA-Z0-9_./?=&:-]+$' -and $requestPath -notmatch '(?i)token|secret|password|session|userId|account'
        $validSchema = Test-BackendSmokeSchema -Schema $endpoint.responseSchema
        $hasMockResponse = $null -ne $endpoint.PSObject.Properties['mockResponse'] -and $null -ne $endpoint.mockResponse

        $checks += [pscustomobject]@{
            type = 'backend-endpoint-contract'
            name = $name
            method = $method
            path = $requestPath
            passed = ($validName -and $readOnlyMethod -and $prodSafe -and $noAuth -and $noMutation -and $validPath -and $validSchema -and $hasMockResponse)
        }

        if (-not $validName) {
            $findings += Add-BackendSmokeFinding -Id 'invalid-endpoint-name' -Severity 'fail' -Path $path -Message 'Backend smoke endpoint name must be a stable lower-case identifier.'
        }
        if (-not $readOnlyMethod) {
            $findings += Add-BackendSmokeFinding -Id 'unsafe-http-method' -Severity 'fail' -Path $path -Message 'M4 PROD_SAFE backend smoke only allows read-only GET endpoints.'
        }
        if (-not $prodSafe) {
            $findings += Add-BackendSmokeFinding -Id 'non-prod-safe-endpoint' -Severity 'fail' -Path $path -Message 'M4 backend smoke endpoints must be classified as PROD_SAFE.'
        }
        if (-not $noAuth) {
            $findings += Add-BackendSmokeFinding -Id 'auth-required' -Severity 'fail' -Path $path -Message 'M4 backend smoke must not require auth without a separate synthetic-user approval.'
        }
        if (-not $noMutation) {
            $findings += Add-BackendSmokeFinding -Id 'state-mutating-endpoint' -Severity 'fail' -Path $path -Message 'M4 backend smoke must not mutate backend state.'
        }
        if (-not $validPath) {
            $findings += Add-BackendSmokeFinding -Id 'unsafe-endpoint-path' -Severity 'fail' -Path $path -Message 'Endpoint path must not contain user identifiers, tokens, secrets or session values.'
        }
        if (-not $validSchema) {
            $findings += Add-BackendSmokeFinding -Id 'missing-response-schema' -Severity 'fail' -Path $path -Message 'Endpoint must define a response schema.'
        }
        if (-not $hasMockResponse) {
            $findings += Add-BackendSmokeFinding -Id 'missing-mock-response' -Severity 'fail' -Path $path -Message 'Endpoint must define a mock response for offline validation.'
        }
    }

    if (@(Get-BackendSmokePolicyArray -Policy $Policy -Name 'endpoints').Count -eq 0) {
        $findings += Add-BackendSmokeFinding -Id 'missing-endpoints' -Severity 'fail' -Path '<policy>' -Message 'Backend smoke policy must define at least one endpoint contract.'
    }

    $failFindings = @($findings | Where-Object { $_.severity -eq 'fail' })
    return [pscustomobject]@{
        gate = 'BackendSmoke'
        dryRun = [bool]$DryRun
        networkCallAttempted = $false
        authAttempted = $false
        gameSessionStarted = $false
        readRuntimeUserData = $false
        mutatingRequestAttempted = $false
        passed = ($failFindings.Count -eq 0)
        checks = $checks
        findings = $findings
    }
}

Export-ModuleMember -Function `
    Read-BackendSmokePolicy, `
    Test-BackendSmokePolicy
