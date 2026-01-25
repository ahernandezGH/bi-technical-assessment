/*
================================================================================
SOLUCION - Issue 001
Candidato: AlexHW
Fecha: 2026-01-25
================================================================================
*/

USE BI_Assessment_DWH;
GO

-- Detectar FK huerfanos
SELECT 
    hm.id_hecho_matricula,
    hm.id_estudiante,
    'FK invalido' AS problema
FROM mat.hechos_matricula hm
LEFT JOIN cat.dim_estudiantes de ON hm.id_estudiante = de.id_estudiante
WHERE de.id_estudiante IS NULL;
