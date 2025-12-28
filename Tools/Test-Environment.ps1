#Requires -Version 5.1
<#
.SYNOPSIS
    Prueba el entorno de evaluación técnica BI

.DESCRIPTION
    Verifica que el entorno del candidato tiene:
    - SQL Server accesible
    - 3 bases de datos creadas
    - Esquemas correctos
    - Volumetría mínima esperada
    - PowerShell y Git configurados
    
.PARAMETER ServerName
    Servidor SQL (default: AHMHW)
    
.PARAMETER Username
    Usuario SQL
    
.PARAMETER Password
    Contraseña SQL
    
.EXAMPLE
    .\Test-Environment.ps1 -Username "rl" -Password "rl2"
#>

param(
    [string]$ServerName = "AHMHW",
    [string]$Username = "rl",
    [string]$Password = "rl2"
)

$ErrorActionPreference = "Continue"

# Colores
$ColorHeader = "Cyan"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"
$ColorInfo = "White"

# ============================================================================
# Funciones auxiliares
# ============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "=======================================================" -ForegroundColor $ColorHeader
    Write-Host "  $Message" -ForegroundColor $ColorHeader
    Write-Host "=======================================================" -ForegroundColor $ColorHeader
    Write-Host ""
}

function Write-Check {
    param(
        [string]$Message,
        [bool]$Success,
        [string]$Detail = ""
    )
    
    if ($Success) {
        Write-Host "  [OK] $Message" -ForegroundColor $ColorSuccess
        if ($Detail) { Write-Host "    $Detail" -ForegroundColor $ColorInfo }
        return 1
    } else {
        Write-Host "  [X] $Message" -ForegroundColor $ColorError
        if ($Detail) { Write-Host "    $Detail" -ForegroundColor $ColorWarning }
        return 0
    }
}

function Test-SQLConnection {
    param([string]$Server, [string]$User, [string]$Pass)
    
    try {
        $output = sqlcmd -S $Server -U $User -P $Pass -Q "SELECT 1" -h -1 -W 2>&1
        $exitCode = $LASTEXITCODE
        return ($exitCode -eq 0)
    } catch {
        return $false
    }
}

function Get-DatabaseExists {
    param([string]$Server, [string]$User, [string]$Pass, [string]$Database)
    
    try {
        $query = "SELECT COUNT(*) FROM sys.databases WHERE name = '$Database'"
        $result = sqlcmd -S $Server -U $User -P $Pass -Q $query -h -1 -W 2>&1
        return (([int]($result | Select-Object -Last 1)) -gt 0)
    } catch {
        return $false
    }
}

function Get-SchemaExists {
    param([string]$Server, [string]$User, [string]$Pass, [string]$Database, [string]$Schema)
    
    try {
        $query = "SELECT COUNT(*) FROM [$Database].sys.schemas WHERE name = '$Schema'"
        $result = sqlcmd -S $Server -U $User -P $Pass -Q $query -h -1 -W 2>&1
        return (([int]($result | Select-Object -Last 1)) -gt 0)
    } catch {
        return $false
    }
}

function Get-TableRowCount {
    param([string]$Server, [string]$User, [string]$Pass, [string]$Database, [string]$Schema, [string]$Table)
    
    try {
        $query = "SELECT COUNT(*) FROM [$Database].[$Schema].[$Table]"
        $result = sqlcmd -S $Server -U $User -P $Pass -Q $query -h -1 -W 2>&1
        return [int]($result | Select-Object -Last 1)
    } catch {
        return -1
    }
}

# ============================================================================
# Inicio de validación
# ============================================================================

Write-Header "TEST DE ENTORNO - BI TECHNICAL ASSESSMENT"

Write-Host "Servidor: $ServerName" -ForegroundColor $ColorInfo
Write-Host "Usuario:  $Username" -ForegroundColor $ColorInfo
Write-Host ""

$checksOK = 0
$totalChecks = 0

# ============================================================================
# CHECK 1: Software base
# ============================================================================

Write-Header "CHECK 1: Software Base"

# PowerShell
$totalChecks++
$psVersion = $PSVersionTable.PSVersion
$checksOK += Write-Check "PowerShell 5.1+" ($psVersion.Major -ge 5) "Versión: $psVersion"

# Git
$totalChecks++
try {
    $gitVersion = (git --version 2>&1) -replace 'git version ', ''
    $checksOK += Write-Check "Git instalado" $true "Versión: $gitVersion"
} catch {
    $checksOK += Write-Check "Git instalado" $false "No encontrado"
}

# sqlcmd
$totalChecks++
try {
    $sqlcmdTest = sqlcmd -? 2>&1
    $checksOK += Write-Check "sqlcmd disponible" $true
} catch {
    $checksOK += Write-Check "sqlcmd disponible" $false "No encontrado en PATH"
}

# ============================================================================
# CHECK 2: Conectividad SQL Server
# ============================================================================

Write-Header "CHECK 2: SQL Server"

$totalChecks++
$sqlConnected = Test-SQLConnection -Server $ServerName -User $Username -Pass $Pass

