# Comparacion de Consultas: TypeORM vs SQL Nativo de PostgreSQL

Este documento presenta la comparativa tecnica entre las consultas ejecutadas con TypeORM (TypeScript) y las sentencias SQL nativas ejecutadas directamente en el motor PostgreSQL 18 para la Fase 2 de Hospitales de Occidente.

---

## 1. Objetivo 01: Top 3 Hospitales con Mayor Demanda en Consulta Externa

### A. Codigo TypeScript (TypeORM QueryBuilder)
```typescript
const qb = dataSource
  .getRepository(Hospital)
  .createQueryBuilder('h')
  .innerJoin('clinica', 'cl', 'cl.id_hospital = h.id_hospital')
  .leftJoin(
    'cita',
    'ci',
    'ci.id_clinica = cl.id_clinica AND ci.fecha_hora BETWEEN :fechaInicio AND :fechaFin',
    { fechaInicio, fechaFin }
  )
  .leftJoin('consulta', 'co', 'co.id_cita = ci.id_cita')
  .leftJoin('receta', 're', 're.id_consulta = co.id_consulta')
  .where('h.es_interno = :esInterno', { esInterno: true })
  .groupBy('h.id_hospital')
  .addGroupBy('h.nombre')
  .select('h.nombre', 'hospital')
  .addSelect("COUNT(DISTINCT ci.id_cita) FILTER (WHERE ci.estado <> 'Cancelada')", 'reservaciones')
  .addSelect('COUNT(DISTINCT co.id_consulta)', 'consultas')
  .addSelect('COUNT(DISTINCT re.id_receta) FILTER (WHERE re.id_cita_proxima IS NOT NULL)', 'proximas_consultas')
  .addSelect(
    "(COUNT(DISTINCT ci.id_cita) FILTER (WHERE ci.estado <> 'Cancelada') + COUNT(DISTINCT co.id_consulta) + COUNT(DISTINCT re.id_receta) FILTER (WHERE re.id_cita_proxima IS NOT NULL))",
    'demanda_total'
  )
  .orderBy('demanda_total', 'DESC')
  .limit(3);
```

### B. Tabla Comparativa Lado a Lado
| Aspecto | SQL Generado por TypeORM (Log Oficial) | SQL Equivalente Nativo (PostgreSQL) |
| :--- | :--- | :--- |
| **Sentencia SQL** | `SELECT "h"."nombre" AS "hospital", COUNT(DISTINCT "ci"."id_cita") FILTER (WHERE "ci"."estado" <> 'Cancelada') AS "reservaciones", COUNT(DISTINCT "co"."id_consulta") AS "consultas", COUNT(DISTINCT "re"."id_receta") FILTER (WHERE "re"."id_cita_proxima" IS NOT NULL) AS "proximas_consultas", (COUNT(DISTINCT "ci"."id_cita") FILTER (WHERE "ci"."estado" <> 'Cancelada') + COUNT(DISTINCT "co"."id_consulta") + COUNT(DISTINCT "re"."id_receta") FILTER (WHERE "re"."id_cita_proxima" IS NOT NULL)) AS "demanda_total" FROM "hospitales_occidente"."hospital" "h" INNER JOIN "hospitales_occidente"."clinica" "cl" ON "cl"."id_hospital" = "h"."id_hospital" LEFT JOIN "hospitales_occidente"."cita" "ci" ON "ci"."id_clinica" = "cl"."id_clinica" AND "ci"."fecha_hora" BETWEEN $1 AND $2 LEFT JOIN "hospitales_occidente"."consulta" "co" ON "co"."id_cita" = "ci"."id_cita" LEFT JOIN "hospitales_occidente"."receta" "re" ON "re"."id_consulta" = "co"."id_consulta" WHERE "h"."es_interno" = $3 GROUP BY "h"."id_hospital", "h"."nombre" ORDER BY demanda_total DESC LIMIT 3` | `WITH demanda AS (SELECT h.id_hospital, h.nombre AS hospital, COUNT(DISTINCT ci.id_cita) FILTER (WHERE ci.estado <> 'Cancelada') AS reservaciones, COUNT(DISTINCT co.id_consulta) AS consultas, COUNT(DISTINCT re.id_receta) FILTER (WHERE re.id_cita_proxima IS NOT NULL) AS proximas_consultas FROM hospital h JOIN clinica cl ON cl.id_hospital = h.id_hospital LEFT JOIN cita ci ON ci.id_clinica = cl.id_clinica AND ci.fecha_hora BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06' LEFT JOIN consulta co ON co.id_cita = ci.id_cita LEFT JOIN receta re ON re.id_consulta = co.id_consulta WHERE h.es_interno = True GROUP BY h.id_hospital, h.nombre) SELECT hospital, reservaciones, consultas, proximas_consultas, (reservaciones + consultas + proximas_consultas) AS demanda_total FROM demanda ORDER BY demanda_total DESC LIMIT 3;` |
| **Parametros** | `-- PARAMETERS: ["2026-01-01 00:00:00-06","2026-12-31 23:59:59-06",true]` | Valores literales incrustados en la sesion interactiva |
| **Identificadores** | TypeORM califica tablas y columnas con esquema y comillas dobles (`"hospitales_occidente"."hospital" "h"`). | Usa el `search_path` de sesion sin comillas obligatorias. |
| **Seguridad** | Parametros separados via protocolo de PostgreSQL ($1, $2, $3). Cero riesgo de inyeccion SQL. | Requiere atencion al construir strings en backend. |

