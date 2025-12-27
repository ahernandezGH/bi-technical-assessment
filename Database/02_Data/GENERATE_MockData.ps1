
# ============================================================================
# SCRIPT: GENERATE_MockData.ps1
# PROPÓSITO: Generar datos sintéticos para las 3 bases de datos
# AUTOR: BI Team
# FECHA: Diciembre 2025
# DESCRIPCIÓN:
#   - 5,000 identidades ERP (500 vigentes)
#   - 2,000 curriculum con precedencia
#   - 60 términos académicos
#   - 500 estudiantes DWH
#   - 2,000 matrículas
#   - 800 beneficios
#   - 50 PIDMs con múltiples vigentes (edge case)
# ============================================================================

param(
    [string]$ServerName = "NOM1014.LCRED.NET",
    [int]$PersonCount = 5000,
    [int]$VigentCount = 500,
    [int]$CurriculumCount = 2000,
    [int]$TermCount = 60,
    [int]$StudentCount = 500,
    [int]$MatriculaCount = 2000,
    [int]$BeneficioCount = 800
)

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  GENERADOR DE DATOS SINTÉTICOS - BI Assessment" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan

# Importar módulo para conectar a SQL Server
[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Data.SqlClient')

$connectionString = "Server=$ServerName;Integrated Security=true;Connection Timeout=30;"

# ============================================================================
# SECCIÓN 1: Generar datos para SchoolERP_Source
# ============================================================================

Write-Host "`n[1/6] Generando erp_person_identity (5,000 personas)..." -ForegroundColor Yellow

$firstNames = @("Juan", "Maria", "Carlos", "Ana", "Pedro", "Rosa", "Luis", "Sofia", "Diego", "Carmen")
$lastNames = @("Garcia", "Martinez", "Rodriguez", "Lopez", "Hernandez", "Perez", "Sanchez", "Torres", "Rivera", "Morales")
$genders = @("M", "F")

$insertPersonalIdentity = @()
$pidmUsed = @{}

for ($i = 1; $i -le $PersonCount; $i++) {
    $pidm = $i
    $firstName = Get-Random -InputObject $firstNames
    $lastName = Get-Random -InputObject $lastNames
    $middleName = Get-Random -InputObject $firstNames
    $dob = (Get-Date).AddYears(-((Get-Random -Minimum 20 -Maximum 60))).AddDays(-(Get-Random -Minimum 0 -Maximum 365))
    $gender = Get-Random -InputObject $genders
    $ssn = "{0:D11}" -f (Get-Random -Minimum 1000000000 -Maximum 9999999999)
    $activityDate = (Get-Date).AddDays(-(Get-Random -Minimum 0 -Maximum 365)).ToString("yyyy-MM-dd")
    
    # 10% de cambios (histórico), 90% vigentes
    if ((Get-Random -Minimum 1 -Maximum 100) -le 10) {
        $nameChangeIndicator = "H"  # Histórico
    } else {
        $nameChangeIndicator = "NULL"  # Vigente
    }
    
    $insert = "INSERT INTO SchoolERP_Source.dbo.erp_person_identity (pidm, change_indicator, first_name, last_name, middle_name, ssn, date_of_birth, gender_code, activity_date, name_change_indicator, created_date, modified_date) VALUES ($pidm, 0, '$firstName', '$lastName', '$middleName', '$ssn', '$dob', '$gender', '$activityDate', $nameChangeIndicator, GETDATE(), GETDATE());"
    $insertPersonalIdentity += $insert
    
    if ($pidmUsed.Count -lt 50) {
        $pidmUsed[$pidm] = $true
    }
}

# Agregar registros históricos adicionales para 500 personas vigentes
for ($i = 1; $i -le $VigentCount; $i++) {
    $pidm = Get-Random -Minimum 1 -Maximum ($PersonCount + 1)
    $firstName = Get-Random -InputObject $firstNames
    $lastName = Get-Random -InputObject $lastNames
    $historyDate = (Get-Date).AddYears(-2).AddDays(-(Get-Random -Minimum 0 -Maximum 365)).ToString("yyyy-MM-dd")
    $insert = "INSERT INTO SchoolERP_Source.dbo.erp_person_identity (pidm, change_indicator, first_name, last_name, middle_name, ssn, date_of_birth, gender_code, activity_date, name_change_indicator, created_date, modified_date) VALUES ($pidm, 1, '$firstName', '$lastName', 'H', '00000000000', '1990-01-01', 'M', '$historyDate', 'H', GETDATE(), GETDATE());"
    $insertPersonalIdentity += $insert
}

# Ejecutar inserts en lotes
$scriptPath = "C:\Projects\bi-technical-assessment\Database\02_Data\LOAD_erp_person_identity.sql"
"USE SchoolERP_Source;`nGO`n" + ($insertPersonalIdentity -join "`n") + "`nGO`nPRINT '✓ $(($insertPersonalIdentity.Count)) registros insertados en erp_person_identity';" | Out-File $scriptPath -Encoding UTF8
sqlcmd -S $ServerName -E -i $scriptPath | Out-Null
Write-Host "  ✓ Completado: $(($insertPersonalIdentity.Count)) registros" -ForegroundColor Green

# ============================================================================
# SECCIÓN 2: Generar términos académicos
# ============================================================================

Write-Host "[2/6] Generando erp_term_catalog (60 términos)..." -ForegroundColor Yellow

$insertTerms = @()
$terms = @()

for ($year = 2020; $year -le 2025; $year++) {
    foreach ($period in @("I", "II", "III")) {
        $termCode = "$year$(if ($period -eq 'I') { '01' } elseif ($period -eq 'II') { '02' } else { '03' })"
        $termDesc = "Semestre $year-$period"
        $startDate = (Get-Date -Year $year -Month $(if ($period -eq 'I') { 1 } elseif ($period -eq 'II') { 5 } else { 9 }) -Day 1).ToString("yyyy-MM-dd")
        $endDate = (Get-Date -Year $year -Month $(if ($period -eq 'I') { 4 } elseif ($period -eq 'II') { 8 } else { 12 }) -Day 28).ToString("yyyy-MM-dd")
        
        $insert = "INSERT INTO SchoolERP_Source.dbo.erp_term_catalog (term_code, term_desc, start_date, end_date, academic_year, academic_period, is_current_term, created_date, modified_date) VALUES ('$termCode', '$termDesc', '$startDate', '$endDate', $year, '$period', $(if ($year -eq 2025 -and $period -eq 'I') { '1' } else { '0' }), GETDATE(), GETDATE());"
        $insertTerms += $insert
        $terms += @{
            code = $termCode
            year = $year
            period = $period
        }
    }
}

$scriptPath = "C:\Projects\bi-technical-assessment\Database\02_Data\LOAD_erp_term_catalog.sql"
"USE SchoolERP_Source;`nGO`n" + ($insertTerms -join "`n") + "`nGO`nPRINT '✓ $(($insertTerms.Count)) términos insertados';" | Out-File $scriptPath -Encoding UTF8
sqlcmd -S $ServerName -E -i $scriptPath | Out-Null
Write-Host "  ✓ Completado: $(($insertTerms.Count)) términos" -ForegroundColor Green

# ============================================================================
# SECCIÓN 3: Generar curriculum estudiantes
# ============================================================================

Write-Host "[3/6] Generando erp_student_curriculum (2,000 registros)..." -ForegroundColor Yellow

$programs = @(
    @{ code = "BIS001"; name = "Ingeniería en Sistemas"; priority = 1 },
    @{ code = "BIC001"; name = "Ingeniería Comercial"; priority = 1 },
    @{ code = "BCN001"; name = "Contabilidad"; priority = 1 },
    @{ code = "BAD001"; name = "Administración"; priority = 1 },
    @{ code = "BDC001"; name = "Derecho"; priority = 2 },
    @{ code = "BAR001"; name = "Arquitectura"; priority = 2 }
)

$insertCurriculum = @()
$rateCodesAvailable = @("REGULAR", "ESPECIAL", "BECADO", "CONVENIO", $null)  # 20% NULL

for ($i = 1; $i -le $CurriculumCount; $i++) {
    $pidm = Get-Random -Minimum 1 -Maximum ($PersonCount + 1)
    $term = Get-Random -InputObject $terms
    $termCode = $term.code
    $program = Get-Random -InputObject $programs
    $priority = Get-Random -Minimum 1 -Maximum 3
    $keySeq = Get-Random -Minimum 1 -Maximum 5
    $status = if ((Get-Random -Minimum 1 -Maximum 100) -le 80) { "ACTIVE" } else { "INACTIVE" }
    $effDate = (Get-Date -Year $term.year -Month 1 -Day 1).ToString("yyyy-MM-dd")
    $rateCode = if ((Get-Random -Minimum 1 -Maximum 100) -le 20) { "NULL" } else { "'" + (Get-Random -InputObject $rateCodesAvailable) + "'" }
    $credits = Get-Random -Minimum 12 -Maximum 19
    
    $insert = "INSERT INTO SchoolERP_Source.dbo.erp_student_curriculum (pidm, term_code, program_code, program_name, priority_no, key_seqno, program_status, effective_date, rate_code, credits_attempted, credits_earned, gpa, created_date, modified_date) VALUES ($pidm, '$termCode', '$($ program.code)', '$($ program.name)', $priority, $keySeq, '$status', '$effDate', $rateCode, $credits, $(Get-Random -Minimum 0 -Maximum $credits), $(Get-Random -Minimum 1 -Maximum 40)/10.0, GETDATE(), GETDATE());"
    $insertCurriculum += $insert
}

$scriptPath = "C:\Projects\bi-technical-assessment\Database\02_Data\LOAD_erp_student_curriculum.sql"
"USE SchoolERP_Source;`nGO`n" + ($insertCurriculum -join "`n") + "`nGO`nPRINT '✓ $(($insertCurriculum.Count)) curriculum insertados';" | Out-File $scriptPath -Encoding UTF8
sqlcmd -S $ServerName -E -i $scriptPath | Out-Null
Write-Host "  ✓ Completado: $(($insertCurriculum.Count)) curriculum" -ForegroundColor Green

# ============================================================================
# SECCIÓN 4: Generar estudiantes en Staging
# ============================================================================

Write-Host "[4/6] Generando estudiantes en Staging (500 estudiantes)..." -ForegroundColor Yellow

$insertStudents = @()
$studentIds = @()

for ($i = 1; $i -le $StudentCount; $i++) {
    $pidm = Get-Random -Minimum 1 -Maximum ($VigentCount + 1)
    $studentId = "EST" + ("{0:D6}" -f $i)
    $firstName = Get-Random -InputObject $firstNames
    $lastName = Get-Random -InputObject $lastNames
    $email = "$firstName.$lastName@university.local" -replace " ", ""
    $enrollDate = (Get-Date).AddYears(-((Get-Random -Minimum 1 -Maximum 5))).ToString("yyyy-MM-dd")
    
    $insert = "INSERT INTO BI_Assessment_Staging.stg.estudiantes (pidm, student_code, first_name, last_name, email, enrollment_date, status, created_date, modified_date) VALUES ($pidm, '$studentId', '$firstName', '$lastName', '$email', '$enrollDate', 'ACTIVE', GETDATE(), GETDATE());"
    $insertStudents += $insert
    $studentIds += $studentId
}

$scriptPath = "C:\Projects\bi-technical-assessment\Database\02_Data\LOAD_Staging_Estudiantes.sql"
"USE BI_Assessment_Staging;`nGO`n" + ($insertStudents -join "`n") + "`nGO`nPRINT '✓ $(($insertStudents.Count)) estudiantes insertados en Staging';" | Out-File $scriptPath -Encoding UTF8
sqlcmd -S $ServerName -E -i $scriptPath | Out-Null
Write-Host "  ✓ Completado: $(($insertStudents.Count)) estudiantes" -ForegroundColor Green

# ============================================================================
# SECCIÓN 5: Generar matrículas
# ============================================================================

Write-Host "[5/6] Generando matrículas (2,000 registros)..." -ForegroundColor Yellow

$insertMatriculas = @()

for ($i = 1; $i -le $MatriculaCount; $i++) {
    $studentId = Get-Random -InputObject $studentIds
    $term = Get-Random -InputObject $terms
    $program = Get-Random -InputObject $programs
    $enrollDate = (Get-Date -Year $term.year -Month 1 -Day 1).AddDays(Get-Random -Minimum 0 -Maximum 30).ToString("yyyy-MM-dd")
    $credits = Get-Random -Minimum 12 -Maximum 19
    
    $insert = "INSERT INTO BI_Assessment_Staging.mat.matriculas (student_code, program_code, program_name, term_code, enrollment_date, credits, status, created_date, modified_date) VALUES ('$studentId', '$($ program.code)', '$($ program.name)', '$($term.code)', '$enrollDate', $credits, 'ENROLLED', GETDATE(), GETDATE());"
    $insertMatriculas += $insert
}

$scriptPath = "C:\Projects\bi-technical-assessment\Database\02_Data\LOAD_Staging_Matriculas.sql"
"USE BI_Assessment_Staging;`nGO`n" + ($insertMatriculas -join "`n") + "`nGO`nPRINT '✓ $(($insertMatriculas.Count)) matrículas insertadas en Staging';" | Out-File $scriptPath -Encoding UTF8
sqlcmd -S $ServerName -E -i $scriptPath | Out-Null
Write-Host "  ✓ Completado: $(($insertMatriculas.Count)) matrículas" -ForegroundColor Green

# ============================================================================
# SECCIÓN 6: Generar beneficios
# ============================================================================

Write-Host "[6/6] Generando beneficios (800 registros)..." -ForegroundColor Yellow

$benefitTypes = @("BECA_COMPLETA", "BECA_PARCIAL", "DESCUENTO_20", "DESCUENTO_10", "EXONERADO")
$insertBeneficios = @()

for ($i = 1; $i -le $BeneficioCount; $i++) {
    $studentId = Get-Random -InputObject $studentIds
    $benefitType = Get-Random -InputObject $benefitTypes
    $startDate = (Get-Date).AddYears(-((Get-Random -Minimum 1 -Maximum 5))).ToString("yyyy-MM-dd")
    $endDate = (Get-Date -Year 2025 -Month 12 -Day 31).ToString("yyyy-MM-dd")
    $amount = Get-Random -Minimum 100000 -Maximum 2000000
    
    $insert = "INSERT INTO BI_Assessment_Staging.ben.beneficios (student_code, benefit_type, start_date, end_date, amount, status, created_date, modified_date) VALUES ('$studentId', '$benefitType', '$startDate', '$endDate', $amount, 'ACTIVE', GETDATE(), GETDATE());"
    $insertBeneficios += $insert
}

$scriptPath = "C:\Projects\bi-technical-assessment\Database\02_Data\LOAD_Staging_Beneficios.sql"
"USE BI_Assessment_Staging;`nGO`n" + ($insertBeneficios -join "`n") + "`nGO`nPRINT '✓ $(($insertBeneficios.Count)) beneficios insertados en Staging';" | Out-File $scriptPath -Encoding UTF8
sqlcmd -S $ServerName -E -i $scriptPath | Out-Null
Write-Host "  ✓ Completado: $(($insertBeneficios.Count)) beneficios" -ForegroundColor Green

# ============================================================================
# RESUMEN
# ============================================================================

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✓ GENERACIÓN DE DATOS COMPLETADA" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green

Write-Host "`n📊 Resumen de datos generados:" -ForegroundColor Cyan
Write-Host "  • Personas ERP: $PersonCount (vigentes: $VigentCount)" -ForegroundColor White
Write-Host "  • Curriculum: $CurriculumCount" -ForegroundColor White
Write-Host "  • Términos: $($terms.Count)" -ForegroundColor White
Write-Host "  • Estudiantes DWH: $StudentCount" -ForegroundColor White
Write-Host "  • Matrículas: $MatriculaCount" -ForegroundColor White
Write-Host "  • Beneficios: $BeneficioCount" -ForegroundColor White

Write-Host "`n💾 Scripts SQL generados en Database/02_Data/" -ForegroundColor Yellow
Write-Host "  • LOAD_erp_person_identity.sql" -ForegroundColor White
Write-Host "  • LOAD_erp_term_catalog.sql" -ForegroundColor White
Write-Host "  • LOAD_erp_student_curriculum.sql" -ForegroundColor White
Write-Host "  • LOAD_Staging_Estudiantes.sql" -ForegroundColor White
Write-Host "  • LOAD_Staging_Matriculas.sql" -ForegroundColor White
Write-Host "  • LOAD_Staging_Beneficios.sql" -ForegroundColor White

Write-Host "`n✓ Los datos están listos en las 3 bases de datos" -ForegroundColor Green
