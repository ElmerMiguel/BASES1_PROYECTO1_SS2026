import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Hospital } from './Hospital';

@Entity({ name: 'clinica', schema: 'hospitales_occidente' })
export class Clinica {
  @PrimaryGeneratedColumn({ name: 'id_clinica', type: 'integer' })
  idClinica: number;

  @Column({ name: 'id_hospital', type: 'integer' })
  idHospital: number;

  @Column({ name: 'numero_clinica', type: 'varchar', length: 10 })
  numeroClinica: string;

  @Column({ name: 'habilitada', type: 'boolean', default: true })
  habilitada: boolean;

  @ManyToOne(() => Hospital)
  @JoinColumn({ name: 'id_hospital' })
  hospital: Hospital;
}
