# Issue 001 - Detalle

## Contexto
En el DWH existen 15 filas en `mat.hechos_matricula` cuyos `id_estudiante` no existen en `cat.dim_estudiantes`. Esto representa riesgo de integridad y doble conteo en vistas analiticas.

## Datos disponibles
- DWH: `BI_Assessment_DWH`
- Tablas clave: `mat.hechos_matricula`, `cat.dim_estudiantes`, `cat.dim_terminos`, `cat.dim_programas`
- Edge case: `id_estudiante` > 99980 insertados como huérfanos

## Tareas
1. Escribir un query de diagnostico que:
   - Devuelva el conteo de huérfanos y un muestreo
   - Confirme claves: estudiante, termino, programa
2. Diseñar y crear un stored procedure `PROC_ValidarIntegridadPreInsert` que:
   - Reciba los parametros minimos del hecho (id_estudiante, id_termino, id_programa, etc.)
   - Valide existencia de claves en las dimensiones
   - Devuelva codigo/descripcion de error si alguna FK no existe
   - Permita continuar si todo es valido
3. Documentar en `SOLUTION.md`:
   - Enfoque de validacion
   - Pruebas ejecutadas (incluye caso valido y caso huérfano)
   - Como integrar el SP en una carga futura (pseudo orquestador)

## Consideraciones
- No modificar ni borrar los 15 registros iniciales; usalos como dataset de prueba
- El SP debe ser idempotente y seguro para concurrencia (sin transacciones abiertas prolongadas)
- Evitar SET XACT_ABORT OFF; preferir transaccion corta con TRY/CATCH

## Definicion de listo
- El SP compila y maneja errores con `THROW`
- El query de QA identifica 15 huérfanos iniciales
- Se describe como orquestar la llamada del SP antes de insertar hechos
