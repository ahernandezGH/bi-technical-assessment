/*
================================================================================
ARCHIVO: ARTIFACT_ExtraccionMultiVigente.sql
DESCRIPCION: Consultas de referencia para extracciones multi-vigentes (Issue 005)
AUTOR: Sistema
FECHA: 2025-01-15
PROYECTO: BI Technical Assessment
ISSUE: Issue005 - ERP Data Extraction with Multiple Active Records

PROPOSITO:
- Demostrar problema de identidades multi-vigentes en ERP Banner
- Proveer consultas base para diseñar extraccion con precedencia
- Ilustrar patrones ROW_NUMBER() para desduplicacion

CONTEXTO:
En Banner, una persona puede tener multiples registros activos en erp_person_identity:
- Cambio de nombre (matrimonio)
- Correccion de documento
- Actualizacion de contacto

Solo se debe extraer el registro MAS RECIENTE segun precedencia:
1. activity_date (DESC)
2. person_surrogate_id (DESC - ultimo ID generado)

TAREAS DEL CANDIDATO:
1. Analizar consultas baseline y entender patron de vigencia
2. Crear CREATE_VistaExtraccionPersonas.sql con logica:
   - ROW_NUMBER() OVER (PARTITION BY pidm ORDER BY activity_date DESC, person_surrogate_id DESC)
   - Filtro WHERE rn = 1
   - Atributos: pidm, full_name, national_id, email, phone, activity_date
3. Crear PROC_ExtraccionDiferencialPersonas.sql para:
   - Leer solo registros modificados desde ultima extraccion (tabla control)
   - Aplicar precedencia multi-vigente
   - Insertar a stg.staging_personas con auditing
4. Crear TEST_MultiVigencia.sql con casos edge:
   - Persona con 3 registros (1 desactualizado, 2 actuales)
   - Persona con mismo activity_date pero diferente surrogate_id
   - Validar que solo se extraiga 1 registro por pidm
5. Documentar estrategia en SOLUTION.md (300-400 palabras)

METRICAS ESPERADAS:
- Vista debe retornar 1 registro por pidm (20 personas -> 20 registros)
- SP debe detectar cambios desde ultima carga (fecha_ultima_extraccion)
- Tests deben cubrir 100% de casos edge (duplicados, fechas iguales)
================================================================================
*/

USE SchoolERP_Source;
GO

-- ===========================================================================
-- CONTEXTO: Datos de prueba con multi-vigencia
-- ===========================================================================

-- Ejemplo: PIDM 1 tiene 2 registros (cambio de nombre)
/*
SELECT * FROM dbo.erp_person_identity WHERE pidm = 1 ORDER BY activity_date DESC;

Resultado esperado:
pidm | person_surrogate_id | activity_date | full_name           | national_id
-----|---------------------|---------------|---------------------|------------
1    | 1001                | 2025-01-10    | Maria Lopez Garcia  | 12345678-9
1    | 1000                | 2024-03-15    | Maria Lopez         | 12345678-9

-> Solo se debe extraer el registro con person_surrogate_id = 1001 (mas reciente)
*/

-- ===========================================================================
-- CONSULTA 1: Identificar registros multi-vigentes
-- ===========================================================================

SELECT 
    pidm,
    COUNT(*) AS total_registros,
    MAX(activity_date) AS ultima_actualizacion,
    MIN(activity_date) AS primera_actualizacion,
    DATEDIFF(DAY, MIN(activity_date), MAX(activity_date)) AS dias_diferencia
FROM dbo.erp_person_identity
GROUP BY pidm
HAVING COUNT(*) > 1  -- Solo personas con multiples registros
ORDER BY total_registros DESC, pidm;

/*
RESULTADOS ESPERADOS:
- PIDM con 2+ registros (ej: cambio de nombre, correccion documento)
- Diferencia de dias indica frecuencia de actualizaciones
- Maximo esperado: 2-3 registros por persona (raro tener mas)
*/

-- ===========================================================================
-- CONSULTA 2: Patron de extraccion con precedencia
-- ===========================================================================

WITH ranked_identities AS (
    SELECT 
        pidm,
        person_surrogate_id,
        full_name,
        national_id,
        email_address,
        phone_number,
        activity_date,
        -- Ranking por PIDM: primero el mas reciente
        ROW_NUMBER() OVER (
            PARTITION BY pidm 
            ORDER BY activity_date DESC, person_surrogate_id DESC
        ) AS precedencia
    FROM dbo.erp_person_identity
)
SELECT 
    pidm,
    person_surrogate_id,
    full_name,
    national_id,
    email_address,
    phone_number,
    activity_date,
    precedencia
