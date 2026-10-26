SET search_path TO hospitales_occidente, public;
SET timezone TO 'America/Guatemala';

BEGIN;


-- 1. PERSONAS NUEVAS (ID 41 AL 75)

INSERT INTO persona (id_persona, nombres, apellidos, dpi, fecha_nacimiento, sexo, telefono, id_direccion) VALUES
    -- Medicos adicionales (IDs 41 al 50)
    (41, 'Gustavo Adolfo', 'Perez Monzon', '2154879650901', '1981-05-12', 'Masculino', '77612241', 8),
    (42, 'Laura Beatriz', 'Castillo Reyes', '2365412780901', '1985-09-20', 'Femenino', '77612242', 9),
    (43, 'Ricardo Antonio', 'Lopez Estrada', '2489632540901', '1983-11-15', 'Masculino', '77612243', 10),
    (44, 'Patricia Eugenia', 'Mendez Soto', '2589631470901', '1989-02-28', 'Femenino', '77612244', 11),
    (45, 'Fernando Jose', 'Morales Paz', '2698745120901', '1990-07-14', 'Masculino', '77612245', 12),
    (46, 'Sofia Alejandra', 'Guzman Cabrera', '2789654130801', '1987-12-03', 'Femenino', '77612246', 15),
    (47, 'Oscar Rene', 'Barillas Ruiz', '2896541280801', '1992-04-18', 'Masculino', '77612247', 16),
    (48, 'Claudia Marcela', 'Herrera Rios', '1987542311201', '1979-08-22', 'Femenino', '77612248', 19),
    (49, 'Julio Cesar', 'Sandoval Mejia', '2258963411201', '1984-01-30', 'Masculino', '77612249', 20),
    (50, 'Monica Rocio', 'Navarro Fuentes', '2987456121201', '1993-06-11', 'Femenino', '77612250', 21),

    -- Enfermeros adicionales (IDs 51 al 60)
    (51, 'Karla Maria', 'Aguilar Santos', '3014589620901', '1991-03-14', 'Femenino', '77623351', 13),
    (52, 'Brenda Leticia', 'Orozco Lima', '3125489610901', '1994-10-25', 'Femenino', '77623352', 14),
    (53, 'Edgar Rolando', 'Chavez Ramos', '3258964110901', '1988-06-19', 'Masculino', '77623353', 8),
    (54, 'Silvia Lorena', 'Cifuentes Cano', '3369854120901', '1993-12-05', 'Femenino', '77623354', 9),
    (55, 'Hugo Leonel', 'Molina Prado', '3487541230901', '1986-04-17', 'Masculino', '77623355', 10),
    (56, 'Glendy Paola', 'Reyes Alonzo', '3598741250801', '1995-08-09', 'Femenino', '77623356', 17),
    (57, 'Marcos Vinicio', 'Cabrera Solis', '3654128960801', '1990-01-23', 'Masculino', '77623357', 18),
    (58, 'Vilma Elizabeth', 'Godinez Lara', '3789654121201', '1992-07-31', 'Femenino', '77623358', 22),
    (59, 'Jorge Mario', 'Valenzuela Paz', '3896541231201', '1989-11-12', 'Masculino', '77623359', 23),
    (60, 'Sonia Raquel', 'Pineda Cruz', '3987456321201', '1996-05-27', 'Femenino', '77623360', 24),

    -- Pacientes nuevos (IDs 61 al 75)
    (61, 'Josue Daniel', 'Cifuentes Sac', '4012589630901', '1980-02-14', 'Masculino', '55112261', 25),
    (62, 'Miriam Elizabeth', 'Morales Pop', '4123698540901', '1975-07-19', 'Femenino', '55112262', 26),
    (63, 'Cesar Augusto', 'Gomez Chaj', '4234589650901', '1992-11-03', 'Masculino', '55112263', 27),
    (64, 'Gladys Noemi', 'Tzun Alvarez', '4345698740901', '1988-04-26', 'Femenino', '55112264', 28),
    (65, 'Ramiro Estuardo', 'Ixcoy Vasquez', '4456789650901', '1968-09-15', 'Masculino', '55112265', 29),
    (66, 'Ingrid Marleny', 'Quiej Gomez', '4567891230801', '1995-12-30', 'Femenino', '55112266', 15),
    (67, 'Hector Manuel', 'Yax Hernandez', '4678912340801', '1973-03-08', 'Masculino', '55112267', 16),
    (68, 'Debora Raquel', 'Chuc Batres', '4789123450801', '2001-08-21', 'Femenino', '55112268', 17),
    (69, 'Alvaro Enrique', 'Macario Castillo', '4891234560801', '1983-05-17', 'Masculino', '55112269', 18),
    (70, 'Marta Lidia', 'Fuentes Sop', '4912345671201', '1965-10-10', 'Femenino', '55112270', 19),
    (71, 'Wilson Rene', 'Ovalle Lopez', '5012345681201', '1997-01-05', 'Masculino', '55112271', 20),
    (72, 'Wendy Johana', 'Barrios Chan', '5123456791201', '1999-06-22', 'Femenino', '55112272', 21),
    (73, 'Guillermo Alfonso', 'Coj Tzun', '5234567810101', '1970-12-18', 'Masculino', '55112273', 30),
    (74, 'Evelyn Roxana', 'Estrada Pop', '5345678920101', '1986-07-04', 'Femenino', '55112274', 31),
    (75, 'Byron Alexander', 'Ajpop Coj', '5456789130101', '1991-09-29', 'Masculino', '55112275', 32)
ON CONFLICT (id_persona) DO NOTHING;



-- 2. PACIENTES NUEVOS (ID 9 AL 23)

