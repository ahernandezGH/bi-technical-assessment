# Logging Conventions - BI Technical Assessment

**Version**: 1.0  
**Last Updated**: 2024-12-28

---

## 📋 Tabla de Contenidos

1. [Logging Architecture](#logging-architecture)
2. [Procedure Signature](#procedure-signature)
3. [Implementation Pattern](#implementation-pattern)
4. [Query Validation and Reporting](#query-validation-and-reporting)
5. [Examples](#examples)

---

## 🏗️ Logging Architecture

### Logging Table

All ETL/sync processes must log to:
```
[BI_Assessment_Staging].dbo.registrar_log
```

**Expected Columns**:
```sql
CREATE TABLE dbo.registrar_log (
    id_ejecucion UNIQUEIDENTIFIER PRIMARY KEY,
    categoria_proceso VARCHAR(50),        -- ETL, SYNC, REPROCESAMIENTO
    nombre_proceso VARCHAR(100),          -- sp_SincronizarPersonas, etc.
    subproceso VARCHAR(100),              -- ReadSource, ValidateData, LoadDWH
    detalle_proceso VARCHAR(500),         -- Descripción de qué se hizo
    parametros VARCHAR(MAX),              -- JSON con parámetros
    resultado VARCHAR(50),                -- En proceso, Completado, Error
    fecha_hora_inicio DATETIME,
    fecha_hora_fin DATETIME,
    duracion_segundos INT,
    error_mensaje VARCHAR(MAX),
    fecha_registro DATETIME DEFAULT GETDATE()
);
```

---

## 🔧 Procedure Signature

### Standard Pattern

```sql
CREATE PROCEDURE [schema].[sp_NombreProcedure]
    @parametro1 INT,
    @parametro2 VARCHAR(100),
    @id_ejecucion UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Generar ID de ejecución si no se proporciona
    IF @id_ejecucion IS NULL
        SET @id_ejecucion = NEWID();
    
    DECLARE @fechaInicio DATETIME = GETDATE();
    DECLARE @parametros VARCHAR(1000) = 
        JSON_OBJECT('parametro1', @parametro1, 'parametro2', @parametro2);
    
    BEGIN TRY
        -- Registrar inicio
        EXEC registrar_log
            @id_ejecucion = @id_ejecucion,
            @categoria_proceso = 'ETL',
            @nombre_proceso = 'sp_NombreProcedure',
            @subproceso = 'Inicio',
            @detalle_proceso = 'Iniciando proceso...',
            @parametros = @parametros,
            @resultado = 'En proceso';
        
        -- LÓGICA AQUÍ
        
        -- Registrar éxito
        UPDATE registrar_log
        SET fecha_hora_fin = GETDATE(),
            duracion_segundos = DATEDIFF(SECOND, @fechaInicio, GETDATE()),
            resultado = 'Completado'
        WHERE id_ejecucion = @id_ejecucion;
        
    END TRY
    BEGIN CATCH
        -- Registrar error
        UPDATE registrar_log
        SET fecha_hora_fin = GETDATE(),
            duracion_segundos = DATEDIFF(SECOND, @fechaInicio, GETDATE()),
            resultado = 'Error',
            error_mensaje = ERROR_MESSAGE()
        WHERE id_ejecucion = @id_ejecucion;
        
        THROW;
    END CATCH
END
```

---

## 💡 Implementation Pattern

### Step 1: Initialize Execution Tracking

```sql
DECLARE @id_ejecucion UNIQUEIDENTIFIER = NEWID();
DECLARE @fechaInicio DATETIME = GETDATE();
DECLARE @parametros VARCHAR(1000) = 
    JSON_OBJECT('table', 'dim_estudiantes', 'limit', 100);
```

### Step 2: Register Process Start

```sql
INSERT INTO [BI_Assessment_Staging].dbo.registrar_log (
    id_ejecucion,
    categoria_proceso,
    nombre_proceso,
    subproceso,
    detalle_proceso,
    parametros,
    resultado,
    fecha_hora_inicio
)
VALUES (
    @id_ejecucion,
    'ETL',                              -- ETL, SYNC, REPROCESAMIENTO
    'sp_SincronizarDimensionPersonas',  -- Procedure name
    'ReadSource',                       -- Sub-step
    'Leyendo personas desde fuente',    -- What we're doing
    @parametros,                        -- JSON params
    'En proceso',
    GETDATE()
);
```

### Step 3: Execute Logic (with error handling)

```sql
BEGIN TRY
    -- Validar entrada
    IF @id_estudiante <= 0
    BEGIN
        RAISERROR('ID estudiante debe ser > 0', 16, 1);
    END
    
    -- Lógica principal
    INSERT INTO cat.dim_estudiantes (nombre, email)
    SELECT nombre, email FROM [SchoolERP_Source].erp.erp_persona
    WHERE id = @id_estudiante;
    
    -- Registrar métrica
    DECLARE @rowsInserted INT = @@ROWCOUNT;
    
    -- Update log: progreso
    UPDATE [BI_Assessment_Staging].dbo.registrar_log
    SET detalle_proceso = 'Insertados ' + CAST(@rowsInserted AS VARCHAR) + ' registros'
    WHERE id_ejecucion = @id_ejecucion;
    
END TRY
BEGIN CATCH
    -- Rollback (if in transaction)
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    -- Log error
    UPDATE [BI_Assessment_Staging].dbo.registrar_log
    SET resultado = 'Error',
        error_mensaje = ERROR_MESSAGE() + ' (Line ' + CAST(ERROR_LINE() AS VARCHAR) + ')',
        fecha_hora_fin = GETDATE(),
        duracion_segundos = DATEDIFF(SECOND, @fechaInicio, GETDATE())
    WHERE id_ejecucion = @id_ejecucion;
    
    THROW;
END CATCH
```

### Step 4: Register Completion

```sql
UPDATE [BI_Assessment_Staging].dbo.registrar_log
SET resultado = 'Completado',
    fecha_hora_fin = GETDATE(),
    duracion_segundos = DATEDIFF(SECOND, @fechaInicio, GETDATE()),
    detalle_proceso = 'Proceso finalizado exitosamente'
WHERE id_ejecucion = @id_ejecucion;
```

---

## 📊 Query Validation and Reporting

### Validate Execution Count

```sql
-- Contar ejecuciones por resultado (último 7 días)
SELECT 
    nombre_proceso,
    resultado,
    COUNT(*) AS cantidad,
    AVG(duracion_segundos) AS duracion_promedio_segundos
FROM [BI_Assessment_Staging].dbo.registrar_log
WHERE fecha_registro >= DATEADD(DAY, -7, GETDATE())
GROUP BY nombre_proceso, resultado
ORDER BY fecha_registro DESC;
```

### Identify Failed Processes

```sql
-- Últimos errores (últimas 24 horas)
SELECT 
    id_ejecucion,
    nombre_proceso,
    subproceso,
    error_mensaje,
    fecha_hora_fin
FROM [BI_Assessment_Staging].dbo.registrar_log
WHERE resultado = 'Error'
    AND fecha_registro >= DATEADD(DAY, -1, GETDATE())
ORDER BY fecha_hora_fin DESC;
```

### Performance Analysis

```sql
-- Procesos más lentos (promedio de duracion)
SELECT TOP 10
    nombre_proceso,
    COUNT(*) AS ejecuciones,
    AVG(duracion_segundos) AS duracion_promedio,
    MAX(duracion_segundos) AS duracion_maxima,
    MIN(duracion_segundos) AS duracion_minima
FROM [BI_Assessment_Staging].dbo.registrar_log
WHERE resultado = 'Completado'
GROUP BY nombre_proceso
ORDER BY duracion_promedio DESC;
```

---

## 📋 Examples

### Example 1: Simple ETL Procedure

```sql
CREATE PROCEDURE [cat].[sp_SincronizarEstudiantes]
    @anyo INT = 2024,
    @id_ejecucion UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @id_ejecucion IS NULL
        SET @id_ejecucion = NEWID();
    
    DECLARE @fechaInicio DATETIME = GETDATE();
    DECLARE @parametros VARCHAR(1000) = 
        JSON_OBJECT('anyo', @anyo);
    
    BEGIN TRY
        -- Register start
        INSERT INTO [BI_Assessment_Staging].dbo.registrar_log
        VALUES (
            @id_ejecucion,
            'SYNC',
            'sp_SincronizarEstudiantes',
            'Start',
            'Sincronizando estudiantes para año ' + CAST(@anyo AS VARCHAR),
            @parametros,
            'En proceso',
            GETDATE(),
            NULL,
            NULL,
            NULL,
            NULL
        );
        
        -- Delete existing (for full refresh)
        DELETE FROM cat.dim_estudiantes
        WHERE YEAR(fecha_carga) = @anyo;
        
        -- Insert new
        INSERT INTO cat.dim_estudiantes (id_persona, nombre, email, fecha_carga)
        SELECT 
            id,
            nombre,
            email,
            GETDATE()
        FROM [SchoolERP_Source].erp.erp_persona
        WHERE YEAR(fecha_creacion) = @anyo;
        
        DECLARE @rowCount INT = @@ROWCOUNT;
        
        -- Register completion
        UPDATE [BI_Assessment_Staging].dbo.registrar_log
        SET resultado = 'Completado',
            fecha_hora_fin = GETDATE(),
            duracion_segundos = DATEDIFF(SECOND, @fechaInicio, GETDATE()),
            detalle_proceso = 'Sincronizados ' + CAST(@rowCount AS VARCHAR) + ' registros'
        WHERE id_ejecucion = @id_ejecucion;
        
    END TRY
    BEGIN CATCH
        UPDATE [BI_Assessment_Staging].dbo.registrar_log
        SET resultado = 'Error',
            error_mensaje = ERROR_MESSAGE(),
            fecha_hora_fin = GETDATE(),
            duracion_segundos = DATEDIFF(SECOND, @fechaInicio, GETDATE())
        WHERE id_ejecucion = @id_ejecucion;
        
        THROW;
    END CATCH
END
```

### Example 2: PowerShell Orchestrator with Logging

```powershell
param(
    [string]$ProcessName = "ETL_Matricula",
    [int]$Year = 2024
)

$ServerName = "localhost"
$DatabaseName = "BI_Assessment_Staging"
$ExecutionId = [guid]::NewGuid()

Write-Host "Iniciando $ProcessName ($ExecutionId)"

try {
    # Run SQL procedure
    sqlcmd -S $ServerName `
           -d $DatabaseName `
           -Q "EXEC cat.sp_SincronizarEstudiantes @anyo=$Year, @id_ejecucion='$ExecutionId'"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Proceso completado" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Proceso falló" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Excepción: $_" -ForegroundColor Red
    exit 1
}
```

---

## ✓ Checklist

Before submitting procedures with logging:

- [ ] Table `registrar_log` created in Staging
- [ ] Unique `id_ejecucion` GUID generated per execution
- [ ] Log entry created on START (with 'En proceso')
- [ ] Log entry updated on SUCCESS (with 'Completado', duration)
- [ ] Log entry updated on ERROR (with error_mensaje)
- [ ] Parameters captured as JSON
- [ ] Error handling with TRY/CATCH
- [ ] @@ROWCOUNT used to track affected rows
- [ ] DATEDIFF(SECOND) used for duration calculation
- [ ] Comments explain WHY, not WHAT

---

Created: 2024-12-28
