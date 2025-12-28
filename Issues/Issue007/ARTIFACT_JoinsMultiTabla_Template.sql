/*
================================================================================
ARCHIVO: ARTIFACT_JoinsMultiTabla_Template.sql
DESCRIPCION: Plantilla para joins complejos con precedencia (Issue 007)
AUTOR: Sistema
FECHA: 2025-01-15
PROYECTO: BI Technical Assessment
ISSUE: Issue007 - Complex Multi-Table Joins with Precedence Rules

PROPOSITO:
- Demostrar patron de joins entre ERP source tables con reglas de precedencia
- Proveer estructura base para consulta de trayectoria academica completa
- Ilustrar uso de CTEs, ROW_NUMBER(), y COALESCE para consolidacion

CONTEXTO:
Para generar reporte de "Trayectoria Estudiantil Completa", se necesita:
1. Identidad mas reciente (erp_person_identity con precedencia)
2. Curriculos activos (erp_student_curriculum por term + priority)
3. Terminos academicos (erp_term_catalog con fechas)

Desafio: Un estudiante puede tener:
- Multiples identidades (cambio nombre) -> usar mas reciente
- Multiples curriculos por termino (doble titulacion) -> usar priority_no
- Multiples terminos (historico) -> ordenar por term_code DESC

TAREAS DEL CANDIDATO:
1. Analizar consulta baseline y entender relaciones entre tablas
2. Crear VIEW_TrayectoriaEstudiantil.sql con:
   - CTE para identidad vigente (ROW_NUMBER por activity_date)
   - CTE para curriculum activo (MAX priority_no por pidm+term)
   - JOIN a terminos para enriquecer con fechas
   - Calculo de metricas: terminos_cursados, promedio_priority, rango_fechas
3. Crear PROC_GenerarReporteTrayectoria.sql para:
   - INPUT: @pidm (opcional, NULL = todos)
   - OUTPUT: Tabla con columnas: pidm, nombre, termino, programa, priority, fechas
   - Filtros: Solo terminos activos (status='ACTIVE')
   - Ordenamiento: Por pidm, luego term_code DESC (mas reciente primero)
4. Crear TEST_JoinsComplejos.sql con validaciones:
   - Estudiante con 2 curriculos en mismo termino (usar priority)
   - Estudiante con cambio de nombre (usar activity_date)
   - Volumetria correcta (N estudiantes -> N*M registros terminos)
5. Documentar estrategia en SOLUTION.md (300-400 palabras)

METRICAS ESPERADAS:
- Vista debe retornar 1 registro por (pidm + term_code)
- Join debe preservar todos los terminos (LEFT JOIN si es necesario)
- Priority mas alto (MAX) debe usarse como desempate
================================================================================
*/

USE SchoolERP_Source;
GO

-- ===========================================================================
-- CONTEXTO: Relaciones entre tablas
-- ===========================================================================

/*
DIAGRAMA RELACIONAL:

erp_person_identity (1:N con erp_student_curriculum)
    pidm (PK natural) --> erp_student_curriculum.pidm (FK)
    activity_date, person_surrogate_id (precedencia)

erp_student_curriculum (1:N con erp_term_catalog)
    curriculum_term_code (FK) --> erp_term_catalog.term_code (PK)
    curriculum_priority_no (precedencia: mas alto = mas reciente)

erp_term_catalog
    term_code (PK), term_start_date, term_end_date

REGLAS DE PRECEDENCIA:
1. Identidad: activity_date DESC, person_surrogate_id DESC (mas reciente)
2. Curriculum: curriculum_priority_no DESC (mas alto)
3. Terminos: term_start_date DESC (cronologico)
*/

-- ===========================================================================
-- CONSULTA 1: Identidad vigente (con precedencia)
-- ===========================================================================

WITH identidad_vigente AS (
    SELECT 
        pidm,
        person_surrogate_id,
        full_name,
        national_id,
        email_address,
        activity_date,
        ROW_NUMBER() OVER (
            PARTITION BY pidm 
            ORDER BY activity_date DESC, person_surrogate_id DESC
        ) AS rn
    FROM dbo.erp_person_identity
)
SELECT 
    pidm,
    full_name AS nombre_vigente,
    national_id,
    email_address,
    activity_date AS fecha_ultima_actualizacion
