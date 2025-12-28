# Issue 003 - Refactorizacion de ETL Complejo

Nivel: Alto (6-8 horas)
Habilidad principal: Arquitectura ETL y modularizacion

## Objetivo
Refactorizar un procedimiento monolitico de carga de beneficios en modulos claros (extract, validate, transform, materialize) y orquestarlos.

## Datos base
- Procedimiento origen: `ETL_CargaBeneficios_MONOLITO.sql` (450 lineas, ver DESCRIPTION para esqueleto)
- Tablas: `stg.beneficios`, `ben.hechos_beneficios`, `cat.dim_estudiantes`, `cat.dim_programas`

## Entregables requeridos
- `PLAN_Refactorizacion.md` (division en modulos y flujo)
- `PROC_ExtractBeneficiosStagging.sql`
- `PROC_ValidateBeneficiosData.sql`
- `PROC_TransformBeneficiosToDWH.sql`
- `PROC_MaterializeBeneficiosViews.sql`
- `PROC_ETL_CargaBeneficiosOrquestador.sql` (llama en orden y registra resultados)
- `TEST_ETL_Refactorizado.sql` (pruebas basicas)
- `SOLUTION.md` (decisiones y resultados)

## Criterios de aceptacion
- Separacion de responsabilidades (cada SP hace una cosa)
- Manejo de errores centralizado y logging basico
- Idempotencia: re-ejecutar no duplica datos
- Cobertura de pruebas minimas (al menos 1 happy path y 1 error controlado)

## Restricciones
- No usar cursores; preferir set-based
- Logging simple: tabla de log o PRINT, pero consistente
- Evitar transacciones largas; usar unidades atomicas

## Como probar
1) Ejecutar orquestador: valida, transforma, carga
2) Forzar un error en validacion y comprobar rollback o salida controlada
3) Repetir ejecucion y confirmar que no duplica (idempotencia)
