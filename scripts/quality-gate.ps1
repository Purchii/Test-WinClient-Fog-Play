param(
    [ValidateSet('Context', 'ActiveRunSafety', 'RunnerSafety', 'TestDataSafety', 'SyntheticUsersSafety', 'AllowedGamesSafety', 'ResourceBudgetSafety', 'ProdMetadataSafety', 'ProdMatrixSafety', 'BacklogSafety', 'ProdSafety', 'Release', 'Privacy', 'AppSmoke', 'BridgeContract', 'BackendSmoke', 'GameSessionCanary', 'NonProdFoundation', 'UpdateManifest', 'TestabilityGaps', 'Full')]
    [string] $Scope = 'Full'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)]
        [string] $RelativePath
    )

    $path = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required path is missing: $RelativePath"
    }
}

function Assert-ScriptsReadmeInventory {
    $readmePath = Join-Path $repoRoot 'scripts/README.md'
    if (-not (Test-Path -LiteralPath $readmePath -PathType Leaf)) {
        throw 'Required path is missing: scripts/README.md'
    }

    $readme = Get-Content -LiteralPath $readmePath -Raw
    $scriptNames = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'scripts') -Filter '*.ps1' -File |
        Sort-Object Name |
        ForEach-Object { $_.Name }

    foreach ($scriptName in $scriptNames) {
        if ($readme -notmatch [regex]::Escape($scriptName)) {
            throw "scripts/README.md does not list runner: $scriptName"
        }
    }
}

function Assert-QualityGateDocsInventory {
    $docsPath = Join-Path $repoRoot 'docs/context/engineering/quality-gates.md'
    $scriptPath = Join-Path $repoRoot 'scripts/quality-gate.ps1'
    if (-not (Test-Path -LiteralPath $docsPath -PathType Leaf)) {
        throw 'Required path is missing: docs/context/engineering/quality-gates.md'
    }
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        throw 'Required path is missing: scripts/quality-gate.ps1'
    }

    $docs = Get-Content -LiteralPath $docsPath -Raw
    $script = Get-Content -LiteralPath $scriptPath -Raw
    $validateSetMatch = [regex]::Match($script, "\[ValidateSet\((?<values>[^\)]*)\)\]")
    if (-not $validateSetMatch.Success) {
        throw 'quality-gate.ps1 does not declare a ValidateSet for -Scope.'
    }

    $scopes = [regex]::Matches($validateSetMatch.Groups['values'].Value, "'([^']+)'") |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object -Unique

    foreach ($scopeName in $scopes) {
        if ($docs -notmatch "-Scope\s+$([regex]::Escape($scopeName))(\s|`r|`n|$)") {
            throw "docs/context/engineering/quality-gates.md does not list quality gate scope: $scopeName"
        }
    }
}

function Invoke-ContextGate {
    $required = @(
        'AGENTS.md',
        'docs/context/current-state.md',
        'docs/context/handoff/active-run.md',
        'docs/context/handoff/context-protocol.md',
        'docs/context/handoff/executor-policy.md',
        'docs/context/handoff/executor-checklist.md',
        'docs/context/governance/decisions-log.md',
        'docs/context/governance/session-log.md',
        'docs/context/governance/context-integrity-checklist.md',
        'docs/context/engineering/git-workflow.md',
        'docs/context/engineering/implementation-status.md',
        'docs/context/engineering/verification-memory.md',
        'docs/context/engineering/quality-gates.md',
        'docs/codex/autonomy-modes.md',
        'docs/codex/milestone-planning-policy.md',
        'docs/codex/communication-policy.md',
        'docs/codex/agent-roles.md',
        'docs/codex/prod-safe-codex-rules.md'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    Assert-ScriptsReadmeInventory
    Assert-QualityGateDocsInventory

    Write-Host 'Context gate passed.'
}

function Invoke-ActiveRunSafetyGate {
    $activeRunPath = Join-Path $repoRoot 'docs/context/handoff/active-run.md'
    $currentStatePath = Join-Path $repoRoot 'docs/context/current-state.md'
    $contextProtocolPath = Join-Path $repoRoot 'docs/context/handoff/context-protocol.md'
    $executorPolicyPath = Join-Path $repoRoot 'docs/context/handoff/executor-policy.md'
    Assert-PathExists 'docs/context/handoff/active-run.md'
    Assert-PathExists 'docs/context/current-state.md'
    Assert-PathExists 'docs/context/handoff/context-protocol.md'
    Assert-PathExists 'docs/context/handoff/executor-policy.md'

    $activeRun = Get-Content -LiteralPath $activeRunPath -Raw
    $currentState = Get-Content -LiteralPath $currentStatePath -Raw
    $contextProtocol = Get-Content -LiteralPath $contextProtocolPath -Raw
    $executorPolicy = Get-Content -LiteralPath $executorPolicyPath -Raw

    foreach ($requiredPhrase in @(
            'Forbidden without a new approved plan',
            'Stop-and-ask triggers',
            'installed client launch',
            'WebView debug/CDP',
            'authentication',
            'real game session',
            'production backend or streaming network interaction',
            'fake/replay server runtime execution',
            'network shaping',
            'hardware inspection',
            'credentials, secrets',
            'reading user AppData',
            'CI/CD enablement',
            'dependency upgrades',
            'weakening ProdGuard/KillSwitch/ResourceBudget/CleanupVerifier',
            'scope expansion beyond local dry-run/schema validation'
        )) {
        if ($activeRun -notmatch [regex]::Escape($requiredPhrase)) {
            throw "active-run.md must document safety boundary phrase: $requiredPhrase"
        }
    }

    if ($activeRun -match '(?i)latest pushed main commit|merged to origin/main at\s+[0-9a-f]{7,40}') {
        throw 'active-run.md must not record stale literal latest-pushed commit markers; use git log instead.'
    }

    foreach ($scopeName in @('SyntheticUsersSafety', 'AllowedGamesSafety', 'ResourceBudgetSafety', 'ProdMetadataSafety')) {
        if ($activeRun -notmatch [regex]::Escape($scopeName)) {
            throw "active-run.md must mention current static safety gate: $scopeName"
        }
        if ($currentState -notmatch [regex]::Escape($scopeName)) {
            throw "current-state.md must mention current static safety gate: $scopeName"
        }
    }
    if ($currentState -notmatch [regex]::Escape('ActiveRunSafety')) {
        throw 'current-state.md must mention ActiveRunSafety.'
    }

    if ($contextProtocol -notmatch 'git log --oneline --decorate -1') {
        throw 'context-protocol.md must identify git log as the authoritative latest commit source.'
    }
    if ($executorPolicy -notmatch 'Do not merge to main without explicit user approval') {
        throw 'executor-policy.md must preserve the explicit main-merge approval rule.'
    }

    Write-Host 'ActiveRunSafety gate passed.'
}

function Invoke-RunnerSafetyGate {
    $scriptRoot = Join-Path $repoRoot 'scripts'
    $runnerScripts = Get-ChildItem -LiteralPath $scriptRoot -Filter 'run-*.ps1' -File | Sort-Object Name
    if ($runnerScripts.Count -eq 0) {
        throw 'No runner scripts were found under scripts/run-*.ps1.'
    }

    $allowedNonBlockingAllowSwitches = @(
        'AllowProdConditional'
    )
    $forbiddenRuntimeCommands = @(
        'Start-Process',
        'Invoke-WebRequest',
        'Invoke-RestMethod',
        'curl.exe',
        'iwr',
        'irm'
    )
    $forbiddenRuntimeTypePatterns = @(
        'System\.Net\.Http\.HttpClient',
        'Net\.WebClient',
        'System\.Net\.WebRequest'
    )
    $forbiddenRuntimePatterns = @(
        '(?i)C:\\Users\\[^''"`\s]+\\AppData',
        '(?i)\\AppData\\',
        '(?i)\\Cookies\\',
        '(?i)\\Local Storage\\',
        '(?i)\\IndexedDB\\'
    )

    foreach ($runner in $runnerScripts) {
        $relative = "scripts/$($runner.Name)"
        $text = Get-Content -LiteralPath $runner.FullName -Raw

        if ($text -notmatch '\[switch\]\s*\$DryRun') {
            throw "$relative must expose a -DryRun switch."
        }
        if ($text -notmatch 'if\s*\(\s*-not\s+\$DryRun\s*\)') {
            throw "$relative must fail closed when -DryRun is missing."
        }

        $allowSwitchMatches = [regex]::Matches($text, '\[switch\]\s*\$(Allow[A-Za-z0-9]+)')
        foreach ($match in $allowSwitchMatches) {
            $switchName = $match.Groups[1].Value
            if ($allowedNonBlockingAllowSwitches -contains $switchName) {
                continue
            }

            $guardPattern = 'if\s*\(\s*\$' + [regex]::Escape($switchName) + '\s*\)'
            if ($text -notmatch $guardPattern) {
                throw "$relative exposes -$switchName but does not explicitly reject it."
            }
        }

        foreach ($pattern in $forbiddenRuntimePatterns) {
            if ($text -match $pattern) {
                throw "$relative contains forbidden runtime user-data path pattern: $pattern"
            }
        }
    }

    $staticSafetyFiles = @(
        Get-ChildItem -LiteralPath (Join-Path $repoRoot 'scripts') -Filter '*.ps1' -File
        Get-ChildItem -LiteralPath (Join-Path $repoRoot 'src/TestFramework') -Recurse -File |
            Where-Object { $_.Extension -in @('.ps1', '.psm1') }
    )
    foreach ($file in $staticSafetyFiles) {
        $relative = $file.FullName.Substring($repoRoot.Length + 1) -replace '\\', '/'
        $text = Get-Content -LiteralPath $file.FullName -Raw
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors)
        if (@($parseErrors).Count -gt 0) {
            throw "$relative could not be parsed for runner safety checks."
        }

        $commands = $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true)
        foreach ($command in $commands) {
            $commandName = $command.GetCommandName()
            if ($null -ne $commandName -and $forbiddenRuntimeCommands -contains $commandName) {
                throw "$relative contains forbidden runtime/network command: $commandName"
            }
        }

        foreach ($pattern in $forbiddenRuntimeTypePatterns) {
            if ($text -match $pattern) {
                throw "$relative contains forbidden runtime/network type pattern: $pattern"
            }
        }
    }

    Write-Host 'RunnerSafety gate passed.'
}

