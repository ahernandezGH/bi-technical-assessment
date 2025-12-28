/*
================================================================================
ARCHIVO: ARTIFACT_TablaHechos_Template.sql
DESCRIPCION: Plantilla para diseño de tabla de hechos (Issue 006)
AUTOR: Sistema
FECHA: 2025-01-15
PROYECTO: BI Technical Assessment
ISSUE: Issue006 - Fact Table Design and Grain Definition

PROPOSITO:
- Demostrar diseño de tabla de hechos con granularidad correcta
- Proveer ejemplos de medidas aditivas, semi-aditivas y calculadas
- Ilustrar relacion con dimensiones conformadas

CONTEXTO:
Actualmente mat.hechos_matricula tiene granularidad ambigua (estudiante-termino
o estudiante-termino-programa?). El candidato debe:
1. Definir granularidad precisa (nivel de detalle)
2. Identificar medidas apropiadas (aditivas, semi-aditivas)
3. Establecer FKs a dimensiones
4. Diseñar indices para consultas tipicas

TAREAS DEL CANDIDATO:
1. Analizar tabla actual y documentar problemas de granularidad
2. Crear CREATE_HechosPagos.sql con:
   - Granularidad: 1 registro = 1 pago individual (estudiante + fecha + tipo_pago)
   - FKs: id_estudiante, id_termino, id_programa, fecha_pago (dimension tiempo)
   - Medidas aditivas: monto_pago, descuento_aplicado, monto_neto
   - Medidas semi-aditivas: saldo_pendiente (snapshot al momento del pago)
   - Atributos degenerados: numero_recibo, metodo_pago
3. Crear PROC_CargaHechosPagos.sql para:
   - Validar granularidad (no duplicados por PK natural)
   - Calcular medidas derivadas (monto_neto = monto - descuento)
   - Mantener integridad referencial con dimensiones
4. Crear QA_ValidarGranularidad.sql con tests:
   - Duplicados por combinacion natural key
   - Consistencia de sumas (SUM monto_neto por estudiante = total esperado)
   - Validacion temporal (no pagos futuros)
5. Documentar decisiones en SOLUTION.md (400-500 palabras)

METRICAS ESPERADAS:
- Granularidad sin duplicados (PK natural unica)
- Cardinalidad: ~100-200 pagos para 20 estudiantes baseline
- Indice clustered en fecha_pago + id_estudiante (queries temporales)
================================================================================
*/

USE BI_Assessment_DWH;
GO

-- ===========================================================================
-- ANALISIS: Granularidad actual de hechos_matricula
-- ===========================================================================

-- Verificar unicidad por estudiante-termino
SELECT 
    id_estudiante,
    id_termino,
    COUNT(*) AS registros,
    SUM(monto_matricula) AS monto_total
FROM mat.hechos_matricula
GROUP BY id_estudiante, id_termino
HAVING COUNT(*) > 1;  -- Detectar duplicados

/*
PREGUNTA CLAVE: 
¿Un estudiante puede tener multiples matriculas en el mismo termino?
- Si SI: Granularidad es estudiante + termino + programa (permite doble titulacion)
- Si NO: Granularidad es estudiante + termino (1 programa por termino)

DECISION: Documentar en SOLUTION.md con justificacion de negocio
*/

-- Verificar distribucion por programa
SELECT 
    id_programa,
    COUNT(DISTINCT id_estudiante) AS estudiantes_unicos,
    COUNT(*) AS total_matriculas,
    AVG(monto_matricula) AS monto_promedio
FROM mat.hechos_matricula
GROUP BY id_programa
ORDER BY estudiantes_unicos DESC;

-- ===========================================================================
-- PLANTILLA: Tabla de hechos de pagos (nueva)
-- ===========================================================================

/*
GRANULARIDAD DEFINIDA: 
1 registro = 1 pago individual de un estudiante en una fecha especifica

EJEMPLO: Estudiante 1 paga matricula en 3 cuotas
- Registro 1: 2025-03-01, cuota_inicial, $500
- Registro 2: 2025-04-01, cuota_2, $500
- Registro 3: 2025-05-01, cuota_3, $500

Total: 3 registros en hechos_pagos (granularidad = pago individual)
*/

