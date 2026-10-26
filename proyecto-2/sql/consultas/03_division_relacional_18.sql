SET search_path TO hospitales_occidente, public;
SET timezone TO 'America/Guatemala';


-- OBJETIVO 18: Division relacional - Pacientes fieles
-- Pacientes con atencion en todas las unidades medicas oficiales:
-- 'Consulta externa', 'Emergencias', 'Cirugia', 'Hospitalizacion'
-- Parametros: lapso de tiempo ('2026-01-01' a '2026-12-31')



-- Enfoque 1: Agregacion relacional con conteo exacto

WITH atenciones AS (
    SELECT 
        ep.id_paciente,
        tu.id_tipo_unidad,
        tu.nombre AS nombre_unidad,
        ing.fecha_hora_ingreso AS fecha_atencion
    FROM ingreso ing
    JOIN episodio ep ON ep.id_episodio = ing.id_episodio
    JOIN unidad_hospital uh ON uh.id_unidad_hospital = ing.id_unidad_hospital
    JOIN tipo_unidad tu ON tu.id_tipo_unidad = uh.id_tipo_unidad
    WHERE ing.fecha_hora_ingreso BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
    
    UNION
    
    SELECT 
        ci.id_paciente,
        1 AS id_tipo_unidad,
        'Consulta externa' AS nombre_unidad,
        con.fecha_hora AS fecha_atencion
    FROM consulta con
    JOIN cita ci ON ci.id_cita = con.id_cita
    WHERE con.fecha_hora BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
    
    UNION
    
    SELECT 
        ep.id_paciente,
        3 AS id_tipo_unidad,
        'Cirugia' AS nombre_unidad,
        c.inicio_programado AS fecha_atencion
    FROM cirugia c
    JOIN solicitud_cirugia sc ON sc.id_solicitud_cirugia = c.id_solicitud_cirugia
    JOIN episodio ep ON ep.id_episodio = sc.id_episodio
    WHERE c.inicio_programado BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
)
SELECT 
    p.id_paciente,
    per.nombres || ' ' || per.apellidos AS nombre_paciente,
    per.dpi,
    COUNT(DISTINCT a.nombre_unidad) AS total_unidades_atendidas
FROM paciente p
JOIN persona per ON per.id_persona = p.id_persona
JOIN atenciones a ON a.id_paciente = p.id_paciente
GROUP BY p.id_paciente, per.nombres, per.apellidos, per.dpi
HAVING COUNT(DISTINCT a.nombre_unidad) = (
    SELECT COUNT(*) 
    FROM tipo_unidad 
    WHERE nombre IN ('Consulta externa', 'Emergencias', 'Cirugia', 'Hospitalizacion')
)
ORDER BY p.id_paciente ASC;



-- Enfoque 2: Doble negacion con algebra relacional (NOT EXISTS / EXCEPT)
-- No existe unidad medica oficial requerida que no haya atendido al paciente

WITH atenciones AS (
    SELECT 
        ep.id_paciente,
        tu.id_tipo_unidad,
        tu.nombre AS nombre_unidad,
        ing.fecha_hora_ingreso AS fecha_atencion
    FROM ingreso ing
    JOIN episodio ep ON ep.id_episodio = ing.id_episodio
    JOIN unidad_hospital uh ON uh.id_unidad_hospital = ing.id_unidad_hospital
    JOIN tipo_unidad tu ON tu.id_tipo_unidad = uh.id_tipo_unidad
    WHERE ing.fecha_hora_ingreso BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
    
    UNION
    
    SELECT 
        ci.id_paciente,
        1 AS id_tipo_unidad,
        'Consulta externa' AS nombre_unidad,
        con.fecha_hora AS fecha_atencion
    FROM consulta con
    JOIN cita ci ON ci.id_cita = con.id_cita
    WHERE con.fecha_hora BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
    
    UNION
    
    SELECT 
        ep.id_paciente,
        3 AS id_tipo_unidad,
        'Cirugia' AS nombre_unidad,
        c.inicio_programado AS fecha_atencion
    FROM cirugia c
    JOIN solicitud_cirugia sc ON sc.id_solicitud_cirugia = c.id_solicitud_cirugia
    JOIN episodio ep ON ep.id_episodio = sc.id_episodio
    WHERE c.inicio_programado BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
)
SELECT 
    p.id_paciente,
    per.nombres || ' ' || per.apellidos AS nombre_paciente,
    per.dpi
FROM paciente p
JOIN persona per ON per.id_persona = p.id_persona
WHERE NOT EXISTS (
    SELECT tu.id_tipo_unidad
    FROM tipo_unidad tu
    WHERE tu.nombre IN ('Consulta externa', 'Emergencias', 'Cirugia', 'Hospitalizacion')
    
    EXCEPT
    
    SELECT a.id_tipo_unidad
    FROM atenciones a
    WHERE a.id_paciente = p.id_paciente
)
ORDER BY p.id_paciente ASC;
