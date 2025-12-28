# Issue 001 - Archivos Requeridos

## Estructura de Entrega

```
Solutions/[TuNombre]/Issue001/
├── QA_ValidarIntegridadEstudiantes.sql      (OBLIGATORIO)
├── PROC_ValidarIntegridadPreInsert.sql      (OBLIGATORIO)
└── SOLUTION.md                               (OBLIGATORIO)
```

---

## 1. QA_ValidarIntegridadEstudiantes.sql

### Propósito
Validar integridad referencial detectando registros "huérfanos" en tablas de hechos.

### Requisitos Técnicos
- **Ubicación**: Raíz de carpeta Issue001
- **Nombrado exactamente**: `QA_ValidarIntegridadEstudiantes.sql`
- **Database**: Ejecutable en `BI_Assessment_DWH`
- **Contenido mínimo**:
  - Contador de FK huérfanos (debe retornar 15)
  - Al menos 2 consultas: count + details
  - Comentarios explicativos

### Validación del Validator
```
CHECK 1: Archivo existe
CHECK 2: Sintaxis SQL válida (SET PARSEONLY)
```

### Ejemplo Mínimo
```sql
-- Contar huérfanos
SELECT COUNT(*) FROM mat.hechos_matricula
WHERE id_estudiante NOT IN (SELECT id_estudiante FROM cat.dim_estudiantes);

-- Listar detalles
SELECT TOP 100 * FROM mat.hechos_matricula
WHERE id_estudiante > 99980;
```

---

## 2. PROC_ValidarIntegridadPreInsert.sql

### Propósito
Crear procedure que valide integridad ANTES de insertar registros nuevos.

### Requisitos Técnicos
- **Ubicación**: Raíz de carpeta Issue001
- **Nombrado exactamente**: `PROC_ValidarIntegridadPreInsert.sql`
- **Database**: Ejecutable en `BI_Assessment_DWH`
- **Contenido mínimo**:
  - Declaración de PROCEDURE (nombre flexible)
  - Parameter: `@id_estudiante INT`
  - Validación: EXISTS vs NOT EXISTS
  - Error handling: TRY/CATCH o IF ... RAISERROR
  - Comentarios explicativos

### Validación del Validator
```
CHECK 2: Sintaxis SQL válida (SET PARSEONLY)
```

### Estructura Recomendada
```sql
CREATE PROCEDURE [schema].[sp_ValidarIntegridadPreInsert]
    @id_estudiante INT
AS
BEGIN
    IF NOT EXISTS (...)
    BEGIN
        RAISERROR('...', 16, 1)
    END
END
```

---

## 3. SOLUTION.md

### Propósito
Explicar el problema, metodología de solución, y validaciones realizadas.

### Requisitos Técnicos
- **Ubicación**: Raíz de carpeta Issue001
- **Nombrado exactamente**: `SOLUTION.md`
- **Formato**: Markdown válido
- **Contenido mínimo**: 150 palabras (contador automático en validator)
- **Estructura sugerida**:

```markdown
# Solución - Issue 001: Validación de Integridad Referencial

## Problema Identificado
[1-2 párrafos describiendo qué es, impacto, scope]

## Causa Raíz
[Análisis técnico de por qué ocurre]

## Solución Propuesta
[Metodología elegida y justificación]

## Script 1: QA_ValidarIntegridadEstudiantes.sql
[Descripción, propósito, resultados esperados]

## Script 2: PROC_ValidarIntegridadPreInsert.sql
[Descripción, propósito, parámetros]

## Validación Ejecutada
[Queries ejecutadas, resultados obtenidos, métricas]

## Conclusiones
[Resumen, recomendaciones futuras]
```

### Scoring
- Mínimo 150 palabras: 20/20 puntos
- 100-149 palabras: 13/20 puntos
- 50-99 palabras: 7/20 puntos
- < 50 palabras: 0/20 puntos

---

## Checklist de Entrega

Antes de hacer commit, verifica:

- [ ] **QA_ValidarIntegridadEstudiantes.sql**
  - [ ] Existe en carpeta Issue001
  - [ ] Nombrado exactamente (sin espacios, sin caracteres especiales)
  - [ ] Ejecutable sin errores en SSMS
  - [ ] Retorna 2+ queries
  - [ ] Tiene comentarios explicativos

- [ ] **PROC_ValidarIntegridadPreInsert.sql**
  - [ ] Existe en carpeta Issue001
  - [ ] Nombrado exactamente
  - [ ] Ejecutable sin errores en SSMS
  - [ ] Crea procedure exitosamente
  - [ ] Tiene TRY/CATCH o error handling

- [ ] **SOLUTION.md**
  - [ ] Existe en carpeta Issue001
  - [ ] Nombrado exactamente (mayúsculas importan)
  - [ ] Formato Markdown válido (sin comillas mal cerradas)
  - [ ] Mínimo 150 palabras
  - [ ] Tiene todas las secciones (Problema, Solución, Scripts, Validación, Conclusiones)
  - [ ] Menciona scripts desarrollados por nombre

- [ ] **General**
  - [ ] Folder: `Solutions/[TuNombre]/Issue001/` (sin espacios)
  - [ ] Git branch: main
  - [ ] PR Title: `Solution - [TuNombre] - Issue [001]` (exacto)
  - [ ] Validator local: 70+ puntos

---

## Ejemplo de Estructura Correcta

```
Solutions/JuanPerez/Issue001/
├── QA_ValidarIntegridadEstudiantes.sql
│   └─ 45 líneas, 2 queries, 8 comentarios
├── PROC_ValidarIntegridadPreInsert.sql
│   └─ 28 líneas, TRY/CATCH, error handling
└── SOLUTION.md
    └─ 312 palabras, todas las secciones

Total: 385 líneas de código/docs
Scoring esperado: 70/100 (Documentación incompleta)
```

---

## Common Mistakes

❌ **INCORRECTO**:
```
Solutions/Juan Perez/Issue 001/        ← Espacios en nombres
Solutions/JuanPerez/Issue1/            ← Solo 1 dígito
Solutions/JuanPerez/Issue001/Qa_*.sql  ← Casos distintos
Solutions/JuanPerez/Issue001/README.md ← Nombre equivocado
```

✅ **CORRECTO**:
```
Solutions/JuanPerez/Issue001/
  QA_ValidarIntegridadEstudiantes.sql
  PROC_ValidarIntegridadPreInsert.sql
  SOLUTION.md
```

---

## Revisión Pre-Submission

Run this locally:

```powershell
# Validar syntax
.\Tools\Validate-Solution.ps1 -Issue "001" -Candidate "JuanPerez" -DryRun

# Esperar: CHECK 1: 25/25, CHECK 2: skip (DryRun), CHECK 3: XX/20

# Validar completo
.\Tools\Validate-Solution.ps1 -Issue "001" -Candidate "JuanPerez"

# Esperar: SCORE 70+/100, STATUS: PASS
```

---

Created: 2024-12-28
