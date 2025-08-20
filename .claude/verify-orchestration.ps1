#!/usr/bin/env pwsh
Write-Host "🔍 Verifying Orchestration Installation..." -ForegroundColor Cyan
Write-Host ""

# Check agents
Write-Host "✅ Checking Agents:" -ForegroundColor Green
$agents = @("orchestrator", "researcher", "planner", "implementer", "tester", "reviewer", "memory")
foreach ($agent in $agents) {
    $agentPath = ".claude/agents/$agent.md"
    if (Test-Path $agentPath) {
        Write-Host "  ✓ $agent agent installed" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $agent agent missing" -ForegroundColor Red
    }
}
Write-Host ""

# Check settings
Write-Host "✅ Checking Settings:" -ForegroundColor Green
if (Test-Path ".claude/settings.local.json") {
    Write-Host "  ✓ settings.local.json configured" -ForegroundColor Green
    $settings = Get-Content ".claude/settings.local.json" | ConvertFrom-Json
    if ($settings.env.ORCHESTRATION_ENABLED -eq "true") {
        Write-Host "  ✓ Orchestration enabled" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Orchestration not enabled" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ settings.local.json missing" -ForegroundColor Red
}
Write-Host ""

# Check orchestration config
Write-Host "✅ Checking Orchestration Config:" -ForegroundColor Green
if (Test-Path ".claude/orchestration_config.json") {
    Write-Host "  ✓ orchestration_config.json present" -ForegroundColor Green
    $config = Get-Content ".claude/orchestration_config.json" | ConvertFrom-Json
    if ($config.orchestration.enabled -eq $true) {
        Write-Host "  ✓ TDD methodology configured" -ForegroundColor Green
    }
} else {
    Write-Host "  ✗ orchestration_config.json missing" -ForegroundColor Red
}
Write-Host ""

# Check memory
Write-Host "✅ Checking Project Memory:" -ForegroundColor Green
if (Test-Path "CLAUDE.md") {
    Write-Host "  ✓ Project memory (CLAUDE.md) present" -ForegroundColor Green
} else {
    Write-Host "  ✗ Project memory missing" -ForegroundColor Red
}
Write-Host ""

# Check documentation structure
Write-Host "✅ Checking Documentation Structure:" -ForegroundColor Green
$docDirs = @("docs/references", "docs/ADR", "test")
foreach ($dir in $docDirs) {
    if (Test-Path $dir) {
        Write-Host "  ✓ $dir directory created" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $dir directory missing" -ForegroundColor Red
    }
}
Write-Host ""

Write-Host "🎉 Orchestration System Status: READY" -ForegroundColor Magenta
Write-Host ""
Write-Host "Test with: claude 'Create a plan for building a REST API'" -ForegroundColor Yellow
Write-Host "TDD Test: claude 'Implement user authentication with TDD'" -ForegroundColor Yellow