function Test-PathMatchesAnyPattern {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Value,

        [Parameter(Mandatory = $true)]
        [string[]] $Patterns
    )

    foreach ($pattern in $Patterns) {
        if ($Value -match $pattern) {
            return $true
        }
    }

    return $false
}

function Invoke-TestDataSafetyGate {
    $testDataRoot = Join-Path $repoRoot 'testdata'
    Assert-PathExists 'testdata'

    $textExtensions = @(
        '.json',
        '.yaml',
        '.yml',
        '.txt',
        '.log',
        '.js',
        '.map',
        '.html',
        '.css'
    )
    $allowedUnsafeFixturePathPatterns = @(
        '(?i)(^|/)backend-smoke-unsafe\.example\.json$',
        '(?i)(^|/)webview-bridge-contract-unsafe\.example\.json$',
        '(?i)(^|/)update-manifest-unsafe\.example\.json$',
        '(?i)(^|/)testability-gaps-unsafe\.example\.json$',
        '(?i)(^|/)app-webview-smoke-unsafe-policy\.example\.json$',
        '(?i)(^|/)game-session-canary-unsafe\.example\.json$',
        '(?i)(^|/)nonprod-foundation-unsafe\.example\.json$',
        '(?i)(^|/)privacy-negative-fixture/',
        '(?i)(^|/)privacy-large-fixture/',
        '(?i)(^|/)release-fixture/bin/installer_info\.txt$',
        '(?i)(^|/)privacy-patterns[^/]*\.example\.json$'
    )
    $riskyPatterns = @(
        @{ Id = 'absolute-user-path'; Pattern = '(?i)C:\\Users\\[^''"`\s]+' },
        @{ Id = 'runtime-user-data-path'; Pattern = '(?i)(AppData|Cookies|Local Storage|IndexedDB|\.db|\\logs\\|/logs/)' },
        @{ Id = 'bearer-token'; Pattern = '(?i)Authorization\s*:\s*Bearer\s+[A-Za-z0-9._~+\/=-]+' },
        @{ Id = 'password-assignment'; Pattern = '(?i)(password|passwd)\s*[:=]\s*[''"]?[^''"`\s,}]{8,}' },
        @{ Id = 'token-assignment'; Pattern = '(?i)(^|[^A-Za-z0-9_-])(access[_-]?token|refresh[_-]?token|token)\s*[:=]\s*[''"]?[^''"`\s,}]{12,}' }
    )

    $files = Get-ChildItem -LiteralPath $testDataRoot -Recurse -File
    foreach ($file in $files) {
        if ($textExtensions -notcontains $file.Extension.ToLowerInvariant()) {
            continue
        }
        if ($file.Length -gt 1048576) {
            throw "TestDataSafety refuses to scan oversized text fixture: $($file.FullName)"
        }

        $relative = $file.FullName.Substring($repoRoot.Length + 1) -replace '\\', '/'
        $testDataRelative = $relative.Substring('testdata/'.Length)
        $text = Get-Content -LiteralPath $file.FullName -Raw
        if ($null -eq $text) {
            continue
        }

        $allowedUnsafeFixture = Test-PathMatchesAnyPattern -Value $testDataRelative -Patterns $allowedUnsafeFixturePathPatterns
        foreach ($riskyPattern in $riskyPatterns) {
            if ($text -match $riskyPattern.Pattern -and -not $allowedUnsafeFixture) {
                throw "$relative contains risky fixture content outside the unsafe/negative allowlist: $($riskyPattern.Id)"
            }
        }

        $urlMatches = [regex]::Matches($text, 'https?://[^\s''"`<>)]+')
        foreach ($match in $urlMatches) {
            $url = $match.Value.TrimEnd('.', ',', ';')
            if ($url -notmatch '^https?://[^/]*example\.invalid(/|$)' -and -not $allowedUnsafeFixture) {
                throw "$relative contains non-placeholder URL outside the unsafe/negative allowlist: $url"
            }
        }
    }

    Write-Host 'TestDataSafety gate passed.'
}

function Get-JsonPropertyRecords {
    param(
        [AllowNull()]
        [object] $Value,

        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    $records = @()
    if ($null -eq $Value) {
        return $records
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string] -and $Value -isnot [pscustomobject]) {
        $index = 0
        foreach ($item in $Value) {
            $records += @(Get-JsonPropertyRecords -Value $item -Path "$Path[$index]")
            $index += 1
        }
        return $records
    }

    if ($Value -is [pscustomobject]) {
        foreach ($property in $Value.PSObject.Properties) {
            $propertyPath = "$Path.$($property.Name)"
            $records += [pscustomobject]@{
                Name = $property.Name
                Path = $propertyPath
                Value = $property.Value
            }
            $records += @(Get-JsonPropertyRecords -Value $property.Value -Path $propertyPath)
        }
    }

    return $records
}

function Invoke-SyntheticUsersSafetyGate {
    $policyPath = Join-Path $repoRoot 'docs/qa/synthetic-users-policy.md'
    $fixturePath = Join-Path $repoRoot 'testdata/synthetic-users.example.json'
    Assert-PathExists 'docs/qa/synthetic-users-policy.md'
    Assert-PathExists 'testdata/synthetic-users.example.json'

    $policy = Get-Content -LiteralPath $policyPath -Raw
    foreach ($requiredPolicyPhrase in @('allowlisted synthetic accounts', 'hardcoded credentials', 'tokens/passwords')) {
        if ($policy -notmatch [regex]::Escape($requiredPolicyPhrase)) {
            throw "Synthetic users policy must document: $requiredPolicyPhrase"
        }
    }

    $text = Get-Content -LiteralPath $fixturePath -Raw
    $data = $text | ConvertFrom-Json
    if ($null -eq $data.syntheticUsers) {
        throw "Synthetic users fixture must contain a top-level 'syntheticUsers' array."
    }

    $forbiddenPropertyPattern = '(?i)(password|passwd|secret|token|cookie|credential|auth|authorization|email|phone|username|login)'
    $forbiddenValuePatterns = @(
        @{ Id = 'absolute-user-path'; Pattern = '(?i)C:\\Users\\[^''"`\s]+' },
        @{ Id = 'runtime-user-data-path'; Pattern = '(?i)(AppData|Cookies|Local Storage|IndexedDB|\.db|\\logs\\|/logs/)' },
        @{ Id = 'url'; Pattern = 'https?://[^\s''"`<>)]+' },
        @{ Id = 'email'; Pattern = '(?i)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}' },
        @{ Id = 'bearer-token'; Pattern = '(?i)Bearer\s+[A-Za-z0-9._~+\/=-]+' }
    )
    $allowedUserProperties = @(
        'alias',
        'purpose',
        'allowedEnvironments',
        'canStartGameSession',
        'maxSessionDurationSeconds'
    )
    $allowedEnvironments = @('local', 'staging', 'production')
    $allowedPurposes = @(
        'prod_safe_login_logout',
        'prod_conditional_stream_canary'
    )

    foreach ($record in (Get-JsonPropertyRecords -Value $data -Path '$')) {
        if ($record.Name -match $forbiddenPropertyPattern) {
            throw "Synthetic users fixture contains forbidden property '$($record.Name)' at $($record.Path)."
        }
        if ($record.Value -is [string]) {
            foreach ($pattern in $forbiddenValuePatterns) {
                if ($record.Value -match $pattern.Pattern) {
                    throw "Synthetic users fixture contains forbidden value pattern '$($pattern.Id)' at $($record.Path)."
                }
            }
        }
    }

    $users = @($data.syntheticUsers)
    if ($users.Count -eq 0) {
        throw 'Synthetic users fixture must contain at least one allowlisted user alias.'
    }

    $aliases = @{}
    foreach ($user in $users) {
        foreach ($property in $user.PSObject.Properties) {
            if ($allowedUserProperties -notcontains $property.Name) {
                throw "Synthetic user '$($user.alias)' contains unsupported property '$($property.Name)'."
            }
        }

        $alias = [string]$user.alias
        if ($alias -notmatch '^qa-[a-z0-9-]+-\d{3}$') {
            throw "Synthetic user alias must be a non-secret qa-* alias with a numeric suffix: $alias"
        }
        if ($aliases.ContainsKey($alias)) {
            throw "Synthetic user alias is duplicated: $alias"
        }
        $aliases[$alias] = $true

        $purpose = [string]$user.purpose
        if ($allowedPurposes -notcontains $purpose) {
            throw "Synthetic user '$alias' has unsupported purpose '$purpose'."
        }

        $envs = @($user.allowedEnvironments)
        if ($envs.Count -eq 0) {
            throw "Synthetic user '$alias' must declare allowedEnvironments."
        }
        foreach ($env in $envs) {
            if ($allowedEnvironments -notcontains [string]$env) {
                throw "Synthetic user '$alias' has unsupported environment '$env'."
            }
        }
        if (-not ($envs -contains 'production')) {
            throw "Synthetic user '$alias' must explicitly declare production if it is in the production allowlist fixture."
        }

        if ($user.canStartGameSession -isnot [bool]) {
            throw "Synthetic user '$alias' must explicitly set canStartGameSession as a boolean."
        }

        if ($user.canStartGameSession -eq $true) {
            if ($alias -notmatch '^qa-canary-') {
                throw "Only qa-canary-* aliases may set canStartGameSession=true: $alias"
            }
            if ($purpose -ne 'prod_conditional_stream_canary') {
                throw "Synthetic user '$alias' can start game sessions only for prod_conditional_stream_canary."
            }

            $maxSessionDurationSeconds = [int]$user.maxSessionDurationSeconds
            if ($maxSessionDurationSeconds -lt 1 -or $maxSessionDurationSeconds -gt 120) {
                throw "Synthetic user '$alias' game-session duration must be between 1 and 120 seconds."
            }
        }
        elseif ($purpose -eq 'prod_safe_login_logout' -and $user.canStartGameSession -ne $false) {
            throw "Synthetic user '$alias' for prod_safe_login_logout must not be able to start game sessions."
        }
    }

    Write-Host 'SyntheticUsersSafety gate passed.'
}

