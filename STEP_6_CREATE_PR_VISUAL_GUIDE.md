# PASO 6: Crear Pull Request - Guía Visual

## 🎯 OPCIÓN 1: Crear PR Manualmente (Recomendado)

### Paso 1: Abre el enlace en tu navegador

Copia y pega en tu navegador:
```
https://github.com/ahernandezGH/bi-technical-assessment/pull/new/solution-testcandidate-issue001
```

Deberías ver una pantalla como esta:

```
┌─────────────────────────────────────────────────────────────────┐
│  Comparing changes                                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  main ← solution-testcandidate-issue001                        │
│  ├─ Base: main                                                  │
│  └─ Compare: solution-testcandidate-issue001                    │
│                                                                  │
│  Able to merge. These branches can be automatically merged.    │
│                                                                  │
│  📝 3 commits with changes                                      │
│     • 9f1afe8 - feat: Add test solution for Issue001           │
│     • ...                                                       │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Create a pull request                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

### Paso 2: Rellena el TÍTULO del PR

En el campo "Title", ingresa **EXACTAMENTE** esto:

```
Solution - TestCandidate - Issue [001]
```

**⚠️ IMPORTANTE**: 
- Debe ser EXACTO (case-sensitive)
- Espacio-guión-espacio: ` - ` (3 caracteres)
- Número entre corchetes: `[001]` (3 dígitos)

**❌ NO hagas esto**:
- ❌ `Solution to Issue 001`
- ❌ `Solution - TestCandidate - Issue 1`
- ❌ `solution - TestCandidate - Issue [001]` (lowercase)
- ❌ `Solution - TestCandidate - Issue [1]` (solo 1 dígito)

**✅ Formato correcto**:
```
Solution - [NOMBRE] - Issue [00X]
           ↑ Flexible    ↑ Formato [00X]
```

---

### Paso 3: Rellena el CUERPO (Body) - OPCIONAL pero recomendado

Haz clic en el campo de descripción y copia-pega:

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

---

### Paso 4: Click "Create pull request"

En la parte inferior derecha, haz clic en el botón verde:

```
┌─────────────────────────────────────┐
│  ✏️  [Draft]                         │
│  [Create pull request] ← CLICK AQUÍ  │
└─────────────────────────────────────┘
```

---

## 🚀 OPCIÓN 2: Crear PR Automáticamente (con GitHub Token)

Si tienes un token de GitHub configurado, ejecuta:

```powershell
# En PowerShell (en el directorio del repositorio)
.\Create-TestPR.ps1
```

**Qué hace el script**:
1. Valida que tengas token en `$env:GITHUB_TOKEN`
2. Prepara datos del PR
3. Envía solicitud a GitHub API
4. Muestra el URL del PR creado
5. Imprime instrucciones para monitorear

**Ejemplo de ejecución**:
```
═══════════════════════════════════════════════════════════
CREATING TEST PULL REQUEST
═══════════════════════════════════════════════════════════

📋 Detalles del PR:
   Título: Solution - TestCandidate - Issue [001]
   Rama: solution-testcandidate-issue001
   Base: main

🔄 Enviando solicitud a GitHub API...

✅ PR CREADO EXITOSAMENTE

📌 Detalles del PR:
   PR Number: #45
   URL: https://github.com/ahernandezGH/bi-technical-assessment/pull/45
   State: open
   Created: 2025-12-30T14:32:00Z

🚀 Workflow debería triggeriarse en ~10 segundos
   Monitorea el progreso en:
   https://github.com/ahernandezGH/bi-technical-assessment/actions
```

---

## 🔍 ¿QUÉ PASA DESPUÉS DE CREAR EL PR?

### Timeline Esperado

```
T+0s     : PR creado
           ├─ GitHub detecta cambios en rama
           └─ Busca GitHub Actions workflows

T+5-10s  : Workflow "Validate Solution" se INICIA
           ├─ Trigger: PR abierto
           └─ Regex: ^Solution - .+ - Issue \[\d{3}\]$ ✅

T+10s    : Job 1: parse-pr-title
           ├─ Runner: ubuntu-latest
           ├─ Acción: Extrae "TestCandidate" + "001"
           └─ Duración: ~10 segundos

T+20s    : Job 2: validate-solution INICIA
           ├─ Runner: windows-latest
           ├─ Paso 1: Setup SQL Server 2019
           │          └─ Duración: 30-40s
           │
           ├─ Paso 2: Load Databases
           │          ├─ Crea [BI_Assessment_Source]
           │          ├─ Crea [BI_Assessment_Staging]
           │          ├─ Crea [BI_Assessment_DWH]
           │          └─ Duración: 20s
           │
           ├─ Paso 3: Load Candidate Files
           │          ├─ QA_*.sql
           │          ├─ PROC_*.sql
           │          ├─ SOLUTION.md (word count)
           │          └─ Duración: 10s
           │
           ├─ Paso 4: Validate-Solution.ps1
           │          ├─ Ejecuta 27 checks
           │          ├─ Genera score
           │          └─ Duración: 60-90s
           │
           └─ Paso 5: Post Comment
                      └─ Duración: 5s

