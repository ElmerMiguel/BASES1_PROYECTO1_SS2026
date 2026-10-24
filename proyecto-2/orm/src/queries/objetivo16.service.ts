import { DataSource } from 'typeorm';

export async function consultarObjetivo16(
  dataSource: DataSource,
  idMedico: number
) {
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
    SELECT 
        nivel_jerarquico,
        id_medico,
        nombre_medico,
        nivel_acceso,
        id_superior,
        nombre_superior
    FROM cadena_supervision
    ORDER BY nivel_jerarquico ASC;
  `;

  return await dataSource.query(sql, [idMedico]);
}