/*
CREATE TABLE mat.hechos_pagos (
    -- Surrogate key (opcional, recomendado para performance)
    id_hecho_pago BIGINT IDENTITY(1,1) PRIMARY KEY,
    
    -- Foreign Keys (dimensiones)
    id_estudiante BIGINT NOT NULL,
    id_termino BIGINT NOT NULL,
    id_programa BIGINT NOT NULL,
    fecha_pago DATE NOT NULL,  -- Puede ser FK a dim_tiempo si existe
    
    -- Atributos degenerados (parte de PK natural, no requieren dimension)
    numero_recibo VARCHAR(20) NOT NULL UNIQUE,  -- Correlacion con sistema transaccional
    tipo_pago VARCHAR(20) NOT NULL CHECK (tipo_pago IN ('MATRICULA', 'ARANCEL', 'CUOTA', 'OTRO')),
    metodo_pago VARCHAR(20) NOT NULL CHECK (metodo_pago IN ('TRANSFERENCIA', 'EFECTIVO', 'TARJETA', 'WEBPAY')),
    cuota_numero INT NULL,  -- Si es pago en cuotas (1, 2, 3, etc)
    
    -- Medidas ADITIVAS (pueden sumarse en cualquier dimension)
    monto_pago DECIMAL(18,2) NOT NULL CHECK (monto_pago >= 0),
    descuento_aplicado DECIMAL(18,2) DEFAULT 0 CHECK (descuento_aplicado >= 0),
    monto_neto AS (monto_pago - descuento_aplicado) PERSISTED,  -- Calculada
    
    -- Medidas SEMI-ADITIVAS (NO se suman en dimension tiempo)
    saldo_pendiente DECIMAL(18,2) DEFAULT 0,  -- Snapshot al momento del pago
    
    -- Medidas de conteo (flags para agregaciones)
    es_primer_pago BIT DEFAULT 0,  -- Indicador para metricas de conversion
    pago_completo BIT DEFAULT 0,   -- Si pago cubre monto total comprometido
    
    -- Auditoria
    fecha_carga DATETIME NOT NULL DEFAULT GETDATE(),
    usuario_carga VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER,
    
    -- Constraint: PK natural (alternativa a surrogate key)
    CONSTRAINT UQ_hechos_pagos_natural UNIQUE (numero_recibo, id_estudiante, fecha_pago),
    
    -- Foreign Keys (validacion referencial)
    CONSTRAINT FK_hechos_pagos_estudiante FOREIGN KEY (id_estudiante) 
        REFERENCES cat.dim_estudiantes(id_estudiante),
    CONSTRAINT FK_hechos_pagos_termino FOREIGN KEY (id_termino) 
        REFERENCES cat.dim_terminos(id_termino),
    CONSTRAINT FK_hechos_pagos_programa FOREIGN KEY (id_programa) 
        REFERENCES cat.dim_programas(id_programa),
    
    -- Indices para queries tipicas
    INDEX IX_hechos_pagos_fecha_estudiante CLUSTERED (fecha_pago, id_estudiante),
    INDEX IX_hechos_pagos_termino (id_termino) INCLUDE (monto_neto),
    INDEX IX_hechos_pagos_programa (id_programa) INCLUDE (monto_neto, saldo_pendiente)
);
*/

-- ===========================================================================
-- STORED PROCEDURE: Carga con validacion de granularidad
-- ===========================================================================

