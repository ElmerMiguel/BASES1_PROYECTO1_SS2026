import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Hospital } from './Hospital';
import { TipoUnidad } from './TipoUnidad';

@Entity({ name: 'unidad_hospital', schema: 'hospitales_occidente' })
export class UnidadHospital {
  @PrimaryGeneratedColumn({ name: 'id_unidad_hospital', type: 'integer' })
  idUnidadHospital: number;

  @Column({ name: 'id_hospital', type: 'integer' })
  idHospital: number;

  @Column({ name: 'id_tipo_unidad', type: 'integer' })
  idTipoUnidad: number;

  @ManyToOne(() => Hospital)
  @JoinColumn({ name: 'id_hospital' })
  hospital: Hospital;

  @ManyToOne(() => TipoUnidad)
  @JoinColumn({ name: 'id_tipo_unidad' })
  tipoUnidad: TipoUnidad;
}
