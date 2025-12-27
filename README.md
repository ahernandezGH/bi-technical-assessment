# 🎯 BI Technical Assessment Repository

**Propósito:** Repositorio de evaluación técnica para candidatos a posiciones de Ingeniero BI, con énfasis en modelado dimensional, T-SQL avanzado y extracción de datos ERP.

---

## 📚 Estructura del Repositorio

```
bi-technical-assessment/
├── README.md                    ← Este archivo
├── SETUP.md                     ← Instrucciones de instalación (próximamente)
├── .github/workflows/           ← CI/CD (próximamente)
├── Database/                    ← Scripts SQL y datos
│   ├── 01_Schema/              ← CREATE scripts
│   ├── 02_Data/                ← LOAD scripts y generadores
│   ├── 03_Baseline/            ← Backup .bak
│   └── 04_Solutions/           ← Soluciones modelo (privado)
├── Issues/                      ← 7 retos técnicos
│   ├── Issue001/               ← Validación integridad
│   ├── Issue002/               ← Optimización performance
│   ├── Issue003/               ← Refactorización ETL
│   ├── Issue004/               ← Diseño dimensional
│   ├── Issue005/               ← Extracción ERP histórica
│   ├── Issue006/               ← Fact table grain
│   └── Issue007/               ← Navegación multi-tabla
├── Standards/                   ← Estándares simplificados
├── Tools/                       ← Scripts de validación
└── Model/                       ← Proyecto tabular (opcional)
```

---

## 🚀 Quick Start

### Prerrequisitos

- SQL Server 2019+ (Express/Developer/LocalDB)
- SSMS 18+
- PowerShell 5.1+
- Git 2.30+

### Instalación

```bash
# 1. Fork este repositorio
# 2. Clone tu fork
git clone https://github.com/TU-USUARIO/bi-technical-assessment.git
cd bi-technical-assessment

# 3. Restaurar base de datos (próximamente)
# Ver SETUP.md para instrucciones detalladas
```

---

## 📋 Catálogo de Issues

| Issue | Nivel | Tiempo | Habilidad Principal |
|-------|-------|--------|---------------------|
| **001** | ⭐⭐☆☆☆ Básico | 2-4h | Validación integridad datos |
| **002** | ⭐⭐⭐☆☆ Medio | 4-6h | Optimización performance SQL |
| **003** | ⭐⭐⭐⭐☆ Alto | 6-8h | Arquitectura ETL modular |
| **004** | ⭐⭐⭐☆☆ Medio | 4-6h | Modelado dimensional (SCD) |
| **005** | ⭐⭐⭐☆☆ Medio | 3-5h | Extracción ERP con precedencia |
| **006** | ⭐⭐⭐⭐☆ Alto | 5-7h | Fact table grain design |
| **007** | ⭐⭐⭐⭐☆ Alto | 4-5h | Navegación multi-tabla ERP |

---

## 📈 Proceso de Evaluación

### FASE 1: Take-Home (7 días)

1. **Selecciona 1 issue** del catálogo según tu nivel
2. **Desarrolla la solución** en tu fork
3. **Sube tu branch**: `solution-[tunombre]-issue00X`
4. **Crea Pull Request** con título: `Solution - [Tu Nombre] - Issue 00X`
5. **Validación automática** ejecuta y te da score 0-100

**Criterio:** Score ≥ 70 → Avanza a Fase 2

### FASE 2: Entrevista Técnica (2-3 horas)

- **Parte A:** Revisión de tu solución (60 min)
- **Parte B:** Issue en vivo (60 min)
- **Parte C:** Caso de producción (30 min)

---

## 🛠️ Estado del Proyecto

🚧 **EN DESARROLLO** 🚧

### ✅ Completado

- [x] Estructura de carpetas
- [x] .gitignore configurado
- [x] README inicial

### 🔄 En Progreso

- [ ] Scripts de creación de esquemas (Fase 1)
- [ ] Generador de datos sintéticos (Fase 1)
- [ ] Documentación de issues (Fase 2)
- [ ] Scripts de validación (Fase 3)
- [ ] Workflow CI/CD (Fase 4)
- [ ] SETUP.md detallado (Fase 5)

---

## 📞 Contacto

Para consultas sobre el proceso de evaluación:
- Email: bi-team@example.com
- Issues: Usar el sistema de Issues de GitHub

---

## 📄 Licencia

Este repositorio es material de evaluación técnica. Uso restringido.

**Última actualización:** Diciembre 2025
