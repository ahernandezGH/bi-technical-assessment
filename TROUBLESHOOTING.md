# Troubleshooting Guide - BI Technical Assessment

Este documento cubre problemas comunes y sus soluciones. Si encuentras un error, consulta primero esta guía antes de crear un issue.

---

## 📑 Índice

1. [Problemas de Setup Inicial](#problemas-de-setup-inicial)
2. [Errores de Conexión a Base de Datos](#errores-de-conexión-a-base-de-datos)
3. [GitHub Actions: Workflow No Se Ejecuta](#github-actions-workflow-no-se-ejecuta)
4. [Errores del Validador (Validate-Solution.ps1)](#errores-del-validador-validate-solutionps1)
5. [Errores de Ejecución SQL](#errores-de-ejecución-sql)
6. [Errores Comunes por Issue](#errores-comunes-por-issue)

---

## Problemas de Setup Inicial

### Error: "sqlcmd is not recognized as an internal or external command"

**Causa**: SQL Server Command Line Utilities no está instalado o no está en PATH.

**Solución**:

```powershell
# 1. Descargar e instalar SQL Server Command Line Utilities
# https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility

# 2. Verificar instalación
sqlcmd -?

# 3. Si aún no funciona, agregar a PATH manualmente:
$env:Path += ";C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\"
```

### Error: "Cannot find path 'Database\01_Schema\CREATE_*.sql'"

**Causa**: El repositorio está incompleto o ejecutaste el script desde el directorio incorrecto.

**Solución**:

```powershell
# 1. Verificar estructura de carpetas
Get-ChildItem -Recurse -Depth 2

# 2. Navegar a la raíz del repositorio
cd C:\Projects\bi-technical-assessment

# 3. Re-ejecutar scripts desde la raíz
sqlcmd -S SERVERNAME -U usuario -P password -i .\Database\01_Schema\CREATE_BI_Assessment_DWH.sql
```

---

## Errores de Conexión a Base de Datos

### Error: "Login failed for user 'sa'"

**Causa**: Autenticación SQL Server no habilitada o credenciales incorrectas.

**Solución**:

```sql
-- 1. Conectar con autenticación Windows en SSMS
-- 2. Habilitar autenticación mixta:
USE master;
GO
EXEC xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE', 
    N'Software\Microsoft\MSSQLServer\MSSQLServer', 
    N'LoginMode', 
    REG_DWORD, 
    2;
GO

-- 3. Reiniciar servicio SQL Server
```

O usar autenticación Windows (Trusted):

```powershell
# Remover parámetros -U y -P
sqlcmd -S SERVERNAME -E -i script.sql
```

### Error: "Cannot open database 'BI_Assessment_DWH'"

**Causa**: La base de datos no existe aún.

**Solución**:

```powershell
# Ejecutar scripts de creación en orden:
sqlcmd -S SERVERNAME -U usuario -P password -i .\Database\01_Schema\CREATE_BI_Assessment_DWH.sql
sqlcmd -S SERVERNAME -U usuario -P password -i .\Database\02_Data\LOAD_Basic_TestData.sql
sqlcmd -S SERVERNAME -U usuario -P password -i .\Database\02_Data\INSERT_EdgeCases.sql
```

---

## GitHub Actions: Workflow No Se Ejecuta

### Problema: "Creé mi PR pero el workflow no inicia"

**Diagnóstico**:

```powershell
# 1. Verificar formato del título del PR (EXACTO):
# ✅ CORRECTO: "Solution - JuanPerez - Issue [001]"
# ❌ INCORRECTO: "Solution: JuanPerez Issue 001"
# ❌ INCORRECTO: "Solution - Juan Perez - Issue [1]"
# ❌ INCORRECTO: "Solution-JuanPerez-Issue[001]"

# 2. Verificar que el workflow existe:
Get-Content .\.github\workflows\validate-solution.yml

# 3. Verificar que el PR está en la rama correcta
# (debe ser PR hacia 'main' desde tu branch)
```

**Solución**:

```powershell
# Renombrar el PR con el formato exacto:
# GitHub UI → Pull Request → Edit Title
# Formato: "Solution - [TuNombre] - Issue [00X]"
#          ^                    ^        ^
#          Espacios obligatorios alrededor del guión
#          Sin espacios en nombre (usa CamelCase)
#          3 dígitos en número de issue
```

### Problema: "Workflow falla con 'ValidationQuery: command not found'"

**Causa**: El archivo `Validate-Solution.ps1` tiene errores de sintaxis o el servidor SQL no responde.

**Solución**:

```powershell
# Probar localmente primero:
.\Tools\Validate-Solution.ps1 -Issue "001" -Candidate "TestCandidate" -ServerName "AHMHW" -Username "rl" -Password "rl2"

# Si falla localmente, corregir antes de hacer PR
```


### Problema: "Fork creado pero GitHub Actions no se ejecutan"

**Causa**: Por defecto, GitHub deshabilita los workflows en repositorios forkeados por seguridad.

**Solucion**:

1. Ve a tu fork: `https://github.com/[TU_USERNAME]/bi-technical-assessment`
2. Click en la pestana **Actions**
3. Veras un mensaje: "Workflows arent being run on this forked repository"
4. Click en **I understand my workflows, go ahead and enable them**
5. Crea tu PR nuevamente (o cierra y abre si ya existia)

### Problema: "Error 403: Resource not accessible by integration"

**Causa**: El workflow intenta comentar en el PR pero no tiene permisos suficientes.

**Solucion**:

1. Verifica que habilitaste GitHub Actions en tu fork (ver seccion anterior)
2. Si el error persiste, contacta al evaluador - el workflow del repositorio base puede necesitar ajustes
3. El resultado de tu evaluacion estara disponible en la pestana **Actions** de tu fork aunque el comentario falle

---

## Errores del Validador (Validate-Solution.ps1)

### Error: "CHECK 1: [X] Archivo no encontrado"

**Causa**: Estructura de carpetas incorrecta o nombres de archivo con errores tipográficos.

**Solución**:

```powershell
# 1. Verificar estructura EXACTA:
Solutions\
  [TuNombre]\              # Sin espacios, usa CamelCase (ej: JuanPerez)
    Issue001\              # Exactamente "Issue" + 3 dígitos
      QA_*.sql             # Mayúsculas en QA_ y PROC_
      PROC_*.sql
      SOLUTION.md          # TODO EN MAYÚSCULAS

# 2. Verificar nombres de archivo según issue:
# Issue001 requiere:
#   - QA_ValidarIntegridadEstudiantes.sql
#   - PROC_ValidarIntegridadPreInsert.sql
#   - SOLUTION.md
```

### Error: "CHECK 2: [X] Sintaxis SQL - Error de sintaxis"

**Causa**: El script SQL tiene errores de sintaxis T-SQL.

**⚠️ IMPORTANTE LIMITACIÓN**: El validador usa `SET PARSEONLY` que **solo verifica sintaxis estructural**, NO valida:

- ❌ Nombres de columnas existentes
- ❌ Nombres de tablas existentes
- ❌ Nombres de schemas
- ❌ Referencias a objetos de base de datos

**Ejemplo del problema**:

```sql
-- ❌ ESTE SCRIPT PASA VALIDACIÓN pero FALLA EN RUNTIME:
SELECT id_matricula FROM mat.hechos_matricula;
-- (columna 'id_matricula' no existe, debería ser 'id_hecho_matricula')

-- ✅ CORRECTO:
SELECT id_hecho_matricula FROM mat.hechos_matricula;
```

**Solución**:

```powershell
# 1. Ejecutar MANUALMENTE en SSMS antes de validar:
# - Conectar a BI_Assessment_DWH
# - Copiar/pegar el contenido de tu script
# - Ejecutar (F5)
# - Si falla con "Invalid column name", corregir el nombre

# 2. Verificar nombres de columnas exactos:
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'mat' AND TABLE_NAME = 'hechos_matricula';

# 3. Solo después de probar en SSMS, ejecutar validador:
.\Tools\Validate-Solution.ps1 -Issue "001" -Candidate "TuNombre"
```

### Error: "CHECK 3: [X] Documentación - Menos de X palabras"

**Causa**: SOLUTION.md no cumple el mínimo de palabras requerido.

**Solución**:

```powershell
# 1. Verificar mínimo por issue:
#    Issue001: 150 palabras
#    Issue002: 200 palabras
#    Issue003: 250 palabras
#    (ver Tools\Validate-Solution.ps1 para cada issue)

# 2. Contar palabras en tu archivo:
(Get-Content .\Solutions\TuNombre\Issue001\SOLUTION.md -Raw -split '\s+').Count

# 3. Agregar contenido de calidad:
#    - Explicar causa raíz del problema
#    - Detallar metodología de solución
#    - Documentar casos edge considerados
#    - Agregar recomendaciones de mejora continua
#    - Referencias a documentación SQL Server
```

### Error: "CHECK 4: [X] Query de validación - Resultado: X (esperado: Y)"

**Causa**: La lógica de tu solución no detecta/corrige correctamente los problemas.

**Solución para Issue001**:

```sql
-- El validador ejecuta:
SELECT COUNT(*) AS huerfanos 
FROM [BI_Assessment_DWH].mat.hechos_matricula hm 
LEFT JOIN [BI_Assessment_DWH].cat.dim_estudiantes de 
    ON hm.id_estudiante = de.id_estudiante 
WHERE de.id_estudiante IS NULL;

-- Debe retornar exactamente: 15

-- Si retorna 0: Los FK huérfanos fueron eliminados (ejecutar INSERT_EdgeCases.sql nuevamente)
-- Si retorna >15: Hay más huérfanos de los esperados (verificar integridad de datos)
-- Si retorna <15: Revisar lógica del JOIN
```

---

## Errores de Ejecución SQL

### Error: "Invalid column name 'id_matricula'"

**Causa**: El script usa un nombre de columna que no existe en la tabla.

**Contexto**: Este es el error MÁS COMÚN en Issue001 porque muchos scripts de ejemplo o plantillas usan `id_matricula`, pero la tabla real usa `id_hecho_matricula`.

**Solución**:

```sql
-- ❌ INCORRECTO (nombre genérico que NO existe):
SELECT id_matricula FROM mat.hechos_matricula;

-- ✅ CORRECTO (nombre real de la columna):
SELECT id_hecho_matricula FROM mat.hechos_matricula;

-- Verificar esquema completo:
EXEC sp_help 'mat.hechos_matricula';

-- O consultar columnas:
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'mat' AND TABLE_NAME = 'hechos_matricula'
ORDER BY ORDINAL_POSITION;
```

**Columnas correctas de mat.hechos_matricula**:

- `id_hecho_matricula` (PK - BIGINT IDENTITY)
- `id_estudiante` (FK - BIGINT)
- `id_termino` (FK - BIGINT)
- `id_programa` (FK - BIGINT)
- `id_cohorte` (FK - BIGINT, NULL permitido)
- `codigo_programa` (VARCHAR(20))
- `nombre_programa` (VARCHAR(100))
- `fecha_matricula` (DATE)
- `creditos_inscritos` (DECIMAL(6,2))
- `promedio_ingreso` (DECIMAL(4,2))
- `es_vigente` (BIT)
- `fecha_carga` (DATETIME)

### Error: "Invalid object name 'cat.dim_estudiantes'"

**Causa**: Schema o tabla no existe, o estás ejecutando en la base de datos incorrecta.

**Solución**:

```sql
-- 1. Verificar base de datos activa:
SELECT DB_NAME();

-- 2. Cambiar a base de datos correcta:
USE BI_Assessment_DWH;
GO

-- 3. Verificar que la tabla existe:
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'cat' AND TABLE_NAME = 'dim_estudiantes';

-- 4. Si no existe, ejecutar scripts de setup:
-- (Ver sección "Errores de Conexión a Base de Datos")
```

### Error: "The multi-part identifier 'hm.id_estudiante' could not be bound"

**Causa**: Alias de tabla incorrecto o tabla no incluida en FROM.

**Solución**:

```sql
-- ❌ INCORRECTO (alias 'hm' no definido):
SELECT hm.id_estudiante
FROM mat.hechos_matricula;

-- ✅ CORRECTO:
SELECT hm.id_estudiante
FROM mat.hechos_matricula hm;

-- O sin alias:
SELECT mat.hechos_matricula.id_estudiante
FROM mat.hechos_matricula;
```

---

## Errores Comunes por Issue

### Issue 001: Validación de Integridad

**Problema**: Query retorna 0 huérfanos cuando debería retornar 15

**Solución**:

```powershell
# Re-insertar datos de prueba:
sqlcmd -S SERVERNAME -U usuario -P password -d BI_Assessment_DWH -i .\Database\02_Data\INSERT_EdgeCases.sql

# Verificar inserción:
sqlcmd -S SERVERNAME -U usuario -P password -d BI_Assessment_DWH -Q "SELECT COUNT(*) FROM mat.hechos_matricula WHERE id_estudiante > 99980"
# Debe retornar: 15
```

**Problema**: PROC_ValidarIntegridadPreInsert no previene inserts

**Solución**:

```sql
-- Tu procedure debe incluir RAISERROR con severidad 16:
CREATE PROCEDURE mat.spValidarIntegridadPreInsert
    @id_estudiante INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM cat.dim_estudiantes WHERE id_estudiante = @id_estudiante)
    BEGIN
        RAISERROR('ID estudiante %d no existe', 16, 1, @id_estudiante);
        RETURN 1;
    END
    RETURN 0;
END;
```

---

## 🆘 Soporte Adicional

Si ninguna de estas soluciones resuelve tu problema:

1. **Revisa documentación del issue específico**:
   - `Issues/Issue00X_*/README.md`
   - `Issues/Issue00X_*/HINTS.md`
   - `Issues/Issue00X_*/REQUIREMENTS.md`

2. **Ejecuta el validador en modo debug**:

   ```powershell
   .\Tools\Validate-Solution.ps1 -Issue "001" -Candidate "TuNombre" -Verbose
   ```

3. **Verifica configuración con DryRun**:

   ```powershell
   .\Tools\Validate-Solution.ps1 -Issue "001" -Candidate "TuNombre" -DryRun
   ```

4. **Crea un issue en GitHub**:
   - Incluye: Issue número, error completo, pasos para reproducir
   - Tag: `@ahernandezGH`

---

**Última actualización**: 2026-01-15  
**Mantenido por**: Arquitectura BI - UFT
