import { DataSource } from 'typeorm';

export async function consultarObjetivo18(
  dataSource: DataSource,
  fechaInicio: string,
  fechaFin: string
) {
  const sql = `
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
  `;

  return await dataSource.query(sql, [fechaInicio, fechaFin]);
}
