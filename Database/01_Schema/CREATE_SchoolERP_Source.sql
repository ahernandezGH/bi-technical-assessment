/*
===============================================================================
SCRIPT: CREATE_SchoolERP_Source.sql
PROPÓSITO: Crear base de datos SchoolERP_Source con tablas históricas ERP
AUTOR: BI Team
FECHA: Diciembre 2025
DESCRIPCIÓN:
  - Crea 3 tablas ERP: erp_person_identity, erp_student_curriculum, erp_term_catalog
  - Datos históricos con indicadores de vigencia
  - Sin indexación inicial (se agrega en Fase 2)
  - Naming neutral (no referencias UFT)
DEPENDENCIAS: SQL Server 2019+
===============================================================================
*/

-- ===== CREAR BASE DE DATOS =====
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'SchoolERP_Source')
BEGIN
    ALTER DATABASE [SchoolERP_Source] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [SchoolERP_Source];
END
GO

CREATE DATABASE [SchoolERP_Source]
GO

USE [SchoolERP_Source]
GO

-- ===== TABLA 1: erp_person_identity =====
-- Historial de identidades de personas (PIDM = Person ID)
-- Vigente: name_change_indicator IS NULL O 'C'
-- Histórico: Otros valores (actividad anterior)

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'erp_person_identity')
    DROP TABLE dbo.erp_person_identity;
GO

CREATE TABLE dbo.erp_person_identity
(
    person_surrogate_id         BIGINT IDENTITY(1,1) PRIMARY KEY,
    pidm                        INT NOT NULL,                  -- Person ID (NO es único, hay histórico)
    first_name                  VARCHAR(50) NOT NULL,
    middle_name                 VARCHAR(50) NULL,
    last_name                   VARCHAR(50) NOT NULL,
    birth_date                  DATE NULL,
    activity_date               DATE NOT NULL,                -- Fecha de esta versión
    name_change_indicator       CHAR(1) NULL,                 -- NULL/'C' = Vigente, otros = Histórico
    email_address               VARCHAR(100) NULL,
    phone_number                VARCHAR(20) NULL,
    created_date                DATETIME NOT NULL DEFAULT GETDATE(),
    modified_date               DATETIME NOT NULL DEFAULT GETDATE()
);

-- ===== TABLA 2: erp_student_curriculum =====
-- Programa de estudiante por término
-- Precedencia: priority_no ASC, key_seqno DESC (en ese orden)

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'erp_student_curriculum')
    DROP TABLE dbo.erp_student_curriculum;
GO

CREATE TABLE dbo.erp_student_curriculum
(
    student_curriculum_id       BIGINT IDENTITY(1,1) PRIMARY KEY,
    pidm                        INT NOT NULL,
    term_code                   VARCHAR(10) NOT NULL,         -- Código de término (ej: 202501)
    program_code                VARCHAR(20) NOT NULL,         -- Código de programa
    program_name                VARCHAR(100) NOT NULL,
    priority_no                 INT NOT NULL DEFAULT 0,       -- Menor = mayor prioridad
    key_seqno                   INT NOT NULL DEFAULT 0,       -- Desempate secundario
    rate_code                   VARCHAR(10) NULL,             -- Tipo de matrícula (puede ser NULL)
    gpa                         DECIMAL(4,2) NULL,
    credit_hours                DECIMAL(6,2) NULL,
    enrollment_date             DATE NOT NULL,
    activity_date               DATE NOT NULL,
    created_date                DATETIME NOT NULL DEFAULT GETDATE(),
    modified_date               DATETIME NOT NULL DEFAULT GETDATE()
);

-- ===== TABLA 3: erp_term_catalog =====
-- Catálogo de términos académicos

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'erp_term_catalog')
    DROP TABLE dbo.erp_term_catalog;
GO

CREATE TABLE dbo.erp_term_catalog
(
    term_catalog_id             BIGINT IDENTITY(1,1) PRIMARY KEY,
    term_code                   VARCHAR(10) NOT NULL UNIQUE,
    term_name                   VARCHAR(50) NOT NULL,         -- Ej: "2025-A"
    term_year                   INT NOT NULL,
    term_sequence               INT NOT NULL,                 -- 1=A, 2=B, 3=C
    start_date                  DATE NOT NULL,
    end_date                    DATE NOT NULL,
    is_active                   BIT NOT NULL DEFAULT 1,
    created_date                DATETIME NOT NULL DEFAULT GETDATE(),
    modified_date               DATETIME NOT NULL DEFAULT GETDATE()
);

-- ===== ÍNDICES BÁSICOS (opcional para Fase 1) =====
-- Crear índices no-clustered para búsquedas frecuentes
CREATE NONCLUSTERED INDEX IX_erp_person_identity_PIDM 
    ON dbo.erp_person_identity(pidm, activity_date DESC, person_surrogate_id DESC);

CREATE NONCLUSTERED INDEX IX_erp_student_curriculum_PIDM_TERM 
    ON dbo.erp_student_curriculum(pidm, term_code);

CREATE NONCLUSTERED INDEX IX_erp_term_catalog_CODE 
    ON dbo.erp_term_catalog(term_code);

GO

-- ===== VERIFICACIÓN =====
PRINT '';
PRINT '✓ Base de datos SchoolERP_Source creada exitosamente';
PRINT '✓ Tablas creadas: erp_person_identity, erp_student_curriculum, erp_term_catalog';
PRINT '✓ Índices básicos creados';
PRINT '';
SELECT 
    TABLE_NAME,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS c WHERE c.TABLE_NAME = t.TABLE_NAME) AS ColumnCount
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_SCHEMA = 'dbo';
