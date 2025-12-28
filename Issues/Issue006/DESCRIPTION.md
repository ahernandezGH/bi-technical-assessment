# Issue 006 - Detalle

## Contexto
Se requiere una tabla de hechos de pagos para analitica (monto, conteo, morosidad, promedio). Se debe definir el grain (transaccion o diario) y las dimensiones asociadas.

## Tareas
1) Definir en `PLAN_FactTableDesign.md`:
   - Grain elegido (p.ej. una fila por pago o por dia-estudiante-tipo)
   - Medidas y clasificacion (additive, semi-additive)
   - Politica de retencion (7 anos) y particion si aplica
2) Crear dims si faltan:
   - `dim_tipo_pago` (codigo, descripcion, categoria)
   - `dim_fecha` (rango suficiente para 7 anos)
3) Crear `hechos_pagos` con claves surrogate y FK a dimensiones; incluir PK/unique acorde al grain.
4) QA en `QA_ValidarGranularidad.sql`: validar grain unico y FKs validas.

## Consideraciones
- Si usas grain transaccion, considera un campo `id_pago` surrogate
- Si usas grain diario, documenta reglas de agregacion
- Medidas sugeridas: monto_pago (additive), saldo_pendiente (semi-additive), conteo_transacciones (additive)

## Definicion de listo
- Scripts de creacion compilan
- QA confirma grain y FKs
- Documentacion explica decisiones y trade-offs
