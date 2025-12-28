# Issue 001 - Tips y Conceptos

---

## 💡 Tip 1: Detectar FK Huérfanos con LEFT JOIN

**Patrón recomendado**:

```sql
SELECT f.*
FROM mat.hechos_matricula f
LEFT JOIN cat.dim_estudiantes d 
    ON f.id_estudiante = d.id_estudiante
WHERE d.id_estudiante IS NULL  -- Solo los sin match (huérfanos)
```

**Por qué LEFT JOIN en lugar de NOT IN**:
- NOT IN falla si la subquery contiene NULL
- LEFT JOIN + IS NULL es más legible y performante
- Compatible con índices (execution plan mejor)

---

## 💡 Tip 2: Usar COUNT(*) para Resumen

```sql
-- MALO: Retorna 15 filas (una por huérfano)
SELECT id_estudiante, id_matricula 
FROM mat.hechos_matricula
WHERE id_estudiante NOT IN (...)

-- MEJOR: Retorna 1 fila con total
SELECT COUNT(*) AS cantidad_huerfanos
FROM mat.hechos_matricula
WHERE id_estudiante NOT IN (...)
```

**En validator, el score depende de**:
- Sintaxis SQL válida ✓
- Retorna resultado (no importa cantidad de filas)
- Incluye explicación en documentación

---

## 💡 Tip 3: Procedure con Validación Simple

```sql
CREATE PROCEDURE [mat].[sp_ValidarIntegridadPreInsert]
    @id_estudiante INT
AS
BEGIN
    -- Verificar que existe
    IF NOT EXISTS (SELECT 1 FROM cat.dim_estudiantes 
                   WHERE id_estudiante = @id_estudiante)
    BEGIN
        RAISERROR('Estudiante %d no existe', 16, 1, @id_estudiante);
        RETURN 1;
    END
    
    RETURN 0;  -- OK
END
```

**Notas**:
- Use `SELECT 1` en NOT EXISTS (más rápido que `SELECT *`)
- RAISERROR severidad 16 = error (detiene transaction)
- RETURN values: 0=OK, 1=Error (convención)

---

## 💡 Tip 4: Comentarios Útiles

```sql
-- MALO: Comentarios obvios
SELECT COUNT(*) -- contar
FROM mat.hechos_matricula  -- tabla hechos matricula

-- MEJOR: Comentarios explicativos
-- ============================================
-- Objetivo: Contar registros FK huérfanos
-- Lógica: Estudios sin match en dim_estudiantes
-- Esperado: 15 registros (datos prueba)
-- ============================================
SELECT COUNT(*) AS cantidad_huerfanos
FROM mat.hechos_matricula f
LEFT JOIN cat.dim_estudiantes d ON f.id_estudiante = d.id_estudiante
WHERE d.id_estudiante IS NULL;
```

---

## 💡 Tip 5: Usar TOP para Debugging

```sql
-- Cuando trabajes en desarrollo:
-- 1. Primero testear con TOP 10
SELECT TOP 10
    f.id_matricula,
    f.id_estudiante,
    f.fecha_matricula
FROM mat.hechos_matricula f
WHERE f.id_estudiante > 99980;

-- 2. Cuando funcione, cambiar a TOP 100 (o ALL)
SELECT TOP 100
    ...

-- 3. En producción, usar TOP o WHERE para limitar
SELECT 
    ...
```

---

## 💡 Tip 6: Testing Manual antes de Submitter

**Paso 1: Testear Query en SSMS**

```sql
-- Copiar contenido de QA_ValidarIntegridadEstudiantes.sql
-- Pegar en SSMS
-- Cambiar database a BI_Assessment_DWH
-- Ejecutar (F5)
-- Verificar: Retorna datos sin errores
```

**Paso 2: Testear Procedure en SSMS**

```sql
-- Copiar contenido de PROC_ValidarIntegridadPreInsert.sql
-- Ejecutar para CREAR el procedure
-- Luego testear:

EXEC mat.sp_ValidarIntegridadPreInsert @id_estudiante = 1;
-- Output: Mensaje éxito

EXEC mat.sp_ValidarIntegridadPreInsert @id_estudiante = 99999;
-- Output: Error (id no existe)
```

**Paso 3: Testear con Validator Local**

```powershell
.\Tools\Validate-Solution.ps1 -Issue "001" -Candidate "TuNombre"

# Si hay errores:
# - ERROR en CHECK 2 = syntax error en SQL
#   → Abrir script en SSMS, encontrar línea roja, corregir
# - ERROR en CHECK 3 = SOLUTION.md < 150 palabras
#   → Agregar más contenido (referencias, recomendaciones)
```

---

## 💡 Tip 7: SOLUTION.md - Estructura Probada

