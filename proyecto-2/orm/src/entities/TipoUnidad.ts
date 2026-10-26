import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity({ name: 'tipo_unidad', schema: 'hospitales_occidente' })
export class TipoUnidad {
  @PrimaryGeneratedColumn({ name: 'id_tipo_unidad', type: 'integer' })
  idTipoUnidad: number;

  @Column({ name: 'nombre', type: 'varchar', length: 50 })
  nombre: string;
}
