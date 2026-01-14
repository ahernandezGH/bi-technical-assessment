# Issue001 - Modelado Dimensional de Entidad Persona

## Contexto
Este issue requiere implementar una dimension de personas siguiendo los estandares de modelado dimensional de UFT Academic.

## Solucion Propuesta

### 1. Estructura de la Tabla
Se crea la tabla `dim_personas` con las siguientes caracteristicas:

- **Surrogate Key (SK)**: `id_persona` como BIGINT IDENTITY(1,1)
- **Natural Key (NK)**: `codigo_persona` como identificador de negocio
- **Atributos dimensionales**: nombre completo, correo, fecha nacimiento
- **Metadatos de auditoria**: fecha insercion, fecha modificacion

### 2. Patron de Tipo 1 (Sobrescritura)
Esta dimension implementa el patron Slowly Changing Dimension (SCD) Tipo 1, donde:
- Los cambios sobrescriben los valores existentes
- Se mantiene registro de ultima modificacion via `fecha_modificacion`
- No se mantiene historico de cambios

### 3. Consideraciones de Diseno

**Claves:**
- Primary Key en surrogate key para eficiencia
- Unique constraint en natural key para integridad referencial
- Clustered index en SK para optimizar joins con tablas de hechos

**Indices:**
- Clustered en `id_persona` (PK)
- Non-clustered unico en `codigo_persona` (NK)

**Constraints:**
- NOT NULL en campos criticos (SK, NK, nombres)
- Valores NULL permitidos en campos opcionales (correo, fecha nacimiento)

### 4. Integracion con Arquitectura UFT
Esta dimension sigue los estandares del proyecto:
- Nomenclatura coherente con convenciones UFT_FIN_DWH
- Auditoria mediante campos fecha_insercion y fecha_modificacion
- Uso de BIGINT para SKs (escala para volumenes grandes)

## Archivos Entregados
- `CREATE_table.sql`: Script DDL con la definicion completa de la tabla
