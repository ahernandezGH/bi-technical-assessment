# Issue 007 - Vista Multi-Tabla ERP Académico

Nivel: Alto (4-5 horas)
Habilidad principal: Joins multi-tabla con precedencia y manejo de NULL

## Objetivo
Construir una vista consolidada que integre identidad, curriculum y terminos ERP con precedencia y manejo de NULL (`rate_code`).

## Datos base
- Tablas: `erp_person_identity`, `erp_student_curriculum`, `erp_term_catalog`
- Regla de identidad vigente igual a Issue 005
- Precedencia curriculum: `priority_no ASC, key_seqno DESC`

## Entregables requeridos
- `QA_AnalisisRelaciones.sql` (verifica cardinalidades y casos con multiples vigentes)
- `CREATE_VIEW_v_estudiantes_programa_vigente.sql`
- `QA_ValidacionVista.sql` (conteos y null handling)
- `SOLUTION.md`

## Criterios de aceptacion
- Una fila por PIDM vigente con programa vigente segun precedencia
- `rate_code` nulo reemplazado por 'No Disponible'
- Sin duplicados ni perdidas de PIDM

## Restricciones
- Precedencia debe ser deterministica
- No usar TOP sin ORDER BY
- Evitar subconsultas correlacionadas pesadas; preferir CTE con window functions

## Como probar
1) QA de origen: PIDM con multiples vigentes en identidad y curriculum
2) Crear vista y validar conteo = PIDM vigentes
3) Verificar que `rate_code` sin valor muestra 'No Disponible'
