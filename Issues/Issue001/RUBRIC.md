# Rubrica - Issue 001

| Dimension | Peso | Criterio |
| ----------- | ------ | ---------- |
| Correccion | 50% | SP bloquea huérfanos y retorna error controlado; QA detecta 15 huérfanos |
| Calidad codigo | 30% | Uso de TRY/CATCH, THROW, parametros tipados, sin cursors |
| Documentacion | 20% | SOLUTION.md explica enfoque, pruebas (valido/huérfano) y como integrar el SP |

## Escala

- Excelente (90-100): SP robusto con mensajes claros, QA preciso, pruebas incluidas
- Bueno (70-89): Valida claves y maneja errores; documentacion breve pero suficiente
- Aceptable (50-69): Valida parcialmente o sin mensajes claros; documentacion minima
- Insuficiente (<50): No bloquea huérfanos, errores no controlados, falta documentacion