function Invoke-AllowedGamesSafetyGate {
    $allowedGamesPath = Join-Path $repoRoot 'testdata/allowed-games.example.json'
    $canaryPolicyPath = Join-Path $repoRoot 'docs/qa/game-session-canary.md'
    Assert-PathExists 'testdata/allowed-games.example.json'
    Assert-PathExists 'docs/qa/game-session-canary.md'

    $policy = Get-Content -LiteralPath $canaryPolicyPath -Raw
    foreach ($requiredPolicyPhrase in @('target game is allowlisted', 'allowed-games.example.json')) {
        if ($policy -notmatch [regex]::Escape($requiredPolicyPhrase)) {
            throw "Game-session canary policy must document allowed-games usage: $requiredPolicyPhrase"
        }
    }

    $text = Get-Content -LiteralPath $allowedGamesPath -Raw
    $data = $text | ConvertFrom-Json
    if ($null -eq $data.allowedGames) {
        throw "Allowed games fixture must contain a top-level 'allowedGames' array."
    }

    $forbiddenPropertyPattern = '(?i)(password|passwd|secret|token|cookie|credential|auth|authorization|url|endpoint|title|name)'
    $forbiddenValuePatterns = @(
        @{ Id = 'absolute-user-path'; Pattern = '(?i)C:\\Users\\[^''"`\s]+' },
        @{ Id = 'runtime-user-data-path'; Pattern = '(?i)(AppData|Cookies|Local Storage|IndexedDB|\.db|\\logs\\|/logs/)' },
        @{ Id = 'url'; Pattern = 'https?://[^\s''"`<>)]+' },
        @{ Id = 'bearer-token'; Pattern = '(?i)Bearer\s+[A-Za-z0-9._~+\/=-]+' }
    )
    foreach ($record in (Get-JsonPropertyRecords -Value $data -Path '$')) {
        if ($record.Name -match $forbiddenPropertyPattern) {
            throw "Allowed games fixture contains forbidden property '$($record.Name)' at $($record.Path)."
        }
        if ($record.Value -is [string]) {
            foreach ($pattern in $forbiddenValuePatterns) {
                if ($record.Value -match $pattern.Pattern) {
                    throw "Allowed games fixture contains forbidden value pattern '$($pattern.Id)' at $($record.Path)."
                }
            }
        }
    }

    $allowedGameProperties = @('alias', 'environment', 'allowedFor')
    $allowedEnvironments = @('local', 'staging', 'production')
    $allowedPurposes = @('prod_conditional_stream_canary')
    $aliases = @{}
    $games = @($data.allowedGames)
    if ($games.Count -eq 0) {
        throw 'Allowed games fixture must contain at least one game alias.'
    }

    foreach ($game in $games) {
        foreach ($property in $game.PSObject.Properties) {
            if ($allowedGameProperties -notcontains $property.Name) {
                throw "Allowed game '$($game.alias)' contains unsupported property '$($property.Name)'."
            }
        }

        $alias = [string]$game.alias
        if ($alias -notmatch '^qa-[a-z0-9-]+-\d+$') {
            throw "Allowed game alias must be a non-production qa-* alias with a numeric suffix: $alias"
        }
        if ($aliases.ContainsKey($alias)) {
            throw "Allowed game alias is duplicated: $alias"
        }
        $aliases[$alias] = $true

        $environment = [string]$game.environment
        if ($allowedEnvironments -notcontains $environment) {
            throw "Allowed game '$alias' has unsupported environment '$environment'."
        }
        if ($environment -eq 'production' -and $alias -notmatch '^qa-') {
            throw "Production allowed game must be a QA alias: $alias"
        }

        $allowedFor = @($game.allowedFor)
        if ($allowedFor.Count -eq 0) {
            throw "Allowed game '$alias' must declare allowedFor."
        }
        foreach ($purpose in $allowedFor) {
            if ($allowedPurposes -notcontains [string]$purpose) {
                throw "Allowed game '$alias' has unsupported allowedFor purpose '$purpose'."
            }
        }
    }

    Write-Host 'AllowedGamesSafety gate passed.'
}

function Invoke-ResourceBudgetSafetyGate {
    $policyPath = Join-Path $repoRoot 'docs/qa/resource-budget-policy.md'
    $budgetPath = Join-Path $repoRoot 'testdata/prod-resource-budget.example.yaml'
    $allowedGamesPath = Join-Path $repoRoot 'testdata/allowed-games.example.json'
    $prodSafetyModule = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
    Assert-PathExists 'docs/qa/resource-budget-policy.md'
    Assert-PathExists 'testdata/prod-resource-budget.example.yaml'
    Assert-PathExists 'testdata/allowed-games.example.json'
    Assert-PathExists 'src/TestFramework/ProdSafety/ProdSafety.psm1'

    $policy = Get-Content -LiteralPath $policyPath -Raw
    foreach ($requiredPolicyPhrase in @('Any production test that starts a game session must have a resource budget', 'No uncontrolled retries')) {
        if ($policy -notmatch [regex]::Escape($requiredPolicyPhrase)) {
            throw "Resource budget policy must document: $requiredPolicyPhrase"
        }
    }

    $budgetText = Get-Content -LiteralPath $budgetPath -Raw
    foreach ($pattern in @(
        '(?i)C:\\Users\\[^''"`\s]+',
        '(?i)(AppData|Cookies|Local Storage|IndexedDB|\.db|\\logs\\|/logs/)',
        'https?://[^\s''"`<>)]',
        '(?i)(password|passwd|secret|token|cookie|credential|auth|authorization)\s*:'
    )) {
        if ($budgetText -match $pattern) {
            throw "Resource budget fixture contains forbidden value pattern: $pattern"
        }
    }

    if ($budgetText -notmatch '(?m)^prodResourceBudget:\s*$') {
        throw "Resource budget fixture must contain a top-level 'prodResourceBudget' mapping."
    }

    $allowedBudgetKeys = @(
        'maxSessionsPerRun',
        'maxParallelSessions',
        'maxSessionDurationSeconds',
        'maxRunsPerHour',
        'allowedRegions',
        'allowedGames',
        'requireCleanupVerification',
        'requireExplicitConditionalFlag'
    )
    $budgetKeyMatches = [regex]::Matches($budgetText, '(?m)^\s{2}([A-Za-z0-9_]+):')
    $budgetKeys = @($budgetKeyMatches | ForEach-Object { $_.Groups[1].Value })
    foreach ($expectedKey in $allowedBudgetKeys) {
        if ($budgetKeys -notcontains $expectedKey) {
            throw "Resource budget fixture is missing key: $expectedKey"
        }
    }
    foreach ($key in $budgetKeys) {
        if ($allowedBudgetKeys -notcontains $key) {
            throw "Resource budget fixture contains unsupported key: $key"
        }
    }

    Import-Module $prodSafetyModule -Force
    $budget = Read-ProdResourceBudget -Path $budgetPath
    if ([int]$budget.maxSessionsPerRun -ne 1) {
        throw 'prodResourceBudget.maxSessionsPerRun must be exactly 1.'
    }
    if ([int]$budget.maxParallelSessions -ne 1) {
        throw 'prodResourceBudget.maxParallelSessions must be exactly 1.'
    }
    if ([int]$budget.maxSessionDurationSeconds -lt 1 -or [int]$budget.maxSessionDurationSeconds -gt 120) {
        throw 'prodResourceBudget.maxSessionDurationSeconds must be between 1 and 120.'
    }
    if ([int]$budget.maxRunsPerHour -lt 1 -or [int]$budget.maxRunsPerHour -gt 3) {
        throw 'prodResourceBudget.maxRunsPerHour must be between 1 and 3.'
    }
    if ($budget.requireCleanupVerification -ne $true) {
        throw 'prodResourceBudget.requireCleanupVerification must be true.'
    }
    if ($budget.requireExplicitConditionalFlag -ne $true) {
        throw 'prodResourceBudget.requireExplicitConditionalFlag must be true.'
    }

    $regions = @($budget.allowedRegions)
    if ($regions.Count -eq 0) {
        throw 'prodResourceBudget.allowedRegions must contain at least one region.'
    }
    foreach ($region in $regions) {
        if ([string]$region -notmatch '^[a-z]{2}-[a-z]+$') {
            throw "prodResourceBudget.allowedRegions contains unsupported region alias: $region"
        }
    }

    $allowedGamesData = Get-Content -LiteralPath $allowedGamesPath -Raw | ConvertFrom-Json
    if ($null -eq $allowedGamesData.allowedGames) {
        throw "Allowed games fixture must contain a top-level 'allowedGames' array."
    }
    $productionCanaryGames = @($allowedGamesData.allowedGames | Where-Object {
            $_.environment -eq 'production' -and @($_.allowedFor) -contains 'prod_conditional_stream_canary'
        } | ForEach-Object { $_.alias })

    $budgetGames = @($budget.allowedGames)
    if ($budgetGames.Count -eq 0) {
        throw 'prodResourceBudget.allowedGames must contain at least one game alias.'
    }
    foreach ($game in $budgetGames) {
        if ([string]$game -notmatch '^qa-[a-z0-9-]+-\d+$') {
            throw "prodResourceBudget.allowedGames contains unsupported game alias: $game"
        }
        if ($productionCanaryGames -notcontains [string]$game) {
            throw "prodResourceBudget.allowedGames contains a game that is not allowlisted for production canary: $game"
        }
    }

    Write-Host 'ResourceBudgetSafety gate passed.'
}

