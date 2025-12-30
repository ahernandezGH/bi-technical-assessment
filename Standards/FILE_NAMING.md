# File Naming Conventions - BI Technical Assessment

**Version**: 1.0  
**Last Updated**: 2024-12-28

---

## 📋 Overview

All files follow a **Phase-Action-Domain** pattern to clearly identify their purpose and lifecycle stage.

```text
[PHASE]_[ACTION]_[DOMAIN].sql
```

Where:

- **PHASE**: CREATE, ALTER, DROP, LOAD, QA, PROC, MERGE, REPORT, etc.
- **ACTION**: Verb describing what the script does (optional)
- **DOMAIN**: Table, procedure, or object affected
- **EXTENSION**: .sql, .ps1, .md, etc.

---

## 🏷️ File Prefixes by Phase

### 0️⃣ Schema Creation (DDL)

```text
CREATE_[ObjectName].sql        -- Initial table/view/procedure creation
ALTER_[ObjectName].sql         -- Schema modifications
DROP_[ObjectName].sql          -- Schema deletion (RARELY USED)

Examples:
  CREATE_DIM_Estudiantes.sql
  CREATE_PROC_SincronizarPersonas.sql
  ALTER_hechos_matricula_AddColumn.sql
```

### 1️⃣ Data Loading (DML)

```text
LOAD_[SourceName]_[TargetTable].sql   -- Insert/bulk load data
MERGE_[SourceTarget].sql               -- MERGE INTO (update+insert)
REFRESH_[ObjectName].sql               -- Refresh/reload existing data

Examples:
  LOAD_Source_Personas.sql
  LOAD_CSV_EstudiantesCSV.sql
  MERGE_Staging_DWH.sql
  REFRESH_MatriculaPorTermino.sql
```

### 2️⃣ Quality Assurance (Testing)

```text
QA_[ValidationName].sql        -- Validation/test queries
TEST_[FeatureName].sql         -- Feature-level tests
VALID_[DataQualityCheck].sql   -- Data quality validation

Examples:
  QA_ValidarIntegridadFK.sql
  QA_ContarFilasMatricula.sql
  TEST_ProcedureSync.sql
  VALID_DuplicatesStudents.sql
```

### 3️⃣ Procedures and Functions

```text
PROC_[ProcedureName].sql       -- CREATE PROCEDURE script
FUNC_[FunctionName].sql        -- CREATE FUNCTION script

Examples:
  PROC_SincronizarDimensiones.sql
  PROC_ValidarIntegridadPreInsert.sql
  FUNC_NormalizarRUT.sql
```

### 4️⃣ Reporting and Views

```text
REPORT_[ReportName].sql        -- Reporting queries/views
VIEW_[ViewName].sql            -- CREATE VIEW scripts

Examples:
  REPORT_MatriculasPorFacultad.sql
  REPORT_BeneficiariosPorTermino.sql
  VIEW_FK_Huerfanos.sql
```

### 5️⃣ Temporary/Working Files

```text
TEMP_[Description].sql         -- Temporary script (DELETE BEFORE SUBMITTING)
WIP_[WorkInProgress].sql       -- Work in progress
DRAFT_[Description].sql        -- Draft/experimental code
DEBUG_[Issue].sql              -- Debugging scripts
BACKUP_[ObjectName].sql        -- Backup scripts (temporary)
OUTPUT_[Results].txt           -- Output/results files (DELETE BEFORE SUBMITTING)

Examples:
  TEMP_TestFK.sql              ← DELETE THIS BEFORE COMMIT
  WIP_NewMatriculaLogic.sql    ← DELETE THIS BEFORE COMMIT
  DEBUG_Issue001.sql           ← DELETE THIS BEFORE COMMIT
  OUTPUT_ValidationResults.txt ← DELETE THIS BEFORE COMMIT
```

---

## 🏗️ By Database Layer

### SchoolERP_Source

```text
LOAD_Banner_Personas.sql              -- Extract from Oracle Banner
LOAD_CSV_DatosHistoricos.sql          -- Load from CSV files
EXTR_[BannerTable].sql                -- Extract scripts
```

### BI_Assessment_Staging

```text
LOAD_Source_Staging_Personas.sql      -- Source → Staging ETL
PROC_SincronizarPersonas.sql          -- Sync procedures
QA_ValidarIntegridadStaging.sql       -- Staging validation
MERGE_Staging_Staging.sql             -- Staging refresh
```

### BI_Assessment_DWH

```text
LOAD_Staging_DWH_Personas.sql         -- Staging → DWH ETL
CREATE_DIM_Estudiantes.sql            -- Dimension creation
CREATE_FACT_Matricula.sql             -- Fact table creation
PROC_MaterializarVistas.sql          -- Materialization
REPORT_MatriculaConsolidado.sql       -- DWH reporting views
```

---

## 📁 Folder Structure Examples

### Issue 001 - Validación Integridad

```text
Solutions/JuanPerez/Issue001/
├── QA_ValidarIntegridadEstudiantes.sql    ✓ Correct
├── PROC_ValidarIntegridadPreInsert.sql    ✓ Correct
├── SOLUTION.md                             ✓ Correct
├── TEMP_TestingQueries.sql                ✗ DELETE (temporary)
└── OUTPUT_Results.txt                     ✗ DELETE (output file)
```

