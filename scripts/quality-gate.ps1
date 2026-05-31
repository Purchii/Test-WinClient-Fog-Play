param(
    [ValidateSet('Context', 'RepositoryRootInventorySafety', 'RootPromptSafety', 'ProdSafetyFrameworkSafety', 'ScriptEncodingSafety', 'PowerShellStructuredSyntaxSafety', 'BinaryFixturePlaceholderSafety', 'QaDocsCommandSafety', 'QaDocsCommandLocalPathSafety', 'QaDocsPowerShellInvocationSafety', 'QaDocsRunnerExampleCoverageSafety', 'QualityGatesDocsScopeSafety', 'ActiveSafetyScopeInventorySafety', 'ScriptsReadmeScopeSafety', 'GovernanceHistoryScopeSafety', 'TestDataStructuredSyntaxSafety', 'QualityGateStructureSafety', 'ActiveRunSafety', 'ContextDocsInventorySafety', 'SessionLogSafety', 'VerificationMemorySafety', 'ActiveVerificationCommandSafety', 'ChecklistSafety', 'DecisionsLogSafety', 'CodexPolicySafety', 'TaskRequestSafety', 'CodexTemplateSafety', 'CodexGoalTemplateSafety', 'CodexDocsInventorySafety', 'QaStrategySafety', 'HandoffProtocolSafety', 'IncomingReferenceSafety', 'FrameworkInventorySafety', 'TestFrameworkInventorySafety', 'IncidentStopSafety', 'QaDocsSafety', 'ArtifactPolicySafety', 'ContractFixtureSafety', 'StaticSurfaceSafety', 'WebViewBundleLocalReferenceSafety', 'FixtureInventorySafety', 'ScriptsInventorySafety', 'RunnerSafety', 'TestDataSafety', 'TestDataInventorySafety', 'UnsafeFixtureCoverageSafety', 'SyntheticUsersSafety', 'AllowedGamesSafety', 'ResourceBudgetSafety', 'ProdMetadataSafety', 'ProdMatrixSafety', 'BacklogSafety', 'ProdSafety', 'Release', 'Privacy', 'AppSmoke', 'BridgeContract', 'BackendSmoke', 'GameSessionCanary', 'NonProdFoundation', 'UpdateManifest', 'TestabilityGaps', 'Full')]
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

    $dispatchLines = @($script -split "`r?`n" | Where-Object { $_ -match 'if\s*\(\s*\$Scope\s+-in\s+@\(' })
    foreach ($scopeName in @($scopes | Where-Object { $_ -ne 'Full' })) {
        $dispatchLine = @($dispatchLines | Where-Object {
                $_ -match "'$([regex]::Escape($scopeName))'" -and $_ -match "'Full'"
            })
        if ($dispatchLine.Count -ne 1) {
            throw "quality-gate.ps1 must include scope '$scopeName' exactly once in a Full dispatch block."
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

function Invoke-RepositoryRootInventorySafetyGate {
    $expectedRootItems = @(
        'AGENTS.md',
        'CODEX_AUTONOMY_MODES_INTEGRATION.md',
        'CODEX_FINAL_TZ_WINCLIENT_QA_AUTOMATION.md',
        'CODEX_FIRST_GOAL_PROMPT.md',
        'CODEX_NEW_THREAD_BOUNDED_AUTONOMOUS_PROMPT.md',
        'CODEX_START_INSTRUCTION.md',
        'README_CODEX_START.md',
        'docs',
        'scripts',
        'src',
        'testdata'
    )
    $ignoredRootItems = @(
        '.git'
    )
    $actualRootItems = @(Get-ChildItem -LiteralPath $repoRoot -Force | Where-Object {
            $ignoredRootItems -notcontains $_.Name
        } | ForEach-Object { $_.Name } | Sort-Object)
    foreach ($item in $expectedRootItems) {
        if ($actualRootItems -notcontains $item) {
            throw "Repository root is missing required item: $item"
        }
    }
    foreach ($item in $actualRootItems) {
        if ($expectedRootItems -notcontains $item) {
            throw "Repository root contains undocumented item: $item"
        }
    }

    Write-Host 'RepositoryRootInventorySafety gate passed.'
}

function Invoke-RootPromptSafetyGate {
    $requirements = @(
        @{
            Path = 'AGENTS.md'
            Phrases = @(
                'This repository is production-sensitive',
                'Non-negotiable production rules',
                'Repository docs and code are the source of truth',
                'default to `NON_AUTONOMOUS`',
                'Do not add real game-session tests'
            )
        },
        @{
            Path = 'CODEX_AUTONOMY_MODES_INTEGRATION.md'
            Phrases = @(
                'Discovery and plan: NON_AUTONOMOUS.',
                'After user accepts the plan: BOUNDED_AUTONOMOUS only inside M0 scope.',
                'Any production-impacting action: NON_AUTONOMOUS.',
                'Merge to main: NON_AUTONOMOUS and explicit user approval required.'
            )
        },
        @{
            Path = 'CODEX_FINAL_TZ_WINCLIENT_QA_AUTOMATION.md'
            Phrases = @(
                'No synthetic user guard = no prod auth test.',
                'No resource budget = no prod game session test.',
                'Any production-impacting action: NON_AUTONOMOUS.',
                'Merge to main: NON_AUTONOMOUS + explicit approval.',
                'M5. Minimal game-session canary',
                'no game session starts during dry-run'
            )
        },
        @{
            Path = 'CODEX_FIRST_GOAL_PROMPT.md'
            Phrases = @(
                'All automation must be production-safe by default.',
                'Repository docs and code are the source of truth.',
                'Discovery and initial plan: NON_AUTONOMOUS.',
                'BOUNDED_AUTONOMOUS within M0 scope only',
                'Stop and ask before any production-impacting action',
                'no production game sessions are started'
            )
        },
        @{
            Path = 'CODEX_NEW_THREAD_BOUNDED_AUTONOMOUS_PROMPT.md'
            Phrases = @(
                'For first discovery of an unknown repository, use NON_AUTONOMOUS mode first.',
                'BOUNDED_AUTONOMOUS within the approved M0 scope only.',
                'repository docs and code are the source of truth',
                'No synthetic user guard = no prod auth test.',
                'No resource budget = no prod game session test.',
                'no production game sessions are started'
            )
        },
        @{
            Path = 'CODEX_START_INSTRUCTION.md'
            Phrases = @(
                'source of truth',
                'NON_AUTONOMOUS',
                'BOUNDED_AUTONOMOUS',
                'Do not add game-session tests.',
                'Game-session canary'
            )
        },
        @{
            Path = 'README_CODEX_START.md'
            Phrases = @(
                'Discovery/plan: NON_AUTONOMOUS.',
                'Implementation after accepted plan: BOUNDED_AUTONOMOUS within approved scope.',
                'Production impact and merge to main: NON_AUTONOMOUS.',
                'game-session tests',
                'M0 scope'
            )
        }
    )

    foreach ($requirement in $requirements) {
        Assert-PathExists $requirement.Path
        $content = Get-Content -LiteralPath (Join-Path $repoRoot $requirement.Path) -Raw
        foreach ($phrase in $requirement.Phrases) {
            if ($content -notmatch [regex]::Escape($phrase)) {
                throw "$($requirement.Path) must preserve root prompt safety phrase: $phrase"
            }
        }
    }

    Write-Host 'RootPromptSafety gate passed.'
}

function Invoke-ProdSafetyFrameworkSafetyGate {
    $readmePath = Join-Path $repoRoot 'src/TestFramework/ProdSafety/README.md'
    $modulePath = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
    $testsPath = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.Tests.ps1'
    Assert-PathExists 'src/TestFramework/ProdSafety/README.md'
    Assert-PathExists 'src/TestFramework/ProdSafety/ProdSafety.psm1'
    Assert-PathExists 'src/TestFramework/ProdSafety/ProdSafety.Tests.ps1'

    $readme = Get-Content -LiteralPath $readmePath -Raw
    foreach ($requiredPhrase in @(
            'local, production-safe guard foundation',
            'intentionally dry-run capable',
            'does not launch the Windows client',
            'authenticate',
            'start game sessions',
            'mutate production state',
            'Every test must declare exactly one classification',
            'no classification = no prod run',
            'PROD_FORBIDDEN',
            'NON_PROD_ONLY',
            'explicit flag, synthetic user, resource budget and cleanup verification',
            'PROD_AUTOMATION_ENABLED',
            'QA_PROD_CANARY_ENABLED',
            '-Scope ProdSafety'
        )) {
        if ($readme -notmatch [regex]::Escape($requiredPhrase)) {
            throw "ProdSafety README must preserve safety phrase: $requiredPhrase"
        }
    }

    $module = Get-Content -LiteralPath $modulePath -Raw
    foreach ($requiredPhrase in @(
            'function Get-ProdSafetyClassificationValues',
            'function New-TestMetadata',
            'function Read-TestMetadataFile',
            'function Test-KillSwitch',
            'function Test-SyntheticUserGuard',
            'function Test-ResourceBudget',
            'function Test-CleanupVerifier',
            'function Invoke-ProdGuard',
            'PROD_AUTOMATION_ENABLED must be enabled for non-dry-run production automation.',
            'QA_PROD_CANARY_ENABLED must be enabled for non-dry-run PROD_CONDITIONAL automation.',
            'is unclassified and cannot run on production.',
            'is PROD_FORBIDDEN and cannot run on production.',
            'is NON_PROD_ONLY and cannot run on production.',
            'requires an allowlisted synthetic user.',
            'requires a resource budget.',
            'requires cleanup verification.'
        )) {
        if ($module -notmatch [regex]::Escape($requiredPhrase)) {
            throw "ProdSafety module must preserve guard phrase: $requiredPhrase"
        }
    }

    $exports = [regex]::Matches($module, '(?m)^\s*(Get-ProdSafetyClassificationValues|New-TestMetadata|Read-TestMetadataFile|Read-SyntheticUsersConfig|Read-ProdResourceBudget|Test-KillSwitch|Test-SyntheticUserGuard|Test-ResourceBudget|Test-CleanupVerifier|Invoke-ProdGuard),?\s*`?') |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object -Unique
    foreach ($exportName in @('Get-ProdSafetyClassificationValues', 'New-TestMetadata', 'Read-TestMetadataFile', 'Read-SyntheticUsersConfig', 'Read-ProdResourceBudget', 'Test-KillSwitch', 'Test-SyntheticUserGuard', 'Test-ResourceBudget', 'Test-CleanupVerifier', 'Invoke-ProdGuard')) {
        if ($exports -notcontains $exportName) {
            throw "ProdSafety module must export guard function: $exportName"
        }
    }

    $tests = Get-Content -LiteralPath $testsPath -Raw
    foreach ($requiredPhrase in @(
            'Unclassified tests must be rejected on production.',
            'PROD_FORBIDDEN tests must be rejected on production.',
            'NON_PROD_ONLY tests must be rejected on production.',
            'PROD_CONDITIONAL dry-run should pass only with explicit flag, budget, synthetic user and cleanup verification.',
            'Non-dry-run production automation must require PROD_AUTOMATION_ENABLED.'
        )) {
        if ($tests -notmatch [regex]::Escape($requiredPhrase)) {
            throw "ProdSafety tests must preserve regression assertion: $requiredPhrase"
        }
    }

    Write-Host 'ProdSafetyFrameworkSafety gate passed.'
}

function Invoke-ScriptEncodingSafetyGate {
    $scriptFiles = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'scripts') -Filter '*.ps1' -File | Sort-Object Name)
    if ($scriptFiles.Count -eq 0) {
        throw 'No PowerShell scripts found under scripts/.'
    }

    foreach ($scriptFile in $scriptFiles) {
        $relativePath = "scripts/$($scriptFile.Name)"
        $bytes = [System.IO.File]::ReadAllBytes($scriptFile.FullName)
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            throw "$relativePath must not use a UTF-8 BOM."
        }
        for ($index = 0; $index -lt $bytes.Length; $index++) {
            if ($bytes[$index] -gt 0x7F) {
                throw "$relativePath must stay ASCII-only for Windows PowerShell parser safety. Non-ASCII byte at offset $index."
            }
        }
    }

    Write-Host 'ScriptEncodingSafety gate passed.'
}

function Invoke-PowerShellStructuredSyntaxSafetyGate {
    $scriptRoot = Join-Path $repoRoot 'scripts'
    $frameworkRoot = Join-Path $repoRoot 'src/TestFramework'
    Assert-PathExists 'scripts'
    Assert-PathExists 'src/TestFramework'

    $scriptFiles = @(Get-ChildItem -LiteralPath $scriptRoot -Filter '*.ps1' -File | Sort-Object FullName)
    $frameworkFiles = @(Get-ChildItem -LiteralPath $frameworkRoot -Recurse -File | Where-Object {
            $_.Extension -in @('.ps1', '.psm1')
        } | Sort-Object FullName)
    $powerShellFiles = @($scriptFiles + $frameworkFiles)

    if ($powerShellFiles.Count -eq 0) {
        throw 'No PowerShell files found for structured syntax validation.'
    }

    foreach ($powerShellFile in $powerShellFiles) {
        $relativePath = $powerShellFile.FullName.Substring($repoRoot.Length + 1) -replace '\\', '/'
        $tokens = $null
        $parseErrors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($powerShellFile.FullName, [ref]$tokens, [ref]$parseErrors) | Out-Null

        if ($parseErrors -and $parseErrors.Count -gt 0) {
            $messages = @($parseErrors | ForEach-Object {
                    "$($_.Extent.StartLineNumber):$($_.Extent.StartColumnNumber) $($_.Message)"
                })
            throw "PowerShell syntax parse failed for $relativePath`n$($messages -join "`n")"
        }
    }

    Write-Host 'PowerShellStructuredSyntaxSafety gate passed.'
}

function Invoke-BinaryFixturePlaceholderSafetyGate {
    $testdataRoot = Join-Path $repoRoot 'testdata'
    Assert-PathExists 'testdata'

    $placeholderExtensions = @('.exe', '.dll', '.pak')
    $forbiddenExtensions = @('.dmp', '.dump', '.db', '.sqlite', '.pdb')
    $maxPlaceholderBytes = 1024
    $binaryFixtureFiles = @(Get-ChildItem -LiteralPath $testdataRoot -Recurse -File | Where-Object {
            $extension = $_.Extension.ToLowerInvariant()
            ($placeholderExtensions -contains $extension) -or ($forbiddenExtensions -contains $extension)
        } | Sort-Object FullName)

    $expectedPlaceholderFiles = @(
        'testdata/app-webview-smoke-fixture/bin/chrome_100_percent.pak',
        'testdata/app-webview-smoke-fixture/bin/libcef.dll',
        'testdata/app-webview-smoke-fixture/bin/rds-client.exe',
        'testdata/app-webview-smoke-fixture/bin/resources.pak',
        'testdata/release-clean-fixture/Uninstall.exe',
        'testdata/release-clean-fixture/bin/crashpad_handler.exe',
        'testdata/release-clean-fixture/bin/libcef.dll',
        'testdata/release-clean-fixture/bin/rds-client.exe',
        'testdata/release-clean-fixture/bin/rds-updater.exe',
        'testdata/release-clean-fixture/bin/sentry.dll',
        'testdata/release-fixture/Uninstall.exe',
        'testdata/release-fixture/bin/crashpad_handler.exe',
        'testdata/release-fixture/bin/libcef.dll',
        'testdata/release-fixture/bin/rds-client.exe',
        'testdata/release-fixture/bin/rds-updater.exe',
        'testdata/release-fixture/bin/sentry.dll'
    )

    $actualRelativePaths = @($binaryFixtureFiles | ForEach-Object {
            $relative = Resolve-Path -LiteralPath $_.FullName -Relative
            $relative.TrimStart('.', '\') -replace '\\', '/'
        })

    foreach ($expectedPath in $expectedPlaceholderFiles) {
        if ($actualRelativePaths -notcontains $expectedPath) {
            throw "Binary fixture placeholder is missing: $expectedPath"
        }
    }
    foreach ($actualPath in $actualRelativePaths) {
        if ($expectedPlaceholderFiles -notcontains $actualPath) {
            throw "Unexpected binary-like fixture path: $actualPath"
        }
    }

    foreach ($file in $binaryFixtureFiles) {
        $relativePath = (Resolve-Path -LiteralPath $file.FullName -Relative).TrimStart('.', '\') -replace '\\', '/'
        $extension = $file.Extension.ToLowerInvariant()
        if ($forbiddenExtensions -contains $extension) {
            throw "Forbidden runtime/debug/database fixture extension is not allowed: $relativePath"
        }
        if ($file.Length -gt $maxPlaceholderBytes) {
            throw "Binary fixture must stay a tiny placeholder <= $maxPlaceholderBytes bytes: $relativePath"
        }
        $bytesToRead = [Math]::Min(2, [int]$file.Length)
        if ($bytesToRead -ge 2) {
            $stream = [System.IO.File]::OpenRead($file.FullName)
            try {
                $header = New-Object byte[] 2
                [void]$stream.Read($header, 0, 2)
                if ($header[0] -eq 0x4D -and $header[1] -eq 0x5A) {
                    throw "Binary fixture must not contain a real PE MZ header: $relativePath"
                }
            }
            finally {
                $stream.Dispose()
            }
        }
    }

    Write-Host 'BinaryFixturePlaceholderSafety gate passed.'
}

function Invoke-QaDocsCommandSafetyGate {
    $qaDocsRoot = Join-Path $repoRoot 'docs/qa'
    Assert-PathExists 'docs/qa'

    $qaDocs = @(Get-ChildItem -LiteralPath $qaDocsRoot -Filter '*.md' -File | Sort-Object Name)
    foreach ($doc in $qaDocs) {
        $lines = Get-Content -LiteralPath $doc.FullName
        for ($lineNumber = 0; $lineNumber -lt $lines.Count; $lineNumber++) {
            $line = [string]$lines[$lineNumber]
            if ($line -notmatch 'run-[A-Za-z0-9-]+\.ps1') {
                continue
            }

            $trimmed = $line.Trim()
            $isCommandLine = $trimmed -match '^(powershell\b|\.\\scripts\\|scripts/)'
            if (-not $isCommandLine) {
                continue
            }

            if ($line -notmatch '(?i)(^|\s)-DryRun(\s|`|$)') {
                throw "$($doc.Name):$($lineNumber + 1) documents a run-*.ps1 command without -DryRun."
            }

            foreach ($forbiddenToken in @('-AllowClientLaunch', '-AllowWebViewDebugPort', '-AllowNetwork', '-AllowAuth', '-AllowExecution', '-AllowRollback', '-AllowCredentials')) {
                if ($line -match [regex]::Escape($forbiddenToken)) {
                    throw "$($doc.Name):$($lineNumber + 1) documents forbidden runtime flag $forbiddenToken."
                }
            }
        }
    }

    Write-Host 'QaDocsCommandSafety gate passed.'
}

