/*
================================================================================
ARCHIVO: ARTIFACT_DimensionCohorte_Template.sql
DESCRIPCION: Plantilla para creacion de dimension cohortes (Issue 004)
AUTOR: Sistema
FECHA: 2025-01-15
PROYECTO: BI Technical Assessment
ISSUE: Issue004 - Dimensional Modeling

PROPOSITO:
- Proveer estructura base para dimension cat.dim_cohortes
- Incluir atributos descriptivos y jerarquicos minimos
- Demostrar buenas practicas de modelado dimensional (SCD, surrogate keys)

CONTEXTO:
La dimension cohortes actualmente solo tiene codigo_cohorte (natural key) y
fecha_inicio. El candidato debe expandirla con atributos calculados, jerarquias
temporales y soporte SCD Type 2.

TAREAS DEL CANDIDATO:
1. Analizar esta plantilla y requisitos de negocio
2. Crear CREATE_DimensionCohorte_Enriquecida.sql con:
   - Columnas adicionales: anyo_cohorte, semestre_cohorte, estado_cohorte
   - Atributos calculados: anyo_academico (ej: 2024-1), edad_cohorte_meses
   - SCD Type 2: fecha_inicio_vigencia, fecha_fin_vigencia, registro_actual
   - Jerarquia temporal: anyo > semestre > mes_inicio
3. Crear PROC_CargaDimensionCohorte.sql para:
   - Detectar cambios en atributos descriptivos
   - Implementar SCD Type 2 (INSERT nuevos, UPDATE old con fecha_fin)
   - Mantener integridad con hechos_matricula (usar surrogate key)
4. Documentar decisiones de modelado en SOLUTION.md (300-500 palabras)

METRICAS ESPERADAS:
- Dimension debe soportar cambios historicos (ej: cohorte 2024-1 cambia estado)
- SP debe detectar 100% de cambios en atributos rastreados
- Volumetria: ~50 cohortes por anyo academico (2 semestres, 1 verano)
================================================================================
*/

USE BI_Assessment_DWH;
GO

-- ===========================================================================
-- VERSION BASELINE: Estructura minima actual
-- ===========================================================================

-- NOTA: Esta tabla YA existe en el baseline. El candidato debe crear version enriquecida.

/*
CREATE TABLE cat.dim_cohortes (
    id_cohorte BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_cohorte VARCHAR(20) NOT NULL UNIQUE,
    fecha_inicio DATE NOT NULL
);
*/

-- ===========================================================================
-- VERSION OBJETIVO: Estructura expandida (a implementar por candidato)
-- ===========================================================================

/*
REQUERIMIENTOS DE NEGOCIO:

1. ATRIBUTOS BASICOS:
   - codigo_cohorte: Natural key (ej: 2024-1, 2025-V)
   - fecha_inicio: Fecha inicio cohorte
   - fecha_fin: Fecha fin programada (calculada: +6 meses)
   - estado_cohorte: ACTIVA | CERRADA | SUSPENDIDA

2. ATRIBUTOS CALCULADOS:
   - anyo_cohorte: Extraido de codigo_cohorte (ej: 2024)
   - semestre_cohorte: 1 (marzo), 2 (agosto), V (verano enero)
   - anyo_academico: Formato año-semestre (ej: 2024-1)
   - edad_cohorte_meses: DATEDIFF(MONTH, fecha_inicio, GETDATE())
   - trimestre_inicio: Q1, Q2, Q3, Q4

3. JERARQUIA TEMPORAL (para drill-down en SSAS):
   - Nivel 1: anyo_cohorte
   - Nivel 2: semestre_cohorte
   - Nivel 3: codigo_cohorte (leaf)

4. SCD TYPE 2 (rastrear cambios historicos):
   - fecha_inicio_vigencia: Cuando registro toma vigencia
   - fecha_fin_vigencia: Cuando registro expira (NULL = actual)
   - registro_actual: BIT (1 = vigente, 0 = historico)
   - version_registro: INT (autoincremental por codigo_cohorte)

5. ATRIBUTOS DE AUDITORIA:
   - fecha_carga: Cuando se inserto en DWH
   - usuario_carga: LOGIN que ejecuto ETL
   - fuente_datos: 'ERP' | 'MANUAL' | 'MIGRACION'

EJEMPLO DE PLANTILLA EXPANDIDA:
*/