function Invoke-ProdMetadataSafetyGate {
    $policyPath = Join-Path $repoRoot 'docs/qa/prod-testing-policy.md'
    $metadataPath = Join-Path $repoRoot 'testdata/prod-safety-tests.example.json'
    $prodSafetyModule = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
    Assert-PathExists 'docs/qa/prod-testing-policy.md'
    Assert-PathExists 'testdata/prod-safety-tests.example.json'
    Assert-PathExists 'src/TestFramework/ProdSafety/ProdSafety.psm1'

    $policy = Get-Content -LiteralPath $policyPath -Raw
    foreach ($requiredPolicyPhrase in @('Every test must be classified', 'No classification = no prod run', 'No resource budget = no prod game session test')) {
        if ($policy -notmatch [regex]::Escape($requiredPolicyPhrase)) {
            throw "Production testing policy must document: $requiredPolicyPhrase"
        }
    }

    $text = Get-Content -LiteralPath $metadataPath -Raw
    $data = $text | ConvertFrom-Json
    if ($null -eq $data.tests) {
        throw "Prod metadata fixture must contain a top-level 'tests' array."
    }

    $forbiddenPropertyPattern = '(?i)(password|passwd|secret|token|cookie|credential|auth|authorization|url|endpoint)'
    $forbiddenValuePatterns = @(
        @{ Id = 'absolute-user-path'; Pattern = '(?i)C:\\Users\\[^''"`\s]+' },
        @{ Id = 'runtime-user-data-path'; Pattern = '(?i)(AppData|Cookies|Local Storage|IndexedDB|\.db|\\logs\\|/logs/)' },
        @{ Id = 'url'; Pattern = 'https?://[^\s''"`<>)]+' },
        @{ Id = 'bearer-token'; Pattern = '(?i)Bearer\s+[A-Za-z0-9._~+\/=-]+' }
    )
    foreach ($record in (Get-JsonPropertyRecords -Value $data -Path '$')) {
        if ($record.Name -match $forbiddenPropertyPattern) {
            throw "Prod metadata fixture contains forbidden property '$($record.Name)' at $($record.Path)."
        }
        if ($record.Value -is [string]) {
            foreach ($pattern in $forbiddenValuePatterns) {
                if ($record.Value -match $pattern.Pattern) {
                    throw "Prod metadata fixture contains forbidden value pattern '$($pattern.Id)' at $($record.Path)."
                }
            }
        }
    }

    Import-Module $prodSafetyModule -Force
    $allowedClassifications = @(Get-ProdSafetyClassificationValues)
    $allowedProperties = @(
        'name',
        'classification',
        'suites',
        'requiresSyntheticUserAlias',
        'targetRegion',
        'targetGame',
        'startsGameSession',
        'mutatesState',
        'requiresCleanupVerification'
    )
    $allowedSuites = @('prod-safe-smoke', 'prod-canary')
    $tests = @($data.tests)
    if ($tests.Count -eq 0) {
        throw 'Prod metadata fixture must contain at least one test.'
    }

    $names = @{}
    foreach ($test in $tests) {
        foreach ($property in $test.PSObject.Properties) {
            if ($allowedProperties -notcontains $property.Name) {
                throw "Prod metadata test '$($test.name)' contains unsupported property '$($property.Name)'."
            }
        }

        $name = [string]$test.name
        if ($name -notmatch '^[a-z0-9]+[a-z0-9-]*$') {
            throw "Prod metadata test name must be a stable lowercase id: $name"
        }
        if ($names.ContainsKey($name)) {
            throw "Prod metadata test name is duplicated: $name"
        }
        $names[$name] = $true

        $classification = [string]$test.classification
        if ($allowedClassifications -notcontains $classification) {
            throw "Prod metadata test '$name' has unsupported classification '$classification'."
        }

        $suiteProperty = $test.PSObject.Properties['suites']
        $testSuites = @()
        if ($null -ne $suiteProperty) {
            $testSuites = @($suiteProperty.Value)
        }

        foreach ($suite in $testSuites) {
            if ($allowedSuites -notcontains [string]$suite) {
                throw "Prod metadata test '$name' has unsupported suite '$suite'."
            }
        }

        $startsGameSession = $false
        $mutatesState = $false
        $requiresCleanupVerification = $false
        $alias = ''
        $targetRegion = ''
        $targetGame = ''
        if ($null -ne $test.PSObject.Properties['startsGameSession']) {
            $startsGameSession = $test.startsGameSession -eq $true
        }
        if ($null -ne $test.PSObject.Properties['mutatesState']) {
            $mutatesState = $test.mutatesState -eq $true
        }
        if ($null -ne $test.PSObject.Properties['requiresCleanupVerification']) {
            $requiresCleanupVerification = $test.requiresCleanupVerification -eq $true
        }
        if ($null -ne $test.PSObject.Properties['requiresSyntheticUserAlias']) {
            $alias = [string]$test.requiresSyntheticUserAlias
        }
        if ($null -ne $test.PSObject.Properties['targetRegion']) {
            $targetRegion = [string]$test.targetRegion
        }
        if ($null -ne $test.PSObject.Properties['targetGame']) {
            $targetGame = [string]$test.targetGame
        }

        if ($classification -eq 'PROD_SAFE') {
            if ($startsGameSession -or $mutatesState -or $requiresCleanupVerification) {
                throw "PROD_SAFE metadata test '$name' must remain read-only and cleanup-free."
            }
            if (-not [string]::IsNullOrWhiteSpace($alias) -and $alias -notmatch '^qa-smoke-\d{3}$') {
                throw "PROD_SAFE metadata test '$name' must use a qa-smoke alias when an alias is required."
            }
        }

        if ($testSuites -contains 'prod-safe-smoke' -and $classification -ne 'PROD_SAFE') {
            throw "prod-safe-smoke suite test '$name' must be PROD_SAFE."
        }

        if ($testSuites -contains 'prod-canary') {
            if ($classification -ne 'PROD_CONDITIONAL') {
                throw "prod-canary suite test '$name' must be PROD_CONDITIONAL."
            }
            if ($alias -notmatch '^qa-canary-[a-z0-9-]+-\d{3}$') {
                throw "prod-canary suite test '$name' must require a qa-canary synthetic alias."
            }
            if ([string]::IsNullOrWhiteSpace($targetRegion) -or [string]::IsNullOrWhiteSpace($targetGame)) {
                throw "prod-canary suite test '$name' must declare targetRegion and targetGame."
            }
            if (-not ($startsGameSession -and $mutatesState -and $requiresCleanupVerification)) {
                throw "prod-canary suite test '$name' must declare session start, state mutation and cleanup verification."
            }
        }

        if ($classification -in @('PROD_FORBIDDEN', 'NON_PROD_ONLY') -and $testSuites.Count -gt 0) {
            throw "$classification metadata test '$name' must not be assigned to production runner suites."
        }
    }

    if (@($tests | Where-Object { $suiteProperty = $_.PSObject.Properties['suites']; $null -ne $suiteProperty -and @($suiteProperty.Value) -contains 'prod-safe-smoke' }).Count -eq 0) {
        throw 'Prod metadata fixture must contain at least one prod-safe-smoke test.'
    }
    if (@($tests | Where-Object { $suiteProperty = $_.PSObject.Properties['suites']; $null -ne $suiteProperty -and @($suiteProperty.Value) -contains 'prod-canary' }).Count -ne 1) {
        throw 'Prod metadata fixture must contain exactly one prod-canary test.'
    }

    Write-Host 'ProdMetadataSafety gate passed.'
}