### C. Log Oficial Capturado
```text
query: SELECT "h"."nombre" AS "hospital", COUNT(DISTINCT "ci"."id_cita") FILTER (WHERE "ci"."estado" <> 'Cancelada') AS "reservaciones", COUNT(DISTINCT "co"."id_consulta") AS "consultas", COUNT(DISTINCT "re"."id_receta") FILTER (WHERE "re"."id_cita_proxima" IS NOT NULL) AS "proximas_consultas", (COUNT(DISTINCT "ci"."id_cita") FILTER (WHERE "ci"."estado" <> 'Cancelada') + COUNT(DISTINCT "co"."id_consulta") + COUNT(DISTINCT "re"."id_receta") FILTER (WHERE "re"."id_cita_proxima" IS NOT NULL)) AS "demanda_total" FROM "hospitales_occidente"."hospital" "h" INNER JOIN "hospitales_occidente"."clinica" "cl" ON "cl"."id_hospital" = "h"."id_hospital"  LEFT JOIN "hospitales_occidente"."cita" "ci" ON "ci"."id_clinica" = "cl"."id_clinica" AND "ci"."fecha_hora" BETWEEN $1 AND $2  LEFT JOIN "hospitales_occidente"."consulta" "co" ON "co"."id_cita" = "ci"."id_cita"  LEFT JOIN "hospitales_occidente"."receta" "re" ON "re"."id_consulta" = "co"."id_consulta" WHERE "h"."es_interno" = $3 GROUP BY "h"."id_hospital", "h"."nombre" ORDER BY demanda_total DESC LIMIT 3 -- PARAMETERS: ["2026-01-01 00:00:00-06","2026-12-31 23:59:59-06",true]
```

---

## 2. Objetivo 16: Cadena de Supervision Medica Recursiva (Jerarquia)

### A. Codigo TypeScript (DataSource con Prepared Statement)
```typescript
const sql = `
  WITH RECURSIVE cadena_supervision AS (
      SELECT 
          m.id_personal AS id_medico,
          p.nombres || ' ' || p.apellidos AS nombre_medico,
          m.nivel_acceso,
          m.id_superior,
          psup.nombres || ' ' || psup.apellidos AS nombre_superior,
          1 AS nivel_jerarquico
      FROM hospitales_occidente.medico m
      JOIN hospitales_occidente.persona p ON p.id_persona = m.id_personal
      LEFT JOIN hospitales_occidente.persona psup ON psup.id_persona = m.id_superior
      WHERE m.id_personal = $1

      UNION ALL

      SELECT 
          sup.id_personal AS id_medico,
          psup.nombres || ' ' || psup.apellidos AS nombre_medico,
          sup.nivel_acceso,
          sup.id_superior,
          p_next.nombres || ' ' || p_next.apellidos AS nombre_superior,
          cs.nivel_jerarquico + 1 AS nivel_jerarquico
      FROM hospitales_occidente.medico sup
      JOIN hospitales_occidente.persona psup ON psup.id_persona = sup.id_personal
      LEFT JOIN hospitales_occidente.persona p_next ON p_next.id_persona = sup.id_superior
      JOIN cadena_supervision cs ON cs.id_superior = sup.id_personal
  )
  SELECT nivel_jerarquico, id_medico, nombre_medico, nivel_acceso, id_superior, nombre_superior
  FROM cadena_supervision
  ORDER BY nivel_jerarquico ASC;
`;
return await dataSource.query(sql, [idMedico]);
```

