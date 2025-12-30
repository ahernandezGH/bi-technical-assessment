# PHASE 5.4: Test GitHub Actions Workflow - Guía Paso a Paso

**Estado**: 🔄 EN PROGRESO  
**Objetivo**: Crear PR de prueba y verificar flujo de auto-grading  
**Rama**: `solution-testcandidate-issue001`  
**Commit**: `9f1afe8`

---

## 📋 PROGRESO ACTUAL

### ✅ COMPLETADO

#### Paso 1: Verificar estado de Git
- **Status**: Working tree clean, branch synced con `origin/main`

#### Paso 2: Crear estructura Solutions/TestCandidate/Issue001
- **Archivos creados**:
  - `QA_ValidarIntegridadEstudiantes.sql` (520 bytes)
  - `PROC_ValidarIntegridadPreInsert.sql` (1,577 bytes)
  - `SOLUTION.md` (2,218 bytes)
- **Origen**: Copiados de `Solutions/JuanPerez/Issue001/` (solución mock)

#### Paso 3: Crear rama de prueba
- **Rama**: `solution-testcandidate-issue001` ✅ Creada
- **Comando**: `git checkout -b solution-testcandidate-issue001`

#### Paso 4: Commit
- **Commit Hash**: `9f1afe8`
- **Mensaje**: `feat: Add test solution for Issue001 (TestCandidate)`
- **Archivos**: 3 files changed, 131 insertions(+)

#### Paso 5: Push a origin
- **Status**: ✅ Pusheada exitosamente a `origin/solution-testcandidate-issue001`
- **Tracking**: Branch set up to track `origin/solution-testcandidate-issue001`

---

## 📝 PASO 6: CREAR EL PULL REQUEST

### 🎯 Ubicación para crear PR
```
https://github.com/ahernandezGH/bi-technical-assessment/pull/new/solution-testcandidate-issue001
```

### ⚠️ TÍTULO REQUERIDO (EXACTO)

El workflow GitHub Actions usa este regex para detectar PRs válidos:

```regex
^Solution - .+ - Issue \[\d{3}\]$
```

**Tu título DEBE ser**:
```
Solution - TestCandidate - Issue [001]
```

**Desglose**:
- `Solution` - Literal exacto (case-sensitive)
- ` - ` - Espacio-guión-espacio (obligatorio)
- `TestCandidate` - Nombre del "candidato" (flexible, cualquier texto aquí)
- ` - ` - Segundo separador espacio-guión-espacio
- `Issue [001]` - "Issue " + espacios + [número con 3 dígitos en corchetes]

**❌ Títulos INVÁLIDOS** (no triggerizan workflow):
- `Solution to Issue 001` (falta formato [00X])
- `Solution - TestCandidate - Issue 001` (sin corchetes)
- `Solution - TestCandidate - Issue [1]` (solo 1 dígito)
- `solution - TestCandidate - Issue [001]` (lowercase "solution")

### 📄 Cuerpo del PR (Recomendado)

```markdown
# Test Submission - Issue 001

## Summary
Testing the automated grading workflow for validation integrity check.

## Files Included
- QA_ValidarIntegridadEstudiantes.sql
- PROC_ValidarIntegridadPreInsert.sql
- SOLUTION.md

## How It Works
Detect orphan foreign keys in matricula table using LEFT JOIN pattern.

## Testing
This solution implements:
1. Query to find huérfanos in the matricula table
2. Stored procedure for integrity validation
3. Documentation of approach

---
This is a test PR to verify the GitHub Actions CI/CD workflow.
```

### 🖱️ PASOS EN GITHUB.COM

1. **Abre el enlace**:
   ```
   https://github.com/ahernandezGH/bi-technical-assessment/pull/new/solution-testcandidate-issue001
   ```

2. **Verifica las ramas**:
   - Base: `main` ✓
   - Compare: `solution-testcandidate-issue001` ✓

3. **Rellena el título**:
   - Pega exactamente: `Solution - TestCandidate - Issue [001]`

4. **Rellena el body** (opcional pero recomendado):
   - Usa el markdown sugerido arriba

5. **Click "Create pull request"**

---

## 🔄 PASO 7: MONITOREAR EL WORKFLOW

Una vez creado el PR, GitHub Actions se TRIGGERIARÁ automáticamente (5-8 segundos después).

### 📊 Qué observar en la pestaña "Actions"

**Flujo esperado**:
```
1. parse-pr-title (ubuntu-latest)
   └─ Extrae: candidate="TestCandidate", issue="001"
   └─ Tiempo: ~10 segundos

2. validate-solution (windows-latest, depende de parse-pr-title)
   ├─ Setup SQL Server 2019
   │  └─ Conecta al servicio preinstalado
   │  └─ Tiempo: ~30-40 segundos
   │
   ├─ Load Databases
   │  ├─ Create [BI_Assessment_Source]
   │  ├─ Create [BI_Assessment_Staging]
   │  ├─ Create [BI_Assessment_DWH]
   │  └─ Load test data (51 registros)
   │  └─ Tiempo: ~20 segundos
   │
   ├─ Load Candidate Solution
   │  ├─ QA_ValidarIntegridadEstudiantes.sql
   │  ├─ PROC_ValidarIntegridadPreInsert.sql
   │  └─ SOLUTION.md (word count validation)
   │  └─ Tiempo: ~10 segundos
   │
   ├─ Run Validate-Solution.ps1
   │  ├─ Ejecuta 27 validaciones
   │  ├─ Compila procedure
   │  ├─ Ejecuta QA queries
   │  ├─ Valida output
   │  └─ Genera score (0-100)
   │  └─ Tiempo: ~60-90 segundos
   │
   └─ Post Comment to PR
      └─ Publica resultado en PR comment
      └─ Tiempo: ~5 segundos

TOTAL: ~5-8 minutos
```

