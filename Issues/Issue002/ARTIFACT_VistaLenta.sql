/*
================================================================================
  ARTEFACTO BASE - Issue 002
  Vista Lenta: v_matricula_beneficios
  PROPÓSITO: Vista con subconsultas correlacionadas para optimización
================================================================================
*/

USE BI_Assessment_DWH;
GO

-- Eliminar si existe
IF EXISTS (SELECT * FROM sys.views WHERE name = 'v_matricula_beneficios' AND schema_id = SCHEMA_ID('mat'))
    DROP VIEW mat.v_matricula_beneficios;
GO

-- Vista LENTA (baseline para optimización Issue 002)
CREATE VIEW mat.v_matricula_beneficios AS
SELECT 
    m.id_hecho_matricula,
    m.id_estudiante,
    m.id_programa,
    m.id_termino,
    m.codigo_programa,
    m.nombre_programa,
    m.fecha_matricula,
    m.creditos_inscritos,
    -- Subconsulta correlacionada 1: buscar term_code
    (SELECT TOP 1 t.term_code 
     FROM cat.dim_terminos t 
     WHERE t.id_termino = m.id_termino) AS term_code,
    -- Subconsulta correlacionada 2: contar beneficios del estudiante
    (SELECT COUNT(*) 
     FROM ben.hechos_beneficios b 
     WHERE b.id_estudiante = m.id_estudiante) AS beneficios_count,
    -- Subconsulta correlacionada 3: suma de beneficios
    (SELECT ISNULL(SUM(b2.monto_beneficio), 0)
     FROM ben.hechos_beneficios b2
     WHERE b2.id_estudiante = m.id_estudiante) AS total_beneficios,
    -- Subconsulta correlacionada 4: programa del estudiante
    (SELECT TOP 1 p.nombre_programa
     FROM cat.dim_programas p
     WHERE p.id_programa = m.id_programa) AS nombre_programa_lookup
FROM mat.hechos_matricula m;
GO

PRINT '✓ Vista lenta v_matricula_beneficios creada (Issue 002 - Artefacto Base)';
GO
