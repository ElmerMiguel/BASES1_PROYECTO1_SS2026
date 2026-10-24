import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity({ name: 'receta', schema: 'hospitales_occidente' })
export class Receta {
  @PrimaryGeneratedColumn({ name: 'id_receta', type: 'bigint' })
  idReceta: string;

  @Column({ name: 'id_consulta', type: 'bigint' })
  idConsulta: string;

  @Column({ name: 'id_cita_proxima', type: 'bigint', nullable: true })
  idCitaProxima: string | null;
}
