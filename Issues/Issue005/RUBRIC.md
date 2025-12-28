# Rubrica - Issue 005

| Dimension | Peso | Criterio |
|-----------|------|----------|
| Correccion | 40% | Seleccion correcta del vigente por PIDM; sin perdidas |
| Logica de precedencia | 30% | ORDER BY deterministico con ROW_NUMBER; manejo de NULL explicito |
| Documentacion | 20% | Metodologia y supuestos claros; QA con conteos antes/despues |
| Calidad codigo | 10% | Set-based, sin cursores; nombres claros |

## Escala
- Excelente: QA completa, precedencia robusta, doc clara
- Bueno: Logica correcta, QA basica
- Aceptable: Detalles faltantes en QA o supuestos
- Insuficiente: Vigentes incorrectos o perdida de registros
