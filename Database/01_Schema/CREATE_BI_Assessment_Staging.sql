/*
===============================================================================
SCRIPT: CREATE_BI_Assessment_Staging.sql
PROPÓSITO: Crear base de datos BI_Assessment_Staging con esquemas y tablas ETL
AUTOR: BI Team
FECHA: Diciembre 2025
DESCRIPCIÓN:
  - Base de staging intermedia entre ERP y DWH
  - Esquemas: stg (raw), cat (catálogos), mat (matrícula), ben (beneficios)
  - Sin transformaciones complejas, datos crudos con validación básica
DEPENDENCIAS: SQL Server 2019+
===============================================================================
*/

-- ===== CREAR BASE DE DATOS =====
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'BI_Assessment_Staging')
BEGIN
    ALTER DATABASE [BI_Assessment_Staging] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [BI_Assessment_Staging];
END
GO

CREATE DATABASE [BI_Assessment_Staging]
GO

USE [BI_Assessment_Staging]
GO

-- ===== CREAR ESQUEMAS =====
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
    EXEC sp_executesql N'CREATE SCHEMA stg';
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'cat')
    EXEC sp_executesql N'CREATE SCHEMA cat';
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'mat')
    EXEC sp_executesql N'CREATE SCHEMA mat';
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ben')
    EXEC sp_executesql N'CREATE SCHEMA ben';
GO

-- ===== TABLA: stg.estudiantes =====
-- Datos crudos de estudiantes desde ERP
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'estudiantes' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'stg')
    DROP TABLE stg.estudiantes;
GO

CREATE TABLE stg.estudiantes
(
    id_estudiante_stg           BIGINT IDENTITY(1,1) PRIMARY KEY,
    pidm                        INT NOT NULL,
    nombre_completo             VARCHAR(150) NOT NULL,
    fecha_nacimiento            DATE NULL,
    email                       VARCHAR(100) NULL,
    telefono                    VARCHAR(20) NULL,
    fecha_carga                 DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_procesamiento         DATETIME NULL
);

-- ===== TABLA: stg.curricula =====
-- Datos crudos de programa de estudiante
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'curricula' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'stg')
    DROP TABLE stg.curricula;
GO

CREATE TABLE stg.curricula
(
    id_curriculum_stg           BIGINT IDENTITY(1,1) PRIMARY KEY,
    pidm                        INT NOT NULL,
    codigo_termino              VARCHAR(10) NOT NULL,
    codigo_programa             VARCHAR(20) NOT NULL,
    nombre_programa             VARCHAR(100) NOT NULL,
    prioridad                   INT NOT NULL DEFAULT 0,
    secuencia_clave             INT NOT NULL DEFAULT 0,
    tipo_matricula              VARCHAR(10) NULL,
    promedio_notas              DECIMAL(4,2) NULL,
    creditos                    DECIMAL(6,2) NULL,
    fecha_carga                 DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_procesamiento         DATETIME NULL
);

-- ===== TABLA: cat.terminos =====
-- Catálogo de términos (dimensión)
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'terminos' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'cat')
    DROP TABLE cat.terminos;
GO

CREATE TABLE cat.terminos
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

-- ===== TABLA: mat.matriculas =====
-- Hechos de matrícula (hechos granulares)
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'matriculas' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'mat')
    DROP TABLE mat.matriculas;
GO

CREATE TABLE mat.matriculas
(
    id_matricula                BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante               INT NOT NULL,
    id_termino                  INT NOT NULL,
    codigo_programa             VARCHAR(20) NOT NULL,
    nombre_programa             VARCHAR(100) NOT NULL,
    fecha_matricula             DATE NOT NULL,
    creditos_inscritos          DECIMAL(6,2) NULL,
    promedio_ingreso            DECIMAL(4,2) NULL,
    es_vigente                  BIT NOT NULL DEFAULT 1,
    fecha_carga                 DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_procesamiento         DATETIME NULL
);

-- ===== TABLA: ben.beneficios =====
-- Hechos de beneficios (ayudas financieras, becas, etc)
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'beneficios' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'ben')
    DROP TABLE ben.beneficios;
GO

CREATE TABLE ben.beneficios
(
    id_beneficio                BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante               INT NOT NULL,
    id_termino                  INT NOT NULL,
    codigo_beneficio            VARCHAR(20) NOT NULL,
    nombre_beneficio            VARCHAR(100) NOT NULL,
    monto_beneficio             DECIMAL(10,2) NOT NULL,
    porcentaje_cobertura        DECIMAL(5,2) NULL,
    fecha_inicio                DATE NOT NULL,
    fecha_fin                   DATE NULL,
    es_vigente                  BIT NOT NULL DEFAULT 1,
    fecha_carga                 DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_procesamiento         DATETIME NULL
);

-- ===== TABLA: cat.dim_programas =====
-- Catálogo de programas académicos
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'dim_programas' AND OBJECT_SCHEMA_NAME(OBJECT_ID) = 'cat')
    DROP TABLE cat.dim_programas;
GO

CREATE TABLE cat.dim_programas
(
    id_programa                 BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_programa             VARCHAR(20) NOT NULL UNIQUE,
    nombre_programa             VARCHAR(100) NOT NULL,
    tipo_programa               VARCHAR(50) NULL,                -- Pregrado, Postgrado, etc
    es_vigente                  BIT NOT NULL DEFAULT 1,
    fecha_carga                 DATETIME NOT NULL DEFAULT GETDATE()
);

-- ===== ÍNDICES =====
CREATE NONCLUSTERED INDEX IX_stg_estudiantes_PIDM ON stg.estudiantes(pidm);
CREATE NONCLUSTERED INDEX IX_stg_curricula_PIDM_TERMINO ON stg.curricula(pidm, codigo_termino);
CREATE NONCLUSTERED INDEX IX_mat_matriculas_ESTUDIANTE ON mat.matriculas(id_estudiante);
CREATE NONCLUSTERED INDEX IX_ben_beneficios_ESTUDIANTE ON ben.beneficios(id_estudiante);

GO

-- ===== VERIFICACIÓN =====
PRINT '';
PRINT '✓ Base de datos BI_Assessment_Staging creada exitosamente';
PRINT '✓ Esquemas creados: stg, cat, mat, ben';
PRINT '✓ Tablas creadas: 8 tablas';
PRINT '';

SELECT 
    OBJECT_SCHEMA_NAME(o.object_id) AS SchemaName,
    o.name AS TableName,
    (SELECT COUNT(*) FROM sys.columns c WHERE c.object_id = o.object_id) AS ColumnCount
FROM sys.objects o
WHERE o.type = 'U'
ORDER BY SchemaName, TableName;
