# BI Technical Assessment

Universidad Hemisferio Sur Latinoamerica - Business Intelligence Platform

Repositorio de evaluación técnica para candidatos a posiciones de BI Developer/Data Engineer.

---

## Índice

- [Descripción General](#descripción-general)
- [Catálogo de Issues](#catálogo-de-issues)
- [Quickstart para Candidatos](#quickstart-para-candidatos)
- [Sistema de Scoring](#sistema-de-scoring)
- [Entorno de Desarrollo](#entorno-de-desarrollo)
- [FAQ](#faq)

---

## Descripción General

Este assessment evalúa habilidades en:

- **SQL Server**: T-SQL, stored procedures, integridad referencial
- **ETL Patterns**: Staging → DWH → Views (arquitectura School_ERP)
- **Data Quality**: Validación de datos, detección de inconsistencias
- **Documentation**: Capacidad de explicar soluciones técnicas

**Formato**:

- 7 issues técnicos independientes
- Cada candidato resuelve 1 issue asignado
- Tiempo: 4-6 horas (sin límite estricto)
- Entrega: Pull Request con título específico
- Scoring: 100 puntos (mínimo 70 para aprobar)

**Proceso**:

1. **Fork** este repositorio
2. **Resolver** el issue asignado en `Solutions/[TuNombre]/Issue[00X]/`
3. **Pull Request** con título: `Solution - [TuNombre] - Issue [00X]`
4. **Auto-grading** vía GitHub Actions (comentario con score)
5. **Review manual** si score ≥ 70 (technical interview)

---

## Catálogo de Issues

| Issue | Título | Dificultad | Archivos | Puntos | Tiempo Est. |
| ------- | -------- | ------------ | ---------- | -------- | ------------- |
| [001](Issues/Issue001_ValidacionIntegridad/) | Validación de Integridad Referencial | ⭐⭐ | 2 SQL + 1 DOC | 70 | 4h |
| [002](Issues/Issue002_DeteccionHuerfanos/) | Detección de Registros Huérfanos | ⭐⭐⭐ | 3 SQL + 1 DOC | 100 | 5h |
| [003](Issues/Issue003_SincronizacionCatalogos/) | Sincronización de Catálogos | ⭐⭐⭐ | 2 SQL + 1 PS1 + 1 DOC | 75 | 5h |
| [004](Issues/Issue004_MaterializacionVistas/) | Materialización de Vistas | ⭐⭐⭐⭐ | 3 SQL + 1 DOC | 85 | 6h |
| [005](Issues/Issue005_AuditoriaEjecuciones/) | Sistema de Auditoría de Ejecuciones | ⭐⭐⭐⭐ | 4 SQL + 1 DOC | 90 | 6h |
| [006](Issues/Issue006_ExtraccionBanner/) | Extracción de Datos desde Oracle Banner | ⭐⭐⭐⭐⭐ | 2 SQL + 1 PS1 + 1 DOC | 95 | 7h |
| [007](Issues/Issue007_IntegracionCompleta/) | Integración End-to-End (Matrícula + Beneficios) | ⭐⭐⭐⭐⭐ | 5 SQL + 1 PS1 + 1 DOC | 100 | 8h |

**Leyenda**:

- ⭐ = Básico (conocimientos SQL fundamentales)
- ⭐⭐⭐ = Intermedio (procedures, CTEs, error handling)
- ⭐⭐⭐⭐⭐ = Avanzado (ETL completo, PowerShell, cross-database)

---

## Quickstart para Candidatos

### 1. Fork y Clone

```bash
# Fork en GitHub UI: Click "Fork" button
# Luego clone tu fork
git clone https://github.com/[TU_USERNAME]/bi-technical-assessment.git
cd bi-technical-assessment
```

**IMPORTANTE - Habilitar GitHub Actions en tu fork:**

1. Ve a tu fork: `https://github.com/[TU_USERNAME]/bi-technical-assessment`
2. Click en la pestana **Actions**
3. Click en **I understand my workflows, go ahead and enable them**

Sin este paso, el auto-grading NO funcionara cuando crees tu PR.

### 2. Setup del Entorno Local

**Requisitos**:

- SQL Server 2019+ (Developer/Express Edition)
- SQL Server Management Studio (SSMS)
- PowerShell 5.1+
- Git 2.30+

**Crear Databases**:

```powershell
# Ejecutar desde raíz del repositorio
cd Database\01_Schema
sqlcmd -S [TU_SERVIDOR] -E -i CREATE_SchoolERP_Source.sql
sqlcmd -S [TU_SERVIDOR] -E -i CREATE_BI_Assessment_Staging.sql
sqlcmd -S [TU_SERVIDOR] -E -i CREATE_BI_Assessment_DWH.sql

# Cargar datos de prueba
cd ..\02_Data
sqlcmd -S [TU_SERVIDOR] -E -i LOAD_Basic_TestData.sql
```

**Validar Entorno**:

```powershell
.\Tools\Test-Environment.ps1 -ServerName "[TU_SERVIDOR]"
# Debe mostrar: "ENTORNO LISTO PARA EVALUACION" (27/27 checks PASS)
```

### 3. Trabajar en tu Solución

**Estructura de carpetas**:

```text
Solutions/
  [TuNombre]/              # Ej: JuanPerez, MariaGomez
    Issue[00X]/            # Ej: Issue001, Issue002
      *.sql                # Scripts SQL requeridos
      *.ps1                # Scripts PowerShell (si aplica)
      SOLUTION.md          # Documentación (OBLIGATORIO)
```

**Ejemplo Issue 001**:

```text
Solutions/JuanPerez/Issue001/
  QA_ValidarIntegridadEstudiantes.sql
  PROC_ValidarIntegridadPreInsert.sql
  SOLUTION.md
```

**SOLUTION.md** debe incluir (mínimo 150 palabras):

- Análisis del problema
- Metodología de solución
- Explicación de cada script
- Queries de validación ejecutados
- Conclusiones y recomendaciones

### 4. Validar tu Solución Localmente

```powershell
.\Tools\Validate-Solution.ps1 `
  -Issue "001" `
  -Candidate "JuanPerez" `
  -ServerName "[TU_SERVIDOR]"

# Output esperado:
#   CHECK 1: Archivos Requeridos      ✓ 25/25 pts
#   CHECK 2: Sintaxis SQL              ✓ 25/25 pts
#   CHECK 3: Documentación             ✓ 20/20 pts
#   CHECK 4: Validación Específica     ✓ 30/30 pts
#   SCORE: 100/100 - STATUS: PASS
```

### 5. Crear Pull Request

```bash
# Crear branch para tu solucion
git checkout -b solution/issue001

# Commit y push a tu branch
git add Solutions/[TuNombre]/
git commit -m "Solution - [TuNombre] - Issue [00X]"
git push origin solution/issue001

# En GitHub: Click en "Compare & pull request" que aparece automaticamente
# TITULO (CRITICO): Solution - [TuNombre] - Issue [00X]
# Ejemplo: "Solution - JuanPerez - Issue 001"
```
**⚠️ IMPORTANTE**: El título del PR **DEBE** seguir exactamente el formato:

```text
Solution - [Candidate] - Issue [00X]
```

Donde `Candidate` es tu nombre sin espacios ni guiones, e `Issue` es el código de 3 dígitos. Los corchetes `[]` son opcionales.
De lo contrario, el auto-grading no se activará.

### 6. Auto-Grading

GitHub Actions ejecutará automáticamente:

1. Parse del título del PR
2. Setup de SQL Server en runner
3. Carga de schemas y test data
4. Ejecución de `Validate-Solution.ps1`
5. Comentario en el PR con score

**Tiempo de ejecución**: ~5-8 minutos

**Resultado**:

- ✅ **PASS** (≥70 pts): Elegible para Phase 2 (Technical Interview)
- ❌ **FAIL** (<70 pts): Review feedback, corrige, y resubmit (1 retry permitido)

---

## Sistema de Scoring

### Distribución de Puntos (100 pts total)

| Check | Descripción | Puntos | Criterio |
| ------- | ------------- | -------- | ---------- |
| **1. Archivos Requeridos** | Presencia de todos los archivos especificados | 25 | All-or-nothing |
| **2. Sintaxis SQL** | Scripts ejecutables sin errores (SET PARSEONLY) | 25 | Proporcional (errores penalizan) |
| **3. Documentación** | SOLUTION.md ≥ 150 palabras | 20 | Proporcional (word count) |
| **4. Validación Específica** | Query retorna resultado esperado | 30 | All-or-nothing (solo si aplica) |

### Passing Score

- **Mínimo**: 70 puntos
- **Criterio**: Demuestra competencia técnica básica + documentación adecuada
- **Retry**: 1 intento adicional permitido si < 70 (feedback detallado proporcionado)

### Ejemplos

**Caso A - PASS (85 pts)**:

- Archivos: ✓ 25/25 (todos presentes)
- Sintaxis: ✓ 20/25 (1 warning menor)
- Documentación: ✓ 20/20 (250 palabras)
- Validación: ✓ 20/30 (resultado cercano, no exacto)

**Caso B - FAIL (65 pts)**:

- Archivos: ✓ 25/25
- Sintaxis: ✗ 15/25 (2 errores de sintaxis)
- Documentación: ✗ 10/20 (solo 80 palabras)
- Validación: ✓ 15/30 (lógica parcialmente correcta)

---

## Entorno de Desarrollo

### Arquitectura de 3 Capas

```text
[SchoolERP_Source]          [BI_Assessment_Staging]      [BI_Assessment_DWH]
  └─ erp schema                └─ cat (catálogos)           └─ cat (dimensiones)
     ├─ erp_persona               ├─ mat (matrícula)           ├─ mat (hechos)
     ├─ erp_student_curriculum    └─ ben (beneficios)          └─ ben (hechos)
     ├─ erp_term_catalog
     ├─ erp_student_scholarship
     ├─ erp_student_benefit
     └─ erp_collection_history
```

**Flujo ETL**:

1. **Source → Staging**: Validación, transformación, limpieza
2. **Staging → DWH**: Dimensiones → Hechos (orden FK)
3. **DWH → Views**: Presentación para SSAS/Power BI

### Datos de Prueba

| Tabla | Registros | Descripción |
| ------- | ----------- | ------------- |
| `erp_persona` | 20 | Estudiantes base (pidm 1-20) |
| `erp_student_curriculum` | 10 | Matrículas válidas (10 estudiantes) |
| `erp_term_catalog` | 6 | Términos académicos (202301-202402) |
| `erp_student_scholarship` | 15 | **FK huérfanos** (id_estudiante > 99980) |
| `erp_student_benefit` | 8 | **FK huérfanos** (id_estudiante > 99980) |
| `erp_collection_history` | 12 | Cobranzas válidas (id_estudiante ≤ 20) |

**Nota**: Los FK huérfanos son **intencionales** para simular issues de integridad referencial.

### Herramientas Disponibles

**Validators**:

- `Tools/Test-Environment.ps1`: Valida setup completo (databases, schemas, volumetría)
- `Tools/Validate-Solution.ps1`: Auto-grading de soluciones (scoring 100 pts)

**Estándares**:

- `Features/ESTANDARES_ARQUITECTURA_BD.md`: Patterns ETL, logging, naming conventions
- `Features/ESTANDARES_NOMENCLATURA.md`: File prefixes, SQL headers, temporary files

**Referencias**:

- `ExtraccionBanner/`: Metodologías de extracción de Oracle Banner
- `Features/Arquitectura_UFT_FIN_IntegracionMatriculaBeneficios/`: Arquitectura completa

---

## Need Help?

Having issues during setup, validation, or submission?

Check our [Troubleshooting Guide](TROUBLESHOOTING.md) for solutions to common problems:

- Setup and installation errors
- Database connection issues
- GitHub Actions workflow problems
- Validation script errors
- SQL execution errors
- Issue-specific solutions

**Quick Reference**: If Validate-Solution.ps1 passes but your SQL fails in SSMS, see [Troubleshooting  Errores de Ejecuci�n SQL](TROUBLESHOOTING.md#errores-de-ejecuci�n-sql) for common column name mismatches.

---

## FAQ

### ¿Puedo usar herramientas de IA (ChatGPT, Copilot)?

**Sí**, se permite asistencia de IA, pero:

- Debes **entender completamente** tu solución
- En la technical interview se profundizará en decisiones de diseño
- El código debe seguir los estándares del repositorio

### ¿Qué pasa si mi PR no activa el auto-grading?

Verifica el título del PR:

```text
✅ Correcto: Solution - [JuanPerez] - Issue [001]
✅ Correcto: Solution - JuanPerez - Issue 001
❌ Incorrecto: Solution JuanPerez Issue 001
❌ Incorrecto: Solution - JuanPerez - Issue 1 (debe ser 001)
❌ Incorrecto: Solution - Juan Perez - Issue [001] (sin espacios en nombre ni guiones)
```

### ¿Puedo resolver múltiples issues?

No se recomienda. Cada candidato recibe **1 issue asignado** según experiencia:

- Junior: Issues 001-003
- Mid-Level: Issues 003-005
- Senior: Issues 005-007

Resolver issues adicionales **no incrementa el score**.

### ¿Qué hacer si obtengo < 70 puntos?

1. Revisa el **comentario detallado** en tu PR
2. Identifica qué checks fallaron
3. Corrige los problemas
4. Ejecuta `Validate-Solution.ps1` localmente
5. Haz push de correcciones (el workflow se re-ejecuta automáticamente)

**Límite**: 1 retry permitido (2 intentos totales).

### ¿Necesito acceso a Oracle Banner?

**No**. Los issues no requieren conexión real a Banner. Los datos de prueba simulan extracciones de Oracle ya materializadas en `SchoolERP_Source`.

Para issues avanzados (006-007), se proporcionan:

- Queries de extracción de referencia (`ExtraccionBanner/METODOLOGIA_*.md`)
- Datos CSV de ejemplo
- Metodología documentada

### ¿Cómo depuro si mi SQL tiene errores?

**Método 1 - SSMS**:

```sql
-- Copia tu script a SSMS
-- Ejecuta línea por línea con F8
-- Revisa mensajes en Output panel
```

**Método 2 - sqlcmd**:

```powershell
sqlcmd -S [SERVIDOR] -E -i "tu_script.sql" -o "OUTPUT_debug.txt"
# Revisa OUTPUT_debug.txt para errores detallados
```

**Método 3 - Validator**:

```powershell
.\Tools\Validate-Solution.ps1 -Issue "001" -Candidate "Test" -DryRun
# Muestra archivos pero no ejecuta queries (validación rápida)
```

### ¿Qué servidor SQL usar para GitHub Actions?

**Automático**. El workflow usa:

- GitHub Actions Runner con Windows
- **SQL Server LocalDB** (`(localdb)\MSSQLLocalDB`)
- Autenticación: Windows Integrated Security (`-E` en sqlcmd)
- Bases de datos `SchoolERP_Source`, `BI_Assessment_Staging` y `BI_Assessment_DWH` creadas on-the-fly

No necesitas configurar nada - el runner es efímero y se autoconfigura.

### ¿Cuánto tarda el auto-grading?

**Timeline**:

- Parse PR title: ~10 segundos
- Setup SQL Server: ~2 minutos
- Load schemas/data: ~1 minuto
- Run validator: ~2-3 minutos
- Post comment: ~10 segundos

**Total**: 5-8 minutos desde que creas el PR.

---

## 📞 Contacto

**Coordinador de Assessment**: Alejandro Hernández
**Email**: <ahernandez@hashware.com>  
**GitHub**: [@ahernandezGH](https://github.com/ahernandezGH)

**Soporte técnico**:

- Issues del repositorio: [Create Issue](https://github.com/ahernandezGH/bi-technical-assessment/issues)
- Problemas con auto-grading: Tag `@ahernandezGH` en tu PR

---

## 📄 Licencia

Este repositorio es privado y confidencial. Uso exclusivo para procesos de selección de Hashware de México S.A de C.V.

**Prohibido**:

- Compartir soluciones con otros candidatos
- Publicar issues o soluciones en redes sociales
- Hacer fork público del repositorio

---

Good luck! 🚀

**Última actualización:** Diciembre 2025
