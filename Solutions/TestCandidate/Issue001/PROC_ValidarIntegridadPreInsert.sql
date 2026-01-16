/*
================================================================================
STORED PROCEDURE - Validar Integridad Pre-Insert
Candidato: Juan Perez
================================================================================
*/

USE BI_Assessment_DWH;
GO

CREATE OR ALTER PROCEDURE mat.spValidarIntegridadPreInsert
    @id_estudiante BIGINT,
    @id_termino BIGINT,
    @id_programa BIGINT,
    @resultado BIT OUTPUT,
    @mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    basura
    BEGIN TRY
        -- Validar estudiante
        IF NOT EXISTS (SELECT 1 FROM cat.dim_estudiantes WHERE id_estudiante = @id_estudiante)
        BEGIN
            SET @resultado = 0;
            SET @mensaje = 'FK invalido: id_estudiante no existe';
            RETURN;
        END
        
        -- Validar termino
        IF NOT EXISTS (SELECT 1 FROM cat.dim_terminos WHERE id_termino = @id_termino)
        BEGIN
            SET @resultado = 0;
            SET @mensaje = 'FK invalido: id_termino no existe';
            RETURN;
        END
        
        -- Validar programa
        IF NOT EXISTS (SELECT 1 FROM cat.dim_programas WHERE id_programa = @id_programa)
        BEGIN
            SET @resultado = 0;
            SET @mensaje = 'FK invalido: id_programa no existe';
            RETURN;
        END
        
        SET @resultado = 1;
        SET @mensaje = 'Validacion exitosa';
        
    END TRY
    BEGIN CATCH
        SET @resultado = 0;
        SET @mensaje = ERROR_MESSAGE();
    END CATCH
END;
GO