### B. Tabla Comparativa Lado a Lado
| Aspecto | Implementacion TypeORM | SQL Equivalente Nativo (PostgreSQL) |
| :--- | :--- | :--- |
| **Sentencia SQL** | CTE recursiva ejecutada con `dataSource.query()` y marcador posicional `$1`. | Idem ejecutada via psql. |
| **Parametros** | `-- PARAMETERS: [7]` (entregado como parametro seguro al driver `pg`). | Valor constante `7` en la clausula WHERE. |
| **Estructura de Retorno** | Array de objetos JSON con tipado inferido de PostgreSQL. | Tabla de tuplas en terminal psql. |
| **Seguridad** | Parametro tipado en backend, previene manipulacion maliciosa del arbol. | Depende del metodo de envio desde el cliente. |

### C. Log Oficial Capturado
```text
query: 
    WITH RECURSIVE cadena_supervision AS (
        SELECT 
            m.id_personal AS id_medico,
            p.nombres || ' ' || p.apellidos AS nombre_medico,
            m.nivel_acceso,
            m.id_superior,
            psup.nombres || ' ' || psup.apellidos AS nombre_superior,
            1 AS nivel_jerarquico
        FROM hospitales_occidente.medico m
        JOIN hospitales_occidente.persona p ON p.id_persona = m.id_personal
        LEFT JOIN hospitales_occidente.persona psup ON psup.id_persona = m.id_superior
        WHERE m.id_personal = $1

        UNION ALL

        SELECT 
            sup.id_personal AS id_medico,
            psup.nombres || ' ' || psup.apellidos AS nombre_medico,
            sup.nivel_acceso,
            sup.id_superior,
            p_next.nombres || ' ' || p_next.apellidos AS nombre_superior,
            cs.nivel_jerarquico + 1 AS nivel_jerarquico
        FROM hospitales_occidente.medico sup
        JOIN hospitales_occidente.persona psup ON psup.id_persona = sup.id_personal
        LEFT JOIN hospitales_occidente.persona p_next ON p_next.id_persona = sup.id_superior
        JOIN cadena_supervision cs ON cs.id_superior = sup.id_personal
    )
    SELECT 
        nivel_jerarquico,
        id_medico,
        nombre_medico,
        nivel_acceso,
        id_superior,
        nombre_superior
    FROM cadena_supervision
    ORDER BY nivel_jerarquico ASC;
   -- PARAMETERS: [7]
```

---

## 3. Objetivo 18: Division Relacional - Pacientes Fieles (4 Unidades)

### A. Codigo TypeScript (Division Relacional Parametrizada)
```typescript
const sql = `
  WITH atenciones AS (
      SELECT ep.id_paciente, tu.id_tipo_unidad, tu.nombre AS nombre_unidad, ing.fecha_hora_ingreso AS fecha_atencion
      FROM hospitales_occidente.ingreso ing
      JOIN hospitales_occidente.episodio ep ON ep.id_episodio = ing.id_episodio
      JOIN hospitales_occidente.unidad_hospital uh ON uh.id_unidad_hospital = ing.id_unidad_hospital
      JOIN hospitales_occidente.tipo_unidad tu ON tu.id_tipo_unidad = uh.id_tipo_unidad
      WHERE ing.fecha_hora_ingreso BETWEEN $1 AND $2
      
      UNION
      
      SELECT ci.id_paciente, 1 AS id_tipo_unidad, 'Consulta externa' AS nombre_unidad, con.fecha_hora AS fecha_atencion
      FROM hospitales_occidente.consulta con
      JOIN hospitales_occidente.cita ci ON ci.id_cita = con.id_cita
      WHERE con.fecha_hora BETWEEN $1 AND $2
      
      UNION
      
      SELECT ep.id_paciente, 3 AS id_tipo_unidad, 'Cirugia' AS nombre_unidad, c.inicio_programado AS fecha_atencion
      FROM hospitales_occidente.cirugia c
      JOIN hospitales_occidente.solicitud_cirugia sc ON sc.id_solicitud_cirugia = c.id_solicitud_cirugia
      JOIN hospitales_occidente.episodio ep ON ep.id_episodio = sc.id_episodio
      WHERE c.inicio_programado BETWEEN $1 AND $2
  )
  SELECT 
      p.id_paciente,
      per.nombres || ' ' || per.apellidos AS nombre_paciente,
      per.dpi,
      COUNT(DISTINCT a.nombre_unidad) AS total_unidades_atendidas
  FROM hospitales_occidente.paciente p
  JOIN hospitales_occidente.persona per ON per.id_persona = p.id_persona
  JOIN atenciones a ON a.id_paciente = p.id_paciente
  GROUP BY p.id_paciente, per.nombres, per.apellidos, per.dpi
  HAVING COUNT(DISTINCT a.nombre_unidad) = (
      SELECT COUNT(*) 
      FROM hospitales_occidente.tipo_unidad 
      WHERE nombre IN ('Consulta externa', 'Emergencias', 'Cirugia', 'Hospitalizacion')
  )
  ORDER BY p.id_paciente ASC;
