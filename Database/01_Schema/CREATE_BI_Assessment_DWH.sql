/*
===============================================================================
SCRIPT: CREATE_BI_Assessment_DWH.sql
PROPÓSITO: Crear base de datos BI_Assessment_DWH con modelo dimensional
AUTOR: BI Team
FECHA: Diciembre 2025
DESCRIPCIÓN:
  - Base DWH con esquemas: cat (dimensiones), mat (hechos matrícula), ben (hechos beneficios)
  - Incluye Foreign Keys referenciando staging (permitiendo huérfanos por diseño para Issue 001)
  - Surrogate keys (BIGINT IDENTITY)
  - Modelo dimensional básico para evaluación
DEPENDENCIAS: BI_Assessment_Staging creada previamente
===============================================================================
*/

-- ===== CREAR BASE DE DATOS =====
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'BI_Assessment_DWH')
BEGIN
    ALTER DATABASE [BI_Assessment_DWH] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [BI_Assessment_DWH];
END
GO

CREATE DATABASE [BI_Assessment_DWH]
GO

USE [BI_Assessment_DWH]
GO

-- ===== CREAR ESQUEMAS =====
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'cat')
    EXEC sp_executesql N'CREATE SCHEMA cat';
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'mat')
    EXEC sp_executesql N'CREATE SCHEMA mat';
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ben')
    EXEC sp_executesql N'CREATE SCHEMA ben';
GO

-- ===== DIMENSIÓN: cat.dim_estudiantes =====
-- Dimensión de estudiantes (vigentes desde ERP)
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'dim_estudiantes' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'cat')
    DROP TABLE cat.dim_estudiantes;
GO

CREATE TABLE cat.dim_estudiantes
(
    id_estudiante               BIGINT IDENTITY(1,1) PRIMARY KEY,
    pidm_erp                    INT NOT NULL UNIQUE,          -- Referencia a ERP
    nombre_completo             VARCHAR(150) NOT NULL,
    fecha_nacimiento            DATE NULL,
    email                       VARCHAR(100) NULL,
    telefono                    VARCHAR(20) NULL,
    fecha_carga                 DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_actualizacion         DATETIME NOT NULL DEFAULT GETDATE()
);

-- ===== DIMENSIÓN: cat.dim_terminos =====
-- Dimensión de períodos académicos
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'dim_terminos' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'cat')
    DROP TABLE cat.dim_terminos;
GO

CREATE TABLE cat.dim_terminos
(
    id_termino                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_termino              VARCHAR(10) NOT NULL UNIQUE,
    nombre_termino              VARCHAR(50) NOT NULL,
    anio                        INT NOT NULL,
    secuencia                   INT NOT NULL,
    fecha_inicio                DATE NOT NULL,
    fecha_fin                   DATE NOT NULL,
    es_activo                   BIT NOT NULL DEFAULT 1,
    fecha_carga                 DATETIME NOT NULL DEFAULT GETDATE()
);

-- ===== DIMENSIÓN: cat.dim_programas =====
-- Dimensión de programas académicos
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'dim_programas' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'cat')
    DROP TABLE cat.dim_programas;
GO

CREATE TABLE cat.dim_programas
(
    id_programa                 BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_programa             VARCHAR(20) NOT NULL UNIQUE,
    nombre_programa             VARCHAR(100) NOT NULL,
    tipo_programa               VARCHAR(50) NULL,
    es_vigente                  BIT NOT NULL DEFAULT 1,
    fecha_carga                 DATETIME NOT NULL DEFAULT GETDATE()
);

-- ===== DIMENSIÓN: cat.dim_cohortes =====
-- Dimensión de cohortes (grupos de ingreso)
-- NOTA: Issue 004 requiere completar esta dimensión
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'dim_cohortes' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'cat')
    DROP TABLE cat.dim_cohortes;
GO

CREATE TABLE cat.dim_cohortes
(
    id_cohorte                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_cohorte              VARCHAR(20) NOT NULL UNIQUE,
    anio_ingreso                INT NOT NULL,
    jornada                     VARCHAR(50) NULL,              -- Diurna, Nocturna, etc
    descripcion                 VARCHAR(200) NULL,
    fecha_inicio_cohorte        DATE NULL,
    es_vigente                  BIT NOT NULL DEFAULT 1,
    fecha_carga                 DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_actualizacion         DATETIME NOT NULL DEFAULT GETDATE()
);

-- ===== HECHO: mat.hechos_matricula =====
-- Hechos de matrícula (grain: estudiante x término)
-- NOTA: Incluye FK a dim_cohortes (requerido para Issue 004)
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'hechos_matricula' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'mat')
    DROP TABLE mat.hechos_matricula;
GO