/*
CREATE OR ALTER PROCEDURE mat.spCargaHechosPagos
    @tabla_staging VARCHAR(100) = 'stg.staging_pagos',
    @id_ejecucion UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @registros_insertados INT = 0;
    DECLARE @registros_rechazados INT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- PASO 1: Validar granularidad (no duplicados en staging)
        IF EXISTS (
            SELECT numero_recibo, id_estudiante, fecha_pago
            FROM stg.staging_pagos
            GROUP BY numero_recibo, id_estudiante, fecha_pago
            HAVING COUNT(*) > 1
        )
        BEGIN
            RAISERROR('Duplicados detectados en staging - revisar granularidad', 16, 1);
        END
        
        -- PASO 2: Validar FKs (integridad referencial)
        IF EXISTS (
            SELECT 1 FROM stg.staging_pagos stg
            LEFT JOIN cat.dim_estudiantes de ON stg.id_estudiante = de.id_estudiante
            WHERE de.id_estudiante IS NULL
        )
        BEGIN
            RAISERROR('FK invalido: id_estudiante no existe en dim_estudiantes', 16, 1);
        END
        
        -- PASO 3: Insertar hechos
        INSERT INTO mat.hechos_pagos (
            id_estudiante, id_termino, id_programa, fecha_pago,
            numero_recibo, tipo_pago, metodo_pago, cuota_numero,
            monto_pago, descuento_aplicado, saldo_pendiente,
            es_primer_pago, pago_completo
        )
        SELECT 
            stg.id_estudiante,
            stg.id_termino,
            stg.id_programa,
            stg.fecha_pago,
            stg.numero_recibo,
            stg.tipo_pago,
            stg.metodo_pago,
            stg.cuota_numero,
            stg.monto_pago,
            ISNULL(stg.descuento_aplicado, 0),
            stg.saldo_pendiente,
            -- Calcular es_primer_pago (no existen pagos previos del estudiante)
            CASE 
                WHEN NOT EXISTS (
                    SELECT 1 FROM mat.hechos_pagos hp 
                    WHERE hp.id_estudiante = stg.id_estudiante 
                      AND hp.fecha_pago < stg.fecha_pago
                ) THEN 1 
                ELSE 0 
            END,
            -- Calcular pago_completo (saldo_pendiente = 0)
            CASE WHEN stg.saldo_pendiente = 0 THEN 1 ELSE 0 END
        FROM stg.staging_pagos stg
        LEFT JOIN mat.hechos_pagos hp 
            ON stg.numero_recibo = hp.numero_recibo 
            AND stg.id_estudiante = hp.id_estudiante
        WHERE hp.id_hecho_pago IS NULL;  -- Solo insertar nuevos
        
        SET @registros_insertados = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        PRINT 'Carga completada: ' + CAST(@registros_insertados AS VARCHAR) + ' pagos insertados';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @error_msg VARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en carga hechos_pagos: %s', 16, 1, @error_msg);
    END CATCH
END;
GO
*/

-- ===========================================================================
-- CONSULTAS QA: Validacion de granularidad
-- ===========================================================================

-- QA 1: Detectar duplicados por PK natural
SELECT 
    numero_recibo,
    id_estudiante,
    fecha_pago,
    COUNT(*) AS ocurrencias
FROM mat.hechos_pagos
GROUP BY numero_recibo, id_estudiante, fecha_pago
HAVING COUNT(*) > 1;

-- QA 2: Consistencia de montos (monto_neto calculado)
SELECT 
    id_hecho_pago,
    monto_pago,
    descuento_aplicado,
    monto_neto,
    CASE 
        WHEN monto_neto <> (monto_pago - descuento_aplicado) 
        THEN 'INCONSISTENTE' 
        ELSE 'OK' 
    END AS validacion
FROM mat.hechos_pagos
WHERE monto_neto <> (monto_pago - descuento_aplicado);

-- QA 3: Validacion temporal (no pagos futuros)
SELECT 
    COUNT(*) AS pagos_futuros
FROM mat.hechos_pagos
WHERE fecha_pago > GETDATE();

-- QA 4: Volumetria por estudiante (detectar outliers)
SELECT 
    de.nombre_completo,
    COUNT(*) AS total_pagos,
    SUM(hp.monto_neto) AS monto_total,
    AVG(hp.monto_neto) AS monto_promedio,
    MIN(hp.fecha_pago) AS primer_pago,
    MAX(hp.fecha_pago) AS ultimo_pago
FROM mat.hechos_pagos hp
INNER JOIN cat.dim_estudiantes de ON hp.id_estudiante = de.id_estudiante
GROUP BY de.nombre_completo
ORDER BY total_pagos DESC;

-- QA 5: Validacion de cuotas (secuencia correcta)
SELECT 
    id_estudiante,
    numero_recibo,
    cuota_numero,
    fecha_pago,
    monto_pago,
    LAG(cuota_numero) OVER (PARTITION BY id_estudiante ORDER BY fecha_pago) AS cuota_anterior,
    CASE 
        WHEN cuota_numero - LAG(cuota_numero) OVER (PARTITION BY id_estudiante ORDER BY fecha_pago) <> 1 
        THEN 'SALTO_CUOTA' 
        ELSE 'OK' 
    END AS validacion_secuencia
FROM mat.hechos_pagos
WHERE cuota_numero IS NOT NULL
ORDER BY id_estudiante, fecha_pago;

