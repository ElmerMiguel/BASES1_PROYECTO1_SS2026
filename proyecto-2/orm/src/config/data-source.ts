import 'reflect-metadata';
import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';
import * as path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

export const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  username: process.env.DB_USER || 'usr_auditor_occidente',
  password: process.env.DB_PASSWORD || 'AuditorPass2026!',
  database: process.env.DB_NAME || 'hospital_occidente',
  schema: process.env.DB_SCHEMA || 'hospitales_occidente',
  synchronize: false,
  logging: ['query', 'error'],
  entities: [path.join(__dirname, '../entities/*.{ts,js}')],
});