FROM identidad_vigente
WHERE rn = 1  -- Solo el mas reciente
ORDER BY pidm;

-- ===========================================================================
-- CONSULTA 2: Curriculum activo (con priority)
-- ===========================================================================

-- Opcion A: Max priority por term (un solo curriculum por term)
SELECT 
    cur.pidm,
    cur.curriculum_term_code,
    cur.curriculum_program_code,
    cur.curriculum_priority_no,
    ter.term_start_date,
    ter.term_end_date
FROM dbo.erp_student_curriculum cur
INNER JOIN (
    -- Subconsulta: Obtener max priority por pidm+term
    SELECT 
        pidm,
        curriculum_term_code,
        MAX(curriculum_priority_no) AS max_priority
    FROM dbo.erp_student_curriculum
    GROUP BY pidm, curriculum_term_code
) max_cur ON cur.pidm = max_cur.pidm 
          AND cur.curriculum_term_code = max_cur.curriculum_term_code
          AND cur.curriculum_priority_no = max_cur.max_priority
LEFT JOIN dbo.erp_term_catalog ter ON cur.curriculum_term_code = ter.term_code
ORDER BY cur.pidm, cur.curriculum_term_code DESC;

-- Opcion B: Todos los curriculos (permitir multiples programas)
SELECT 
    cur.pidm,
    cur.curriculum_term_code,
    cur.curriculum_program_code,
    cur.curriculum_priority_no,
    ter.term_start_date,
    ter.term_end_date,
    ROW_NUMBER() OVER (
        PARTITION BY cur.pidm, cur.curriculum_term_code 
        ORDER BY cur.curriculum_priority_no DESC
    ) AS curriculum_rank
FROM dbo.erp_student_curriculum cur
LEFT JOIN dbo.erp_term_catalog ter ON cur.curriculum_term_code = ter.term_code
ORDER BY cur.pidm, cur.curriculum_term_code DESC, curriculum_rank;

-- ===========================================================================
-- CONSULTA 3: Trayectoria completa (join 3 tablas)
-- ===========================================================================

WITH identidad_vigente AS (
    SELECT 
        pidm,
        full_name,
        national_id,
        ROW_NUMBER() OVER (
            PARTITION BY pidm 
            ORDER BY activity_date DESC, person_surrogate_id DESC
        ) AS rn
    FROM dbo.erp_person_identity
),
curriculum_consolidado AS (
    SELECT 
        cur.pidm,
        cur.curriculum_term_code,
        cur.curriculum_program_code,
        cur.curriculum_priority_no,
        cur.curriculum_key_seqno,
        ROW_NUMBER() OVER (
            PARTITION BY cur.pidm, cur.curriculum_term_code 
            ORDER BY cur.curriculum_priority_no DESC, cur.curriculum_key_seqno DESC
        ) AS curriculum_rank
    FROM dbo.erp_student_curriculum cur
)
SELECT 
    ident.pidm,
    ident.full_name AS nombre_estudiante,
    ident.national_id AS documento,
    curr.curriculum_term_code AS termino,
    curr.curriculum_program_code AS programa,
    curr.curriculum_priority_no AS prioridad,
    ter.term_start_date AS fecha_inicio_termino,
    ter.term_end_date AS fecha_fin_termino,
    DATEDIFF(DAY, ter.term_start_date, ter.term_end_date) AS duracion_dias
FROM identidad_vigente ident
INNER JOIN curriculum_consolidado curr ON ident.pidm = curr.pidm AND curr.curriculum_rank = 1
LEFT JOIN dbo.erp_term_catalog ter ON curr.curriculum_term_code = ter.term_code
WHERE ident.rn = 1  -- Solo identidad vigente
ORDER BY ident.pidm, curr.curriculum_term_code DESC;

