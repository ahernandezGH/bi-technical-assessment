# Issue 002 - Detalle

## Contexto
La vista `v_matricula_beneficios` une matriculas y beneficios con subconsultas correlacionadas. El tiempo actual es ~45s. Debe optimizarse a <5s sin alterar resultados.

## Artefacto base
Si la vista no existe en tu entorno, crea la version lenta con este esqueleto (ajusta nombres de esquemas si es necesario):

```sql
CREATE OR ALTER VIEW mat.v_matricula_beneficios AS
SELECT m.id_matricula,
       m.id_estudiante,
       m.id_programa,
       b.monto_beneficio,
       b.tipo_beneficio,
       (SELECT TOP 1 t.term_code FROM cat.dim_terminos t WHERE t.id_termino = m.id_termino) AS term_code,
       (SELECT COUNT(*) FROM ben.hechos_beneficios b2 WHERE b2.id_estudiante = m.id_estudiante) AS beneficios_count
FROM mat.hechos_matricula m
LEFT JOIN ben.hechos_beneficios b ON b.id_estudiante = m.id_estudiante;
```

## Tareas
1) Medir la version actual (tiempo, IO, plan de ejecucion) y documentar en `QA_AnalisisPerformance.sql`.
2) Reescribir la vista eliminando subconsultas correlacionadas y aplicando joins set-based.
3) Proponer y crear indices para soportar la vista (archivo `CREATE_IndicesRecomendados.sql`).
4) Documentar mejoras en `SOLUTION.md` con comparativas antes/despues.

## Consideraciones
- Mantener misma cardinalidad (no duplicar filas)
- Orden de columnas puede variar, pero el resultado logico debe coincidir
- Si se usan CTEs, explicar por que mejoran el plan

## Definicion de listo
- Vista optimizada compila y retorna mismo conteo de filas que la version lenta
- Medicion antes/despues documentada
- Indices propuestos creados y justificados