/*
CREATE TABLE cat.dim_cohortes_enriquecida (
    -- Surrogate Key
    id_cohorte_sk BIGINT IDENTITY(1,1) PRIMARY KEY,
    
    -- Natural Key
    codigo_cohorte VARCHAR(20) NOT NULL,
    
    -- Atributos descriptivos
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NULL,  -- Calculado: DATEADD(MONTH, 6, fecha_inicio)
    estado_cohorte VARCHAR(20) DEFAULT 'ACTIVA' CHECK (estado_cohorte IN ('ACTIVA', 'CERRADA', 'SUSPENDIDA')),
    
    -- Atributos calculados
    anyo_cohorte INT NOT NULL,  -- YEAR(fecha_inicio)
    semestre_cohorte VARCHAR(2) NOT NULL,  -- '1', '2', 'V'
    anyo_academico AS (CAST(anyo_cohorte AS VARCHAR(4)) + '-' + semestre_cohorte) PERSISTED,
    edad_cohorte_meses AS (DATEDIFF(MONTH, fecha_inicio, GETDATE())) PERSISTED,
    trimestre_inicio AS ('Q' + CAST(DATEPART(QUARTER, fecha_inicio) AS VARCHAR(1))) PERSISTED,
    
    -- SCD Type 2
    fecha_inicio_vigencia DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin_vigencia DATETIME NULL,
    registro_actual BIT NOT NULL DEFAULT 1,
    version_registro INT NOT NULL DEFAULT 1,
    
    -- Auditoria
    fecha_carga DATETIME NOT NULL DEFAULT GETDATE(),
    usuario_carga VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER,
    fuente_datos VARCHAR(20) NOT NULL DEFAULT 'ERP',
    
    -- Indices
    INDEX IX_dim_cohortes_codigo (codigo_cohorte, registro_actual),
    INDEX IX_dim_cohortes_anyo_semestre (anyo_cohorte, semestre_cohorte),
    INDEX IX_dim_cohortes_vigencia (fecha_inicio_vigencia, fecha_fin_vigencia)
);
*/

-- ===========================================================================
-- STORED PROCEDURE: Carga con SCD Type 2
-- ===========================================================================

/*
LOGICA DE CARGA:

1. STAGING: Leer datos fuente (ERP, CSV) a tabla temporal
2. DETECCION CAMBIOS: Comparar staging vs dimension actual (JOIN por codigo_cohorte)
3. NUEVOS REGISTROS: INSERT directo con registro_actual=1
4. CAMBIOS: 
   a. UPDATE registro old: SET fecha_fin_vigencia=GETDATE(), registro_actual=0
   b. INSERT registro new: con version_registro+1, registro_actual=1
5. SIN CAMBIOS: No hacer nada (dimension inmutable)

ATRIBUTOS RASTREADOS (triggers de SCD Type 2):
- estado_cohorte (cambio ACTIVA->CERRADA)
- fecha_fin (reprogramacion)
- Otros atributos descriptivos son inmutables (fecha_inicio, anyo, semestre)

EJEMPLO DE PROCEDIMIENTO:
*/

/*
CREATE OR ALTER PROCEDURE cat.spCargaDimensionCohorte
    @tabla_staging VARCHAR(100) = 'stg.staging_cohortes',  -- Tabla origen
    @id_ejecucion UNIQUEIDENTIFIER = NULL                   -- Correlacion log
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @fecha_proceso DATETIME = GETDATE();
    DECLARE @registros_nuevos INT = 0;
    DECLARE @registros_actualizados INT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- PASO 1: Detectar nuevos registros
        INSERT INTO cat.dim_cohortes_enriquecida (
            codigo_cohorte, fecha_inicio, fecha_fin, estado_cohorte,
            anyo_cohorte, semestre_cohorte, 
            fecha_inicio_vigencia, registro_actual, version_registro
        )
        SELECT 
            stg.codigo_cohorte,
            stg.fecha_inicio,
            DATEADD(MONTH, 6, stg.fecha_inicio) AS fecha_fin,
            ISNULL(stg.estado_cohorte, 'ACTIVA'),
            YEAR(stg.fecha_inicio),
            stg.semestre_cohorte,
            @fecha_proceso,
            1,  -- registro_actual
            1   -- version_registro (primera version)
        FROM stg.staging_cohortes stg
        LEFT JOIN cat.dim_cohortes_enriquecida dim 
            ON stg.codigo_cohorte = dim.codigo_cohorte 
            AND dim.registro_actual = 1
        WHERE dim.id_cohorte_sk IS NULL;  -- Solo si no existe
        
        SET @registros_nuevos = @@ROWCOUNT;
        
        -- PASO 2: Detectar cambios (SCD Type 2)
        -- Cerrar registros old
        UPDATE dim
        SET fecha_fin_vigencia = @fecha_proceso,
            registro_actual = 0
        FROM cat.dim_cohortes_enriquecida dim
        INNER JOIN stg.staging_cohortes stg
            ON dim.codigo_cohorte = stg.codigo_cohorte
            AND dim.registro_actual = 1
        WHERE dim.estado_cohorte <> ISNULL(stg.estado_cohorte, 'ACTIVA');  -- Cambio detectado
        
        -- Insertar registros new
        INSERT INTO cat.dim_cohortes_enriquecida (
            codigo_cohorte, fecha_inicio, fecha_fin, estado_cohorte,
            anyo_cohorte, semestre_cohorte,
            fecha_inicio_vigencia, registro_actual, version_registro
        )
        SELECT 
            stg.codigo_cohorte,
            stg.fecha_inicio,
            DATEADD(MONTH, 6, stg.fecha_inicio),
            ISNULL(stg.estado_cohorte, 'ACTIVA'),
            YEAR(stg.fecha_inicio),
            stg.semestre_cohorte,
            @fecha_proceso,
            1,
            (SELECT MAX(version_registro) FROM cat.dim_cohortes_enriquecida WHERE codigo_cohorte = stg.codigo_cohorte) + 1
        FROM stg.staging_cohortes stg
        INNER JOIN cat.dim_cohortes_enriquecida dim
            ON stg.codigo_cohorte = dim.codigo_cohorte
            AND dim.fecha_fin_vigencia = @fecha_proceso;  -- Solo los que acabamos de cerrar
        
        SET @registros_actualizados = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        -- Log de resultado
        PRINT 'Carga completada: ' + CAST(@registros_nuevos AS VARCHAR) + ' nuevos, ' 
              + CAST(@registros_actualizados AS VARCHAR) + ' actualizados';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @error_msg VARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en carga dimension cohortes: %s', 16, 1, @error_msg);
    END CATCH
END;
GO
*/