### 🎯 Resultados esperados

**Para solución mock (JuanPerez/TestCandidate)**:

| Métrica | Valor |
|---------|-------|
| Score | 70-75/100 |
| Status | ✅ PASS |
| Comment | Automático con emoji |

### 📌 Cómo ver los resultados

**En GitHub.com**:

1. **Ve a la pestaña "Actions"** en el repositorio
2. **Busca el workflow** "Validate Solution" más reciente
3. **Haz clic** en el workflow run
4. **Observa los jobs**:
   - `parse-pr-title` (verde = éxito)
   - `validate-solution` (verde = validación completa)
5. **En la pestaña "PR"**, deberías ver un comentario automático con:
   ```
   ✅ Solution Validation Result
   
   Score: 70/100
   Status: PASS
   
   [Expandible con detalles completos]
   ```

---

## 🔍 PASO 8: INTERPRETAR RESULTADOS

### Score Breakdown (máx 100 puntos)

```
Database Setup:        10 pts
Schema Creation:       10 pts
Data Loading:          10 pts
QA Query Validation:   20 pts
Procedure Execution:   20 pts
SOLUTION.md (150+ wds): 15 pts
File Naming:            5 pts
Syntax Validation:      5 pts
Scoring:               5 pts
---
TOTAL:               100 pts
```

### Posibles Puntajes

| Score | Status | Acción |
|-------|--------|--------|
| ≥70 | ✅ PASS | Solución válida, puede pasar Issue |
| 50-69 | ⚠️ NEEDS WORK | Errores menores, revisar feedback |
| <50 | ❌ FAIL | Errores graves, revisar requirements |

### Ejemplo de Comment en PR

```markdown
## ✅ Solution Validation Result

**Score**: 70/100  
**Status**: ✅ PASS

### Results Summary
- Database connectivity: ✓
- Schema validation: ✓
- Test data integrity: ✓
- Query execution: ✓
- Procedure compilation: ✓
- SOLUTION.md word count: ✓ (285 words)

### Issues Found
- None critical (score ≥70)

---
[Detalles expandibles con cada validación]

**Candidate**: TestCandidate  
**Issue**: 001  
**Execution Time**: 6 min 45 sec  
**Timestamp**: 2025-12-30 14:32 UTC
```

---

## 📊 PASO 9: DOCUMENTAR EJECUCIÓN

Después de que el workflow complete, documenta:

### Recolectar información:

1. **URL del PR**:
   ```
   https://github.com/ahernandezGH/bi-technical-assessment/pull/[PR_NUMBER]
   ```

2. **Tiempo de ejecución**:
   - Cuando se creó PR: [TIMESTAMP]
   - Cuando completó workflow: [TIMESTAMP]
   - Total: [MINUTOS]

3. **Score final**: [X/100]

4. **Status**: [PASS/FAIL]

5. **Jobs ejecutados**:
   - parse-pr-title: ✅/❌
   - validate-solution: ✅/❌

### Documento final

Crear archivo: `PHASE_5_4_RESULTS.md` con:

```markdown
# PHASE 5.4 TEST RESULTS

## PR Details
- **Title**: Solution - TestCandidate - Issue [001]
- **Branch**: solution-testcandidate-issue001
- **Commit**: 9f1afe8
- **PR URL**: [Link]
- **PR Number**: [#XXX]

## Workflow Execution
- **Created**: [Timestamp]
- **Completed**: [Timestamp]
- **Duration**: [X min Y sec]

## Job Results
| Job | Status | Duration |
|-----|--------|----------|
| parse-pr-title | ✅ | ~10s |
| validate-solution | ✅ | ~5m30s |

## Final Score
- **Score**: 70/100
- **Status**: ✅ PASS
- **Auto-Comment**: Posted ✅

## Observations
- Workflow triggered correctly on regex match
- SQL Server setup successful
- Databases created and loaded
- Test solution executed without errors
- Auto-comment posted with correct format

## Lessons Learned
1. PR title format is critical (regex match)
2. Workflow timing: 5-8 minutes is typical
3. Windows runner needed for SQL Server 2019
4. Mock solution from JuanPerez scores 70-75 points
5. All 27 validators in Test-Environment.ps1 passed

## Next Steps
- [x] Test workflow with PR
- [ ] Fix any issues if score <70
- [ ] Re-run workflow if needed
- [ ] Complete Phase 5 final summary
```

---

## ✅ RESUMEN PHASE 5.4

| Paso | Status | Descripción |
|------|--------|-------------|
| 1 | ✅ | Verificar estado de Git |
| 2 | ✅ | Crear Solutions/TestCandidate/Issue001 |
| 3 | ✅ | Crear rama solution-testcandidate-issue001 |
| 4 | ✅ | Commit con archivos |
| 5 | ✅ | Push a origin |
| 6 | 🔄 | Crear PR con título exacto |
| 7 | ⏳ | Monitorear Actions workflow |
| 8 | ⏳ | Interpretar resultados |
| 9 | ⏳ | Documentar ejecución |

---

**Documento generado**: 2025-12-30  
**Phase**: 5.4 de 5  
**Próximo**: Crear PR y monitorear Actions tab
