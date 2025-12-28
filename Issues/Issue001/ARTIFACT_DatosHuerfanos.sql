/*
================================================================================
ARCHIVO: ARTIFACT_DatosHuerfanos.sql
DESCRIPCION: Datos de referencia para Issue 001 - Validacion de Integridad
AUTOR: Sistema
FECHA: 2025-01-15
PROYECTO: BI Technical Assessment
ISSUE: Issue001 - Data Integrity Validation

PROPOSITO:
- Proveer consulta para identificar registros huerfanos en hechos_matricula
- Servir como baseline para que candidatos creen stored procedure de validacion
- Demostrar el problema de integridad referencial que se debe resolver

CONTEXTO:
Durante la carga inicial se insertaron 15 registros con id_estudiante invalidos
(99999 a 99985) que no existen en cat.dim_estudiantes. Esta es una situacion
realista que debe detectarse y prevenirse en ETLs de produccion.

TAREAS DEL CANDIDATO:
1. Analizar esta consulta y entender el patron de FK huerfanos
2. Crear QA_ValidarIntegridadEstudiantes.sql con deteccion avanzada
3. Crear PROC_ValidarIntegridadPreInsert.sql para prevenir inserts invalidos
4. Documentar estrategia en SOLUTION.md (200-300 palabras)

METRICAS ESPERADAS:
- Consulta actual debe retornar 15 registros huerfanos
- FK huerfanos estan en rango id_estudiante 99985-99999
- Cada registro huerfano debe tener valores validos en otras dimensiones
================================================================================
*/

USE BI_Assessment_DWH;
GO

-- ===========================================================================
-- CONSULTA 1: Identificar FK huerfanos en hechos_matricula
-- ===========================================================================

SELECT 
    hm.id_matricula,
    hm.id_estudiante,
    hm.id_termino,
    hm.id_programa,
    hm.id_cohorte,
    hm.monto_matricula,
    hm.fecha_matricula,
    'HUERFANO: id_estudiante no existe' AS problema
FROM mat.hechos_matricula hm
LEFT JOIN cat.dim_estudiantes de ON hm.id_estudiante = de.id_estudiante
WHERE de.id_estudiante IS NULL;

-- ===========================================================================
-- CONSULTA 2: Estadisticas de integridad
-- ===========================================================================

SELECT 
    COUNT(*) AS total_registros,
    SUM(CASE WHEN de.id_estudiante IS NULL THEN 1 ELSE 0 END) AS huerfanos_estudiante,
    SUM(CASE WHEN dt.id_termino IS NULL THEN 1 ELSE 0 END) AS huerfanos_termino,
    SUM(CASE WHEN dp.id_programa IS NULL THEN 1 ELSE 0 END) AS huerfanos_programa,
    SUM(CASE WHEN dc.id_cohorte IS NULL THEN 1 ELSE 0 END) AS huerfanos_cohorte,
    CAST(SUM(CASE WHEN de.id_estudiante IS NULL THEN 1.0 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS porcentaje_huerfanos
FROM mat.hechos_matricula hm
LEFT JOIN cat.dim_estudiantes de ON hm.id_estudiante = de.id_estudiante
LEFT JOIN cat.dim_terminos dt ON hm.id_termino = dt.id_termino
LEFT JOIN cat.dim_programas dp ON hm.id_programa = dp.id_programa
LEFT JOIN cat.dim_cohortes dc ON hm.id_cohorte = dc.id_cohorte;

-- ===========================================================================
-- CONSULTA 3: Perfil de IDs huerfanos (patron de generacion)
-- ===========================================================================

SELECT 
    hm.id_estudiante,
    COUNT(*) AS ocurrencias
FROM mat.hechos_matricula hm
LEFT JOIN cat.dim_estudiantes de ON hm.id_estudiante = de.id_estudiante
WHERE de.id_estudiante IS NULL
GROUP BY hm.id_estudiante
ORDER BY hm.id_estudiante DESC;

-- ===========================================================================
-- CONSULTA 4: Impacto en reportes (joins con dimensiones)
-- ===========================================================================

-- Esta consulta simula un reporte tipico que fallaria con datos huerfanos
SELECT 
    de.nombre_completo AS estudiante,
    dt.codigo_termino AS termino,
    dp.nombre_programa AS programa,
    dc.codigo_cohorte AS cohorte,
    hm.monto_matricula
FROM mat.hechos_matricula hm
INNER JOIN cat.dim_estudiantes de ON hm.id_estudiante = de.id_estudiante
INNER JOIN cat.dim_terminos dt ON hm.id_termino = dt.id_termino
INNER JOIN cat.dim_programas dp ON hm.id_programa = dp.id_programa
INNER JOIN cat.dim_cohortes dc ON hm.id_cohorte = dc.id_cohorte
WHERE hm.id_estudiante > 99980; -- Este filtro NO retornaria registros huerfanos

-- ===========================================================================
-- CONSULTA 5: Verificacion de FKs reales (metadata)
-- ===========================================================================

-- Nota: En este baseline NO existen FKs fisicos para permitir la carga
-- El candidato debe implementar validacion logica via SP

SELECT 
    fk.name AS nombre_fk,
    tp.name AS tabla_padre,
    tr.name AS tabla_referenciada,
    fk.is_disabled
FROM sys.foreign_keys fk
INNER JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
INNER JOIN sys.tables tr ON fk.referenced_object_id = tr.object_id
WHERE tp.name = 'hechos_matricula'
    AND SCHEMA_NAME(tp.schema_id) = 'mat';

/*
================================================================================
RESULTADOS ESPERADOS:

CONSULTA 1: 15 registros con id_estudiante entre 99985-99999
CONSULTA 2: total_registros > 15, huerfanos_estudiante = 15, otros = 0
CONSULTA 3: 15 filas con id_estudiante desc (99999, 99998, ..., 99985)
CONSULTA 4: 0 registros (INNER JOIN filtra huerfanos)
CONSULTA 5: 0 FKs (no hay constraints fisicos)

ESTRATEGIA DE SOLUCION SUGERIDA:
1. Crear tabla de log: cat.log_validacion_integridad
2. SP de validacion: mat.spValidarIntegridadPreInsert
   - INPUT: @id_estudiante, @id_termino, @id_programa, @id_cohorte
   - OUTPUT: @resultado BIT (0=invalido, 1=valido), @mensaje VARCHAR(500)
   - LOGICA: Verificar EXISTS en cada dimension, registrar en log
3. Integrar SP en ETL: Llamar antes de cada INSERT/UPDATE
4. Documentar: Diagrama de flujo, casos edge, metricas de rendimiento

METRICAS DE EVALUACION:
- [25pts] QA detecta los 15 huerfanos correctamente
- [35pts] SP previene nuevos inserts invalidos con TRY/CATCH
- [20pts] Log de validacion registra fecha, usuario, resultado
- [20pts] Documentacion incluye diagrama y estrategia de remediacion
================================================================================
*/