if ($sqlConnected) {
    $checksOK += Write-Check "Conexión a SQL Server" $true "$ServerName"
    
    # Obtener version
    try {
        $versionQuery = "SELECT @@VERSION"
        $version = sqlcmd -S $ServerName -U $Username -P $Password -Q $versionQuery -h -1 -W 2>&1 | Select-Object -First 1
        Write-Host "    $version" -ForegroundColor $ColorInfo
    } catch {}
} else {
    $checksOK += Write-Check "Conexión a SQL Server" $false "No se pudo conectar a $ServerName"
    Write-Host ""
    Write-Host "ERROR CRÍTICO: No se puede continuar sin conexión SQL" -ForegroundColor $ColorError
    exit 1
}

# ============================================================================
# CHECK 3: Bases de datos
# ============================================================================

Write-Header "CHECK 3: Bases de Datos"

$databases = @{
    "SchoolERP_Source" = @{
        Schemas = @("dbo")
        Tables = @(
            @{Schema="dbo"; Name="erp_person_identity"; MinRows=10},
            @{Schema="dbo"; Name="erp_term_catalog"; MinRows=5},
            @{Schema="dbo"; Name="erp_student_curriculum"; MinRows=5}
        )
    }
    "BI_Assessment_Staging" = @{
        Schemas = @("stg", "cat", "mat", "ben")
        Tables = @()
    }
    "BI_Assessment_DWH" = @{
        Schemas = @("cat", "mat", "ben")
        Tables = @(
            @{Schema="mat"; Name="hechos_matricula"; MinRows=15}
        )
    }
}

foreach ($db in $databases.Keys) {
    $totalChecks++
    $exists = Get-DatabaseExists -Server $ServerName -User $Username -Pass $Password -Database $db
    $checksOK += Write-Check "Base de datos: $db" $exists
    
    if ($exists) {
        # Verificar esquemas
        foreach ($schema in $databases[$db].Schemas) {
            $totalChecks++
            $schemaExists = Get-SchemaExists -Server $ServerName -User $Username -Pass $Password -Database $db -Schema $schema
            $checksOK += Write-Check "  Esquema: $schema" $schemaExists
        }
        
        # Verificar tablas y volumetría
        foreach ($table in $databases[$db].Tables) {
            $totalChecks++
            $rowCount = Get-TableRowCount -Server $ServerName -User $Username -Pass $Password -Database $db -Schema $table.Schema -Table $table.Name
            
            if ($rowCount -ge 0) {
                $meetsMin = $rowCount -ge $table.MinRows
                $checksOK += Write-Check "  Tabla: $($table.Schema).$($table.Name)" $meetsMin "$rowCount registros (mín: $($table.MinRows))"
            } else {
                $checksOK += Write-Check "  Tabla: $($table.Schema).$($table.Name)" $false "No accesible"
            }
        }
    }
}

# ============================================================================
# CHECK 4: Validaciones específicas
# ============================================================================

Write-Header "CHECK 4: Edge Cases y Datos de Prueba"

# Verificar FK huérfanos (Issue 001)
$totalChecks++
try {
    $query = "SELECT COUNT(*) FROM BI_Assessment_DWH.mat.hechos_matricula WHERE id_estudiante > 99980"
    $result = sqlcmd -S $ServerName -U $Username -P $Password -Q $query -h -1 -W 2>&1
    $huerfanos = [int]($result | Select-Object -Last 1)
    $checksOK += Write-Check "FK huérfanos (Issue 001)" ($huerfanos -eq 15) "$huerfanos registros (esperado: 15)"
} catch {
    $checksOK += Write-Check "FK huérfanos (Issue 001)" $false "No se pudo verificar"
}

# ============================================================================
# CHECK 5: Estructura del repositorio
# ============================================================================

Write-Header "CHECK 5: Estructura del Repositorio"

$requiredFolders = @(
    "Database\01_Schema",
    "Database\02_Data",
    "Database\03_Baseline",
    "Issues",
    "Tools",
    "Standards"
)

foreach ($folder in $requiredFolders) {
    $totalChecks++
    $exists = Test-Path $folder
    $checksOK += Write-Check "Carpeta: $folder" $exists
}

# Git inicializado
$totalChecks++
$gitInit = Test-Path ".git"
$checksOK += Write-Check "Git inicializado" $gitInit

# ============================================================================
# RESULTADO FINAL
# ============================================================================

Write-Header "RESULTADO FINAL"

$percentage = [math]::Round(($checksOK / $totalChecks) * 100)
$status = if ($percentage -ge 80) { "PASS" } else { "FAIL" }
$statusColor = if ($percentage -ge 80) { $ColorSuccess } else { $ColorError }

Write-Host ""
Write-Host "Checks OK: $checksOK/$totalChecks ($percentage%)" -ForegroundColor $ColorInfo
Write-Host "STATUS: $status" -ForegroundColor $statusColor
Write-Host ""

if ($percentage -ge 80) {
    Write-Host "[OK] ENTORNO LISTO PARA EVALUACION" -ForegroundColor $ColorSuccess
} else {
    Write-Host "[!] CONFIGURACION INCOMPLETA" -ForegroundColor $ColorWarning
    Write-Host ""
    Write-Host "Revisar los checks fallidos arriba y completar setup" -ForegroundColor $ColorInfo
    Write-Host "Consultar SETUP.md para instrucciones detalladas" -ForegroundColor $ColorInfo
}

Write-Host ""

# Retornar código de salida
if ($percentage -ge 80) { exit 0 } else { exit 1 }
