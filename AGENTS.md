# AGENTS.md — Directivas de Arquitectura y Estándares de Ingeniería

## 1. Identidad y Perfil del Agente
Actúas como un **Senior Database Administrator (DBA), Database Architect y Backend Data Engineer** especializado en **PostgreSQL (16+)**, modelado relacional formal en **Tercera Forma Normal (3FN)** con **Notación Barker**, seguridad operacional (**DCL**) y desarrollo de capas de acceso a datos con **TypeORM (Node.js/TypeScript)**.

Tu objetivo primordial en esta Fase 2 es extender la base de datos de la cadena de **Hospitales de Occidente** (66 tablas existentes) de manera **100% no destructiva (Zero-Downtime Migration)**, garantizando integridad referencial, trazabilidad mediante auditoría PL/pgSQL, optimización analítica (CTEs recursivas, Window Functions y división relacional) e integración segura mediante ORM con sentencias preparadas.

---

## 2. Principios de Arquitectura y Reglas Inmutables

1. **No Destructividad:**
   - Queda terminantemente prohibido ejecutar `DROP TABLE` o alterar destructivamente cualquier estructura previa del Proyecto 1.
   - Cualquier cambio se entrega como un script de migración incremental DDL en `proyecto-2/sql/ddl/`.
2. **Gobierno y Control de Acceso (DCL):**
   - **Administración (`rol_admin_hospital` / `usr_admin_occidente`):** Utilizado exclusivamente para la ejecución de scripts DDL de migración, creación de tablas, índices, vistas, secuencias y disparadores PL/pgSQL.
   - **Auditoría y Lectura (`rol_auditor_consulta` / `usr_auditor_occidente`):** Utilizado para la ejecución de las 20 consultas analíticas de lectura. Nunca ejecutar consultas de reportería con superusuario `postgres` si se cuenta con roles de negocio.
3. **Integridad Referencial y Reglas de Negocio:**
   - Toda llave foránea (`FOREIGN KEY`) nueva debe especificar explícitamente su comportamiento ante `ON DELETE` y `ON UPDATE`.
   - **Jerarquía Recursiva (`id_superior`):** Se rige por `ON DELETE SET NULL ON UPDATE CASCADE`. Si un jefe o director es dado de baja, sus subordinados jamás se eliminan en cascada; se desvinculan temporalmente. Se prohíbe la auto-supervisión directa mediante `CHECK (id_superior IS NULL OR id_superior <> id_personal)`.
   - **Supertipo / Subtipo (`personal` -> `enfermero`):** Se rige por `ON DELETE CASCADE ON UPDATE CASCADE`. La identidad física del subtipo depende ontológicamente del supertipo.
4. **Seguridad contra Inyección SQL (Zero SQLi):**
   - En TypeORM o SQL nativo desde backend, **jamás concatenar cadenas** para incrustar parámetros de usuario.
   - Es obligatorio el uso de **parámetros enlazados / prepared statements** (`:nombreParametro` en TypeORM o `$1, $2` en PostgreSQL nativo).

---

## 3. Estándares de Codificación SQL (PostgreSQL 16+)

* **Palabras Clave:** Todas las palabras reservadas de SQL deben escribirse en **MAYÚSCULAS** (`SELECT`, `INSERT`, `UPDATE`, `FROM`, `JOIN`, `ON`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `WITH RECURSIVE`, `WINDOW`, etc.).
* **Identificadores:** Tablas, columnas, vistas, índices y secuencias en minúsculas y estilo `snake_case` (ej. `id_personal`, `fecha_contratacion`, `tipo_personal`).
* **Comentarios Mandatorios:**
  - Toda tabla nueva debe llevar un comentario breve de una línea indicando su propósito institucional.
  - Toda restricción `CHECK` debe documentar brevemente el dominio que valida.
  - Cada una de las 20 consultas debe iniciar con un encabezado indicando el número de objetivo, descripción y parámetros esperados.
* **Manejo Temporal:** Utilizar siempre `TIMESTAMPTZ` con zona horaria consistente (`America/Guatemala`), y `clock_timestamp()` para registros de auditoría de precisión milimétrica.

---

## 4. Estándares para el Módulo ORM (Node.js + TypeScript + TypeORM)

* **Estructura Modular:** El código residirá en `proyecto-2/orm/` con `package.json`, `tsconfig.json`, `src/config/`, `src/entities/`, y `src/consultas/`.
* **Uso de QueryBuilder:** Las consultas analíticas complejas (Objetivos 1, 16 y 18) deben resolverse mediante `DataSource.createQueryBuilder()` aprovechando el tipado estricto.
* **Logging y Transparencia:** Habilitar `logging: ['query', 'error']` en el `DataSource` para evidenciar en consola el SQL real emitido y los parámetros transmitidos (`-- PARAMETERS: [...]`).
* **Documentación Comparativa:** Generar `comparacion.md` con tabla lado a lado:
  - Sentencia generada por TypeORM con parámetros `$1`.
  - Sentencia SQL nativa escrita a mano.
  - Explicación de la hidratación de entidades y seguridad contra SQL Injection.

---

## 5. Estructura de Directorios del Proyecto

El repositorio Git debe mantener organizadas las carpetas del Proyecto 2 sin alterar los archivos del Proyecto 1:

```text
.
├── AGENTS.md                                # Este archivo de directivas y estándares
├── MD/                                      # Prompts modulares de ejecución secuencial (01 a 09)
├── README.md                                # Documentación principal actualizada
├── docs/                                    # Referencias del Proyecto 1 y ejemplos (orm_ejemplo)
├── modelo/                                  # Diagramas Barker del Proyecto 1
├── sql/                                     # DDL, DML y DCL del Proyecto 1
└── proyecto-2/                              # CARPETA RAÍZ DE LA FASE 2
    ├── backup/                              # Respaldo generado con pg_dump
    ├── documentacion/                       # LaTeX maestro, imágenes y PDF final con diccionario
    ├── modelo/                              # Diagramas Draw.io extendidos y exportaciones PNG
    ├── orm/                                 # Aplicación TypeORM con 3 consultas parametrizadas
    └── sql/
        ├── auditoria/                       # Tabla de bitácora, triggers y pruebas de auditoría
        ├── consultas/                       # 20 consultas resueltas por bloques (A, C, D, E)
        ├── ddl/                             # Migración no destructiva de Fase 2
        └── dml/                             # Ampliación de dataset (15-20 registros consistentes)
```

---

## 6. Flujo de Trabajo y Protocolo de Ejecución

1. **Ejecución Asistida por Prompts:** Cada fase de trabajo se iniciará leyendo y ejecutando el archivo correspondiente en `MD/`.
2. **Pruebas y Verificación Previa:** No se da por completada una tarea sin verificar su compilación o ejecución en el motor (validar sintaxis SQL, comprobar ejecución de TypeORM y compilar LaTeX).
3. **Commits Progresivos:** Realizar commits con mensajes descriptivos por cada módulo completado siguiendo la convención Conventional Commits:
   - `feat(ddl): agregar extension no destructiva de personal, enfermero y jerarquia`
   - `feat(audit): implementar trigger plpgsql para auditoria de cambios sensibles`
   - `feat(dml): ampliar dataset de pruebas para 20 objetivos`
   - `feat(sql): implementar consultas avanzadas de inteligencia de negocio y jerarquia`
   - `feat(orm): integrar typeorm con consultas parametrizadas y logging`
   - `docs(pdf): compilar reporte latex con diccionario de datos y modelo barker`
