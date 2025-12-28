# Issue 004 - Materialización de Vistas DWH

**Dificultad**: ⭐⭐⭐⭐ Avanzado  
**Tiempo Estimado**: 6 horas  
**Puntos**: 85 puntos

---

## 📋 Descripción

Crear vistas materializadas que agreguen hechos a nivel de estudiante y términos para dashboards Power BI.

**Objetivo**:
- 2 vistas materializadas con pre-cálculos
- Indexes para optimizar performance
- Refresh script automático
- Documentación de grain y dimensionalidad

---

## 📝 Archivos Requeridos

```
Solutions/[TuNombre]/Issue004/
├── CREATE_V_MatriculasPorEstudiante.sql
├── CREATE_V_BeneficiosPorTermino.sql
├── PROC_RefreshVistasMateriazadas.sql
└── SOLUTION.md
```

---

## 🎯 Requisitos Técnicos

- **SQL**: CREATE VIEW con JOINs complejos
- **Grain**: Definir nivel de detalle (estudiante × semestre)
- **Indexes**: Non-clustered en columnas de filtro frecuente
- **Performance**: Documentar execution plan

---

## 💡 Conceptos Clave

- **View vs Materialized View**: Diferencias en refresh
- **Grain**: Nivel de detalle de los hechos
- **Aggregations**: SUM, COUNT pre-calculados
- **Clustered vs Non-clustered indexes**: Estrategia de indexación

---

Created: 2024-12-28