```markdown
# Solución Issue 001

## Problema
[Describe qué es un FK huérfano, por qué ocurre, impacto en reportes]

Palabras clave: "integridad referencial", "datos inconsistentes", "dimension", "hechos"

## Metodología
[Explica tu enfoque: queries para detectar + procedure para prevenir]

## Queries Desarrolladas

### QA_ValidarIntegridadEstudiantes.sql
Detecta registros en hechos_matricula sin match en dim_estudiantes.
Usando LEFT JOIN para máxima claridad.
Retorna contador + detalles de los 100 primeros huérfanos.

### PROC_ValidarIntegridadPreInsert.sql
Crea procedure que valida id_estudiante antes de operaciones INSERT.
Implementa TRY/CATCH para manejo de errores.
RAISERROR detiene la transaction si ID no existe.

## Resultados
[Paste salida de SSMS]
```
Cantidad de huérfanos: 15
Detalles: [tabla con IDs]
```
[Describe qué observaste]

## Conclusiones
[Recomendaciones para evitar en futuro]
```

**Esto suma ~200-250 palabras automáticamente** ✓

---

## 💡 Tip 8: Errores Comunes y Soluciones

**Error 1: "Procedure already exists"**
```sql
-- MALO:
CREATE PROCEDURE [mat].[sp_ValidarIntegridadPreInsert] ...

-- MEJOR:
IF OBJECT_ID('[mat].[sp_ValidarIntegridadPreInsert]') IS NOT NULL
    DROP PROCEDURE [mat].[sp_ValidarIntegridadPreInsert];

CREATE PROCEDURE [mat].[sp_ValidarIntegridadPreInsert] ...
```

**Error 2: "Invalid column name 'id_estudiante'"**
```sql
-- Verificar nombre exacto de columna:
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'hechos_matricula';

-- Luego usar nombre exacto (respeta case)
SELECT id_estudiante FROM mat.hechos_matricula;
```

**Error 3: "RAISERROR" no reconocido**
```sql
-- MALO: RAISE ERROR (dos palabras)
-- CORRECTO: RAISERROR (una palabra)
RAISERROR('Mensaje', 16, 1);
```

---

## 💡 Tip 9: Validación de Datos

**Antes de submit, verifica que**:

```sql
-- 1. dim_estudiantes tiene 20 registros
SELECT COUNT(*) FROM cat.dim_estudiantes;
-- Output: 20

-- 2. hechos_matricula tiene FK válidos + huérfanos
SELECT 
    COUNT(CASE WHEN id_estudiante <= 20 THEN 1 END) AS validos,
    COUNT(CASE WHEN id_estudiante > 99980 THEN 1 END) AS huerfanos
FROM mat.hechos_matricula;
-- Output: validos=10, huerfanos=15

-- 3. Query QA retorna 15
[Copia QA_ValidarIntegridadEstudiantes.sql y ejecuta]
-- Output: 15
```

---

## 💡 Tip 10: SOLUTION.md Word Count

**Cómo contar palabras**:

```powershell
# PowerShell
$content = Get-Content "Solutions\[TuNombre]\Issue001\SOLUTION.md" -Raw
$wordCount = ($content -split '\s+').Count
Write-Host "Palabras: $wordCount"
# Output: Palabras: 267 (ejemplo)
```

**Si < 150 palabras**:
- Agregra más detalles en "Conclusiones"
- Explica por qué elegiste LEFT JOIN vs NOT IN
- Menciona edge cases (NULL values, performance)
- Cita referencias (SQL Docs, best practices)

---

## 🎯 Resumen: Pasos para Resolver

1. **Entender el problema** (5 min)
   - Leer README.md
   - Revisar datos en SSMS
   - Entender arquitectura 3-layer

2. **Escribir Query QA** (45 min)
   - Draft en SSMS (probar linea por linea)
   - Refactorir para legibilidad
   - Agregar comentarios explicativos
   - Salvar como QA_ValidarIntegridadEstudiantes.sql

3. **Escribir Procedure** (45 min)
   - Lógica simple: IF NOT EXISTS → RAISERROR
   - Testear con buenos y malos IDs
   - Agregar TRY/CATCH si necesario
   - Salvar como PROC_ValidarIntegridadPreInsert.sql

4. **Documentar en SOLUTION.md** (60 min)
   - Copiar template de Tip 7
   - Completar cada sección
   - Ejecutar word count
   - Agregar más párrafos si < 150 palabras

5. **Validar Localmente** (15 min)
   - Ejecutar validator
   - Corregir errores de sintaxis si hay
   - Confirmar score ≥ 70

6. **Commit y PR** (5 min)
   - Git add/commit
   - Push
   - Crear PR con título exacto

**Tiempo total: ~3 horas**

---

Created: 2024-12-28