/*
RESULTADO ESPERADO:
- 1 registro por (pidm + term_code)
- full_name es el mas reciente (activity_date DESC)
- curriculum_program_code es el de mayor priority
- Todos los terminos del estudiante incluidos (historico completo)
*/

-- ===========================================================================
-- CONSULTA 4: Estadisticas de trayectoria
-- ===========================================================================

WITH trayectoria AS (
    SELECT 
        ident.pidm,
        ident.full_name,
        COUNT(DISTINCT curr.curriculum_term_code) AS terminos_cursados,
        MIN(ter.term_start_date) AS fecha_primer_termino,
        MAX(ter.term_end_date) AS fecha_ultimo_termino,
        COUNT(DISTINCT curr.curriculum_program_code) AS programas_distintos,
        AVG(CAST(curr.curriculum_priority_no AS FLOAT)) AS prioridad_promedio
    FROM (
        SELECT pidm, full_name, 
               ROW_NUMBER() OVER (PARTITION BY pidm ORDER BY activity_date DESC) AS rn
        FROM dbo.erp_person_identity
    ) ident
    INNER JOIN dbo.erp_student_curriculum curr ON ident.pidm = curr.pidm
    LEFT JOIN dbo.erp_term_catalog ter ON curr.curriculum_term_code = ter.term_code
    WHERE ident.rn = 1
    GROUP BY ident.pidm, ident.full_name
)
SELECT 
    pidm,
    full_name,
    terminos_cursados,
    programas_distintos,
    fecha_primer_termino,
    fecha_ultimo_termino,
    DATEDIFF(MONTH, fecha_primer_termino, fecha_ultimo_termino) AS duracion_meses,
    prioridad_promedio
FROM trayectoria
ORDER BY terminos_cursados DESC, pidm;

/*
METRICAS CLAVE:
- terminos_cursados: Total de terminos registrados (historico)
- programas_distintos: Cambios de carrera o doble titulacion
- duracion_meses: Tiempo entre primer y ultimo termino
- prioridad_promedio: Indica estabilidad curricular (bajo = estable)
*/

-- ===========================================================================
-- CONSULTA 5: Casos edge - Validacion de joins
-- ===========================================================================

-- Caso 1: Estudiantes con multiples curriculos en mismo termino
SELECT 
    pidm,
    curriculum_term_code,
    COUNT(*) AS curriculos_en_termino,
    STRING_AGG(curriculum_program_code, ', ') AS programas
FROM dbo.erp_student_curriculum
GROUP BY pidm, curriculum_term_code
HAVING COUNT(*) > 1
ORDER BY pidm, curriculum_term_code;

-- Caso 2: Curriculos sin termino en catalogo (FK huerfano)
SELECT 
    cur.pidm,
    cur.curriculum_term_code,
    cur.curriculum_program_code
FROM dbo.erp_student_curriculum cur
LEFT JOIN dbo.erp_term_catalog ter ON cur.curriculum_term_code = ter.term_code
WHERE ter.term_code IS NULL;

-- Caso 3: Identidades sin curriculos (estudiantes sin inscripcion)
SELECT 
    ident.pidm,
    ident.full_name,
    ident.activity_date
FROM (
    SELECT pidm, full_name, activity_date,
           ROW_NUMBER() OVER (PARTITION BY pidm ORDER BY activity_date DESC) AS rn
    FROM dbo.erp_person_identity
) ident
LEFT JOIN dbo.erp_student_curriculum cur ON ident.pidm = cur.pidm
WHERE ident.rn = 1 AND cur.pidm IS NULL;

-- ===========================================================================
-- STORED PROCEDURE: Reporte trayectoria
-- ===========================================================================

