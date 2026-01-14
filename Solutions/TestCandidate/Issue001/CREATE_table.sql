-- =====================================================================
-- Script: CREATE_table.sql
-- Autor: Sistema de Validacion UFT
-- Fecha: 2025-01-14
-- Issue: Issue001 - Modelado Dimensional Persona
-- =====================================================================

CREATE TABLE [dbo].[dim_personas] (
    -- Surrogate Key
    id_persona BIGINT IDENTITY(1,1) NOT NULL,
    
    -- Natural Key
    codigo_persona VARCHAR(20) NOT NULL,
    
    -- Atributos dimensionales
    nombre_completo VARCHAR(200) NOT NULL,
    correo_electronico VARCHAR(100) NULL,
    fecha_nacimiento DATE NULL,
    
    -- Metadatos de auditoria
    fecha_insercion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    
    -- Constraints
    CONSTRAINT PK_dim_personas PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT UQ_dim_personas_codigo UNIQUE NONCLUSTERED (codigo_persona)
);

-- Indices adicionales para optimizacion
CREATE NONCLUSTERED INDEX IX_dim_personas_nombre 
    ON [dbo].[dim_personas] (nombre_completo);
