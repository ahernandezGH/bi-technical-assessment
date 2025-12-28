# Issue 003 - Sincronización de Catálogos

**Dificultad**: ⭐⭐⭐ Intermedio  
**Tiempo Estimado**: 5 horas  
**Puntos**: 75 puntos

---

## 📋 Descripción

Crear sincronización automática de catálogos (dimensiones) desde `SchoolERP_Source` hacia `BI_Assessment_Staging` usando patrones ETL.

**Objetivo**:
- Procedure que inserta/actualiza dimensiones
- Script de validación post-sync
- PowerShell orchestrator para scheduled execution
- Documentación de metodología

---

## 📝 Archivos Requeridos

```
Solutions/[TuNombre]/Issue003/
├── PROC_SincronizarDimensionPersonas.sql
├── QA_ValidarSincronizacion.sql
├── ORQUESTADOR_SincronizacionCatalogos.ps1
└── SOLUTION.md
```

---

## 🎯 Requisitos Técnicos

- **SQL**: Procedure con MERGE (INSERT + UPDATE)
- **PowerShell**: Script que ejecuta procedure + logging
- **Validación**: Counts pre/post sync
- **Performance**: Documentar tiempo de ejecución

---

## 💡 Conceptos Clave

- **MERGE statement**: Insertar O actualizar dinámicamente
- **Surrogate keys**: IDENTITY(1,1) para dimension
- **Soft deletes**: Marcar eliminados vs hard delete
- **Slowly Changing Dimensions (SCD Type 2)**: Histórico de cambios

---

Created: 2024-12-28
