import { Entity, PrimaryGeneratedColumn, Column, OneToOne, JoinColumn } from 'typeorm';
import { Cita } from './Cita';

@Entity({ name: 'consulta', schema: 'hospitales_occidente' })
export class Consulta {
  @PrimaryGeneratedColumn({ name: 'id_consulta', type: 'bigint' })
  idConsulta: string;

  @Column({ name: 'id_cita', type: 'bigint', unique: true })
  idCita: string;

  @Column({ name: 'id_episodio', type: 'bigint' })
  idEpisodio: string;

  @Column({ name: 'fecha_hora', type: 'timestamptz' })
  fechaHora: Date;

  @OneToOne(() => Cita)
  @JoinColumn({ name: 'id_cita' })
  cita: Cita;
}
