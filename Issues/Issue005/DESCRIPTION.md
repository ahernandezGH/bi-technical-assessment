# Issue 005 - Detalle

## Contexto
`erp_person_identity` almacena historial de identidades. Se requiere derivar la fila vigente por PIDM segun precedencia: `activity_date DESC, person_surrogate_id DESC`. 50 PIDM tienen multiples vigentes para probar el algoritmo.

## Tareas
1) Analizar los datos fuente en `QA_AnalisisDatosOrigen.sql`:
   - Conteo de PIDM totales y PIDM con multiples vigentes
   - Distribucion de `name_change_indicator` (NULL, 'C', otros)
2) Implementar `PROC_ExtractCurrentRecords.sql` que retorne (o inserte en tabla destino) los registros vigentes:
   - Regla: ROW_NUMBER() OVER (PARTITION BY pidm ORDER BY activity_date DESC, person_surrogate_id DESC) = 1
   - Manejar `name_change_indicator` NULL como vigente
3) Validar en `QA_ValidacionResultados.sql`:
   - 1 registro vigente por PIDM
   - Sin PIDM perdidos

## Consideraciones
- No modificar la tabla origen
- Si guardas resultado en staging, limpia la tabla destino antes de insertar
- Documenta supuestos en `METODOLOGIA_Extraccion.md`

## Definicion de listo
- Procedimiento ejecuta sin errores y produce conjunto vigente
- QA confirma cardinalidad correcta
- Documentacion describe precedencia y manejo de NULL
