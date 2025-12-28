# SQL Style Guide - BI Technical Assessment

**Version**: 1.0  
**Last Updated**: 2024-12-28

---

## 📋 Tabla de Contenidos

1. [Naming Conventions](#naming-conventions)
2. [Formatting](#formatting)
3. [Comments](#comments)
4. [Best Practices](#best-practices)
5. [Performance Considerations](#performance-considerations)

---

## 🏷️ Naming Conventions

### Databases

```sql
-- PATTERN: [Domain]_[Layer]
-- Domain: ACA, FIN, IMB, Banner, Cobranza
-- Layer: Stagging, DWH

✅ BI_Assessment_Staging
✅ BI_Assessment_DWH
❌ Staging  (too generic)
❌ DWH_Assessment  (wrong order)
```

### Schemas

```sql
-- PATTERN: [Purpose]
-- Purpose: cat (catalogs), mat (enrollment), ben (benefits), dbo (utilities)

✅ cat.dim_estudiantes
✅ mat.hechos_matricula
✅ ben.hechos_beneficios
❌ catalog.estudiantes
❌ mat_hechos  (should be schema)
```

### Tables

```sql
-- PATTERN: [dim|fact|hechos|lookup]_[descriptor]
-- Prefix: dim (dimension), hechos/fact (facts), lookup/config (reference)

✅ cat.dim_estudiantes (dimension)
✅ mat.hechos_matricula (fact)
✅ ben.lookup_beneficio_tipo (reference)
❌ estudiante  (missing prefix)
❌ fact_matricula_hechos  (redundant)
```

### Stored Procedures

```sql
-- PATTERN: sp_[Purpose][Verb]
-- Verb: Create, Update, Delete, Sync, Refresh, Validate, Report

✅ sp_SincronizarDimensionPersonas
✅ sp_ValidarIntegridadPreInsert
✅ sp_ReporteMatriculaPorFacultad
❌ UpdatePersonas  (missing sp_ prefix)
❌ sincronizar  (should be PascalCase)
```

### Functions

```sql
-- PATTERN: fn_[Purpose]
✅ fn_CalcularEdadEstudiante
✅ fn_NormalizarRUT
❌ GetAge  (missing fn_ prefix)
```

### Views

```sql
-- PATTERN: v_[Purpose]
-- If materialized: mv_[Purpose]

✅ v_hechos_matricula_consolidado
✅ mv_estudiantes_activos
❌ vw_view  (redundant)
❌ materialized_view  (missing prefix)
```

### Indexes

```sql
-- PATTERN: IX_[TableName]_[Columns]

✅ IX_hechos_matricula_id_estudiante
✅ IX_dim_estudiantes_id_persona_estado
❌ idx_students  (too vague)
```

### Variables and Parameters

```sql
-- PATTERN: @[PurposeName] (all lowercase after @)

✅ @id_estudiante INT
✅ @fecha_inicio DATETIME
✅ @criterio_busqueda VARCHAR(100)
❌ @ID (all caps)
❌ @StudentID (PascalCase)
```

---

## 🎨 Formatting

### Case and Indentation

```sql
-- GOOD: Uppercase keywords, lowercase identifiers
SELECT 
    e.id_estudiante,
    e.nombre,
    m.fecha_matricula
FROM cat.dim_estudiantes e
LEFT JOIN mat.hechos_matricula m ON e.id_estudiante = m.id_estudiante
WHERE e.estado = 'Activo'
ORDER BY e.nombre;

-- BAD: Lowercase keywords
select e.id_estudiante, e.nombre, m.fecha_matricula
from cat.dim_estudiantes e
left join mat.hechos_matricula m on e.id_estudiante = m.id_estudiante
where e.estado = 'Activo'
order by e.nombre;
```

### Line Length

```sql
-- GOOD: Break long lines at ~100 characters
SELECT 
    e.id_estudiante,
    e.nombre,
    e.email,
    m.fecha_matricula,
    m.estado
FROM cat.dim_estudiantes e
LEFT JOIN mat.hechos_matricula m 
    ON e.id_estudiante = m.id_estudiante
WHERE e.estado = 'Activo'
    AND m.fecha_matricula >= CAST('2024-01-01' AS DATE);

-- BAD: One long line
SELECT e.id_estudiante, e.nombre, e.email, m.fecha_matricula, m.estado FROM cat.dim_estudiantes e LEFT JOIN mat.hechos_matricula m ON e.id_estudiante = m.id_estudiante WHERE e.estado = 'Activo' AND m.fecha_matricula >= CAST('2024-01-01' AS DATE);
```

### JOINs and WHEREs

```sql
-- GOOD: Conditions on separate lines
SELECT *
FROM tabla1 t1
INNER JOIN tabla2 t2 
    ON t1.id = t2.id
    AND t1.estado = 'Activo'
LEFT JOIN tabla3 t3 
    ON t2.id = t3.id
WHERE t1.fecha >= '2024-01-01'
    AND t1.tipo IN ('A', 'B', 'C');

-- BAD: All on one line
SELECT * FROM tabla1 t1 INNER JOIN tabla2 t2 ON t1.id = t2.id AND t1.estado = 'Activo' LEFT JOIN tabla3 t3 ON t2.id = t3.id WHERE t1.fecha >= '2024-01-01' AND t1.tipo IN ('A', 'B', 'C');
```

### CTEs (Common Table Expressions)

```sql
-- GOOD: Separate CTEs, clear ordering
WITH cte_estudiantes AS (
    SELECT 
        id_estudiante,
        nombre,
        estado
    FROM cat.dim_estudiantes
    WHERE estado = 'Activo'
),
cte_matriculas AS (
    SELECT 
        id_estudiante,
        COUNT(*) AS cantidad_matriculas
    FROM mat.hechos_matricula
    GROUP BY id_estudiante
)
SELECT 
    e.id_estudiante,
    e.nombre,
    m.cantidad_matriculas
FROM cte_estudiantes e
LEFT JOIN cte_matriculas m ON e.id_estudiante = m.id_estudiante;

-- BAD: All on one line
WITH cte_estudiantes AS (SELECT id_estudiante, nombre, estado FROM cat.dim_estudiantes WHERE estado = 'Activo'), cte_matriculas AS (SELECT id_estudiante, COUNT(*) AS cantidad_matriculas FROM mat.hechos_matricula GROUP BY id_estudiante) SELECT e.id_estudiante, e.nombre, m.cantidad_matriculas FROM cte_estudiantes e LEFT JOIN cte_matriculas m ON e.id_estudiante = m.id_estudiante;
```

---

## 📝 Comments

### Header Comments

```sql
-- ============================================
-- Título: Validar Integridad Estudiantes
-- Propósito: Detectar FK huérfanos
-- Autor: Tu Nombre
-- Fecha: 2024-12-28
-- ============================================
-- Cambios:
-- 2024-12-28: Versión inicial
-- ============================================
```

### Inline Comments

```sql
SELECT 
    e.id_estudiante,
    e.nombre,
    -- Contar matrículas activas (no las canceladas)
    COUNT(m.id_matricula) AS matriculas_activas
FROM cat.dim_estudiantes e
LEFT JOIN mat.hechos_matricula m 
    ON e.id_estudiante = m.id_estudiante
    AND m.estado NOT IN ('Cancelado', 'Rechazado')
GROUP BY e.id_estudiante, e.nombre;
```

### Block Comments

```sql
/*
  Descripción larga que puede ocupar
  múltiples líneas para explicar
  la lógica compleja del script
*/
SELECT *
FROM tabla
WHERE condicion = 'valor';
```

### Avoid Comments

```sql
-- BAD: Obvious comments
SELECT id_estudiante FROM cat.dim_estudiantes;  -- Select ID from students

-- GOOD: Explanatory comments
-- Exclude students with incomplete profiles
SELECT id_estudiante FROM cat.dim_estudiantes WHERE profile_completeness >= 0.80;
```

---

## ✅ Best Practices

### Use Aliases

```sql
-- GOOD: Clear aliases for all tables
SELECT 
    e.id_estudiante,
    e.nombre,
    m.fecha_matricula
FROM cat.dim_estudiantes e
LEFT JOIN mat.hechos_matricula m ON e.id_estudiante = m.id_estudiante;

-- BAD: No aliases
SELECT 
    dim_estudiantes.id_estudiante,
    dim_estudiantes.nombre,
    hechos_matricula.fecha_matricula
FROM cat.dim_estudiantes
LEFT JOIN mat.hechos_matricula ON dim_estudiantes.id_estudiante = hechos_matricula.id_estudiante;
```

### Explicit Column Names (No *)

```sql
-- GOOD: List specific columns
SELECT 
    e.id_estudiante,
    e.nombre,
    e.email
FROM cat.dim_estudiantes e;

-- BAD: SELECT *
SELECT * FROM cat.dim_estudiantes;  -- Hard to maintain, slow with many columns
```

### Data Type Precision

```sql
-- GOOD: Explicit data types
DECLARE @fecha_inicio DATE = '2024-01-01';
DECLARE @cantidad INT = 100;
DECLARE @nombre VARCHAR(100) = 'Juan';
DECLARE @monto DECIMAL(10, 2) = 1234.56;

-- BAD: Implicit types
DECLARE @fecha_inicio = '2024-01-01';  -- Implicit conversion
DECLARE @nombre = 'Juan';  -- Could overflow
```

### NULL Handling

```sql
-- GOOD: Explicit NULL handling
SELECT 
    e.id_estudiante,
    e.nombre,
    ISNULL(m.fecha_matricula, CAST('1900-01-01' AS DATE)) AS fecha_matricula
FROM cat.dim_estudiantes e
LEFT JOIN mat.hechos_matricula m ON e.id_estudiante = m.id_estudiante;

-- ALSO GOOD: COALESCE
SELECT 
    COALESCE(e.nombre, 'Sin nombre') AS nombre
FROM cat.dim_estudiantes e;
```

### Error Handling

```sql
-- GOOD: TRY/CATCH pattern
BEGIN TRY
    INSERT INTO cat.dim_estudiantes VALUES (...)
    
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    
    DECLARE @ErrorMsg NVARCHAR(MAX) = ERROR_MESSAGE()
    RAISERROR(@ErrorMsg, 16, 1)
END CATCH

-- BAD: No error handling
INSERT INTO cat.dim_estudiantes VALUES (...)
```

---

## ⚡ Performance Considerations

### Use Proper Indexes

```sql
-- GOOD: Indexed JOIN columns
CREATE INDEX IX_hechos_matricula_id_estudiante 
ON mat.hechos_matricula(id_estudiante);

-- QUERY PLAN: Seek (efficient)
SELECT * FROM mat.hechos_matricula WHERE id_estudiante = 5;
```

### Avoid Functions on WHERE Columns

```sql
-- GOOD: Direct comparison
WHERE fecha_matricula >= '2024-01-01';

-- BAD: Function blocks index use
WHERE CAST(fecha_matricula AS DATE) >= '2024-01-01';
WHERE YEAR(fecha_matricula) = 2024;
```

### Use UNION ALL over UNION

```sql
-- GOOD: UNION ALL (no distinct overhead)
SELECT id FROM tabla1
UNION ALL
SELECT id FROM tabla2;

-- BAD: UNION (applies DISTINCT)
SELECT id FROM tabla1
UNION
SELECT id FROM tabla2;
```

### Batch Operations

```sql
-- GOOD: Batch INSERT for large data
INSERT INTO tabla (col1, col2)
SELECT col1, col2 FROM fuente
WHERE condicion = 'valor';

-- BAD: Row-by-row INSERT
FOR EACH row IN fuente DO
    INSERT INTO tabla ...
END FOR
```

---

## 🔍 Checklist

Before submitting SQL scripts:

- [ ] All tables prefixed with schema (cat., mat., etc.)
- [ ] All stored procedures named sp_*
- [ ] All variables prefixed with @
- [ ] Comments explain WHY, not WHAT
- [ ] Line length ≤ 100 characters
- [ ] Proper indentation (4 spaces)
- [ ] No SELECT * (explicit columns)
- [ ] NULL handling explicit
- [ ] Error handling (TRY/CATCH)
- [ ] Aliases for all tables
- [ ] Data types explicit and precise
- [ ] No functions on WHERE columns (for performance)
- [ ] Comments in English or Spanish (consistent)

---

Created: 2024-12-28
