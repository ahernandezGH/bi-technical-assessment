# Issue 005 - Sistema de Auditoría de Ejecuciones

**Dificultad**: ⭐⭐⭐⭐ Avanzado  
**Tiempo Estimado**: 6 horas  
**Puntos**: 90 puntos

---

## 📋 Descripción

Implementar sistema de logging y auditoría para rastrear ejecuciones de procesos ETL.

**Objetivo**:
- Tabla de auditoría con estructura completa
- Procedure para registrar ejecuciones (inicio, fin, duracion, resultado)
- Procedure para reportes de auditoría (por proceso, por fecha, por resultado)
- Dashboard queries

---

## 📝 Archivos Requeridos

```
Solutions/[TuNombre]/Issue005/
├── CREATE_T_AuditoriaEjecuciones.sql
├── PROC_RegistrarEjecucion.sql
├── PROC_ReporteAuditoriaEjecuciones.sql
└── SOLUTION.md
```

---

## 🎯 Requisitos Técnicos

- **Tabla**: Columns: id, proceso, inicio, fin, duracion, resultado, parametros (JSON)
- **Logging**: Procedure que inserta antes/después de operaciones
- **Reportes**: Aggregations (éxito rate, tiempo promedio, errors)
- **JSON**: Guardar parameters como JSON para flexibilidad

---

## 💡 Conceptos Clave

- **Auditoría**: Qué + cuándo + quién + resultado
- **JSON Storage**: VARCHAR(MAX) + JSON_VALUE para queries
- **Date/Time**: GETDATE(), DATEDIFF para calcular duración
- **Error Handling**: TRY/CATCH + RETHROW

---

Created: 2024-12-28