T+5-8min : ✅ WORKFLOW COMPLETA
           ├─ Jobs: parse-pr-title ✅, validate-solution ✅
           ├─ PR Comment: Auto-posted ✅
           └─ Score visible: 70/100 ✅ PASS
```

---

## 📊 VER RESULTADOS

### En GitHub.com

1. **Abre tu PR**:
   ```
   https://github.com/ahernandezGH/bi-technical-assessment/pull/[NUMERO]
   ```

2. **Busca el Workflow Comment** (debería aparecer en la pestaña "Conversation"):
   ```
   ✅ Solution Validation Result
   
   Score: 70/100
   Status: PASS
   
   [Detalles expandibles]
   ```

3. **Verifica la pestaña "Checks"**:
   - ✅ parse-pr-title
   - ✅ validate-solution

### En GitHub Actions Tab

1. Ve a: `https://github.com/ahernandezGH/bi-technical-assessment/actions`

2. Busca "Validate Solution" workflow más reciente

3. Haz clic para ver detalles:
   ```
   Validate Solution #4567
   
   Jobs:
   ├─ parse-pr-title
   │  ├─ Status: ✅ Passed
   │  ├─ Duration: 10s
   │  └─ Logs...
   │
   └─ validate-solution
      ├─ Status: ✅ Passed
      ├─ Duration: 5m 30s
      └─ Logs...
   ```

---

## ⚠️ TROUBLESHOOTING

### Workflow no se triggerizó

**Síntomas**:
- No ves workflow en Actions tab
- Pasaron >2 minutos sin que se inicie

**Causas posibles**:
1. ❌ **Título no matchea regex** (más probable)
   - Verifica: `Solution - TestCandidate - Issue [001]`
   - Debe ser EXACTO (case-sensitive)
   - Debe tener ` - ` (espacio-guión-espacio)
   - Debe tener `[001]` (corchetes, 3 dígitos)

2. ❌ **Workflow está deshabilitado** (poco probable)
   - Ve a: `.github/workflows/validate-solution.yml`
   - Verifica que no esté commented

3. ❌ **Rama no existe en origin**
   - Verifica: `git push origin solution-testcandidate-issue001`
   - Debe estar pusheada

**Solución**:
- Cierra el PR (no lo elimines)
- Verifica el título
- Crea nuevo PR con título correcto

---

### Workflow inició pero se detuvo

**Síntomas**:
- Job inició pero muestra ❌
- Logs muestran error

**Causas**:
- Error SQL Server setup
- Error en carga de bases de datos
- Error en validación

**Solución**:
- Haz clic en el job que falló
- Expande los logs
- Busca el error (RED TEXT)
- Reporta el error en el repositorio

---

### Score < 70 (FAIL)

**Síntomas**:
- Workflow completó ✅ pero score < 70
- Comment muestra "NEEDS WORK"

**Soluciones**:
1. Revisa el comment detalladamente
2. Identifica qué falló
3. Corrige los archivos en la rama
4. Haz push nuevamente (auto-comment update será posted)

**Ejemplo de FAIL**:
```
❌ Score: 45/100
Status: FAIL - Needs Work

Issues Found:
- QA_ValidarIntegridadEstudiantes.sql: Syntax error on line 3
- SOLUTION.md: Word count 85 (required: 150+)
- PROC_ValidarIntegridadPreInsert.sql: Compilation failed
```

---

## ✅ CHECKLIST - Antes de crear PR

- [ ] Rama `solution-testcandidate-issue001` creada
- [ ] 3 archivos en `Solutions/TestCandidate/Issue001/`
- [ ] Archivos pusheados a origin
- [ ] URL de PR ready: `https://github.com/ahernandezGH/bi-technical-assessment/pull/new/solution-testcandidate-issue001`
- [ ] Título exacto memorizó: `Solution - TestCandidate - Issue [001]`
- [ ] Body preparado (opcional)

---

## 📝 SIGUIENTE PASO

Una vez creado el PR:

1. **Espera 5-8 minutos** para que el workflow complete
2. **Monitorea Actions tab** para ver progreso
3. **Lee el comment auto-posted** con los resultados
4. **Documenta los resultados** en `PHASE_5_4_RESULTS.md`

---

**Documento**: Step 6 de Phase 5.4  
**Siguiente**: Step 7 - Monitorear Workflow
