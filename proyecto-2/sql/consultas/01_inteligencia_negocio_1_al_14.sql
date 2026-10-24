SET search_path TO hospitales_occidente, public;
SET timezone TO 'America/Guatemala';

-- ============================================================================
-- OBJETIVO 01: Top 3 hospitales con mayor demanda en consulta externa
-- Parametros: lapso de tiempo ('2026-01-01' a '2026-12-31')
-- ============================================================================
WITH demanda AS (
    SELECT 
        h.id_hospital,
        h.nombre AS hospital,
        COUNT(DISTINCT ci.id_cita) FILTER (WHERE ci.estado <> 'Cancelada') AS reservaciones,
        COUNT(DISTINCT co.id_consulta) AS consultas,
        COUNT(DISTINCT re.id_receta) FILTER (WHERE re.id_cita_proxima IS NOT NULL) AS proximas_consultas
    FROM hospital h
    JOIN clinica cl ON cl.id_hospital = h.id_hospital
    LEFT JOIN cita ci ON ci.id_clinica = cl.id_clinica 
        AND ci.fecha_hora BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
    LEFT JOIN consulta co ON co.id_cita = ci.id_cita
    LEFT JOIN receta re ON re.id_consulta = co.id_consulta
    WHERE h.es_interno = True
    GROUP BY h.id_hospital, h.nombre
)
SELECT 
    hospital,
    reservaciones,
    consultas,
    proximas_consultas,
    (reservaciones + consultas + proximas_consultas) AS demanda_total
FROM demanda
ORDER BY demanda_total DESC
LIMIT 3;


-- ============================================================================
-- OBJETIVO 02: 5 medicos de consulta externa con menor nota (ranking 1 al 5)
-- ============================================================================
SELECT 
    m.id_personal AS id_medico,
    p.nombres || ' ' || p.apellidos AS nombre_medico,
    m.no_colegiado,
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
GROUP BY m.id_personal, p.nombres, p.apellidos, m.no_colegiado, h.nombre
ORDER BY calificacion_promedio ASC, numero_consultas ASC
LIMIT 5;


-- ============================================================================
-- OBJETIVO 03: 5 mejores medicos de emergencias en un lapso de tiempo
-- Parametros: lapso de tiempo ('2026-01-01' a '2026-12-31')
-- ============================================================================
WITH turnos_calc AS (
    SELECT 
        ap.id_personal AS id_medico,
        uh.id_hospital,
        COUNT(ap.id_asignacion) AS turnos_laborados,
        SUM(
            CASE 
                WHEN t.hora_fin > t.hora_inicio 
                THEN EXTRACT(EPOCH FROM (t.hora_fin - t.hora_inicio)) / 3600.0
                ELSE (EXTRACT(EPOCH FROM (t.hora_fin - t.hora_inicio)) / 3600.0) + 24.0
            END
        ) AS horas_laboradas
    FROM asignacion_personal ap
    JOIN unidad_hospital uh ON uh.id_unidad_hospital = ap.id_unidad_hospital
    JOIN turno t ON t.id_turno = ap.id_turno
    WHERE uh.id_tipo_unidad = 2
      AND ap.fecha_inicio <= '2026-12-31'
      AND (ap.fecha_fin IS NULL OR ap.fecha_fin >= '2026-01-01')
    GROUP BY ap.id_personal, uh.id_hospital
),
egresos_calc AS (
    SELECT 
        e.id_medico,
        uh.id_hospital,
        COUNT(e.id_egreso) AS egresos_vivos_consentimiento
    FROM egreso e
    JOIN ingreso i ON i.id_ingreso = e.id_ingreso
    JOIN unidad_hospital uh ON uh.id_unidad_hospital = i.id_unidad_hospital
    WHERE uh.id_tipo_unidad = 2
      AND e.codigo_egreso = 'Vivo'
      AND e.egreso_sin_consentimiento = False
      AND e.fecha_hora_egreso BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
    GROUP BY e.id_medico, uh.id_hospital
)
SELECT 
    m.id_personal AS id_medico,
    p.nombres || ' ' || p.apellidos AS nombre_medico,
    h.nombre AS hospital,
    COALESCE(tc.horas_laboradas, 0) AS horas_laboradas,
    COALESCE(tc.turnos_laborados, 0) AS turnos_laborados,
    COALESCE(ec.egresos_vivos_consentimiento, 0) AS egresos_vivos_consentimiento
