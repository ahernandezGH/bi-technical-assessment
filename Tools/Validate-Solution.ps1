#Requires -Version 5.1
<#
.SYNOPSIS
    Validador de soluciones para BI Technical Assessment

.DESCRIPTION
    Valida que la solución de un candidato cumple con los requisitos mínimos:
    - Archivos requeridos presentes
    - Sintaxis SQL válida (PARSEONLY)
    - Query de validación retorna resultado esperado
    - Documentación mínima (palabras en SOLUTION.md)
    
.PARAMETER Issue
    Número de issue (001-007)
    
.PARAMETER Candidate
    Nombre del candidato (sin espacios, para carpeta)
    
.PARAMETER ServerName
    Servidor SQL (default: AHMHW)
    
.PARAMETER Username
    Usuario SQL
    
.PARAMETER Password
    Contraseña SQL
    
.EXAMPLE
    .\Validate-Solution.ps1 -Issue 001 -Candidate "JuanPerez" -Username "rl" -Password "rl2"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^\d{3}$')]
    [string]$Issue,
    
    [Parameter(Mandatory=$true)]
    [string]$Candidate,
    
    [string]$ServerName = "AHMHW",
    
    [string]$Username = "rl",
    
    [string]$Password = "rl2",
    
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Colores
$ColorHeader = "Cyan"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"
$ColorInfo = "White"

# Configuración de issues
$IssueConfig = @{
    "001" = @{
        Name = "Validación Integridad"
        RequiredFiles = @(
            "QA_ValidarIntegridadEstudiantes.sql",
            "PROC_ValidarIntegridadPreInsert.sql",
            "SOLUTION.md"
        )
        MinWords = 150
        Database = "BI_Assessment_DWH"
        ValidationQuery = "SELECT COUNT(*) AS huerfanos FROM mat.hechos_matricula WHERE id_estudiante NOT IN (SELECT id_estudiante FROM cat.dim_estudiantes)"
        ExpectedResult = 15
    }
    "002" = @{
        Name = "Optimización Vista"
        RequiredFiles = @(
            "QA_AnalisisPerformance.sql",
            "ALTER_v_matricula_beneficios_Optimizada.sql",
            "SOLUTION.md"
        )
        MinWords = 200
        Database = "BI_Assessment_DWH"
    }
    "003" = @{
        Name = "Refactorización ETL"
        RequiredFiles = @(
            "PLAN_Refactorizacion.md",
            "PROC_ETL_CargaBeneficiosOrquestador.sql",
            "SOLUTION.md"
        )
        MinWords = 250
        Database = "BI_Assessment_Staging"
    }
    "004" = @{
        Name = "Dimensión Cohortes"
        RequiredFiles = @(
            "PLAN_DimensionDesign.md",
            "DIAGRAM_ModeloDimensional.md",
            "CREATE_TABLE_dim_cohortes.sql",
            "SOLUTION.md"
        )
        MinWords = 300
        Database = "BI_Assessment_DWH"
    }
    "005" = @{
        Name = "Extracción ERP"
        RequiredFiles = @(
            "METODOLOGIA_Extraccion.md",
            "QA_AnalisisDatosOrigen.sql",
            "PROC_ExtractCurrentRecords.sql",
            "SOLUTION.md"
        )
        MinWords = 200
        Database = "SchoolERP_Source"
    }
    "006" = @{
        Name = "Fact Table Grain"
        RequiredFiles = @(
            "PLAN_FactTableDesign.md",
            "DIAGRAM_ModeloDimensional.md",
            "CREATE_TABLE_hechos_pagos.sql",
            "SOLUTION.md"
        )
        MinWords = 300
        Database = "BI_Assessment_DWH"
    }
    "007" = @{
        Name = "Vista Multi-Tabla"
        RequiredFiles = @(
            "QA_AnalisisRelaciones.sql",
            "CREATE_VIEW_v_estudiantes_programa_vigente.sql",
            "SOLUTION.md"
        )
        MinWords = 200
        Database = "SchoolERP_Source"
    }
}

# ============================================================================
# Funciones auxiliares
# ============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor $ColorHeader
    Write-Host "  $Message" -ForegroundColor $ColorHeader
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor $ColorHeader
}