function Invoke-QaDocsCommandLocalPathSafetyGate {
    $qaDocsRoot = Join-Path $repoRoot 'docs/qa'
    Assert-PathExists 'docs/qa'

    $forbiddenReferencePatterns = @(
        @{ Id = 'installed-client-path'; Pattern = '(?i)C:\\Program Files\\MTC Fog Play' },
        @{ Id = 'absolute-user-path'; Pattern = '(?i)C:\\Users\\' },
        @{ Id = 'appdata'; Pattern = '(?i)AppData' },
        @{ Id = 'remote-url'; Pattern = '(?i)\bhttps?://' },
        @{ Id = 'localhost'; Pattern = '(?i)\b(?:localhost|127\.0\.0\.1|0\.0\.0\.0|::1)\b' },
        @{ Id = 'webview-debug'; Pattern = '(?i)(remote-debugging|debug-port|webview-debug|devtools|chrome-devtools|\bcdp\b)' },
        @{ Id = 'runtime-data-path'; Pattern = '(?i)(cookies?|Local Storage|IndexedDB|\.db\b|\.sqlite\b|\.dmp\b|\.dump\b|\.log\b|\\logs?\\|/logs?/)' },
        @{ Id = 'absolute-windows-path'; Pattern = '(?i)(^|\s|["''])[A-Z]:\\' }
    )
    $localFixturePathPattern = '(?i)^(?:\.(?:\\|/))?testdata(?:\\|/|$)'
    $pathArgumentPattern = '(?i)(?:^|\s)-(?<name>[A-Za-z]*(?:Path|Root))\s+(?<value>"[^"]+"|''[^'']+''|[^\s`]+)'

    $qaDocs = @(Get-ChildItem -LiteralPath $qaDocsRoot -Filter '*.md' -File | Sort-Object Name)
    foreach ($doc in $qaDocs) {
        $lines = Get-Content -LiteralPath $doc.FullName
        for ($lineNumber = 0; $lineNumber -lt $lines.Count; $lineNumber++) {
            $line = [string]$lines[$lineNumber]
            if ($line -notmatch 'run-[A-Za-z0-9-]+\.ps1') {
                continue
            }

            $trimmed = $line.Trim()
            $isCommandLine = $trimmed -match '^(powershell\b|\.\\scripts\\|scripts/)'
            if (-not $isCommandLine) {
                continue
            }

            foreach ($pattern in $forbiddenReferencePatterns) {
                if ($line -match $pattern.Pattern) {
                    throw "$($doc.Name):$($lineNumber + 1) documents a run-*.ps1 command with forbidden local path or endpoint token: $($pattern.Id)."
                }
            }

            foreach ($match in [regex]::Matches($line, $pathArgumentPattern)) {
                $argumentName = $match.Groups['name'].Value
                $argumentValue = $match.Groups['value'].Value.Trim([char[]]@('"', "'"))
                if ($argumentValue -notmatch $localFixturePathPattern) {
                    throw "$($doc.Name):$($lineNumber + 1) documents $argumentName outside local testdata fixtures: $argumentValue"
                }
            }
        }
    }

    Write-Host 'QaDocsCommandLocalPathSafety gate passed.'
}

function Invoke-QaDocsPowerShellInvocationSafetyGate {
    $qaDocsRoot = Join-Path $repoRoot 'docs/qa'
    Assert-PathExists 'docs/qa'

    $qaDocs = @(Get-ChildItem -LiteralPath $qaDocsRoot -Filter '*.md' -File | Sort-Object Name)
    $safeInvocationPattern = '(?i)^powershell\s+-NoProfile\s+-ExecutionPolicy\s+Bypass\s+-File\s+\.\\scripts\\run-[A-Za-z0-9-]+\.ps1(\s|$)'
    foreach ($doc in $qaDocs) {
        $lines = Get-Content -LiteralPath $doc.FullName
        for ($lineNumber = 0; $lineNumber -lt $lines.Count; $lineNumber++) {
            $line = [string]$lines[$lineNumber]
            if ($line -notmatch 'run-[A-Za-z0-9-]+\.ps1') {
                continue
            }

            $trimmed = $line.Trim()
            $isCommandLine = $trimmed -match '^(powershell\b|\.\\scripts\\|scripts/)'
            if (-not $isCommandLine) {
                continue
            }

            if ($trimmed -notmatch $safeInvocationPattern) {
                throw "$($doc.Name):$($lineNumber + 1) must document run-*.ps1 via: powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\..."
            }
        }
    }

    Write-Host 'QaDocsPowerShellInvocationSafety gate passed.'
}

function Invoke-QaDocsRunnerExampleCoverageSafetyGate {
    $qaDocsRoot = Join-Path $repoRoot 'docs/qa'
    Assert-PathExists 'docs/qa'

    $runnerDocContracts = @(
        @{ Runner = 'run-backend-smoke.ps1'; Doc = 'backend-smoke.md' },
        @{ Runner = 'run-game-session-canary.ps1'; Doc = 'game-session-canary.md' },
        @{ Runner = 'run-nonprod-foundation.ps1'; Doc = 'nonprod-foundation.md' },
        @{ Runner = 'run-testability-gaps.ps1'; Doc = 'testability-gaps.md' },
        @{ Runner = 'run-update-manifest-gate.ps1'; Doc = 'update-manifest-gate.md' },
        @{ Runner = 'run-webview-bridge-contract.ps1'; Doc = 'webview-bridge-contract.md' },
        @{ Runner = 'run-app-webview-smoke.ps1'; Doc = 'app-webview-smoke.md' }
    )

    foreach ($contract in $runnerDocContracts) {
        Assert-PathExists "scripts/$($contract.Runner)"
        Assert-PathExists "docs/qa/$($contract.Doc)"

        $docPath = Join-Path $qaDocsRoot $contract.Doc
        $lines = Get-Content -LiteralPath $docPath
        $safeCommandPattern = "(?i)^powershell\s+-NoProfile\s+-ExecutionPolicy\s+Bypass\s+-File\s+\.\\scripts\\$([regex]::Escape($contract.Runner))(\s|$)"
        $matchingCommands = @()
        for ($lineNumber = 0; $lineNumber -lt $lines.Count; $lineNumber++) {
            $trimmed = ([string]$lines[$lineNumber]).Trim()
            if ($trimmed -match $safeCommandPattern) {
                $matchingCommands += [pscustomobject]@{
                    LineNumber = $lineNumber + 1
                    Text = $trimmed
                }
            }
        }

        if ($matchingCommands.Count -eq 0) {
            throw "$($contract.Doc) must document a command-looking dry-run example for $($contract.Runner)."
        }

        $dryRunCommands = @($matchingCommands | Where-Object { $_.Text -match '(?i)(^|\s)-DryRun(\s|`|$)' })
        if ($dryRunCommands.Count -eq 0) {
            throw "$($contract.Doc) must document $($contract.Runner) with -DryRun."
        }
    }

    Write-Host 'QaDocsRunnerExampleCoverageSafety gate passed.'
}

function Invoke-QualityGatesDocsScopeSafetyGate {
    $docsPath = Join-Path $repoRoot 'docs/context/engineering/quality-gates.md'
    $scriptPath = Join-Path $repoRoot 'scripts/quality-gate.ps1'
    Assert-PathExists 'docs/context/engineering/quality-gates.md'
    Assert-PathExists 'scripts/quality-gate.ps1'

    $docs = Get-Content -LiteralPath $docsPath -Raw
    $script = Get-Content -LiteralPath $scriptPath -Raw
    $validateSetMatch = [regex]::Match($script, "\[ValidateSet\((?<values>[^\)]*)\)\]")
    if (-not $validateSetMatch.Success) {
        throw 'quality-gate.ps1 does not declare a ValidateSet for -Scope.'
    }

    $validateScopes = @([regex]::Matches($validateSetMatch.Groups['values'].Value, "'([^']+)'") |
            ForEach-Object { $_.Groups[1].Value })
    if ($validateScopes.Count -eq 0) {
        throw 'quality-gate.ps1 ValidateSet must declare at least one -Scope value.'
    }

    $preferredScriptBlock = [regex]::Match($docs, '(?ms)^```powershell\s*(?<block>.*?)^```')
    if (-not $preferredScriptBlock.Success) {
        throw 'docs/context/engineering/quality-gates.md must keep a powershell Preferred script command block.'
    }

    $blockLines = ($preferredScriptBlock.Groups['block'].Value) -split '\r?\n'
    $commandLines = @($blockLines |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -ne '' })
    if ($commandLines.Count -eq 0) {
        throw 'docs/context/engineering/quality-gates.md Preferred script block must list quality-gate commands.'
    }

    $documentedScopes = @()
    $commandPattern = '^\.\\scripts\\quality-gate\.ps1 -Scope ([A-Za-z0-9]+)\z'
    foreach ($commandLine in $commandLines) {
        $commandMatch = [regex]::Match($commandLine, $commandPattern)
        if (-not $commandMatch.Success) {
            throw "quality-gates.md Preferred script command has invalid syntax: $commandLine"
        }

        $documentedScopes += $commandMatch.Groups[1].Value
    }

    foreach ($scopeName in $validateScopes) {
        $documentedCount = @($documentedScopes | Where-Object { $_ -eq $scopeName }).Count
        if ($documentedCount -ne 1) {
            throw "quality-gates.md Preferred script block must list ValidateSet scope exactly once: $scopeName"
        }
    }

    foreach ($scopeName in $documentedScopes) {
        if ($validateScopes -notcontains $scopeName) {
            throw "quality-gates.md Preferred script block lists unknown scope: $scopeName"
        }
    }

    Write-Host 'QualityGatesDocsScopeSafety gate passed.'
}

function Invoke-ActiveSafetyScopeInventorySafetyGate {
    $scriptPath = Join-Path $repoRoot 'scripts/quality-gate.ps1'
    $activeRunPath = Join-Path $repoRoot 'docs/context/handoff/active-run.md'
    $currentStatePath = Join-Path $repoRoot 'docs/context/current-state.md'
    Assert-PathExists 'scripts/quality-gate.ps1'
    Assert-PathExists 'docs/context/handoff/active-run.md'
    Assert-PathExists 'docs/context/current-state.md'

    $script = Get-Content -LiteralPath $scriptPath -Raw
    $activeRun = Get-Content -LiteralPath $activeRunPath -Raw
    $currentState = Get-Content -LiteralPath $currentStatePath -Raw
    $validateSetMatch = [regex]::Match($script, "\[ValidateSet\((?<values>[^\)]*)\)\]")
    if (-not $validateSetMatch.Success) {
        throw 'quality-gate.ps1 does not declare a ValidateSet for -Scope.'
    }

    $safetyScopes = [regex]::Matches($validateSetMatch.Groups['values'].Value, "'([^']+Safety)'") |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object -Unique
    foreach ($scopeName in $safetyScopes) {
        if ($activeRun -notmatch [regex]::Escape($scopeName)) {
            throw "active-run.md must mention safety scope from ValidateSet: $scopeName"
        }
        if ($currentState -notmatch [regex]::Escape($scopeName)) {
            throw "current-state.md must mention safety scope from ValidateSet: $scopeName"
        }
    }

    $milestoneMatch = [regex]::Match($activeRun, 'Current milestone:\s+Post-M6 local/static safety gate hardening complete through (?<scope>[A-Za-z0-9]+Safety)\.')
    if (-not $milestoneMatch.Success) {
        throw 'active-run.md must keep a Current milestone marker ending in a Safety scope.'
    }
    if ($safetyScopes -notcontains $milestoneMatch.Groups['scope'].Value) {
        throw "active-run.md Current milestone marker names an unknown Safety scope: $($milestoneMatch.Groups['scope'].Value)"
    }

    Write-Host 'ActiveSafetyScopeInventorySafety gate passed.'
}

function Invoke-ScriptsReadmeScopeSafetyGate {
    $scriptPath = Join-Path $repoRoot 'scripts/quality-gate.ps1'
    $readmePath = Join-Path $repoRoot 'scripts/README.md'
    Assert-PathExists 'scripts/quality-gate.ps1'
    Assert-PathExists 'scripts/README.md'

    $script = Get-Content -LiteralPath $scriptPath -Raw
    $readme = Get-Content -LiteralPath $readmePath -Raw
    $validateSetMatch = [regex]::Match($script, "\[ValidateSet\((?<values>[^\)]*)\)\]")
    if (-not $validateSetMatch.Success) {
        throw 'quality-gate.ps1 does not declare a ValidateSet for -Scope.'
    }

    $scopes = [regex]::Matches($validateSetMatch.Groups['values'].Value, "'([^']+)'") |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object -Unique
    foreach ($scopeName in @($scopes | Where-Object { $_ -ne 'Full' })) {
        if ($readme -notmatch [regex]::Escape($scopeName)) {
            throw "scripts/README.md must mention quality gate scope: $scopeName"
        }
    }

    Write-Host 'ScriptsReadmeScopeSafety gate passed.'
}

function Invoke-GovernanceHistoryScopeSafetyGate {
    $scriptPath = Join-Path $repoRoot 'scripts/quality-gate.ps1'
    $verificationPath = Join-Path $repoRoot 'docs/context/engineering/verification-memory.md'
    $sessionLogPath = Join-Path $repoRoot 'docs/context/governance/session-log.md'
    Assert-PathExists 'scripts/quality-gate.ps1'
    Assert-PathExists 'docs/context/engineering/verification-memory.md'
    Assert-PathExists 'docs/context/governance/session-log.md'

    $script = Get-Content -LiteralPath $scriptPath -Raw
    $verificationMemory = Get-Content -LiteralPath $verificationPath -Raw
    $sessionLog = Get-Content -LiteralPath $sessionLogPath -Raw
    $validateSetMatch = [regex]::Match($script, "\[ValidateSet\((?<values>[^\)]*)\)\]")
    if (-not $validateSetMatch.Success) {
        throw 'quality-gate.ps1 does not declare a ValidateSet for -Scope.'
    }

    $safetyScopes = [regex]::Matches($validateSetMatch.Groups['values'].Value, "'([^']+Safety)'") |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object -Unique
    foreach ($scopeName in $safetyScopes) {
        if ($verificationMemory -notmatch [regex]::Escape($scopeName)) {
            throw "verification-memory.md must mention safety scope from ValidateSet: $scopeName"
        }
        if ($sessionLog -notmatch [regex]::Escape($scopeName)) {
            throw "session-log.md must mention safety scope from ValidateSet: $scopeName"
        }
    }

    Write-Host 'GovernanceHistoryScopeSafety gate passed.'
}

function Invoke-TestDataStructuredSyntaxSafetyGate {
    $testdataRoot = Join-Path $repoRoot 'testdata'
    Assert-PathExists 'testdata'

    $jsonFiles = @(Get-ChildItem -LiteralPath $testdataRoot -Recurse -File -Filter '*.json' | Sort-Object FullName)
    if ($jsonFiles.Count -eq 0) {
        throw 'testdata must contain JSON fixture files.'
    }

    foreach ($jsonFile in $jsonFiles) {
        $relativePath = (Resolve-Path -LiteralPath $jsonFile.FullName -Relative).TrimStart('.', '\') -replace '\\', '/'
        try {
            Get-Content -LiteralPath $jsonFile.FullName -Raw | ConvertFrom-Json | Out-Null
        }
        catch {
            throw "$relativePath must parse as JSON: $($_.Exception.Message)"
        }
    }

    $budgetPath = Join-Path $repoRoot 'testdata/prod-resource-budget.example.yaml'
    Assert-PathExists 'testdata/prod-resource-budget.example.yaml'
    $budgetText = Get-Content -LiteralPath $budgetPath -Raw
    if ($budgetText -notmatch '(?m)^prodResourceBudget:\s*$') {
        throw "testdata/prod-resource-budget.example.yaml must keep top-level prodResourceBudget mapping."
    }
    foreach ($requiredKey in @('maxSessionsPerRun', 'maxParallelSessions', 'maxSessionDurationSeconds', 'maxRunsPerHour', 'requireCleanupVerification', 'requireExplicitConditionalFlag', 'allowedRegions', 'allowedGames')) {
        if ($budgetText -notmatch "(?m)^\s+$([regex]::Escape($requiredKey)):\s*") {
            throw "testdata/prod-resource-budget.example.yaml must keep key: $requiredKey"
        }
    }

    Write-Host 'TestDataStructuredSyntaxSafety gate passed.'
}

function Invoke-QualityGateStructureSafetyGate {
    $scriptPath = Join-Path $repoRoot 'scripts/quality-gate.ps1'
    Assert-PathExists 'scripts/quality-gate.ps1'

    $script = Get-Content -LiteralPath $scriptPath -Raw
    $validateSetMatch = [regex]::Match($script, "\[ValidateSet\((?<values>[^\)]*)\)\]")
    if (-not $validateSetMatch.Success) {
        throw 'quality-gate.ps1 does not declare a ValidateSet for -Scope.'
    }

    $scopes = [regex]::Matches($validateSetMatch.Groups['values'].Value, "'([^']+)'") |
        ForEach-Object { $_.Groups[1].Value }
    if (@($scopes | Where-Object { $_ -eq 'Full' }).Count -ne 1) {
        throw "quality-gate.ps1 ValidateSet must include 'Full' exactly once."
    }

    foreach ($scopeName in @($scopes | Where-Object { $_ -ne 'Full' })) {
        $functionPattern = "(?m)^function\s+Invoke-$([regex]::Escape($scopeName))Gate\s*\{"
        $functionMatches = @([regex]::Matches($script, $functionPattern))
        if ($functionMatches.Count -ne 1) {
            throw "quality-gate.ps1 must define exactly one Invoke-$($scopeName)Gate function."
        }

        $dispatchPattern = "if\s*\(\s*\`$Scope\s+-in\s+@\('$([regex]::Escape($scopeName))',\s*'Full'\)\s*\)\s*\{\s*Invoke-$([regex]::Escape($scopeName))Gate\s*\}"
        $dispatchMatches = @([regex]::Matches($script, $dispatchPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline))
        if ($dispatchMatches.Count -ne 1) {
            throw "quality-gate.ps1 must dispatch scope '$scopeName' to Invoke-$($scopeName)Gate exactly once in Full."
        }
    }

    Write-Host 'QualityGateStructureSafety gate passed.'
}

function Get-LatestVerificationMemoryBranchEntryText {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $Text
    )

    $entryMatches = @([regex]::Matches($Text, '(?ms)^## \d{4}-\d{2}-\d{2} - .+?(?=^## \d{4}-\d{2}-\d{2} - |\z)'))
    $branchEntries = @($entryMatches | Where-Object { $_.Value -match 'Branch:\s+`codex/' })
    if ($branchEntries.Count -eq 0) {
        throw 'verification-memory.md must contain codex branch verification entries.'
    }

    return [string]$branchEntries[0].Value
}

function Resolve-SafetyScopeFromVerificationMemoryEntry {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $EntryText,

        [Parameter(Mandatory = $true)]
        [string[]] $KnownSafetyScopes
    )

    $titleLine = ([regex]::Match($EntryText, '^## .+', 'Multiline')).Value
    $branchLine = ([regex]::Match($EntryText, '^Branch:\s+`codex/[^`]+`', 'Multiline')).Value
    $markerText = "$titleLine`n$branchLine"

    $scopeMatches = @()
    foreach ($scopeName in $KnownSafetyScopes) {
        $scopeCore = $scopeName -replace 'Safety$', ''
        $coreWords = @([regex]::Matches($scopeCore, '[A-Z][a-z0-9]*|[0-9]+') | ForEach-Object { $_.Value.ToLowerInvariant() })
        if ($coreWords.Count -eq 0) {
            continue
        }

        $corePattern = ($coreWords | ForEach-Object { [regex]::Escape($_) }) -join '[-\s]+'
        if ($markerText -match "(?i)\b$corePattern(?:[-\s]+safety)?\b") {
            $scopeMatches += [pscustomobject]@{
                Scope      = $scopeName
                CoreLength = $scopeCore.Length
            }
        }
    }

    if ($scopeMatches.Count -eq 0) {
        throw 'verification-memory.md latest codex branch entry must identify a known Safety scope in its title or branch.'
    }

    $orderedMatches = @($scopeMatches | Sort-Object -Property CoreLength, Scope -Descending)
    if ($orderedMatches.Count -gt 1 -and $orderedMatches[0].CoreLength -eq $orderedMatches[1].CoreLength) {
        throw "verification-memory.md latest codex branch entry maps ambiguously to Safety scopes: $($orderedMatches[0].Scope), $($orderedMatches[1].Scope)"
    }

    return $orderedMatches[0].Scope
}

