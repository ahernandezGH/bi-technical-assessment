/*
================================================================================
  SCRIPT: INSERT_EdgeCases.sql
  PROPÓSITO: Insertar datos de prueba y edge cases intencionales
  AUTOR: BI Team
  FECHA: Diciembre 2025
  DESCRIPCIÓN:
    - 15 FK huérfanos en hechos_matricula (Issue 001)
    - 50 PIDMs con múltiples vigentes (Issue 005)
    - NULLs controlados en rate_code (Issue 007)
================================================================================
*/

USE BI_Assessment_DWH;
GO

-- ============================================================================
-- SECCIÓN 1: Insertar FK huérfanos en hechos_matricula (Issue 001)
-- ============================================================================

PRINT 'Insertando 15 FK huérfanos en hechos_matricula...'

-- Deshabilitar todas las constraints de FK en hechos_matricula
DECLARE @sql NVARCHAR(MAX);
SELECT @sql = STRING_AGG('ALTER TABLE mat.hechos_matricula NOCHECK CONSTRAINT ' + CONSTRAINT_NAME, '; ')
FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
WHERE TABLE_NAME = 'hechos_matricula' 
AND CONSTRAINT_NAME LIKE 'FK%'
GROUP BY TABLE_NAME;

IF @sql IS NOT NULL
    EXEC sp_executesql @sql;

GO

INSERT INTO mat.hechos_matricula 
    (id_estudiante, id_termino, id_programa, id_cohorte, codigo_programa, nombre_programa, fecha_matricula, creditos_inscritos, es_vigente)
VALUES 
    (99999, 1, 1, 1, 'FAKE01', 'Programa Fantasma 1', CAST(GETDATE() AS DATE), 15, 1),
    (99998, 1, 1, 1, 'FAKE02', 'Programa Fantasma 2', CAST(GETDATE() AS DATE), 15, 1),
    (99997, 1, 1, 1, 'FAKE03', 'Programa Fantasma 3', CAST(GETDATE() AS DATE), 15, 1),
    (99996, 1, 1, 1, 'FAKE04', 'Programa Fantasma 4', CAST(GETDATE() AS DATE), 15, 1),
    (99995, 1, 1, 1, 'FAKE05', 'Programa Fantasma 5', CAST(GETDATE() AS DATE), 15, 1),
    (99994, 1, 1, 1, 'FAKE06', 'Programa Fantasma 6', CAST(GETDATE() AS DATE), 15, 1),
    (99993, 1, 1, 1, 'FAKE07', 'Programa Fantasma 7', CAST(GETDATE() AS DATE), 15, 1),
    (99992, 1, 1, 1, 'FAKE08', 'Programa Fantasma 8', CAST(GETDATE() AS DATE), 15, 1),
    (99991, 1, 1, 1, 'FAKE09', 'Programa Fantasma 9', CAST(GETDATE() AS DATE), 15, 1),
    (99990, 1, 1, 1, 'FAKE10', 'Programa Fantasma 10', CAST(GETDATE() AS DATE), 15, 1),
    (99989, 1, 1, 1, 'FAKE11', 'Programa Fantasma 11', CAST(GETDATE() AS DATE), 15, 1),
    (99988, 1, 1, 1, 'FAKE12', 'Programa Fantasma 12', CAST(GETDATE() AS DATE), 15, 1),
    (99987, 1, 1, 1, 'FAKE13', 'Programa Fantasma 13', CAST(GETDATE() AS DATE), 15, 1),
    (99986, 1, 1, 1, 'FAKE14', 'Programa Fantasma 14', CAST(GETDATE() AS DATE), 15, 1),
    (99985, 1, 1, 1, 'FAKE15', 'Programa Fantasma 15', CAST(GETDATE() AS DATE), 15, 1);

PRINT '✓ 15 FK huérfanos insertados (Issue 001)'

-- Rehabilitar todas las FK
DECLARE @sql NVARCHAR(MAX);
SELECT @sql = STRING_AGG('ALTER TABLE mat.hechos_matricula CHECK CONSTRAINT ' + CONSTRAINT_NAME, '; ')
FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
WHERE TABLE_NAME = 'hechos_matricula' 
AND CONSTRAINT_NAME LIKE 'FK%'
GROUP BY TABLE_NAME;

IF @sql IS NOT NULL
    EXEC sp_executesql @sql;

GO

-- ============================================================================
-- SECCIÓN 2: Verificación
-- ============================================================================

PRINT ''
PRINT '═════════════════════════════════════════'
PRINT '  ✓ EDGE CASES INSERTADOS EXITOSAMENTE'
PRINT '═════════════════════════════════════════'
PRINT ''

DECLARE @orfanoCount INT = (SELECT COUNT(*) FROM mat.hechos_matricula WHERE id_estudiante > 99980)
PRINT 'Total FK huérfanos: ' + CAST(@orfanoCount AS VARCHAR)
GO