function Invoke-ProdMatrixSafetyGate {
    $matrixPath = Join-Path $repoRoot 'docs/qa/prod-safe-test-matrix.md'
    Assert-PathExists 'docs/qa/prod-safe-test-matrix.md'

    $allowedClassifications = @(
        'PROD_SAFE',
        'PROD_CONDITIONAL',
        'PROD_FORBIDDEN',
        'PROD_FORBIDDEN on production'
    )
    $scenarioRows = @()
    $lines = Get-Content -LiteralPath $matrixPath
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if (-not $trimmed.StartsWith('|')) {
            continue
        }
        if ($trimmed -match '^\|\s*-+') {
            continue
        }

        $columns = @($trimmed.Trim('|').Split('|') | ForEach-Object { $_.Trim() })
        if ($columns.Count -lt 3 -or $columns[0] -eq 'Scenario') {
            continue
        }

        $scenarioRows += [pscustomobject]@{
            Scenario = $columns[0]
            Classification = $columns[1]
            Notes = $columns[2]
        }
    }

    if ($scenarioRows.Count -eq 0) {
        throw 'Prod-safe test matrix must contain at least one scenario row.'
    }

    foreach ($row in $scenarioRows) {
        if ($allowedClassifications -notcontains $row.Classification) {
            throw "Prod-safe matrix scenario '$($row.Scenario)' has unsupported classification '$($row.Classification)'."
        }

        $scenarioText = "$($row.Scenario) $($row.Notes)"
        if ($scenarioText -match '(?i)game session|session canary|reconnect|stream') {
            if ($row.Classification -eq 'PROD_SAFE') {
                throw "Prod-safe matrix scenario '$($row.Scenario)' must not be PROD_SAFE because it can involve sessions/streams."
            }
        }

        if ($scenarioText -match '(?i)rollback|load|stress|chaos|destructive|network') {
            if ($row.Classification -notmatch '^PROD_FORBIDDEN') {
                throw "Prod-safe matrix scenario '$($row.Scenario)' must be PROD_FORBIDDEN on production."
            }
            if ($row.Notes -notmatch 'NON_PROD_ONLY') {
                throw "Prod-safe matrix scenario '$($row.Scenario)' must document NON_PROD_ONLY handling."
            }
        }

        if ($row.Classification -eq 'PROD_CONDITIONAL' -and $row.Notes -notmatch '(?i)requires|allowlisted|budget|cleanup|synthetic') {
            throw "Prod-safe matrix scenario '$($row.Scenario)' must document conditional guard requirements."
        }
    }

    Write-Host 'ProdMatrixSafety gate passed.'
}

function Invoke-BacklogSafetyGate {
    $backlogPath = Join-Path $repoRoot 'docs/qa/value-effort-backlog.md'
    Assert-PathExists 'docs/qa/value-effort-backlog.md'

    $expectedMilestonePrefixes = @('M0', 'M1', 'M2', 'M3', 'M4', 'M5', 'M6')
    $allowedPriorities = @('P0', 'P1', 'P2', 'P0/P1', 'P1/P2')
    $rows = @()
    $lines = Get-Content -LiteralPath $backlogPath
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if (-not $trimmed.StartsWith('|')) {
            continue
        }
        if ($trimmed -match '^\|\s*-+') {
            continue
        }

        $columns = @($trimmed.Trim('|').Split('|') | ForEach-Object { $_.Trim() })
        if ($columns.Count -lt 4 -or $columns[0] -eq 'Milestone') {
            continue
        }

        $rows += [pscustomobject]@{
            Milestone = $columns[0]
            Value = $columns[1]
            Effort = $columns[2]
            Priority = $columns[3]
        }
    }

    if ($rows.Count -ne $expectedMilestonePrefixes.Count) {
        throw "Value/effort backlog must contain exactly $($expectedMilestonePrefixes.Count) milestone rows."
    }

    foreach ($prefix in $expectedMilestonePrefixes) {
        $matches = @($rows | Where-Object { $_.Milestone -match "^$prefix(\s|$)" })
        if ($matches.Count -ne 1) {
            throw "Value/effort backlog must contain exactly one row for $prefix."
        }
    }

    foreach ($row in $rows) {
        $value = 0
        $effort = 0
        if (-not [int]::TryParse($row.Value, [ref]$value) -or $value -lt 1 -or $value -gt 5) {
            throw "Backlog milestone '$($row.Milestone)' has invalid Value '$($row.Value)'."
        }
        if (-not [int]::TryParse($row.Effort, [ref]$effort) -or $effort -lt 1 -or $effort -gt 5) {
            throw "Backlog milestone '$($row.Milestone)' has invalid Effort '$($row.Effort)'."
        }
        if ($allowedPriorities -notcontains $row.Priority) {
            throw "Backlog milestone '$($row.Milestone)' has unsupported Priority '$($row.Priority)'."
        }
        if ($row.Milestone -match '(?i)game-session|Fake|replay|network|hardware' -and $row.Priority -notmatch 'P[12]') {
            throw "Backlog milestone '$($row.Milestone)' must remain P1/P2 until non-production/runtime prerequisites are approved."
        }
    }

    Write-Host 'BacklogSafety gate passed.'
}

function Invoke-ProdSafetyGate {
    $required = @(
        'docs/qa/prod-testing-policy.md',
        'docs/qa/synthetic-users-policy.md',
        'docs/qa/resource-budget-policy.md',
        'docs/qa/prod-safe-test-matrix.md',
        'docs/qa/artifacts-policy.md',
        'docs/qa/flakiness-policy.md',
        'testdata/synthetic-users.example.json',
        'testdata/prod-resource-budget.example.yaml',
        'testdata/prod-safety-tests.example.json',
        'src/TestFramework/ProdSafety/ProdSafety.psm1',
        'src/TestFramework/ProdSafety/ProdSafety.Tests.ps1',
        'scripts/run-prod-safe-smoke.ps1',
        'scripts/run-prod-canary.ps1'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.Tests.ps1')
    & (Join-Path $repoRoot 'scripts/run-prod-safe-smoke.ps1') -Environment production -DryRun

    $canaryScript = Join-Path $repoRoot 'scripts/run-prod-canary.ps1'
    $smokeScript = Join-Path $repoRoot 'scripts/run-prod-safe-smoke.ps1'
    $missingSmokeDryRunRejected = $false
    try {
        & $smokeScript -Environment production | Out-Null
    }
    catch {
        $missingSmokeDryRunRejected = $true
    }
    if (-not $missingSmokeDryRunRejected) {
        throw 'Prod-safe smoke runner must reject calls without -DryRun.'
    }

    $missingCanaryDryRunRejected = $false
    try {
        & $canaryScript -Environment production -AllowProdConditional -CleanupVerified | Out-Null
    }
    catch {
        $missingCanaryDryRunRejected = $true
    }
    if (-not $missingCanaryDryRunRejected) {
        throw 'Prod canary runner must reject calls without -DryRun.'
    }

    & $canaryScript -Environment production -DryRun -ExpectFailure
    & $canaryScript -Environment production -DryRun -AllowProdConditional -CleanupVerified

    Write-Host 'ProdSafety gate passed.'
}

function Invoke-StubGate {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    Write-Host "$Name gate is documented but not implemented in M0."
}

function Invoke-JsonGate {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock] $Command
    )

    $output = & $Command
    $json = ($output | Out-String).Trim()
    if ([string]::IsNullOrWhiteSpace($json)) {
        throw 'Gate command did not return JSON output.'
    }

    return $json | ConvertFrom-Json
}

function Assert-FindingId {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Result,

        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    $matches = @($Result.findings | Where-Object { $_.id -eq $Id })
    if ($matches.Count -eq 0) {
        throw "Expected finding id was not produced: $Id"
    }
}

function Assert-CommandRejected {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock] $Command,

        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    $rejected = $false
    try {
        & $Command | Out-Null
    }
    catch {
        $rejected = $true
    }

    if (-not $rejected) {
        throw $Message
    }
}

