SET search_path TO hospitales_occidente, public;
SET timezone TO 'America/Guatemala';


-- OBJETIVO 16: Cadena de supervision medica recursiva
-- Parametros: id_medico

WITH RECURSIVE cadena_supervision AS (
    SELECT 
        m.id_personal AS id_medico,
        p.nombres || ' ' || p.apellidos AS nombre_medico,
        m.nivel_acceso,
        m.id_superior,
        psup.nombres || ' ' || psup.apellidos AS nombre_superior,
        1 AS nivel_jerarquico
    FROM medico m
    JOIN persona p ON p.id_persona = m.id_personal
    LEFT JOIN persona psup ON psup.id_persona = m.id_superior
    WHERE m.id_personal = 7

    UNION ALL

    SELECT 
        sup.id_personal AS id_medico,
        psup.nombres || ' ' || psup.apellidos AS nombre_medico,
        sup.nivel_acceso,
        sup.id_superior,
        p_next.nombres || ' ' || p_next.apellidos AS nombre_superior,
        cs.nivel_jerarquico + 1 AS nivel_jerarquico
    FROM medico sup
    JOIN persona psup ON psup.id_persona = sup.id_personal
    LEFT JOIN persona p_next ON p_next.id_persona = sup.id_superior
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



-- OBJETIVO 17: Ranking dual de calificaciones (hospital y red general)


-- a: Funciones de ventana
SELECT 
    m.id_personal,
    p.nombres || ' ' || p.apellidos AS nombre_medico,
    m.no_colegiado,
    h.nombre AS hospital,
    COUNT(DISTINCT con.id_consulta) AS numero_consultas,
    ROUND(AVG(cp.puntuacion), 2) AS calificacion_promedio,
    RANK() OVER (
        PARTITION BY h.id_hospital 
        ORDER BY AVG(cp.puntuacion) ASC
    ) AS ranking_hospital,
    RANK() OVER (
        ORDER BY AVG(cp.puntuacion) ASC
    ) AS ranking_general
FROM medico m
JOIN persona p ON p.id_persona = m.id_personal
JOIN cita ci ON ci.id_medico = m.id_personal
JOIN clinica cl ON cl.id_clinica = ci.id_clinica
JOIN hospital h ON h.id_hospital = cl.id_hospital
JOIN consulta con ON con.id_cita = ci.id_cita
JOIN calificacion_personal cp ON cp.id_personal = m.id_personal
GROUP BY m.id_personal, p.nombres, p.apellidos, m.no_colegiado, h.id_hospital, h.nombre
ORDER BY calificacion_promedio ASC;


-- b: Subconsultas correlacionadas
WITH promedios AS (
    SELECT 
        m.id_personal,
        p.nombres || ' ' || p.apellidos AS nombre_medico,
        m.no_colegiado,
        h.id_hospital,
        h.nombre AS hospital,
        COUNT(DISTINCT con.id_consulta) AS numero_consultas,
        ROUND(AVG(cp.puntuacion), 2) AS calificacion_promedio
    FROM medico m
    JOIN persona p ON p.id_persona = m.id_personal
    JOIN cita ci ON ci.id_medico = m.id_personal
    JOIN clinica cl ON cl.id_clinica = ci.id_clinica
    JOIN hospital h ON h.id_hospital = cl.id_hospital
    JOIN consulta con ON con.id_cita = ci.id_cita
    JOIN calificacion_personal cp ON cp.id_personal = m.id_personal
    GROUP BY m.id_personal, p.nombres, p.apellidos, m.no_colegiado, h.id_hospital, h.nombre
)
SELECT 
    p1.id_personal,
    p1.nombre_medico,
    p1.no_colegiado,
    p1.hospital,
    p1.numero_consultas,
    p1.calificacion_promedio,
    (
        SELECT COUNT(*) + 1
        FROM promedios p2
        WHERE p2.id_hospital = p1.id_hospital
          AND p2.calificacion_promedio < p1.calificacion_promedio
    ) AS ranking_hospital,
    (
        SELECT COUNT(*) + 1
        FROM promedios p3
        WHERE p3.calificacion_promedio < p1.calificacion_promedio
    ) AS ranking_general
FROM promedios p1
ORDER BY p1.calificacion_promedio ASC;



-- OBJETIVO 17: Evaluacion de planes de ejecucion con EXPLAIN ANALYZE


-- Plan Variante A (Funciones de ventana)
EXPLAIN (ANALYZE, BUFFERS, COSTS, VERBOSE, TIMING)
WITH promedios AS (
    SELECT 
        m.id_personal,
        p.nombres || ' ' || p.apellidos AS nombre_medico,
        m.no_colegiado,
        h.id_hospital,
        h.nombre AS hospital,
        COUNT(DISTINCT con.id_consulta) AS numero_consultas,
        ROUND(AVG(cp.puntuacion), 2) AS calificacion_promedio
    FROM medico m
    JOIN persona p ON p.id_persona = m.id_personal
    JOIN cita ci ON ci.id_medico = m.id_personal
    JOIN clinica cl ON cl.id_clinica = ci.id_clinica
    JOIN hospital h ON h.id_hospital = cl.id_hospital
    JOIN consulta con ON con.id_cita = ci.id_cita
    JOIN calificacion_personal cp ON cp.id_personal = m.id_personal
    GROUP BY m.id_personal, p.nombres, p.apellidos, m.no_colegiado, h.id_hospital, h.nombre
)
SELECT 
    id_personal,
    nombre_medico,
    no_colegiado,
    hospital,
    numero_consultas,
    calificacion_promedio,
    RANK() OVER (PARTITION BY id_hospital ORDER BY calificacion_promedio ASC) AS ranking_hospital,
    RANK() OVER (ORDER BY calificacion_promedio ASC) AS ranking_general
FROM promedios
ORDER BY calificacion_promedio ASC;

-- Plan Variante B (Subconsultas correlacionadas)
EXPLAIN (ANALYZE, BUFFERS, COSTS, VERBOSE, TIMING)
WITH promedios AS (
    SELECT 
        m.id_personal,
        p.nombres || ' ' || p.apellidos AS nombre_medico,
        m.no_colegiado,
        h.id_hospital,
        h.nombre AS hospital,
        COUNT(DISTINCT con.id_consulta) AS numero_consultas,
        ROUND(AVG(cp.puntuacion), 2) AS calificacion_promedio
    FROM medico m
    JOIN persona p ON p.id_persona = m.id_personal
    JOIN cita ci ON ci.id_medico = m.id_personal
    JOIN clinica cl ON cl.id_clinica = ci.id_clinica
    JOIN hospital h ON h.id_hospital = cl.id_hospital
    JOIN consulta con ON con.id_cita = ci.id_cita
    JOIN calificacion_personal cp ON cp.id_personal = m.id_personal
    GROUP BY m.id_personal, p.nombres, p.apellidos, m.no_colegiado, h.id_hospital, h.nombre
)
SELECT 
    p1.id_personal,
    p1.nombre_medico,
    p1.no_colegiado,
    p1.hospital,
    p1.numero_consultas,
    p1.calificacion_promedio,
    (
        SELECT COUNT(*) + 1
        FROM promedios p2
        WHERE p2.id_hospital = p1.id_hospital
          AND p2.calificacion_promedio < p1.calificacion_promedio
    ) AS ranking_hospital,
    (
        SELECT COUNT(*) + 1
        FROM promedios p3
        WHERE p3.calificacion_promedio < p1.calificacion_promedio
    ) AS ranking_general
FROM promedios p1
ORDER BY p1.calificacion_promedio ASC;