### Issue 003 - Sincronización Catálogos

```text
Solutions/MariaPérez/Issue003/
├── PROC_SincronizarDimensionPersonas.sql
├── QA_ValidarSincronizacion.sql
├── ORQUESTADOR_SincronizacionCatalogos.ps1
├── SOLUTION.md
├── DRAFT_AlternativeApproach.sql          ✗ DELETE
└── BACKUP_OldProcedure.sql                ✗ DELETE
```

### Issue 007 - Integración Completa

```text
Solutions/PedroRodriguez/Issue007/
├── ETL_01_ExtraccionSource.sql
├── ETL_02_ValidacionStagingIntegridad.sql
├── ETL_03_TransformacionDWH.sql
├── ETL_04_MaterializacionVistas.sql
├── ORQUESTADOR_ETL_Completo.ps1
├── SOLUTION.md
├── DEBUG_ETLStep2.sql                     ✗ DELETE
├── TEMP_LoadTesting.ps1                   ✗ DELETE
└── OUTPUT_ExecutionLog.txt                ✗ DELETE
```

---

## 🎯 SQL Header Template

Every SQL file should include:

```sql
-- ============================================
-- Fase: [CREATE | LOAD | QA | PROC | REPORT]
-- Archivo: [Nombre completo del script]
-- Propósito: [Descripción breve]
-- Autor: [Tu Nombre]
-- Fecha: [2024-12-28]
-- ============================================
-- Cambios:
-- 2024-12-28: Versión inicial
-- ============================================
-- Dependencias:
-- - Tabla: [BI_Assessment_DWH].cat.dim_estudiantes
-- - Schema: [BI_Assessment_Staging].dbo.*
-- ============================================
-- Validación:
-- - Expected rows: 20
-- - Script execution time: ~2 segundos
-- ============================================

USE BI_Assessment_DWH;

-- Script content here
```

---

## 🚀 PowerShell Header Template

Every PowerShell file should include:

```powershell
<#
.SYNOPSIS
    Sincronizar catálogos desde Source a Staging

.DESCRIPTION
    Script que ejecuta procedure de sincronización con logging y error handling.

.PARAMETER ServerName
    SQL Server nombre o IP (default: localhost)

.PARAMETER DatabaseName
    Database target (default: BI_Assessment_Staging)

.EXAMPLE
    .\ORQUESTADOR_SincronizacionCatalogos.ps1 -ServerName "AHMHW" -DatabaseName "BI_Assessment_Staging"

.NOTES
    Autor: Tu Nombre
    Fecha: 2024-12-28
    Versión: 1.0
#>

param(
    [string]$ServerName = "localhost",
    [string]$DatabaseName = "BI_Assessment_Staging"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Script content here
```

---

## ✓ Cleaning Before Submission

**CRITICAL**: Remove all temporary files before submitting PR!

```powershell
# Detect and list temporary files
Get-ChildItem "Solutions\[TuNombre]\Issue001" -File | 
    Where-Object { $_.Name -match '^(TEMP|WIP|DRAFT|DEBUG|BACKUP|OUTPUT)_' } |
    ForEach-Object { Write-Host "DELETE: $($_.Name)" -ForegroundColor Red }

# Delete temporary files
Get-ChildItem "Solutions\[TuNombre]\Issue001" -File | 
    Where-Object { $_.Name -match '^(TEMP|WIP|DRAFT|DEBUG|BACKUP|OUTPUT)_' } |
    Remove-Item -Force

# Verify
Get-ChildItem "Solutions\[TuNombre]\Issue001" -File
```

---

## 📋 Checklist

Before submitting:

- [ ] File names use correct prefixes (CREATE, LOAD, QA, PROC, REPORT)
- [ ] No TEMP, WIP, DRAFT, DEBUG, BACKUP prefixes in final submission
- [ ] No OUTPUT_*.txt files included
- [ ] All SQL files have header comments
- [ ] All PowerShell files have <#...#> headers
- [ ] File names are descriptive and follow pattern
- [ ] No spaces in file names (use CamelCase or underscores)
- [ ] Extension matches file type (.sql, .ps1, .md)
- [ ] Folder structure matches Issue### pattern

---

## 🚫 Examples of BAD Naming

```text
❌ script.sql                    (too vague)
❌ Validate Integrity.sql        (spaces, unclear)
❌ script_v1_FINAL_backup.sql    (multiple versions)
❌ TEMP_Queries.sql              (temporary, should be deleted)
❌ Debug - Testing.sql           (spaces and dashes)
❌ Old_PROC.sql                  (missing action)
❌ File (1).sql                  (Windows auto-numbering)
```

## ✅ Examples of GOOD Naming

```text
✅ QA_ValidarIntegridadEstudiantes.sql
✅ PROC_SincronizarDimensionPersonas.sql
✅ CREATE_DIM_Estudiantes.sql
✅ LOAD_Source_Staging.sql
✅ REPORT_MatriculasPorFacultad.sql
✅ VIEW_FK_Huerfanos.sql
✅ ORQUESTADOR_ETL_Completo.ps1
✅ SOLUTION.md
```

---

Created: 2024-12-28
