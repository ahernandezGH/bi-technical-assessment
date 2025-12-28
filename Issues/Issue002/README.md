# Issue 002 - Optimizacion de Vista

Nivel: Medio (4-6 horas)
Habilidad principal: Performance SQL y planes de ejecucion

## Objetivo
Reducir el tiempo de respuesta de la vista `v_matricula_beneficios` (actual ~45s, meta <5s) mediante reescritura y/o indices.

## Datos base
- Vista lenta esperada: `v_matricula_beneficios` (crear en tu rama si no existe usando el script lento provisto en DESCRIPTION)
- Tablas: `mat.hechos_matricula`, `ben.hechos_beneficios`, `cat.dim_estudiantes`, `cat.dim_programas`, `cat.dim_terminos`

## Entregables requeridos
- `QA_AnalisisPerformance.sql` (captura actual: IO, CPU, tiempo)
- `ALTER_v_matricula_beneficios_Optimizada.sql` o `CREATE VIEW` equivalente
- `CREATE_IndicesRecomendados.sql` (si aplica)
- Planes de ejecucion antes/despues (guardar como comentarios o texto)
- `SOLUTION.md` (explica cambios, trade-offs, mediciones)

## Criterios de aceptacion
- Tiempo esperado <5 segundos en dataset actual
- Evita scans innecesarios; se justifican los indices propuestos
- Sin duplicar registros y sin cambiar grain de la vista

## Restricciones
- No usar NOLOCK
- No forzar hints arbitrarios; justificar si usas OPTIMIZE FOR u OPTION(RECOMPILE)
- Mantener legibilidad y set-based logic

## Como probar
1) Capturar tiempo/IO de la version lenta
2) Aplicar vista optimizada e indices sugeridos
3) Repetir medicion y documentar mejora
