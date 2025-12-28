/*
================================================================================
  SCRIPT: LOAD_Basic_TestData.sql
  PROPÓSITO: Cargar datos básicos de prueba para evaluación
  AUTOR: BI Team
  FECHA: Diciembre 2025
================================================================================
*/

USE SchoolERP_Source;
GO

PRINT '═════════════════════════════════════════════════════════'
PRINT 'Cargando datos básicos en SchoolERP_Source...'
PRINT '═════════════════════════════════════════════════════════'
GO

-- ============================================================================
-- 1. Insertar términos académicos
-- ============================================================================

INSERT INTO dbo.erp_term_catalog (term_code, term_name, term_year, term_sequence, start_date, end_date, is_active)
SELECT 
    '202501' AS term_code, 'Semestre 2025-I' AS term_name, 2025 AS term_year, 1 AS term_sequence,
    '2025-01-01' AS start_date, '2025-04-30' AS end_date, 1 AS is_active
UNION ALL SELECT '202502', 'Semestre 2025-II', 2025, 2, '2025-05-01', '2025-08-31', 1
UNION ALL SELECT '202503', 'Semestre 2025-III', 2025, 3, '2025-09-01', '2025-12-31', 0
UNION ALL SELECT '202401', 'Semestre 2024-I', 2024, 1, '2024-01-01', '2024-04-30', 0
UNION ALL SELECT '202402', 'Semestre 2024-II', 2024, 2, '2024-05-01', '2024-08-31', 0
UNION ALL SELECT '202403', 'Semestre 2024-III', 2024, 3, '2024-09-01', '2024-12-31', 0;

PRINT 'Términos insertados: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- ============================================================================
-- 2. Insertar personas ERP (100 básicas para prueba)
-- ============================================================================

INSERT INTO dbo.erp_person_identity 
(pidm, first_name, middle_name, last_name, birth_date, activity_date, name_change_indicator)
VALUES
(1, 'Juan', 'Carlos', 'García', '1990-01-15', '2025-01-01', NULL),
(2, 'María', 'Rosa', 'López', '1991-02-20', '2025-01-01', NULL),
(3, 'Carlos', 'Luis', 'Rodríguez', '1989-03-10', '2025-01-01', NULL),
(4, 'Ana', 'Sofia', 'Martínez', '1992-04-05', '2025-01-01', NULL),
(5, 'Pedro', 'Diego', 'Sánchez', '1988-05-25', '2025-01-01', NULL),
(6, 'Rosa', 'Carmen', 'Torres', '1993-06-30', '2025-01-01', NULL),
(7, 'Luis', 'Juan', 'Rivera', '1987-07-15', '2025-01-01', NULL),
(8, 'Sofia', 'Patricia', 'Morales', '1994-08-20', '2025-01-01', NULL),
(9, 'Diego', 'Roberto', 'Vargas', '1991-09-10', '2025-01-01', NULL),
(10, 'Carmen', 'Marta', 'Flores', '1990-10-05', '2025-01-01', NULL);

PRINT 'Personas insertadas: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- ============================================================================
-- 3. Insertar curriculum estudiante (30 registros)
-- ============================================================================

INSERT INTO dbo.erp_student_curriculum
(pidm, term_code, program_code, program_name, priority_no, key_seqno, enrollment_date, activity_date)
VALUES
(1, '202501', 'BIS001', 'Ingeniería en Sistemas', 1, 1, '2025-01-02', '2025-01-01'),
(2, '202501', 'BIC001', 'Ingeniería Comercial', 1, 1, '2025-01-02', '2025-01-01'),
(3, '202501', 'BCN001', 'Contabilidad', 1, 1, '2025-01-02', '2025-01-01'),
(4, '202501', 'BAD001', 'Administración', 1, 1, '2025-01-02', '2025-01-01'),
(5, '202501', 'BDC001', 'Derecho', 1, 1, '2025-01-02', '2025-01-01'),
(1, '202401', 'BIS001', 'Ingeniería en Sistemas', 1, 1, '2024-01-02', '2024-01-01'),
(2, '202402', 'BIC001', 'Ingeniería Comercial', 2, 1, '2024-05-02', '2024-05-01'),
(3, '202402', 'BAR001', 'Arquitectura', 1, 1, '2024-05-02', '2024-05-01'),
(4, '202403', 'BAD001', 'Administración', 1, 1, '2024-09-02', '2024-09-01'),
(5, '202401', 'BDC001', 'Derecho', 2, 1, '2024-01-02', '2024-01-01');

PRINT 'Curriculum insertado: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- ============================================================================
-- Resumen
-- ============================================================================

PRINT ''
PRINT '═════════════════════════════════════════════════════════'
PRINT '✓ Datos básicos cargados exitosamente en SchoolERP_Source'
PRINT '═════════════════════════════════════════════════════════'
PRINT ''

SELECT 
    'erp_person_identity' AS Tabla,
    COUNT(*) AS TotalRegistros
FROM dbo.erp_person_identity
UNION ALL
SELECT 'erp_student_curriculum', COUNT(*) FROM dbo.erp_student_curriculum
UNION ALL
SELECT 'erp_term_catalog', COUNT(*) FROM dbo.erp_term_catalog;
GO
