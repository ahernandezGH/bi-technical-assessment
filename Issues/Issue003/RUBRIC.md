# Rubrica - Issue 003

| Dimension | Peso | Criterio |
|-----------|------|----------|
| Arquitectura | 35% | Separacion clara de fases, orquestador simple y seguro |
| Correccion | 30% | Valida FK, nulos obligatorios, rangos; idempotencia basica |
| Mantenibilidad | 25% | Codigo modular, nombres claros, sin logica duplicada |
| Documentacion | 10% | PLAN y SOLUTION describen flujo, errores y pruebas |

## Escala
- Excelente: Fases bien definidas, control de errores y logging coherente, pruebas cubren error y exito
- Bueno: Modularizacion correcta, error handling basico, pruebas minimas
- Aceptable: Separacion parcial, pocas pruebas, documentacion breve
- Insuficiente: Sigue siendo monolitico o sin manejo de errores
