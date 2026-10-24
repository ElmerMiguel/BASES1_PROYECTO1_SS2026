import { Entity, PrimaryGeneratedColumn, Column, OneToOne, JoinColumn } from 'typeorm';
import { SolicitudCirugia } from './SolicitudCirugia';

@Entity({ name: 'cirugia', schema: 'hospitales_occidente' })
export class Cirugia {
  @PrimaryGeneratedColumn({ name: 'id_cirugia', type: 'bigint' })
  idCirugia: string;

  @Column({ name: 'id_solicitud_cirugia', type: 'bigint', unique: true })
  idSolicitudCirugia: string;

  @Column({ name: 'inicio_programado', type: 'timestamptz' })
  inicioProgramado: Date;

  @OneToOne(() => SolicitudCirugia)
  @JoinColumn({ name: 'id_solicitud_cirugia' })
  solicitudCirugia: SolicitudCirugia;
}