function Invoke-ActiveRunSafetyGate {
    $activeRunPath = Join-Path $repoRoot 'docs/context/handoff/active-run.md'
    $currentStatePath = Join-Path $repoRoot 'docs/context/current-state.md'
    $implementationStatusPath = Join-Path $repoRoot 'docs/context/engineering/implementation-status.md'
    $verificationMemoryPath = Join-Path $repoRoot 'docs/context/engineering/verification-memory.md'
    $contextProtocolPath = Join-Path $repoRoot 'docs/context/handoff/context-protocol.md'
    $executorPolicyPath = Join-Path $repoRoot 'docs/context/handoff/executor-policy.md'
    Assert-PathExists 'docs/context/handoff/active-run.md'
    Assert-PathExists 'docs/context/current-state.md'
    Assert-PathExists 'docs/context/engineering/implementation-status.md'
    Assert-PathExists 'docs/context/engineering/verification-memory.md'
    Assert-PathExists 'docs/context/handoff/context-protocol.md'
    Assert-PathExists 'docs/context/handoff/executor-policy.md'

    $activeRun = Get-Content -LiteralPath $activeRunPath -Raw
    $currentState = Get-Content -LiteralPath $currentStatePath -Raw
    $implementationStatus = Get-Content -LiteralPath $implementationStatusPath -Raw
    $verificationMemory = Get-Content -LiteralPath $verificationMemoryPath -Raw
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
            'scope expansion beyond local dry-run/schema validation',
            'Use `git status --short --branch` as the authoritative current branch/worktree source',
            'became inactive/history-only after handoff to `019e7aab-dbaf-70d0-b143-ed7e6eb0bde0`',
            'are preserved for history, are not deleted, are not archived automatically unless the user explicitly asks'
        )) {
        if ($activeRun -notmatch [regex]::Escape($requiredPhrase)) {
            throw "active-run.md must document safety boundary phrase: $requiredPhrase"
        }
    }

    if ($activeRun -match '(?i)latest pushed main commit|merged to origin/main at\s+[0-9a-f]{7,40}') {
        throw 'active-run.md must not record stale literal latest-pushed commit markers; use git log instead.'
    }
    if ($activeRun -match '(?ms)^Current branch:\s*```text\s*(?:codex/|main\b)') {
        throw 'active-run.md must not record a live literal current branch; use git status instead.'
    }
    if ($activeRun -match 'Thread\s+`[0-9a-f-]{36}`\s+is the active task thread') {
        throw 'active-run.md must not declare a literal historical thread id as the active task thread; document lifecycle rules instead.'
    }
    if ($currentState -match 'Thread\s+`[0-9a-f-]{36}`\s+is the active task thread') {
        throw 'current-state.md must not declare a literal historical thread id as the active task thread; document lifecycle rules instead.'
    }
    if ($currentState -match '(?i)Current installed artifact source') {
        throw 'current-state.md must not describe installed artifacts as the current autonomous verification source.'
    }
    if ($implementationStatus -match '(?is)Current artifact source:\s*.*C:\\Program Files\\MTC Fog Play') {
        throw 'implementation-status.md must not describe installed artifacts as the current autonomous verification source.'
    }
    foreach ($requiredCurrentStatePhrase in @(
            'Current autonomous verification source: committed local fixtures only',
            'Installed artifact reads from `C:\Program Files\MTC Fog Play` require a separate explicit approved plan'
        )) {
        if ($currentState -notmatch [regex]::Escape($requiredCurrentStatePhrase)) {
            throw "current-state.md must preserve active installed-artifact safety phrase: $requiredCurrentStatePhrase"
        }
    }
    foreach ($requiredImplementationStatusPhrase in @(
            'Historical artifact observation:',
            'installed signed client directory observed on 2026-05-30: `C:\Program Files\MTC Fog Play`',
            'current autonomous verification uses committed local fixtures only; installed artifact reads require a separate explicit approved plan.'
        )) {
        if ($implementationStatus -notmatch [regex]::Escape($requiredImplementationStatusPhrase)) {
            throw "implementation-status.md must preserve installed-artifact history phrase: $requiredImplementationStatusPhrase"
        }
    }

    $currentStaticSafetyScopes = @(Get-QualityGateScopeNames | Where-Object { $_ -match 'Safety$' } | Sort-Object -Unique)
    foreach ($scopeName in $currentStaticSafetyScopes) {
        if ($activeRun -notmatch [regex]::Escape($scopeName)) {
            throw "active-run.md must mention current static safety gate: $scopeName"
        }
        if ($currentState -notmatch [regex]::Escape($scopeName)) {
            throw "current-state.md must mention current static safety gate: $scopeName"
        }
    }
    $latestVerificationEntry = Get-LatestVerificationMemoryBranchEntryText -Text $verificationMemory
    $knownSafetyScopes = @(Get-QualityGateScopeNames | Where-Object { $_ -match 'Safety$' })
    $expectedMilestoneScope = Resolve-SafetyScopeFromVerificationMemoryEntry -EntryText $latestVerificationEntry -KnownSafetyScopes $knownSafetyScopes
    $milestoneMatch = [regex]::Match($activeRun, 'Current milestone:\s+Post-M6 local/static safety gate hardening complete through (?<scope>[A-Za-z0-9]+Safety)\.')
    if (-not $milestoneMatch.Success) {
        throw 'active-run.md must keep a Current milestone marker ending in a Safety scope.'
    }
    if ($milestoneMatch.Groups['scope'].Value -ne $expectedMilestoneScope) {
        throw "active-run.md Current milestone marker must sync with verification-memory.md latest codex branch entry: expected $expectedMilestoneScope."
    }
    if ($activeRun -notmatch '-Scope\s+ActiveRunSafety') {
        throw 'active-run.md Last verification must include ActiveRunSafety.'
    }

    if ($contextProtocol -notmatch 'git log --oneline --decorate -1') {
        throw 'context-protocol.md must identify git log as the authoritative latest commit source.'
    }
    if ($contextProtocol -notmatch 'git status --short --branch') {
        throw 'context-protocol.md must identify git status as the authoritative current branch source.'
    }
    if ($executorPolicy -notmatch 'Do not merge to main without explicit user approval') {
        throw 'executor-policy.md must preserve the explicit main-merge approval rule.'
    }

    Write-Host 'ActiveRunSafety gate passed.'
}

function Invoke-ContextDocsInventorySafetyGate {
    $contextRoot = Join-Path $repoRoot 'docs/context'
    Assert-PathExists 'docs/context'

    $expectedDocs = @(
        'current-state.md',
        'engineering/git-workflow.md',
        'engineering/implementation-status.md',
        'engineering/quality-gates.md',
        'engineering/verification-memory.md',
        'governance/context-integrity-checklist.md',
        'governance/decisions-log.md',
        'governance/session-log.md',
        'handoff/active-run.md',
        'handoff/context-protocol.md',
        'handoff/executor-checklist.md',
        'handoff/executor-policy.md',
        'handoff/task-request-log.md',
        'handoff/task-request-template.md'
    )
    $actualDocs = @(Get-ChildItem -LiteralPath $contextRoot -Recurse -File -Filter '*.md' | ForEach-Object {
            $_.FullName.Substring($contextRoot.Length + 1) -replace '\\', '/'
        } | Sort-Object)
    foreach ($doc in $expectedDocs) {
        if ($actualDocs -notcontains $doc) {
            throw "docs/context is missing required context doc: $doc"
        }
    }
    foreach ($doc in $actualDocs) {
        if ($expectedDocs -notcontains $doc) {
            throw "docs/context contains undocumented context doc: $doc"
        }
    }

    Write-Host 'ContextDocsInventorySafety gate passed.'
}

function Invoke-SessionLogSafetyGate {
    $sessionLogPath = Join-Path $repoRoot 'docs/context/governance/session-log.md'
    $verificationPath = Join-Path $repoRoot 'docs/context/engineering/verification-memory.md'
    Assert-PathExists 'docs/context/governance/session-log.md'
    Assert-PathExists 'docs/context/engineering/verification-memory.md'

    $sessionLog = Get-Content -LiteralPath $sessionLogPath -Raw
    $verificationMemory = Get-Content -LiteralPath $verificationPath -Raw
    $entryMatches = @([regex]::Matches($sessionLog, '(?ms)^## \d{4}-\d{2}-\d{2} - .+?(?=^## \d{4}-\d{2}-\d{2} - |\z)'))
    if ($entryMatches.Count -eq 0) {
        throw 'session-log.md must contain dated session entries.'
    }

    $branchEntries = @($entryMatches | Where-Object {
            $_.Value -match 'Branch:\s+`codex/' -and
            $_.Value -match 'after user allowed autonomous work and pushes to main'
        })
    if ($branchEntries.Count -eq 0) {
        throw 'session-log.md must contain guarded codex branch entries.'
    }

    $latestVerificationBranchEntry = Get-LatestVerificationMemoryBranchEntryText -Text $verificationMemory
    $latestVerificationBranchMatch = [regex]::Match($latestVerificationBranchEntry, '^Branch:\s+`(?<branch>codex/[^`]+)`', 'Multiline')
    if (-not $latestVerificationBranchMatch.Success) {
        throw 'verification-memory.md latest codex branch entry must include a codex branch line.'
    }
    $latestSessionBranchEntries = @($entryMatches | Where-Object { $_.Value -match 'Branch:\s+`codex/' })
    if ($latestSessionBranchEntries.Count -eq 0) {
        throw 'session-log.md must contain codex branch entries.'
    }
    $latestSessionBranchMatch = [regex]::Match($latestSessionBranchEntries[0].Value, '^Branch:\s+`(?<branch>codex/[^`]+)`', 'Multiline')
    if (-not $latestSessionBranchMatch.Success) {
        throw 'session-log.md latest codex branch entry must include a codex branch line.'
    }
    if ($latestSessionBranchMatch.Groups['branch'].Value -ne $latestVerificationBranchMatch.Groups['branch'].Value) {
        throw "session-log.md latest codex branch entry must match verification-memory.md latest codex branch: expected $($latestVerificationBranchMatch.Groups['branch'].Value)."
    }

    foreach ($entry in $branchEntries) {
        $entryText = $entry.Value
        $title = ([regex]::Match($entryText, '^## .+', 'Multiline')).Value
        foreach ($requiredHeading in @('Mode:', 'Branch:', 'Scope:', 'Safety:')) {
            if ($entryText -notmatch [regex]::Escape($requiredHeading)) {
                throw "session-log.md entry '$title' must include $requiredHeading"
            }
        }
        foreach ($requiredPhrase in @(
                'No installed client launch',
                'No WebView debug/CDP',
                'No authentication',
                'No production backend',
                'No game session',
                'No user AppData'
            )) {
            if ($entryText -notmatch [regex]::Escape($requiredPhrase)) {
                throw "session-log.md entry '$title' must preserve safety phrase: $requiredPhrase"
            }
        }
    }

    $latestEntry = $entryMatches[0]
    if ($latestEntry.Value -match 'Branch:\s+`codex/') {
        $entryText = $latestEntry.Value
        $title = ([regex]::Match($entryText, '^## .+', 'Multiline')).Value
        foreach ($requiredHeading in @('Mode:', 'Branch:', 'Thread lifecycle:', 'Scope:', 'Safety:')) {
            if ($entryText -notmatch [regex]::Escape($requiredHeading)) {
                throw "session-log.md latest entry '$title' must include $requiredHeading"
            }
        }
        if ($entryText -notmatch [regex]::Escape('inactive/history-only')) {
            throw "session-log.md latest entry '$title' must preserve inactive/history-only lifecycle wording"
        }
        foreach ($requiredPhrase in @(
                'No installed client launch',
                'No WebView debug/CDP',
                'No authentication',
                'No production backend',
                'No game session',
                'No user AppData'
            )) {
            if ($entryText -notmatch [regex]::Escape($requiredPhrase)) {
                throw "session-log.md latest entry '$title' must preserve safety phrase: $requiredPhrase"
            }
        }
    }

    Write-Host 'SessionLogSafety gate passed.'
}

function Invoke-VerificationMemorySafetyGate {
    $verificationPath = Join-Path $repoRoot 'docs/context/engineering/verification-memory.md'
    Assert-PathExists 'docs/context/engineering/verification-memory.md'

    $verificationMemory = Get-Content -LiteralPath $verificationPath -Raw
    foreach ($forbiddenPending in @('verification pending', '- pending', 'pending local run')) {
        if ($verificationMemory -match [regex]::Escape($forbiddenPending)) {
            throw "verification-memory.md must not contain unresolved marker: $forbiddenPending"
        }
    }

    $entryMatches = @([regex]::Matches($verificationMemory, '(?ms)^## \d{4}-\d{2}-\d{2} - .+?(?=^## \d{4}-\d{2}-\d{2} - |\z)'))
    $branchEntries = @($entryMatches | Where-Object { $_.Value -match 'Branch:\s+`codex/' })
    if ($branchEntries.Count -eq 0) {
        throw 'verification-memory.md must contain codex branch verification entries.'
    }

    foreach ($entry in $branchEntries) {
        $entryText = $entry.Value
        $title = ([regex]::Match($entryText, '^## .+', 'Multiline')).Value
        foreach ($requiredPhrase in @('Status: passed', 'Production impact:', 'Commands:', 'Results:')) {
            if ($entryText -notmatch [regex]::Escape($requiredPhrase)) {
                throw "verification-memory.md entry '$title' must include $requiredPhrase"
            }
        }
        $productionImpactLine = ([regex]::Match($entryText, '^Production impact:\s*(.+)$', 'Multiline')).Value
        if ($productionImpactLine -match 'Production impact:\s*none;' -and $productionImpactLine -match '\bstatic\b' -and $entryText -notmatch 'Not run:') {
            throw "verification-memory.md static entry '$title' must include Not run rationale."
        }
    }

    $latestBranchEntryText = $branchEntries[0].Value
    $latestBranchEntryTitle = ([regex]::Match($latestBranchEntryText, '^## .+', 'Multiline')).Value
    foreach ($requiredPhrase in @(
            'Safety notes:',
            'No real credentials committed.',
            'No production game session started.',
            'No unsafe test enabled.'
        )) {
        if ($latestBranchEntryText -notmatch [regex]::Escape($requiredPhrase)) {
            throw "verification-memory.md latest entry '$latestBranchEntryTitle' must preserve safety phrase: $requiredPhrase"
        }
    }

    Write-Host 'VerificationMemorySafety gate passed.'
}

function Get-QualityGateScopeNames {
    $scriptPath = Join-Path $repoRoot 'scripts/quality-gate.ps1'
    Assert-PathExists 'scripts/quality-gate.ps1'

    $script = Get-Content -LiteralPath $scriptPath -Raw
    $validateSetMatch = [regex]::Match($script, "\[ValidateSet\((?<values>[^\)]*)\)\]")
    if (-not $validateSetMatch.Success) {
        throw 'quality-gate.ps1 does not declare a ValidateSet for -Scope.'
    }

    return @([regex]::Matches($validateSetMatch.Groups['values'].Value, "'([^']+)'") |
            ForEach-Object { $_.Groups[1].Value })
}

function Get-CommandBulletsFromSection {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]] $Lines,

        [Parameter(Mandatory = $true)]
        [string] $SectionPattern,

        [Parameter(Mandatory = $true)]
        [string] $SourceName
    )

    $inSection = $false
    $startedCommands = $false
    $commands = @()
    for ($lineNumber = 0; $lineNumber -lt $Lines.Count; $lineNumber++) {
        $line = [string]$Lines[$lineNumber]
        if (-not $inSection) {
            if ($line -match $SectionPattern) {
                $inSection = $true
            }
            continue
        }

        if ($line.Trim() -eq '' -and -not $startedCommands) {
            continue
        }

        $commandMatch = [regex]::Match($line, '^\s*-\s+`(?<command>[^`]+)`[.;]?\s*$')
        if ($commandMatch.Success) {
            $startedCommands = $true
            $commands += [pscustomobject]@{
                Command = $commandMatch.Groups['command'].Value
                Line    = $lineNumber + 1
                Source  = $SourceName
            }
            continue
        }

        if ($startedCommands -or $line.Trim() -ne '') {
            break
        }
    }

    if ($commands.Count -eq 0) {
        throw "$SourceName must contain command bullet lines under the requested section."
    }

    return $commands
}

function Get-MostRecentVerificationMemoryCommandBullets {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]] $Lines
    )

    $entryStart = -1
    for ($lineNumber = 0; $lineNumber -lt $Lines.Count; $lineNumber++) {
        if ([string]$Lines[$lineNumber] -match '^## \d{4}-\d{2}-\d{2} - ') {
            $entryStart = $lineNumber
            break
        }
    }
    if ($entryStart -lt 0) {
        throw 'verification-memory.md must contain a dated top entry.'
    }

    $entryEnd = $Lines.Count
    for ($lineNumber = $entryStart + 1; $lineNumber -lt $Lines.Count; $lineNumber++) {
        if ([string]$Lines[$lineNumber] -match '^## \d{4}-\d{2}-\d{2} - ') {
            $entryEnd = $lineNumber
            break
        }
    }

    $entryLines = @($Lines[$entryStart..($entryEnd - 1)])
    return Get-CommandBulletsFromSection -Lines $entryLines -SectionPattern '^Commands:\s*$' -SourceName 'verification-memory.md top entry Commands'
}

function Assert-ActiveVerificationCommandIsSafe {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject] $CommandRecord,

        [Parameter(Mandatory = $true)]
        [string[]] $KnownScopes
    )

    $command = $CommandRecord.Command.Trim()
    $location = "$($CommandRecord.Source):$($CommandRecord.Line)"

    $forbiddenPatterns = @(
        @{ Id = 'installed-client-path'; Pattern = '(?i)C:\\Program Files\\MTC Fog Play' },
        @{ Id = 'absolute-user-path'; Pattern = '(?i)C:\\Users\\' },
        @{ Id = 'appdata'; Pattern = '(?i)AppData' },
        @{ Id = 'runtime-data-path'; Pattern = '(?i)(cookies?|Local Storage|IndexedDB|\.db\b|\.sqlite\b|\.dmp\b|\.dump\b|\.log\b|\\logs?\\|/logs?/)' },
        @{ Id = 'remote-url'; Pattern = '(?i)\bhttps?://' },
        @{ Id = 'localhost'; Pattern = '(?i)\b(?:localhost|127\.0\.0\.1|0\.0\.0\.0|::1)\b' },
        @{ Id = 'webview-debug'; Pattern = '(?i)(remote-debugging|debug-port|webview-debug|devtools|chrome-devtools|\bcdp\b)' },
        @{ Id = 'direct-runner'; Pattern = '(?i)(^|\s|\\|/)run-[A-Za-z0-9-]+\.ps1\b' },
        @{ Id = 'auth-network-session-flags'; Pattern = '(?i)(-AllowAuth|-AllowNetwork|-AllowExecution|-AllowRollback|-AllowCredentials|-AllowClientLaunch|-AllowWebViewDebugPort|-AllowProdConditional|auth\s|login|session\s+start|start-session|game-session)' },
        @{ Id = 'network-or-ci-command'; Pattern = '(?i)(Invoke-WebRequest|Invoke-RestMethod|\bcurl\b|\bwget\b|\bnpm\b|\byarn\b|\bpnpm\b|\bpip\s+install\b|\bdotnet\s+restore\b|\bgh\s+workflow\b|ci/cd|pipeline)' }
    )
    foreach ($pattern in $forbiddenPatterns) {
        if ($command -match $pattern.Pattern) {
            throw "$location contains forbidden active verification command token: $($pattern.Id)."
        }
    }

    $qualityGateMatch = [regex]::Match($command, '^powershell -NoProfile -ExecutionPolicy Bypass -File \.\\scripts\\quality-gate\.ps1 -Scope (?<scope>[A-Za-z0-9]+)$')
    if ($qualityGateMatch.Success) {
        $scopeName = $qualityGateMatch.Groups['scope'].Value
        if ($KnownScopes -notcontains $scopeName) {
            throw "$location references unknown quality-gate scope: $scopeName"
        }
        return
    }

    if ($command -in @('git diff --check', 'git status --short --branch')) {
        return
    }

    throw "$location has unsupported active verification command shape: $command"
}

function Invoke-ActiveVerificationCommandSafetyGate {
    $activeRunPath = Join-Path $repoRoot 'docs/context/handoff/active-run.md'
    $verificationPath = Join-Path $repoRoot 'docs/context/engineering/verification-memory.md'
    Assert-PathExists 'docs/context/handoff/active-run.md'
    Assert-PathExists 'docs/context/engineering/verification-memory.md'

    $knownScopes = Get-QualityGateScopeNames
    $activeRunLines = @(Get-Content -LiteralPath $activeRunPath)
    $verificationLines = @(Get-Content -LiteralPath $verificationPath)
    $commandRecords = @()
    $commandRecords += Get-CommandBulletsFromSection -Lines $activeRunLines -SectionPattern '^Last verification:\s*$' -SourceName 'active-run.md Last verification'
    $commandRecords += Get-MostRecentVerificationMemoryCommandBullets -Lines $verificationLines

    foreach ($commandRecord in $commandRecords) {
        Assert-ActiveVerificationCommandIsSafe -CommandRecord $commandRecord -KnownScopes $knownScopes
    }

    Write-Host 'ActiveVerificationCommandSafety gate passed.'
}

