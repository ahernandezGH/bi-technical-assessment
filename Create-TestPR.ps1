# Script para crear PR automáticamente (requiere GitHub token)
# Uso: .\Create-TestPR.ps1

# ============================================================================
# PHASE 5.4 - Crear Test PR automáticamente
# ============================================================================

param(
    [string]$Token = $env:GITHUB_TOKEN,
    [string]$Owner = "ahernandezGH",
    [string]$Repo = "bi-technical-assessment",
    [string]$Branch = "solution-testcandidate-issue001",
    [string]$Title = "Solution - TestCandidate - Issue [001]"
)

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "CREATING TEST PULL REQUEST" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Verificar token
if (-not $Token) {
    Write-Host "❌ Error: GitHub token no encontrado" -ForegroundColor Red
    Write-Host ""
    Write-Host "Para usar este script, configura tu token:" -ForegroundColor Yellow
    Write-Host '  $env:GITHUB_TOKEN = "ghp_xxxxxxxxxxxxx"' -ForegroundColor Yellow
    Write-Host ""
    Write-Host "O crea el PR manualmente en:" -ForegroundColor Cyan
    Write-Host "  https://github.com/$Owner/$Repo/pull/new/$Branch" -ForegroundColor Cyan
    exit 1
}

# Preparar datos del PR
$prBody = @"
# Test Submission - Issue 001

## Summary
Testing the automated grading workflow for validation integrity check.

## Files Included
- QA_ValidarIntegridadEstudiantes.sql
- PROC_ValidarIntegridadPreInsert.sql
- SOLUTION.md

## How It Works
Detect orphan foreign keys in matricula table using LEFT JOIN pattern.

## Testing
This solution implements:
1. Query to find huérfanos in the matricula table
2. Stored procedure for integrity validation
3. Documentation of approach

---
This is a test PR to verify the GitHub Actions CI/CD workflow.
"@

$payload = @{
    title = $Title
    head  = $Branch
    base  = "main"
    body  = $prBody
} | ConvertTo-Json

Write-Host "📋 Detalles del PR:" -ForegroundColor Cyan
Write-Host "   Título: $Title" -ForegroundColor White
Write-Host "   Rama: $Branch" -ForegroundColor White
Write-Host "   Base: main" -ForegroundColor White
Write-Host ""
Write-Host "🔄 Enviando solicitud a GitHub API..." -ForegroundColor Yellow
Write-Host ""

# Crear PR via GitHub API
try {
    $headers = @{
        "Authorization" = "token $Token"
        "Accept"        = "application/vnd.github.v3+json"
    }

    $response = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/$Owner/$Repo/pulls" `
        -Method POST `
        -Headers $headers `
        -Body $payload `
        -ContentType "application/json"

    Write-Host "✅ PR CREADO EXITOSAMENTE" -ForegroundColor Green
    Write-Host ""
    Write-Host "📌 Detalles del PR:" -ForegroundColor Cyan
    Write-Host "   PR Number: #$($response.number)" -ForegroundColor White
    Write-Host "   URL: $($response.html_url)" -ForegroundColor White
    Write-Host "   State: $($response.state)" -ForegroundColor White
    Write-Host "   Created: $($response.created_at)" -ForegroundColor White
    Write-Host ""
    Write-Host "🚀 Workflow debería triggeriarse en ~10 segundos" -ForegroundColor Yellow
    Write-Host "   Monitorea el progreso en:" -ForegroundColor Cyan
    Write-Host "   https://github.com/$Owner/$Repo/actions" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

}
catch {
    Write-Host "❌ Error al crear PR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Respuesta de GitHub:" -ForegroundColor Yellow
    Write-Host ($_ | ConvertFrom-Json | ConvertTo-Json -Depth 10) -ForegroundColor Yellow
    exit 1
}
