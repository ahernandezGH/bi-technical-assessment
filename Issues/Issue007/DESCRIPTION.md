# Issue 007 - Detalle

## Contexto
Se necesita una vista consolidada que navegue tres tablas ERP:
1) `erp_person_identity` (identidad vigente)
2) `erp_student_curriculum` (programa vigente con precedencia `priority_no ASC, key_seqno DESC`)
3) `erp_term_catalog` (datos del termino)

## Tareas
1) Analizar relaciones en `QA_AnalisisRelaciones.sql`:
   - PIDM totales
   - PIDM con multiples vigentes en identidad y curriculum
   - Casos sin term_code valido
2) Crear `CREATE_VIEW_v_estudiantes_programa_vigente.sql`:
   - Selecciona identidad vigente (misma regla que Issue 005)
   - Selecciona programa vigente por precedencia
   - Une terminos para exponer `term_code`, fechas
   - Reemplaza `rate_code` NULL con 'No Disponible'
3) Validar en `QA_ValidacionVista.sql`:
   - Conteo filas = PIDM vigentes
   - Sin duplicados de PIDM
   - rate_code sin NULL

## Consideraciones
- Usa ROW_NUMBER para precedencia en identidad y curriculum
- Asegura orden deterministico
- Usa CTEs para claridad

## Definicion de listo
- Vista compila y entrega una fila por PIDM vigente
- QA confirma conteos y manejo de NULL
- Documentacion resume logica de precedencia