INSERT INTO paciente (id_paciente, id_persona, no_expediente, estado_civil, no_seguro_social, religion, ocupacion, id_municipio_nacimiento) VALUES
    (9, 61, 'EXP-2026-009', 'Casado', 'IGSS-4012589', 'Catolica', 'Comerciante', 1),
    (10, 62, 'EXP-2026-010', 'Casado', 'IGSS-4123698', 'Evangelica', 'Maestra', 1),
    (11, 63, 'EXP-2026-011', 'Soltero', 'IGSS-4234589', 'Catolica', 'Perito Contador', 1),
    (12, 64, 'EXP-2026-012', 'Casado', 'IGSS-4345698', 'Evangelica', 'Secretaria', 1),
    (13, 65, 'EXP-2026-013', 'Casado', 'IGSS-4456789', 'Catolica', 'Agricultor', 1),
    (14, 66, 'EXP-2026-014', 'Soltero', NULL, 'Catolica', 'Estudiante', 2),
    (15, 67, 'EXP-2026-015', 'Casado', 'IGSS-4678912', 'Evangelica', 'Transportista', 2),
    (16, 68, 'EXP-2026-016', 'Soltero', NULL, 'Catolica', 'Estudiante', 2),
    (17, 69, 'EXP-2026-017', 'Union de hecho', 'IGSS-4891234', 'Evangelica', 'Mecanico', 2),
    (18, 70, 'EXP-2026-018', 'Viudo', 'IGSS-4912345', 'Catolica', 'Ama de casa', 3),
    (19, 71, 'EXP-2026-019', 'Soltero', 'IGSS-5012345', 'Evangelica', 'Albañil', 3),
    (20, 72, 'EXP-2026-020', 'Soltero', NULL, 'Catolica', 'Perito Administracion', 3),
    (21, 73, 'EXP-2026-021', 'Casado', 'IGSS-5234567', 'Catolica', 'Comerciante', 4),
    (22, 74, 'EXP-2026-022', 'Casado', 'IGSS-5345678', 'Evangelica', 'Enfermera auxiliar', 4),
    (23, 75, 'EXP-2026-023', 'Soltero', 'IGSS-5456789', 'Catolica', 'Chofer profesional', 4)
ON CONFLICT (id_paciente) DO NOTHING;



-- 3. PERSONAL ADICIONAL (MEDICOS Y ENFERMEROS, ID 41 AL 60)

INSERT INTO personal (id_personal, id_persona, tipo_personal, activo, fecha_contratacion, salario) VALUES
    -- Medicos
    (41, 41, 'Medico', True, '2024-02-01', 16000.00),
    (42, 42, 'Medico', True, '2024-03-15', 13500.00),
    (43, 43, 'Medico', True, '2024-05-01', 13000.00),
    (44, 44, 'Medico', True, '2025-01-10', 11500.00),
    (45, 45, 'Medico', True, '2025-02-01', 11000.00),
    (46, 46, 'Medico', True, '2024-06-01', 13500.00),
    (47, 47, 'Medico', True, '2025-03-15', 11000.00),
    (48, 48, 'Medico', True, '2023-11-01', 22000.00),
    (49, 49, 'Medico', True, '2024-04-10', 15500.00),
    (50, 50, 'Medico', True, '2025-06-01', 10500.00),

    -- Enfermeros
    (51, 51, 'Enfermero', True, '2024-01-15', 7500.00),
    (52, 52, 'Enfermero', True, '2024-03-01', 6800.00),
    (53, 53, 'Enfermero', True, '2023-08-15', 7200.00),
    (54, 54, 'Enfermero', True, '2024-07-01', 7800.00),
    (55, 55, 'Enfermero', True, '2023-10-01', 8200.00),
    (56, 56, 'Enfermero', True, '2025-01-15', 6500.00),
    (57, 57, 'Enfermero', True, '2024-05-20', 7000.00),
    (58, 58, 'Enfermero', True, '2024-02-10', 7300.00),
    (59, 59, 'Enfermero', True, '2023-12-01', 6900.00),
    (60, 60, 'Enfermero', True, '2025-04-01', 6500.00)
ON CONFLICT (id_personal) DO NOTHING;



-- 4. SUBTIPO ENFERMERO (REGISTROS ADICIONALES 51 AL 60)

INSERT INTO enfermero (id_personal, no_licencia, grado_academico, area_asignada) VALUES
    (51, 'LIC-ENF-0051', 'Licenciado', 'Consulta Externa'),
    (52, 'TEC-ENF-0052', 'Tecnico', 'Emergencias'),
    (53, 'LIC-ENF-0053', 'Licenciado', 'Quirofano'),
    (54, 'MAG-ENF-0054', 'Magister', 'Hospitalizacion'),
    (55, 'LIC-ENF-0055', 'Licenciado', 'Emergencias'),
    (56, 'AUX-ENF-0056', 'Auxiliar', 'Consulta Externa'),
    (57, 'TEC-ENF-0057', 'Tecnico', 'Hospitalizacion'),
    (58, 'LIC-ENF-0058', 'Licenciado', 'Recuperacion'),
    (59, 'TEC-ENF-0059', 'Tecnico', 'Emergencias'),
    (60, 'AUX-ENF-0060', 'Auxiliar', 'Hospitalizacion')
ON CONFLICT (id_personal) DO NOTHING;



-- 5. SUBTIPO MEDICO (REGISTROS ADICIONALES 41 AL 50)

INSERT INTO medico (id_personal, no_colegiado, condicion, institucion_origen, tarifa_consulta, id_superior, nivel_acceso) VALUES
    (41, 'COL-17100', 'Planta', NULL, 300.00, NULL, 'Jefe de Servicio'),
    (42, 'COL-18250', 'Planta', NULL, 275.00, NULL, 'Jefe de Guardia'),
    (43, 'COL-19300', 'Planta', NULL, 250.00, NULL, 'Jefe de Guardia'),
    (44, 'COL-20400', 'Residente', NULL, 200.00, NULL, 'Medico Asistencial'),
    (45, 'COL-21500', 'Residente', NULL, 200.00, NULL, 'Medico Asistencial'),
    (46, 'COL-18900', 'Planta', NULL, 275.00, NULL, 'Jefe de Guardia'),
    (47, 'COL-22100', 'Residente', NULL, 200.00, NULL, 'Medico Asistencial'),
    (48, 'COL-10500', 'Planta', NULL, 350.00, NULL, 'Director Medico'),
    (49, 'COL-16800', 'Planta', NULL, 300.00, NULL, 'Jefe de Servicio'),
    (50, 'COL-23200', 'Residente', NULL, 200.00, NULL, 'Medico Asistencial')
ON CONFLICT (id_personal) DO NOTHING;



-- 6. ASIGNACION DE ESPECIALIDADES PARA MEDICOS ADICIONALES

INSERT INTO medico_especialidad (id_medico, id_especialidad, es_principal) VALUES
    (41, 1, True),   -- Cardiologia
    (42, 7, True),   -- Medicina General
    (43, 2, True),   -- Dermatologia
    (44, 7, True),   -- Medicina General
    (45, 10, True),  -- Oftalmologia
    (46, 7, True),   -- Medicina General
    (47, 7, True),   -- Medicina General
    (48, 1, True),   -- Cardiologia
    (49, 4, True),   -- Ginecologia Oncologica
    (50, 7, True)    -- Medicina General
ON CONFLICT (id_medico, id_especialidad) DO NOTHING;