FROM medico m
JOIN persona p ON p.id_persona = m.id_personal
JOIN turnos_calc tc ON tc.id_medico = m.id_personal
JOIN hospital h ON h.id_hospital = tc.id_hospital
LEFT JOIN egresos_calc ec ON ec.id_medico = m.id_personal AND ec.id_hospital = tc.id_hospital
ORDER BY egresos_vivos_consentimiento DESC, horas_laboradas DESC
LIMIT 5;


-- ============================================================================
-- OBJETIVO 04: 3 hospitales con mayor eficiencia en emergencias
-- Parametros: lapso de tiempo ('2026-01-01' a '2026-12-31')
-- ============================================================================
WITH camas_emergencias AS (
    SELECT 
        uh.id_hospital,
        COUNT(ea.id_espacio) AS camas_totales
    FROM espacio_atencion ea
    JOIN unidad_hospital uh ON uh.id_unidad_hospital = ea.id_unidad_hospital
    WHERE uh.id_tipo_unidad = 2 AND ea.tipo = 'Camilla'
    GROUP BY uh.id_hospital
),
flujo_emergencias AS (
    SELECT 
        uh.id_hospital,
        COUNT(DISTINCT i.id_ingreso) AS total_ingresos,
        COUNT(DISTINCT e.id_egreso) AS total_egresos,
        ROUND(AVG(COALESCE(i.prioridad_triage, 3)), 2) AS promedio_triage_espera
    FROM ingreso i
    JOIN unidad_hospital uh ON uh.id_unidad_hospital = i.id_unidad_hospital
    LEFT JOIN egreso e ON e.id_ingreso = i.id_ingreso
    WHERE uh.id_tipo_unidad = 2
      AND i.fecha_hora_ingreso BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
    GROUP BY uh.id_hospital
)
SELECT 
    h.id_hospital,
    h.nombre AS hospital,
    COALESCE(ce.camas_totales, 0) AS camas_totales,
    COALESCE(fe.total_ingresos, 0) AS total_ingresos,
    COALESCE(fe.total_egresos, 0) AS total_egresos,
    (COALESCE(ce.camas_totales, 0) - (COALESCE(fe.total_ingresos, 0) - COALESCE(fe.total_egresos, 0))) AS camas_disponibles,
    COALESCE(fe.promedio_triage_espera, 0) AS promedio_triage_espera
FROM hospital h
LEFT JOIN camas_emergencias ce ON ce.id_hospital = h.id_hospital
LEFT JOIN flujo_emergencias fe ON fe.id_hospital = h.id_hospital
WHERE h.es_interno = True
ORDER BY camas_disponibles DESC, promedio_triage_espera ASC
LIMIT 3;


-- ============================================================================
-- OBJETIVO 05: 3 cirujanos mas eficientes (menor uso de recursos y mas cirugias aprobadas)
-- Parametros: lapso de tiempo ('2026-01-01' a '2026-12-31')
-- ============================================================================
WITH agendamientos_aprobados AS (
    SELECT 
        sc.id_cirujano,
        COUNT(DISTINCT sc.id_solicitud_cirugia) AS solicitudes_aprobadas
    FROM solicitud_cirugia sc
    JOIN revision_solicitud rs ON rs.id_solicitud_cirugia = sc.id_solicitud_cirugia
    WHERE rs.decision = 'Aprobada'
      AND sc.fecha_hora_solicitud BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
    GROUP BY sc.id_cirujano
),
recursos_utilizados AS (
    SELECT 
        sc.id_cirujano,
        COALESCE(SUM(DISTINCT si.cantidad), 0) AS total_insumos,
        COALESCE(SUM(DISTINCT sinstr.cantidad), 0) AS total_instrumentos,
        COALESCE(SUM(DISTINCT se.cantidad), 0) AS total_equipos
    FROM solicitud_cirugia sc
    JOIN revision_solicitud rs ON rs.id_solicitud_cirugia = sc.id_solicitud_cirugia
    LEFT JOIN solicitud_insumo si ON si.id_solicitud_cirugia = sc.id_solicitud_cirugia
    LEFT JOIN solicitud_instrumento sinstr ON sinstr.id_solicitud_cirugia = sc.id_solicitud_cirugia
    LEFT JOIN solicitud_equipo se ON se.id_solicitud_cirugia = sc.id_solicitud_cirugia
    WHERE rs.decision = 'Aprobada'
      AND sc.fecha_hora_solicitud BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
    GROUP BY sc.id_cirujano
)
SELECT 
    m.id_personal AS id_cirujano,
    p.nombres || ' ' || p.apellidos AS nombre_cirujano,
    m.no_colegiado,
    COALESCE(aa.solicitudes_aprobadas, 0) AS agendamientos_aprobados,
    COALESCE(ru.total_insumos, 0) AS total_insumos,
    COALESCE(ru.total_instrumentos, 0) AS total_instrumentos,
    COALESCE(ru.total_equipos, 0) AS total_equipos,
    (COALESCE(ru.total_insumos, 0) + COALESCE(ru.total_instrumentos, 0) + COALESCE(ru.total_equipos, 0)) AS recursos_totales
