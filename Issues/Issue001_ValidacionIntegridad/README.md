# Issue 001 - Validación de Integridad Referencial

**Dificultad**: ⭐⭐ Básico  
**Tiempo Estimado**: 4 horas  
**Puntos**: 70 puntos  
**Fecha Creación**: 2024-12-28

---

## 📋 Descripción del Problema

El equipo BI ha detectado inconsistencias en los datos de matrícula después de migraciones desde Oracle Banner. Específicamente, existen registros en las tablas de "hechos" (matrícula y beneficios) que apuntan a estudiantes inexistentes en la dimensión de personas.

**Impacto**:
- Reportes Power BI muestran filas sin contexto (NULL en joins)
- SSAS cube falla al procesar
- Análisis de cohortes imposible

**Objetivo**: Crear queries y procedures que detecten y documenten estos registros "huérfanos" para auditoría y resolución.

---

## 🎯 Requisitos Técnicos

### Entrada (Input)

**Databases**:
- `SchoolERP_Source`: Datos crudos de Oracle Banner
- `BI_Assessment_Staging`: Staging de ETL
- `BI_Assessment_DWH`: Capa de presentación

**Tablas Clave**:
- `[BI_Assessment_DWH].cat.dim_estudiantes` (dimension)
- `[BI_Assessment_DWH].mat.hechos_matricula` (fact table)

**Datos de Prueba**:
- 20 personas válidas (id_estudiante 1-20)
- 15 registros FK huérfanos (id_estudiante > 99980)

### Salida (Output)

**Query de Validación** (`QA_ValidarIntegridadEstudiantes.sql`):
- Cuenta total de FK huérfanos en `hechos_matricula`
- Lista detallada con id, semestre, estado

**Procedure de Prevención** (`PROC_ValidarIntegridadPreInsert.sql`):
- Procedure que bloquea INSERT de FK huérfanos
- RAISERROR si intenta insertar id_estudiante no existente
- Logging de intentos rechazados

**Documentación** (`SOLUTION.md`):
- Explicación del problema y solución
- Metodología de validación
- Recomendaciones para evitar en futuro

---

## 📝 Archivos Requeridos

```
Solutions/[TuNombre]/Issue001/
├── QA_ValidarIntegridadEstudiantes.sql      (Query de validación)
├── PROC_ValidarIntegridadPreInsert.sql      (Procedure de prevención)
└── SOLUTION.md                               (Documentación - mínimo 150 palabras)
```

### QA_ValidarIntegridadEstudiantes.sql

**Requisitos**:
- Query ejecutable directamente en `BI_Assessment_DWH`
- Retorna contador de FK huérfanos (esperado: 15)
- Incluye details con id_estudiante, fecha_matricula, estado
- Comentarios explicativos

**Estructura esperada**:
```sql
-- ============================================
-- Query: Validar Integridad Estudiantes
-- Propósito: Detectar FK huérfanos
-- Autor: [Tu Nombre]
-- Fecha: 2024-12-28
-- ============================================

-- Verificar FK huérfanos
SELECT ...

-- Listar detalles
SELECT TOP 100 ...
WHERE id_estudiante NOT IN (SELECT id_estudiante FROM cat.dim_estudiantes)
```

### PROC_ValidarIntegridadPreInsert.sql

**Requisitos**:
- Crea PROCEDURE validador
- Input: `@id_estudiante INT`
- Retorna: EXIT 0 (OK) o RAISERROR
- Usa TRY/CATCH para manejo de errores

**Lógica**:
```sql
CREATE PROCEDURE [mat].[sp_ValidarIntegridadPreInsert]
    @id_estudiante INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM cat.dim_estudiantes WHERE id_estudiante = @id_estudiante)
    BEGIN
        RAISERROR('ID estudiante %d no existe en dimension', 16, 1, @id_estudiante)
        RETURN 1
    END
    RETURN 0
END
```

### SOLUTION.md

**Contenido mínimo** (150 palabras):
1. Análisis del problema
2. Causa raíz
3. Soluciones propuestas (prevención vs limpieza)
4. Scripts desarrollados
5. Pruebas ejecutadas
6. Recomendaciones futuras

**Estructura sugerida**:
```markdown
## Problema
[1-2 párrafos: ¿Qué es? ¿Cuánto impacta?]

## Causa Raíz
[Análisis: ¿Por qué ocurre?]

## Metodología de Solución
[Estrategia: Prevención vs Limpieza]

## Scripts Desarrollados
### Query QA_ValidarIntegridadEstudiantes.sql
[Descripción breve]

### Procedure PROC_ValidarIntegridadPreInsert.sql
[Descripción breve]

## Validación Ejecutada
[Queries de prueba + resultados]

## Conclusiones
[Resumen y recomendaciones]
```

---

## 💡 Hints y Conceptos Clave

### 1. LEFT JOIN para Detectar Huérfanos

```sql
-- Pattern: Detectar registros sin match en dimension
SELECT f.*
FROM mat.hechos_matricula f
LEFT JOIN cat.dim_estudiantes d ON f.id_estudiante = d.id_estudiante
WHERE d.id_estudiante IS NULL  -- Los huérfanos
```

### 2. NOT IN vs LEFT JOIN Performance

```sql
-- OPCION 1: NOT IN (evitar con NULLs)
SELECT * FROM mat.hechos_matricula 
WHERE id_estudiante NOT IN (SELECT id_estudiante FROM cat.dim_estudiantes)

-- OPCION 2: LEFT JOIN (más eficiente)
SELECT f.* FROM mat.hechos_matricula f
LEFT JOIN cat.dim_estudiantes d ON f.id_estudiante = d.id_estudiante
WHERE d.id_estudiante IS NULL
```

