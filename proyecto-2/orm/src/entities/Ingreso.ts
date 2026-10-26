import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Episodio } from './Episodio';
import { UnidadHospital } from './UnidadHospital';

@Entity({ name: 'ingreso', schema: 'hospitales_occidente' })
export class Ingreso {
  @PrimaryGeneratedColumn({ name: 'id_ingreso', type: 'bigint' })
  idIngreso: string;

  @Column({ name: 'id_episodio', type: 'bigint' })
  idEpisodio: string;

  @Column({ name: 'id_unidad_hospital', type: 'integer' })
  idUnidadHospital: number;

  @Column({ name: 'fecha_hora_ingreso', type: 'timestamptz' })
  fechaHoraIngreso: Date;

  @ManyToOne(() => Episodio)
  @JoinColumn({ name: 'id_episodio' })
  episodio: Episodio;

  @ManyToOne(() => UnidadHospital)
  @JoinColumn({ name: 'id_unidad_hospital' })
  unidadHospital: UnidadHospital;
}
