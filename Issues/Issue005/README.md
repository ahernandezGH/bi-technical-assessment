# Issue 005 - Extraccion ERP Historica (Identidades)

Nivel: Medio (3-5 horas)
Habilidad principal: Precedencia y derivacion de registros vigentes

## Objetivo
Derivar registros vigentes de `erp_person_identity` aplicando precedencia por `activity_date DESC, person_surrogate_id DESC`, preservando trazabilidad historica.

## Datos base
- Tabla fuente: `SchoolERP_Source.dbo.erp_person_identity` (5000+ registros simulados)
- 50 PIDM con multiples vigentes intencionalmente

## Entregables requeridos
- `METODOLOGIA_Extraccion.md` (reglas de precedencia y supuestos)
- `QA_AnalisisDatosOrigen.sql` (conteos, duplicados, casos con multiples vigentes)
- `PROC_ExtractCurrentRecords.sql` (devuelve/almacena registros vigentes)
- `QA_ValidacionResultados.sql` (confirma 1 vigente por PIDM)
- `SOLUTION.md`

## Criterios de aceptacion
- Un unico registro vigente por PIDM, elegido por precedencia definida
- Historico se mantiene sin alteraciones
- Manejo explicito de NULL en name_change_indicator

## Restricciones
- No borrar historico
- No usar TOP sin ORDER BY deterministico
- Set-based; sin cursores

## Como probar
1) Ejecutar QA origen: contar PIDM con multiples vigentes
2) Ejecutar PROC y validar salida (tabla o temp table)
3) QA final: 1 vigente por PIDM; ningun PIDM perdido