-- ===========================================================================
-- CONSULTAS DE VALIDACION
-- ===========================================================================

-- Validar SCD Type 2: Historial de cambios
/*
SELECT 
    codigo_cohorte,
    version_registro,
    estado_cohorte,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    registro_actual
FROM cat.dim_cohortes_enriquecida
WHERE codigo_cohorte = '2024-1'
ORDER BY version_registro;
*/

-- Validar jerarquia temporal
/*
SELECT 
    anyo_cohorte,
    semestre_cohorte,
    COUNT(DISTINCT codigo_cohorte) AS cohortes_count,
    MIN(fecha_inicio) AS primer_cohorte,
    MAX(fecha_inicio) AS ultimo_cohorte
FROM cat.dim_cohortes_enriquecida
WHERE registro_actual = 1
GROUP BY anyo_cohorte, semestre_cohorte
ORDER BY anyo_cohorte DESC, semestre_cohorte;
*/

-- Validar integridad con hechos
/*
SELECT 
    COUNT(*) AS hechos_huerfanos
FROM mat.hechos_matricula hm
LEFT JOIN cat.dim_cohortes_enriquecida dc 
    ON hm.id_cohorte = dc.id_cohorte_sk 
    AND dc.registro_actual = 1
WHERE dc.id_cohorte_sk IS NULL;
*/

/*
================================================================================
CRITERIOS DE EVALUACION:

[25pts] CREATE TABLE con estructura completa (20+ columnas)
        - Surrogate key, natural key, atributos calculados
        - Columnas SCD Type 2 (vigencia, registro_actual, version)
        - Indices apropiados (codigo, anyo-semestre, vigencia)
        
[35pts] STORED PROCEDURE con logica SCD Type 2
        - Deteccion de nuevos registros (LEFT JOIN staging)
        - Cierre de registros old (UPDATE fecha_fin_vigencia)
        - Insercion de registros new (version+1)
        - Manejo de errores con TRY/CATCH
        
[20pts] CONSULTAS QA para validar:
        - Historial de versiones (GROUP BY codigo_cohorte)
        - Volumetria por anyo-semestre
        - Integridad con hechos_matricula
        
[20pts] DOCUMENTACION en SOLUTION.md:
        - Diagrama de jerarquia temporal
        - Justificacion SCD Type 2 vs Type 1
        - Estrategia para cambios en atributos descriptivos
        - Impacto en reportes SSAS/Power BI

DATOS DE PRUEBA SUGERIDOS:
INSERT stg.staging_cohortes VALUES 
('2024-1', '2024-03-01', '1', 'ACTIVA'),
('2024-2', '2024-08-01', '2', 'ACTIVA'),
('2025-V', '2025-01-15', 'V', 'ACTIVA');

-- Cambio: Cerrar cohorte 2024-1
UPDATE stg.staging_cohortes SET estado_cohorte = 'CERRADA' WHERE codigo_cohorte = '2024-1';
EXEC cat.spCargaDimensionCohorte;

-- Validar: Debe haber 2 registros para 2024-1 (version 1 y 2)
================================================================================
*/
