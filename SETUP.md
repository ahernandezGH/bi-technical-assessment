# Setup Guide - BI Technical Assessment

**Última actualización**: 2024-12-28  
**Versión**: 1.0

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Instalación por Sistema Operativo](#instalación-por-sistema-operativo)
3. [Configuración de SQL Server](#configuración-de-sql-server)
4. [Setup del Repositorio](#setup-del-repositorio)
5. [Validación del Entorno](#validación-del-entorno)
6. [Troubleshooting](#troubleshooting)

---

## Requisitos Previos

### 🔧 Software Obligatorio

| Software | Versión Mínima | Propósito |
| ---------- | ----------------- | ---------- |
| **SQL Server** | 2019 Express/Developer | Database para assessment |
| **SSMS** | 18.0+ | Editor SQL + management |
| **PowerShell** | 5.1 (Windows) / 7.0+ (otros) | Validators + scripts ETL |
| **Git** | 2.30+ | Control de versiones |
| **Visual Studio Code** | 1.70+ | Editor (opcional pero recomendado) |

### Hardware Mínimo

- **CPU**: 2 cores @ 2.0 GHz
- **RAM**: 4 GB (8 GB recomendado)
- **Disk**: 5 GB libres (3 GB para SQL Server + 2 GB datos)
- **Network**: Conexión a internet (GitHub)

### Verificar Instalaciones Previas

```powershell
# PowerShell version
$PSVersionTable.PSVersion

# SQL Server (si está instalado)
sqlcmd -S localhost -Q "SELECT @@VERSION"

# Git version
git --version

# sqlcmd availability
sqlcmd /?
```

---

## Instalación por Sistema Operativo

### 💻 Windows 10/11

#### 1. SQL Server 2019 Express

**Descarga**:

- [SQL Server 2019 Express Edition](https://www.microsoft.com/en-us/sql-server/sql-server-editions-express)
- Archivo: `SQLServer2019-SSEI-Expr.exe` (~1.5 GB)

**Instalación**:

```powershell
# 1. Ejecutar instalador
.\SQLServer2019-SSEI-Expr.exe

# 2. Seleccionar opciones:
#    - Installation Type: "New SQL Server installation"
#    - Instance Name: MSSQLSERVER (default) o tu nombre
#    - Engine Services: ✓ Database Engine
#    - SQL Server Agent: ✓ (para scheduled jobs)
#    - Database Engine Configuration:
#      - Authentication: "Mixed Mode"
#      - SA Password: Tu password fuerte
#      - Data directory: C:\Program Files\Microsoft SQL Server\...

# 3. Finalizar instalación
```

**Verificar instalación**:

```powershell
# Conectar con Windows Auth (default)
sqlcmd -S localhost

# Output esperado:
# 1>
# (Prompt interactivo)

# Salir
exit
```

#### 2. SQL Server Management Studio (SSMS)

**Descarga**:

- [SSMS 19.0+](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
- Archivo: `SSMS-Setup-ENU.exe` (~500 MB)

**Instalación**:

```powershell
# 1. Ejecutar instalador
.\SSMS-Setup-ENU.exe

# 2. Seguir wizard (opciones default OK)

# 3. Reiniciar (recomendado)
```

**Verificar conexión**:

- Abrir SSMS
- Server name: `localhost` (o `.\MSSQLSERVER` si cambió nombre)
- Authentication: Windows Authentication (default)
- Click "Connect"

#### 3. Git for Windows

**Descarga**:

- [Git for Windows](https://gitforwindows.org/)
- Archivo: `Git-2.xxx-64-bit.exe`

**Instalación**:

```powershell
# 1. Ejecutar instalador
.\Git-2.xxx-64-bit.exe

# 2. Opciones recomendadas:
#    - Use Git from Windows Command Prompt: ✓
#    - Use Windows' default console: ✓
#    - Enable Git Credential Manager: ✓

# 3. Finalizar

# 4. Configurar usuario
git config --global user.name "Tu Nombre"
git config --global user.email "tu.email@ejemplo.com"
```

**Verificar instalación**:

```powershell
git --version
# Output: git version 2.xxx

git config --list
# Output: user.name=Tu Nombre, user.email=...
```

#### 4. Visual Studio Code (Opcional)

**Descarga**:

- [VS Code](https://code.visualstudio.com/download)
- Archivo: `VSCodeUserSetup-x64-1.xxx.exe`

**Extensiones Recomendadas**:

```text
- mssql (Microsoft)
- PowerShell (Microsoft)
- Git Graph
- Markdown All in One
```

### 💻 macOS

#### 1. SQL Server (Docker Alternative)

**Requisito**: Docker Desktop for Mac

```bash
# 1. Instalar Docker Desktop
# Descargar desde https://www.docker.com/products/docker-desktop

# 2. Iniciar Docker Desktop

# 3. Descargar SQL Server 2019 image
docker pull mcr.microsoft.com/mssql/server:2019-latest

# 4. Ejecutar container
docker run -e 'ACCEPT_EULA=Y' \
  -e 'SA_PASSWORD=YourPassword123!' \
  -p 1433:1433 \
  --name mssql2019 \
  -d mcr.microsoft.com/mssql/server:2019-latest

# 5. Verificar que está corriendo
docker ps | grep mssql2019
```

**Conectar desde sqlcmd**:

```bash
sqlcmd -S localhost,1433 -U sa -P 'YourPassword123!'
```

#### 2. Brew Packages

```bash
# Git (si no está instalado)
brew install git

# PowerShell (recomendado para scripts)
brew install powershell

# sqlcmd-go (cliente SQL Server liviano)
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
brew install mssql-tools
```

#### 3. VS Code

```bash
brew install --cask visual-studio-code
```

### 💻 Linux (Ubuntu 20.04+)

#### 1. SQL Server (Docker)

```bash
# 1. Instalar Docker
sudo apt-get update
sudo apt-get install -y docker.io

# 2. Descargar y ejecutar SQL Server
docker run -e 'ACCEPT_EULA=Y' \
  -e 'SA_PASSWORD=YourPassword123!' \
  -p 1433:1433 \
  --name mssql2019 \
  -d mcr.microsoft.com/mssql/server:2019-latest

# 3. Verificar
docker ps | grep mssql2019
```

#### 2. Herramientas CLI

```bash
# sqlcmd via mssql-tools
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | \
  sudo tee /etc/apt/sources.list.d/msprod.list

sudo apt-get update
sudo apt-get install -y mssql-tools

# Git
sudo apt-get install -y git

# PowerShell
sudo apt-get install -y powershell

# VS Code
sudo snap install --classic code
```

---

## Configuración de SQL Server

### 🗄️ 1. Crear Databases

```powershell
# Variables
$ServerName = "localhost"
$SaPassword = "tu_password"  # Reemplazar con tu password

# Script SQL
$sqlScript = @"
-- Crear databases
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SchoolERP_Source')
  CREATE DATABASE SchoolERP_Source;

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'BI_Assessment_Staging')
  CREATE DATABASE BI_Assessment_Staging;

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'BI_Assessment_DWH')
  CREATE DATABASE BI_Assessment_DWH;

-- Verificar
SELECT name, create_date FROM sys.databases 
WHERE name IN ('SchoolERP_Source', 'BI_Assessment_Staging', 'BI_Assessment_DWH')
ORDER BY create_date;
"@

# Ejecutar
sqlcmd -S $ServerName -U sa -P $SaPassword -Q $sqlScript
```

**Output esperado**:

```text
name                          create_date
SchoolERP_Source              2024-12-28 10:30:45.123
BI_Assessment_Staging         2024-12-28 10:30:45.567
BI_Assessment_DWH             2024-12-28 10:30:45.890
```

### 2. Cargar Esquemas

```powershell
# Ejecutar scripts de creación en orden
$SchemaScripts = @(
    "Database\01_Schemas\CREATE_SchoolERP_Source.sql",
    "Database\01_Schemas\CREATE_BI_Assessment_Staging.sql",
    "Database\01_Schemas\CREATE_BI_Assessment_DWH.sql"
)

foreach ($script in $SchemaScripts) {
    Write-Host "Ejecutando: $script"
    sqlcmd -S $ServerName -U sa -P $SaPassword -i $script
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ OK" -ForegroundColor Green
    } else {
        Write-Host "✗ ERROR" -ForegroundColor Red
        exit 1
    }
}
```

### 3. Cargar Datos de Prueba

```powershell
# Ejecutar scripts de datos en orden
$DataScripts = @(
    "Database\02_Data\LOAD_Basic_TestData.sql"
)

foreach ($script in $DataScripts) {
    Write-Host "Cargando: $script"
    sqlcmd -S $ServerName -U sa -P $SaPassword -i $script
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ OK" -ForegroundColor Green
    } else {
        Write-Host "✗ ERROR" -ForegroundColor Red
        exit 1
    }
}
```

### 4. Verificar Integridad

```sql
-- Ejecutar en SSMS o sqlcmd
USE SchoolERP_Source;
SELECT COUNT(*) AS PersonasCount FROM erp.erp_persona;
SELECT COUNT(*) AS MatriculasCount FROM erp.erp_student_curriculum;
SELECT COUNT(*) AS TerminosCount FROM erp.erp_term_catalog;

-- Output esperado:
-- PersonasCount: 20
-- MatriculasCount: 10
-- TerminosCount: 6
```

---

## Setup del Repositorio

### 🎯 1. Fork del Repositorio

**En GitHub**:

```text
1. Ir a https://github.com/ahernandezGH/bi-technical-assessment
2. Click botón "Fork" (esquina superior derecha)
3. Seleccionar "Create a new fork"
4. Mantener opciones default
5. Click "Create fork"
```

**Resultado**: Tu fork en `https://github.com/[TU_USUARIO]/bi-technical-assessment`

### 2. Clonar Fork Localmente

```powershell
# Navegar a carpeta de proyectos
cd C:\Projects  # Cambiar según tu preferencia

# Clonar tu fork
git clone https://github.com/[TU_USUARIO]/bi-technical-assessment.git
cd bi-technical-assessment

# Verificar remotes
git remote -v
# Origin: tu fork
```

### 3. Agregar Upstream (Opcional pero Recomendado)

```powershell
# Agregar remote al repositorio original
git remote add upstream https://github.com/ahernandezGH/bi-technical-assessment.git

# Verificar
git remote -v
# origin: tu fork
# upstream: repositorio original
```

### 4. Configurar Git Localmente

```powershell
# Usuario
git config user.name "Tu Nombre Completo"
git config user.email "tu.email@ejemplo.com"

# Editor default (opcional)
git config core.editor "code"

# Colores
git config color.ui true

# Alias útiles
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
```

---

## Validación del Entorno

### ✅ 1. Ejecutar Test-Environment.ps1

```powershell
# Desde raíz del repositorio
cd C:\Projects\bi-technical-assessment

# Ejecutar validator
.\Tools\Test-Environment.ps1 -ServerName "localhost" -Username "sa" -Password "tu_password"

# Output esperado:
# ============================================================
#   VALIDADOR DE ENTORNO - BI TECHNICAL ASSESSMENT
# ============================================================
# 
# Servidor: localhost
# ...
# 
# ============================================================
#   RESULTADO FINAL
# ============================================================
# 
# ENTORNO LISTO PARA EVALUACION
# 27/27 checks PASS
```

**Si falla algún check**:

1. Revisa el mensaje de error específico
2. Consulta sección [Troubleshooting](#troubleshooting)
3. Intenta corregir y re-ejecutar

### 2. Crear Branch de Prueba

```powershell
# Crear branch local
git checkout -b test-setup

# Crear archivo de prueba
"Test file" | Out-File "test.txt"

# Commit
git add test.txt
git commit -m "test: Verify Git setup"

# Push
git push origin test-setup

# Eliminar branch (limpiar)
git checkout main
git branch -d test-setup
git push origin --delete test-setup
```

### 3. Verificar Acceso a GitHub

```powershell
# Testear conexión SSH (si configuraste)
ssh -T git@github.com
# Output: "Hi [username]! You've successfully authenticated..."

# O testear HTTPS con credentials
git clone https://github.com/[TU_USUARIO]/bi-technical-assessment.git test-clone
Remove-Item test-clone -Recurse
```

---

## Troubleshooting

### Problema: "sqlcmd not recognized" 🔧

**Causa**: sqlcmd no está en PATH

**Soluciones**:

1. **Windows**: Agregar SQL Tools a PATH

   ```powershell
   $env:PATH += ";C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn"
   # Hacer permanente:
   [Environment]::SetEnvironmentVariable("PATH", $env:PATH, "User")
   ```

2. **macOS/Linux**: Usar full path

   ```bash
   /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P password
   ```

### Problema: "SQL Server connection failed"

**Causa más común**: Password incorrecto o SQL Server no corriendo

**Pasos**:

```powershell
# 1. Verificar SQL Server corriendo (Windows)
Get-Service MSSQLSERVER | Select-Object Status

# 2. Si está parado, iniciar
Start-Service MSSQLSERVER

# 3. Verificar password (usar sa)
sqlcmd -S localhost -U sa -P "tu_password_exacto"

# 4. Si no funciona, resetear sa password (Windows):
sqlcmd -S localhost -U sa -Q "ALTER LOGIN [sa] WITH PASSWORD = 'NuevaPassword123!'"
```

### Problema: "PowerShell script execution disabled"

**Causa**: Política de ejecución de scripts

**Solución**:

```powershell
# Ver política actual
Get-ExecutionPolicy

# Cambiar a RemoteSigned (permite scripts locales)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Confirmar
Get-ExecutionPolicy
# Output: RemoteSigned
```

### Problema: "Git credentials keep asking for password"

**Solución 1 - Credential Manager (Windows)**:

```powershell
# Opción A: GitHub Personal Access Token
# 1. Generar token en GitHub (Settings → Developer settings → Personal access tokens)
# 2. Usar token como password cuando se pida

# Opción B: Configurar Credential Helper
git config --global credential.helper wincred
```

**Solución 2 - SSH Keys (todas las plataformas)**:

```bash
# Generar key
ssh-keygen -t ed25519 -C "tu.email@ejemplo.com"

# Agregar a GitHub SSH Keys (Settings → SSH and GPG keys)

# Testear
ssh -T git@github.com
```

### Problema: "Port 1433 already in use (Docker)"

**Causa**: Otro proceso usando puerto SQL Server

**Soluciones**:

```bash
# Opción A: Usar puerto diferente
docker run -e 'ACCEPT_EULA=Y' \
  -e 'SA_PASSWORD=Password!' \
  -p 1434:1433 \  # Usar puerto 1434 localmente
  mcr.microsoft.com/mssql/server:2019-latest

# Conectar: sqlcmd -S localhost,1434

# Opción B: Matar contenedor anterior
docker stop mssql2019
docker rm mssql2019
```

### Problema: "Insufficient disk space"

**Solución**: Liberar espacio o cambiar location de datos

```sql
-- Cambiar location de archivos de datos (en SSMS)
ALTER DATABASE SchoolERP_Source 
MODIFY FILE (
  NAME = SchoolERP_Source,
  FILENAME = 'D:\SQLData\SchoolERP_Source.mdf'  -- Nueva ruta
);

-- Detener DB, mover archivo físicamente, reiniciar
```

### Problema: Validator falla con "Cannot connect to database"

**Checks**:

1. ¿SQL Server está corriendo?

   ```powershell
   sqlcmd -S localhost -U sa -P password -Q "SELECT 1"
   ```

2. ¿Databases existen?

   ```powershell
   sqlcmd -S localhost -U sa -P password -Q "SELECT name FROM sys.databases"
   ```

3. ¿Schemas creados?

   ```powershell
   sqlcmd -S localhost -U sa -P password -d SchoolERP_Source -Q "SELECT name FROM sys.schemas"
   ```

4. ¿Username/Password correctos?
   - Default: `sa` (SQL Auth)
   - O Windows Auth si no configuraste password

---

## � Candidate Submission Workflow (Fork & PR)

This section is for **candidates submitting solutions**, not local developers.

### Step 1: Fork the Repository

1. Go to: https://github.com/ahernandezGH/bi-technical-assessment
2. Click **Fork** (top right)
3. Your fork URL: `https://github.com/YOUR-GITHUB-USERNAME/bi-technical-assessment`

### Step 2: Clone Your Fork Locally

```powershell
# Clone your fork
git clone https://github.com/YOUR-GITHUB-USERNAME/bi-technical-assessment.git
cd bi-technical-assessment

# Configure upstream (to stay synced with original)
git remote add upstream https://github.com/ahernandezGH/bi-technical-assessment.git
git fetch upstream
```

### Step 3: Solve Your Issue Locally

1. Create solution folder:
   ```powershell
   mkdir -p "Solutions\YourName\Issue00X"
   ```

2. Copy required files (see `Issues/` for your issue):
   - SQL queries
   - Documentation (SOLUTION.md)
   - Supporting files

3. **Optional: Validate locally** (if you have SQL Server setup):
   ```powershell
   # Run test suite locally before submitting
   # (Local validation script coming in Phase 6)
   ```

### Step 4: Commit & Push to Your Fork

```powershell
# Commit your solution
git add Solutions/
git commit -m "solution: Issue [00X] - Your description"

# Push to YOUR fork (not the original repo)
git push origin main
```

### Step 5: Create a Pull Request (PR)

1. Go to YOUR fork: `github.com/YOUR-USERNAME/bi-technical-assessment`
2. Click **Pull Requests** → **New Pull Request**
3. **IMPORTANT**: Set base repo to original:
   - Base: `ahernandezGH/bi-technical-assessment` (main)
   - Head: `YOUR-USERNAME/bi-technical-assessment` (main)
4. **PR Title** (EXACT format required):
   ```
   Solution - [YourName] - Issue [00X]
   ```
   Examples:
   - `Solution - [JuanPerez] - Issue [001]`
   - `Solution - [MariaGarcia] - Issue [003]`

5. Click **Create Pull Request**

### Step 6: GitHub Actions Validates Automatically

Your PR will trigger the workflow:

```
┌─────────────────────────────────────────┐
│ GitHub Actions triggers automatically   │
│ (no manual action needed)                │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│ 1. Parse PR Title                       │
│    Extract candidate name & issue       │
│    Validate regex format                │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│ 2. Validate Solution                    │
│    - Check SOLUTION.md exists           │
│    - Count words (min 50)               │
│    - Check required SQL files           │
│    - Assign score (0–100)               │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│ 3. Post Auto-Comment with Results:      │
│    ✅ PASS (Score: 75/100)              │
│    or                                   │
│    ❌ FAIL (Score: 45/100)              │
│                                         │
│    "Congratulations! You are eligible   │
│     for Phase 2 (Technical Interview)"  │
│    or                                   │
│    "Please review feedback and resubmit │
│     (1 retry allowed)"                  │
└─────────────────────────────────────────┘
```

### Step 7: How the Evaluator Sees Results

**Evaluator's view:**

1. Logs into GitHub: https://github.com/ahernandezGH/bi-technical-assessment/pulls
2. Clicks on candidate's PR
3. Scrolls to **github-actions[bot] comment** with:
   - Score (X/100)
   - Status (PASS/FAIL)
   - Full validation output
   - Feedback message

4. If **PASS (≥70 points)**:
   - Candidate is eligible for Phase 2 (Technical Interview)
   - Evaluator schedules interview

5. If **FAIL (<70 points)**:
   - Candidate can resubmit once (1 retry allowed)
   - Evaluator waits for new PR

### Quick Reference: PR Title Format

| Valid ✅ | Invalid ❌ |
|----------|-----------|
| `Solution - [JuanPerez] - Issue [001]` | `Solution - JuanPerez - Issue [001]` (missing brackets) |
| `Solution - [Maria] - Issue [003]` | `Solution - Maria - Issue 003` (no issue brackets) |
| `Solution - [Alex123] - Issue [007]` | `Solution - [Alex123] - Issue 7` (00X format required) |

---

## �📞 Soporte

Si encuentras problemas durante setup:

1. **Consulta FAQ**: Busca tu error en sección Troubleshooting
2. **GitHub Issues**: [Crear issue en repositorio](https://github.com/ahernandezGH/bi-technical-assessment/issues)
3. **Email**: <alvaro.hernandez@uft.cl>

---

## ✓ Checklist de Verificación

Antes de empezar a resolver issues, asegúrate de:

- [ ] SQL Server 2019+ instalado y corriendo
- [ ] SSMS instalado (opcional pero recomendado)
- [ ] Git configurado (user.name, user.email)
- [ ] Repositorio clonado localmente
- [ ] 3 databases creados (Source, Staging, DWH)
- [ ] Schemas cargados sin errores
- [ ] Test data cargado (20 personas, etc.)
- [ ] `Test-Environment.ps1` retorna 27/27 PASS
- [ ] PowerShell execution policy permite scripts locales
- [ ] SSH keys o GitHub token configurado

Si todos los items tienen ✓, **estás listo para comenzar!** 🚀

---

**Última actualización**: 2024-12-28  
**Versión**: 1.0
