# Issue 001 - Validacion de Integridad de Datos

Nivel: Basico (2-4 horas)
Habilidad principal: T-SQL (integridad referencial)

## Objetivo
Detectar e impedir carga de registros en `mat.hechos_matricula` con `id_estudiante` inexistente en `cat.dim_estudiantes`.

## Datos base
- 15 registros huérfanos insertados en `BI_Assessment_DWH.mat.hechos_matricula` (id_estudiante > 99980)
- Tablas de referencia: `cat.dim_estudiantes`, `cat.dim_terminos`, `cat.dim_programas`

## Entregables requeridos
- `QA_ValidarIntegridadEstudiantes.sql` (query de hallazgo y conteo)
- `PROC_ValidarIntegridadPreInsert.sql` (SP con guard clauses y retorno de errores)
- `SOLUTION.md` (explica estrategia, pruebas y hallazgos)

## Criterios de aceptacion
- El SP bloquea inserciones huérfanas y devuelve codigo/descripcion de error
- El query de QA devuelve exactamente 15 huérfanos iniciales
- No se eliminan datos, solo se validan o rechazan
- Manejo de errores con TRY/CATCH y `THROW`

## Restricciones
- No deshabilitar constraints definitivas
- No usar cursors
- Mantener idioma SQL estandar (sin dependencias a funciones CLR)

## Como probar
1) Ejecutar `QA_ValidarIntegridadEstudiantes.sql` y confirmar 15 huérfanos
2) Probar el SP insertando un registro huérfano simulado (esperar error controlado)
3) Probar con registro valido (esperar insercion exitosa)