function Invoke-ReleaseGate {
    $required = @(
        'docs/qa/release-gates.md',
        'testdata/release-gate-policy.example.json',
        'testdata/release-gate-policy.clean-fixture.json',
        'testdata/release-fixture',
        'testdata/release-clean-fixture',
        'scripts/run-release-gate.ps1'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    $releaseGate = Join-Path $repoRoot 'scripts/run-release-gate.ps1'
    $missingDryRunRejected = $false
    try {
        & $releaseGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/release-fixture') `
            -PolicyPath (Join-Path $repoRoot 'testdata/release-gate-policy.example.json') | Out-Null
    }
    catch {
        $missingDryRunRejected = $true
    }
    if (-not $missingDryRunRejected) {
        throw 'Release gate runner must reject calls without -DryRun.'
    }

    $negative = Invoke-JsonGate {
        & $releaseGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/release-fixture') `
            -PolicyPath (Join-Path $repoRoot 'testdata/release-gate-policy.example.json') `
            -DryRun `
            -ExpectFindings
    }

    if ($negative.passed -ne $false) {
        throw 'Release negative fixture should report passed=false.'
    }
    if (@($negative.signatureResults).Count -lt 4) {
        throw 'Release negative fixture did not exercise signature checks.'
    }
    if (@($negative.versionResults).Count -lt 1) {
        throw 'Release negative fixture did not exercise version metadata checks.'
    }
    Assert-FindingId -Result $negative -Id 'invalid-signature'
    Assert-FindingId -Result $negative -Id 'missing-version-metadata'
    Assert-FindingId -Result $negative -Id 'forbidden-extension'
    Assert-FindingId -Result $negative -Id 'local-user-path'

    $clean = Invoke-JsonGate {
        & $releaseGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/release-clean-fixture') `
            -PolicyPath (Join-Path $repoRoot 'testdata/release-gate-policy.clean-fixture.json') `
            -DryRun
    }

    if ($clean.passed -ne $true) {
        throw 'Release clean fixture should report passed=true.'
    }

    Write-Host 'Release gate passed.'
}

function Invoke-UpdateManifestGate {
    $required = @(
        'docs/qa/update-manifest-gate.md',
        'src/TestFramework/UpdateManifest/UpdateManifest.psm1',
        'src/TestFramework/UpdateManifest/UpdateManifest.Tests.ps1',
        'scripts/run-update-manifest-gate.ps1',
        'testdata/update-manifest.example.json',
        'testdata/update-manifest-unsafe.example.json'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/UpdateManifest/UpdateManifest.Tests.ps1')

    $updateManifest = Join-Path $repoRoot 'scripts/run-update-manifest-gate.ps1'
    Assert-CommandRejected -Message 'Update manifest runner must reject calls without -DryRun.' -Command {
        & $updateManifest `
            -PolicyPath (Join-Path $repoRoot 'testdata/update-manifest.example.json') | Out-Null
    }

    foreach ($flag in @('AllowNetwork', 'AllowExecution', 'AllowRollback', 'AllowCredentials')) {
        Assert-CommandRejected -Message "Update manifest runner must reject -$flag." -Command {
            $params = @{
                PolicyPath = (Join-Path $repoRoot 'testdata/update-manifest.example.json')
                DryRun = $true
            }
            $params[$flag] = $true
            & $updateManifest `
                @params | Out-Null
        }
    }

    $result = Invoke-JsonGate {
        & $updateManifest `
            -PolicyPath (Join-Path $repoRoot 'testdata/update-manifest.example.json') `
            -DryRun
    }

    if ($result.passed -ne $true) {
        throw 'Update manifest fixture should pass.'
    }
    if ($result.networkCallAttempted -ne $false -or $result.updaterStarted -ne $false -or $result.rollbackAttempted -ne $false -or $result.credentialsUsed -ne $false) {
        throw 'Update manifest dry-run must report no network/updater/rollback/credential activity.'
    }

    $negative = Invoke-JsonGate {
        & $updateManifest `
            -PolicyPath (Join-Path $repoRoot 'testdata/update-manifest-unsafe.example.json') `
            -DryRun `
            -ReportOnly
    }
    Assert-FindingId -Result $negative -Id 'policy-not-dry-run-only'
    Assert-FindingId -Result $negative -Id 'network-not-disabled'
    Assert-FindingId -Result $negative -Id 'execution-not-disabled'
    Assert-FindingId -Result $negative -Id 'rollback-not-disabled'
    Assert-FindingId -Result $negative -Id 'credentials-not-disabled'
    Assert-FindingId -Result $negative -Id 'unsafe-endpoint'
    Assert-FindingId -Result $negative -Id 'command-defined'
    Assert-FindingId -Result $negative -Id 'invalid-version'
    Assert-FindingId -Result $negative -Id 'unsafe-artifact-path'
    Assert-FindingId -Result $negative -Id 'invalid-sha256'
    Assert-FindingId -Result $negative -Id 'invalid-size'
    Assert-FindingId -Result $negative -Id 'signature-not-required'
    Assert-FindingId -Result $negative -Id 'rollback-allowed'
    Assert-FindingId -Result $negative -Id 'post-install-command-defined'

    Write-Host 'UpdateManifest gate passed.'
}

function Invoke-PrivacyGate {
    $required = @(
        'docs/qa/privacy-and-logging-checks.md',
        'testdata/privacy-patterns.example.json',
        'testdata/privacy-patterns-small-limit.example.json',
        'testdata/release-fixture',
        'testdata/privacy-clean-fixture',
        'testdata/privacy-negative-fixture',
        'testdata/privacy-large-fixture',
        'scripts/run-privacy-gate.ps1'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    $privacyGate = Join-Path $repoRoot 'scripts/run-privacy-gate.ps1'
    $missingDryRunRejected = $false
    try {
        & $privacyGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/privacy-negative-fixture') `
            -PatternsPath (Join-Path $repoRoot 'testdata/privacy-patterns.example.json') | Out-Null
    }
    catch {
        $missingDryRunRejected = $true
    }
    if (-not $missingDryRunRejected) {
        throw 'Privacy gate runner must reject calls without -DryRun.'
    }

    $installedLike = Invoke-JsonGate {
        & $privacyGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/release-fixture') `
            -PatternsPath (Join-Path $repoRoot 'testdata/privacy-patterns.example.json') `
            -DryRun `
            -ExpectFindings
    }
    Assert-FindingId -Result $installedLike -Id 'local-user-path'

    $negative = Invoke-JsonGate {
        & $privacyGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/privacy-negative-fixture') `
            -PatternsPath (Join-Path $repoRoot 'testdata/privacy-patterns.example.json') `
            -DryRun `
            -ExpectFindings
    }
    Assert-FindingId -Result $negative -Id 'bearer-token'
    Assert-FindingId -Result $negative -Id 'password'
    Assert-FindingId -Result $negative -Id 'generic-token'

    $large = Invoke-JsonGate {
        & $privacyGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/privacy-large-fixture') `
            -PatternsPath (Join-Path $repoRoot 'testdata/privacy-patterns-small-limit.example.json') `
            -DryRun `
            -ExpectFindings
    }
    Assert-FindingId -Result $large -Id 'text-file-too-large'

    $clean = Invoke-JsonGate {
        & $privacyGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/privacy-clean-fixture') `
            -PatternsPath (Join-Path $repoRoot 'testdata/privacy-patterns.example.json') `
            -DryRun
    }
    if ($clean.passed -ne $true) {
        throw 'Privacy clean fixture should report passed=true.'
    }

    Write-Host 'Privacy gate passed.'
}

function Invoke-AppSmokeGate {
    $required = @(
        'docs/qa/app-webview-smoke.md',
        'src/TestFramework/WindowsSmoke/WindowsSmoke.psm1',
        'src/TestFramework/WindowsSmoke/WindowsSmoke.Tests.ps1',
        'scripts/run-app-webview-smoke.ps1',
        'testdata/app-webview-smoke.example.json',
        'testdata/app-webview-smoke-unsafe-policy.example.json',
        'testdata/app-webview-smoke-fixture'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/WindowsSmoke/WindowsSmoke.Tests.ps1')

    $appSmoke = Join-Path $repoRoot 'scripts/run-app-webview-smoke.ps1'
    $missingDryRunRejected = $false
    try {
        & $appSmoke `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/app-webview-smoke-fixture') `
            -PolicyPath (Join-Path $repoRoot 'testdata/app-webview-smoke.example.json') | Out-Null
    }
    catch {
        $missingDryRunRejected = $true
    }
    if (-not $missingDryRunRejected) {
        throw 'App/WebView smoke runner must reject calls without -DryRun.'
    }

    $clientLaunchRejected = $false
    try {
        & $appSmoke `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/app-webview-smoke-fixture') `
            -PolicyPath (Join-Path $repoRoot 'testdata/app-webview-smoke.example.json') `
            -DryRun `
            -AllowClientLaunch | Out-Null
    }
    catch {
        $clientLaunchRejected = $true
    }
    if (-not $clientLaunchRejected) {
        throw 'App/WebView smoke runner must reject -AllowClientLaunch.'
    }

    $debugPortRejected = $false
    try {
        & $appSmoke `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/app-webview-smoke-fixture') `
            -PolicyPath (Join-Path $repoRoot 'testdata/app-webview-smoke.example.json') `
            -DryRun `
            -AllowWebViewDebugPort | Out-Null
    }
    catch {
        $debugPortRejected = $true
    }
    if (-not $debugPortRejected) {
        throw 'App/WebView smoke runner must reject -AllowWebViewDebugPort.'
    }

    $result = Invoke-JsonGate {
        & $appSmoke `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/app-webview-smoke-fixture') `
            -PolicyPath (Join-Path $repoRoot 'testdata/app-webview-smoke.example.json') `
            -DryRun
    }

    if ($result.passed -ne $true) {
        throw 'App/WebView smoke fixture should pass.'
    }
    if ($result.processStarted -ne $false -or $result.debugPortUsed -ne $false -or $result.authAttempted -ne $false -or $result.gameSessionStarted -ne $false) {
        throw 'App/WebView smoke dry-run must report no process/debug/auth/game activity.'
    }

    $negative = Invoke-JsonGate {
        & $appSmoke `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/app-webview-smoke-fixture') `
            -PolicyPath (Join-Path $repoRoot 'testdata/app-webview-smoke-unsafe-policy.example.json') `
            -DryRun `
            -ReportOnly
    }
    Assert-FindingId -Result $negative -Id 'policy-not-dry-run-only'
    Assert-FindingId -Result $negative -Id 'unsafe-launch-argument'
    Assert-FindingId -Result $negative -Id 'unsafe-runtime-path'

    Write-Host 'AppSmoke gate passed.'
}

function Invoke-BridgeContractGate {
    $required = @(
        'docs/qa/webview-bridge-contract.md',
        'src/TestFramework/WebViewBridge/WebViewBridge.psm1',
        'src/TestFramework/WebViewBridge/WebViewBridge.Tests.ps1',
        'scripts/run-webview-bridge-contract.ps1',
        'testdata/webview-bridge-contract.example.json',
        'testdata/webview-bridge-contract-unsafe.example.json'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/WebViewBridge/WebViewBridge.Tests.ps1')

    $bridgeContract = Join-Path $repoRoot 'scripts/run-webview-bridge-contract.ps1'
    $missingDryRunRejected = $false
    try {
        & $bridgeContract `
            -ContractPath (Join-Path $repoRoot 'testdata/webview-bridge-contract.example.json') | Out-Null
    }
    catch {
        $missingDryRunRejected = $true
    }
    if (-not $missingDryRunRejected) {
        throw 'WebView bridge contract runner must reject calls without -DryRun.'
    }

    $clientLaunchRejected = $false
    try {
        & $bridgeContract `
            -ContractPath (Join-Path $repoRoot 'testdata/webview-bridge-contract.example.json') `
            -DryRun `
            -AllowClientLaunch | Out-Null
    }
    catch {
        $clientLaunchRejected = $true
    }
    if (-not $clientLaunchRejected) {
        throw 'WebView bridge contract runner must reject -AllowClientLaunch.'
    }

    $debugPortRejected = $false
    try {
        & $bridgeContract `
            -ContractPath (Join-Path $repoRoot 'testdata/webview-bridge-contract.example.json') `
            -DryRun `
            -AllowWebViewDebugPort | Out-Null
    }
    catch {
        $debugPortRejected = $true
    }
    if (-not $debugPortRejected) {
        throw 'WebView bridge contract runner must reject -AllowWebViewDebugPort.'
    }

    $result = Invoke-JsonGate {
        & $bridgeContract `
            -ContractPath (Join-Path $repoRoot 'testdata/webview-bridge-contract.example.json') `
            -DryRun
    }

    if ($result.passed -ne $true) {
        throw 'WebView bridge contract fixture should pass.'
    }
    if ($result.processStarted -ne $false -or $result.debugPortUsed -ne $false -or $result.authAttempted -ne $false -or $result.gameSessionStarted -ne $false -or $result.readRuntimeUserData -ne $false) {
        throw 'WebView bridge contract dry-run must report no process/debug/auth/game/runtime-data activity.'
    }

    $negative = Invoke-JsonGate {
        & $bridgeContract `
            -ContractPath (Join-Path $repoRoot 'testdata/webview-bridge-contract-unsafe.example.json') `
            -DryRun `
            -ReportOnly
    }
    Assert-FindingId -Result $negative -Id 'policy-not-dry-run-only'
    Assert-FindingId -Result $negative -Id 'unsafe-diagnostic'
    Assert-FindingId -Result $negative -Id 'unsafe-runtime-path'

    Write-Host 'BridgeContract gate passed.'
}

function Invoke-BackendSmokeGate {
    $required = @(
        'docs/qa/backend-smoke.md',
        'src/TestFramework/BackendSmoke/BackendSmoke.psm1',
        'src/TestFramework/BackendSmoke/BackendSmoke.Tests.ps1',
        'scripts/run-backend-smoke.ps1',
        'testdata/backend-smoke.example.json',
        'testdata/backend-smoke-unsafe.example.json'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/BackendSmoke/BackendSmoke.Tests.ps1')

    $backendSmoke = Join-Path $repoRoot 'scripts/run-backend-smoke.ps1'
    $result = Invoke-JsonGate {
        & $backendSmoke `
            -PolicyPath (Join-Path $repoRoot 'testdata/backend-smoke.example.json') `
            -DryRun
    }

    if ($result.passed -ne $true) {
        throw 'Backend smoke fixture should pass.'
    }
    if ($result.networkCallAttempted -ne $false -or $result.authAttempted -ne $false -or $result.gameSessionStarted -ne $false -or $result.readRuntimeUserData -ne $false -or $result.mutatingRequestAttempted -ne $false) {
        throw 'Backend smoke dry-run must report no network/auth/game/runtime-data/mutation activity.'
    }

    $negative = Invoke-JsonGate {
        & $backendSmoke `
            -PolicyPath (Join-Path $repoRoot 'testdata/backend-smoke-unsafe.example.json') `
            -DryRun `
            -ReportOnly
    }
    Assert-FindingId -Result $negative -Id 'policy-not-dry-run-only'
    Assert-FindingId -Result $negative -Id 'network-not-disabled'
    Assert-FindingId -Result $negative -Id 'unsafe-header'
    Assert-FindingId -Result $negative -Id 'unsafe-runtime-path'
    Assert-FindingId -Result $negative -Id 'state-mutating-endpoint'

    Write-Host 'BackendSmoke gate passed.'
}

function Invoke-GameSessionCanaryGate {
    $required = @(
        'docs/qa/game-session-canary.md',
        'src/TestFramework/GameSessionCanary/GameSessionCanary.psm1',
        'src/TestFramework/GameSessionCanary/GameSessionCanary.Tests.ps1',
        'scripts/run-game-session-canary.ps1',
        'testdata/game-session-canary.example.json',
        'testdata/game-session-canary-unsafe.example.json',
        'testdata/allowed-games.example.json'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/GameSessionCanary/GameSessionCanary.Tests.ps1')

    $gameSessionCanary = Join-Path $repoRoot 'scripts/run-game-session-canary.ps1'
    Assert-CommandRejected -Message 'Game-session canary runner must reject PROD_CONDITIONAL runs without -AllowProdConditional.' -Command {
        & $gameSessionCanary `
            -PlanPath (Join-Path $repoRoot 'testdata/game-session-canary.example.json') `
            -DryRun `
            -CleanupVerified | Out-Null
    }

    foreach ($flag in @('AllowClientLaunch', 'AllowNetwork', 'AllowAuth')) {
        Assert-CommandRejected -Message "Game-session canary runner must reject -$flag." -Command {
            $params = @{
                PlanPath = (Join-Path $repoRoot 'testdata/game-session-canary.example.json')
                DryRun = $true
                AllowProdConditional = $true
                CleanupVerified = $true
            }
            $params[$flag] = $true
            & $gameSessionCanary `
                @params | Out-Null
        }
    }

    $result = Invoke-JsonGate {
        & $gameSessionCanary `
            -PlanPath (Join-Path $repoRoot 'testdata/game-session-canary.example.json') `
            -DryRun `
            -AllowProdConditional `
            -CleanupVerified
    }

    if ($result.passed -ne $true) {
        throw 'Game-session canary readiness fixture should pass.'
    }
    if ($result.processStarted -ne $false -or $result.networkCallAttempted -ne $false -or $result.authAttempted -ne $false -or $result.gameSessionStarted -ne $false -or $result.cleanupAttempted -ne $false -or $result.readRuntimeUserData -ne $false) {
        throw 'Game-session canary dry-run must report no process/network/auth/game/cleanup/runtime-data activity.'
    }

    $negative = Invoke-JsonGate {
        & $gameSessionCanary `
            -PlanPath (Join-Path $repoRoot 'testdata/game-session-canary-unsafe.example.json') `
            -DryRun `
            -AllowProdConditional `
            -CleanupVerified `
            -ReportOnly
    }
    Assert-FindingId -Result $negative -Id 'policy-not-dry-run-only'
    Assert-FindingId -Result $negative -Id 'execution-not-disabled'
    Assert-FindingId -Result $negative -Id 'client-launch-not-disabled'
    Assert-FindingId -Result $negative -Id 'network-not-disabled'
    Assert-FindingId -Result $negative -Id 'auth-not-disabled'
    Assert-FindingId -Result $negative -Id 'unsafe-runtime-path'
    Assert-FindingId -Result $negative -Id 'non-prod-conditional-canary'
    Assert-FindingId -Result $negative -Id 'cleanup-not-required'
    Assert-FindingId -Result $negative -Id 'duration-exceeds-budget'
    Assert-FindingId -Result $negative -Id 'game-not-allowlisted'
    Assert-FindingId -Result $negative -Id 'uncontrolled-retries'
    Assert-FindingId -Result $negative -Id 'missing-readiness-signals'

    Write-Host 'GameSessionCanary gate passed.'
}

function Invoke-NonProdFoundationGate {
    $required = @(
        'docs/qa/nonprod-foundation.md',
        'src/TestFramework/NonProdFoundation/NonProdFoundation.psm1',
        'src/TestFramework/NonProdFoundation/NonProdFoundation.Tests.ps1',
        'scripts/run-nonprod-foundation.ps1',
        'testdata/nonprod-foundation.example.json',
        'testdata/nonprod-foundation-unsafe.example.json'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/NonProdFoundation/NonProdFoundation.Tests.ps1')

    $nonProdFoundation = Join-Path $repoRoot 'scripts/run-nonprod-foundation.ps1'
    Assert-CommandRejected -Message 'Non-prod foundation runner must reject calls without -DryRun.' -Command {
        & $nonProdFoundation `
            -PlanPath (Join-Path $repoRoot 'testdata/nonprod-foundation.example.json') | Out-Null
    }

    foreach ($flag in @('AllowExecution', 'AllowNetwork', 'AllowAuth')) {
        Assert-CommandRejected -Message "Non-prod foundation runner must reject -$flag." -Command {
            $params = @{
                PlanPath = (Join-Path $repoRoot 'testdata/nonprod-foundation.example.json')
                DryRun = $true
            }
            $params[$flag] = $true
            & $nonProdFoundation `
                @params | Out-Null
        }
    }

    $result = Invoke-JsonGate {
        & $nonProdFoundation `
            -PlanPath (Join-Path $repoRoot 'testdata/nonprod-foundation.example.json') `
            -DryRun
    }

    if ($result.passed -ne $true) {
        throw 'Non-prod foundation fixture should pass.'
    }
    if ($result.processStarted -ne $false -or $result.debugPortUsed -ne $false -or $result.networkCallAttempted -ne $false -or $result.authAttempted -ne $false -or $result.gameSessionStarted -ne $false -or $result.readRuntimeUserData -ne $false -or $result.ciCdEnabled -ne $false -or $result.dependencyChanged -ne $false) {
        throw 'Non-prod foundation dry-run must report no process/debug/network/auth/game/runtime-data/CI/dependency activity.'
    }

    $negative = Invoke-JsonGate {
        & $nonProdFoundation `
            -PlanPath (Join-Path $repoRoot 'testdata/nonprod-foundation-unsafe.example.json') `
            -DryRun `
            -ReportOnly
    }
    Assert-FindingId -Result $negative -Id 'policy-not-dry-run-only'
    Assert-FindingId -Result $negative -Id 'execution-not-disabled'
    Assert-FindingId -Result $negative -Id 'network-not-disabled'
    Assert-FindingId -Result $negative -Id 'client-launch-not-disabled'
    Assert-FindingId -Result $negative -Id 'webview-debug-not-disabled'
    Assert-FindingId -Result $negative -Id 'auth-not-disabled'
    Assert-FindingId -Result $negative -Id 'runtime-data-read-not-disabled'
    Assert-FindingId -Result $negative -Id 'cicd-not-disabled'
    Assert-FindingId -Result $negative -Id 'unsafe-runtime-path'
    Assert-FindingId -Result $negative -Id 'production-endpoint-defined'
    Assert-FindingId -Result $negative -Id 'non-nonprod-classification'
    Assert-FindingId -Result $negative -Id 'component-not-schema-only'
    Assert-FindingId -Result $negative -Id 'component-execution-enabled'
    Assert-FindingId -Result $negative -Id 'component-uses-production'
    Assert-FindingId -Result $negative -Id 'component-requires-credentials'
    Assert-FindingId -Result $negative -Id 'component-mutates-state'
    Assert-FindingId -Result $negative -Id 'component-starts-game-session'
    Assert-FindingId -Result $negative -Id 'missing-contract-schema'
    Assert-FindingId -Result $negative -Id 'unsafe-component-reference'

    Write-Host 'NonProdFoundation gate passed.'
}

function Invoke-TestabilityGapsGate {
    $required = @(
        'docs/qa/testability-gaps.md',
        'src/TestFramework/TestabilityGaps/TestabilityGaps.psm1',
        'src/TestFramework/TestabilityGaps/TestabilityGaps.Tests.ps1',
        'scripts/run-testability-gaps.ps1',
        'testdata/testability-gaps.example.json',
        'testdata/testability-gaps-unsafe.example.json'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/TestabilityGaps/TestabilityGaps.Tests.ps1')

    $testabilityGaps = Join-Path $repoRoot 'scripts/run-testability-gaps.ps1'
    Assert-CommandRejected -Message 'Testability gaps runner must reject calls without -DryRun.' -Command {
        & $testabilityGaps `
            -PolicyPath (Join-Path $repoRoot 'testdata/testability-gaps.example.json') | Out-Null
    }

    foreach ($flag in @('AllowProductionAction', 'AllowCredentials', 'AllowRuntimeUserData')) {
        Assert-CommandRejected -Message "Testability gaps runner must reject -$flag." -Command {
            $params = @{
                PolicyPath = (Join-Path $repoRoot 'testdata/testability-gaps.example.json')
                DryRun = $true
            }
            $params[$flag] = $true
            & $testabilityGaps `
                @params | Out-Null
        }
    }

    $result = Invoke-JsonGate {
        & $testabilityGaps `
            -PolicyPath (Join-Path $repoRoot 'testdata/testability-gaps.example.json') `
            -DryRun
    }

    if ($result.passed -ne $true) {
        throw 'Testability gaps fixture should pass.'
    }
    if ($result.productionActionAttempted -ne $false -or $result.credentialsUsed -ne $false -or $result.runtimeUserDataRead -ne $false) {
        throw 'Testability gaps dry-run must report no production action, credential use or runtime user data read.'
    }

    $negative = Invoke-JsonGate {
        & $testabilityGaps `
            -PolicyPath (Join-Path $repoRoot 'testdata/testability-gaps-unsafe.example.json') `
            -DryRun `
            -ReportOnly
    }
    Assert-FindingId -Result $negative -Id 'policy-not-dry-run-only'
    Assert-FindingId -Result $negative -Id 'production-execution-not-disabled'
    Assert-FindingId -Result $negative -Id 'runtime-data-read-not-disabled'
    Assert-FindingId -Result $negative -Id 'credentials-not-disabled'
    Assert-FindingId -Result $negative -Id 'invalid-gap-id'
    Assert-FindingId -Result $negative -Id 'invalid-area'
    Assert-FindingId -Result $negative -Id 'invalid-status'
    Assert-FindingId -Result $negative -Id 'gap-marked-production-safe'
    Assert-FindingId -Result $negative -Id 'gap-requires-credentials'
    Assert-FindingId -Result $negative -Id 'gap-requires-user-data'
    Assert-FindingId -Result $negative -Id 'invalid-required-evidence'
    Assert-FindingId -Result $negative -Id 'missing-stop-trigger'
    Assert-FindingId -Result $negative -Id 'missing-next-safe-step'

    Write-Host 'TestabilityGaps gate passed.'
}

if ($Scope -in @('Context', 'Full')) {
    Invoke-ContextGate
}

if ($Scope -in @('ActiveRunSafety', 'Full')) {
    Invoke-ActiveRunSafetyGate
}

if ($Scope -in @('RunnerSafety', 'Full')) {
    Invoke-RunnerSafetyGate
}

if ($Scope -in @('TestDataSafety', 'Full')) {
    Invoke-TestDataSafetyGate
}

if ($Scope -in @('SyntheticUsersSafety', 'Full')) {
    Invoke-SyntheticUsersSafetyGate
}

if ($Scope -in @('AllowedGamesSafety', 'Full')) {
    Invoke-AllowedGamesSafetyGate
}

if ($Scope -in @('ResourceBudgetSafety', 'Full')) {
    Invoke-ResourceBudgetSafetyGate
}

if ($Scope -in @('ProdMetadataSafety', 'Full')) {
    Invoke-ProdMetadataSafetyGate
}

if ($Scope -in @('ProdMatrixSafety', 'Full')) {
    Invoke-ProdMatrixSafetyGate
}

if ($Scope -in @('BacklogSafety', 'Full')) {
    Invoke-BacklogSafetyGate
}

if ($Scope -in @('ProdSafety', 'Full')) {
    Invoke-ProdSafetyGate
}

if ($Scope -in @('Release', 'Full')) {
    Invoke-ReleaseGate
}

if ($Scope -in @('UpdateManifest', 'Full')) {
    Invoke-UpdateManifestGate
}

if ($Scope -in @('Privacy', 'Full')) {
    Invoke-PrivacyGate
}

if ($Scope -in @('AppSmoke', 'Full')) {
    Invoke-AppSmokeGate
}

if ($Scope -in @('BridgeContract', 'Full')) {
    Invoke-BridgeContractGate
}

if ($Scope -in @('BackendSmoke', 'Full')) {
    Invoke-BackendSmokeGate
}

if ($Scope -in @('GameSessionCanary', 'Full')) {
    Invoke-GameSessionCanaryGate
}

if ($Scope -in @('NonProdFoundation', 'Full')) {
    Invoke-NonProdFoundationGate
}

if ($Scope -in @('TestabilityGaps', 'Full')) {
    Invoke-TestabilityGapsGate
}
