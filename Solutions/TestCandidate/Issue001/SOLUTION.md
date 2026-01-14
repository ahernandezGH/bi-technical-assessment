# Solución Issue 001 - Data Integrity Validation

**Candidato:** Juan Pérez  
**Fecha:** 2025-12-28  
**Issue:** 001 - Validación de Integridad Referencial

## Problema Identificado

La tabla `mat.hechos_matricula` contiene **15 registros huérfanos** con `id_estudiante` entre 99985-99999 que no existen en `cat.dim_estudiantes`. Esto representa un problema crítico de integridad referencial que:

- Genera errores en reportes con INNER JOIN
- Distorsiona métricas de matrícula
- Indica falta de validación en ETL

## Estrategia de Solución

### 1. Detección de Huérfanos (QA_ValidarIntegridadEstudiantes.sql)

Implementé consulta con **LEFT JOIN** para detectar registros sin correspondencia en dimensión estudiantes. La query retorna los 15 huérfanos esperados con identificación clara del problema.

### 2. Prevención Pre-Insert (PROC_ValidarIntegridadPreInsert.sql)

Creé stored procedure de validación con:

- **INPUT:** id_estudiante, id_termino, id_programa, id_cohorte
- **OUTPUT:** @resultado BIT (0=inválido, 1=válido), @mensaje VARCHAR(500)
- **LÓGICA:** Verificar EXISTS en cada dimensión antes de permitir insert
- **MANEJO ERRORES:** TRY/CATCH con mensajes descriptivos

El SP retorna código 0 y mensaje específico si alguna FK es inválida, bloqueando el insert.

### 3. Remediación de Datos

Para corregir los 15 registros existentes, propongo:
- **Opción A:** DELETE de registros huérfanos (si no tienen valor de negocio)
- **Opción B:** INSERT de estudiantes placeholder con id_estudiante 99985-99999
- **Opción C:** Mapeo a estudiante "Desconocido" (id_estudiante = -1)

Recomiendo **Opción A** con log de auditoria.

## Resultados

- ✅ QA detecta 100% de huérfanos (15 registros)
- ✅ SP previene nuevos inserts inválidos con validación completa
- ✅ Mensajes de error descriptivos facilitan debugging
- ✅ Implementación lista para integración en ETL

## Próximos Pasos

1. Ejecutar remediación de datos (DELETE huérfanos)
2. Integrar SP en proceso ETL de carga
3. Crear alerta diaria para detectar nuevos huérfanos
4. Documentar procedimiento en manual operacional

---

**Total palabras:** 287
