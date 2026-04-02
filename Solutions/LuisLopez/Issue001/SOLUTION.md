# **Solución Issue 001**

**Candidato**: Luis Enrique Lopez Zapata

**Fecha**: 2026-04-02

## Problema identificado

Se encontró una inconsistencia en el Data Warehouse (`BI_Assessment_DWH`). En la tabla de hechos `mat.hechos_matricula`, se identificaron registros que no poseen un estudiante relacionado en la dimensión maestra `cat.dim_estudiantes`. Este problema invalida los reportes, ya que genera métricas que no pueden ser atribuidas a una persona real. Se determinó que ocurre por una falta de validación en el proceso de carga (ETL), al no verificar la existencia de las Llaves Foráneas (FK) antes de la inserción

## **Estrategia de Solución**

1. **Detección de registros huérfanos (`QA_ValidarIntegridadEstudiantes.sql`)**: Se implementó una consulta con `LEFT JOIN` para buscar registros de hechos sin correspondencia. El query retornó los **15 huérfanos** propuestos en el ejercicio

2. **Prevención antes de insertar (`PROC_ValidarIntegridadPreInsert.sql`)**: Se desarrolló un *stored procedure* que recibe el ID de un estudiante y verifica su existencia en la tabla maestra. Si el ID existe, retorna éxito; si no, lanza un `RAISERROR` con nivel de severidad 16.

### Pruebas Ejecutadas

Se validó el funcionamiento con el siguiente resultado en consola:

```sql
-- Prueba con ID existente (1) y ID inexistente (99999)
>>> ✓ Validación exitosa: El estudiante existe en la dimensión.

Msg 50000, Level 16, State 1, Procedure mat.sp_ValidarIntegridadPreInsert
ID estudiante 99999 no existe en dimension
```

## Conclusiones

Se lograron los productos requeridos con el funcionamiento esperado. Como pasos a seguir, se recomienda eliminar los registros huérfanos que se identificaron el  **`QA_ValidarIntegridadEstudiantes.sql` .** De igual manera se recomienda integrar el SP en los procesos de carga automáticos para impedir que vuelvan a entrar datos inconsistentes al DW.