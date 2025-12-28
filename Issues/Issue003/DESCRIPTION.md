# Issue 003 - Detalle

## Contexto
Existe un procedimiento monolitico `ETL_CargaBeneficios` (~450 lineas) con multiples responsabilidades: extrae, valida, transforma y materializa. Se requiere modularizar y mejorar mantenibilidad.

## Artefacto base (esqueleto simplificado)
```sql
CREATE OR ALTER PROCEDURE ben.ETL_CargaBeneficios_MONOLITO
AS
BEGIN
    SET NOCOUNT ON;
    -- Extrae desde stg.beneficios
    -- Valida duplicados y FK
    -- Transforma formatos y normaliza
    -- Inserta en ben.hechos_beneficios
    -- Refresca vistas de consumo
END;
```

## Tareas
1) Proponer arquitectura modular en `PLAN_Refactorizacion.md` con 4 fases: Extract, Validate, Transform, Materialize.
2) Implementar SPs por fase (nombres sugeridos en README) y un orquestador que las llame en secuencia con control de errores.
3) Agregar validaciones basicas: FK contra `cat.dim_estudiantes` y `cat.dim_programas`, nulos obligatorios, rango de montos.
4) Proveer script `TEST_ETL_Refactorizado.sql` con al menos:
   - Caso exitoso
   - Caso con FK inexistente (debe fallar controladamente)

## Consideraciones
- Manejar errores con TRY/CATCH y `THROW`; registrar mensaje y paso
- Usar transacciones cortas por paso, no una unica transaccion larga
- Preparar para futuras extensiones (p.ej. paginacion o carga incremental)

## Definicion de listo
- Orquestador ejecuta las 4 fases en orden y retorna estado final
- Re-ejecucion no duplica datos ya insertados (idempotencia basica)
- Documentacion describe decisiones y trade-offs