function Invoke-ChecklistSafetyGate {
    $executorChecklistPath = Join-Path $repoRoot 'docs/context/handoff/executor-checklist.md'
    $contextChecklistPath = Join-Path $repoRoot 'docs/context/governance/context-integrity-checklist.md'
    Assert-PathExists 'docs/context/handoff/executor-checklist.md'
    Assert-PathExists 'docs/context/governance/context-integrity-checklist.md'

    $executorChecklist = Get-Content -LiteralPath $executorChecklistPath -Raw
    $contextChecklist = Get-Content -LiteralPath $contextChecklistPath -Raw

    foreach ($requiredSection in @('Before implementation:', 'Before final report:')) {
        if ($executorChecklist -notmatch [regex]::Escape($requiredSection)) {
            throw "executor-checklist.md must include section: $requiredSection"
        }
    }

    foreach ($requiredPhrase in @(
            'git status --short',
            'Correct task thread confirmed',
            'New independent task/milestone has its own Codex thread',
            '`create_thread` used or attempted first',
            'No `PROCESS_ERROR_THREAD_REUSE` remains unresolved',
            'Not working directly on main, unless explicitly allowed',
            'AGENTS.md read',
            'Autonomy boundary and stop-and-ask triggers understood',
            'Production impact classified',
            'Verification commands identified',
            'verification-memory.md updated',
            'session-log.md updated',
            'active-run.md updated',
            'No secrets committed',
            'No stop-and-ask trigger bypassed',
            'No unapproved production-impacting tests added'
        )) {
        if ($executorChecklist -notmatch [regex]::Escape($requiredPhrase)) {
            throw "executor-checklist.md must preserve checklist phrase: $requiredPhrase"
        }
    }

    foreach ($requiredPhrase in @(
            '`active-run.md` matches latest focus/status',
            'Current work is in the correct task thread',
            'Any new independent task/milestone has a separate Codex thread',
            '`create_thread` was used or attempted first',
            'PROCESS_ERROR_THREAD_REUSE',
            '`current-state.md` reflects current state',
            '`value-effort-backlog.md` points to next bounded work',
            '`decisions-log.md` records durable decisions',
            '`session-log.md` records meaningful work',
            '`verification-memory.md` records commands/results',
            '`implementation-status.md` matches code/docs',
            'No important decision lives only in chat'
        )) {
        if ($contextChecklist -notmatch [regex]::Escape($requiredPhrase)) {
            throw "context-integrity-checklist.md must preserve checklist phrase: $requiredPhrase"
        }
    }

    Write-Host 'ChecklistSafety gate passed.'
}

function Invoke-DecisionsLogSafetyGate {
    $decisionsLogPath = Join-Path $repoRoot 'docs/context/governance/decisions-log.md'
    Assert-PathExists 'docs/context/governance/decisions-log.md'

    $decisionsLog = Get-Content -LiteralPath $decisionsLogPath -Raw
    foreach ($decisionId in 1..10) {
        $formattedId = 'D-{0:D3}' -f $decisionId
        if ($decisionsLog -notmatch "##\s+${formattedId}:") {
            throw "decisions-log.md must preserve decision entry: $formattedId"
        }
    }

    $decisionEntries = @([regex]::Matches($decisionsLog, '(?ms)^## D-\d{3}: .+?(?=^## D-\d{3}: |\z)'))
    foreach ($entry in $decisionEntries) {
        $entryText = $entry.Value
        $title = ([regex]::Match($entryText, '^## D-\d{3}: .+', 'Multiline')).Value
        if ($entryText -notmatch 'Status:\s+accepted\.') {
            throw "decisions-log.md entry '$title' must keep accepted status."
        }
        if ($entryText -notmatch 'Decision:') {
            throw "decisions-log.md entry '$title' must include a Decision statement."
        }
    }

    foreach ($requiredPhrase in @(
            'production-safety foundation, not game-session E2E',
            'does not work directly on main',
            'no production game-session automation before ProdGuard',
            'release artifact and privacy gates are independent from E2E',
            'update rollback, network degradation, load/stress/chaos and destructive tests are not production tests',
            'NON_AUTONOMOUS for discovery/risky/production-impacting work',
            'BOUNDED_AUTONOMOUS only after the user accepts a bounded plan',
            'multi-agent mode by default for non-trivial milestones',
            'Merge to `main` still requires explicit user approval',
            'commit and push are separate actions',
            'user approval to "push" the current task branch includes permission to create the required local commit',
            'does not include permission to merge to `main`',
            'every new independent task or milestone in autonomous work uses a separate Codex thread',
            'extended autonomous time, permission to push, or permission to merge changes execution authority only',
            'each newly selected follow-up quality gate, hardening item, feature slice, backlog item or milestone is a new independent task',
            '`create_thread` is the priority mechanism',
            'retries `create_thread` once',
            'the previous task thread becomes inactive/history-only after handoff',
            'must not be deleted and is not archived automatically unless the user explicitly asks',
            'PROCESS_ERROR_THREAD_REUSE'
        )) {
        if ($decisionsLog -notmatch [regex]::Escape($requiredPhrase)) {
            throw "decisions-log.md must preserve decision phrase: $requiredPhrase"
        }
    }

    Write-Host 'DecisionsLogSafety gate passed.'
}

function Invoke-CodexPolicySafetyGate {
    $prodSafeRulesPath = Join-Path $repoRoot 'docs/codex/prod-safe-codex-rules.md'
    $gitHandoffRulesPath = Join-Path $repoRoot 'docs/codex/git-handoff-rules.md'
    $autonomyModesPath = Join-Path $repoRoot 'docs/codex/autonomy-modes.md'
    $goalModeRulesPath = Join-Path $repoRoot 'docs/codex/goal-mode-rules.md'
    $workflowPath = Join-Path $repoRoot 'docs/codex/codex-workflow.md'
    $executorPolicyPath = Join-Path $repoRoot 'docs/context/handoff/executor-policy.md'

    Assert-PathExists 'docs/codex/prod-safe-codex-rules.md'
    Assert-PathExists 'docs/codex/git-handoff-rules.md'
    Assert-PathExists 'docs/codex/autonomy-modes.md'
    Assert-PathExists 'docs/codex/goal-mode-rules.md'
    Assert-PathExists 'docs/codex/codex-workflow.md'
    Assert-PathExists 'docs/context/handoff/executor-policy.md'

    $prodSafeRules = Get-Content -LiteralPath $prodSafeRulesPath -Raw
    $gitHandoffRules = Get-Content -LiteralPath $gitHandoffRulesPath -Raw
    $autonomyModes = Get-Content -LiteralPath $autonomyModesPath -Raw
    $goalModeRules = Get-Content -LiteralPath $goalModeRulesPath -Raw
    $workflow = Get-Content -LiteralPath $workflowPath -Raw
    $executorPolicy = Get-Content -LiteralPath $executorPolicyPath -Raw

    foreach ($requiredPhrase in @(
            'run unclassified tests on production',
            'run PROD_FORBIDDEN on production',
            'run PROD_CONDITIONAL without explicit flag',
            'use real user accounts',
            'hardcode credentials',
            'weaken ProdGuard/KillSwitch',
            'add blind retries hiding instability',
            'start game sessions before resource budget and cleanup verification exist'
        )) {
        if ($prodSafeRules -notmatch [regex]::Escape($requiredPhrase)) {
            throw "prod-safe-codex-rules.md must preserve rule: $requiredPhrase"
        }
    }

    foreach ($requiredPhrase in @(
            'Branch per task',
            'No direct work on main',
            'No merge to main without explicit user approval',
            'Declare autonomy mode in active-run.md',
            'Default to NON_AUTONOMOUS when scope or production impact is unclear',
            'verification-memory.md keeps commands/results',
            'decisions-log.md keeps durable decisions'
        )) {
        if ($gitHandoffRules -notmatch [regex]::Escape($requiredPhrase)) {
            throw "git-handoff-rules.md must preserve rule: $requiredPhrase"
        }
    }

    foreach ($requiredPhrase in @(
            'autonomy is never implicit',
            'If the mode is not declared, use **non-autonomous / supervised mode**',
            'After the user accepts the current milestone plan, Codex may work in `BOUNDED_AUTONOMOUS` mode only inside that accepted scope',
            'extended autonomous time, push permission or merge permission does not permit batching multiple independent tasks in one thread',
            'each newly selected follow-up gate, hardening item, feature slice or backlog item starts a new independent task',
            'the previous task thread becomes inactive/history-only after handoff',
            'is not deleted and is not archived automatically unless the user explicitly asks',
            'production-impacting tasks',
            'any change that can start a cloud-gaming session',
            'CI/CD changes that can run tests automatically',
            'dependency upgrades',
            'credentials, secrets, auth, synthetic-user configuration',
            'merge to `main`',
            'no production game session is started',
            'no merge to `main` happens without explicit approval',
            'Stop and ask before any production-impacting action, scope expansion, credential use, CI/CD enablement, commit/push if not explicitly allowed, or merge to main'
        )) {
        if ($autonomyModes -notmatch [regex]::Escape($requiredPhrase)) {
            throw "autonomy-modes.md must preserve rule: $requiredPhrase"
        }
    }

    foreach ($requiredPhrase in @(
            'Every new milestone starts with a `NON_AUTONOMOUS` discovery/planning step',
            'Codex must not create or execute a detailed implementation plan for all future milestones unless the user explicitly requests it',
            'Codex must stop and ask before production impact, scope expansion, game sessions, credential/secret use, CI/CD enablement, dependency upgrade, guard weakening, commit/push if not explicitly allowed, or merge to `main`'
        )) {
        if ($goalModeRules -notmatch [regex]::Escape($requiredPhrase)) {
            throw "goal-mode-rules.md must preserve rule: $requiredPhrase"
        }
    }

    foreach ($requiredPhrase in @(
            'Confirm this is the correct Codex thread',
            'For a new independent task or milestone, use `create_thread` first',
            'Treat a newly selected follow-up gate, hardening item, feature slice or backlog item as a new independent task',
            'Treat extended autonomous time, push permission and merge permission as execution permissions only',
            'Preserve the previous task thread for history: do not delete it, and do not archive it automatically unless the user explicitly asks',
            'Wait for approval if in NON_AUTONOMOUS discovery mode',
            'Confirm production classification',
            'Implement only allowed scope',
            'Do not merge main without explicit approval',
            'PROCESS_ERROR_THREAD_REUSE'
        )) {
        if ($workflow -notmatch [regex]::Escape($requiredPhrase)) {
            throw "codex-workflow.md must preserve rule: $requiredPhrase"
        }
    }

    foreach ($requiredPhrase in @(
            'Every run must declare autonomy mode: NON_AUTONOMOUS or BOUNDED_AUTONOMOUS',
            'Default to NON_AUTONOMOUS until the user accepts the plan',
            'Every new independent task or milestone in autonomous work must use a separate Codex thread',
            'User approval for long-running autonomous work, extra autonomous hours, push permission, or merge permission does not combine independent tasks into one thread',
            'Each newly chosen follow-up hardening gate, milestone, feature slice, or backlog item is a new independent task',
            'The previous task thread is preserved for history: it must not be deleted and is not archived automatically unless the user explicitly asks',
            'Do not expand scope without user approval',
            'Do not work directly on main',
            'Do not merge to main without explicit user approval',
            'Do not commit secrets, logs, crash dumps or release binaries unless explicitly approved as fixtures',
            'If a task may affect production, classify it before implementation',
            'If safety cannot be proven, treat production run as forbidden',
            'stop and ask before scope expansion, production impact, credential use, CI/CD enablement, commit/push if not explicitly allowed, or merge to main'
        )) {
        if ($executorPolicy -notmatch [regex]::Escape($requiredPhrase)) {
            throw "executor-policy.md must preserve rule: $requiredPhrase"
        }
    }

    Write-Host 'CodexPolicySafety gate passed.'
}

function Invoke-TaskRequestSafetyGate {
    $templatePath = Join-Path $repoRoot 'docs/context/handoff/task-request-template.md'
    $logPath = Join-Path $repoRoot 'docs/context/handoff/task-request-log.md'
    Assert-PathExists 'docs/context/handoff/task-request-template.md'
    Assert-PathExists 'docs/context/handoff/task-request-log.md'

    $template = Get-Content -LiteralPath $templatePath -Raw
    $log = Get-Content -LiteralPath $logPath -Raw

    foreach ($requiredPhrase in @(
            '/goal [bounded goal]',
            'Context:',
            'Objective:',
            'Scope:',
            'Allowed paths:',
            'Forbidden:',
            'Production classification:',
            'PROD_SAFE / PROD_CONDITIONAL / PROD_FORBIDDEN / NON_PROD_ONLY',
            'Acceptance criteria:',
            'Verification:',
            'Stop when:'
        )) {
        if ($template -notmatch [regex]::Escape($requiredPhrase)) {
            throw "task-request-template.md must preserve template phrase: $requiredPhrase"
        }
    }

    if ($log -match 'No Codex task has been executed yet') {
        throw 'task-request-log.md must not contain stale no-task marker.'
    }
    foreach ($requiredPhrase in @(
            'Task request log',
            'Authoritative task execution history lives in',
            'session-log.md',
            'verification-memory.md',
            'active-run.md',
            'New task requests must preserve context, objective, scope, forbidden actions, production classification, acceptance criteria, verification commands and stop conditions.'
        )) {
        if ($log -notmatch [regex]::Escape($requiredPhrase)) {
            throw "task-request-log.md must preserve log phrase: $requiredPhrase"
        }
    }

    Write-Host 'TaskRequestSafety gate passed.'
}

function Invoke-CodexTemplateSafetyGate {
    $reviewTemplatePath = Join-Path $repoRoot 'docs/codex/review-template.md'
    $taskTemplatePath = Join-Path $repoRoot 'docs/codex/task-template.md'
    $communicationPolicyPath = Join-Path $repoRoot 'docs/codex/communication-policy.md'
    $agentRolesPath = Join-Path $repoRoot 'docs/codex/agent-roles.md'

    Assert-PathExists 'docs/codex/review-template.md'
    Assert-PathExists 'docs/codex/task-template.md'
    Assert-PathExists 'docs/codex/communication-policy.md'
    Assert-PathExists 'docs/codex/agent-roles.md'

    $reviewTemplate = Get-Content -LiteralPath $reviewTemplatePath -Raw
    $taskTemplate = Get-Content -LiteralPath $taskTemplatePath -Raw
    $communicationPolicy = Get-Content -LiteralPath $communicationPolicyPath -Raw
    $agentRoles = Get-Content -LiteralPath $agentRolesPath -Raw

    foreach ($requiredPhrase in @(
            'scope drift',
            'autonomy mode declared and respected',
            'production classification',
            'secrets',
            'flakiness',
            'cleanup',
            'verification evidence',
            'docs updated',
            'no merge to main without approval',
            'stop-and-ask triggers were not bypassed'
        )) {
        if ($reviewTemplate -notmatch [regex]::Escape($requiredPhrase)) {
            throw "review-template.md must preserve review item: $requiredPhrase"
        }
    }

    foreach ($requiredPhrase in @(
            'Task:',
            'Execution mode:',
            'Scope:',
            'Classification:',
            'Allowed files:',
            'Forbidden:',
            'Verification:'
        )) {
        if ($taskTemplate -notmatch [regex]::Escape($requiredPhrase)) {
            throw "task-template.md must preserve template field: $requiredPhrase"
        }
    }

    foreach ($requiredPhrase in @(
            'User-facing answers, plans, status updates, final reports, blockers and questions must be written in Russian by default',
            'Codex must not expose private chain-of-thought or raw scratchpad reasoning',
            'production-safety implications',
            'verification performed',
            'Stop-and-ask language',
            'what decision is needed',
            'why Codex cannot safely proceed without it',
            'Production-safety',
            'Production-impacting'
        )) {
        if ($communicationPolicy -notmatch [regex]::Escape($requiredPhrase)) {
            throw "communication-policy.md must preserve communication rule: $requiredPhrase"
        }
    }

    foreach ($requiredPhrase in @(
            'multi-agent mode by default for all non-trivial milestones',
            'Planner does not change files',
            'Builder does not commit/push',
            'QA Reviewer does not commit/push',
            'Orchestrator commits/pushes only after verification and only when allowed',
            'Merge to `main` always requires explicit user approval',
            'Never use remote speed as a reason to skip local verification',
            'Never merge or force-push protected trunk without explicit approval',
            'Prod Safety: production classification, credentials, game-session and guard review'
        )) {
        if ($agentRoles -notmatch [regex]::Escape($requiredPhrase)) {
            throw "agent-roles.md must preserve role rule: $requiredPhrase"
        }
    }

    Write-Host 'CodexTemplateSafety gate passed.'
}

function Invoke-CodexGoalTemplateSafetyGate {
    $goalTemplatePath = Join-Path $repoRoot 'docs/codex/goal-template.md'
    Assert-PathExists 'docs/codex/goal-template.md'

    $goalTemplate = Get-Content -LiteralPath $goalTemplatePath -Raw
    foreach ($requiredPhrase in @(
            '/goal [name]',
            'Context:',
            'Execution mode:',
            'Discovery and plan: NON_AUTONOMOUS.',
            'Implementation after accepted plan: BOUNDED_AUTONOMOUS within approved scope.',
            'Stop and ask before production impact, scope expansion, credentials, CI/CD enablement, commit/push if not explicitly allowed, or merge to main.',
            'Objective:',
            'Read first:',
            'AGENTS.md',
            'docs/context/handoff/active-run.md',
            'Scope:',
            'Allowed:',
            'Forbidden:',
            'Acceptance criteria:',
            'Verification:',
            'Stop when:'
        )) {
        if ($goalTemplate -notmatch [regex]::Escape($requiredPhrase)) {
            throw "goal-template.md must preserve goal template phrase: $requiredPhrase"
        }
    }

    Write-Host 'CodexGoalTemplateSafety gate passed.'
}

function Invoke-CodexDocsInventorySafetyGate {
    $codexDocsRoot = Join-Path $repoRoot 'docs/codex'
    Assert-PathExists 'docs/codex'

    $expectedDocs = @(
        'agent-roles.md',
        'autonomy-modes.md',
        'codex-workflow.md',
        'communication-policy.md',
        'git-handoff-rules.md',
        'goal-mode-rules.md',
        'goal-template.md',
        'milestone-planning-policy.md',
        'prod-safe-codex-rules.md',
        'review-template.md',
        'task-template.md'
    )
    $actualDocs = @(Get-ChildItem -LiteralPath $codexDocsRoot -File -Filter '*.md' | ForEach-Object { $_.Name } | Sort-Object)
    foreach ($doc in $expectedDocs) {
        if ($actualDocs -notcontains $doc) {
            throw "docs/codex is missing required policy/template doc: $doc"
        }
    }
    foreach ($doc in $actualDocs) {
        if ($expectedDocs -notcontains $doc) {
            throw "docs/codex contains undocumented policy/template doc: $doc"
        }
    }

    Write-Host 'CodexDocsInventorySafety gate passed.'
}

