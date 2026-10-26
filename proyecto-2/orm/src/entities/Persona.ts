import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity({ name: 'persona', schema: 'hospitales_occidente' })
export class Persona {
  @PrimaryGeneratedColumn({ name: 'id_persona', type: 'integer' })
  idPersona: number;

  @Column({ name: 'nombres', type: 'varchar', length: 100 })
  nombres: string;

  @Column({ name: 'apellidos', type: 'varchar', length: 100 })
  apellidos: string;

  @Column({ name: 'dpi', type: 'varchar', length: 13, unique: true })
  dpi: string;
}
