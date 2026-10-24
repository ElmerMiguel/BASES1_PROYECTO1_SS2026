import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity({ name: 'hospital', schema: 'hospitales_occidente' })
export class Hospital {
  @PrimaryGeneratedColumn({ name: 'id_hospital', type: 'integer' })
  idHospital: number;

  @Column({ name: 'nombre', type: 'varchar', length: 150 })
  nombre: string;

  @Column({ name: 'es_interno', type: 'boolean', default: true })
  esInterno: boolean;
}