`;
return await dataSource.query(sql, [fechaInicio, fechaFin]);
```

### B. Tabla Comparativa Lado a Lado
| Aspecto | Implementacion TypeORM | SQL Equivalente Nativo (PostgreSQL) |
| :--- | :--- | :--- |
| **Sentencia SQL** | Division relacional formal con union de atenciones y agregacion relacional. | Idem ejecutada via psql. |
| **Parametros** | `-- PARAMETERS: ["2026-01-01 00:00:00-06","2026-12-31 23:59:59-06"]` | Rango temporal incrustado en script SQL. |
| **Resultado** | Exactamente los 3 pacientes fieles (ID 1, 2, 9). | Mismo conjunto de resultados de 3 pacientes. |
| **Seguridad** | Enlace estricto de parametros `$1` y `$2`, previniendo inyeccion en los filtros temporales. | Requiere atencion al sanitizar variables externas. |

### C. Log Oficial Capturado
```text
query: 
    WITH atenciones AS (
        SELECT 
            ep.id_paciente,
            tu.id_tipo_unidad,
            tu.nombre AS nombre_unidad,
            ing.fecha_hora_ingreso AS fecha_atencion
        FROM hospitales_occidente.ingreso ing
        JOIN hospitales_occidente.episodio ep ON ep.id_episodio = ing.id_episodio
        JOIN hospitales_occidente.unidad_hospital uh ON uh.id_unidad_hospital = ing.id_unidad_hospital
        JOIN hospitales_occidente.tipo_unidad tu ON tu.id_tipo_unidad = uh.id_tipo_unidad
        WHERE ing.fecha_hora_ingreso BETWEEN $1 AND $2
        
        UNION
        
        SELECT 
            ci.id_paciente,
            1 AS id_tipo_unidad,
            'Consulta externa' AS nombre_unidad,
            con.fecha_hora AS fecha_atencion
        FROM hospitales_occidente.consulta con
        JOIN hospitales_occidente.cita ci ON ci.id_cita = con.id_cita
        WHERE con.fecha_hora BETWEEN $1 AND $2
        
        UNION
        
        SELECT 
            ep.id_paciente,
            3 AS id_tipo_unidad,
            'Cirugia' AS nombre_unidad,
            c.inicio_programado AS fecha_atencion
        FROM hospitales_occidente.cirugia c
        JOIN hospitales_occidente.solicitud_cirugia sc ON sc.id_solicitud_cirugia = c.id_solicitud_cirugia
        JOIN hospitales_occidente.episodio ep ON ep.id_episodio = sc.id_episodio
        WHERE c.inicio_programado BETWEEN $1 AND $2
    )
    SELECT 
        p.id_paciente,
        per.nombres || ' ' || per.apellidos AS nombre_paciente,
        per.dpi,
        COUNT(DISTINCT a.nombre_unidad) AS total_unidades_atendidas
    FROM hospitales_occidente.paciente p
    JOIN hospitales_occidente.persona per ON per.id_persona = p.id_persona
    JOIN atenciones a ON a.id_paciente = p.id_paciente
    GROUP BY p.id_paciente, per.nombres, per.apellidos, per.dpi
    HAVING COUNT(DISTINCT a.nombre_unidad) = (
        SELECT COUNT(*) 
        FROM hospitales_occidente.tipo_unidad 
        WHERE nombre IN ('Consulta externa', 'Emergencias', 'Cirugia', 'Hospitalizacion')
    )
    ORDER BY p.id_paciente ASC;
   -- PARAMETERS: ["2026-01-01 00:00:00-06","2026-12-31 23:59:59-06"]
```

---

## 4. Evaluacion de Seguridad y Arquitectura

1. **Prevencion Total de Inyeccion SQL (Zero SQLi):**
   Tanto en el QueryBuilder como en las consultas complejas parametrizadas, los valores de usuario no se concatenan a la cadena SQL. TypeORM envia la consulta preparada y los parametros en mensajes separados al protocolo binario del motor PostgreSQL.
2. **Rol de Base de Datos Restringido:**
   La conexion utiliza exclusivamente el usuario `usr_auditor_occidente` (`rol_auditor_consulta`), garantizando privilegios de solo lectura (`SELECT`) sin permisos de escritura ni modificacion estructural DDL.
3. **Equivalencia Funcional:**
   Los resultados producidos por la capa ORM en Node.js coinciden tupla por tupla con las consultas ejecutadas directamente en `psql`.