function Write-Check {
    param(
        [string]$Message,
        [bool]$Success,
        [string]$Detail = ""
    )
    
    if ($Success) {
        Write-Host "  ✓ $Message" -ForegroundColor $ColorSuccess
        if ($Detail) { Write-Host "    $Detail" -ForegroundColor $ColorInfo }
    } else {
        Write-Host "  ✗ $Message" -ForegroundColor $ColorError
        if ($Detail) { Write-Host "    $Detail" -ForegroundColor $ColorWarning }
    }
}

function Test-SQLSyntax {
    param(
        [string]$FilePath,
        [string]$Server,
        [string]$User,
        [string]$Pass,
        [string]$Database
    )
    
    try {
        # Usar SET PARSEONLY para verificar sintaxis sin ejecutar
        $tempFile = [System.IO.Path]::GetTempFileName()
        "SET PARSEONLY ON;`n" + (Get-Content $FilePath -Raw) + "`nSET PARSEONLY OFF;" | Out-File $tempFile -Encoding UTF8
        
        $result = sqlcmd -S $Server -U $User -P $Pass -d $Database -i $tempFile -h -1 2>&1
        
        Remove-Item $tempFile -Force
        
        if ($LASTEXITCODE -eq 0) {
            return @{ Success = $true; Message = "Sintaxis válida" }
        } else {
            return @{ Success = $false; Message = "Error de sintaxis: $($result -join ' ')" }
        }
    } catch {
        return @{ Success = $false; Message = "Error al validar: $_" }
    }
}

# ============================================================================
# Inicio de validación
# ============================================================================

Write-Header "VALIDADOR DE SOLUCIONES - BI TECHNICAL ASSESSMENT"

if (-not $IssueConfig.ContainsKey($Issue)) {
    Write-Host "ERROR: Issue $Issue no existe. Issues válidos: 001-007" -ForegroundColor $ColorError
    exit 1
}

$config = $IssueConfig[$Issue]
$solutionPath = Join-Path (Get-Location) "Solutions\$Candidate\Issue$Issue"

Write-Host ""
Write-Host "Issue:     Issue $Issue - $($config.Name)" -ForegroundColor $ColorInfo
Write-Host "Candidato: $Candidate" -ForegroundColor $ColorInfo
Write-Host "Ruta:      $solutionPath" -ForegroundColor $ColorInfo
Write-Host "Servidor:  $ServerName" -ForegroundColor $ColorInfo

if ($DryRun) {
    Write-Host ""
    Write-Host "MODO DRY RUN - No se ejecutarán validaciones SQL" -ForegroundColor $ColorWarning
}

# ============================================================================
# CHECK 1: Archivos requeridos
# ============================================================================

Write-Header "CHECK 1: Archivos Requeridos"

$score = 0
$maxScore = 100
$fileCheckPoints = 25

if (-not (Test-Path $solutionPath)) {
    Write-Check "Carpeta de solución existe" $false "No se encontró: $solutionPath"
    Write-Host ""
    Write-Host "SCORE: 0/$maxScore - FAIL" -ForegroundColor $ColorError
    exit 1
}

$filesFound = 0
$totalFiles = $config.RequiredFiles.Count

foreach ($file in $config.RequiredFiles) {
    $filePath = Join-Path $solutionPath $file
    $exists = Test-Path $filePath
    Write-Check $file $exists
    if ($exists) { $filesFound++ }
}

$fileScore = [math]::Round(($filesFound / $totalFiles) * $fileCheckPoints)
$score += $fileScore

Write-Host ""
Write-Host "Archivos: $filesFound/$totalFiles ($fileScore/$fileCheckPoints puntos)" -ForegroundColor $ColorInfo

# ============================================================================
# CHECK 2: Sintaxis SQL
# ============================================================================

Write-Header "CHECK 2: Sintaxis SQL"

$sqlFiles = $config.RequiredFiles | Where-Object { $_ -like "*.sql" }
$sqlCheckPoints = 25
$sqlValid = 0