function Invoke-QaStrategySafetyGate {
    $strategyPath = Join-Path $repoRoot 'docs/qa/test-strategy.md'
    $contractPath = Join-Path $repoRoot 'docs/qa/testability-contract.md'
    $flakinessPath = Join-Path $repoRoot 'docs/qa/flakiness-policy.md'
    Assert-PathExists 'docs/qa/test-strategy.md'
    Assert-PathExists 'docs/qa/testability-contract.md'
    Assert-PathExists 'docs/qa/flakiness-policy.md'

    $strategy = Get-Content -LiteralPath $strategyPath -Raw
    $contract = Get-Content -LiteralPath $contractPath -Raw
    $flakiness = Get-Content -LiteralPath $flakinessPath -Raw

    foreach ($requiredPhrase in @(
            'ProdSafety framework',
            'Git/handoff/verification governance',
            'Release artifact gates',
            'Privacy/logging gates',
            'App launch and WebView smoke',
            'WebView/native bridge contract and fake native host',
            'Safe backend read-only smoke',
            'Minimal game-session canary as PROD_CONDITIONAL',
            'Future non-prod fake/replay/network/hardware regression',
            'Testability gap registry for runtime blockers and required evidence',
            'Do not start with broad E2E'
        )) {
        if ($strategy -notmatch [regex]::Escape($requiredPhrase)) {
            throw "test-strategy.md must preserve strategy phrase: $requiredPhrase"
        }
    }

    foreach ($requiredPhrase in @(
            '--test-mode',
            '--test-config=<path>',
            '--log-dir=<path>',
            '--crash-dump-dir=<path>',
            '--clean-user-data',
            '--disable-auto-update',
            '--enable-diagnostics',
            '--webview-debug-port=<localhost-port>',
            'Debug/CDP ports must never be enabled for normal production users by default',
            'Runtime and environment gaps are tracked in `docs/qa/testability-gaps.md` and `testdata/testability-gaps.example.json`'
        )) {
        if ($contract -notmatch [regex]::Escape($requiredPhrase)) {
            throw "testability-contract.md must preserve contract phrase: $requiredPhrase"
        }
    }

    foreach ($requiredPhrase in @(
            'Blind retry is not a fix',
            'Retry must have a strict limit and a reason',
            'Retry must not create extra production sessions outside budget',
            'Prefer observable waits over arbitrary sleep',
            'Flaky tests must be stabilized or quarantined with reason',
            'Quarantine must have a follow-up task'
        )) {
        if ($flakiness -notmatch [regex]::Escape($requiredPhrase)) {
            throw "flakiness-policy.md must preserve flakiness phrase: $requiredPhrase"
        }
    }

    Write-Host 'QaStrategySafety gate passed.'
}

function Invoke-HandoffProtocolSafetyGate {
    $contextProtocolPath = Join-Path $repoRoot 'docs/context/handoff/context-protocol.md'
    $gitWorkflowPath = Join-Path $repoRoot 'docs/context/engineering/git-workflow.md'
    Assert-PathExists 'docs/context/handoff/context-protocol.md'
    Assert-PathExists 'docs/context/engineering/git-workflow.md'

    $contextProtocol = Get-Content -LiteralPath $contextProtocolPath -Raw
    $gitWorkflow = Get-Content -LiteralPath $gitWorkflowPath -Raw

    foreach ($requiredSource in @(
            'AGENTS.md',
            'docs/context/handoff/active-run.md',
            'docs/context/current-state.md',
            'docs/context/handoff/context-protocol.md',
            'docs/context/handoff/executor-policy.md',
            'docs/context/handoff/executor-checklist.md',
            'docs/context/engineering/git-workflow.md',
            'docs/context/engineering/implementation-status.md',
            'docs/context/engineering/verification-memory.md',
            'docs/context/governance/decisions-log.md',
            'docs/context/governance/session-log.md',
            'docs/codex/autonomy-modes.md',
            'docs/qa/prod-testing-policy.md',
            'docs/qa/prod-safe-test-matrix.md'
        )) {
        if ($contextProtocol -notmatch [regex]::Escape($requiredSource)) {
            throw "context-protocol.md must keep source-of-truth entry: $requiredSource"
        }
    }

    foreach ($requiredPhrase in @(
            'Old chat context is advisory only',
            'Repository docs and code are source of truth',
            'Use `git log --oneline --decorate -1` as the authoritative latest commit source',
            'Use `git status --short --branch` as the authoritative current branch/worktree source',
            'Do not record a literal latest pushed commit in `active-run.md`',
            'A new independent task or milestone in autonomous work requires a separate Codex thread',
            'Long-running autonomous permission extends time, not task/thread scope',
            'Push or merge permission does not waive the separate-thread requirement',
            'Choosing the next autonomous follow-up gate, hardening item or backlog item starts a new independent task',
            '`create_thread` is the priority mechanism for starting a new independent task',
            'record that attempt as inactive/orphan and retry `create_thread` once',
            'After the second normal `create_thread` failure, create the task thread with a Codex worktree',
            'After a new task thread is created, the previous task thread becomes inactive/history-only after handoff',
            'The previous task thread is preserved for history: it must not be deleted and is not archived automatically unless the user explicitly asks',
            'PROCESS_ERROR_THREAD_REUSE',
            'If execution mode is not declared, use `NON_AUTONOMOUS`',
            'If the current milestone plan is not recorded or not accepted, Codex must stop and ask before changing files'
        )) {
        if ($contextProtocol -notmatch [regex]::Escape($requiredPhrase)) {
            throw "context-protocol.md must preserve protocol phrase: $requiredPhrase"
        }
    }

    foreach ($requiredPhrase in @(
            '`main` is protected trunk',
            'Do not work directly on `main` for backlog tasks',
            'Every bounded goal uses a dedicated task branch',
            'Every new independent autonomous task or milestone uses a separate Codex thread',
            'Extended autonomous time, push permission or merge permission does not waive thread-per-task',
            'A newly selected follow-up gate, hardening item, feature slice or backlog item is a new independent task',
            'After a new task thread is created, the previous task thread becomes inactive/history-only after handoff',
            'The previous task thread is preserved for history: it must not be deleted and is not archived automatically unless the user explicitly asks',
            'Use `create_thread` first for new independent tasks',
            'retry `create_thread` once',
            'Codex worktree fallback after the second failure',
            'PROCESS_ERROR_THREAD_REUSE',
            'Fetch/pull before starting a task branch',
            'Do not let remote workflow replace local verification',
            'Do not mix unrelated changes',
            'Do not force-push to main',
            'Do not merge to main without explicit user approval',
            'Merge to main always requires NON_AUTONOMOUS explicit user approval',
            'Orchestrator commits after verification only when explicit user approval or an accepted project policy allows it'
        )) {
        if ($gitWorkflow -notmatch [regex]::Escape($requiredPhrase)) {
            throw "git-workflow.md must preserve workflow phrase: $requiredPhrase"
        }
    }

    Write-Host 'HandoffProtocolSafety gate passed.'
}

function Invoke-IncomingReferenceSafetyGate {
    $incomingRoot = Join-Path $repoRoot 'docs/_incoming_reference'
    $agentsPath = Join-Path $repoRoot 'AGENTS.md'
    $contextProtocolPath = Join-Path $repoRoot 'docs/context/handoff/context-protocol.md'
    Assert-PathExists 'docs/_incoming_reference'
    Assert-PathExists 'AGENTS.md'
    Assert-PathExists 'docs/context/handoff/context-protocol.md'

    $expectedReferences = @(
        'CODEX_GOAL_PROMPT_QA_AUTOMATION_MTC_FOG_PLAY.md',
        'CODEX_MULTIAGENT_GOAL_RULES_MTC_FOG_PLAY.md',
        'CODEX_QA_AUTOMATION_TZ_MTC_FOG_PLAY.md',
        'QUICK_START_CODEX_QA_MTC_FOG_PLAY.md',
        'TZ_WinClient_QA_Automation_Prod_Codex_v0.1.md'
    )
    $actualReferences = @(Get-ChildItem -LiteralPath $incomingRoot -File -Filter '*.md' | ForEach-Object { $_.Name } | Sort-Object)
    foreach ($reference in $expectedReferences) {
        if ($actualReferences -notcontains $reference) {
            throw "docs/_incoming_reference is missing expected reference file: $reference"
        }
    }
    foreach ($reference in $actualReferences) {
        if ($expectedReferences -notcontains $reference) {
            throw "docs/_incoming_reference contains undocumented reference file: $reference"
        }
    }

    $agents = Get-Content -LiteralPath $agentsPath -Raw
    $contextProtocol = Get-Content -LiteralPath $contextProtocolPath -Raw
    foreach ($requiredPhrase in @(
            'Old chat context is advisory only',
            'Repository docs and code are the source of truth',
            '`docs/_incoming_reference/` is historical/reference-only input; it is not active scope unless restated in repository docs, scripts or code'
        )) {
        if ($agents -notmatch [regex]::Escape($requiredPhrase)) {
            throw "AGENTS.md must preserve incoming-reference source-of-truth phrase: $requiredPhrase"
        }
    }
    foreach ($requiredPhrase in @(
            'Old chat context is advisory only',
            'Repository docs and code are source of truth',
            '`docs/_incoming_reference/` is historical/reference-only input and is not active scope unless restated in repository docs, scripts or code'
        )) {
        if ($contextProtocol -notmatch [regex]::Escape($requiredPhrase)) {
            throw "context-protocol.md must preserve incoming-reference source-of-truth phrase: $requiredPhrase"
        }
    }

    Write-Host 'IncomingReferenceSafety gate passed.'
}

function Invoke-FrameworkInventorySafetyGate {
    $frameworkRoot = Join-Path $repoRoot 'src/TestFramework'
    Assert-PathExists 'src/TestFramework'

    $expectedModules = @(
        'BackendSmoke',
        'GameSessionCanary',
        'NonProdFoundation',
        'ProdSafety',
        'TestabilityGaps',
        'UpdateManifest',
        'WebViewBridge',
        'WindowsSmoke'
    )

    $actualModules = @(Get-ChildItem -LiteralPath $frameworkRoot -Directory | ForEach-Object { $_.Name } | Sort-Object)
    foreach ($moduleName in $expectedModules) {
        if ($actualModules -notcontains $moduleName) {
            throw "src/TestFramework must contain module directory: $moduleName"
        }
        Assert-PathExists "src/TestFramework/$moduleName/$moduleName.psm1"
        Assert-PathExists "src/TestFramework/$moduleName/$moduleName.Tests.ps1"
    }
    foreach ($moduleName in $actualModules) {
        if ($expectedModules -notcontains $moduleName) {
            throw "src/TestFramework contains undocumented module directory: $moduleName"
        }
    }

    $moduleContracts = @(
        @{ Module = 'BackendSmoke'; Runner = 'run-backend-smoke.ps1'; Doc = 'backend-smoke.md'; Fixtures = @('backend-smoke.example.json', 'backend-smoke-unsafe.example.json') },
        @{ Module = 'GameSessionCanary'; Runner = 'run-game-session-canary.ps1'; Doc = 'game-session-canary.md'; Fixtures = @('game-session-canary.example.json', 'game-session-canary-unsafe.example.json') },
        @{ Module = 'NonProdFoundation'; Runner = 'run-nonprod-foundation.ps1'; Doc = 'nonprod-foundation.md'; Fixtures = @('nonprod-foundation.example.json', 'nonprod-foundation-unsafe.example.json') },
        @{ Module = 'TestabilityGaps'; Runner = 'run-testability-gaps.ps1'; Doc = 'testability-gaps.md'; Fixtures = @('testability-gaps.example.json', 'testability-gaps-unsafe.example.json') },
        @{ Module = 'UpdateManifest'; Runner = 'run-update-manifest-gate.ps1'; Doc = 'update-manifest-gate.md'; Fixtures = @('update-manifest.example.json', 'update-manifest-unsafe.example.json') },
        @{ Module = 'WebViewBridge'; Runner = 'run-webview-bridge-contract.ps1'; Doc = 'webview-bridge-contract.md'; Fixtures = @('webview-bridge-contract.example.json', 'webview-bridge-contract-unsafe.example.json') },
        @{ Module = 'WindowsSmoke'; Runner = 'run-app-webview-smoke.ps1'; Doc = 'app-webview-smoke.md'; Fixtures = @('app-webview-smoke.example.json', 'app-webview-smoke-unsafe-policy.example.json') }
    )

    foreach ($contract in $moduleContracts) {
        Assert-PathExists "scripts/$($contract.Runner)"
        Assert-PathExists "docs/qa/$($contract.Doc)"
        foreach ($fixture in $contract.Fixtures) {
            Assert-PathExists "testdata/$fixture"
        }
    }

    foreach ($runner in @('run-prod-safe-smoke.ps1', 'run-prod-canary.ps1')) {
        Assert-PathExists "scripts/$runner"
    }
    foreach ($doc in @('prod-testing-policy.md', 'release-gates.md', 'privacy-and-logging-checks.md')) {
        Assert-PathExists "docs/qa/$doc"
    }
    foreach ($fixture in @('prod-safety-tests.example.json', 'release-gate-policy.example.json', 'privacy-patterns.example.json')) {
        Assert-PathExists "testdata/$fixture"
    }

    Write-Host 'FrameworkInventorySafety gate passed.'
}

function Invoke-TestFrameworkInventorySafetyGate {
    $frameworkRoot = Join-Path $repoRoot 'src/TestFramework'
    Assert-PathExists 'src/TestFramework'

    $expectedFiles = @(
        'BackendSmoke/BackendSmoke.psm1',
        'BackendSmoke/BackendSmoke.Tests.ps1',
        'GameSessionCanary/GameSessionCanary.psm1',
        'GameSessionCanary/GameSessionCanary.Tests.ps1',
        'NonProdFoundation/NonProdFoundation.psm1',
        'NonProdFoundation/NonProdFoundation.Tests.ps1',
        'ProdSafety/ProdSafety.psm1',
        'ProdSafety/ProdSafety.Tests.ps1',
        'ProdSafety/README.md',
        'TestabilityGaps/TestabilityGaps.psm1',
        'TestabilityGaps/TestabilityGaps.Tests.ps1',
        'UpdateManifest/UpdateManifest.psm1',
        'UpdateManifest/UpdateManifest.Tests.ps1',
        'WebViewBridge/WebViewBridge.psm1',
        'WebViewBridge/WebViewBridge.Tests.ps1',
        'WindowsSmoke/WindowsSmoke.psm1',
        'WindowsSmoke/WindowsSmoke.Tests.ps1'
    )
    $actualFiles = @(Get-ChildItem -LiteralPath $frameworkRoot -Recurse -File | ForEach-Object {
            $_.FullName.Substring($frameworkRoot.Length + 1) -replace '\\', '/'
        } | Sort-Object)
    foreach ($file in $expectedFiles) {
        if ($actualFiles -notcontains $file) {
            throw "src/TestFramework is missing required file: $file"
        }
    }
    foreach ($file in $actualFiles) {
        if ($expectedFiles -notcontains $file) {
            throw "src/TestFramework contains undocumented file: $file"
        }
    }

    Write-Host 'TestFrameworkInventorySafety gate passed.'
}

function Invoke-IncidentStopSafetyGate {
    $policyPath = Join-Path $repoRoot 'docs/qa/incident-stop-policy.md'
    $activeRunPath = Join-Path $repoRoot 'docs/context/handoff/active-run.md'
    $testabilityGapsPath = Join-Path $repoRoot 'testdata/testability-gaps.example.json'
    Assert-PathExists 'docs/qa/incident-stop-policy.md'
    Assert-PathExists 'docs/context/handoff/active-run.md'
    Assert-PathExists 'testdata/testability-gaps.example.json'

    $policy = Get-Content -LiteralPath $policyPath -Raw
    $activeRun = Get-Content -LiteralPath $activeRunPath -Raw
    $gaps = Get-Content -LiteralPath $testabilityGapsPath -Raw | ConvertFrom-Json

    $requiredTriggers = @(
        'installed-client-launch',
        'webview-debug-cdp',
        'authentication',
        'synthetic-login',
        'production-backend-network',
        'streaming-network',
        'network-call',
        'game-session-execution',
        'runtime-user-data',
        'credentials',
        'production-impact',
        'replay-server-runtime',
        'network-shaping',
        'hardware-inspection',
        'update-rollback-execution',
        'cicd-enablement',
        'dependency-upgrade',
        'guard-weakening',
        'scope-expansion'
    )

    foreach ($trigger in $requiredTriggers) {
        if ($policy -notmatch "(?m)^-\s+$([regex]::Escape($trigger))\s*$") {
            throw "incident-stop-policy.md must list stop trigger: $trigger"
        }
    }

    foreach ($requiredPhrase in @(
            'do not launch the installed client',
            'do not enable WebView debug/CDP',
            'do not authenticate',
            'do not call production backend or streaming services',
            'do not start or stop a real game session',
            'do not read user AppData, logs, cookies, databases or dumps',
            'do not enable CI/CD or upgrade dependencies'
        )) {
        if ($policy -notmatch [regex]::Escape($requiredPhrase)) {
            throw "incident-stop-policy.md must document default handling phrase: $requiredPhrase"
        }
    }

    foreach ($activeRunPhrase in @(
            'installed client launch',
            'WebView debug/CDP',
            'authentication',
            'real game session',
            'production backend or streaming network interaction',
            'credentials, secrets',
            'reading user AppData',
            'CI/CD enablement',
            'dependency upgrades',
            'scope expansion beyond local dry-run/schema validation'
        )) {
        if ($activeRun -notmatch [regex]::Escape($activeRunPhrase)) {
            throw "active-run.md must preserve stop trigger phrase: $activeRunPhrase"
        }
    }

    if ($null -eq $gaps.gaps) {
        throw "testability-gaps.example.json must contain a top-level 'gaps' array."
    }
    foreach ($gap in @($gaps.gaps)) {
        $stopTriggers = @($gap.stopTriggers)
        if ($stopTriggers.Count -eq 0) {
            throw "Testability gap '$($gap.id)' must list at least one stop trigger."
        }
        foreach ($trigger in $stopTriggers) {
            if ($requiredTriggers -notcontains [string]$trigger) {
                throw "Testability gap '$($gap.id)' uses a stop trigger not listed in incident-stop-policy.md: $trigger"
            }
        }
    }

    Write-Host 'IncidentStopSafety gate passed.'
}

function Invoke-QaDocsSafetyGate {
    $docsRoot = Join-Path $repoRoot 'docs/qa'
    Assert-PathExists 'docs/qa'

    $requiredDocs = @(
        'app-webview-smoke.md',
        'artifacts-policy.md',
        'backend-smoke.md',
        'flakiness-policy.md',
        'game-session-canary.md',
        'incident-stop-policy.md',
        'nonprod-foundation.md',
        'privacy-and-logging-checks.md',
        'prod-safe-test-matrix.md',
        'prod-testing-policy.md',
        'release-gates.md',
        'resource-budget-policy.md',
        'synthetic-users-policy.md',
        'test-strategy.md',
        'testability-contract.md',
        'testability-gaps.md',
        'update-manifest-gate.md',
        'value-effort-backlog.md',
        'webview-bridge-contract.md'
    )

    foreach ($docName in $requiredDocs) {
        Assert-PathExists "docs/qa/$docName"
    }

    $safetyPhrasesByDoc = @{
        'test-strategy.md' = @('Do not start with broad E2E')
        'testability-contract.md' = @('Debug/CDP ports must never be enabled for normal production users by default')
        'artifacts-policy.md' = @('synthetic account alias, not password/token', 'Do not publish unsanitized logs')
        'flakiness-policy.md' = @('Blind retry is not a fix', 'Retry must not create extra production sessions outside budget')
        'incident-stop-policy.md' = @('Stop-and-ask triggers', 'do not launch the installed client')
        'prod-testing-policy.md' = @('No classification = no prod run', 'No resource budget = no prod game session test')
        'synthetic-users-policy.md' = @('hardcoded credentials', 'Committed allowlist fixtures must stay alias-only')
        'resource-budget-policy.md' = @('Any production test that starts a game session must have a resource budget')
        'prod-safe-test-matrix.md' = @('PROD_CONDITIONAL', 'PROD_FORBIDDEN')
        'game-session-canary.md' = @('This milestone does not execute a game session')
        'testability-gaps.md' = @('does not close gaps by launching the client')
        'release-gates.md' = @('This default is for a separate manual/explicit-plan artifact read only', 'Current autonomous verification must use committed local fixtures')
        'privacy-and-logging-checks.md' = @('This default is for a separate manual/explicit-plan artifact read only', 'Current autonomous verification must use committed local fixtures')
        'app-webview-smoke.md' = @('This default is for a separate manual/explicit-plan artifact read only', 'Current autonomous verification must use committed local fixtures')
    }

    foreach ($docName in $safetyPhrasesByDoc.Keys) {
        $path = Join-Path $docsRoot $docName
        $content = Get-Content -LiteralPath $path -Raw
        foreach ($phrase in $safetyPhrasesByDoc[$docName]) {
            if ($content -notmatch [regex]::Escape($phrase)) {
                throw "docs/qa/$docName must preserve safety phrase: $phrase"
            }
        }
    }

    $docs = Get-ChildItem -LiteralPath $docsRoot -Filter '*.md' -File | Sort-Object Name
    foreach ($doc in $docs) {
        if ($requiredDocs -notcontains $doc.Name) {
            throw "docs/qa contains an undocumented markdown policy file: $($doc.Name)"
        }
    }

    Write-Host 'QaDocsSafety gate passed.'
}

