Set-StrictMode -Version Latest

function Add-WebViewBridgeFinding {
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

function Get-WebViewBridgePolicyArray {
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

function Read-WebViewBridgeContract {
    param([Parameter(Mandatory = $true)][string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "WebView bridge contract not found: $Path"
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Test-WebViewBridgeName {
    param([AllowNull()][object] $Value)

    if ($null -eq $Value) {
        return $false
    }

    return ([string]$Value) -match '^[a-z][a-zA-Z0-9.:-]*$'
}

function Test-WebViewBridgeSchema {
    param([AllowNull()][object] $Schema)

    if ($null -eq $Schema) {
        return $false
    }

    $schemaType = $Schema.PSObject.Properties['type']
    if ($null -eq $schemaType -or [string]::IsNullOrWhiteSpace([string]$schemaType.Value)) {
        return $false
    }

    if ([string]$schemaType.Value -eq 'object') {
        $properties = $Schema.PSObject.Properties['properties']
        if ($null -eq $properties -or $null -eq $properties.Value) {
            return $false
        }
    }

    return $true
}

function Test-WebViewBridgeContract {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Contract,

        [switch] $DryRun
    )

    $findings = @()
    $checks = @()

    if (-not $DryRun) {
        $findings += Add-WebViewBridgeFinding -Id 'dry-run-flag-required' -Severity 'fail' -Path '<runner>' -Message 'M3 WebView bridge contract validator requires the dry-run flag.'
    }

    $dryRunOnlyProperty = $Contract.PSObject.Properties['dryRunOnly']
    $dryRunOnly = $null -ne $dryRunOnlyProperty -and $dryRunOnlyProperty.Value -eq $true
    $checks += [pscustomobject]@{
        type = 'policy-safety'
        name = 'dryRunOnly'
        passed = $dryRunOnly
    }
    if (-not $dryRunOnly) {
        $findings += Add-WebViewBridgeFinding -Id 'policy-not-dry-run-only' -Severity 'fail' -Path '<contract>' -Message 'M3 WebView bridge contract must be dry-run only.'
    }

    foreach ($runtimePath in (Get-WebViewBridgePolicyArray -Policy $Contract -Name 'runtimePaths')) {
        $runtimePathText = [string]$runtimePath
        if ($runtimePathText -match '(?i)AppData|Cookies|cookie|\.log|logs|crash|dump|Local Storage|IndexedDB') {
            $findings += Add-WebViewBridgeFinding -Id 'unsafe-runtime-path' -Severity 'fail' -Path '<contract>' -Message 'M3 contract checks must not read user runtime paths, logs, cookies, DBs or dumps.'
        }
    }

    foreach ($diagnostic in (Get-WebViewBridgePolicyArray -Policy $Contract -Name 'diagnostics')) {
        $diagnosticText = [string]$diagnostic
        if ($diagnosticText -match '(?i)cdp|debug|remote-debugging|devtools|port') {
            $findings += Add-WebViewBridgeFinding -Id 'unsafe-diagnostic' -Severity 'fail' -Path '<contract>' -Message 'M3 contract checks must not require WebView debug/CDP diagnostics.'
        }
    }

    $commandNames = @{}
    $eventNames = @{}

    foreach ($command in (Get-WebViewBridgePolicyArray -Policy $Contract -Name 'commands')) {
        $name = [string]$command.name
        $path = "commands/$name"
        $validName = Test-WebViewBridgeName -Value $command.name
        $validDirection = ([string]$command.direction) -eq 'web -> native'
        $validPayload = Test-WebViewBridgeSchema -Schema $command.payloadSchema
        $hasEffect = -not [string]::IsNullOrWhiteSpace([string]$command.expectedEffect)
        $hasErrorBehavior = -not [string]::IsNullOrWhiteSpace([string]$command.errorBehavior)
        $safeLogging = ([string]$command.loggingPolicy) -match '(?i)saniti[sz]ed|no secrets|no payload values'
        $prodSafe = ([string]$command.productionSafety) -match 'PROD_SAFE'

        $checks += [pscustomobject]@{
            type = 'command-contract'
            name = $name
            passed = ($validName -and $validDirection -and $validPayload -and $hasEffect -and $hasErrorBehavior -and $safeLogging -and $prodSafe)
        }

        if (-not $validName) {
            $findings += Add-WebViewBridgeFinding -Id 'invalid-command-name' -Severity 'fail' -Path $path -Message 'Bridge command name must be stable lower camel/dotted identifier.'
        }
        if ($commandNames.ContainsKey($name)) {
            $findings += Add-WebViewBridgeFinding -Id 'duplicate-command-name' -Severity 'fail' -Path $path -Message 'Bridge command name is duplicated.'
        }
        else {
            $commandNames[$name] = $true
        }
        if (-not $validDirection) {
            $findings += Add-WebViewBridgeFinding -Id 'invalid-command-direction' -Severity 'fail' -Path $path -Message 'Bridge commands must use web -> native direction.'
        }
        if (-not $validPayload) {
            $findings += Add-WebViewBridgeFinding -Id 'missing-command-payload-schema' -Severity 'fail' -Path $path -Message 'Bridge command must define a payload schema.'
        }
        if (-not $hasEffect) {
            $findings += Add-WebViewBridgeFinding -Id 'missing-command-effect' -Severity 'fail' -Path $path -Message 'Bridge command must define an expected effect.'
        }
        if (-not $hasErrorBehavior) {
            $findings += Add-WebViewBridgeFinding -Id 'missing-command-error-behavior' -Severity 'fail' -Path $path -Message 'Bridge command must define error behavior.'
        }
        if (-not $safeLogging) {
            $findings += Add-WebViewBridgeFinding -Id 'unsafe-command-logging-policy' -Severity 'fail' -Path $path -Message 'Bridge command logging policy must require sanitized logs and no secrets.'
        }
        if (-not $prodSafe) {
            $findings += Add-WebViewBridgeFinding -Id 'missing-command-production-safety' -Severity 'fail' -Path $path -Message 'Bridge command must be classified as PROD_SAFE local contract only.'
        }
    }

    foreach ($event in (Get-WebViewBridgePolicyArray -Policy $Contract -Name 'events')) {
        $name = [string]$event.name
        $path = "events/$name"
        $validName = Test-WebViewBridgeName -Value $event.name
        $validDirection = ([string]$event.direction) -eq 'native -> web'
        $validPayload = Test-WebViewBridgeSchema -Schema $event.payloadSchema
        $hasErrorBehavior = -not [string]::IsNullOrWhiteSpace([string]$event.errorBehavior)
        $safeLogging = ([string]$event.loggingPolicy) -match '(?i)saniti[sz]ed|no secrets|no payload values'
        $prodSafe = ([string]$event.productionSafety) -match 'PROD_SAFE'

        $checks += [pscustomobject]@{
            type = 'event-contract'
            name = $name
            passed = ($validName -and $validDirection -and $validPayload -and $hasErrorBehavior -and $safeLogging -and $prodSafe)
        }

        if (-not $validName) {
            $findings += Add-WebViewBridgeFinding -Id 'invalid-event-name' -Severity 'fail' -Path $path -Message 'Bridge event name must be stable lower camel/dotted identifier.'
        }
        if ($eventNames.ContainsKey($name)) {
            $findings += Add-WebViewBridgeFinding -Id 'duplicate-event-name' -Severity 'fail' -Path $path -Message 'Bridge event name is duplicated.'
        }
        else {
            $eventNames[$name] = $true
        }
        if (-not $validDirection) {
            $findings += Add-WebViewBridgeFinding -Id 'invalid-event-direction' -Severity 'fail' -Path $path -Message 'Bridge events must use native -> web direction.'
        }
        if (-not $validPayload) {
            $findings += Add-WebViewBridgeFinding -Id 'missing-event-payload-schema' -Severity 'fail' -Path $path -Message 'Bridge event must define a payload schema.'
        }
        if (-not $hasErrorBehavior) {
            $findings += Add-WebViewBridgeFinding -Id 'missing-event-error-behavior' -Severity 'fail' -Path $path -Message 'Bridge event must define malformed payload behavior.'
        }
        if (-not $safeLogging) {
            $findings += Add-WebViewBridgeFinding -Id 'unsafe-event-logging-policy' -Severity 'fail' -Path $path -Message 'Bridge event logging policy must require sanitized logs and no secrets.'
        }
        if (-not $prodSafe) {
            $findings += Add-WebViewBridgeFinding -Id 'missing-event-production-safety' -Severity 'fail' -Path $path -Message 'Bridge event must be classified as PROD_SAFE local contract only.'
        }
    }

    foreach ($case in (Get-WebViewBridgePolicyArray -Policy $Contract -Name 'fakeNativeHostCases')) {
        $caseName = [string]$case.name
        $path = "fakeNativeHostCases/$caseName"
        $caseType = [string]$case.type
        $target = [string]$case.target
        $expected = [string]$case.expectedResult
        $validType = $caseType -in @('command', 'event', 'malformed-command', 'malformed-event')
        $targetKnown = $commandNames.ContainsKey($target) -or $eventNames.ContainsKey($target)
        $hasExpectedResult = -not [string]::IsNullOrWhiteSpace($expected)
        $rejectsMalformed = ($caseType -notmatch 'malformed') -or ($expected -match '(?i)reject|error|ignore')

        $checks += [pscustomobject]@{
            type = 'fake-native-host-case'
            name = $caseName
            target = $target
            passed = ($validType -and $targetKnown -and $hasExpectedResult -and $rejectsMalformed)
        }

        if (-not $validType) {
            $findings += Add-WebViewBridgeFinding -Id 'invalid-fake-host-case-type' -Severity 'fail' -Path $path -Message 'Fake native host case type is not supported.'
        }
        if (-not $targetKnown) {
            $findings += Add-WebViewBridgeFinding -Id 'unknown-fake-host-target' -Severity 'fail' -Path $path -Message 'Fake native host case targets an unknown command or event.'
        }
        if (-not $hasExpectedResult) {
            $findings += Add-WebViewBridgeFinding -Id 'missing-fake-host-expected-result' -Severity 'fail' -Path $path -Message 'Fake native host case must define an expected result.'
        }
        if (-not $rejectsMalformed) {
            $findings += Add-WebViewBridgeFinding -Id 'malformed-case-not-rejected' -Severity 'fail' -Path $path -Message 'Malformed fake native host cases must expect rejection, error or ignore behavior.'
        }
    }

    if ($commandNames.Count -eq 0) {
        $findings += Add-WebViewBridgeFinding -Id 'missing-commands' -Severity 'fail' -Path '<contract>' -Message 'Contract must define at least one web -> native command.'
    }
    if ($eventNames.Count -eq 0) {
        $findings += Add-WebViewBridgeFinding -Id 'missing-events' -Severity 'fail' -Path '<contract>' -Message 'Contract must define at least one native -> web event.'
    }

    $failFindings = @($findings | Where-Object { $_.severity -eq 'fail' })
    return [pscustomobject]@{
        gate = 'WebViewBridgeContract'
        dryRun = [bool]$DryRun
        launchedClient = $false
        processStarted = $false
        enabledWebViewDebugPort = $false
        debugPortUsed = $false
        authAttempted = $false
        gameSessionStarted = $false
        readRuntimeUserData = $false
        passed = ($failFindings.Count -eq 0)
        commandCount = $commandNames.Count
        eventCount = $eventNames.Count
        checks = $checks
        findings = $findings
    }
}

Export-ModuleMember -Function `
    Read-WebViewBridgeContract, `
    Test-WebViewBridgeContract