FROM medico m
JOIN persona p ON p.id_persona = m.id_personal
JOIN agendamientos_aprobados aa ON aa.id_cirujano = m.id_personal
JOIN recursos_utilizados ru ON ru.id_cirujano = m.id_personal
ORDER BY aa.solicitudes_aprobadas DESC, recursos_totales ASC
LIMIT 3;


-- ============================================================================
-- OBJETIVO 06: 3 tipos de cirugia con mayores ingresos monetarios (sin complicaciones y exito)
-- Parametros: lapso de tiempo ('2026-01-01' a '2026-12-31')
-- ============================================================================
SELECT 
    pq.id_procedimiento,
    pq.nombre AS tipo_cirugia,
    COUNT(DISTINCT c.id_cirugia) AS total_cirugias_exitosas,
    SUM(fd.cantidad * fd.precio_unitario) AS ingresos_monetarios
FROM cirugia c
JOIN solicitud_cirugia sc ON sc.id_solicitud_cirugia = c.id_solicitud_cirugia
JOIN solicitud_procedimiento sp ON sp.id_solicitud_cirugia = sc.id_solicitud_cirugia
JOIN procedimiento_quirurgico pq ON pq.id_procedimiento = sp.id_procedimiento
JOIN factura_detalle fd ON fd.id_cirugia = c.id_cirugia
WHERE c.estado = 'Finalizada'
  AND c.condicion_evolucion = 'Sin complicaciones'
  AND NOT EXISTS (
      SELECT 1 
      FROM cirugia_verificacion cv 
      WHERE cv.id_cirugia = c.id_cirugia 
        AND cv.resultado NOT IN ('Exito', 'Aceptable')
  )
  AND c.inicio_programado BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
GROUP BY pq.id_procedimiento, pq.nombre
ORDER BY ingresos_monetarios DESC
LIMIT 3;


-- ============================================================================
-- OBJETIVO 07: 3 hospitales con mayores ingresos en hospitalizacion
-- Parametros: lapso de tiempo ('2026-01-01' a '2026-12-31')
-- ============================================================================
SELECT 
    h.id_hospital,
    h.nombre AS hospital,
    SUM(p.monto) AS ingresos_hospitalizacion,
    COUNT(DISTINCT ea.id_espacio) AS camillas_asignadas,
    ROUND(AVG(fd.precio_unitario), 2) AS costo_promedio_servicio
FROM hospital h
JOIN unidad_hospital uh ON uh.id_hospital = h.id_hospital AND uh.id_tipo_unidad = 4
JOIN pago p ON p.id_unidad_hospital = uh.id_unidad_hospital
JOIN factura f ON f.id_factura = p.id_factura
JOIN factura_detalle fd ON fd.id_factura = f.id_factura AND fd.concepto = 'Hospitalizacion'
LEFT JOIN espacio_atencion ea ON ea.id_unidad_hospital = uh.id_unidad_hospital AND ea.tipo = 'Camilla'
WHERE p.fecha_pago BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
GROUP BY h.id_hospital, h.nombre
ORDER BY ingresos_hospitalizacion DESC, camillas_asignadas ASC, costo_promedio_servicio ASC
LIMIT 3;


-- ============================================================================
-- OBJETIVO 08: Total de pagos por metodo (efectivo, credito, debito) por hospital y unidad
-- ============================================================================
SELECT 
    h.id_hospital,
    h.nombre AS hospital,
    tu.nombre AS unidad_medica,
    COALESCE(SUM(p.monto) FILTER (WHERE mp.nombre = 'Efectivo'), 0) AS total_efectivo,
    COALESCE(SUM(p.monto) FILTER (WHERE mp.nombre = 'Tarjeta de credito'), 0) AS total_credito,
    COALESCE(SUM(p.monto) FILTER (WHERE mp.nombre = 'Tarjeta de debito'), 0) AS total_debito,
    COALESCE(SUM(p.monto), 0) AS total_general