function Assert-JsonPatternIds {
    param(
        [Parameter(Mandatory = $true)]
        [object[]] $Patterns,

        [Parameter(Mandatory = $true)]
        [string[]] $RequiredIds,

        [Parameter(Mandatory = $true)]
        [string] $PolicyName
    )

    $ids = @($Patterns | ForEach-Object { [string]$_.id })
    foreach ($id in $RequiredIds) {
        if ($ids -notcontains $id) {
            throw "$PolicyName must contain pattern id: $id"
        }
    }
    foreach ($pattern in $Patterns) {
        if ([string]::IsNullOrWhiteSpace([string]$pattern.id)) {
            throw "$PolicyName contains a pattern without an id."
        }
        if ([string]::IsNullOrWhiteSpace([string]$pattern.pattern)) {
            throw "$PolicyName pattern '$($pattern.id)' must define a regex pattern."
        }
        if (@('fail', 'warn') -notcontains [string]$pattern.severity) {
            throw "$PolicyName pattern '$($pattern.id)' has unsupported severity '$($pattern.severity)'."
        }
    }
}

function Invoke-ArtifactPolicySafetyGate {
    $releasePolicyPath = Join-Path $repoRoot 'testdata/release-gate-policy.example.json'
    $releaseCleanPolicyPath = Join-Path $repoRoot 'testdata/release-gate-policy.clean-fixture.json'
    $privacyPatternsPath = Join-Path $repoRoot 'testdata/privacy-patterns.example.json'
    $privacySmallLimitPath = Join-Path $repoRoot 'testdata/privacy-patterns-small-limit.example.json'
    Assert-PathExists 'testdata/release-gate-policy.example.json'
    Assert-PathExists 'testdata/release-gate-policy.clean-fixture.json'
    Assert-PathExists 'testdata/privacy-patterns.example.json'
    Assert-PathExists 'testdata/privacy-patterns-small-limit.example.json'

    $releasePolicy = Get-Content -LiteralPath $releasePolicyPath -Raw | ConvertFrom-Json
    $releaseCleanPolicy = Get-Content -LiteralPath $releaseCleanPolicyPath -Raw | ConvertFrom-Json
    $privacyPolicy = Get-Content -LiteralPath $privacyPatternsPath -Raw | ConvertFrom-Json
    $privacySmallLimitPolicy = Get-Content -LiteralPath $privacySmallLimitPath -Raw | ConvertFrom-Json

    foreach ($requiredFile in @('bin/rds-client.exe', 'bin/rds-updater.exe', 'Uninstall.exe', 'bin/libcef.dll', 'bin/crashpad_handler.exe', 'bin/sentry.dll')) {
        if (@($releasePolicy.requiredFiles) -notcontains $requiredFile) {
            throw "release-gate-policy.example.json must require file: $requiredFile"
        }
        if (@($releaseCleanPolicy.requiredFiles) -notcontains $requiredFile) {
            throw "release-gate-policy.clean-fixture.json must require file: $requiredFile"
        }
    }

    foreach ($extension in @('.pdb', '.map')) {
        if (@($releasePolicy.forbiddenExtensions) -notcontains $extension) {
            throw "release-gate-policy.example.json must forbid extension: $extension"
        }
        if (@($releaseCleanPolicy.forbiddenExtensions) -notcontains $extension) {
            throw "release-gate-policy.clean-fixture.json must forbid extension: $extension"
        }
    }

    Assert-JsonPatternIds -Patterns @($releasePolicy.forbiddenTextPatterns) -RequiredIds @(
        'local-user-path',
        'source-map-reference',
        'unsafe-debug-flag'
    ) -PolicyName 'release-gate-policy.example.json'
    Assert-JsonPatternIds -Patterns @($releaseCleanPolicy.forbiddenTextPatterns) -RequiredIds @(
        'local-user-path',
        'source-map-reference',
        'unsafe-debug-flag'
    ) -PolicyName 'release-gate-policy.clean-fixture.json'

    $signatureRequired = @($releasePolicy.signatureChecks | Where-Object { $_.required -ne $true })
    if ($signatureRequired.Count -gt 0) {
        throw 'release-gate-policy.example.json must require configured signatures.'
    }
    $cleanSignatureRelaxed = @($releaseCleanPolicy.signatureChecks | Where-Object { $_.required -ne $false })
    if ($cleanSignatureRelaxed.Count -gt 0) {
        throw 'release-gate-policy.clean-fixture.json must keep signature checks relaxed for local clean fixtures.'
    }

    Assert-JsonPatternIds -Patterns @($privacyPolicy.patterns) -RequiredIds @(
        'access-token',
        'refresh-token',
        'password',
        'bearer-token',
        'generic-token',
        'api-key',
        'private-key',
        'local-user-path',
        'turn-credential'
    ) -PolicyName 'privacy-patterns.example.json'

    foreach ($extension in @('.txt', '.log', '.json', '.yaml', '.yml', '.ini', '.cfg', '.conf', '.xml', '.js', '.css', '.html', '.map')) {
        if (@($privacyPolicy.textFileExtensions) -notcontains $extension) {
            throw "privacy-patterns.example.json must scan extension: $extension"
        }
    }
    if ([int64]$privacyPolicy.maxTextFileBytes -lt 1 -or [int64]$privacyPolicy.maxTextFileBytes -gt 5242880) {
        throw 'privacy-patterns.example.json maxTextFileBytes must stay between 1 and 5242880.'
    }
    if (@($privacySmallLimitPolicy.patterns | ForEach-Object { [string]$_.id }) -notcontains 'access-token') {
        throw 'privacy-patterns-small-limit.example.json must keep access-token coverage.'
    }
    if ([int64]$privacySmallLimitPolicy.maxTextFileBytes -ge [int64]$privacyPolicy.maxTextFileBytes) {
        throw 'privacy-patterns-small-limit.example.json must keep a smaller scan limit than the default policy.'
    }

    Write-Host 'ArtifactPolicySafety gate passed.'
}

function Invoke-ContractFixtureSafetyGate {
    $backendPath = Join-Path $repoRoot 'testdata/backend-smoke.example.json'
    $updatePath = Join-Path $repoRoot 'testdata/update-manifest.example.json'
    $bridgePath = Join-Path $repoRoot 'testdata/webview-bridge-contract.example.json'
    Assert-PathExists 'testdata/backend-smoke.example.json'
    Assert-PathExists 'testdata/update-manifest.example.json'
    Assert-PathExists 'testdata/webview-bridge-contract.example.json'
    Assert-PathExists 'docs/qa/backend-smoke.md'
    Assert-PathExists 'docs/qa/update-manifest-gate.md'
    Assert-PathExists 'docs/qa/webview-bridge-contract.md'

    $backend = Get-Content -LiteralPath $backendPath -Raw | ConvertFrom-Json
    $update = Get-Content -LiteralPath $updatePath -Raw | ConvertFrom-Json
    $bridge = Get-Content -LiteralPath $bridgePath -Raw | ConvertFrom-Json

    if ($backend.dryRunOnly -ne $true -or $backend.networkDisabled -ne $true) {
        throw 'backend-smoke.example.json must stay dry-run only with network disabled.'
    }
    if (@($backend.headers).Count -ne 0) {
        throw 'backend-smoke.example.json must not define headers.'
    }
    if (@($backend.runtimePaths).Count -ne 0) {
        throw 'backend-smoke.example.json must not define runtime paths.'
    }
    foreach ($endpoint in @($backend.endpoints)) {
        if ($endpoint.method -ne 'GET') {
            throw "Backend endpoint '$($endpoint.name)' must stay GET-only."
        }
        if ($endpoint.classification -ne 'PROD_SAFE' -or $endpoint.requiresAuth -ne $false -or $endpoint.mutatesState -ne $false) {
            throw "Backend endpoint '$($endpoint.name)' must stay PROD_SAFE, auth-free and read-only."
        }
        if ([string]$endpoint.path -match '(?i)(userId|session|token|secret|password|auth|cookie)') {
            throw "Backend endpoint '$($endpoint.name)' path contains forbidden production/user-data terms."
        }
        if ($null -eq $endpoint.responseSchema -or $null -eq $endpoint.mockResponse) {
            throw "Backend endpoint '$($endpoint.name)' must define responseSchema and mockResponse."
        }
    }

    if ($update.dryRunOnly -ne $true -or $update.networkDisabled -ne $true -or $update.executionDisabled -ne $true -or $update.rollbackDisabled -ne $true -or $update.credentialsDisabled -ne $true) {
        throw 'update-manifest.example.json must keep dry-run/network/execution/rollback/credential safety flags enabled.'
    }
    if (@($update.endpoints).Count -ne 0 -or @($update.commands).Count -ne 0) {
        throw 'update-manifest.example.json must not define endpoints or commands.'
    }
    foreach ($package in @($update.packages)) {
        if ([string]$package.id -notmatch '^rds-[a-z0-9-]+$') {
            throw "Update package id must stay stable and local: $($package.id)"
        }
        if ([string]$package.version -notmatch '^\d+\.\d+\.\d+([-+][A-Za-z0-9.-]+)?$') {
            throw "Update package '$($package.id)' must use an explicit semantic-like version."
        }
        if ([string]$package.artifactPath -match '^(?i:https?://|[A-Za-z]:\\|\\\\)') {
            throw "Update package '$($package.id)' artifactPath must stay local relative."
        }
        if ([string]$package.sha256 -notmatch '^[a-f0-9]{64}$') {
            throw "Update package '$($package.id)' must define a 64-character SHA-256 hex digest."
        }
        if ([int64]$package.sizeBytes -lt 1) {
            throw "Update package '$($package.id)' must define positive sizeBytes."
        }
        if ($package.signatureRequired -ne $true -or $package.rollbackAllowed -ne $false -or -not [string]::IsNullOrWhiteSpace([string]$package.postInstallCommand)) {
            throw "Update package '$($package.id)' must require signature, disallow rollback and omit post-install commands."
        }
    }

    if ($bridge.dryRunOnly -ne $true -or @($bridge.diagnostics).Count -ne 0 -or @($bridge.runtimePaths).Count -ne 0) {
        throw 'webview-bridge-contract.example.json must stay dry-run only without diagnostics or runtime paths.'
    }
    foreach ($test in @($bridge.tests)) {
        if ($test.classification -ne 'PROD_SAFE' -or $test.startsGameSession -ne $false -or $test.mutatesState -ne $false -or $test.requiresCleanupVerification -ne $false) {
            throw "Bridge test '$($test.name)' must stay PROD_SAFE and non-runtime."
        }
    }
    $knownTargets = @()
    foreach ($command in @($bridge.commands)) {
        if ($command.direction -ne 'web -> native') {
            throw "Bridge command '$($command.name)' must keep direction 'web -> native'."
        }
        if ($command.productionSafety -notmatch 'PROD_SAFE local contract only' -or $command.loggingPolicy -notmatch 'no secrets') {
            throw "Bridge command '$($command.name)' must document local PROD_SAFE safety and sanitized logging."
        }
        if (@($command.payloadSchema.required) -notcontains 'requestId') {
            throw "Bridge command '$($command.name)' must require requestId."
        }
        $knownTargets += [string]$command.name
    }
    foreach ($event in @($bridge.events)) {
        if ($event.direction -ne 'native -> web') {
            throw "Bridge event '$($event.name)' must keep direction 'native -> web'."
        }
        if ($event.productionSafety -notmatch 'PROD_SAFE local contract only' -or $event.loggingPolicy -notmatch 'no secrets') {
            throw "Bridge event '$($event.name)' must document local PROD_SAFE safety and sanitized logging."
        }
        if (@($event.payloadSchema.required) -notcontains 'requestId') {
            throw "Bridge event '$($event.name)' must require requestId."
        }
        $knownTargets += [string]$event.name
    }
    foreach ($case in @($bridge.fakeNativeHostCases)) {
        if ($knownTargets -notcontains [string]$case.target) {
            throw "Bridge fake native host case '$($case.name)' targets unknown command/event '$($case.target)'."
        }
    }

    Write-Host 'ContractFixtureSafety gate passed.'
}

function Invoke-StaticSurfaceSafetyGate {
    $appPolicyPath = Join-Path $repoRoot 'testdata/app-webview-smoke.example.json'
    $nonProdPath = Join-Path $repoRoot 'testdata/nonprod-foundation.example.json'
    Assert-PathExists 'testdata/app-webview-smoke.example.json'
    Assert-PathExists 'testdata/nonprod-foundation.example.json'
    Assert-PathExists 'docs/qa/app-webview-smoke.md'
    Assert-PathExists 'docs/qa/nonprod-foundation.md'

    $appPolicy = Get-Content -LiteralPath $appPolicyPath -Raw | ConvertFrom-Json
    $nonProd = Get-Content -LiteralPath $nonProdPath -Raw | ConvertFrom-Json

    if ($appPolicy.dryRunOnly -ne $true) {
        throw 'app-webview-smoke.example.json must stay dry-run only.'
    }
    if (@($appPolicy.launchArguments).Count -ne 0) {
        throw 'app-webview-smoke.example.json must not define launch arguments.'
    }
    if (@($appPolicy.runtimePaths).Count -ne 0) {
        throw 'app-webview-smoke.example.json must not define runtime paths.'
    }
    foreach ($requiredFile in @('bin/rds-client.exe', 'bin/libcef.dll', 'bin/chrome_100_percent.pak', 'bin/resources.pak')) {
        if (@($appPolicy.requiredFiles) -notcontains $requiredFile) {
            throw "app-webview-smoke.example.json must require static artifact file: $requiredFile"
        }
    }
    $expectedBundles = @('settings', 'stream-settings', 'error-connect', 'update')
    $bundleNames = @($appPolicy.webViewBundles | ForEach-Object { [string]$_.name })
    foreach ($bundleName in $expectedBundles) {
        if ($bundleNames -notcontains $bundleName) {
            throw "app-webview-smoke.example.json must include WebView bundle: $bundleName"
        }
    }
    foreach ($bundle in @($appPolicy.webViewBundles)) {
        if ([string]$bundle.path -notmatch '^bin/resources/[a-z0-9-]+$') {
            throw "WebView bundle '$($bundle.name)' must use a local bin/resources path."
        }
        foreach ($file in @('index.html', 'asset-manifest.json')) {
            if (@($bundle.requiredFiles) -notcontains $file) {
                throw "WebView bundle '$($bundle.name)' must require file: $file"
            }
        }
        foreach ($key in @('main.css', 'main.js', 'index.html')) {
            if (@($bundle.requiredManifestKeys) -notcontains $key) {
                throw "WebView bundle '$($bundle.name)' must require manifest key: $key"
            }
        }
    }

    foreach ($flag in @('dryRunOnly', 'executionDisabled', 'clientLaunchDisabled', 'webViewDebugDisabled', 'networkCallsDisabled', 'authDisabled', 'runtimeDataReadsDisabled', 'ciCdDisabled')) {
        $property = $nonProd.PSObject.Properties[$flag]
        if ($null -eq $property -or $property.Value -ne $true) {
            throw "nonprod-foundation.example.json must keep $flag=true."
        }
    }
    if (@($nonProd.runtimePaths).Count -ne 0 -or @($nonProd.productionEndpoints).Count -ne 0) {
        throw 'nonprod-foundation.example.json must not define runtime paths or production endpoints.'
    }
    $expectedTypes = @('fake-backend', 'fake-signaling', 'replay-server', 'network-shaper', 'hardware-matrix', 'update-rollback-lab')
    $componentTypes = @($nonProd.components | ForEach-Object { [string]$_.type })
    foreach ($type in $expectedTypes) {
        if ($componentTypes -notcontains $type) {
            throw "nonprod-foundation.example.json must include component type: $type"
        }
    }
    foreach ($component in @($nonProd.components)) {
        if ([string]$component.name -notmatch '^[a-z0-9]+[a-z0-9-]*$') {
            throw "Non-prod component name must be stable lowercase id: $($component.name)"
        }
        if ($component.classification -ne 'NON_PROD_ONLY' -or $component.schemaOnly -ne $true -or $component.executionEnabled -ne $false -or $component.usesProduction -ne $false -or $component.requiresCredentials -ne $false -or $component.mutatesState -ne $false -or $component.startsGameSession -ne $false) {
            throw "Non-prod component '$($component.name)' must stay schema-only, NON_PROD_ONLY and non-runtime."
        }
        if (@($component.forbiddenReferences).Count -ne 0) {
            throw "Non-prod component '$($component.name)' must not define forbiddenReferences."
        }
        if ($null -eq $component.contractSchema -or $component.contractSchema.type -ne 'object' -or @($component.contractSchema.required).Count -eq 0) {
            throw "Non-prod component '$($component.name)' must define an object contractSchema with required fields."
        }
    }

    Write-Host 'StaticSurfaceSafety gate passed.'
}

function Invoke-WebViewBundleLocalReferenceSafetyGate {
    $policyPath = Join-Path $repoRoot 'testdata/app-webview-smoke.example.json'
    $resourcesRoot = Join-Path $repoRoot 'testdata/app-webview-smoke-fixture/bin/resources'
    Assert-PathExists 'testdata/app-webview-smoke.example.json'
    Assert-PathExists 'testdata/app-webview-smoke-fixture/bin/resources'

    $policy = Get-Content -LiteralPath $policyPath -Raw | ConvertFrom-Json
    $expectedBundles = @('settings', 'stream-settings', 'error-connect', 'update')
    $bundleNames = @($policy.webViewBundles | ForEach-Object { [string]$_.name })
    foreach ($bundleName in $expectedBundles) {
        if ($bundleNames -notcontains $bundleName) {
            throw "app-webview-smoke.example.json must include WebView bundle: $bundleName"
        }
    }

    $forbiddenReferencePatterns = @(
        @{ Id = 'remote-url'; Pattern = '(?i)\b(?:https?|wss?)://' },
        @{ Id = 'localhost'; Pattern = '(?i)\b(?:localhost|127\.0\.0\.1|0\.0\.0\.0|\[?::1\]?)\b' },
        @{ Id = 'webview-debug'; Pattern = '(?i)(remote-debugging|debug-port|webview-debug|devtools|chrome-devtools|cdp\b)' },
        @{ Id = 'runtime-user-path'; Pattern = '(?i)(AppData|C:\\Users\\|\\Users\\|/Users/|Cookies|Local Storage|IndexedDB|\.db\b|\\logs\\|/logs/)' },
        @{ Id = 'production-endpoint'; Pattern = '(?i)\b(?:api|prod|production|stream|signaling)[-.][A-Za-z0-9.-]+\.(?:ru|com|net|org)\b' }
    )

    foreach ($bundle in @($policy.webViewBundles)) {
        $bundleName = [string]$bundle.name
        $bundlePath = [string]$bundle.path
        if ($expectedBundles -notcontains $bundleName) {
            throw "Unexpected WebView bundle in app-webview-smoke.example.json: $bundleName"
        }
        if ($bundlePath -ne "bin/resources/$bundleName") {
            throw "WebView bundle '$bundleName' must use local fixture path bin/resources/$bundleName."
        }
        foreach ($pattern in $forbiddenReferencePatterns) {
            if ($bundlePath -match $pattern.Pattern) {
                throw "WebView bundle '$bundleName' policy path contains forbidden reference: $($pattern.Id)"
            }
        }
    }

    $bundleDirs = @(Get-ChildItem -LiteralPath $resourcesRoot -Directory | Sort-Object Name)
    $actualBundleNames = @($bundleDirs | ForEach-Object { $_.Name })
    foreach ($bundleName in $expectedBundles) {
        if ($actualBundleNames -notcontains $bundleName) {
            throw "Fixture resources are missing WebView bundle directory: $bundleName"
        }
    }
    foreach ($bundleName in $actualBundleNames) {
        if ($expectedBundles -notcontains $bundleName) {
            throw "Fixture resources contain undocumented WebView bundle directory: $bundleName"
        }
    }

    foreach ($bundleDir in $bundleDirs) {
        foreach ($fileName in @('index.html', 'asset-manifest.json')) {
            $bundleFile = Join-Path $bundleDir.FullName $fileName
            if (-not (Test-Path -LiteralPath $bundleFile -PathType Leaf)) {
                throw "WebView bundle '$($bundleDir.Name)' is missing $fileName."
            }
            $relative = $bundleFile.Substring($repoRoot.Length + 1) -replace '\\', '/'
            $text = Get-Content -LiteralPath $bundleFile -Raw
            foreach ($pattern in $forbiddenReferencePatterns) {
                if ($text -match $pattern.Pattern) {
                    throw "$relative contains forbidden WebView bundle reference: $($pattern.Id)"
                }
            }
        }

        $manifestPath = Join-Path $bundleDir.FullName 'asset-manifest.json'
        $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
        if ($null -eq $manifest.files) {
            throw "WebView bundle '$($bundleDir.Name)' asset-manifest.json must contain files mapping."
        }
        foreach ($key in @('main.css', 'main.js', 'index.html')) {
            $property = $manifest.files.PSObject.Properties[$key]
            if ($null -eq $property) {
                throw "WebView bundle '$($bundleDir.Name)' asset-manifest.json is missing files.$key."
            }
            $value = [string]$property.Value
            if ($value -match '^\s*$' -or $value -match '(?i)^[a-z][a-z0-9+.-]*:' -or $value -match '\\|//|\.\.' -or $value -notmatch '^/') {
                throw "WebView bundle '$($bundleDir.Name)' manifest path for $key must be a root-relative local static path."
            }
            if ($key -eq 'index.html') {
                if ($value -ne '/index.html') {
                    throw "WebView bundle '$($bundleDir.Name)' manifest path for index.html must stay /index.html."
                }
            }
            elseif ($key -eq 'main.css') {
                if ($value -notmatch '^/static/css/[A-Za-z0-9][A-Za-z0-9._/-]*\.css$') {
                    throw "WebView bundle '$($bundleDir.Name)' manifest path for main.css must stay under /static/css/."
                }
            }
            elseif ($key -eq 'main.js') {
                if ($value -notmatch '^/static/js/[A-Za-z0-9][A-Za-z0-9._/-]*\.js$') {
                    throw "WebView bundle '$($bundleDir.Name)' manifest path for main.js must stay under /static/js/."
                }
            }
        }
    }

    Write-Host 'WebViewBundleLocalReferenceSafety gate passed.'
}

