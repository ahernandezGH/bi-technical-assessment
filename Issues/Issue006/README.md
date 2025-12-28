# Issue 006 - Diseno de Tabla de Hechos de Pagos

Nivel: Alto (5-7 horas)
Habilidad principal: Diseno de grain de hechos y medidas

## Objetivo
Disenar `hechos_pagos` con grain transaccion (o diario justificado), definiendo medidas additive/semi-additive y dimensiones requeridas.

## Datos base
- Fuente esperada: pagos por estudiante, fecha, tipo de pago
- Dimensiones disponibles: `dim_estudiantes`, `dim_fecha`, `dim_tipo_pago` (crear si no existe)

## Entregables requeridos
- `PLAN_FactTableDesign.md` (grain, medidas, retencion)
- `DIAGRAM_ModeloDimensional.md` (hechos_pagos y dimensiones)
- `CREATE_TABLE_hechos_pagos.sql`
- `CREATE_TABLE_dim_tipo_pago.sql` (si no existe)
- `CREATE_TABLE_dim_fecha.sql` (si no existe)
- `CREATE_INDEXES_hechos_pagos.sql`
- `QA_ValidarGranularidad.sql`
- `SOLUTION.md`

## Criterios de aceptacion
- Grain definido y coherente con medidas
- Medidas clasificadas (additive, semi-additive)
- FK hacia dimensiones clave
- Retencion 7 anos considerada

## Restricciones
- No mezclar granos; si usas diario, justifica agregacion
- Dim_fecha debe soportar rangos requeridos
- Documentar cualquier suposicion de fuente

## Como probar
1) Crear dims necesarias (fecha, tipo_pago) si faltan
2) Crear hechos y cargar dataset de prueba pequeño
3) QA: validar grain (unico por PK) y FK validas
