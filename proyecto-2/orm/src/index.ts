import 'reflect-metadata';
import { AppDataSource } from './config/data-source';
import { consultarObjetivo01 } from './queries/objetivo01.service';
import { consultarObjetivo16 } from './queries/objetivo16.service';
import { consultarObjetivo18 } from './queries/objetivo18.service';

async function main() {
  console.log('================================================================');
  console.log('HOSPITALES DE OCCIDENTE - MODULO ORM (TYPEORM + TYPESCRIPT)');
  console.log('================================================================');

  try {
    await AppDataSource.initialize();
    console.log('Conexion exitosa a PostgreSQL con rol: usr_auditor_occidente');
    console.log('Esquema activo: hospitales_occidente\n');

    // 1. Objetivo 01: Top 3 Hospitales con mayor demanda
    console.log('----------------------------------------------------------------');
    console.log('OBJETIVO 01: Top 3 Hospitales con mayor demanda en Consulta Externa');
    console.log('Parametros: fechaInicio = 2026-01-01 00:00:00-06, fechaFin = 2026-12-31 23:59:59-06');
    console.log('----------------------------------------------------------------');
    const resultado01 = await consultarObjetivo01(
      AppDataSource,
      '2026-01-01 00:00:00-06',
      '2026-12-31 23:59:59-06'
    );
    console.table(resultado01);

    // 2. Objetivo 16: Cadena de supervision medica recursiva
    console.log('\n----------------------------------------------------------------');
    console.log('OBJETIVO 16: Cadena de supervision medica recursiva (Jerarquia)');
    console.log('Parametro: idMedico = 7 (Mario Alejandro Gomez Chan)');
    console.log('----------------------------------------------------------------');
    const resultado16 = await consultarObjetivo16(AppDataSource, 7);
    console.table(resultado16);

    // 3. Objetivo 18: Division relacional - Pacientes fieles (4 unidades)
    console.log('\n----------------------------------------------------------------');
    console.log('OBJETIVO 18: Division relacional - Pacientes fieles (4 unidades)');
    console.log('Parametros: fechaInicio = 2026-01-01 00:00:00-06, fechaFin = 2026-12-31 23:59:59-06');
    console.log('----------------------------------------------------------------');
    const resultado18 = await consultarObjetivo18(
      AppDataSource,
      '2026-01-01 00:00:00-06',
      '2026-12-31 23:59:59-06'
    );
    console.table(resultado18);

  } catch (error) {
    console.error('Error durante la ejecucion:', error);
  } finally {
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
      console.log('\nConexion cerrada correctamente.');
    }
  }
}

main();
