# ✓ FASE 1 COMPLETADA - Esquemas y Datos Sintéticos

**Fecha completada:** 27 de Diciembre de 2025  
**Duración:** ~2 horas  
**Servidor:** NOM1014.LCRED.NET

---

## 📊 Estado de Entregables

### ✅ BASES DE DATOS CREADAS

| Base de Datos | Estado | Descripción |
| --------------- | -------- | ------------- |
| **SchoolERP_Source** | ✅ Creada | Fuente ERP con tablas históricas |
| **BI_Assessment_Staging** | ✅ Creada | Staging con esquemas: `stg`, `cat`, `mat`, `ben` |
| **BI_Assessment_DWH** | ✅ Creada | Data Warehouse con dimensiones y hechos |

---

## 📋 TABLAS ERP POBLADAS

### SchoolERP_Source

| Tabla | Registros | Descripción |
| ------- | ----------- | ------------- |
| **erp_person_identity** | 20 | Identidades de personas vigentes + históricas |
| **erp_term_catalog** | 6 | Términos académicos (2024-2025) |
| **erp_student_curriculum** | 10 | Curriculum estudiante con precedencia |

---

## 🏗️ DIMENSIONES Y HECHOS DWH

### Dimensiones (cat schema)

- ✅ `dim_estudiantes` - Personas con estado vigente
- ✅ `dim_terminos` - Catálogo de términos académicos
- ✅ `dim_programas` - Catálogo de programas
- ✅ `dim_cohortes` - Cohortes (pendiente carga de datos)

### Hechos (mat y ben schemas)

- ✅ `hechos_matricula` - 15 registros con FK huérfanos (Issue 001)
- ✅ `hechos_beneficios` - Estructura creada (pendiente datos)
- ✅ `hechos_pagos` - Estructura creada (pendiente datos)

---

## 🔍 EDGE CASES IMPLEMENTADOS

### Issue 001 - Validación Integridad (FK Huérfanos)

✅ **Completado:** 15 registros insertados en `hechos_matricula` con `id_estudiante` no existentes en `dim_estudiantes`

```sql
-- Ejemplo de FK huérfano
SELECT * FROM BI_Assessment_DWH.mat.hechos_matricula 
WHERE id_estudiante > 99980;

-- Resultado: 15 registros sin referencia en dim_estudiantes
```

---

## 📁 SCRIPTS SQL CREADOS

### Schema Creation (01_Schema/)

| Archivo | Descripción |
| --------- | ------------- |
| `CREATE_SchoolERP_Source.sql` | Crea tablas ERP con índices |
| `CREATE_BI_Assessment_Staging.sql` | Crea staging con esquemas y tablas |
| `CREATE_BI_Assessment_DWH.sql` | Crea DWH con dimensiones y hechos |

### Data Loading (02_Data/)

| Archivo | Descripción | Registros Cargados |
| --------- | ------------- | ------------------- |
| `LOAD_Basic_TestData.sql` | Carga términos y personas | 26 |
| `LOAD_Curriculum_Data.sql` | Carga curriculum estudiantes | 10 |
| `INSERT_EdgeCases.sql` | Inserta FK huérfanos | 15 |
| `GENERATE_MockData.ps1` | Generador para datos a escala | Script |

---

## 🔄 COMANDOS PARA REPRODUCIR FASE 1

### 1. Ejecutar Scripts de Schema

```powershell
Set-Location "C:\Projects\bi-technical-assessment\Database\01_Schema"

sqlcmd -S "NOM1014.LCRED.NET" -E -i CREATE_SchoolERP_Source.sql
sqlcmd -S "NOM1014.LCRED.NET" -E -i CREATE_BI_Assessment_Staging.sql
sqlcmd -S "NOM1014.LCRED.NET" -E -i CREATE_BI_Assessment_DWH.sql
```

### 2. Ejecutar Scripts de Carga

```powershell
Set-Location "C:\Projects\bi-technical-assessment\Database\02_Data"

sqlcmd -S "NOM1014.LCRED.NET" -E -i LOAD_Basic_TestData.sql
sqlcmd -S "NOM1014.LCRED.NET" -E -i LOAD_Curriculum_Data.sql
sqlcmd -S "NOM1014.LCRED.NET" -E -i INSERT_EdgeCases.sql
```

### 3. Verificar Datos

```sql
-- Conectar a NOM1014.LCRED.NET

-- Contar registros
SELECT 'SchoolERP_Source - erp_person_identity' AS Tabla, COUNT(*) FROM SchoolERP_Source.dbo.erp_person_identity
UNION ALL
SELECT 'SchoolERP_Source - erp_term_catalog', COUNT(*) FROM SchoolERP_Source.dbo.erp_term_catalog
UNION ALL
SELECT 'SchoolERP_Source - erp_student_curriculum', COUNT(*) FROM SchoolERP_Source.dbo.erp_student_curriculum
UNION ALL
SELECT 'BI_Assessment_DWH - hechos_matricula', COUNT(*) FROM BI_Assessment_DWH.mat.hechos_matricula;

-- Verificar FK huérfanos (Issue 001)
SELECT id_estudiante, id_termino, fecha_matricula 
FROM BI_Assessment_DWH.mat.hechos_matricula 
WHERE id_estudiante NOT IN (SELECT id_estudiante FROM BI_Assessment_DWH.cat.dim_estudiantes);
```

---

## 📈 ESTADÍSTICAS FINALES

```text
Total Registros por Base:
├── SchoolERP_Source
│   ├── erp_person_identity: 20
│   ├── erp_term_catalog: 6
│   └── erp_student_curriculum: 10
│
└── BI_Assessment_DWH
    └── hechos_matricula: 15 (con FK huérfanos)

Total: 51 registros cargados
```

---

## 🎯 PRÓXIMO PASO: FASE 2

### Qué sigue (5 días)

- [ ] Crear 7 carpetas de Issues con:
  - README.md (descripción del reto)
  - DESCRIPTION.md (problema detallado)
  - RUBRIC.md (criterios evaluación)
  - Artefactos base (vistas lentas, SPs monolíticas, etc.)

- [ ] Documentar cada Issue con contexto
- [ ] Preparar datos de prueba específicos por Issue

---

## 🔗 Referencias

- **Plan General:** [`PLAN_Implementacion_Repositorio_Evaluacion.md`](../../../PLAN_Implementacion_Repositorio_Evaluacion.md)
- **Arquitectura:** [`DOC_Arquitectura_EvaluacionCandidatosBI.md`](../../../DOC_Arquitectura_EvaluacionCandidatosBI.md)
- **Repositorio:** <https://github.com/ahernandezGH/bi-technical-assessment>
- **Commits:**
  - Fase 0: `535259c` (Estructura base)
  - Fase 1: `78da58d`, `fb733ee` (Esquemas y datos)

---

**Estado:** ✅ FASE 1 COMPLETADA  
**Próxima revisión:** Inicio de Fase 2 (Issues)
