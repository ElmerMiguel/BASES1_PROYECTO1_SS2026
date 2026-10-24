import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Paciente } from './Paciente';
import { Hospital } from './Hospital';

@Entity({ name: 'episodio', schema: 'hospitales_occidente' })
export class Episodio {
  @PrimaryGeneratedColumn({ name: 'id_episodio', type: 'bigint' })
  idEpisodio: string;

  @Column({ name: 'id_paciente', type: 'bigint' })
  idPaciente: string;

  @Column({ name: 'id_hospital', type: 'integer' })
  idHospital: number;

  @Column({ name: 'fecha_apertura', type: 'timestamptz' })
  fechaApertura: Date;

  @Column({ name: 'fecha_cierre', type: 'timestamptz', nullable: true })
  fechaCierre: Date | null;

  @ManyToOne(() => Paciente)
  @JoinColumn({ name: 'id_paciente' })
  paciente: Paciente;

  @ManyToOne(() => Hospital)
  @JoinColumn({ name: 'id_hospital' })
  hospital: Hospital;
}