CREATE TABLE mat.hechos_matricula
(
    id_hecho_matricula          BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante               BIGINT NOT NULL,
    id_termino                  BIGINT NOT NULL,
    id_programa                 BIGINT NOT NULL,
    id_cohorte                  BIGINT NULL,                   -- FK a dim_cohortes (puede ser NULL inicialmente)
    codigo_programa             VARCHAR(20) NOT NULL,
    nombre_programa             VARCHAR(100) NOT NULL,
    fecha_matricula             DATE NOT NULL,
    creditos_inscritos          DECIMAL(6,2) NULL,
    promedio_ingreso            DECIMAL(4,2) NULL,
    es_vigente                  BIT NOT NULL DEFAULT 1,
    fecha_carga                 DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_actualizacion         DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (id_estudiante) REFERENCES cat.dim_estudiantes(id_estudiante),
    FOREIGN KEY (id_termino) REFERENCES cat.dim_terminos(id_termino),
    FOREIGN KEY (id_programa) REFERENCES cat.dim_programas(id_programa)
    -- NOTA: No incluimos FK a dim_cohortes aquí (Issue 004 la agregará)
);

-- ===== HECHO: ben.hechos_beneficios =====
-- Hechos de beneficios (ayudas financieras)
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'hechos_beneficios' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'ben')
    DROP TABLE ben.hechos_beneficios;
GO

CREATE TABLE ben.hechos_beneficios
(
    id_hecho_beneficio          BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante               BIGINT NOT NULL,
    id_termino                  BIGINT NOT NULL,
    codigo_beneficio            VARCHAR(20) NOT NULL,
    nombre_beneficio            VARCHAR(100) NOT NULL,
    monto_beneficio             DECIMAL(10,2) NOT NULL,
    porcentaje_cobertura        DECIMAL(5,2) NULL,
    fecha_inicio                DATE NOT NULL,
    fecha_fin                   DATE NULL,
    es_vigente                  BIT NOT NULL DEFAULT 1,
    fecha_carga                 DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_actualizacion         DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (id_estudiante) REFERENCES cat.dim_estudiantes(id_estudiante),
    FOREIGN KEY (id_termino) REFERENCES cat.dim_terminos(id_termino)
);

-- ===== HECHO: ben.hechos_pagos =====
-- Hechos de pagos (transacciones de pago)
-- NOTA: Issue 006 requiere completar este diseño
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'hechos_pagos' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'ben')
    DROP TABLE ben.hechos_pagos;
GO

CREATE TABLE ben.hechos_pagos
(
    id_pago                     BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante               BIGINT NOT NULL,
    id_termino                  BIGINT NOT NULL,
    fecha_pago                  DATE NOT NULL,
    monto_pago                  DECIMAL(10,2) NOT NULL,
    tipo_pago                   VARCHAR(50) NOT NULL,         -- Matrícula, Aranceles, etc
    estado_pago                 VARCHAR(20) NOT NULL,         -- Pagado, Pendiente, Vencido
    fecha_carga                 DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_actualizacion         DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (id_estudiante) REFERENCES cat.dim_estudiantes(id_estudiante),
    FOREIGN KEY (id_termino) REFERENCES cat.dim_terminos(id_termino)
);

-- ===== ÍNDICES =====
CREATE NONCLUSTERED INDEX IX_dim_estudiantes_PIDM ON cat.dim_estudiantes(pidm_erp);
CREATE NONCLUSTERED INDEX IX_dim_terminos_CODIGO ON cat.dim_terminos(codigo_termino);
CREATE NONCLUSTERED INDEX IX_dim_programas_CODIGO ON cat.dim_programas(codigo_programa);
CREATE NONCLUSTERED INDEX IX_mat_hechos_matricula_EST_TERM ON mat.hechos_matricula(id_estudiante, id_termino);
CREATE NONCLUSTERED INDEX IX_ben_hechos_beneficios_EST ON ben.hechos_beneficios(id_estudiante);
CREATE NONCLUSTERED INDEX IX_ben_hechos_pagos_EST_FECHA ON ben.hechos_pagos(id_estudiante, fecha_pago);

GO

-- ===== VERIFICACIÓN =====
PRINT '';
PRINT '✓ Base de datos BI_Assessment_DWH creada exitosamente';
PRINT '✓ Esquemas creados: cat, mat, ben';
PRINT '✓ Dimensiones: dim_estudiantes, dim_terminos, dim_programas, dim_cohortes';
PRINT '✓ Hechos: hechos_matricula, hechos_beneficios, hechos_pagos';
PRINT '';

SELECT 
    OBJECT_SCHEMA_NAME(o.object_id) AS SchemaName,
    o.name AS TableName,
    (SELECT COUNT(*) FROM sys.columns c WHERE c.object_id = o.object_id) AS ColumnCount
FROM sys.objects o
WHERE o.type = 'U'
ORDER BY SchemaName, TableName;
