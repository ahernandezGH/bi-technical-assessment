/*
================================================================================
  ARTEFACTO BASE - Issue 003
  ETL Monolítico: ETL_CargaBeneficios_MONOLITO
  PROPÓSITO: Procedimiento monolítico para refactorización
================================================================================
*/

USE BI_Assessment_Staging;
GO

-- Eliminar si existe
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'ETL_CargaBeneficios_MONOLITO' AND schema_id = SCHEMA_ID('ben'))
    DROP PROCEDURE ben.ETL_CargaBeneficios_MONOLITO;
GO

CREATE PROCEDURE ben.ETL_CargaBeneficios_MONOLITO
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMsg NVARCHAR(4000);
    DECLARE @RowCount INT;
    DECLARE @StartTime DATETIME = GETDATE();
    
    PRINT '=== Inicio ETL Carga Beneficios (MONOLITO) ===';
    PRINT 'Timestamp: ' + CONVERT(VARCHAR, @StartTime, 120);
    
    -- ========================================================================
    -- FASE 1: EXTRACCIÓN (debería estar en SP separado)
    -- ========================================================================
    PRINT 'Fase 1: Extrayendo datos staging...';
    
    -- Extraer beneficios del staging
    IF OBJECT_ID('tempdb..#temp_beneficios') IS NOT NULL DROP TABLE #temp_beneficios;
    
    SELECT 
        student_code,
        benefit_type,
        start_date,
        end_date,
        amount,
        status
    INTO #temp_beneficios
    FROM stg.beneficios
    WHERE status = 'ACTIVE';
    
    SET @RowCount = @@ROWCOUNT;
    PRINT 'Extraídos: ' + CAST(@RowCount AS VARCHAR) + ' registros';
    
    -- ========================================================================
    -- FASE 2: VALIDACIÓN (debería estar en SP separado)
    -- ========================================================================
    PRINT 'Fase 2: Validando datos...';
    
    -- Validar duplicados
    IF EXISTS (
        SELECT student_code, benefit_type, start_date
        FROM #temp_beneficios
        GROUP BY student_code, benefit_type, start_date
        HAVING COUNT(*) > 1
    )
    BEGIN
        SET @ErrorMsg = 'ERROR: Duplicados detectados en staging';
        PRINT @ErrorMsg;
        THROW 50001, @ErrorMsg, 1;
    END
    
    -- Validar montos
    IF EXISTS (SELECT 1 FROM #temp_beneficios WHERE amount <= 0 OR amount IS NULL)
    BEGIN
        SET @ErrorMsg = 'ERROR: Montos inválidos detectados';
        PRINT @ErrorMsg;
        THROW 50002, @ErrorMsg, 1;
    END
    
    -- Validar fechas
    IF EXISTS (SELECT 1 FROM #temp_beneficios WHERE start_date > end_date)
    BEGIN
        SET @ErrorMsg = 'ERROR: Fechas inconsistentes';
        PRINT @ErrorMsg;
        THROW 50003, @ErrorMsg, 1;
    END
    
    PRINT 'Validaciones OK';
    
    -- ========================================================================
    -- FASE 3: TRANSFORMACIÓN (debería estar en SP separado)
    -- ========================================================================
    PRINT 'Fase 3: Transformando datos...';
    
    -- Normalizar tipos de beneficio
    UPDATE #temp_beneficios
    SET benefit_type = UPPER(LTRIM(RTRIM(benefit_type)));
    
    -- Calcular duración en días
    ALTER TABLE #temp_beneficios ADD duracion_dias INT;
    
    UPDATE #temp_beneficios
    SET duracion_dias = DATEDIFF(DAY, start_date, end_date);
    
    PRINT 'Transformaciones aplicadas';
    
    -- ========================================================================
    -- FASE 4: CARGA (debería estar en SP separado con merge)
    -- ========================================================================
    PRINT 'Fase 4: Cargando a DWH...';
    
    -- En un diseño real, aquí haría INSERT/MERGE a BI_Assessment_DWH.ben.hechos_beneficios
    -- Por ahora solo simula
    SET @RowCount = (SELECT COUNT(*) FROM #temp_beneficios);
    PRINT 'Registros listos para carga: ' + CAST(@RowCount AS VARCHAR);
    
    -- ========================================================================
    -- FASE 5: MATERIALIZACIÓN DE VISTAS (debería estar en SP separado)
    -- ========================================================================
    PRINT 'Fase 5: Refrescando vistas materializadas...';
    
    -- Simulación de refresh de vistas
    PRINT 'Vista ben.v_beneficios_activos: refrescada';
    PRINT 'Vista ben.v_resumen_beneficios_estudiante: refrescada';
    
    -- ========================================================================
    -- RESUMEN FINAL
    -- ========================================================================
    DECLARE @EndTime DATETIME = GETDATE();
    DECLARE @Duration INT = DATEDIFF(SECOND, @StartTime, @EndTime);
    
    PRINT '=== ETL Completado ===';
    PRINT 'Duración: ' + CAST(@Duration AS VARCHAR) + ' segundos';
    PRINT 'Timestamp fin: ' + CONVERT(VARCHAR, @EndTime, 120);
    
    -- Limpieza
    IF OBJECT_ID('tempdb..#temp_beneficios') IS NOT NULL DROP TABLE #temp_beneficios;
END;
GO

PRINT '✓ Procedimiento monolítico ETL_CargaBeneficios_MONOLITO creado (Issue 003 - Artefacto Base)';
GO