function Invoke-FixtureInventorySafetyGate {
    foreach ($fixtureRoot in @(
            'testdata/release-fixture',
            'testdata/release-clean-fixture',
            'testdata/privacy-negative-fixture',
            'testdata/privacy-large-fixture',
            'testdata/privacy-clean-fixture',
            'testdata/app-webview-smoke-fixture'
        )) {
        Assert-PathExists $fixtureRoot
    }

    foreach ($requiredFile in @(
            'testdata/release-fixture/bin/rds-client.exe',
            'testdata/release-fixture/bin/rds-updater.exe',
            'testdata/release-fixture/bin/libcef.dll',
            'testdata/release-fixture/bin/crashpad_handler.exe',
            'testdata/release-fixture/bin/sentry.dll',
            'testdata/release-fixture/Uninstall.exe',
            'testdata/release-fixture/bin/installer_info.txt',
            'testdata/release-fixture/bin/resources/settings/static/js/main.fixture.js',
            'testdata/release-fixture/bin/resources/settings/static/js/main.fixture.js.map'
        )) {
        Assert-PathExists $requiredFile
    }

    foreach ($requiredFile in @(
            'testdata/release-clean-fixture/bin/rds-client.exe',
            'testdata/release-clean-fixture/bin/rds-updater.exe',
            'testdata/release-clean-fixture/bin/libcef.dll',
            'testdata/release-clean-fixture/bin/crashpad_handler.exe',
            'testdata/release-clean-fixture/bin/sentry.dll',
            'testdata/release-clean-fixture/Uninstall.exe'
        )) {
        Assert-PathExists $requiredFile
    }

    $releaseCleanRoot = Join-Path $repoRoot 'testdata/release-clean-fixture'
    $releaseCleanForbidden = @(Get-ChildItem -LiteralPath $releaseCleanRoot -Recurse -File | Where-Object {
            $_.Extension.ToLowerInvariant() -in @('.map', '.pdb') -or $_.Name -eq 'installer_info.txt'
        })
    if ($releaseCleanForbidden.Count -gt 0) {
        throw 'release-clean-fixture must not contain sourcemaps, PDBs or installer_info.txt.'
    }

    foreach ($requiredFile in @(
            'testdata/privacy-negative-fixture/app.log',
            'testdata/privacy-large-fixture/large.log',
            'testdata/privacy-clean-fixture/app.log'
        )) {
        Assert-PathExists $requiredFile
    }

    $largePrivacyFile = Get-Item -LiteralPath (Join-Path $repoRoot 'testdata/privacy-large-fixture/large.log')
    $privacySmallLimitPath = Join-Path $repoRoot 'testdata/privacy-patterns-small-limit.example.json'
    $privacySmallLimitPolicy = Get-Content -LiteralPath $privacySmallLimitPath -Raw | ConvertFrom-Json
    if ($largePrivacyFile.Length -le [int64]$privacySmallLimitPolicy.maxTextFileBytes) {
        throw 'privacy-large-fixture/large.log must remain larger than the small-limit privacy policy.'
    }
    $largePrivacyText = Get-Content -LiteralPath $largePrivacyFile.FullName -Raw
    if ($largePrivacyText -notmatch '(?i)access[_-]?token') {
        throw 'privacy-large-fixture/large.log must keep token-like fixture content for scan-limit coverage.'
    }

    $cleanPrivacyText = Get-Content -LiteralPath (Join-Path $repoRoot 'testdata/privacy-clean-fixture/app.log') -Raw
    if ($cleanPrivacyText -match '(?i)(token|password|secret|C:\\Users\\|AppData)') {
        throw 'privacy-clean-fixture/app.log must remain sanitized.'
    }

    foreach ($requiredFile in @(
            'testdata/app-webview-smoke-fixture/bin/rds-client.exe',
            'testdata/app-webview-smoke-fixture/bin/libcef.dll',
            'testdata/app-webview-smoke-fixture/bin/chrome_100_percent.pak',
            'testdata/app-webview-smoke-fixture/bin/resources.pak'
        )) {
        Assert-PathExists $requiredFile
    }

    foreach ($bundleName in @('settings', 'stream-settings', 'error-connect', 'update')) {
        foreach ($requiredFile in @('index.html', 'asset-manifest.json')) {
            Assert-PathExists "testdata/app-webview-smoke-fixture/bin/resources/$bundleName/$requiredFile"
        }
    }

    Write-Host 'FixtureInventorySafety gate passed.'
}

