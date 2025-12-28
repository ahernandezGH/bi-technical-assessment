# Issue 002 - Detección Avanzada de Registros Huérfanos

**Dificultad**: ⭐⭐⭐ Intermedio  
**Tiempo Estimado**: 5 horas  
**Puntos**: 100 puntos  
**Validación**: Incluye ValidationQuery (30 pts adicionales)

---

## 📋 Descripción

Ampliar la validación del Issue 001 para detectar huérfanos en MÚLTIPLES tablas (mat.hechos_matricula, ben.hechos_beneficios, col.hechos_cobranzas) usando patrones avanzados.

**Objetivo**: 
- Crear view que unifique detección de FK huérfanos
- Procedure que reporte por tabla + severidad
- ValidationQuery que retorne 15 (cantidad esperada de huérfanos)

---

## 📝 Archivos Requeridos

```
Solutions/[TuNombre]/Issue002/
├── QA_DeteccionHuerfanosUnificada.sql
├── PROC_ReporteIntegridadPorTabla.sql
├── VIEW_FK_Huerfanos.sql
└── SOLUTION.md (≥150 palabras)
```

---

## 🎯 Requisitos Técnicos

### Entrada
- 3 databases: Source, Staging, DWH
- 3 fact tables: mat.hechos_matricula (15 huérfanos), ben.hechos_beneficios (8), col.hechos_cobranzas (0)

### Salida
- **QA**: Query que detecta huérfanos en todas las tablas con UNION
- **PROC**: Procedure que retorna reporte por tabla + counts + severidad
- **VIEW**: Vista que muestra huérfanos unificados (para otros reportes)
- **ValidationQuery**: Debe retornar 15 (suma de huérfanos en mat + ben)

---

## 💡 Hints

- Usar UNION para combinar queries de múltiples tablas
- CTE para agregar metadata (tabla, schema, fecha_deteccion)
- Procedure con cursor opcional para reporte por tabla
- View reutilizable para dashboards

---

## 📚 Referencias

- [UNION vs UNION ALL](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/set-operators-union-transact-sql)
- [CREATE VIEW](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-view-transact-sql)
- [Common Table Expressions (CTE)](https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql-tsql)

Created: 2024-12-28
