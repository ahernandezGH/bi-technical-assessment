# Issue 004 - Detalle

## Contexto
Se requiere agregar la jerarquia de cohortes al modelo. Cohorte puede definirse como combinacion de anio de ingreso y periodo, o segun reglas del programa. Debe diseñarse una dimension dedicada y enlazar hechos_matricula.

## Tareas
1) Definir grain y atributos de `dim_cohortes` en `PLAN_DimensionDesign.md`.
2) Elegir SCD Type (1 vs 2) y justificarlo. Si Type 2, incluir vigencia.
3) Crear tabla y indices (scripts separados) y actualizar `hechos_matricula` para referenciar `id_cohorte`.
4) Implementar `PROC_SincronizarDimensionCohortes` que:
   - Derive cohorte desde datos existentes (term_code, programa, anyo_ingreso si aplica)
   - Inserte nuevas cohortes evitando duplicados
5) QA: `QA_ValidarIntegridadReferencial.sql` para asegurar que todos los hechos tienen cohorte valida.

## Consideraciones
- Mantener surrogate key (`id_cohorte`) y clave de negocio (codigo_cohorte)
- Cohorte deberia ser estable; si esperas cambios historicos, usa Type 2
- Atributos sugeridos: codigo_cohorte, anyo_ingreso, periodo, jornada, estado

## Definicion de listo
- Tabla creada con indices y FK aplicado
- SP de sincronizacion carga cohortes derivadas
- QA confirma 0 referencias nulas o huérfanas