/*
CREATE OR ALTER PROCEDURE dbo.spGenerarReporteTrayectoria
    @pidm INT = NULL,  -- NULL = todos los estudiantes
    @fecha_desde DATE = NULL,  -- Filtro por fecha inicio termino
    @fecha_hasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    WITH identidad_vigente AS (
        SELECT 
            pidm, full_name, national_id, email_address,
            ROW_NUMBER() OVER (PARTITION BY pidm ORDER BY activity_date DESC, person_surrogate_id DESC) AS rn
        FROM dbo.erp_person_identity
        WHERE (@pidm IS NULL OR pidm = @pidm)  -- Filtro opcional
    ),
    curriculum_priorizado AS (
        SELECT 
            pidm, curriculum_term_code, curriculum_program_code, curriculum_priority_no,
            ROW_NUMBER() OVER (PARTITION BY pidm, curriculum_term_code ORDER BY curriculum_priority_no DESC) AS rn
        FROM dbo.erp_student_curriculum
    )
    SELECT 
        ident.pidm,
        ident.full_name AS nombre_estudiante,
        ident.national_id AS documento_identidad,
        ident.email_address AS email,
        curr.curriculum_term_code AS codigo_termino,
        ter.term_start_date AS fecha_inicio,
        ter.term_end_date AS fecha_fin,
        curr.curriculum_program_code AS codigo_programa,
        curr.curriculum_priority_no AS prioridad_curriculum,
        CASE 
            WHEN ter.term_end_date < GETDATE() THEN 'FINALIZADO'
            WHEN ter.term_start_date > GETDATE() THEN 'FUTURO'
            ELSE 'EN_CURSO'
        END AS estado_termino
    FROM identidad_vigente ident
    INNER JOIN curriculum_priorizado curr 
        ON ident.pidm = curr.pidm AND curr.rn = 1
    LEFT JOIN dbo.erp_term_catalog ter 
        ON curr.curriculum_term_code = ter.term_code
    WHERE ident.rn = 1
        AND (@fecha_desde IS NULL OR ter.term_start_date >= @fecha_desde)
        AND (@fecha_hasta IS NULL OR ter.term_end_date <= @fecha_hasta)
    ORDER BY ident.pidm, curr.curriculum_term_code DESC;
END;
GO
*/

-- Ejemplos de ejecucion:
/*
-- Todos los estudiantes
EXEC dbo.spGenerarReporteTrayectoria;

-- Estudiante especifico
EXEC dbo.spGenerarReporteTrayectoria @pidm = 1;

-- Terminos entre fechas
EXEC dbo.spGenerarReporteTrayectoria 
    @fecha_desde = '2024-01-01', 
    @fecha_hasta = '2024-12-31';
*/

/*
================================================================================
CRITERIOS DE EVALUACION:

[30pts] Vista de trayectoria con joins correctos
        - CTEs para identidad vigente y curriculum priorizado
        - JOIN apropiado (INNER vs LEFT segun caso)
        - ROW_NUMBER() con ORDER BY correcto (precedencia)
        - 1 registro por (pidm + term_code) garantizado
        
[30pts] Stored procedure con parametros opcionales
        - @pidm opcional (NULL = todos)
        - Filtros de fecha implementados
        - Estado termino calculado (FINALIZADO/EN_CURSO/FUTURO)
        - Ordenamiento correcto (pidm, term_code DESC)
        
[25pts] Tests de casos edge
        - Multiples curriculos en mismo termino (validar priority)
        - Cambio de nombre (validar activity_date)
        - FK huerfanos (curriculum sin termino)
        - Volumetria (N estudiantes -> N*M registros)
        
[15pts] Documentacion en SOLUTION.md
        - Diagrama de relaciones (ERD simplificado)
        - Justificacion INNER vs LEFT JOIN por tabla
        - Estrategia de precedencia (activity_date > surrogate_id > priority)
        - Ejemplos de queries de negocio (tasa retencion, cambios carrera)

DATOS DE PRUEBA:
-- Simular doble curriculum en mismo termino
INSERT INTO dbo.erp_student_curriculum VALUES 
(1, '202501', 'ING-INFO', 1, 1, GETDATE()),  -- Prioridad baja
(1, '202501', 'ING-CIVIL', 2, 2, GETDATE()); -- Prioridad alta (ganador)

-- Ejecutar SP
EXEC dbo.spGenerarReporteTrayectoria @pidm = 1;

-- Validar: Solo aparece ING-CIVIL para term 202501
================================================================================
*/