function Invoke-ScriptsInventorySafetyGate {
    $scriptRoot = Join-Path $repoRoot 'scripts'
    Assert-PathExists 'scripts'

    $expectedFiles = @(
        'quality-gate.ps1',
        'README.md',
        'run-app-webview-smoke.ps1',
        'run-backend-smoke.ps1',
        'run-game-session-canary.ps1',
        'run-nonprod-foundation.ps1',
        'run-privacy-gate.ps1',
        'run-prod-canary.ps1',
        'run-prod-safe-smoke.ps1',
        'run-release-gate.ps1',
        'run-testability-gaps.ps1',
        'run-update-manifest-gate.ps1',
        'run-webview-bridge-contract.ps1'
    )
    $actualFiles = @(Get-ChildItem -LiteralPath $scriptRoot -File | ForEach-Object { $_.Name } | Sort-Object)
    foreach ($file in $expectedFiles) {
        if ($actualFiles -notcontains $file) {
            throw "scripts is missing required file: $file"
        }
    }
    foreach ($file in $actualFiles) {
        if ($expectedFiles -notcontains $file) {
            throw "scripts contains undocumented file: $file"
        }
    }

    Write-Host 'ScriptsInventorySafety gate passed.'
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
    $unsafeInputPathVocabulary = @(
        'AppData',
        'Cookies',
        'cookie',
        '\.log',
        'logs',
        'crash',
        'dump',
        'Local Storage',
        'IndexedDB',
        '\.db'
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

        $runnerParamText = ($text -split 'Set-StrictMode', 2)[0]
        $pathParameterMatches = [regex]::Matches($runnerParamText, '\[string\]\s+\$(?<name>[A-Za-z0-9]*(?:Path|Root))')
        $pathParameterNames = @($pathParameterMatches | ForEach-Object { $_.Groups['name'].Value } | Sort-Object -Unique)
        if ($pathParameterNames.Count -gt 0) {
            foreach ($requiredToken in $unsafeInputPathVocabulary) {
                if ($text -notmatch [regex]::Escape($requiredToken)) {
                    throw "$relative exposes path-like parameters but does not preserve unsafe input path guard token: $requiredToken"
                }
            }

            foreach ($parameterName in $pathParameterNames) {
                $inlineGuardPattern = '\$' + [regex]::Escape($parameterName) + '\s+-match\s+[''"].*AppData'
                $helperGuardPattern = 'InputPathSafe\s+-Name\s+''' + [regex]::Escape($parameterName) + '''\s+-Path\s+\$' + [regex]::Escape($parameterName)
                if ($text -notmatch $inlineGuardPattern -and $text -notmatch $helperGuardPattern) {
                    throw "$relative exposes `$$parameterName but does not guard it against unsafe runtime input paths."
                }
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

function Invoke-TestDataInventorySafetyGate {
    $testDataRoot = Join-Path $repoRoot 'testdata'
    Assert-PathExists 'testdata'

    $expectedFiles = @(
        'allowed-games.example.json',
        'app-webview-smoke.example.json',
        'app-webview-smoke-fixture/bin/chrome_100_percent.pak',
        'app-webview-smoke-fixture/bin/libcef.dll',
        'app-webview-smoke-fixture/bin/rds-client.exe',
        'app-webview-smoke-fixture/bin/resources.pak',
        'app-webview-smoke-fixture/bin/resources/error-connect/asset-manifest.json',
        'app-webview-smoke-fixture/bin/resources/error-connect/index.html',
        'app-webview-smoke-fixture/bin/resources/settings/asset-manifest.json',
        'app-webview-smoke-fixture/bin/resources/settings/index.html',
        'app-webview-smoke-fixture/bin/resources/stream-settings/asset-manifest.json',
        'app-webview-smoke-fixture/bin/resources/stream-settings/index.html',
        'app-webview-smoke-fixture/bin/resources/update/asset-manifest.json',
        'app-webview-smoke-fixture/bin/resources/update/index.html',
        'app-webview-smoke-unsafe-policy.example.json',
        'backend-smoke.example.json',
        'backend-smoke-unsafe.example.json',
        'game-session-canary.example.json',
        'game-session-canary-unsafe.example.json',
        'nonprod-foundation.example.json',
        'nonprod-foundation-unsafe.example.json',
        'privacy-clean-fixture/app.log',
        'privacy-large-fixture/large.log',
        'privacy-negative-fixture/app.log',
        'privacy-patterns.example.json',
        'privacy-patterns-small-limit.example.json',
        'prod-resource-budget.example.yaml',
        'prod-safety-tests.example.json',
        'release-clean-fixture/Uninstall.exe',
        'release-clean-fixture/bin/crashpad_handler.exe',
        'release-clean-fixture/bin/libcef.dll',
        'release-clean-fixture/bin/rds-client.exe',
        'release-clean-fixture/bin/rds-updater.exe',
        'release-clean-fixture/bin/sentry.dll',
        'release-fixture/Uninstall.exe',
        'release-fixture/Uninstall.exe.fixture',
        'release-fixture/bin/crashpad_handler.exe',
        'release-fixture/bin/crashpad_handler.exe.fixture',
        'release-fixture/bin/installer_info.txt',
        'release-fixture/bin/libcef.dll',
        'release-fixture/bin/libcef.dll.fixture',
        'release-fixture/bin/rds-client.exe',
        'release-fixture/bin/rds-client.exe.fixture',
        'release-fixture/bin/rds-updater.exe',
        'release-fixture/bin/rds-updater.exe.fixture',
        'release-fixture/bin/resources/settings/static/js/main.fixture.js',
        'release-fixture/bin/resources/settings/static/js/main.fixture.js.map',
        'release-fixture/bin/sentry.dll',
        'release-fixture/bin/sentry.dll.fixture',
        'release-gate-policy.clean-fixture.json',
        'release-gate-policy.example.json',
        'synthetic-users.example.json',
        'testability-gaps.example.json',
        'testability-gaps-unsafe.example.json',
        'update-manifest.example.json',
        'update-manifest-unsafe.example.json',
        'webview-bridge-contract.example.json',
        'webview-bridge-contract-unsafe.example.json'
    )
    $actualFiles = @(Get-ChildItem -LiteralPath $testDataRoot -Recurse -File | ForEach-Object {
            $_.FullName.Substring($testDataRoot.Length + 1) -replace '\\', '/'
        } | Sort-Object)
    foreach ($file in $expectedFiles) {
        if ($actualFiles -notcontains $file) {
            throw "testdata is missing required fixture file: $file"
        }
    }
    foreach ($file in $actualFiles) {
        if ($expectedFiles -notcontains $file) {
            throw "testdata contains undocumented fixture file: $file"
        }
    }

    Write-Host 'TestDataInventorySafety gate passed.'
}

function Invoke-UnsafeFixtureCoverageSafetyGate {
    $testDataRoot = Join-Path $repoRoot 'testdata'
    Assert-PathExists 'testdata'

    $expectedCoverage = @(
        @{
            Fixture = 'app-webview-smoke-unsafe-policy.example.json'
            CoverageFiles = @('src/TestFramework/WindowsSmoke/WindowsSmoke.Tests.ps1', 'scripts/quality-gate.ps1')
            FindingIds = @('policy-not-dry-run-only', 'unsafe-launch-argument', 'unsafe-runtime-path')
        },
        @{
            Fixture = 'backend-smoke-unsafe.example.json'
            CoverageFiles = @('src/TestFramework/BackendSmoke/BackendSmoke.Tests.ps1', 'scripts/quality-gate.ps1')
            FindingIds = @('policy-not-dry-run-only', 'network-not-disabled', 'unsafe-header', 'unsafe-runtime-path', 'state-mutating-endpoint')
        },
        @{
            Fixture = 'game-session-canary-unsafe.example.json'
            CoverageFiles = @('src/TestFramework/GameSessionCanary/GameSessionCanary.Tests.ps1', 'scripts/quality-gate.ps1')
            FindingIds = @('policy-not-dry-run-only', 'execution-not-disabled', 'client-launch-not-disabled', 'network-not-disabled', 'auth-not-disabled', 'runtime-paths-not-empty', 'unsafe-runtime-path', 'non-prod-conditional-canary', 'missing-canary-suite-metadata', 'canary-suite-metadata-not-exact', 'cleanup-not-required', 'synthetic-alias-not-canary', 'synthetic-alias-not-allowlisted', 'synthetic-alias-not-production-allowed', 'duration-exceeds-budget', 'duration-exceeds-synthetic-user-budget', 'game-not-in-budget', 'game-not-allowlisted', 'uncontrolled-retries', 'missing-readiness-signals', 'readiness-signals-not-exact')
        },
        @{
            Fixture = 'nonprod-foundation-unsafe.example.json'
            CoverageFiles = @('src/TestFramework/NonProdFoundation/NonProdFoundation.Tests.ps1', 'scripts/quality-gate.ps1')
            FindingIds = @('policy-not-dry-run-only', 'execution-not-disabled', 'network-not-disabled', 'client-launch-not-disabled', 'webview-debug-not-disabled', 'auth-not-disabled', 'runtime-data-read-not-disabled', 'cicd-not-disabled', 'unsafe-runtime-path', 'production-endpoint-defined', 'non-nonprod-classification', 'component-not-schema-only', 'component-execution-enabled', 'component-uses-production', 'component-requires-credentials', 'component-mutates-state', 'component-starts-game-session', 'missing-contract-schema', 'unsafe-component-reference')
        },
        @{
            Fixture = 'testability-gaps-unsafe.example.json'
            CoverageFiles = @('src/TestFramework/TestabilityGaps/TestabilityGaps.Tests.ps1', 'scripts/quality-gate.ps1')
            FindingIds = @('policy-not-dry-run-only', 'production-execution-not-disabled', 'runtime-data-read-not-disabled', 'credentials-not-disabled', 'invalid-gap-id', 'invalid-area', 'invalid-status', 'gap-marked-production-safe', 'gap-requires-credentials', 'gap-requires-user-data', 'invalid-required-evidence', 'missing-stop-trigger', 'missing-next-safe-step')
        },
        @{
            Fixture = 'update-manifest-unsafe.example.json'
            CoverageFiles = @('src/TestFramework/UpdateManifest/UpdateManifest.Tests.ps1', 'scripts/quality-gate.ps1')
            FindingIds = @('policy-not-dry-run-only', 'network-not-disabled', 'execution-not-disabled', 'rollback-not-disabled', 'credentials-not-disabled', 'unsafe-endpoint', 'command-defined', 'invalid-version', 'unsafe-artifact-path', 'invalid-sha256', 'invalid-size', 'signature-not-required', 'rollback-allowed', 'post-install-command-defined')
        },
        @{
            Fixture = 'webview-bridge-contract-unsafe.example.json'
            CoverageFiles = @('src/TestFramework/WebViewBridge/WebViewBridge.Tests.ps1', 'scripts/quality-gate.ps1')
            FindingIds = @('policy-not-dry-run-only', 'unsafe-diagnostic', 'unsafe-runtime-path')
        }
    )

    $actualFixtures = @(Get-ChildItem -LiteralPath $testDataRoot -Filter '*unsafe*.example.json' -File | ForEach-Object { $_.Name } | Sort-Object)
    $expectedFixtures = @($expectedCoverage | ForEach-Object { $_.Fixture } | Sort-Object)

    foreach ($fixture in $expectedFixtures) {
        if ($actualFixtures -notcontains $fixture) {
            throw "UnsafeFixtureCoverageSafety expected unsafe fixture is missing from testdata: $fixture"
        }
    }
    foreach ($fixture in $actualFixtures) {
        if ($expectedFixtures -notcontains $fixture) {
            throw "UnsafeFixtureCoverageSafety found unsafe fixture without static negative coverage contract: $fixture"
        }
    }

    foreach ($coverage in $expectedCoverage) {
        $fixturePath = "testdata/$($coverage.Fixture)"
        $pathCovered = $false
        $assertionCoverage = @{}
        foreach ($findingId in $coverage.FindingIds) {
            $assertionCoverage[$findingId] = $false
        }

        foreach ($coverageFile in $coverage.CoverageFiles) {
            Assert-PathExists $coverageFile
            $fullCoveragePath = Join-Path $repoRoot $coverageFile
            $content = Get-Content -LiteralPath $fullCoveragePath -Raw
            $normalizedContent = $content -replace '\\', '/'
            $fixtureIndex = $normalizedContent.IndexOf($fixturePath, [System.StringComparison]::OrdinalIgnoreCase)
            if ($fixtureIndex -lt 0) {
                continue
            }

            $pathCovered = $true
            $scanLength = [Math]::Min(8000, $normalizedContent.Length - $fixtureIndex)
            $fixtureScope = $normalizedContent.Substring($fixtureIndex, $scanLength)

            foreach ($findingId in $coverage.FindingIds) {
                $assertPattern = "Assert-FindingId\s+-Result\s+\S+\s+-Id\s+'$([regex]::Escape($findingId))'"
                if ($fixtureScope -match $assertPattern) {
                    $assertionCoverage[$findingId] = $true
                }
            }
        }

        if (-not $pathCovered) {
            throw "UnsafeFixtureCoverageSafety requires fixture path mention in coverage files: $fixturePath"
        }

        foreach ($findingId in $coverage.FindingIds) {
            if (-not $assertionCoverage[$findingId]) {
                throw "UnsafeFixtureCoverageSafety requires finding-id assertion for ${fixturePath}: $findingId"
            }
        }
    }

    Write-Host 'UnsafeFixtureCoverageSafety gate passed.'
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
    $budgetPath = Join-Path $repoRoot 'testdata/prod-resource-budget.example.yaml'
    $prodSafetyModule = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
    Assert-PathExists 'docs/qa/synthetic-users-policy.md'
    Assert-PathExists 'testdata/synthetic-users.example.json'
    Assert-PathExists 'testdata/prod-resource-budget.example.yaml'
    Assert-PathExists 'src/TestFramework/ProdSafety/ProdSafety.psm1'

    $policy = Get-Content -LiteralPath $policyPath -Raw
    foreach ($requiredPolicyPhrase in @('allowlisted synthetic accounts', 'hardcoded credentials', 'tokens/passwords', 'resource budget')) {
        if ($policy -notmatch [regex]::Escape($requiredPolicyPhrase)) {
            throw "Synthetic users policy must document: $requiredPolicyPhrase"
        }
    }

    Import-Module $prodSafetyModule -Force
    $budget = Read-ProdResourceBudget -Path $budgetPath
    $budgetMaxSessionDurationSeconds = [int]$budget.maxSessionDurationSeconds

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
            if ($maxSessionDurationSeconds -gt $budgetMaxSessionDurationSeconds) {
                throw "Synthetic user '$alias' game-session duration must not exceed prodResourceBudget.maxSessionDurationSeconds."
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
    $syntheticUsersPath = Join-Path $repoRoot 'testdata/synthetic-users.example.json'
    $budgetPath = Join-Path $repoRoot 'testdata/prod-resource-budget.example.yaml'
    $allowedGamesPath = Join-Path $repoRoot 'testdata/allowed-games.example.json'
    $prodSafetyModule = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
    Assert-PathExists 'docs/qa/prod-testing-policy.md'
    Assert-PathExists 'testdata/prod-safety-tests.example.json'
    Assert-PathExists 'testdata/synthetic-users.example.json'
    Assert-PathExists 'testdata/prod-resource-budget.example.yaml'
    Assert-PathExists 'testdata/allowed-games.example.json'
    Assert-PathExists 'src/TestFramework/ProdSafety/ProdSafety.psm1'

    $policy = Get-Content -LiteralPath $policyPath -Raw
    foreach ($requiredPolicyPhrase in @('Every test must be classified', 'No classification = no prod run', 'No resource budget = no prod game session test', 'bounded game-session permission within the committed resource budget', 'target region and target game metadata must stay allowlisted')) {
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
    $budget = Read-ProdResourceBudget -Path $budgetPath
    $budgetMaxSessionDurationSeconds = [int]$budget.maxSessionDurationSeconds
    $budgetRegions = @($budget.allowedRegions)
    $budgetGames = @($budget.allowedGames)
    $syntheticUsersData = Get-Content -LiteralPath $syntheticUsersPath -Raw | ConvertFrom-Json
    if ($null -eq $syntheticUsersData.syntheticUsers) {
        throw "Synthetic users fixture must contain a top-level 'syntheticUsers' array."
    }
    $syntheticUsersByAlias = @{}
    foreach ($user in @($syntheticUsersData.syntheticUsers)) {
        $userAlias = [string]$user.alias
        if (-not [string]::IsNullOrWhiteSpace($userAlias)) {
            if ($syntheticUsersByAlias.ContainsKey($userAlias)) {
                throw "Synthetic user alias is duplicated: $userAlias"
            }
            $syntheticUsersByAlias[$userAlias] = $user
        }
    }
    $allowedGamesData = Get-Content -LiteralPath $allowedGamesPath -Raw | ConvertFrom-Json
    if ($null -eq $allowedGamesData.allowedGames) {
        throw "Allowed games fixture must contain a top-level 'allowedGames' array."
    }
    $productionCanaryGames = @($allowedGamesData.allowedGames | Where-Object {
            $_.environment -eq 'production' -and @($_.allowedFor) -contains 'prod_conditional_stream_canary'
        } | ForEach-Object { $_.alias })
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
            if (-not [string]::IsNullOrWhiteSpace($alias)) {
                if (-not $syntheticUsersByAlias.ContainsKey($alias)) {
                    throw "PROD_SAFE metadata test '$name' requires synthetic alias '$alias' that is not allowlisted in synthetic-users.example.json."
                }
                $syntheticUser = $syntheticUsersByAlias[$alias]
                if ([string]$syntheticUser.purpose -ne 'prod_safe_login_logout') {
                    throw "PROD_SAFE metadata test '$name' synthetic alias '$alias' must have purpose prod_safe_login_logout."
                }
                if ($syntheticUser.canStartGameSession -ne $false) {
                    throw "PROD_SAFE metadata test '$name' synthetic alias '$alias' must have canStartGameSession=false."
                }
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
            if (-not $syntheticUsersByAlias.ContainsKey($alias)) {
                throw "prod-canary suite test '$name' requires synthetic alias '$alias' that is not allowlisted in synthetic-users.example.json."
            }
            $syntheticUser = $syntheticUsersByAlias[$alias]
            if ([string]$syntheticUser.purpose -ne 'prod_conditional_stream_canary') {
                throw "prod-canary suite test '$name' synthetic alias '$alias' must have purpose prod_conditional_stream_canary."
            }
            if ($syntheticUser.canStartGameSession -ne $true) {
                throw "prod-canary suite test '$name' synthetic alias '$alias' must have canStartGameSession=true."
            }
            $syntheticUserMaxSessionDurationSeconds = [int]$syntheticUser.maxSessionDurationSeconds
            if ($syntheticUserMaxSessionDurationSeconds -lt 1 -or $syntheticUserMaxSessionDurationSeconds -gt $budgetMaxSessionDurationSeconds) {
                throw "prod-canary suite test '$name' synthetic alias '$alias' maxSessionDurationSeconds must fit prodResourceBudget.maxSessionDurationSeconds."
            }
            if ([string]::IsNullOrWhiteSpace($targetRegion) -or [string]::IsNullOrWhiteSpace($targetGame)) {
                throw "prod-canary suite test '$name' must declare targetRegion and targetGame."
            }
            if ($budgetRegions -notcontains $targetRegion) {
                throw "prod-canary suite test '$name' targetRegion '$targetRegion' is not allowlisted in prodResourceBudget.allowedRegions."
            }
            if ($budgetGames -notcontains $targetGame) {
                throw "prod-canary suite test '$name' targetGame '$targetGame' is not allowlisted in prodResourceBudget.allowedGames."
            }
            if ($productionCanaryGames -notcontains $targetGame) {
                throw "prod-canary suite test '$name' targetGame '$targetGame' is not allowlisted as a production canary game."
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

    Assert-CommandRejected -Message 'Prod-safe smoke runner must reject unsafe runtime test metadata paths before reading them.' -Command {
        & $smokeScript `
            -Environment production `
            -TestMetadataPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\prod-safety-tests.json' `
            -SyntheticUsersPath (Join-Path $repoRoot 'testdata/synthetic-users.example.json') `
            -DryRun | Out-Null
    }
    Assert-CommandRejected -Message 'Prod-safe smoke runner must reject unsafe runtime synthetic user paths before reading them.' -Command {
        & $smokeScript `
            -Environment production `
            -TestMetadataPath (Join-Path $repoRoot 'testdata/prod-safety-tests.example.json') `
            -SyntheticUsersPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\synthetic-users.json' `
            -DryRun | Out-Null
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

    Assert-CommandRejected -Message 'Prod canary runner must reject unsafe runtime test metadata paths before reading them.' -Command {
        & $canaryScript `
            -Environment production `
            -TestMetadataPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\prod-safety-tests.json' `
            -SyntheticUsersPath (Join-Path $repoRoot 'testdata/synthetic-users.example.json') `
            -ResourceBudgetPath (Join-Path $repoRoot 'testdata/prod-resource-budget.example.yaml') `
            -DryRun | Out-Null
    }
    Assert-CommandRejected -Message 'Prod canary runner must reject unsafe runtime synthetic user paths before reading them.' -Command {
        & $canaryScript `
            -Environment production `
            -TestMetadataPath (Join-Path $repoRoot 'testdata/prod-safety-tests.example.json') `
            -SyntheticUsersPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\synthetic-users.json' `
            -ResourceBudgetPath (Join-Path $repoRoot 'testdata/prod-resource-budget.example.yaml') `
            -DryRun | Out-Null
    }
    Assert-CommandRejected -Message 'Prod canary runner must reject unsafe runtime resource budget paths before reading them.' -Command {
        & $canaryScript `
            -Environment production `
            -TestMetadataPath (Join-Path $repoRoot 'testdata/prod-safety-tests.example.json') `
            -SyntheticUsersPath (Join-Path $repoRoot 'testdata/synthetic-users.example.json') `
            -ResourceBudgetPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\prod-resource-budget.yaml' `
            -DryRun | Out-Null
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

    Assert-CommandRejected -Message 'Release gate runner must reject unsafe runtime policy paths before reading them.' -Command {
        & $releaseGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/release-fixture') `
            -PolicyPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\release-policy.json' `
            -DryRun | Out-Null
    }
    Assert-CommandRejected -Message 'Release gate runner must reject unsafe runtime artifact roots before probing them.' -Command {
        & $releaseGate `
            -ArtifactRoot 'C:\Users\someone\AppData\Local\MTC Fog Play\logs' `
            -PolicyPath (Join-Path $repoRoot 'testdata/release-gate-policy.example.json') `
            -DryRun | Out-Null
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

    Assert-CommandRejected -Message 'Update manifest runner must reject unsafe runtime input paths before reading them.' -Command {
        & $updateManifest `
            -PolicyPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\update.json' `
            -DryRun | Out-Null
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

    Assert-CommandRejected -Message 'Privacy gate runner must reject unsafe runtime patterns paths before reading them.' -Command {
        & $privacyGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/privacy-negative-fixture') `
            -PatternsPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\privacy-patterns.json' `
            -DryRun | Out-Null
    }
    Assert-CommandRejected -Message 'Privacy gate runner must reject unsafe runtime artifact roots before probing them.' -Command {
        & $privacyGate `
            -ArtifactRoot 'C:\Users\someone\AppData\Local\MTC Fog Play\logs' `
            -PatternsPath (Join-Path $repoRoot 'testdata/privacy-patterns.example.json') `
            -DryRun | Out-Null
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

    Assert-CommandRejected -Message 'App/WebView smoke runner must reject unsafe runtime policy paths before reading them.' -Command {
        & $appSmoke `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/app-webview-smoke-fixture') `
            -PolicyPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\app-smoke.json' `
            -DryRun | Out-Null
    }

    Assert-CommandRejected -Message 'App/WebView smoke runner must reject unsafe runtime artifact roots before probing them.' -Command {
        & $appSmoke `
            -ArtifactRoot 'C:\Users\someone\AppData\Local\MTC Fog Play\logs' `
            -PolicyPath (Join-Path $repoRoot 'testdata/app-webview-smoke.example.json') `
            -DryRun | Out-Null
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

    Assert-CommandRejected -Message 'WebView bridge contract runner must reject unsafe runtime input paths before reading them.' -Command {
        & $bridgeContract `
            -ContractPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\bridge.json' `
            -DryRun | Out-Null
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
    foreach ($flag in @('AllowNetwork', 'AllowAuth')) {
        Assert-CommandRejected -Message "Backend smoke runner must reject -$flag." -Command {
            $params = @{
                PolicyPath = (Join-Path $repoRoot 'testdata/backend-smoke.example.json')
                DryRun = $true
            }
            $params[$flag] = $true
            & $backendSmoke `
                @params | Out-Null
        }
    }

    Assert-CommandRejected -Message 'Backend smoke runner must reject unsafe runtime input paths before reading them.' -Command {
        & $backendSmoke `
            -PolicyPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\backend.json' `
            -DryRun | Out-Null
    }

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

    Assert-CommandRejected -Message 'Game-session canary runner must reject unsafe runtime input paths before reading them.' -Command {
        & $gameSessionCanary `
            -PlanPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\canary.json' `
            -DryRun `
            -AllowProdConditional `
            -CleanupVerified | Out-Null
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
    Assert-FindingId -Result $negative -Id 'runtime-paths-not-empty'
    Assert-FindingId -Result $negative -Id 'unsafe-runtime-path'
    Assert-FindingId -Result $negative -Id 'non-prod-conditional-canary'
    Assert-FindingId -Result $negative -Id 'missing-canary-suite-metadata'
    Assert-FindingId -Result $negative -Id 'canary-suite-metadata-not-exact'
    Assert-FindingId -Result $negative -Id 'cleanup-not-required'
    Assert-FindingId -Result $negative -Id 'synthetic-alias-not-canary'
    Assert-FindingId -Result $negative -Id 'synthetic-alias-not-allowlisted'
    Assert-FindingId -Result $negative -Id 'synthetic-alias-not-production-allowed'
    Assert-FindingId -Result $negative -Id 'duration-exceeds-budget'
    Assert-FindingId -Result $negative -Id 'duration-exceeds-synthetic-user-budget'
    Assert-FindingId -Result $negative -Id 'game-not-in-budget'
    Assert-FindingId -Result $negative -Id 'game-not-allowlisted'
    Assert-FindingId -Result $negative -Id 'uncontrolled-retries'
    Assert-FindingId -Result $negative -Id 'missing-readiness-signals'
    Assert-FindingId -Result $negative -Id 'readiness-signals-not-exact'

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

    Assert-CommandRejected -Message 'Non-prod foundation runner must reject unsafe runtime input paths before reading them.' -Command {
        & $nonProdFoundation `
            -PlanPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\nonprod.json' `
            -DryRun | Out-Null
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

    Assert-CommandRejected -Message 'Testability gaps runner must reject unsafe runtime input paths before reading them.' -Command {
        & $testabilityGaps `
            -PolicyPath 'C:\Users\someone\AppData\Local\MTC Fog Play\logs\gaps.json' `
            -DryRun | Out-Null
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

if ($Scope -in @('RepositoryRootInventorySafety', 'Full')) {
    Invoke-RepositoryRootInventorySafetyGate
}

if ($Scope -in @('RootPromptSafety', 'Full')) {
    Invoke-RootPromptSafetyGate
}

if ($Scope -in @('ProdSafetyFrameworkSafety', 'Full')) {
    Invoke-ProdSafetyFrameworkSafetyGate
}

if ($Scope -in @('ScriptEncodingSafety', 'Full')) {
    Invoke-ScriptEncodingSafetyGate
}

if ($Scope -in @('PowerShellStructuredSyntaxSafety', 'Full')) {
    Invoke-PowerShellStructuredSyntaxSafetyGate
}

if ($Scope -in @('BinaryFixturePlaceholderSafety', 'Full')) {
    Invoke-BinaryFixturePlaceholderSafetyGate
}

if ($Scope -in @('QaDocsCommandSafety', 'Full')) {
    Invoke-QaDocsCommandSafetyGate
}

if ($Scope -in @('QaDocsCommandLocalPathSafety', 'Full')) {
    Invoke-QaDocsCommandLocalPathSafetyGate
}

if ($Scope -in @('QaDocsPowerShellInvocationSafety', 'Full')) {
    Invoke-QaDocsPowerShellInvocationSafetyGate
}

if ($Scope -in @('QaDocsRunnerExampleCoverageSafety', 'Full')) {
    Invoke-QaDocsRunnerExampleCoverageSafetyGate
}

if ($Scope -in @('QualityGatesDocsScopeSafety', 'Full')) {
    Invoke-QualityGatesDocsScopeSafetyGate
}

if ($Scope -in @('ActiveSafetyScopeInventorySafety', 'Full')) {
    Invoke-ActiveSafetyScopeInventorySafetyGate
}

if ($Scope -in @('ScriptsReadmeScopeSafety', 'Full')) {
    Invoke-ScriptsReadmeScopeSafetyGate
}

if ($Scope -in @('GovernanceHistoryScopeSafety', 'Full')) {
    Invoke-GovernanceHistoryScopeSafetyGate
}

if ($Scope -in @('TestDataStructuredSyntaxSafety', 'Full')) {
    Invoke-TestDataStructuredSyntaxSafetyGate
}

if ($Scope -in @('QualityGateStructureSafety', 'Full')) {
    Invoke-QualityGateStructureSafetyGate
}

if ($Scope -in @('ActiveRunSafety', 'Full')) {
    Invoke-ActiveRunSafetyGate
}

if ($Scope -in @('ContextDocsInventorySafety', 'Full')) {
    Invoke-ContextDocsInventorySafetyGate
}

if ($Scope -in @('SessionLogSafety', 'Full')) {
    Invoke-SessionLogSafetyGate
}

if ($Scope -in @('VerificationMemorySafety', 'Full')) {
    Invoke-VerificationMemorySafetyGate
}

if ($Scope -in @('ActiveVerificationCommandSafety', 'Full')) {
    Invoke-ActiveVerificationCommandSafetyGate
}

if ($Scope -in @('ChecklistSafety', 'Full')) {
    Invoke-ChecklistSafetyGate
}

if ($Scope -in @('DecisionsLogSafety', 'Full')) {
    Invoke-DecisionsLogSafetyGate
}

if ($Scope -in @('CodexPolicySafety', 'Full')) {
    Invoke-CodexPolicySafetyGate
}

if ($Scope -in @('TaskRequestSafety', 'Full')) {
    Invoke-TaskRequestSafetyGate
}

if ($Scope -in @('CodexTemplateSafety', 'Full')) {
    Invoke-CodexTemplateSafetyGate
}

if ($Scope -in @('CodexGoalTemplateSafety', 'Full')) {
    Invoke-CodexGoalTemplateSafetyGate
}

if ($Scope -in @('CodexDocsInventorySafety', 'Full')) {
    Invoke-CodexDocsInventorySafetyGate
}

if ($Scope -in @('QaStrategySafety', 'Full')) {
    Invoke-QaStrategySafetyGate
}

if ($Scope -in @('HandoffProtocolSafety', 'Full')) {
    Invoke-HandoffProtocolSafetyGate
}

if ($Scope -in @('IncomingReferenceSafety', 'Full')) {
    Invoke-IncomingReferenceSafetyGate
}

if ($Scope -in @('FrameworkInventorySafety', 'Full')) {
    Invoke-FrameworkInventorySafetyGate
}

if ($Scope -in @('TestFrameworkInventorySafety', 'Full')) {
    Invoke-TestFrameworkInventorySafetyGate
}

if ($Scope -in @('IncidentStopSafety', 'Full')) {
    Invoke-IncidentStopSafetyGate
}

if ($Scope -in @('QaDocsSafety', 'Full')) {
    Invoke-QaDocsSafetyGate
}

if ($Scope -in @('ArtifactPolicySafety', 'Full')) {
    Invoke-ArtifactPolicySafetyGate
}

if ($Scope -in @('ContractFixtureSafety', 'Full')) {
    Invoke-ContractFixtureSafetyGate
}

if ($Scope -in @('StaticSurfaceSafety', 'Full')) {
    Invoke-StaticSurfaceSafetyGate
}

if ($Scope -in @('WebViewBundleLocalReferenceSafety', 'Full')) {
    Invoke-WebViewBundleLocalReferenceSafetyGate
}

if ($Scope -in @('FixtureInventorySafety', 'Full')) {
    Invoke-FixtureInventorySafetyGate
}

if ($Scope -in @('ScriptsInventorySafety', 'Full')) {
    Invoke-ScriptsInventorySafetyGate
}

if ($Scope -in @('RunnerSafety', 'Full')) {
    Invoke-RunnerSafetyGate
}

if ($Scope -in @('TestDataSafety', 'Full')) {
    Invoke-TestDataSafetyGate
}

if ($Scope -in @('TestDataInventorySafety', 'Full')) {
    Invoke-TestDataInventorySafetyGate
}

if ($Scope -in @('UnsafeFixtureCoverageSafety', 'Full')) {
    Invoke-UnsafeFixtureCoverageSafetyGate
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