FROM hospital h
JOIN unidad_hospital uh ON uh.id_hospital = h.id_hospital
JOIN tipo_unidad tu ON tu.id_tipo_unidad = uh.id_tipo_unidad
LEFT JOIN pago p ON p.id_unidad_hospital = uh.id_unidad_hospital
LEFT JOIN metodo_pago mp ON mp.id_metodo_pago = p.id_metodo_pago
WHERE h.es_interno = True
GROUP BY h.id_hospital, h.nombre, tu.id_tipo_unidad, tu.nombre
ORDER BY h.id_hospital, tu.id_tipo_unidad;


-- ============================================================================
-- OBJETIVO 09: 3 hospitales con mayores ingresos monetarios por visita
-- Parametros: lapso de tiempo ('2026-01-01' a '2026-12-31')
-- ============================================================================
WITH ingresos_hosp AS (
    SELECT 
        uh.id_hospital,
        SUM(p.monto) AS ingresos_totales
    FROM pago p
    JOIN unidad_hospital uh ON uh.id_unidad_hospital = p.id_unidad_hospital
    WHERE p.fecha_pago BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
    GROUP BY uh.id_hospital
),
visitas_hosp AS (
    SELECT 
        uh.id_hospital,
        COUNT(DISTINCT i.id_ingreso) AS total_ingresos
    FROM ingreso i
    JOIN unidad_hospital uh ON uh.id_unidad_hospital = i.id_unidad_hospital
    WHERE i.fecha_hora_ingreso BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
    GROUP BY uh.id_hospital
),
consultas_hosp AS (
    SELECT 
        cl.id_hospital,
        COUNT(DISTINCT co.id_consulta) AS total_consultas
    FROM consulta co
    JOIN cita ci ON ci.id_cita = co.id_cita
    JOIN clinica cl ON cl.id_clinica = ci.id_clinica
    WHERE co.fecha_hora BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
    GROUP BY cl.id_hospital
)
SELECT 
    h.id_hospital,
    h.nombre AS hospital,
    COALESCE(ih.ingresos_totales, 0) AS ingresos_totales,
    (COALESCE(vh.total_ingresos, 0) + COALESCE(ch.total_consultas, 0)) AS total_visitas,
    ROUND(
        COALESCE(ih.ingresos_totales, 0) / 
        NULLIF(COALESCE(vh.total_ingresos, 0) + COALESCE(ch.total_consultas, 0), 0), 
        2
    ) AS ingreso_promedio_por_visita
FROM hospital h
LEFT JOIN ingresos_hosp ih ON ih.id_hospital = h.id_hospital
LEFT JOIN visitas_hosp vh ON vh.id_hospital = h.id_hospital
LEFT JOIN consultas_hosp ch ON ch.id_hospital = h.id_hospital
WHERE h.es_interno = True
ORDER BY ingreso_promedio_por_visita DESC NULLS LAST
LIMIT 3;


-- ============================================================================
-- OBJETIVO 10: Fecha con mayor cantidad de decesos por hospital y unidad critica
-- ============================================================================
WITH decesos_diarios AS (
    SELECT 
        uh.id_hospital,
        e.fecha_hora_egreso::DATE AS fecha_deceso,
        tu.nombre AS unidad_medica,
        COUNT(e.id_egreso) AS total_decesos,
        ROW_NUMBER() OVER (
            PARTITION BY uh.id_hospital 
            ORDER BY COUNT(e.id_egreso) DESC, e.fecha_hora_egreso::DATE DESC
        ) AS rank_hospital
    FROM egreso e
    JOIN ingreso i ON i.id_ingreso = e.id_ingreso
    JOIN unidad_hospital uh ON uh.id_unidad_hospital = i.id_unidad_hospital
    JOIN tipo_unidad tu ON tu.id_tipo_unidad = uh.id_tipo_unidad
    WHERE e.codigo_egreso = 'Muerto'
    GROUP BY uh.id_hospital, e.fecha_hora_egreso::DATE, tu.nombre
)
SELECT 
    h.id_hospital,
    h.nombre AS hospital,
    dd.fecha_deceso,
    dd.unidad_medica AS unidad_mayoria_decesos,
    dd.total_decesos AS cantidad_decesos
FROM decesos_diarios dd
JOIN hospital h ON h.id_hospital = dd.id_hospital
WHERE dd.rank_hospital = 1
ORDER BY dd.total_decesos DESC, h.id_hospital;


-- ============================================================================
-- OBJETIVO 11: Ingresos monetarios totales de cada hospital en un lapso de tiempo
-- Parametros: lapso de tiempo ('2026-01-01' a '2026-12-31')
-- ============================================================================
SELECT 
    h.id_hospital,
    h.nombre AS hospital,
    COALESCE(SUM(p.monto), 0) AS total_ingresos_monetarios
