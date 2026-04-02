-- ============================================================================
-- Query: Validar Integridad Estudiantes 
-- Propósito: Identificar registros en hechos sin correspondencia en dimensiones.
-- Autor: Luis Enrique Lopez Zapata
-- Fecha: 2026-04-02
-- ============================================================================

USE BI_Assessment_DWH;
GO

-- 1. Contador de FK huérfanos (Resultado esperado: 15)
SELECT 
    COUNT(f.id_hecho_matricula) AS total_huerfanos,
    'hechos_matricula' AS tabla_afectada
FROM mat.hechos_matricula f
LEFT JOIN cat.dim_estudiantes d ON f.id_estudiante = d.id_estudiante
WHERE d.id_estudiante IS NULL;

-- 2. Detalle de los registros afectados usando nombres de columna originales
SELECT TOP 100
    f.id_hecho_matricula,
    f.id_estudiante,
    f.fecha_matricula,
    f.es_vigente, -- Nombre de columna original según tu esquema
    d.id_estudiante AS existe_en_dim 
FROM mat.hechos_matricula f
LEFT JOIN cat.dim_estudiantes d ON f.id_estudiante = d.id_estudiante
WHERE d.id_estudiante IS NULL
ORDER BY f.id_estudiante DESC;