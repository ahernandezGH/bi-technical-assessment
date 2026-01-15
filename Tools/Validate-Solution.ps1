#Requires -Version 5.1
<#
.SYNOPSIS
    Validador de soluciones para BI Technical Assessment

.DESCRIPTION
    Valida que la solucion de un candidato cumple con los requisitos minimos:
    - Archivos requeridos presentes
    - Sintaxis SQL valida (PARSEONLY)
    - Query de validacion retorna resultado esperado
    - Documentacion minima (palabras en SOLUTION.md)
    
.PARAMETER Issue
    Numero de issue (001-007)
    
.PARAMETER Candidate
    Nombre del candidato (sin espacios, para carpeta)
    
.PARAMETER ServerName
    Servidor SQL (default: AHMHW)
    
.PARAMETER Username
    Usuario SQL
    
.PARAMETER Password
    Contrasena SQL
    
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

# Configuracion de issues
$IssueConfig = @{
    "001" = @{
        Name = "Validacion Integridad"
        RequiredFiles = @(
            "QA_ValidarIntegridadEstudiantes.sql",
            "PROC_ValidarIntegridadPreInsert.sql",
            "SOLUTION.md"
        )
        MinWords = 150
        Database = "BI_Assessment_DWH"
        ValidationQuery = "SELECT COUNT(*) AS huerfanos FROM [BI_Assessment_DWH].mat.hechos_matricula hm LEFT JOIN [BI_Assessment_DWH].cat.dim_estudiantes de ON hm.id_estudiante = de.id_estudiante WHERE de.id_estudiante IS NULL"
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
        Name = "Dimension Cohortes"
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
        Name = "Extraccion ERP"
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
        Write-Host '  [OK] ' -NoNewline -ForegroundColor $ColorSuccess
        Write-Host $Message -ForegroundColor $ColorSuccess
        if ($Detail) {
            Write-Host '      ' -NoNewline
            Write-Host $Detail -ForegroundColor $ColorInfo
        }
    } else {
        Write-Host '  [X] ' -NoNewline -ForegroundColor $ColorError
        Write-Host $Message -ForegroundColor $ColorError
        if ($Detail) {
            Write-Host '      ' -NoNewline
            Write-Host $Detail -ForegroundColor $ColorWarning
        }
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
        $sqlContent = 'SET PARSEONLY ON;' + [System.Environment]::NewLine + (Get-Content $FilePath -Raw) + [System.Environment]::NewLine + 'SET PARSEONLY OFF;'
        $sqlContent | Out-File $tempFile -Encoding UTF8
        
        $result = sqlcmd -S $Server -U $User -P $Pass -d $Database -i $tempFile -h -1 2>&1
        
        Remove-Item $tempFile -Force
        
        if ($LASTEXITCODE -eq 0) {
            $successMsg = 'Sintaxis valida'
            return @{ Success = $true; Message = $successMsg }
        } else {
            $errorMsg = 'Error de sintaxis: ' + ($result -join ' ')
            return @{ Success = $false; Message = $errorMsg }
        }
    } catch {
        $catchMsg = 'Error al validar: ' + $_
        return @{ Success = $false; Message = $catchMsg }
    }
}

# ============================================================================
# Inicio de validacion
# ============================================================================

$mainHeader = 'VALIDADOR DE SOLUCIONES - BI TECHNICAL ASSESSMENT'
Write-Header $mainHeader

if (-not $IssueConfig.ContainsKey($Issue)) {
    $errorMsg = 'ERROR: Issue ' + $Issue + ' no existe. Issues validos: 001-007'
    Write-Host $errorMsg -ForegroundColor $ColorError
    exit 1
}

$config = $IssueConfig[$Issue]
$solutionPath = Join-Path (Get-Location) ('Solutions\' + $Candidate + '\Issue' + $Issue)

Write-Host ""
$issueMsg = 'Issue:     Issue ' + $Issue + ' - ' + $config.Name
Write-Host $issueMsg -ForegroundColor $ColorInfo
$candidateMsg = 'Candidato: ' + $Candidate
Write-Host $candidateMsg -ForegroundColor $ColorInfo
$pathMsg = 'Ruta:      ' + $solutionPath
Write-Host $pathMsg -ForegroundColor $ColorInfo
$serverMsg = 'Servidor:  ' + $ServerName
Write-Host $serverMsg -ForegroundColor $ColorInfo

if ($DryRun) {
    Write-Host ""
    $dryRunMsg = 'MODO DRY RUN - No se ejecutaran validaciones SQL'
    Write-Host $dryRunMsg -ForegroundColor $ColorWarning
}

# ============================================================================
# CHECK 1: Archivos requeridos
# ============================================================================

Write-Header 'CHECK 1: Archivos Requeridos'

$score = 0
$maxScore = 100
$fileCheckPoints = 25

if (-not (Test-Path $solutionPath)) {
    $checkMsg = 'Carpeta de solucion existe'
    $detailMsg = 'No se encontro: ' + $solutionPath
    Write-Check $checkMsg $false $detailMsg
    Write-Host ""
    $failMsg = 'SCORE: 0/' + $maxScore + ' - FAIL'
    Write-Host $failMsg -ForegroundColor $ColorError
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
$fileMessage = 'Archivos: ' + $filesFound + '/' + $totalFiles + ' (' + $fileScore + '/' + $fileCheckPoints + ' puntos)'
Write-Host $fileMessage -ForegroundColor $ColorInfo

# ============================================================================
# CHECK 2: Sintaxis SQL
# ============================================================================

$headerMessage = 'CHECK 2: Sintaxis SQL'
Write-Header $headerMessage

$sqlFiles = $config.RequiredFiles | Where-Object { $_ -like '*.sql' }
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
        $sqlMessage = 'SQL valido: ' + $sqlValid + '/' + $sqlFiles.Count + ' (' + $sqlScore + '/' + $sqlCheckPoints + ' puntos)'
        Write-Host $sqlMessage -ForegroundColor $ColorInfo
    }
} else {
    Write-Host '  (Skipped en DryRun)' -ForegroundColor $ColorWarning
}

