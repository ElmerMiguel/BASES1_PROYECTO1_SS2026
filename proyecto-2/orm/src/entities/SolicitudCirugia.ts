import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Episodio } from './Episodio';

@Entity({ name: 'solicitud_cirugia', schema: 'hospitales_occidente' })
export class SolicitudCirugia {
  @PrimaryGeneratedColumn({ name: 'id_solicitud_cirugia', type: 'bigint' })
  idSolicitudCirugia: string;

  @Column({ name: 'id_episodio', type: 'bigint' })
  idEpisodio: string;

  @ManyToOne(() => Episodio)
  @JoinColumn({ name: 'id_episodio' })
  episodio: Episodio;
}