-- 7. CONFIGURACION DE LA CADENA JERARQUICA DE 4 NIVELES (OBJETIVO 16 Y 17)

-- HOSPITAL 1: Los Altos
UPDATE medico SET nivel_acceso = 'Director Medico', id_superior = NULL WHERE id_personal = 1;
UPDATE medico SET nivel_acceso = 'Jefe de Servicio', id_superior = 1 WHERE id_personal IN (2, 3);
UPDATE medico SET nivel_acceso = 'Jefe de Guardia', id_superior = 2 WHERE id_personal IN (4, 5);
UPDATE medico SET nivel_acceso = 'Jefe de Guardia', id_superior = 3 WHERE id_personal = 6;
UPDATE medico SET nivel_acceso = 'Medico Asistencial', id_superior = 4 WHERE id_personal IN (7, 8);
UPDATE medico SET nivel_acceso = 'Medico Asistencial', id_superior = 5 WHERE id_personal = 9;
UPDATE medico SET nivel_acceso = 'Medico Asistencial', id_superior = 6 WHERE id_personal = 10;

-- HOSPITAL 2: San Juan de Occidente
UPDATE medico SET nivel_acceso = 'Director Medico', id_superior = NULL WHERE id_personal = 11;
UPDATE medico SET nivel_acceso = 'Jefe de Servicio', id_superior = 11 WHERE id_personal IN (12, 41);
UPDATE medico SET nivel_acceso = 'Jefe de Guardia', id_superior = 12 WHERE id_personal = 42;
UPDATE medico SET nivel_acceso = 'Jefe de Guardia', id_superior = 41 WHERE id_personal = 43;
UPDATE medico SET nivel_acceso = 'Medico Asistencial', id_superior = 42 WHERE id_personal = 44;
UPDATE medico SET nivel_acceso = 'Medico Asistencial', id_superior = 43 WHERE id_personal = 45;

-- HOSPITAL 3: Totonicapan
UPDATE medico SET nivel_acceso = 'Director Medico', id_superior = NULL WHERE id_personal = 13;
UPDATE medico SET nivel_acceso = 'Jefe de Servicio', id_superior = 13 WHERE id_personal = 14;
UPDATE medico SET nivel_acceso = 'Jefe de Guardia', id_superior = 14 WHERE id_personal = 46;
UPDATE medico SET nivel_acceso = 'Medico Asistencial', id_superior = 46 WHERE id_personal = 47;

-- HOSPITAL 4: San Marcos
UPDATE medico SET nivel_acceso = 'Director Medico', id_superior = NULL WHERE id_personal = 48;
UPDATE medico SET nivel_acceso = 'Jefe de Servicio', id_superior = 48 WHERE id_personal = 49;
UPDATE medico SET nivel_acceso = 'Medico Asistencial', id_superior = 49 WHERE id_personal = 50;



-- 8. ASIGNACION DE PERSONAL A UNIDADES HOSPITALARIAS Y TURNOS

INSERT INTO asignacion_personal (id_asignacion, id_personal, id_unidad_hospital, id_turno, fecha_inicio, fecha_fin) VALUES
    -- Hospital 1
    (20, 10, 2, 1, '2026-01-01', NULL),
    (21, 9, 2, 2, '2026-01-01', NULL),
    (22, 51, 1, 1, '2026-01-01', NULL),
    (23, 52, 2, 2, '2026-01-01', NULL),
    (24, 53, 3, 1, '2026-01-01', NULL),
    (25, 54, 4, 1, '2026-01-01', NULL),

    -- Hospital 2
    (26, 11, 5, 1, '2026-01-01', NULL),
    (27, 12, 6, 2, '2026-01-01', NULL),
    (28, 41, 7, 1, '2026-01-01', NULL),
    (29, 42, 6, 1, '2026-01-01', NULL),
    (30, 43, 5, 2, '2026-01-01', NULL),
    (31, 44, 6, 2, '2026-01-01', NULL),
    (32, 45, 5, 1, '2026-01-01', NULL),
    (33, 55, 6, 1, '2026-01-01', NULL),
    (34, 56, 5, 1, '2026-01-01', NULL),

    -- Hospital 3
    (35, 13, 9, 1, '2026-01-01', NULL),
    (36, 14, 10, 2, '2026-01-01', NULL),
    (37, 46, 10, 1, '2026-01-01', NULL),
    (38, 47, 9, 2, '2026-01-01', NULL),
    (39, 57, 12, 1, '2026-01-01', NULL),
    (40, 58, 11, 1, '2026-01-01', NULL),

    -- Hospital 4
    (41, 48, 13, 1, '2026-01-01', NULL),
    (42, 49, 14, 1, '2026-01-01', NULL),
    (43, 50, 13, 2, '2026-01-01', NULL),
    (44, 59, 14, 2, '2026-01-01', NULL),
    (45, 60, 16, 1, '2026-01-01', NULL)
ON CONFLICT (id_asignacion) DO NOTHING;



-- 9. EPISODIOS ASISTENCIALES ADICIONALES (ID 9 AL 30)

