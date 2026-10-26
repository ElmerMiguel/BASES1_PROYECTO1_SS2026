import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Clinica } from './Clinica';
import { Medico } from './Medico';

@Entity({ name: 'cita', schema: 'hospitales_occidente' })
export class Cita {
  @PrimaryGeneratedColumn({ name: 'id_cita', type: 'bigint' })
  idCita: string;

  @Column({ name: 'id_paciente', type: 'bigint' })
  idPaciente: string;

  @Column({ name: 'id_clinica', type: 'integer' })
  idClinica: number;

  @Column({ name: 'id_medico', type: 'integer' })
  idMedico: number;

  @Column({ name: 'fecha_hora', type: 'timestamptz' })
  fechaHora: Date;

  @Column({ name: 'estado', type: 'varchar', length: 15, default: 'Programada' })
  estado: string;

  @ManyToOne(() => Clinica)
  @JoinColumn({ name: 'id_clinica' })
  clinica: Clinica;

  @ManyToOne(() => Medico)
  @JoinColumn({ name: 'id_medico' })
  medico: Medico;
}