FROM ranked_identities
WHERE precedencia = 1  -- Solo el registro mas vigente
ORDER BY pidm;

/*
VALIDACION:
- COUNT(DISTINCT pidm) = COUNT(*) (1 registro por persona)
- Todos los registros tienen precedencia = 1
- activity_date es el mas reciente para cada pidm
*/

-- ===========================================================================
-- CONSULTA 3: Deteccion de cambios (extraccion diferencial)
-- ===========================================================================

-- Simular tabla de control de extracciones
/*
CREATE TABLE dbo.control_extracciones (
    tabla_origen VARCHAR(100) PRIMARY KEY,
    fecha_ultima_extraccion DATETIME NOT NULL,
    registros_extraidos INT DEFAULT 0,
    fecha_actualizacion DATETIME DEFAULT GETDATE()
);

INSERT INTO dbo.control_extracciones VALUES 
('erp_person_identity', '2025-01-01 00:00:00', 0, GETDATE());
*/

DECLARE @fecha_ultima_extraccion DATETIME = '2025-01-01 00:00:00';  -- Parametro SP

WITH ranked_identities AS (
    SELECT 
        pidm,
        person_surrogate_id,
        full_name,
        national_id,
        email_address,
        phone_number,
        activity_date,
        ROW_NUMBER() OVER (
            PARTITION BY pidm 
            ORDER BY activity_date DESC, person_surrogate_id DESC
        ) AS precedencia
    FROM dbo.erp_person_identity
    WHERE activity_date > @fecha_ultima_extraccion  -- Solo registros nuevos/modificados
)
SELECT 
    pidm,
    person_surrogate_id,
    full_name,
    national_id,
    email_address,
    phone_number,
    activity_date
FROM ranked_identities
WHERE precedencia = 1
ORDER BY activity_date DESC;

/*
LOGICA EXTRACCION DIFERENCIAL:
1. Filtrar por activity_date > fecha_ultima_extraccion
2. Aplicar precedencia (ROW_NUMBER)
3. Insertar a stg.staging_personas
4. Actualizar control_extracciones con nueva fecha

NOTA: Si una persona tiene actualizacion reciente, se extrae solo ese registro
aunque tenga otros historicos. Los registros viejos ya fueron extraidos antes.
*/

-- ===========================================================================
-- CONSULTA 4: Casos edge - Validacion exhaustiva
-- ===========================================================================

-- Caso 1: Registros con mismo activity_date (usar surrogate_id como desempate)
SELECT 
    pidm,
    person_surrogate_id,
    activity_date,
    ROW_NUMBER() OVER (
        PARTITION BY pidm 
        ORDER BY activity_date DESC, person_surrogate_id DESC
    ) AS precedencia
FROM dbo.erp_person_identity
WHERE pidm IN (
    SELECT pidm 
    FROM dbo.erp_person_identity 
    GROUP BY pidm, activity_date 
    HAVING COUNT(*) > 1
);

-- Caso 2: Detectar registros huerfanos en curriculum sin identidad vigente
SELECT 
    cur.pidm,
    cur.curriculum_term_code,
    cur.curriculum_priority_no
FROM dbo.erp_student_curriculum cur
LEFT JOIN (
    SELECT DISTINCT pidm FROM dbo.erp_person_identity
) ident ON cur.pidm = ident.pidm
WHERE ident.pidm IS NULL;

-- Caso 3: Volumetria comparativa (antes y despues de precedencia)
SELECT 
    'Sin filtro' AS tipo,
    COUNT(*) AS total_registros,
    COUNT(DISTINCT pidm) AS personas_unicas
FROM dbo.erp_person_identity

UNION ALL

SELECT 
    'Con precedencia' AS tipo,
    COUNT(*) AS total_registros,
    COUNT(DISTINCT pidm) AS personas_unicas
FROM (
    SELECT pidm
    FROM (
        SELECT pidm, 
               ROW_NUMBER() OVER (PARTITION BY pidm ORDER BY activity_date DESC, person_surrogate_id DESC) AS rn
        FROM dbo.erp_person_identity
    ) sub
    WHERE rn = 1
) final;

-- ===========================================================================
-- CONSULTA 5: Perfil de actualizaciones (frecuencia, patrones)
-- ===========================================================================

SELECT 
    YEAR(activity_date) AS anyo,
    MONTH(activity_date) AS mes,
    COUNT(*) AS total_actualizaciones,
    COUNT(DISTINCT pidm) AS personas_actualizadas,
    AVG(CAST(COUNT(*) AS FLOAT)) OVER () AS promedio_mensual
