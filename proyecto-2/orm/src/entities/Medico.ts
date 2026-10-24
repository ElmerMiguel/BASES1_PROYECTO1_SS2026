import { Entity, PrimaryColumn, Column, OneToOne, ManyToOne, JoinColumn } from 'typeorm';
import { Persona } from './Persona';

@Entity({ name: 'medico', schema: 'hospitales_occidente' })
export class Medico {
  @PrimaryColumn({ name: 'id_personal', type: 'integer' })
  idPersonal: number;

  @Column({ name: 'no_colegiado', type: 'varchar', length: 15, unique: true })
  noColegiado: string;

  @Column({ name: 'id_superior', type: 'integer', nullable: true })
  idSuperior: number | null;

  @Column({ name: 'nivel_acceso', type: 'varchar', length: 25, default: 'Medico Asistencial' })
  nivelAcceso: string;

  @OneToOne(() => Persona)
  @JoinColumn({ name: 'id_personal' })
  persona: Persona;

  @ManyToOne(() => Medico, { nullable: true })
  @JoinColumn({ name: 'id_superior' })
  superior: Medico | null;
}