# ============================================================================
# CHECK 3: Documentacion
# ============================================================================

$header3 = 'CHECK 3: Documentacion (SOLUTION.md)'
Write-Header $header3

$docCheckPoints = 20
$solutionMd = Join-Path $solutionPath 'SOLUTION.md'

if (Test-Path $solutionMd) {
    $content = Get-Content $solutionMd -Raw
    $wordCount = ($content -split '\s+').Count
    $meetsMin = $wordCount -ge $config.MinWords
    
    $checkMsg = 'SOLUTION.md presente'
    $detailMsg = '' + $wordCount + ' palabras (minimo: ' + $config.MinWords + ')'
    Write-Check $checkMsg $true $detailMsg
    
    if ($meetsMin) {
        $score += $docCheckPoints
        Write-Host ""
        $docMsg = 'Documentacion: PASS (' + $docCheckPoints + '/' + $docCheckPoints + ' puntos)'
        Write-Host $docMsg -ForegroundColor $ColorSuccess
    } else {
        $partialScore = [math]::Round(($wordCount / $config.MinWords) * $docCheckPoints)
        $score += $partialScore
        Write-Host ""
        $docMsg = 'Documentacion: PARCIAL (' + $partialScore + '/' + $docCheckPoints + ' puntos)'
        Write-Host $docMsg -ForegroundColor $ColorWarning
    }
} else {
    Write-Check 'SOLUTION.md presente' $false 'Archivo no encontrado'
}

# ============================================================================
# CHECK 4: Validacion especifica (si aplica)
# ============================================================================

if ($config.ValidationQuery -and -not $DryRun) {
    $header4 = 'CHECK 4: Validacion Especifica'
    Write-Header $header4
    
    $validationCheckPoints = 30
    
    try {
        $result = sqlcmd -S $ServerName -U $Username -P $Password -d $config.Database -Q $config.ValidationQuery -h -1 -W 2>&1
        # Filtrar solo lineas numericas (evita "(N rows affected)")
        $numericLine = $result | Where-Object { $_ -match '^\d+$' } | Select-Object -First 1
        $actualValue = [int]$numericLine
        
        if ($actualValue -eq $config.ExpectedResult) {
            $checkMsg = 'Query de validacion'
            $detailMsg = 'Resultado: ' + $actualValue + ' (esperado: ' + $config.ExpectedResult + ')'
            Write-Check $checkMsg $true $detailMsg
            $score += $validationCheckPoints
        } else {
            $checkMsg = 'Query de validacion'
            $detailMsg = 'Resultado: ' + $actualValue + ' (esperado: ' + $config.ExpectedResult + ')'
            Write-Check $checkMsg $false $detailMsg
        }
    } catch {
        $checkMsg = 'Query de validacion'
        $errorDetail = 'Error al ejecutar: ' + $_
        Write-Check $checkMsg $false $errorDetail
    }
}

# ============================================================================
# RESULTADO FINAL
# ============================================================================

Write-Header 'RESULTADO FINAL'

$passingScore = 70
$status = if ($score -ge $passingScore) { 'PASS' } else { 'FAIL' }
$statusColor = if ($status -eq 'PASS') { $ColorSuccess } else { $ColorError }

Write-Host ""
$scoreMsg = 'SCORE: ' + $score + '/' + $maxScore
Write-Host $scoreMsg -ForegroundColor $ColorInfo
$statusSymbol = if ($status -eq 'PASS') { '[OK]' } else { '[FAIL]' }
$statusMsg = 'STATUS: ' + $status + ' ' + $statusSymbol
Write-Host $statusMsg -ForegroundColor $statusColor
Write-Host ""

if ($status -eq 'PASS') {
    $passMsg = 'El candidato ' + $Candidate + ' es ELEGIBLE para Fase 2 (Entrevista Tecnica)'
    Write-Host $passMsg -ForegroundColor $ColorSuccess
} else {
    $failMsg = 'El candidato ' + $Candidate + ' NO cumple el minimo requerido (>=' + $passingScore + ')'
    Write-Host $failMsg -ForegroundColor $ColorWarning
    $retryMsg = 'Puede recibir feedback y reenviar (1 vez permitida)'
    Write-Host $retryMsg -ForegroundColor $ColorInfo
}

Write-Host ""

# Retornar codigo de salida
if ($status -eq 'PASS') { exit 0 } else { exit 1 }