### 3. Procedure con Error Handling

```sql
CREATE PROCEDURE [schema].[sp_NombreProcedure]
    @parametro1 INT,
    @parametro2 VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        -- Lógica
        IF NOT EXISTS (SELECT 1 FROM tabla WHERE id = @parametro1)
        BEGIN
            RAISERROR('Parámetro inválido', 16, 1)
        END
    END TRY
    BEGIN CATCH
        -- Logging y error handling
        THROW
    END CATCH
END
```

### 4. Datos de Prueba

**Estudiantes válidos**: 
```sql
SELECT * FROM cat.dim_estudiantes
-- id_estudiante: 1-20 (20 registros)
```

**FK Huérfanos**:
```sql
SELECT * FROM mat.hechos_matricula
WHERE id_estudiante > 99980
-- 15 registros intentados
```

---

## 🧪 Validación Local

### Antes de Submitter

```powershell
# 1. Ejecutar queries manualmente en SSMS
# - Copiar QA_ValidarIntegridadEstudiantes.sql
# - Ejecutar en BI_Assessment_DWH
# - Verificar retorna 15 FK huérfanos

# 2. Crear procedure
# - Copiar PROC_ValidarIntegridadPreInsert.sql
# - Ejecutar en BI_Assessment_DWH
# - Verificar que se crea sin errores

# 3. Testear procedure
sqlcmd -S localhost -U sa -P password -d BI_Assessment_DWH -Q @"
  EXEC mat.sp_ValidarIntegridadPreInsert @id_estudiante = 1
  -- Debe retornar: 0 (exitoso)
  
  EXEC mat.sp_ValidarIntegridadPreInsert @id_estudiante = 99999
  -- Debe retornar: Error + RAISERROR
"@

# 4. Validar syntax de todo
.\Tools\Validate-Solution.ps1 -Issue "001" -Candidate "[TuNombre]" -DryRun
```

### Con el Validator

```powershell
# Ejecutar validador completo
.\Tools\Validate-Solution.ps1 -Issue "001" -Candidate "[TuNombre]" -ServerName "localhost" -Username "sa" -Password "password"

# Output esperado:
# CHECK 1: Archivos Requeridos      ✓ 25/25 pts
# CHECK 2: Sintaxis SQL              ✓ 25/25 pts  
# CHECK 3: Documentación             ✓ 20/20 pts
# SCORE: 70/100 - STATUS: PASS
```

---

## 📚 Referencias

### Documentación SQL Server
- [Constraints (PRIMARY KEY, FOREIGN KEY)](https://learn.microsoft.com/en-us/sql/relational-databases/tables/primary-and-foreign-key-constraints)
- [CREATE PROCEDURE](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-procedure-transact-sql)
- [RAISERROR](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/raiserror-transact-sql)

### Arquitectura del Repositorio
- [ESTANDARES_ARQUITECTURA_BD.md](../../Features/ESTANDARES_ARQUITECTURA_BD.md): Patterns ETL
- [ESTANDARES_NOMENCLATURA.md](../../Features/ESTANDARES_NOMENCLATURA.md): Naming conventions

### Datos de Prueba
- [LOAD_Basic_TestData.sql](../../Database/02_Data/LOAD_Basic_TestData.sql): Script de carga

---

## 🎬 Ejemplo de Solución (Parcial)

```sql
-- ============================================
-- QUERY: Validar Integridad Estudiantes
-- ============================================

USE BI_Assessment_DWH;

-- PARTE 1: Contar FK huérfanos
SELECT 
    COUNT(*) AS cantidad_huerfanos,
    'hechos_matricula' AS tabla_afectada
FROM mat.hechos_matricula f
WHERE f.id_estudiante NOT IN (SELECT id_estudiante FROM cat.dim_estudiantes)

UNION ALL

SELECT 
    COUNT(*),
    'hechos_beneficios'
FROM ben.hechos_beneficios f
WHERE f.id_estudiante NOT IN (SELECT id_estudiante FROM cat.dim_estudiantes);

-- PARTE 2: Listar detalles (TOP 100)
SELECT TOP 100
    f.id_matricula,
    f.id_estudiante,
    f.fecha_matricula,
    f.estado,
    d.id_estudiante AS 'existe_en_dim'
FROM mat.hechos_matricula f
LEFT JOIN cat.dim_estudiantes d ON f.id_estudiante = d.id_estudiante
WHERE d.id_estudiante IS NULL
ORDER BY f.id_estudiante DESC;
```

---

## ❓ Preguntas Frecuentes

### ¿Qué diferencia hay entre mi query y la procedure?
- **Query (QA_)**: Lee datos, detecta problemas (validación post-hoc)
- **Procedure (PROC_)**: Bloquea inserts, previene problemas (proactivo)

### ¿Debo limpiar los FK huérfanos?
**No**. El assessment es detectarlos y documentarlos, no eliminarlos. La decisión de limpieza depende del negocio.

### ¿Puedo usar CTE o window functions?
**Sí**. Cualquier T-SQL válido es aceptado. Se recomienda usar CTEs para legibilidad.

### ¿El ID estudiante debe ser INT?
Sí, según schema de BI_Assessment_DWH. Verificar en la tabla dim_estudiantes.

---

## 📞 Soporte

Si tienes preguntas sobre este issue:
1. Consulta [SETUP.md](../../SETUP.md) para asuntos de configuración
2. Revisa [ESTANDARES_ARQUITECTURA_BD.md](../../Features/ESTANDARES_ARQUITECTURA_BD.md) para patterns
3. Crea issue en GitHub repo con tag `@ahernandezGH`

---

**Created**: 2024-12-28  
**Last Updated**: 2024-12-28  
**Category**: Data Quality / Validación