if (-not $DryRun) {
    foreach ($file in $sqlFiles) {
        $filePath = Join-Path $solutionPath $file
        if (Test-Path $filePath) {
            $result = Test-SQLSyntax -FilePath $filePath -Server $ServerName -User $Username -Pass $Password -Database $config.Database
            Write-Check $file $result.Success $result.Message
            if ($result.Success) { $sqlValid++ }
        }
    }
    
    if ($sqlFiles.Count -gt 0) {
        $sqlScore = [math]::Round(($sqlValid / $sqlFiles.Count) * $sqlCheckPoints)
        $score += $sqlScore
        Write-Host ""
        Write-Host "SQL válido: $sqlValid/$($sqlFiles.Count) ($sqlScore/$sqlCheckPoints puntos)" -ForegroundColor $ColorInfo
    }
} else {
    Write-Host "  (Skipped en DryRun)" -ForegroundColor $ColorWarning
}

# ============================================================================
# CHECK 3: Documentación
# ============================================================================

Write-Header "CHECK 3: Documentación (SOLUTION.md)"

$docCheckPoints = 20
$solutionMd = Join-Path $solutionPath "SOLUTION.md"

if (Test-Path $solutionMd) {
    $content = Get-Content $solutionMd -Raw
    $wordCount = ($content -split '\s+').Count
    $meetsMin = $wordCount -ge $config.MinWords
    
    Write-Check "SOLUTION.md presente" $true "$wordCount palabras (mínimo: $($config.MinWords))"
    
    if ($meetsMin) {
        $score += $docCheckPoints
        Write-Host ""
        Write-Host "Documentación: PASS ($docCheckPoints/$docCheckPoints puntos)" -ForegroundColor $ColorSuccess
    } else {
        $partialScore = [math]::Round(($wordCount / $config.MinWords) * $docCheckPoints)
        $score += $partialScore
        Write-Host ""
        Write-Host "Documentación: PARCIAL ($partialScore/$docCheckPoints puntos)" -ForegroundColor $ColorWarning
    }
} else {
    Write-Check "SOLUTION.md presente" $false "Archivo no encontrado"
}

# ============================================================================
# CHECK 4: Validación específica (si aplica)
# ============================================================================

if ($config.ValidationQuery -and -not $DryRun) {
    Write-Header "CHECK 4: Validación Específica"
    
    $validationCheckPoints = 30
    
    try {
        $result = sqlcmd -S $ServerName -U $Username -P $Password -d $config.Database -Q $config.ValidationQuery -h -1 -W 2>&1 | Select-Object -Skip 2 | Select-Object -First 1
        $actualValue = [int]($result -replace '\s+', '')
        
        if ($actualValue -eq $config.ExpectedResult) {
            Write-Check "Query de validación" $true "Resultado: $actualValue (esperado: $($config.ExpectedResult))"
            $score += $validationCheckPoints
        } else {
            Write-Check "Query de validación" $false "Resultado: $actualValue (esperado: $($config.ExpectedResult))"
        }
    } catch {
        Write-Check "Query de validación" $false "Error al ejecutar: $_"
    }
}

# ============================================================================
# RESULTADO FINAL
# ============================================================================

Write-Header "RESULTADO FINAL"

$passingScore = 70
$status = if ($score -ge $passingScore) { "PASS" } else { "FAIL" }
$statusColor = if ($status -eq "PASS") { $ColorSuccess } else { $ColorError }

Write-Host ""
Write-Host "SCORE: $score/$maxScore" -ForegroundColor $ColorInfo
Write-Host "STATUS: $status $(if ($status -eq 'PASS') { '✓' } else { '✗' })" -ForegroundColor $statusColor
Write-Host ""

if ($status -eq "PASS") {
    Write-Host "El candidato $Candidate es ELEGIBLE para Fase 2 (Entrevista Técnica)" -ForegroundColor $ColorSuccess
} else {
    Write-Host "El candidato $Candidate NO cumple el mínimo requerido (≥$passingScore)" -ForegroundColor $ColorWarning
    Write-Host "Puede recibir feedback y reenviar (1 vez permitida)" -ForegroundColor $ColorInfo
}

Write-Host ""

# Retornar código de salida
if ($status -eq "PASS") { exit 0 } else { exit 1 }
