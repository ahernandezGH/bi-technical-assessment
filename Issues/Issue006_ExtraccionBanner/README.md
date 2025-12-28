# Issue 006 - Extracción de Datos desde Oracle Banner

**Dificultad**: ⭐⭐⭐⭐⭐ Muy Avanzado  
**Tiempo Estimado**: 7 horas  
**Puntos**: 95 puntos

---

## 📋 Descripción

Simular extracción de datos desde Oracle Banner usando OPENQUERY y metodología de "foto" (snapshot point-in-time).

**Objetivo**:
- Query OPENQUERY simulado contra linkedserver Oracle
- Aplicar filtros de fecha de foto
- Validar completitud de extracción
- Documentar metodología

---

## 📝 Archivos Requeridos

```
Solutions/[TuNombre]/Issue006/
├── EXTR_SARADAP.sql          (Admissions data)
├── EXTR_SPRIDEN.sql          (Student demographics)
├── PROC_ValidarCompletitudExtraccion.ps1
└── SOLUTION.md
```

---

## 🎯 Requisitos Técnicos

- **Linked Server**: OPENQUERY o OPENDATASOURCE simulation
- **Foto concept**: Filtrar por fecha oficial de snapshot
- **Completitud**: Contar expected vs actual rows
- **Methodología**: Documentar en METODOLOGIA_*.md

---

## 💡 Conceptos Clave

- **Linked Servers**: Conectar SQL Server a Oracle
- **OPENQUERY**: Query remoto con filtros locales
- **Foto**: Snapshot point-in-time de Oracle
- **Precedencia**: Orden de carga (Personas → Admisiones → Matrículas)

---

## 📚 Referencias

- ExtraccionBanner/METODOLOGIA_*.md: Ejemplos reales
- Banner tables: SARADAP, SPRIDEN, SOVLCUR, etc.

---

Created: 2024-12-28