INSERT INTO episodio (id_episodio, id_paciente, id_hospital, fecha_apertura, fecha_cierre) VALUES
    -- Paciente 1 (Fiel: 4 unidades en Hospital 1)
    (9, 1, 1, '2026-02-01 08:00:00-06', '2026-02-01 12:00:00-06'),   -- Consulta Externa
    (10, 1, 1, '2026-03-10 14:30:00-06', '2026-03-10 20:00:00-06'),  -- Emergencias
    (11, 1, 1, '2026-04-05 07:00:00-06', '2026-04-05 18:00:00-06'),  -- Cirugia
    (12, 1, 1, '2026-05-12 09:00:00-06', '2026-05-16 11:00:00-06'),  -- Hospitalizacion

    -- Paciente 2 (Fiel: 4 unidades en Hospital 1)
    (13, 2, 1, '2026-02-15 09:30:00-06', '2026-02-15 13:00:00-06'),  -- Consulta Externa
    (14, 2, 1, '2026-03-22 18:00:00-06', '2026-03-23 06:00:00-06'),  -- Emergencias
    (15, 2, 1, '2026-04-18 06:30:00-06', '2026-04-18 16:00:00-06'),  -- Cirugia
    (16, 2, 1, '2026-06-01 10:00:00-06', '2026-06-05 14:00:00-06'),  -- Hospitalizacion

    -- Paciente 9 (Fiel: 4 unidades en Hospital 2)
    (17, 9, 2, '2026-02-10 08:30:00-06', '2026-02-10 11:30:00-06'),  -- Consulta Externa
    (18, 9, 2, '2026-03-14 21:00:00-06', '2026-03-15 08:00:00-06'),  -- Emergencias
    (19, 9, 2, '2026-05-20 07:00:00-06', '2026-05-20 17:00:00-06'),  -- Cirugia
    (20, 9, 2, '2026-06-15 11:00:00-06', '2026-06-19 12:00:00-06'),  -- Hospitalizacion

    -- Pacientes con atenciones parciales (1 a 3 unidades)
    (21, 10, 1, '2026-03-01 08:00:00-06', '2026-03-01 11:00:00-06'), -- Solo Consulta
    (22, 11, 1, '2026-03-05 19:00:00-06', '2026-03-06 02:00:00-06'), -- Solo Emergencias
    (23, 12, 2, '2026-04-10 07:30:00-06', '2026-04-10 14:00:00-06'), -- Consulta y Cirugia
    (24, 12, 2, '2026-04-25 08:00:00-06', '2026-04-25 12:00:00-06'),
    (25, 13, 3, '2026-05-02 08:00:00-06', '2026-05-02 11:00:00-06'), -- Hospital 3 Consulta
    (26, 14, 3, '2026-05-18 20:00:00-06', '2026-05-19 07:00:00-06'), -- Hospital 3 Emergencias
    (27, 15, 3, '2026-06-10 09:00:00-06', '2026-06-15 10:00:00-06'), -- Hospital 3 Hosp
    (28, 16, 4, '2026-06-01 08:30:00-06', '2026-06-01 11:30:00-06'), -- Hospital 4 Consulta
    (29, 17, 4, '2026-06-20 22:00:00-06', '2026-06-21 06:00:00-06'), -- Hospital 4 Emergencias
    (30, 18, 4, '2026-07-05 10:00:00-06', '2026-07-10 14:00:00-06')  -- Hospital 4 Hosp
ON CONFLICT (id_episodio) DO NOTHING;



-- 10. CITAS Y CONSULTAS EXTERNAS (PARA OBJETIVOS 1, 2, 13, 18)

INSERT INTO cita (id_cita, id_paciente, id_medico, id_clinica, fecha_hora, canal_asignacion, tipo_consulta, id_hospital_referente, estado, fecha_cancelacion, motivo_cancelacion, cancelacion_notificada, id_cita_anterior, id_cita_recargo_origen) VALUES
    -- Citas realizadas Hospital 1
    (10, 1, 7, 1, '2026-02-01 08:30:00-06', 'Recepcion general', 'Primera vez', NULL, 'Realizada', NULL, NULL, NULL, NULL, NULL),
    (11, 2, 8, 2, '2026-02-15 10:00:00-06', 'Telefono', 'Primera vez', NULL, 'Realizada', NULL, NULL, NULL, NULL, NULL),
    (12, 10, 7, 1, '2026-03-01 08:30:00-06', 'Telefono', 'Primera vez', NULL, 'Realizada', NULL, NULL, NULL, NULL, NULL),
    (13, 11, 8, 2, '2026-03-15 09:00:00-06', 'Recepcion general', 'Primera vez', NULL, 'Programada', NULL, NULL, NULL, NULL, NULL),
    (14, 12, 7, 1, '2026-03-20 11:00:00-06', 'Correo institucional', 'Reconsulta', NULL, 'Cancelada', '2026-03-19 14:00:00-06', 'Paciente no puede presentarse', True, NULL, NULL),

    -- Citas realizadas Hospital 2
    (15, 9, 42, 3, '2026-02-10 09:00:00-06', 'Recepcion general', 'Primera vez', NULL, 'Realizada', NULL, NULL, NULL, NULL, NULL),
    (16, 12, 44, 4, '2026-04-10 08:00:00-06', 'Telefono', 'Primera vez', NULL, 'Realizada', NULL, NULL, NULL, NULL, NULL),
    (17, 13, 42, 3, '2026-04-15 10:30:00-06', 'Recepcion general', 'Primera vez', NULL, 'Programada', NULL, NULL, NULL, NULL, NULL),

    -- Citas realizadas Hospital 3
    (18, 13, 46, 5, '2026-05-02 08:30:00-06', 'Recepcion general', 'Primera vez', NULL, 'Realizada', NULL, NULL, NULL, NULL, NULL),
    (19, 14, 47, 5, '2026-05-10 09:00:00-06', 'Telefono', 'Primera vez', NULL, 'Programada', NULL, NULL, NULL, NULL, NULL),

    -- Citas realizadas Hospital 4
    (20, 16, 49, 7, '2026-06-01 09:00:00-06', 'Recepcion general', 'Primera vez', NULL, 'Realizada', NULL, NULL, NULL, NULL, NULL),
    (21, 17, 50, 7, '2026-06-15 10:00:00-06', 'Telefono', 'Primera vez', NULL, 'Programada', NULL, NULL, NULL, NULL, NULL)
ON CONFLICT (id_cita) DO NOTHING;

INSERT INTO consulta (id_consulta, id_cita, id_episodio, fecha_hora, id_diagnostico, otros_datos_interes, notas_observaciones) VALUES
    (10, 10, 9, '2026-02-01 09:00:00-06', 7, 'Evaluacion general rutinaria', 'Paciente refiere dolor abdominal leve'),
    (11, 11, 13, '2026-02-15 10:30:00-06', 1, 'Control cardiovascular', 'Hipertension arterial grado 1'),
    (12, 12, 21, '2026-03-01 09:00:00-06', 7, 'Evaluacion general', 'Paciente estable'),
    (13, 15, 17, '2026-02-10 09:30:00-06', 7, 'Evaluacion de primera vez', 'Se indican estudios complementarios'),
    (14, 16, 23, '2026-04-10 08:30:00-06', 1, 'Control cardiologico', 'Plan de seguimiento ambulatorio'),
    (15, 18, 25, '2026-05-02 09:00:00-06', 7, 'Chequeo ambulatorio', 'Paciente sin complicaciones agudas'),
    (16, 20, 28, '2026-06-01 09:30:00-06', 4, 'Control ginecologico', 'Evolucion adecuada')
ON CONFLICT (id_consulta) DO NOTHING;

-- Recetas con proximas citas programadas (para demanda en Obj 1)
INSERT INTO receta (id_receta, id_consulta, fecha_emision, id_cita_proxima, orientacion_paciente) VALUES
    (10, 10, '2026-02-01', 13, 'Tomar medicamentos segun horario indicado'),
    (11, 11, '2026-02-15', 17, 'Dieta baja en sodio y control de presion arterial'),
    (12, 13, '2026-02-10', 19, 'Reposo relativo y abundante hidratacion'),
    (13, 15, '2026-05-02', 21, 'Continuar con tratamiento prescrito')
