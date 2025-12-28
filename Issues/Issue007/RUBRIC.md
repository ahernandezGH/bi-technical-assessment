# Rubrica - Issue 007

| Dimension | Peso | Criterio |
|-----------|------|----------|
| Correccion | 40% | Una fila por PIDM vigente; precedencia correcta; sin duplicados |
| Precedencia | 30% | ROW_NUMBER deterministico para identidad y curriculum; join correcto con terminos |
| Manejo NULL | 20% | rate_code reemplazado por 'No Disponible'; otros NULL manejados si aplica |
| Documentacion | 10% | QA y SOLUTION explican logica y pruebas |

## Escala
- Excelente: Vista clara con CTEs, precedencia correcta, QA solida
- Bueno: Logica correcta, QA basica
- Aceptable: Detalles faltantes en QA o manejos parciales de NULL
- Insuficiente: Duplicados, precedencia incorrecta o conteos errados
