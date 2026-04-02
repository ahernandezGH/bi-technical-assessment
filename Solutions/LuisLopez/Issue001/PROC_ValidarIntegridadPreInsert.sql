-- ============================================================================
-- STORED PROCEDURE
-- PROPÓSITO: Validar integridad referencial de id_estudiante antes del insert.
-- AUTOR: Luis Enrique Lopez Zapata
-- FECHA: 2026-04-02
-- ============================================================================

USE BI_Assessment_DWH;
GO

CREATE OR ALTER PROCEDURE [mat].[sp_ValidarIntegridadPreInsert]
    @id_estudiante INT
AS
BEGIN
    BEGIN TRY
        -- 1. VALIDACIÓN DE EXISTENCIA
        -- Verifica si el ID existe en la tabla maestra (dimensión)
        IF NOT EXISTS (SELECT 1 FROM cat.dim_estudiantes WHERE id_estudiante = @id_estudiante)
        BEGIN
            -- Si no existe, genera un error de severidad 16 (Error de usuario)
            RAISERROR('ID estudiante %d no existe en dimension', 16, 1, @id_estudiante);
            
            -- Retornar 1 para indicar fallo
            RETURN 1;
        END

        -- 2. VALIDACIÓN EXITOSA
        -- Si el flujo llega aquí, la integridad está garantizada
        PRINT '✓ Validación exitosa: El estudiante existe en la dimensión.';
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- 3. MANEJO DE EXCEPCIONES
        -- Captura cualquier error inesperado y lo re-lanza con RAISERROR
        DECLARE @Msg NVARCHAR(MAX) = ERROR_MESSAGE();
        RAISERROR(@Msg, 16, 1);
        
        -- Retornar 1 para asegurar que el error detenga la ejecución externa
        RETURN 1;
    END CATCH
END;
GO