ON CONFLICT (id_receta) DO NOTHING;



-- 11. INGRESOS Y EGRESOS (EMERGENCIAS Y HOSPITALIZACION)

INSERT INTO ingreso (id_ingreso, id_episodio, id_unidad_hospital, id_servicio, fecha_hora_ingreso, motivo_ingreso, id_diagnostico_presuntivo, id_medico, id_espacio, id_paciente_encargado, estado_actual_paciente, prioridad_triage, dias_estimados_estancia) VALUES
    -- Emergencias Hospital 1
    (10, 10, 2, 2, '2026-03-10 14:30:00-06', 'Dolor precordial agudo de inicio subito', 1, 6, 5, 1, 'Paciente consciente orientado con dolor toracico', 2, 1),
    (11, 14, 2, 2, '2026-03-22 18:00:00-06', 'Trauma en miembro inferior por caida', 7, 6, 6, 2, 'Dolor intenso con limitacion funcional', 3, 1),
    (12, 22, 2, 2, '2026-03-05 19:00:00-06', 'Dificultad respiratoria moderada', 7, 10, 7, 3, 'Taquipneico en observacion de emergencia', 2, 1),

    -- Hospitalizacion Hospital 1
    (13, 12, 4, 4, '2026-05-12 09:00:00-06', 'Ingreso para manejo postquirurgico y recuperacion', 1, 4, 10, 1, 'Estable afebril tolerando via oral', 4, 4),
    (14, 16, 4, 4, '2026-06-01 10:00:00-06', 'Ingreso para monitoreo cardiovascular continuo', 1, 5, 11, 2, 'Hemodinamicamente estable en cama asignada', 4, 5),

    -- Emergencias Hospital 2
    (15, 18, 6, 6, '2026-03-14 21:00:00-06', 'Sindrome febril agudo y deshidratacion', 7, 42, 19, 1, 'Febril deshidratado en sala de choque', 2, 1),

    -- Hospitalizacion Hospital 2
    (16, 20, 8, 8, '2026-06-15 11:00:00-06', 'Internamiento para tratamiento intravenoso', 1, 41, 12, 1, 'Evolucion favorable con tratamiento', 4, 4),

    -- Emergencias Hospital 3
    (17, 26, 10, 10, '2026-05-18 20:00:00-06', 'Cefalea intensa refractaria a analgesicos', 7, 46, 20, 1, 'Paciente orientado en camilla de observacion', 3, 1),

    -- Hospitalizacion Hospital 3
    (18, 27, 12, 12, '2026-06-10 09:00:00-06', 'Internamiento para observacion medica', 7, 46, 25, 1, 'Estable bajo cuidado de enfermeria', 4, 5),

    -- Emergencias Hospital 4
    (19, 29, 14, 14, '2026-06-20 22:00:00-06', 'Dolor abdominal severo en fosa iliaca', 7, 49, 21, 1, 'En evaluacion diagnostica', 2, 1),

    -- Hospitalizacion Hospital 4
    (20, 30, 16, 16, '2026-07-05 10:00:00-06', 'Recuperacion medica de proceso infeccioso', 7, 49, 26, 1, 'Mejoria clinica notable', 4, 5)
ON CONFLICT (id_ingreso) DO NOTHING;

-- Egresos (incluyendo vivos con consentimiento para Obj 3 y fecha pico decesos para Obj 10)
INSERT INTO egreso (id_egreso, id_ingreso, fecha_hora_egreso, id_diagnostico_principal, motivo_egreso, id_medico, codigo_egreso, egreso_sin_consentimiento, motivo_sin_consentimiento, id_traslado, id_hospital_referido) VALUES
    -- Egresos vivos con consentimiento (Obj 3)
    (10, 10, '2026-03-10 20:00:00-06', 1, 'Mejoria clinica evidente dolor controlado', 6, 'Vivo', False, NULL, NULL, NULL),
    (11, 11, '2026-03-23 06:00:00-06', 7, 'Inmovilizacion satisfactoria sin compromiso vascular', 6, 'Vivo', False, NULL, NULL, NULL),
    (12, 13, '2026-05-16 11:00:00-06', 1, 'Alta por completar ciclo de recuperacion hospitalaria', 4, 'Vivo', False, NULL, NULL, NULL),
    (13, 14, '2026-06-05 14:00:00-06', 1, 'Monitoreo completado sin arritmias detectadas', 5, 'Vivo', False, NULL, NULL, NULL),
    (14, 15, '2026-03-15 08:00:00-06', 7, 'Hidratacion adecuada euglicemico', 42, 'Vivo', False, NULL, NULL, NULL),
    (15, 16, '2026-06-19 12:00:00-06', 1, 'Tratamiento antibiotico concluido exitosamente', 41, 'Vivo', False, NULL, NULL, NULL),
    (16, 17, '2026-05-19 07:00:00-06', 7, 'Cefalea resuelta signos vitales estables', 46, 'Vivo', False, NULL, NULL, NULL),
    (17, 18, '2026-06-15 10:00:00-06', 7, 'Alta medica por buena evolucion', 46, 'Vivo', False, NULL, NULL, NULL),
    (18, 20, '2026-07-10 14:00:00-06', 7, 'Alta medica con cita de control', 49, 'Vivo', False, NULL, NULL, NULL),

    -- Casos de deceso concentrados en fecha pico 2026-08-15 (Obj 10)
    (19, 12, '2026-08-15 16:30:00-06', 1, 'Paro cardiorrespiratorio no refractario a maniobras', 10, 'Muerto', False, NULL, NULL, NULL),
    (20, 19, '2026-08-15 23:45:00-06', 7, 'Falla multiorganica aguda en choque septico', 49, 'Muerto', False, NULL, NULL, NULL)
ON CONFLICT (id_egreso) DO NOTHING;



-- 12. HISTORIAS CLINICAS, SOLICITUDES Y CIRUGIAS (OBJETIVOS 5, 6, 18)

INSERT INTO historia_clinica (id_historia_clinica, id_episodio, id_medico, fecha_hora, tipo_interrogatorio, informante, padecimiento_actual) VALUES
    (10, 11, 2, '2026-04-05 07:30:00-06', 'Directo', NULL, 'Paciente evaluado para intervencion quirurgica programada'),
    (11, 15, 2, '2026-04-18 07:00:00-06', 'Directo', NULL, 'Cuadro clinico estable para resolucion quirurgica electiva'),
    (12, 19, 41, '2026-05-20 07:30:00-06', 'Directo', NULL, 'Evaluacion preoperatoria completa para procedimiento')
ON CONFLICT (id_historia_clinica) DO NOTHING;

-- Solicitudes de cirugia
INSERT INTO solicitud_cirugia (id_solicitud_cirugia, id_episodio, id_historia_clinica, id_cirujano, caracter, id_tipo_anestesia, tiempo_estimado_min, fecha_hora_solicitud) VALUES
    (10, 11, 10, 2, 'Programado', 1, 120, '2026-04-05 08:00:00-06'),
    (11, 15, 11, 2, 'Programado', 1, 90, '2026-04-18 07:30:00-06'),
    (12, 19, 12, 41, 'Programado', 1, 110, '2026-05-20 08:00:00-06')
ON CONFLICT (id_solicitud_cirugia) DO NOTHING;

-- Revisiones de comite (aprobadas para cirujano eficiente Obj 5)
INSERT INTO revision_solicitud (id_revision, id_solicitud_cirugia, decision, fecha_hora, razones) VALUES
    (10, 10, 'Aprobada', '2026-04-05 08:30:00-06', 'Paciente apto con riesgo quirurgico controlado'),
    (11, 11, 'Aprobada', '2026-04-18 08:00:00-06', 'Procedimiento electivo con valoracion preanestesica lista'),
    (12, 12, 'Aprobada', '2026-05-20 08:30:00-06', 'Comite otorga autorizacion unanime')
ON CONFLICT (id_revision) DO NOTHING;

-- Procedimientos quirúrgicos solicitados
INSERT INTO solicitud_procedimiento (id_solicitud_cirugia, id_procedimiento) VALUES
    (10, 1),
    (11, 1),
    (12, 1)
ON CONFLICT (id_solicitud_cirugia, id_procedimiento) DO NOTHING;

-- Insumos, instrumental y equipos con cantidades optimas (menor cantidad para Obj 5)
INSERT INTO solicitud_insumo (id_solicitud_cirugia, id_insumo, cantidad) VALUES
    (10, 1, 2),
    (10, 2, 1),
    (11, 1, 2),
    (11, 2, 1),
    (12, 1, 3),
    (12, 2, 2)
ON CONFLICT (id_solicitud_cirugia, id_insumo) DO NOTHING;

INSERT INTO solicitud_instrumento (id_solicitud_cirugia, id_instrumento, cantidad) VALUES
    (10, 1, 2),
    (11, 1, 2),
    (12, 1, 3)
ON CONFLICT (id_solicitud_cirugia, id_instrumento) DO NOTHING;

INSERT INTO solicitud_equipo (id_solicitud_cirugia, id_equipo, cantidad) VALUES
    (10, 1, 1),
    (11, 1, 1),
    (12, 1, 2)
ON CONFLICT (id_solicitud_cirugia, id_equipo) DO NOTHING;

-- Cirugias finalizadas sin complicaciones (para Obj 6)
INSERT INTO cirugia (id_cirugia, id_solicitud_cirugia, id_quirofano, inicio_programado, fin_programado, inicio_real, fin_real, estado, id_ingreso, condicion_evolucion) VALUES
    (10, 10, 1, '2026-04-05 09:00:00-06', '2026-04-05 11:00:00-06', '2026-04-05 09:15:00-06', '2026-04-05 10:55:00-06', 'Finalizada', 10, 'Sin complicaciones'),
    (11, 11, 2, '2026-04-18 08:30:00-06', '2026-04-18 10:00:00-06', '2026-04-18 08:40:00-06', '2026-04-18 09:50:00-06', 'Finalizada', 11, 'Sin complicaciones'),
    (12, 12, 15, '2026-05-20 09:00:00-06', '2026-05-20 11:00:00-06', '2026-05-20 09:10:00-06', '2026-05-20 10:45:00-06', 'Finalizada', 15, 'Sin complicaciones')
ON CONFLICT (id_cirugia) DO NOTHING;

-- Verificaciones quirurgicas en estado Exito (Obj 6)
INSERT INTO cirugia_verificacion (id_verificacion, id_cirugia, id_item, resultado, detalle, fecha_hora_registro, id_enfermero) VALUES
    (50, 10, 1, 'Exito', 'Checklist intraoperatorio verificado', '2026-04-05 09:30:00-06', 15),
    (51, 10, 2, 'Exito', 'Instrumental completo al cierre', '2026-04-05 10:45:00-06', 15),
    (52, 11, 1, 'Exito', 'Pausa quirurgica y conteo conforme', '2026-04-18 08:50:00-06', 16),
    (53, 11, 2, 'Exito', 'Sin complicaciones en monitoreo anestesico', '2026-04-18 09:40:00-06', 16),
    (54, 12, 1, 'Exito', 'Pausa de seguridad aprobada', '2026-05-20 09:20:00-06', 53),
    (55, 12, 2, 'Exito', 'Conteo de gasas e instrumental exacto', '2026-05-20 10:35:00-06', 53)
ON CONFLICT (id_verificacion) DO NOTHING;



-- 13. FACTURACION, PAGOS Y METODOS (OBJETIVOS 6, 7, 8, 9, 11, 14)