-- ===========================================================================
-- CONSULTAS ANALITICAS: Ejemplos de uso
-- ===========================================================================

-- Analisis 1: Ingresos mensuales (medida aditiva)
SELECT 
    YEAR(fecha_pago) AS anyo,
    MONTH(fecha_pago) AS mes,
    COUNT(*) AS total_pagos,
    SUM(monto_neto) AS ingresos_totales,
    AVG(monto_neto) AS monto_promedio
FROM mat.hechos_pagos
GROUP BY YEAR(fecha_pago), MONTH(fecha_pago)
ORDER BY anyo DESC, mes DESC;

-- Analisis 2: Conversion (estudiantes que completan pago)
SELECT 
    dt.codigo_termino,
    COUNT(DISTINCT hp.id_estudiante) AS estudiantes_pagadores,
    SUM(CASE WHEN hp.pago_completo = 1 THEN 1 ELSE 0 END) AS pagos_completos,
    CAST(SUM(CASE WHEN hp.pago_completo = 1 THEN 1.0 ELSE 0 END) * 100.0 
         / COUNT(DISTINCT hp.id_estudiante) AS DECIMAL(5,2)) AS tasa_conversion
FROM mat.hechos_pagos hp
INNER JOIN cat.dim_terminos dt ON hp.id_termino = dt.id_termino
GROUP BY dt.codigo_termino
ORDER BY dt.codigo_termino DESC;

-- Analisis 3: Saldo pendiente actual (medida semi-aditiva)
-- IMPORTANTE: NO sumar saldo_pendiente en dimension tiempo!
SELECT 
    de.nombre_completo,
    MAX(hp.fecha_pago) AS fecha_ultimo_pago,  -- Solo el snapshot mas reciente
    (
        SELECT TOP 1 saldo_pendiente 
        FROM mat.hechos_pagos hp2 
        WHERE hp2.id_estudiante = hp.id_estudiante 
        ORDER BY hp2.fecha_pago DESC
    ) AS saldo_actual
FROM mat.hechos_pagos hp
INNER JOIN cat.dim_estudiantes de ON hp.id_estudiante = de.id_estudiante
GROUP BY hp.id_estudiante, de.nombre_completo
HAVING MAX(hp.fecha_pago) >= DATEADD(MONTH, -3, GETDATE())  -- Solo activos recientes
ORDER BY saldo_actual DESC;

/*
================================================================================
CRITERIOS DE EVALUACION:

[30pts] CREATE TABLE con diseño correcto
        - Granularidad documentada (comentario al inicio)
        - PK natural + surrogate key
        - Medidas aditivas vs semi-aditivas correctamente identificadas
        - Constraints de integridad (CHECK, FK)
        - Indices apropiados (clustered en fecha_pago)
        
[30pts] Stored procedure de carga
        - Validacion de duplicados (HAVING COUNT(*) > 1)
        - Validacion FK antes de INSERT
        - Calculo de medidas derivadas (es_primer_pago, pago_completo)
        - Manejo de errores con TRANSACTION/ROLLBACK
        
[25pts] Consultas QA (5 validaciones minimas)
        - Duplicados por PK natural
        - Consistencia de calculos (monto_neto)
        - Validacion temporal (no fechas futuras)
        - Volumetria por estudiante
        - Secuencia de cuotas
        
[15pts] Documentacion en SOLUTION.md
        - Definicion precisa de granularidad (1 registro = ?)
        - Justificacion medidas aditivas vs semi-aditivas
        - Diagrama de modelo estrella (fact + dims)
        - Ejemplos de queries tipicas (ingresos, conversion, saldo)

DATOS DE PRUEBA SUGERIDOS:
INSERT stg.staging_pagos VALUES 
(1, 1, 1, '2025-03-01', 'REC-2025-001', 'MATRICULA', 'TRANSFERENCIA', 1, 1000.00, 100.00, 1900.00),
(1, 1, 1, '2025-04-01', 'REC-2025-002', 'CUOTA', 'WEBPAY', 2, 1000.00, 0, 900.00),
(1, 1, 1, '2025-05-01', 'REC-2025-003', 'CUOTA', 'WEBPAY', 3, 900.00, 0, 0);

-- Ejecutar carga
EXEC mat.spCargaHechosPagos;

-- Validar: 3 registros para estudiante 1, saldo_pendiente decreciente
================================================================================
*/
