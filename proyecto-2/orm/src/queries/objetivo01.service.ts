import { DataSource } from 'typeorm';
import { Hospital } from '../entities/Hospital';

export async function consultarObjetivo01(
  dataSource: DataSource,
  fechaInicio: string,
  fechaFin: string
) {
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

  return await qb.getRawMany();
}