INSERT INTO factura (id_factura, serie, numero_factura, id_episodio, fecha_emision, nit_cliente, nombre_cliente, descripcion, numero_cuotas, id_personal_emite, estado) VALUES
    (10, 'A', 'FAC-2026-010', 9, '2026-02-01 11:30:00-06', 'CF', 'Josue Cifuentes', 'Atencion de consulta externa general', 1, 25, 'Emitida'),
    (11, 'A', 'FAC-2026-011', 10, '2026-03-10 19:30:00-06', 'CF', 'Josue Cifuentes', 'Atencion de urgencia y estabilizacion', 3, 25, 'Emitida'),
    (12, 'A', 'FAC-2026-012', 11, '2026-04-05 17:30:00-06', 'CF', 'Josue Cifuentes', 'Procedimiento quirurgico y quirofano', 6, 25, 'Emitida'),
    (13, 'A', 'FAC-2026-013', 12, '2026-05-16 10:30:00-06', 'CF', 'Josue Cifuentes', 'Hospitalizacion por 4 dias', 4, 25, 'Emitida'),
    (14, 'A', 'FAC-2026-014', 13, '2026-02-15 12:30:00-06', 'CF', 'Miriam Morales', 'Atencion consulta especializada', 1, 25, 'Emitida'),
    (15, 'A', 'FAC-2026-015', 14, '2026-03-23 05:30:00-06', 'CF', 'Miriam Morales', 'Manejo de emergencia traumatologica', 2, 25, 'Emitida'),
    (16, 'A', 'FAC-2026-016', 15, '2026-04-18 15:30:00-06', 'CF', 'Miriam Morales', 'Intervencion quirurgica programada', 5, 25, 'Emitida'),
    (17, 'A', 'FAC-2026-017', 16, '2026-06-05 13:30:00-06', 'CF', 'Miriam Morales', 'Internamiento hospitalario 5 dias', 6, 25, 'Emitida'),
    (18, 'A', 'FAC-2026-018', 17, '2026-02-10 11:00:00-06', 'CF', 'Cesar Gomez', 'Consulta ambulatoria Hospital 2', 1, 26, 'Emitida'),
    (19, 'A', 'FAC-2026-019', 18, '2026-03-15 07:30:00-06', 'CF', 'Cesar Gomez', 'Atencion de emergencia en Hospital 2', 2, 26, 'Emitida'),
    (20, 'A', 'FAC-2026-020', 19, '2026-05-20 16:30:00-06', 'CF', 'Cesar Gomez', 'Acto quirurgico en Hospital 2', 6, 26, 'Emitida'),
    (21, 'A', 'FAC-2026-021', 20, '2026-06-19 11:30:00-06', 'CF', 'Cesar Gomez', 'Servicio de hospitalizacion Hospital 2', 4, 26, 'Emitida'),
    (22, 'A', 'FAC-2026-022', 25, '2026-05-02 10:30:00-06', 'CF', 'Ramiro Ixcoy', 'Consulta externa Hospital 3', 1, 27, 'Emitida'),
    (23, 'A', 'FAC-2026-023', 27, '2026-06-15 09:30:00-06', 'CF', 'Ingrid Quiej', 'Hospitalizacion Hospital 3', 3, 27, 'Emitida'),
    (24, 'A', 'FAC-2026-024', 28, '2026-06-01 11:00:00-06', 'CF', 'Hector Yax', 'Consulta externa Hospital 4', 1, 27, 'Emitida'),
    (25, 'A', 'FAC-2026-025', 30, '2026-07-10 13:30:00-06', 'CF', 'Debora Chuc', 'Hospitalizacion Hospital 4', 4, 27, 'Emitida')
ON CONFLICT (id_factura) DO NOTHING;

-- Renglones facturados
INSERT INTO factura_detalle (id_factura_detalle, id_factura, concepto, descripcion, cantidad, precio_unitario, porcentaje_aplicado, id_consulta, id_ingreso, id_cirugia) VALUES
    (10, 10, 'Consulta', 'Honorarios de consulta externa', 1, 250.00, 100, 10, NULL, NULL),
    (11, 11, 'Emergencia', 'Atencion de emergencia', 1, 850.00, 100, NULL, 10, NULL),
    (12, 12, 'Cirugia', 'Honorarios quirurgicos cirujano y quirofano', 1, 4500.00, 100, NULL, NULL, 10),
    (13, 13, 'Hospitalizacion', 'Estancia en cama hospitalaria por 4 dias', 4, 600.00, 100, NULL, 13, NULL),
    (14, 14, 'Consulta', 'Consulta medica de seguimiento', 1, 300.00, 100, 11, NULL, NULL),
    (15, 15, 'Emergencia', 'Emergencia y sutura menor', 1, 750.00, 100, NULL, 11, NULL),
    (16, 16, 'Cirugia', 'Intervencion quirurgica programada', 1, 5200.00, 100, NULL, NULL, 11),
    (17, 17, 'Hospitalizacion', 'Internamiento hospitalario por 5 dias', 5, 600.00, 100, NULL, 14, NULL),
    (18, 18, 'Consulta', 'Consulta externa facultativa', 1, 275.00, 100, 13, NULL, NULL),
    (19, 19, 'Emergencia', 'Atencion de urgencia y medicamentos', 1, 900.00, 100, NULL, 15, NULL),
    (20, 20, 'Cirugia', 'Procedimiento quirurgico Hospital 2', 1, 4800.00, 100, NULL, NULL, 12),
    (21, 21, 'Hospitalizacion', 'Estancia en sala de hospitalizacion 4 dias', 4, 550.00, 100, NULL, 16, NULL),
    (22, 22, 'Consulta', 'Consulta medica Hospital 3', 1, 200.00, 100, 15, NULL, NULL),
    (23, 23, 'Hospitalizacion', 'Estancia hospitalaria Hospital 3 por 5 dias', 5, 500.00, 100, NULL, 18, NULL),
    (24, 24, 'Consulta', 'Consulta medica Hospital 4', 1, 200.00, 100, 16, NULL, NULL),
    (25, 25, 'Hospitalizacion', 'Estancia hospitalaria Hospital 4 por 5 dias', 5, 500.00, 100, NULL, 20, NULL)
ON CONFLICT (id_factura_detalle) DO NOTHING;

-- Registro de pagos con metodos (Efectivo: 1, Tarjeta de credito: 2, Tarjeta de debito: 3)
INSERT INTO pago (id_pago, id_factura, numero_cuota, monto, fecha_pago, id_metodo_pago, id_unidad_hospital, id_personal_recibe, referencia) VALUES
    -- Hospital 1
    (10, 10, 1, 250.00, '2026-02-01 11:45:00-06', 1, 1, 25, 'PAG-EFE-010'),
    (11, 11, 1, 850.00, '2026-03-10 19:45:00-06', 2, 2, 25, 'VOUCHER-CC-011'),
    (12, 12, 1, 2250.00, '2026-04-05 17:45:00-06', 2, 3, 25, 'VOUCHER-CC-012A'),
    (13, 12, 2, 2250.00, '2026-05-05 10:00:00-06', 3, 3, 25, 'DEB-TRANS-012B'),
    (14, 13, 1, 1200.00, '2026-05-16 10:45:00-06', 1, 4, 25, 'PAG-EFE-013'),
    (15, 14, 1, 300.00, '2026-02-15 12:45:00-06', 3, 1, 25, 'DEB-TRANS-014'),
    (16, 15, 1, 750.00, '2026-03-23 05:45:00-06', 1, 2, 25, 'PAG-EFE-015'),
    (17, 16, 1, 2600.00, '2026-04-18 15:45:00-06', 2, 3, 25, 'VOUCHER-CC-016'),
    (18, 17, 1, 1500.00, '2026-06-05 13:45:00-06', 1, 4, 25, 'PAG-EFE-017'),

    -- Hospital 2
    (19, 18, 1, 275.00, '2026-02-10 11:15:00-06', 1, 5, 26, 'PAG-EFE-018'),
    (20, 19, 1, 900.00, '2026-03-15 07:45:00-06', 2, 6, 26, 'VOUCHER-CC-019'),
    (21, 20, 1, 4800.00, '2026-05-20 16:45:00-06', 3, 7, 26, 'DEB-TRANS-020'),
    (22, 21, 1, 1100.00, '2026-06-19 11:45:00-06', 1, 8, 26, 'PAG-EFE-021'),

    -- Hospital 3
    (23, 22, 1, 200.00, '2026-05-02 10:45:00-06', 1, 9, 27, 'PAG-EFE-022'),
    (24, 23, 1, 1250.00, '2026-06-15 09:45:00-06', 3, 12, 27, 'DEB-TRANS-023'),

    -- Hospital 4
    (25, 24, 1, 200.00, '2026-06-01 11:15:00-06', 1, 13, 27, 'PAG-EFE-024'),
    (26, 25, 1, 1250.00, '2026-07-10 13:45:00-06', 2, 16, 27, 'VOUCHER-CC-025')
