/*
================================================================================
  SCRIPT: LOAD_Curriculum_Data.sql
  PROPÓSITO: Insertar curriculum de estudiantes
================================================================================
*/

USE SchoolERP_Source;
GO

INSERT INTO dbo.erp_student_curriculum
(pidm, term_code, program_code, program_name, priority_no, key_seqno, enrollment_date, activity_date)
VALUES
(1, '202501', 'BIS001', 'Ingeniería en Sistemas', 1, 1, '2025-01-01', '2025-01-01'),
(2, '202501', 'BIC001', 'Ingeniería Comercial', 1, 1, '2025-01-01', '2025-01-01'),
(3, '202501', 'BCN001', 'Contabilidad', 1, 1, '2025-01-01', '2025-01-01'),
(4, '202501', 'BAD001', 'Administración', 1, 1, '2025-01-01', '2025-01-01'),
(5, '202501', 'BDC001', 'Derecho', 1, 1, '2025-01-01', '2025-01-01'),
(1, '202401', 'BIS001', 'Ingeniería en Sistemas', 1, 1, '2024-01-01', '2024-01-01'),
(2, '202402', 'BIC001', 'Ingeniería Comercial', 2, 1, '2024-05-01', '2024-05-01'),
(3, '202402', 'BAR001', 'Arquitectura', 1, 1, '2024-05-01', '2024-05-01'),
(4, '202403', 'BAD001', 'Administración', 1, 1, '2024-09-01', '2024-09-01'),
(5, '202401', 'BDC001', 'Derecho', 2, 1, '2024-01-01', '2024-01-01');

PRINT 'Curriculum insertado: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO
