import { Entity, PrimaryGeneratedColumn, Column, OneToOne, JoinColumn } from 'typeorm';
import { Persona } from './Persona';

@Entity({ name: 'paciente', schema: 'hospitales_occidente' })
export class Paciente {
  @PrimaryGeneratedColumn({ name: 'id_paciente', type: 'bigint' })
  idPaciente: string;

  @Column({ name: 'id_persona', type: 'integer', unique: true })
  idPersona: number;

  @OneToOne(() => Persona)
  @JoinColumn({ name: 'id_persona' })
  persona: Persona;
}
