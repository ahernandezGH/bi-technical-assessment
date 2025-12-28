# Issue 004 - Diseno de Dimension Jerarquica (Cohortes)

Nivel: Medio (4-6 horas)
Habilidad principal: Modelado dimensional (SCD)

## Objetivo
Disenar la dimension `dim_cohortes` y enlazarla a `hechos_matricula`, justificando SCD, grain y atributos.

## Datos base
- Tablas actuales: `mat.hechos_matricula`, `cat.dim_estudiantes`, `cat.dim_terminos`, `cat.dim_programas`
- Cohorte derivable desde terminos y programas (definir logica)

## Entregables requeridos
- `PLAN_DimensionDesign.md` (justificacion de SCD, grain, atributos)
- `DIAGRAM_ModeloDimensional.md` (diagrama ER simple con dim_cohortes y relaciones)
- `CREATE_TABLE_dim_cohortes.sql`
- `CREATE_INDEXES_dim_cohortes.sql`
- `ALTER_hechos_matricula.sql` (agrega FK a cohorte)
- `PROC_SincronizarDimensionCohortes.sql`
- `QA_ValidarIntegridadReferencial.sql`
- `SOLUTION.md` (resumen de decisiones y pruebas)

## Criterios de aceptacion
- Cohorte con clave surrogate y atributo de negocio
- SCD justificado (Type 1 o 2) y consistente
- FK a hechos_matricula creado y validado

## Restricciones
- Mantener grain de hechos_matricula (no duplicar)
- Si usas Type 2, define columnas de vigencia (fecha_inicio, fecha_fin, es_vigente)
- Diagrama en texto/markdown (no requiere imagen)

## Como probar
1) Ejecutar sincronizacion de cohortes
2) Verificar que hechos_matricula referencia una cohorte valida
3) QA de integridad referencial y conteos