FROM hospital h
LEFT JOIN unidad_hospital uh ON uh.id_hospital = h.id_hospital
LEFT JOIN pago p ON p.id_unidad_hospital = uh.id_unidad_hospital
    AND p.fecha_pago BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
WHERE h.es_interno = True
GROUP BY h.id_hospital, h.nombre
ORDER BY total_ingresos_monetarios DESC;


-- ============================================================================
-- OBJETIVO 12: Promedio de edad y distribucion por sexo en emergencias por turno
-- ============================================================================
SELECT 
    h.id_hospital,
    h.nombre AS hospital,
    COALESCE(t.nombre, 'Sin turno especifico') AS turno,
    ROUND(AVG(EXTRACT(YEAR FROM age(i.fecha_hora_ingreso, per.fecha_nacimiento))), 1) AS promedio_edad,
    COUNT(*) FILTER (WHERE per.sexo = 'Masculino') AS total_masculino,
    COUNT(*) FILTER (WHERE per.sexo = 'Femenino') AS total_femenino,
    COUNT(*) AS total_ingresos_emergencias
FROM ingreso i
JOIN unidad_hospital uh ON uh.id_unidad_hospital = i.id_unidad_hospital
JOIN hospital h ON h.id_hospital = uh.id_hospital
JOIN episodio ep ON ep.id_episodio = i.id_episodio
JOIN paciente pac ON pac.id_paciente = ep.id_paciente
JOIN persona per ON per.id_persona = pac.id_persona
LEFT JOIN asignacion_personal ap ON ap.id_personal = i.id_medico 
    AND ap.id_unidad_hospital = i.id_unidad_hospital
LEFT JOIN turno t ON t.id_turno = ap.id_turno
WHERE uh.id_tipo_unidad = 2
GROUP BY h.id_hospital, h.nombre, t.nombre
ORDER BY h.id_hospital, turno;


-- ============================================================================
-- OBJETIVO 13: Reporte de citas en consulta externa agrupado por sexo y especialidad
-- ============================================================================
SELECT 
    ci.fecha_hora::DATE AS fecha_cita,
    h.nombre AS hospital,
    per.sexo AS sexo_paciente,
    COALESCE(esp.nombre, 'Medicina General') AS especialidad_medica,
    COUNT(ci.id_cita) AS total_citas,
    COUNT(ci.id_cita) FILTER (WHERE ci.estado = 'Realizada') AS citas_realizadas,
    COUNT(ci.id_cita) FILTER (WHERE ci.estado = 'Programada') AS citas_programadas,
    COUNT(ci.id_cita) FILTER (WHERE ci.estado = 'Cancelada') AS citas_canceladas
FROM cita ci
JOIN clinica cl ON cl.id_clinica = ci.id_clinica
JOIN hospital h ON h.id_hospital = cl.id_hospital
JOIN paciente pac ON pac.id_paciente = ci.id_paciente
JOIN persona per ON per.id_persona = pac.id_persona
JOIN medico m ON m.id_personal = ci.id_medico
LEFT JOIN medico_especialidad me ON me.id_medico = m.id_personal AND me.es_principal = True
LEFT JOIN especialidad esp ON esp.id_especialidad = me.id_especialidad
GROUP BY ci.fecha_hora::DATE, h.nombre, per.sexo, esp.nombre
ORDER BY fecha_cita ASC, hospital ASC, especialidad_medica ASC;


-- ============================================================================
-- OBJETIVO 14: Promedio de cuotas de financiamiento por unidad medica en cada hospital
-- Parametros: lapso de tiempo ('2026-01-01' a '2026-12-31')
-- ============================================================================
SELECT 
    h.id_hospital,
    h.nombre AS hospital,
    tu.nombre AS unidad_medica,
    COUNT(DISTINCT f.id_factura) AS total_facturas_emitidas,
    ROUND(AVG(f.numero_cuotas), 2) AS promedio_cuotas_financiamiento
FROM factura f
JOIN pago p ON p.id_factura = f.id_factura
JOIN unidad_hospital uh ON uh.id_unidad_hospital = p.id_unidad_hospital
JOIN hospital h ON h.id_hospital = uh.id_hospital
JOIN tipo_unidad tu ON tu.id_tipo_unidad = uh.id_tipo_unidad
WHERE f.fecha_emision BETWEEN '2026-01-01 00:00:00-06' AND '2026-12-31 23:59:59-06'
GROUP BY h.id_hospital, h.nombre, tu.id_tipo_unidad, tu.nombre
ORDER BY h.id_hospital, tu.id_tipo_unidad;