FROM dbo.erp_person_identity
WHERE activity_date >= DATEADD(MONTH, -12, GETDATE())  -- Ultimo anyo
GROUP BY YEAR(activity_date), MONTH(activity_date)
ORDER BY anyo DESC, mes DESC;

/*
PATRONES ESPERADOS:
- Picos en marzo (inicio semestre 1) y agosto (inicio semestre 2)
- Minimo en enero (vacaciones)
- Promedio: 5-10 actualizaciones/mes para 20 personas baseline
*/

-- ===========================================================================
-- STORED PROCEDURE: Plantilla para extraccion diferencial
-- ===========================================================================

/*
CREATE OR ALTER PROCEDURE dbo.spExtraccionDiferencialPersonas
    @fecha_corte DATETIME = NULL,  -- NULL = usar control_extracciones
    @tabla_destino VARCHAR(100) = 'BI_Assessment_Staging.stg.staging_personas',
    @id_ejecucion UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Obtener fecha ultima extraccion
    IF @fecha_corte IS NULL
    BEGIN
        SELECT @fecha_corte = fecha_ultima_extraccion 
        FROM dbo.control_extracciones 
        WHERE tabla_origen = 'erp_person_identity';
    END
    
    DECLARE @fecha_actual DATETIME = GETDATE();
    DECLARE @registros_extraidos INT = 0;
    
    BEGIN TRY
        -- Extraccion con precedencia
        WITH ranked_identities AS (
            SELECT 
                pidm,
                person_surrogate_id,
                full_name,
                national_id,
                email_address,
                phone_number,
                activity_date,
                ROW_NUMBER() OVER (
                    PARTITION BY pidm 
                    ORDER BY activity_date DESC, person_surrogate_id DESC
                ) AS rn
            FROM dbo.erp_person_identity
            WHERE activity_date > @fecha_corte
        )
        INSERT INTO BI_Assessment_Staging.stg.staging_personas (
            pidm, nombre_completo, documento_identidad, email, telefono, 
            fecha_actualizacion_erp, fecha_carga_staging
        )
        SELECT 
            pidm, full_name, national_id, email_address, phone_number,
            activity_date, @fecha_actual
        FROM ranked_identities
        WHERE rn = 1;
        
        SET @registros_extraidos = @@ROWCOUNT;
        
        -- Actualizar control
        UPDATE dbo.control_extracciones
        SET fecha_ultima_extraccion = @fecha_actual,
            registros_extraidos = registros_extraidos + @registros_extraidos,
            fecha_actualizacion = @fecha_actual
        WHERE tabla_origen = 'erp_person_identity';
        
        PRINT 'Extraccion completada: ' + CAST(@registros_extraidos AS VARCHAR) + ' registros';
        
    END TRY
    BEGIN CATCH
        DECLARE @error_msg VARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en extraccion diferencial: %s', 16, 1, @error_msg);
    END CATCH
END;
GO
*/

/*
================================================================================
CRITERIOS DE EVALUACION:

[25pts] Vista de extraccion con precedencia
        - ROW_NUMBER() correcto (activity_date DESC, surrogate_id DESC)
        - Filtro WHERE rn = 1
        - 1 registro por pidm garantizado
        
[30pts] Stored procedure diferencial
        - Lee fecha_ultima_extraccion desde control
        - Aplica filtro activity_date > @fecha_corte
        - Inserta a staging con auditoria (fecha_carga)
        - Actualiza tabla control con nueva fecha
        
[25pts] Tests de casos edge
        - Multi-vigencia con mismo activity_date
        - Personas sin registros recientes
        - Validacion volumetria (antes/despues)
        
[20pts] Documentacion en SOLUTION.md
        - Diagrama de flujo extraccion diferencial
        - Justificacion orden precedencia (fecha > surrogate_id)
        - Estrategia para manejar deletes (soft delete vs hard delete)
        - Impacto en dimension cat.dim_estudiantes

DATOS DE PRUEBA:
-- Simular cambio de nombre
UPDATE dbo.erp_person_identity 
SET activity_date = GETDATE(), full_name = 'Maria Lopez Martinez'
WHERE pidm = 1 AND person_surrogate_id = 1001;

-- Ejecutar extraccion
EXEC dbo.spExtraccionDiferencialPersonas;

-- Validar: Solo 1 registro para PIDM 1 con nuevo nombre
SELECT * FROM BI_Assessment_Staging.stg.staging_personas WHERE pidm = 1;
================================================================================
*/