ON CONFLICT (id_pago) DO NOTHING;



-- 14. CALIFICACIONES DE SERVICIO Y PERSONAL (PARA OBJETIVOS 2 Y 17)

INSERT INTO calificacion_personal (id_calificacion_personal, id_episodio, id_personal, puntuacion, comentario, fecha_hora) VALUES
    -- Calificaciones bajas para medicos con menor nota (Obj 2 y 17)
    (10, 9, 7, 2, 'Atencion acelerada y poca explicacion del diagnostico', '2026-02-01 12:00:00-06'),
    (11, 21, 7, 1, 'Puntualidad deficiente y trato distante', '2026-03-01 11:30:00-06'),
    (12, 10, 6, 2, 'Tiempo de espera prolongado en la sala de emergencia', '2026-03-10 20:30:00-06'),
    (13, 13, 8, 2, 'Consulta con poca comunicacion al paciente', '2026-02-15 13:15:00-06'),
    (14, 17, 42, 2, 'El medico se mostro apurado durante la cita', '2026-02-10 11:45:00-06'),
    (15, 23, 44, 1, 'Mala atencion y explicacion confusa de recetas', '2026-04-10 14:15:00-06'),
    (16, 25, 46, 2, 'Atencion poco amable en clinica', '2026-05-02 11:15:00-06'),
    (17, 28, 49, 2, 'Retraso de casi dos horas para ingresar a consulta', '2026-06-01 11:45:00-06'),

    -- Calificaciones altas para otros facultativos
    (18, 11, 2, 5, 'Excelente cirujano muy profesional y atento', '2026-04-05 18:00:00-06'),
    (19, 12, 4, 5, 'Cuidado de hospitalizacion impecable y humano', '2026-05-16 11:15:00-06'),
    (20, 15, 2, 5, 'Intervencion quirurgica sin ninguna queja', '2026-04-18 16:15:00-06'),
    (21, 16, 5, 5, 'Doctor muy pendiente de la evolucion', '2026-06-05 14:15:00-06'),
    (22, 19, 41, 5, 'Cirujano altamente calificado y puntual', '2026-05-20 17:15:00-06')
ON CONFLICT (id_calificacion_personal) DO NOTHING;



-- 15. SINCRONIZACION FINAL DE SECUENCIAS

SELECT setval(pg_get_serial_sequence('persona', 'id_persona'), COALESCE((SELECT MAX(id_persona) FROM persona), 1));
SELECT setval(pg_get_serial_sequence('personal', 'id_personal'), COALESCE((SELECT MAX(id_personal) FROM personal), 1));
SELECT setval(pg_get_serial_sequence('paciente', 'id_paciente'), COALESCE((SELECT MAX(id_paciente) FROM paciente), 1));
SELECT setval(pg_get_serial_sequence('asignacion_personal', 'id_asignacion'), COALESCE((SELECT MAX(id_asignacion) FROM asignacion_personal), 1));
SELECT setval(pg_get_serial_sequence('episodio', 'id_episodio'), COALESCE((SELECT MAX(id_episodio) FROM episodio), 1));
SELECT setval(pg_get_serial_sequence('ingreso', 'id_ingreso'), COALESCE((SELECT MAX(id_ingreso) FROM ingreso), 1));
SELECT setval(pg_get_serial_sequence('egreso', 'id_egreso'), COALESCE((SELECT MAX(id_egreso) FROM egreso), 1));
SELECT setval(pg_get_serial_sequence('cita', 'id_cita'), COALESCE((SELECT MAX(id_cita) FROM cita), 1));
SELECT setval(pg_get_serial_sequence('consulta', 'id_consulta'), COALESCE((SELECT MAX(id_consulta) FROM consulta), 1));
SELECT setval(pg_get_serial_sequence('receta', 'id_receta'), COALESCE((SELECT MAX(id_receta) FROM receta), 1));
SELECT setval(pg_get_serial_sequence('historia_clinica', 'id_historia_clinica'), COALESCE((SELECT MAX(id_historia_clinica) FROM historia_clinica), 1));
SELECT setval(pg_get_serial_sequence('solicitud_cirugia', 'id_solicitud_cirugia'), COALESCE((SELECT MAX(id_solicitud_cirugia) FROM solicitud_cirugia), 1));
SELECT setval(pg_get_serial_sequence('revision_solicitud', 'id_revision'), COALESCE((SELECT MAX(id_revision) FROM revision_solicitud), 1));
SELECT setval(pg_get_serial_sequence('cirugia', 'id_cirugia'), COALESCE((SELECT MAX(id_cirugia) FROM cirugia), 1));
SELECT setval(pg_get_serial_sequence('cirugia_verificacion', 'id_verificacion'), COALESCE((SELECT MAX(id_verificacion) FROM cirugia_verificacion), 1));
SELECT setval(pg_get_serial_sequence('factura', 'id_factura'), COALESCE((SELECT MAX(id_factura) FROM factura), 1));
SELECT setval(pg_get_serial_sequence('factura_detalle', 'id_factura_detalle'), COALESCE((SELECT MAX(id_factura_detalle) FROM factura_detalle), 1));
SELECT setval(pg_get_serial_sequence('pago', 'id_pago'), COALESCE((SELECT MAX(id_pago) FROM pago), 1));
SELECT setval(pg_get_serial_sequence('calificacion_personal', 'id_calificacion_personal'), COALESCE((SELECT MAX(id_calificacion_personal) FROM calificacion_personal), 1));

COMMIT;


