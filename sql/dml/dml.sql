

SET search_path TO hospitales_occidente, public;
SET timezone TO 'America/Guatemala';

/* ============================================================================
   M1. CATALOGOS CLINICOS Y GEOGRAFIA
   ============================================================================ */

-- Insercion de datos en departamento: Catalogo de los 22 departamentos de Guatemala.
INSERT INTO departamento (id_departamento, nombre) VALUES
    (1, 'Quetzaltenango'),
    (2, 'Totonicapan'),
    (3, 'San Marcos'),
    (4, 'Huehuetenango'),
    (5, 'Solola'),
    (6, 'Quiche'),
    (7, 'Suchitepequez'),
    (8, 'Retalhuleu'),
    (9, 'Chimaltenango'),
    (10, 'Escuintla'),
    (11, 'Guatemala'),
    (12, 'Sacatepequez'),
    (13, 'Alta Verapaz'),
    (14, 'Baja Verapaz'),
    (15, 'El Progreso'),
    (16, 'Izabal'),
    (17, 'Zacapa'),
    (18, 'Chiquimula'),
    (19, 'Jalapa'),
    (20, 'Jutiapa'),
    (21, 'Santa Rosa'),
    (22, 'Peten');

-- Insercion de datos en municipio: Municipios del pais enfocados en la region de Occidente.
INSERT INTO municipio (id_municipio, id_departamento, nombre) VALUES
    (1, 1, 'Quetzaltenango'),
    (2, 1, 'Salcaja'),
    (3, 1, 'Olintepeque'),
    (4, 1, 'Cantel'),
    (5, 1, 'Almolonga'),
    (6, 1, 'Zunil'),
    (7, 1, 'San Carlos Sija'),
    (8, 1, 'Coatepeque'),
    (9, 1, 'La Esperanza'),
    (10, 1, 'San Juan Ostuncalco'),
    (11, 2, 'Totonicapan'),
    (12, 2, 'San Cristobal Totonicapan'),
    (13, 2, 'San Francisco El Alto'),
    (14, 2, 'Momostenango'),
    (15, 2, 'Santa Maria Chiquimula'),
    (16, 3, 'San Marcos'),
    (17, 3, 'San Pedro Sacatepequez'),
    (18, 3, 'Malacatan'),
    (19, 3, 'Esquipulas Palo Gordo'),
    (20, 4, 'Huehuetenango'),
    (21, 4, 'Chiantla'),
    (22, 4, 'Malacatancito'),
    (23, 4, 'Santa Cruz Barillas'),
    (24, 5, 'Solola'),
    (25, 5, 'Panajachel'),
    (26, 5, 'Santiago Atitlan'),
    (27, 6, 'Santa Cruz del Quiche'),
    (28, 6, 'Chichicastenango'),
    (29, 7, 'Mazatenango'),
    (30, 7, 'Cuyotenango'),
    (31, 8, 'Retalhuleu'),
    (32, 8, 'San Sebastian'),
    (33, 11, 'Guatemala'),
    (34, 11, 'Mixco'),
    (35, 11, 'Villa Nueva');

-- Insercion de datos en direccion: Direcciones habituales de personas y sedes hospitalarias.
INSERT INTO direccion (id_direccion, id_municipio, area, detalle) VALUES
    (1, 1, 'Urbana', 'Calle Rodolfo Robles 12-45 Zona 1 Quetzaltenango'),
    (2, 1, 'Urbana', 'Avenida Las Americas 7-20 Zona 3 Quetzaltenango'),
    (3, 11, 'Urbana', '4a Calle 3-15 Zona 1 Totonicapan'),
    (4, 16, 'Urbana', '5a Avenida 8-30 Zona 2 San Marcos'),
    (5, 33, 'Urbana', 'Calzada Roosevelt 14-25 Zona 11 Guatemala'),
    (6, 33, 'Urbana', '1a Avenida 10-50 Zona 1 Guatemala'),
    (7, 20, 'Urbana', '6a Calle 4-18 Zona 1 Huehuetenango'),
    (8, 1, 'Urbana', 'Canton Choqui Sector 2 Lote 15 Quetzaltenango'),
    (9, 1, 'Rural', 'Aldea San Jose Chiquilaja Sector Central Quetzaltenango'),
    (10, 2, 'Urbana', 'Barrio San Jacinto 2a Avenida 4-10 Salcaja'),
    (11, 4, 'Rural', 'Aldea Pasac Primero Cantel'),
    (12, 5, 'Rural', 'Canton Las Flores Paraje Chitzun Almolonga'),
    (13, 9, 'Urbana', 'Sector Las Rosas Lote 45 La Esperanza'),
    (14, 10, 'Rural', 'Aldea Monrovia Sector Los Encuentros San Juan Ostuncalco'),
    (15, 11, 'Urbana', 'Barrio Chuisuc Zona 3 Totonicapan'),
    (16, 12, 'Rural', 'Canton Xecanchavox San Cristobal Totonicapan'),
    (17, 13, 'Urbana', 'Barrio El Calvario 1a Calle 2-25 San Francisco El Alto'),
    (18, 14, 'Rural', 'Aldea San Vicente Buenabaj Momostenango'),
    (19, 17, 'Urbana', 'Canton San Sebastian 3a Avenida 5-12 San Pedro Sacatepequez'),
    (20, 18, 'Rural', 'Aldea El Carmen Frontera Malacatan'),
    (21, 21, 'Urbana', 'Canton Los Regadillos Chiantla'),
    (22, 25, 'Urbana', 'Calle Santander 4-50 Panajachel'),
    (23, 27, 'Urbana', 'Zona 2 Santa Cruz del Quiche'),
    (24, 28, 'Rural', 'Canton Chupol Chichicastenango'),
    (25, 29, 'Urbana', 'Colonia El Compromiso Mazatenango'),
    (26, 31, 'Urbana', 'Zona 1 Retalhuleu'),
    (27, 34, 'Urbana', 'Colonia San Cristobal Sector A Mixco'),
    (28, 1, 'Urbana', 'Zona 3 Diagonal 2 15-40 Quetzaltenango'),
    (29, 1, 'Urbana', 'Zona 5 Colonia El Maestro Quetzaltenango'),
    (30, 2, 'Rural', 'Aldea Curruchique Salcaja'),
    (31, 3, 'Rural', 'Canton Chuisuc Olintepeque'),
    (32, 11, 'Rural', 'Paraje Chiyax Totonicapan'),
    (33, 16, 'Urbana', 'Zona 1 Parque Central San Marcos'),
    (34, 1, 'Urbana', 'Zona 10 Colonia Minerva Quetzaltenango'),
    (35, 11, 'Urbana', 'Zona 2 Barrio La Cienega Totonicapan');

-- Insercion de datos en parentesco: Tipos de parentesco reconocidos entre paciente y encargado.
INSERT INTO parentesco (id_parentesco, nombre) VALUES
    (1, 'Padre'),
    (2, 'Madre'),
    (3, 'Conyuge'),
    (4, 'Hijo'),
    (5, 'Hija'),
    (6, 'Hermano'),
    (7, 'Hermana'),
    (8, 'Abuelo'),
    (9, 'Abuela'),
    (10, 'Tio'),
    (11, 'Tia'),
    (12, 'Tutor Legal'),
    (13, 'Representante Legal'),
    (14, 'Otro');

-- Insercion de datos en especialidad: Especialidades medicas clinicas y quirurgicas del proyecto.
INSERT INTO especialidad (id_especialidad, nombre, tipo) VALUES
    (1, 'Cardiologia', 'Clinica'),
    (2, 'Dermatologia', 'Clinica'),
    (3, 'Fisioterapia', 'Clinica'),
    (4, 'Ginecologia Oncologica', 'Clinica'),
    (5, 'Hematologia', 'Clinica'),
    (6, 'Medicina Fisica y Rehabilitacion', 'Clinica'),
    (7, 'Medicina General', 'Clinica'),
    (8, 'Nutricion y Dietetica', 'Clinica'),
    (9, 'Odontologia General', 'Clinica'),
    (10, 'Oftalmologia', 'Clinica'),
    (11, 'Psicologia', 'Clinica'),
    (12, 'Pediatria', 'Clinica'),
    (13, 'Urologia', 'Clinica'),
    (14, 'Terapia del Lenguaje', 'Clinica'),
    (15, 'Cirugia Cardiovascular (Adulto y Pediatrica)', 'Quirurgica'),
    (16, 'Cirugia de la Mano', 'Quirurgica'),
    (17, 'Cirugia General', 'Quirurgica'),
    (18, 'Videolaparoscopia Quirurgica', 'Quirurgica'),
    (19, 'Cirugia Ginecologica', 'Quirurgica'),
    (20, 'Cirugia Neurologica', 'Quirurgica'),
    (21, 'Cirugia Oftalmologica', 'Quirurgica'),
    (22, 'Cirugia Oncologica', 'Quirurgica'),
    (23, 'Cirugia Ortopedica', 'Quirurgica'),
    (24, 'Cirugia Otorrinolaringologica', 'Quirurgica'),
    (25, 'Cirugia Pediatrica', 'Quirurgica'),
    (26, 'Cirugia Plastica', 'Quirurgica'),
    (27, 'Cirugia de Torax', 'Quirurgica'),
    (28, 'Cirugia Urologica', 'Quirurgica'),
    (29, 'Medicina Interna', 'Clinica'),
    (30, 'Neumologia', 'Clinica'),
    (31, 'Neurologia', 'Clinica'),
    (32, 'Oncologia', 'Clinica'),
    (33, 'Ortopedia', 'Clinica'),
    (34, 'Anestesiologia', 'Quirurgica');

-- Insercion de datos en diagnostico: Diagnosticos medicos codificados con CIE-10.
INSERT INTO diagnostico (id_diagnostico, codigo_cie10, descripcion) VALUES
    (1, 'I10', 'Hipertension esencial primaria'),
    (2, 'E11.9', 'Diabetes mellitus tipo 2 sin complicaciones'),
    (3, 'K35.8', 'Apendicitis aguda no especificada'),
    (4, 'K80.2', 'Calculo de la vesicula biliar sin colecistitis'),
    (5, 'J18.9', 'Neumonia no especificada'),
    (6, 'S82.2', 'Fractura de la diafisis de la tibia'),
    (7, 'O80.0', 'Parto unico espontaneo cefalico'),
    (8, 'K40.9', 'Hernia inguinal unilateral sin obstruccion'),
    (9, 'R10.0', 'Abdomen agudo'),
    (10, 'S06.0', 'Conmocion cerebral'),
    (11, 'J45.9', 'Asma no especificada'),
    (12, 'N39.0', 'Infeccion de vias urinarias sitio no especificado'),
    (13, 'I21.9', 'Infarto agudo del miocardio sin otra especificacion'),
    (14, 'K29.7', 'Gastritis no especificada'),
    (15, 'M54.5', 'Lumbago no especificado');

-- Insercion de datos en tipo_unidad: 4 unidades medicas oficiales mas destino para externos.
INSERT INTO tipo_unidad (id_tipo_unidad, nombre) VALUES
    (1, 'Consulta externa'),
    (2, 'Emergencias'),
    (3, 'Cirugia'),
    (4, 'Hospitalizacion'),
    (5, 'Otro');

-- Insercion de datos en servicio_medico: Servicios y atenciones medicas por tipo de unidad.
INSERT INTO servicio_medico (id_servicio, id_tipo_unidad, nombre, activo) VALUES
    (1, 1, 'Atencion Cardiologica Ambulatoria', True),
    (2, 1, 'Atencion Dermatologica', True),
    (3, 1, 'Fisioterapia y Rehabilitacion', True),
    (4, 1, 'Ginecologia Oncologica Clinica', True),
    (5, 1, 'Hematologia Clinica Ambulatoria', True),
    (6, 1, 'Medicina Fisica y Readaptacion', True),
    (7, 1, 'Consulta Medicina General', True),
    (8, 1, 'Nutricion Clinica y Dietetica', True),
    (9, 1, 'Odontologia General Integral', True),
    (10, 1, 'Oftalmologia Clinica General', True),
    (11, 1, 'Psicologia Clinica y Consejeria', True),
    (12, 1, 'Pediatria Clinica Ambulatoria', True),
    (13, 1, 'Urologia Clinica Integral', True),
    (14, 1, 'Terapia del Lenguaje y Foniatria', True),
    (15, 2, 'Aislamiento y control de la via aerea y ventilacion', True),
    (16, 2, 'Control cardiocirculatorio', True),
    (17, 2, 'Atencion de pacientes politraumatizados', True),
    (18, 2, 'Manejo, control y administracion de drogas protocolizadas', True),
    (19, 2, 'Procedimientos de control y observacion', True),
    (20, 2, 'Procedimientos terapeuticos y diagnosticos', True),
    (21, 2, 'Procedimientos diagnosticos de urgencia', True),
    (22, 3, 'Cirugia General y Abdominal', True),
    (23, 3, 'Cirugia Traumatologica y de Fracturas', True),
    (24, 3, 'Cirugia Ginecologica y Obstetricia', True),
    (25, 3, 'Cirugia Cardiovascular y Toracica', True),
    (26, 3, 'Videolaparoscopia Quirurgica de Precision', True),
    (27, 4, 'Hospitalizacion Hematologia', True),
    (28, 4, 'Hospitalizacion Medicina Interna', True),
    (29, 4, 'Hospitalizacion Neumologia', True),
    (30, 4, 'Hospitalizacion Neurologia', True),
    (31, 4, 'Hospitalizacion Oncologia', True),
    (32, 4, 'Hospitalizacion Ortopedia', True),
    (33, 4, 'Hospitalizacion Pediatria', True),
    (34, 4, 'Unidad de Cuidados Intermedios', True),
    (35, 4, 'Unidad de Cuidado Critico de Adultos', True),
    (36, 5, 'Servicio Medico Externo Referido', True);

-- Insercion de datos en turno: Turnos matutinos, vespertinos y de guardias hospitalarias.
INSERT INTO turno (id_turno, nombre, hora_inicio, hora_fin) VALUES
    (1, 'Turno Matutino Consulta Externa', '06:00:00', '14:00:00'),
    (2, 'Turno Vespertino Quirurgico', '14:00:00', '22:00:00'),
    (3, 'Guardia Emergencia Diurna 12h', '07:00:00', '19:00:00'),
    (4, 'Guardia Emergencia Nocturna 12h', '19:00:00', '07:00:00');

-- Insercion de datos en metodo_pago: Formas de pago autorizadas en recepcion de hospitales.
INSERT INTO metodo_pago (id_metodo_pago, nombre) VALUES
    (1, 'Efectivo'),
    (2, 'Tarjeta de debito'),
    (3, 'Tarjeta de credito'),
    (4, 'Transferencia bancaria'),
    (5, 'Cheque');

-- Insercion de datos en medicamento: Medicamentos recetables con su forma farmaceutica.
INSERT INTO medicamento (id_medicamento, nombre, presentacion) VALUES
    (1, 'Amoxicilina + Acido Clavulanico', 'Tabletas 500/125 mg'),
    (2, 'Paracetamol', 'Tabletas 500 mg'),
    (3, 'Ibuprofeno', 'Capsulas 400 mg'),
    (4, 'Losartan Potasico', 'Tabletas 50 mg'),
    (5, 'Metformina Clorhidrato', 'Tabletas 850 mg'),
    (6, 'Ceftriaxona', 'Frasco ampolla 1 g'),
    (7, 'Omeprazol', 'Capsulas 20 mg'),
    (8, 'Ciprofloxacina', 'Tabletas 500 mg'),
    (9, 'Diclofenaco Sodico', 'Ampolla 75 mg/3 ml'),
    (10, 'Salbutamol', 'Inhalador 100 mcg/dosis'),
    (11, 'Enoxaparina Sodica', 'Jeringa prellenada 40 mg'),
    (12, 'Fentanilo', 'Ampolla 0.5 mg/10 ml'),
    (13, 'Propofol', 'Ampolla 200 mg/20 ml'),
    (14, 'Ketorolaco', 'Ampolla 30 mg'),
    (15, 'Tramadol Clorhidrato', 'Ampolla 100 mg');

-- Insercion de datos en examen_laboratorio: Catalogo de pruebas diagnosticas de laboratorio.
INSERT INTO examen_laboratorio (id_examen, nombre) VALUES
    (1, 'Hematologia completa'),
    (2, 'Quimica sanguinea 6 elementos'),
    (3, 'Tiempos de coagulacion TP y TTP'),
    (4, 'Examen general de orina'),
    (5, 'Perfil lipidico completo'),
    (6, 'Pruebas de funcion hepatica'),
    (7, 'Electrolitos sericos'),
    (8, 'Gasometria arterial'),
    (9, 'Prueba de embarazo hCG cualitativa'),
    (10, 'Grupo sanguineo y factor Rh'),
    (11, 'Coprocultivo'),
    (12, 'Urocultivo con antibiograma');

-- Insercion de datos en tipo_anestesia: Modalidades de induccion anestesica autorizadas.
INSERT INTO tipo_anestesia (id_tipo_anestesia, nombre) VALUES
    (1, 'Anestesia general balanceada'),
    (2, 'Anestesia regional raquidea'),
    (3, 'Anestesia epidural'),
    (4, 'Sedacion consciente monitorizada'),
    (5, 'Anestesia local infiltrativa');

-- Insercion de datos en procedimiento_quirurgico: Procedimientos quirurgicos tipificados.
INSERT INTO procedimiento_quirurgico (id_procedimiento, id_especialidad, nombre, descripcion) VALUES
    (1, 18, 'Apendicectomia videolaparoscopica', 'Extirpacion quirurgica de apendice cecal inflamado por via laparoscopica'),
    (2, 18, 'Colecistectomia laparoscopica', 'Extirpacion de vesicula biliar con calculos mediante tecnica laparoscopica'),
    (3, 17, 'Herniorrafia inguinal con malla', 'Reparacion quirurgica de defecto herniario inguinal con colocacion de protesis'),
    (4, 23, 'Osteosintesis de fractura de tibia', 'Reduccion abierta y fijacion interna con placa y tornillos en diafisis tibial'),
    (5, 19, 'Cesarea segmentaria transperitoneal', 'Extraccion quirurgica de feto a traves de histerotomia segmentaria'),
    (6, 15, 'Revascularizacion miocardica coronaria', 'Puente coronario con injerto arterial o venoso'),
    (7, 16, 'Liberacion de tunel carpiano', 'Seccion del ligamento anular anterior del carpo'),
    (8, 20, 'Craneotomia descompresiva de urgencia', 'Apertura quirurgica de calota para alivio de hipertension endocraneal'),
    (9, 21, 'Facoemulsificacion con lente intraocular', 'Cirugia de catarata con ultrasonido y colocacion de implante'),
    (10, 22, 'Tiroidectomia total oncologica', 'Reseccion completa de glandula tiroides y vaciamiento ganglionar'),
    (11, 28, 'Reseccion transuretral de prostata', 'Ablacion endoscopica de tejido prostatico obstructivo'),
    (12, 24, 'Amigdalectomia con adenoidectomia', 'Extirpacion quirurgica de amigdalas palatinas y tejido adenoideo');

-- Insercion de datos en insumo: Materiales consumibles utilizados en atencion medica.
INSERT INTO insumo (id_insumo, nombre, descripcion, material, tipo) VALUES
    (1, 'Guantes esteriles de latex quirurgicos', 'Par de guantes esteriles desechables numero 7.5', 'Latex natural', 'Quirurgico'),
    (2, 'Gasas esteriles radiopacas 10x10 cm', 'Paquete de 10 gasas con cinta detectable por rayos X', 'Algodon hidrofilo', 'Quirurgico'),
    (3, 'Sutura Vicryl 2-0 con aguja curva', 'Sutura absorbible sintetica trenzada de 70 cm', 'Poliglactina 910', 'Quirurgico'),
    (4, 'Sutura Nylon 3-0 con aguja cortante', 'Sutura monofilamento no absorbible para piel', 'Poliamida', 'Quirurgico'),
    (5, 'Solucion Salina 0.9% 1000 ml', 'Solucion fisiologica esteril para perfusion intravenosa', 'Cloruro de sodio en agua', 'Medico'),
    (6, 'Solucion Hartman 1000 ml', 'Solucion polielectrolitica balanceada para reposicion', 'Lactato de Ringer', 'Medico'),
    (7, 'Cateter intravenoso calibre 18G', 'Cateter periferico sobre aguja con aletas', 'Poliuretano biocompatible', 'Medico'),
    (8, 'Equipo de venoclisis normogotero', 'Linea de infusion con camara de goteo y filtro', 'Plastico grado medico', 'Medico'),
    (9, 'Sonda Foley calibre 16 Fr', 'Sonda vesical de dos vias con balon de retencion', 'Silicona transparente', 'Quirurgico'),
    (10, 'Bolsa recolectora de orina 2000 ml', 'Bolsa graduada con valvula antirreflujo', 'Polietileno resistente', 'Medico'),
    (11, 'Venda elastica 6 pulgadas', 'Venda de compresion elastica con ganchos de sujecion', 'Algodon y elastano', 'Medico'),
    (12, 'Hoja de bisturi numero 15', 'Hoja cortante quirurgica esteril desechable', 'Acero al carbono', 'Quirurgico'),
    (13, 'Mascarilla quirurgica triple capa', 'Mascarilla facial con ajuste nasal y elastico', 'Tela no tejida polipropileno', 'Medico'),
    (14, 'Tubo endotraqueal con balon 7.5 mm', 'Tubo traqueal con manguito de baja presion', 'PVC siliconado', 'Quirurgico'),
    (15, 'Esparadrapo microporoso 2 pulgadas', 'Cinta adhesiva hipoalergenica de tela transpirable', 'Papel poroso adhesivo', 'Medico');

-- Insercion de datos en instrumento: Instrumental quirurgico reutilizable esterilizable.
INSERT INTO instrumento (id_instrumento, nombre, descripcion, tipo, funcion) VALUES
    (1, 'Mango de bisturi numero 3', 'Mango anatomico para hojas de bisturi pequenas', 'Quirurgico', 'Corte'),
    (2, 'Tijera de Metzenbaum curva 18 cm', 'Tijera fina para diseccion delicada de tejidos', 'Quirurgico', 'Corte'),
    (3, 'Tijera de Mayo recta 17 cm', 'Tijera robusta para corte de suturas y material', 'Quirurgico', 'Corte'),
    (4, 'Pinza de diseccion con dientes', 'Pinza de prension con dientes de raton 1x2', 'Quirurgico', 'Contenido'),
    (5, 'Pinza de diseccion sin dientes', 'Pinza atraumatica de tejido vascular y serosas', 'Quirurgico', 'Contenido'),
    (6, 'Pinza hemostatica Kelly curva', 'Pinza para oclusion vascular hemostatica', 'Quirurgico', 'Hemostatica'),
    (7, 'Pinza de Pean hemostatica grande', 'Pinza de hemostasia fuerte para pediculos gruesos', 'Quirurgico', 'Hemostatica'),
    (8, 'Separador de Farabeuf par', 'Separadores manuales de planos superficiales', 'Quirurgico', 'Retractor'),
    (9, 'Separador de Deaver mediano', 'Separador valva profunda abdominal y pelvica', 'Quirurgico', 'Retractor'),
    (10, 'Portaagujas de Mayo-Hegar 16 cm', 'Instrumento con bocas de tungsteno para suturar', 'Quirurgico', 'Accesorio'),
    (11, 'Canula de succion Yankauer', 'Tubo curvo rigido para aspiracion quirurgica', 'Quirurgico', 'Accesorio'),
    (12, 'Malla de polipropileno monofilamento', 'Protesis quirurgica de refuerzo tisular', 'Quirurgico', 'Implante');

-- Insercion de datos en equipo: Equipos medicos y biomedicos de diagnostico y quirofano.
INSERT INTO equipo (id_equipo, nombre, descripcion, tipo, funcion) VALUES
    (1, 'Maquina de anestesia con monitor integrado', 'Estacion de trabajo de anestesia con ventilador', 'Quirurgico', 'Tratamiento'),
    (2, 'Monitor de signos vitales multiparametrico', 'Monitor continuo de ECG, SpO2, PNI, temperatura', 'Medico', 'Diagnostico'),
    (3, 'Unidad electroquirurgica bipolar monopolar', 'Generador electroquirurgico con coagulacion de precision', 'Quirurgico', 'Tratamiento'),
    (4, 'Torre de videolaparoscopia quirurgica HD', 'Camara HD, fuente de luz LED e insuflador CO2', 'Quirurgico', 'Exploracion'),
    (5, 'Desfibrilador bifasico con marcapasos', 'Monitor desfibrilador de reanimacion avanzada', 'Medico', 'Tratamiento'),
    (6, 'Lampara quirurgica de techo de luz LED', 'Lampara scialitica de doble satelite quirurgico', 'Quirurgico', 'Exploracion'),
    (7, 'Bomba de infusion continua volumetrica', 'Bomba electronica precisa para administracion de farmacos', 'Medico', 'Tratamiento'),
    (8, 'Arco en C radiologico quirurgico', 'Fluoroscopio digital portatil para cirugia ortopedica', 'Quirurgico', 'Diagnostico'),
    (9, 'Ventilador mecanico invasivo de intensivo', 'Respirador volumetrico para soporte respiratorio critico', 'Medico', 'Tratamiento'),
    (10, 'Electrocardiografo digital de 12 derivadas', 'Equipo portatil de registro cardiologico digital', 'Medico', 'Diagnostico'),
    (11, 'Ultrasonografo doppler color portatil', 'Equipo ultrasonico de exploracion hepatica y vascular', 'Medico', 'Diagnostico');

-- Insercion de datos en momento_quirurgico: Fases cronologicas de chequeo del proceso quirurgico.
INSERT INTO momento_quirurgico (id_momento, nombre, fase, orden) VALUES
    (1, 'Planificacion preoperatoria', 'Preoperatorio', 1),
    (2, 'Entrada a quirofano', 'Preoperatorio', 2),
    (3, 'Chequeo en quirofano', 'Intraoperatorio', 3),
    (4, 'Procedimientos de pausa quirurgica', 'Intraoperatorio', 4),
    (5, 'Gestion de cuidados intraoperatoria', 'Intraoperatorio', 5),
    (6, 'Salida quirurgica', 'Intraoperatorio', 6),
    (7, 'Ingreso a sala de recuperacion', 'Postoperatorio', 7),
    (8, 'Traslado seguro a sala', 'Postoperatorio', 8);

-- Insercion de datos en item_verificacion: Items de seguridad quirurgica de la lista de chequeo.
INSERT INTO item_verificacion (id_item, id_momento, descripcion, tipo_resultado, orden) VALUES
    (1, 1, 'Disponibilidad de tabla quirurgica confirmada', 'Exito o fallo', 1),
    (2, 1, 'Preparacion de equipos y quirofano previo al ingreso', 'Exito o fallo', 2),
    (3, 1, 'Recepcion y acogida de paciente en el quirofano', 'Exito o fallo', 3),
    (4, 2, 'Brazalete de identificacion del paciente confirmado', 'Exito o fallo', 1),
    (5, 2, 'Ficha clinica con consentimientos y preanestesica en regla', 'Exito o fallo', 2),
    (6, 2, 'Confirmacion de arsenal instrumental y esteril operativo', 'Exito o fallo', 3),
    (7, 2, 'Disponibilidad de farmacos y tecnica anestesica comprobada', 'Exito o fallo', 4),
    (8, 3, 'Presencia completa del equipo quirurgico en sala', 'Exito o fallo', 1),
    (9, 3, 'Traslado correcto de camilla a mesa quirurgica', 'Exito o fallo', 2),
    (10, 3, 'Posicionamiento ergonomico correcto en mesa operatoria', 'Exito o fallo', 3),
    (11, 3, 'Placa neutra de electrobisturi instalada correctamente', 'Exito o fallo', 4),
    (12, 4, 'Confirmacion verbal de identidad del paciente', 'Exito o fallo', 1),
    (13, 4, 'Confirmacion de condiciones de esterilidad y campo', 'Exito o fallo', 2),
    (14, 4, 'Revision de maquina de anestesia y via aerea permeable', 'Exito o fallo', 3),
    (15, 4, 'Cirujano indica plan quirurgico y pasos criticos', 'Exito o fallo', 4),
    (16, 4, 'Incision quirurgica autorizada formalmente', 'Exito o fallo', 5),
    (17, 5, 'Registro y control de balance hidrico estricto', 'Aceptabilidad', 1),
    (18, 5, 'Seguridad en administracion de medicamentos protocolizados', 'Aceptabilidad', 2),
    (19, 5, 'Registro y monitoreo de transfusion de sangre', 'Aceptabilidad', 3),
    (20, 6, 'Cirujano anuncia formalmente el fin de procedimientos', 'Exito o fallo', 1),
    (21, 6, 'Confirmacion de procedimiento quirurgico realizado', 'Exito o fallo', 2),
    (22, 6, 'Conteo de gasas, compresas e instrumental satisfactorio', 'Exito o fallo', 3),
    (23, 6, 'Cierre correcto de incision quirurgica sin fugas', 'Exito o fallo', 4),
    (24, 7, 'Condiciones de evolucion durante la cirugia', 'Aceptabilidad', 1),
    (25, 7, 'Confirmacion de cama post anestesica adecuada', 'Exito o fallo', 2),
    (26, 7, 'Gases clinicos, monitores y electrodos operativos', 'Exito o fallo', 3),
    (27, 7, 'Disposicion de personal de enfermeria asignado', 'Exito o fallo', 4),
    (28, 7, 'Medicamentos disponibles y portasueros colocados', 'Exito o fallo', 5),
    (29, 8, 'Signos vitales dentro de limites fisiologicos normales', 'Exito o fallo', 1),
    (30, 8, 'Zona operatoria limpia con aposito esteril integro', 'Exito o fallo', 2),
    (31, 8, 'Documentacion clinica completa y boleta de traslado', 'Exito o fallo', 3),
    (32, 8, 'Sueros de mantencion y venoclisis pasando correctamente', 'Exito o fallo', 4);

/* ============================================================================
   M2. ESTRUCTURA HOSPITALARIA
   ============================================================================ */

-- Insercion de datos en hospital: Hospitales propios de Occidente y centros de referencia externa.
INSERT INTO hospital (id_hospital, codigo, nombre, id_direccion, telefono, correo, es_interno, activo) VALUES
    (1, 'HOC-01', 'Hospital Central de Occidente Los Altos', 1, '77612000', 'info.xela@hospitalesoccidente.gt', True, True),
    (2, 'HOC-02', 'Hospital Regional San Juan de Occidente', 2, '77654000', 'sanjuan.xela@hospitalesoccidente.gt', True, True),
    (3, 'HOC-03', 'Hospital Departamental de Totonicapan Atanasio Tzul', 3, '77661000', 'totonicapan@hospitalesoccidente.gt', True, True),
    (4, 'HOC-04', 'Hospital Regional de San Marcos La Union', 4, '77603000', 'sanmarcos@hospitalesoccidente.gt', True, True),
    (5, 'EXT-01', 'Centro Medico Militar de Guatemala', 5, '23341000', 'referencias@cmmilitar.gob.gt', False, True),
    (6, 'EXT-02', 'Hospital General San Juan de Dios Capital', 6, '22510000', 'direccion@hgsjd.gob.gt', False, True),
    (7, 'EXT-03', 'Hospital Regional de Huehuetenango Doctor Jorge Vides', 7, '77642000', 'direccion@hrhuehue.gob.gt', False, True);

-- Insercion de datos en unidad_hospital: Unidades operativas activadas en los hospitales internos.
INSERT INTO unidad_hospital (id_unidad_hospital, id_hospital, id_tipo_unidad) VALUES
    (1, 1, 1),
    (2, 1, 2),
    (3, 1, 3),
    (4, 1, 4),
    (5, 2, 1),
    (6, 2, 2),
    (7, 2, 3),
    (8, 2, 4),
    (9, 3, 1),
    (10, 3, 2),
    (11, 3, 3),
    (12, 3, 4),
    (13, 4, 1),
    (14, 4, 2),
    (15, 4, 3),
    (16, 4, 4);

-- Insercion de datos en espacio_atencion: Camillas de observacion y quirofanos (maximo 4 por hospital).
INSERT INTO espacio_atencion (id_espacio, id_unidad_hospital, tipo, codigo, habilitado) VALUES
    (1, 3, 'Quirofano', 'QX-01-XELA', True),
    (2, 3, 'Quirofano', 'QX-02-XELA', True),
    (3, 3, 'Quirofano', 'QX-03-XELA', True),
    (4, 3, 'Quirofano', 'QX-04-XELA', True),
    (5, 2, 'Camilla', 'CAM-EM-101', True),
    (6, 2, 'Camilla', 'CAM-EM-102', True),
    (7, 2, 'Camilla', 'CAM-EM-103', True),
    (8, 2, 'Camilla', 'CAM-EM-104', True),
    (9, 2, 'Camilla', 'CAM-EM-105', True),
    (10, 4, 'Camilla', 'CAM-HOSP-201', True),
    (11, 4, 'Camilla', 'CAM-HOSP-202', True),
    (12, 4, 'Camilla', 'CAM-HOSP-203', True),
    (13, 4, 'Camilla', 'CAM-HOSP-204', True),
    (14, 4, 'Camilla', 'CAM-HOSP-205', True),
    (15, 7, 'Quirofano', 'QX-01-SJD', True),
    (16, 7, 'Quirofano', 'QX-02-SJD', True),
    (17, 7, 'Quirofano', 'QX-03-SJD', True),
    (18, 7, 'Quirofano', 'QX-04-SJD', True),
    (19, 6, 'Camilla', 'CAM-EM-201', True),
    (20, 6, 'Camilla', 'CAM-EM-202', True),
    (21, 6, 'Camilla', 'CAM-EM-203', True),
    (22, 11, 'Quirofano', 'QX-01-TOTO', True),
    (23, 11, 'Quirofano', 'QX-02-TOTO', True),
    (24, 11, 'Quirofano', 'QX-03-TOTO', True),
    (25, 12, 'Camilla', 'CAM-HOSP-301', True),
    (26, 12, 'Camilla', 'CAM-HOSP-302', True),
    (27, 12, 'Camilla', 'CAM-HOSP-303', True);

-- Insercion de datos en clinica: Consultorios medicos para atencion de consulta externa.
INSERT INTO clinica (id_clinica, id_hospital, numero_clinica, habilitada) VALUES
    (1, 1, 'CLN-101', True),
    (2, 1, 'CLN-102', True),
    (3, 1, 'CLN-103', True),
    (4, 1, 'CLN-104', True),
    (5, 1, 'CLN-105', True),
    (6, 2, 'CLN-201', True),
    (7, 2, 'CLN-202', True),
    (8, 2, 'CLN-203', True),
    (9, 3, 'CLN-301', True),
    (10, 3, 'CLN-302', True),
    (11, 4, 'CLN-401', True),
    (12, 4, 'CLN-402', True);

/* ============================================================================
   M3. PERSONAS Y PERSONAL
   ============================================================================ */

-- Insercion de datos en persona: Sujetos con datos demograficos de Guatemala (DPI 13 digitos).
INSERT INTO persona (id_persona, nombres, apellidos, dpi, fecha_nacimiento, sexo, telefono, id_direccion) VALUES
    (1, 'Carlos Roberto', 'Ixcoy Rodriguez', '2548963210901', '1978-04-12', 'Masculino', '77611101', 8),
    (2, 'Juan Francisco', 'Yax Sac', '2145879630901', '1982-08-25', 'Masculino', '77611102', 9),
    (3, 'Elmer David', 'Chaj Morales', '1987542360901', '1980-11-14', 'Masculino', '77611103', 10),
    (4, 'Pedro Luis', 'Tzun Cux', '1874563210901', '1975-02-18', 'Masculino', '77611104', 11),
    (5, 'Maria Elena', 'Alvarez Garcia', '2365412890901', '1985-05-30', 'Femenino', '77611105', 12),
    (6, 'Ana Sofia', 'Vasquez Hernandez', '2258964120901', '1984-09-15', 'Femenino', '77611106', 13),
    (7, 'Mario Alejandro', 'Gomez Chan', '2489631450901', '1988-12-04', 'Masculino', '77611107', 14),
    (8, 'Roberto Miguel', 'Pop Coj', '2654123980901', '1989-07-21', 'Masculino', '77611108', 15),
    (9, 'Jorge Luis', 'Xiquin Chuc', '2789654120901', '1994-03-10', 'Masculino', '77611109', 16),
    (10, 'Victor Manuel', 'Quiej Macario', '2896541230901', '1995-06-18', 'Masculino', '77611110', 17),
    (11, 'Edgar Fernando', 'Batres Estrada', '2987456320901', '1998-01-22', 'Masculino', '77611111', 18),
    (12, 'Hector Daniel', 'Castillo Barrios', '1654897230101', '1972-10-05', 'Masculino', '23341112', 27),
    (13, 'Diego Alejandro', 'Fuentes Ovalle', '1745896320101', '1974-04-19', 'Masculino', '22511113', 27),
    (14, 'Silvia Patricia', 'De Leon Lopez', '2014589630901', '1981-03-27', 'Femenino', '77611114', 28),
    (15, 'Carmen Lucia', 'Ixcoy Yax', '2569874120901', '1986-09-12', 'Femenino', '77622215', 28),
    (16, 'Rosa Maria', 'Sac Chaj', '2458963210901', '1988-02-14', 'Femenino', '77622216', 29),
    (17, 'Claudia Andrea', 'Morales Tzun', '2369854120801', '1990-11-20', 'Femenino', '77622217', 15),
    (18, 'Juana Teresa', 'Cux Alvarez', '2145896320801', '1987-04-05', 'Femenino', '77622218', 16),
    (19, 'Marta Leticia', 'Garcia Vasquez', '2258741231201', '1989-08-30', 'Femenino', '77622219', 19),
    (20, 'Daniel Alejandro', 'Gomez Pop', '3014589630901', '2000-05-14', 'Masculino', '55441120', 30),
    (21, 'Manuel Antonio', 'Chan Coj', '3125489630901', '2001-09-23', 'Masculino', '55441121', 31),
    (22, 'David Fernando', 'Xiquin Batres', '3258964120801', '2000-12-01', 'Masculino', '55441122', 32),
    (23, 'Brenda Sofia', 'Quiej Estrada', '3058964120901', '2002-02-18', 'Femenino', '55442223', 30),
    (24, 'Ingrid Paola', 'Macario Castillo', '3145896320801', '2001-07-09', 'Femenino', '55442224', 32),
    (25, 'Sandra Elena', 'Barrios Fuentes', '2489632140901', '1991-03-15', 'Femenino', '77633325', 34),
    (26, 'Leticia Andrea', 'Ovalle De Leon', '2377889910901', '1992-10-28', 'Femenino', '77633326', 34),
    (27, 'Victor Hugo', 'Sop Ajpop', '2158963240801', '1985-06-11', 'Masculino', '77633327', 35),
    (28, 'Jose Miguel', 'Yax Ixcoy', '2658941230901', '1993-07-14', 'Masculino', '55661128', 8),
    (29, 'Maria Concepcion', 'Sac Rodriguez', '2799112230901', '1996-01-20', 'Femenino', '55661129', 9),
    (30, 'Juan Carlos', 'Chaj Tzun', '2896541230801', '1990-11-08', 'Masculino', '55661130', 15),
    (31, 'Sofia Elizabeth', 'Cux Morales', NULL, '2018-04-25', 'Femenino', '55661131', 16),
    (32, 'Pedro Francisco', 'Pop Chan', '1548963210901', '1960-03-18', 'Masculino', '55661132', 10),
    (33, 'Elena Beatriz', 'Alvarez Hernandez', '2466778810901', '1988-09-05', 'Femenino', '55661133', 13),
    (34, 'Mario Rene', 'Gomez Vasquez', '2365894120801', '1982-12-14', 'Masculino', '55661134', 17),
    (35, 'Lucia Carmen', 'Xiquin Coj', '2258963140901', '1975-06-22', 'Femenino', '55661135', 14),
    (36, 'Tomas Antonio', 'Yax Macario', '1896541230901', '1965-02-10', 'Masculino', '55771136', 8),
    (37, 'Francisco Javier', 'Sac Lopez', '2688991120901', '1992-05-18', 'Masculino', '55771137', 9),
    (38, 'Juana Maria', 'Tzun Batres', '1789654120801', '1968-08-30', 'Femenino', '55771138', 15),
    (39, 'Roberto Daniel', 'Cux Estrada', '2489651230801', '1987-10-12', 'Masculino', '55771139', 16),
    (40, 'Silvia Andrea', 'Gomez Castillo', '2398745610801', '1985-04-03', 'Femenino', '55771140', 17);

-- Insercion de datos en paciente: Subtipo persona correspondiente a usuarios del hospital.
INSERT INTO paciente (id_paciente, id_persona, no_expediente, estado_civil, no_seguro_social, religion, ocupacion, id_municipio_nacimiento) VALUES
    (1, 28, 'EXP-2026-0001', 'Soltero', '1002548960', 'Catolica', 'Agricultor', 1),
    (2, 29, 'EXP-2026-0002', 'Casado', '1003698520', 'Evangelica', 'Ama de casa', 1),
    (3, 30, 'EXP-2026-0003', 'Soltero', '1004785210', 'Catolica', 'Comerciante', 11),
    (4, 31, 'EXP-2026-0004', 'Soltero', NULL, 'Catolica', 'Estudiante', 11),
    (5, 32, 'EXP-2026-0005', 'Casado', '1001478520', 'Catolica', 'Jubilado', 1),
    (6, 33, 'EXP-2026-0006', 'Casado', '1005896320', 'Evangelica', 'Maestra', 1),
    (7, 34, 'EXP-2026-0007', 'Casado', '1006985410', 'Catolica', 'Transportista', 11),
    (8, 35, 'EXP-2026-0008', 'Viudo', '1007896540', 'Catolica', 'Tejedora artesanal', 1);

-- Insercion de datos en paciente_encargado: Relacion entre paciente y sus familiares responsables.
INSERT INTO paciente_encargado (id_paciente_encargado, id_paciente, id_persona, id_parentesco, es_principal) VALUES
    (1, 1, 36, 1, True),
    (2, 2, 37, 3, True),
    (3, 3, 38, 2, True),
    (4, 4, 39, 1, True),
    (5, 7, 40, 3, True);

-- Insercion de datos en personal: Empleados asistenciales y de soporte del hospital.
INSERT INTO personal (id_personal, id_persona, tipo_personal, activo) VALUES
    (1, 1, 'Medico', True),
    (2, 2, 'Medico', True),
    (3, 3, 'Medico', True),
    (4, 4, 'Medico', True),
    (5, 5, 'Medico', True),
    (6, 6, 'Medico', True),
    (7, 7, 'Medico', True),
    (8, 8, 'Medico', True),
    (9, 9, 'Medico', True),
    (10, 10, 'Medico', True),
    (11, 11, 'Medico', True),
    (12, 12, 'Medico', True),
    (13, 13, 'Medico', True),
    (14, 14, 'Medico', True),
    (15, 15, 'Enfermero', True),
    (16, 16, 'Enfermero', True),
    (17, 17, 'Enfermero', True),
    (18, 18, 'Enfermero', True),
    (19, 19, 'Enfermero', True),
    (20, 20, 'Practicante de medicina', True),
    (21, 21, 'Practicante de medicina', True),
    (22, 22, 'Practicante de medicina', True),
    (23, 23, 'Practicante de enfermeria', True),
    (24, 24, 'Practicante de enfermeria', True),
    (25, 25, 'Administrativo', True),
    (26, 26, 'Administrativo', True),
    (27, 27, 'Administrativo', True);

-- Insercion de datos en medico: Medicos colegiados, condiciones laborales y tarifas.
INSERT INTO medico (id_personal, no_colegiado, condicion, institucion_origen, tarifa_consulta) VALUES
    (1, 'COL-12450', 'Planta', NULL, 250.00),
    (2, 'COL-13200', 'Planta', NULL, 300.00),
    (3, 'COL-14100', 'Planta', NULL, 275.00),
    (4, 'COL-11850', 'Planta', NULL, 300.00),
    (5, 'COL-15600', 'Planta', NULL, 200.00),
    (6, 'COL-16200', 'Planta', NULL, 350.00),
    (7, 'COL-17400', 'Planta', NULL, 150.00),
    (8, 'COL-18100', 'Planta', NULL, 150.00),
    (9, 'COL-20150', 'Residente', NULL, 120.00),
    (10, 'COL-20890', 'Residente', NULL, 120.00),
    (11, 'COL-22400', 'Interno', NULL, 100.00),
    (12, 'COL-09850', 'Externo', 'Centro Medico Militar de Guatemala', 500.00),
    (13, 'COL-08940', 'Externo', 'Hospital General San Juan de Dios Capital', 600.00),
    (14, 'COL-14880', 'Planta', NULL, 350.00);

-- Insercion de datos en medico_especialidad: Acreditacion de especialidades por facultativo.
INSERT INTO medico_especialidad (id_medico, id_especialidad, es_principal) VALUES
    (1, 17, True),
    (1, 18, False),
    (2, 18, True),
    (2, 17, False),
    (3, 34, True),
    (4, 23, True),
    (4, 33, False),
    (5, 12, True),
    (6, 1, True),
    (7, 7, True),
    (8, 7, True),
    (9, 17, True),
    (10, 29, True),
    (11, 7, True),
    (12, 15, True),
    (13, 20, True),
    (14, 4, True);

-- Insercion de datos en asignacion_personal: Asignacion operativa a unidades y turnos.
INSERT INTO asignacion_personal (id_asignacion, id_personal, id_unidad_hospital, id_turno, fecha_inicio, fecha_fin) VALUES
    (1, 1, 1, 1, '2026-01-01', NULL),
    (2, 5, 1, 1, '2026-01-01', NULL),
    (3, 6, 1, 1, '2026-01-01', NULL),
    (4, 7, 1, 1, '2026-01-01', NULL),
    (5, 14, 1, 1, '2026-01-01', NULL),
    (6, 1, 3, 2, '2026-01-01', NULL),
    (7, 2, 3, 2, '2026-01-01', NULL),
    (8, 3, 3, 2, '2026-01-01', NULL),
    (9, 4, 3, 2, '2026-01-01', NULL),
    (10, 7, 2, 3, '2026-01-01', NULL),
    (11, 8, 2, 4, '2026-01-01', NULL),
    (12, 15, 3, 2, '2026-01-01', NULL),
    (13, 16, 3, 2, '2026-01-01', NULL),
    (14, 17, 2, 3, '2026-01-01', NULL),
    (15, 18, 4, 3, '2026-01-01', NULL),
    (16, 25, 1, 1, '2026-01-01', NULL),
    (17, 26, 2, 3, '2026-01-01', NULL),
    (18, 27, 3, 2, '2026-01-01', NULL);

-- Insercion de datos en horario_medico: Horario de atencion semanal en clinicas matutinas.
INSERT INTO horario_medico (id_horario, id_medico, id_clinica, dia_semana, hora_inicio, hora_fin) VALUES
    (1, 1, 1, 1, '08:00:00', '12:00:00'),
    (2, 1, 1, 3, '08:00:00', '12:00:00'),
    (3, 5, 2, 1, '07:00:00', '12:00:00'),
    (4, 5, 2, 2, '07:00:00', '12:00:00'),
    (5, 5, 2, 3, '07:00:00', '12:00:00'),
    (6, 5, 2, 4, '07:00:00', '12:00:00'),
    (7, 5, 2, 5, '07:00:00', '12:00:00'),
    (8, 6, 3, 2, '08:00:00', '12:30:00'),
    (9, 6, 3, 4, '08:00:00', '12:30:00'),
    (10, 7, 4, 1, '07:00:00', '12:00:00'),
    (11, 7, 4, 2, '07:00:00', '12:00:00'),
    (12, 7, 4, 3, '07:00:00', '12:00:00'),
    (13, 7, 4, 4, '07:00:00', '12:00:00'),
    (14, 7, 4, 5, '07:00:00', '12:00:00');

/* ============================================================================
   M4. NUCLEO CLINICO COMUN
   ============================================================================ */

-- Insercion de datos en episodio: Ciclo integral de atencion del paciente.
INSERT INTO episodio (id_episodio, id_paciente, id_hospital, fecha_apertura, fecha_cierre) VALUES
    (1, 1, 1, '2026-09-01 08:00:00-06', '2026-09-03 16:00:00-06'),
    (2, 2, 1, '2026-09-05 06:30:00-06', '2026-09-07 11:00:00-06'),
    (3, 3, 1, '2026-09-10 14:15:00-06', '2026-09-16 10:00:00-06'),
    (4, 4, 1, '2026-09-12 08:30:00-06', '2026-09-12 11:30:00-06'),
    (5, 5, 1, '2026-09-15 09:00:00-06', '2026-09-15 10:45:00-06'),
    (6, 6, 1, '2026-09-18 10:00:00-06', '2026-09-18 12:00:00-06'),
    (7, 7, 1, '2026-09-22 08:00:00-06', '2026-09-22 10:30:00-06'),
    (8, 8, 1, '2026-09-25 18:00:00-06', '2026-09-27 12:00:00-06');

-- Insercion de datos en registro_signos_vitales: Mediciones fisiologicas durante el episodio.
INSERT INTO registro_signos_vitales (id_signos_vitales, id_episodio, fecha_hora, presion_sistolica, presion_diastolica, frecuencia_cardiaca, frecuencia_respiratoria, temperatura_c, saturacion_oxigeno, peso_kg, talla_cm, id_personal) VALUES
    (1, 1, '2026-09-01 08:15:00-06', 120, 80, 88, 18, 38.2, 98, 68.5, 168.0, 17),
    (2, 1, '2026-09-01 13:00:00-06', 115, 75, 76, 16, 37.0, 99, 68.5, 168.0, 15),
    (3, 2, '2026-09-05 06:45:00-06', 110, 70, 78, 18, 36.6, 99, 72.0, 158.0, 16),
    (4, 3, '2026-09-10 14:30:00-06', 135, 85, 102, 22, 36.8, 96, 75.0, 172.0, 17),
    (5, 3, '2026-09-11 08:00:00-06', 125, 80, 82, 18, 37.1, 98, 75.0, 172.0, 18),
    (6, 4, '2026-09-12 08:45:00-06', 95, 60, 95, 20, 37.5, 98, 22.0, 115.0, 15),
    (7, 5, '2026-09-15 09:15:00-06', 130, 82, 70, 16, 36.5, 97, 80.0, 165.0, 16),
    (8, 6, '2026-09-18 10:15:00-06', 118, 76, 74, 16, 36.7, 98, 62.0, 160.0, 15),
    (9, 7, '2026-09-22 08:15:00-06', 122, 80, 76, 17, 36.6, 98, 74.0, 170.0, 16),
    (10, 8, '2026-09-25 18:15:00-06', 175, 105, 98, 20, 36.8, 95, 66.0, 155.0, 17);

-- Insercion de datos en ingreso: Ficha de ingreso a Emergencias, Cirugia u Hospitalizacion.
INSERT INTO ingreso (id_ingreso, id_episodio, id_unidad_hospital, id_servicio, fecha_hora_ingreso, motivo_ingreso, id_diagnostico_presuntivo, id_medico, id_espacio, id_paciente_encargado, estado_actual_paciente, prioridad_triage, dias_estimados_estancia) VALUES
    (1, 1, 2, 19, '2026-09-01 08:10:00-06', 'Dolor abdominal agudo intenso en fosa iliaca derecha con fiebre y nauseas', 9, 7, 5, 1, 'Paciente agudo quejumbroso febril con abdomen en tabla', 2, 1),
    (2, 1, 3, 22, '2026-09-01 09:30:00-06', 'Apendicitis aguda confirmada para intervencion videolaparoscopica urgente', 3, 2, 1, 1, 'Estable preparado en ayuno preoperatorio inmediato', 1, 2),
    (3, 2, 3, 24, '2026-09-05 06:40:00-06', 'Embarazo a termino para cesarea electiva programada por macrosomia', 7, 14, 2, 2, 'Gestante en buen estado general con ayuno adecuado', 3, 2),
    (4, 3, 2, 17, '2026-09-10 14:20:00-06', 'Accidente en motocicleta con deformidad y dolor en pierna derecha', 6, 8, 6, 3, 'Politraumatizado consciente con dolor severo e inmovilizacion', 1, 1),
    (5, 3, 3, 23, '2026-09-10 15:30:00-06', 'Fractura diafisiaria de tibia derecha desplazada para osteosintesis', 6, 4, 3, 3, 'Inmovilizado con ferula y analgesia parenteral', 2, 5),
    (6, 3, 4, 32, '2026-09-10 20:00:00-06', 'Recuperacion postoperatoria de osteosintesis tibial y terapia antibiotica', 6, 4, 10, 3, 'Evolucion favorable afebril con herida limpia', 3, 5),
    (7, 8, 2, 16, '2026-09-25 18:10:00-06', 'Cefalea intensa mareo y cifras tensionales elevadas de 175/105', 1, 8, 7, NULL, 'Paciente con urgencia hipertensiva sin dano agudo a organo blanco', 2, 2);

-- Insercion de datos en traslado: Ficha de traslado inter-unidades u hospitales de la red.
INSERT INTO traslado (id_traslado, id_episodio, fecha_hora, id_medico_indica, id_hospital_origen, id_tipo_unidad_origen, id_servicio_origen, id_hospital_destino, id_tipo_unidad_destino, id_servicio_destino, id_ingreso_destino, motivo, consentimiento_otorgado, id_paciente_encargado) VALUES
    (1, 1, '2026-09-01 09:15:00-06', 7, 1, 2, 19, 1, 3, 22, 2, 'Hallazgo ultrasonografico de apendicitis aguda grado II requiere cirugia inmediata', True, 1),
    (2, 3, '2026-09-10 15:15:00-06', 8, 1, 2, 17, 1, 3, 23, 5, 'Fractura cerrada desplazada requiere resolucion quirurgica de urgencia', True, 3),
    (3, 3, '2026-09-10 19:45:00-06', 4, 1, 3, 23, 1, 4, 32, 6, 'Traslado seguro postquirurgico para estancia hospitalaria y fisioterapia', True, 3);

-- Insercion de datos en egreso: Ficha de egreso y alta clinica (cierra el ingreso 1:1).
INSERT INTO egreso (id_egreso, id_ingreso, fecha_hora_egreso, id_diagnostico_principal, motivo_egreso, id_medico, codigo_egreso, egreso_sin_consentimiento, motivo_sin_consentimiento, id_traslado, id_hospital_referido) VALUES
    (1, 1, '2026-09-01 09:25:00-06', 3, 'Traslado a cirugia por cuadro de apendicitis', 7, 'Vivo', False, NULL, 1, NULL),
    (2, 2, '2026-09-03 16:00:00-06', 3, 'Recuperacion postoperatoria exitosa de apendicectomia', 2, 'Vivo', False, NULL, NULL, NULL),
    (3, 3, '2026-09-07 11:00:00-06', 7, 'Puerperio quirurgico mediato sin complicaciones', 14, 'Parto', False, NULL, NULL, NULL),
    (4, 4, '2026-09-10 15:20:00-06', 6, 'Traslado a quirofano de traumatologia', 8, 'Vivo', False, NULL, 2, NULL),
    (5, 5, '2026-09-10 19:50:00-06', 6, 'Traslado a sala de hospitalizacion ortopedica', 4, 'Vivo', False, NULL, 3, NULL),
    (6, 6, '2026-09-16 10:00:00-06', 6, 'Consolidacion de herida y deambulacion asistida', 4, 'Vivo', False, NULL, NULL, NULL),
    (7, 7, '2026-09-27 12:00:00-06', 1, 'Cifras de presion arterial controladas con losartan', 8, 'Vivo', False, NULL, NULL, NULL);

-- Insercion de datos en egreso_diagnostico_secundario: Diagnosticos secundarios al alta.
INSERT INTO egreso_diagnostico_secundario (id_egreso, id_diagnostico) VALUES
    (2, 14),
    (3, 2),
    (6, 15);

-- Insercion de datos en consumo_insumo: Insumos consumidos por el paciente en la estancia.
INSERT INTO consumo_insumo (id_consumo_insumo, id_ingreso, id_insumo, cantidad, fecha_hora, id_personal) VALUES
    (1, 2, 1, 4, '2026-09-01 10:30:00-06', 15),
    (2, 2, 2, 3, '2026-09-01 10:35:00-06', 15),
    (3, 2, 3, 2, '2026-09-01 11:15:00-06', 15),
    (4, 2, 5, 2, '2026-09-01 10:15:00-06', 16),
    (5, 3, 1, 4, '2026-09-05 08:30:00-06', 16),
    (6, 3, 3, 3, '2026-09-05 09:15:00-06', 16),
    (7, 3, 6, 2, '2026-09-05 08:00:00-06', 16),
    (8, 5, 1, 6, '2026-09-10 16:30:00-06', 15),
    (9, 5, 4, 3, '2026-09-10 18:30:00-06', 15),
    (10, 6, 5, 5, '2026-09-11 08:00:00-06', 18),
    (11, 6, 7, 2, '2026-09-11 08:00:00-06', 18);

/* ============================================================================
   M5. CONSULTA EXTERNA
   ============================================================================ */

-- Insercion de datos en cita: Agendamiento ambulatorio y control de cancelaciones.
INSERT INTO cita (id_cita, id_paciente, id_medico, id_clinica, fecha_hora, canal_asignacion, tipo_consulta, id_hospital_referente, estado, fecha_cancelacion, motivo_cancelacion, cancelacion_notificada, id_cita_anterior, id_cita_recargo_origen, creada_en) VALUES
    (1, 4, 5, 2, '2026-09-12 09:00:00-06', 'Recepcion general', 'Primera vez', NULL, 'Realizada', NULL, NULL, NULL, NULL, NULL, '2026-09-10 10:00:00-06'),
    (2, 5, 6, 3, '2026-09-15 09:30:00-06', 'Telefono', 'Reconsulta', NULL, 'Realizada', NULL, NULL, NULL, NULL, NULL, '2026-09-11 11:30:00-06'),
    (3, 6, 7, 4, '2026-09-18 10:30:00-06', 'Correo institucional', 'Referido', 5, 'Realizada', NULL, NULL, NULL, NULL, NULL, '2026-09-14 14:00:00-06'),
    (4, 7, 7, 4, '2026-09-19 08:30:00-06', 'Telefono', 'Primera vez', NULL, 'Cancelada', '2026-09-19 08:00:00-06', 'Incomparecencia del paciente sin aviso previo', False, NULL, NULL, '2026-09-15 09:00:00-06'),
    (5, 7, 7, 4, '2026-09-22 08:30:00-06', 'Recepcion general', 'Primera vez', NULL, 'Realizada', NULL, NULL, NULL, 4, 4, '2026-09-20 09:00:00-06'),
    (6, 1, 1, 1, '2026-09-28 08:30:00-06', 'Recepcion general', 'Primera vez', NULL, 'Programada', NULL, NULL, NULL, NULL, NULL, '2026-09-24 10:00:00-06');

-- Insercion de datos en consulta: Ficha clinica de consulta ambulatoria (1:1 con cita).
INSERT INTO consulta (id_consulta, id_cita, id_episodio, fecha_hora, id_diagnostico, otros_datos_interes, notas_observaciones) VALUES
    (1, 1, 4, '2026-09-12 09:15:00-06', 5, 'Paciente pediatrica presenta tos productiva fiebre de 2 dias y rinorrea', 'Se auscultan estertores crepitantes basales derechos sin cianosis'),
    (2, 2, 5, '2026-09-15 09:40:00-06', 1, 'Control periodico de paciente hipertenso bajo tratamiento regular', 'Cifras tensionales en meta terapeutica asintomatico cardiovascular'),
    (3, 3, 6, '2026-09-18 10:45:00-06', 14, 'Paciente remitida por epigastralgia urente de 3 meses de evolucion', 'Abdomen blando depresible doloroso a palpacion en epigastrio sin irritacion'),
    (4, 5, 7, '2026-09-22 08:45:00-06', 15, 'Dolor punzante lumbosacro desencadenado tras cargar bulto de mercaderia', 'Contractura paravertebral bilateral L4-S1 reflejos osteotendinosos conservados');

-- Insercion de datos en receta: Prescripcion medica emitida al paciente en consulta.
INSERT INTO receta (id_receta, id_consulta, fecha_emision, id_cita_proxima, orientacion_paciente) VALUES
    (1, 1, '2026-09-12', NULL, 'Reposo en cama, abundantes liquidos tibios y vigilancia de signos de alarma'),
    (2, 2, '2026-09-15', NULL, 'Dieta hiposodica estricta, caminata diaria 30 minutos y control de peso'),
    (3, 4, '2026-09-22', NULL, 'Aplicar compresas tibias en zona lumbar y evitar sobrecargas de fuerza');

-- Insercion de datos en receta_detalle: Medicamentos recetados con dosis y duracion.
INSERT INTO receta_detalle (id_receta_detalle, id_receta, id_medicamento, dosis, duracion_dias) VALUES
    (1, 1, 1, '500 mg cada 8 horas por via oral', 7),
    (2, 1, 2, '500 mg cada 8 horas si hay fiebre o malestar', 3),
    (3, 2, 4, '50 mg cada 24 horas por la manana en ayunas', 30),
    (4, 3, 3, '400 mg cada 8 horas despues de alimentos', 5),
    (5, 3, 7, '20 mg cada 24 horas antes del desayuno', 15);

-- Insercion de datos en orden_laboratorio: Ordenes de pruebas diagnosticas en consulta.
INSERT INTO orden_laboratorio (id_orden_laboratorio, id_consulta, fecha_emision, indicaciones) VALUES
    (1, 1, '2026-09-12', 'Realizar en ayuno temprano para recuento leucocitario'),
    (2, 3, '2026-09-18', 'Evaluacion de perfil hematico y quimica sanguinea completa');

-- Insercion de datos en orden_laboratorio_detalle: Examenes prescritos en cada orden.
INSERT INTO orden_laboratorio_detalle (id_orden_laboratorio, id_examen) VALUES
    (1, 1),
    (2, 1),
    (2, 2),
    (2, 4);

/* ============================================================================
   M6. CIRUGIA: PROCESO QUIRURGICO Y CHECKLISTS
   ============================================================================ */

-- Insercion de datos en historia_clinica: Interrogatorio y exploracion sistematizada.
INSERT INTO historia_clinica (id_historia_clinica, id_episodio, id_medico, fecha_hora, tipo_interrogatorio, informante, antecedentes_heredofamiliares, antecedentes_personales_no_patologicos, antecedentes_patologicos, padecimiento_actual, interrogatorio_aparatos_sistemas, sintomas_generales_terapeutica, estudios_previos, id_signos_vitales, exploracion_general, explo_cabeza, explo_cuello, explo_torax, explo_abdomen, explo_extremidades, explo_columna_vertebral, explo_cavidad_bucal, explo_cavidad_vaginal, explo_cavidad_rectal, explo_conducto_auditivo_externo) VALUES
    (1, 1, 1, '2026-09-01 08:30:00-06', 'Directo', NULL, 'Madre hipertensa padre con diabetes tipo 2', 'Vivienda formal con todos los servicios basicos dieta balanceada', 'Niega cirugias previas o alergias medicamentosas', 'Inicia hace 18 horas con dolor periumbilical que migro a fosa iliaca derecha con vomito', 'Aparato digestivo con nauseas y anorexia aparato respiratorio sin sintomas', 'Fiebre no cuantificada automedico analgesico comun sin mejoria', 'Ultrasonido abdominal con imagen en diana compatible con apendicitis', 1, 'Paciente agudo facies dolorosa posicion antalgica cooperador', 'Normocefalo pupilas isocoricas reactivas escleras limpias', 'Movil simetrico no adenopatias ni ingurgitacion yugular', 'Campos pulmonares ventilados ruidos cardiacos ritmicos sin soplos', 'Dolor intenso a palpacion en punto de McBurney signo de Blumberg positivo defensa muscular', 'Tono y fuerza conservados pulsos perifericos presentes simetricos', 'Sin alteraciones posturales palpacion espinosa no dolorosa', 'Mucosa oral deshidratada piezas dentales completas', NULL, 'Tono de esfinter anal conservado ampolla vacia dolor a palpacion anterior', 'Conductos auditivos permeables membranas timpanicas integras'),
    (2, 2, 14, '2026-09-04 09:00:00-06', 'Directo', NULL, 'Sin antecedentes familiares de importancia', 'Alimentacion adecuada vivienda con saneamiento basico', 'Gesta 2 Para 1 Cesarea 0 sin alergias', 'Embarazo de 39 semanas de gestacion acude para resolucion electiva', 'Movimientos fetales activos niega perdidas transvaginales', 'Asintomatica toma vitaminas prenatales y hierro', 'Monitoreo fetal reactivo y biometria ecografica con peso fetal de 3900 g', 3, 'Paciente femenina orientada normohidratada en reposo confortable', 'Facies no caracteristica mucosas humedas', 'Cuello simetrico tiroides no palpable', 'Torax simetrico murmullo vesicular conservado', 'Abdomen globoso por utero gravido altura uterina 36 cm feto unico cefalico FCF 142 lpm', 'Extremidades con edema leve maleolar bilateral pulsos presentes', 'Columna con lordosis fisiologica gestacional conservada', 'Cavidad oral en buen estado higiene adecuada', 'Cuello posterior cerrado formado no sangrado ni liquido', 'No evaluado diferido', 'Pabellones auriculares bien implantados conductos libres'),
    (3, 3, 4, '2026-09-10 14:45:00-06', 'Indirecto', 'Juana Maria Tzun Batres (Madre)', 'Padre fallecido por enfermedad cardiaca madre aparentemente sana', 'Trabajador de comercio viaja frecuentemente en motocicleta', 'Niega antecedentes medicos cronicos refiere fractura de clavicula en la infancia', 'Sufre colision en motocicleta contra vehiculo hace 1 hora presentando dolor intenso y deformidad', 'Perdida de fuerza funcional en extremidad inferior derecha no perdida de conciencia', 'Administraron analgesico en ambulancia de bomberos', 'Radiografia de pierna derecha muestra fractura diafisiaria de tibia conminuta cerrada', 4, 'Paciente quejumbroso inmovilizado con ferula posterior algico pero reactivo', 'Craneo sin heridas evidentes no hematomas epicraneales', 'Cuello con collarin blando alineado sin crepitacion', 'Torax con buena expansion auscultacion simetrica', 'Abdomen plano blando no doloroso ruidos hidroaereos presentes', 'Extremidad inferior derecha con deformidad en tercio medio de tibia edema severo pulsos distales presentes', 'Eje vertebral alineado sin dolor a palpacion superficial', 'Dentadura integra sin cuerpos extranos', NULL, 'No evaluado', 'Conductos auditivos sin otorragia'),
    (4, 5, 12, '2026-09-16 10:00:00-06', 'Directo', NULL, 'Padre fallecido por infarto agudo al miocardio a los 55 anos', 'Tabaquismo suspendido hace 5 anos sedentario', 'Hipertension arterial de 15 anos de evolucion', 'Disnea de medianos esfuerzos y dolor precordial opresivo ocasional', 'Aparato cardiovascular con palpitaciones gastrointestinal sin cambios', 'En tratamiento con Losartan y Aspirina', 'Electrocardiograma con cambios isquemicos anterolaterales', 7, 'Paciente masculino en decubito supino consciente y orientado', 'Sin alteraciones morfologicas', 'Pulso carotideo amplio simetrico', 'Ruidos cardiacos apagados ritmo de galope ocasional', 'Abdomen globoso blando no doloroso', 'Extremidades con edema maleolar grado I', 'Columna dorsal sin desviaciones', 'Mucosa semihumeda', NULL, 'No evaluado', 'Normoyentes');

-- Insercion de datos en solicitud_cirugia: Solicitudes formales de intervencion quirurgica.
INSERT INTO solicitud_cirugia (id_solicitud_cirugia, id_episodio, id_historia_clinica, id_cirujano, caracter, id_tipo_anestesia, tiempo_estimado_min, fecha_hora_solicitud) VALUES
    (1, 1, 1, 2, 'Urgente', 1, 60, '2026-09-01 09:35:00-06'),
    (2, 2, 2, 14, 'Programado', 2, 75, '2026-09-04 10:00:00-06'),
    (3, 3, 3, 4, 'Urgente', 2, 120, '2026-09-10 15:35:00-06'),
    (4, 5, 4, 12, 'Programado', 1, 240, '2026-09-16 11:00:00-06');

-- Insercion de datos en solicitud_procedimiento: Procedimientos requeridos en cada solicitud.
INSERT INTO solicitud_procedimiento (id_solicitud_cirugia, id_procedimiento) VALUES
    (1, 1),
    (2, 5),
    (3, 4),
    (4, 6);

-- Insercion de datos en solicitud_insumo: Insumos consumibles con cantidad estimada.
INSERT INTO solicitud_insumo (id_solicitud_cirugia, id_insumo, cantidad) VALUES
    (1, 1, 4),
    (1, 2, 4),
    (1, 3, 2),
    (1, 5, 2),
    (2, 1, 4),
    (2, 2, 4),
    (2, 3, 3),
    (2, 6, 2),
    (3, 1, 6),
    (3, 2, 6),
    (3, 4, 3),
    (3, 5, 3),
    (4, 1, 6),
    (4, 2, 8),
    (4, 14, 1);

-- Insercion de datos en solicitud_instrumento: Instrumental quirurgico solicitado con cantidad.
INSERT INTO solicitud_instrumento (id_solicitud_cirugia, id_instrumento, cantidad) VALUES
    (1, 1, 1),
    (1, 2, 1),
    (1, 4, 2),
    (1, 11, 1),
    (2, 1, 1),
    (2, 3, 1),
    (2, 9, 1),
    (2, 10, 2),
    (3, 1, 1),
    (3, 8, 2),
    (3, 6, 4),
    (3, 10, 2),
    (4, 1, 1),
    (4, 2, 2),
    (4, 6, 6);

-- Insercion de datos en solicitud_equipo: Equipos biomedicos solicitados para la intervencion.
INSERT INTO solicitud_equipo (id_solicitud_cirugia, id_equipo, cantidad) VALUES
    (1, 1, 1),
    (1, 2, 1),
    (1, 4, 1),
    (2, 1, 1),
    (2, 2, 1),
    (2, 3, 1),
    (3, 1, 1),
    (3, 2, 1),
    (3, 8, 1),
    (4, 1, 1),
    (4, 2, 1),
    (4, 7, 2);

-- Insercion de datos en revision_solicitud: Dictamen de aprobacion o rechazo del comite medico.
INSERT INTO revision_solicitud (id_revision, id_solicitud_cirugia, decision, fecha_hora, razones) VALUES
    (1, 1, 'Aprobada', '2026-09-01 09:45:00-06', NULL),
    (2, 2, 'Aprobada', '2026-09-04 14:00:00-06', NULL),
    (3, 3, 'Aprobada', '2026-09-10 15:45:00-06', NULL),
    (4, 4, 'Rechazada', '2026-09-17 09:00:00-06', 'Paciente presenta descompensacion hemodinamica y requiere estabilizacion previa con cateterismo diagnostico antes de cirugia mayor');

-- Insercion de datos en revision_miembro_comite: Medicos que evaluaron la solicitud quirurgica.
INSERT INTO revision_miembro_comite (id_revision, id_medico) VALUES
    (1, 1),
    (1, 3),
    (2, 1),
    (2, 14),
    (3, 1),
    (3, 4),
    (4, 1),
    (4, 6);

-- Insercion de datos en cirugia: Cirugias agendadas en quirofano con control de tiempos.
INSERT INTO cirugia (id_cirugia, id_solicitud_cirugia, id_quirofano, inicio_programado, fin_programado, inicio_real, fin_real, estado, id_ingreso, condicion_evolucion) VALUES
    (1, 1, 1, '2026-09-01 10:00:00-06', '2026-09-01 12:00:00-06', '2026-09-01 10:10:00-06', '2026-09-01 11:45:00-06', 'Finalizada', 2, 'Sin complicaciones'),
    (2, 2, 2, '2026-09-05 08:00:00-06', '2026-09-05 10:00:00-06', '2026-09-05 08:15:00-06', '2026-09-05 09:40:00-06', 'Finalizada', 3, 'Sin complicaciones'),
    (3, 3, 3, '2026-09-10 16:00:00-06', '2026-09-10 19:30:00-06', '2026-09-10 16:15:00-06', '2026-09-10 19:10:00-06', 'Finalizada', 5, 'Sin complicaciones');

-- Insercion de datos en cirugia_equipo_medico: Equipo de salud en quirofano con rol acreditado.
INSERT INTO cirugia_equipo_medico (id_cirugia, id_personal, rol) VALUES
    (1, 2, 'Cirujano principal'),
    (1, 9, 'Cirujano ayudante'),
    (1, 3, 'Anestesiologo'),
    (1, 15, 'Enfermero instrumentista'),
    (1, 16, 'Enfermero circulante'),
    (1, 20, 'Practicante de medicina'),
    (1, 23, 'Practicante de enfermeria'),
    (2, 14, 'Cirujano principal'),
    (2, 1, 'Cirujano ayudante'),
    (2, 3, 'Anestesiologo'),
    (2, 16, 'Enfermero instrumentista'),
    (2, 17, 'Enfermero circulante'),
    (3, 4, 'Cirujano principal'),
    (3, 11, 'Cirujano ayudante'),
    (3, 3, 'Anestesiologo'),
    (3, 15, 'Enfermero instrumentista'),
    (3, 18, 'Enfermero circulante');

-- Insercion de datos en consentimiento_informado: Consentimiento quirurgico firmado y autorizado.
INSERT INTO consentimiento_informado (id_consentimiento, id_cirugia, nombre_procedimiento, objetivo_procedimiento, caracteristicas_procedimiento, riesgos_procedimiento, id_medico, firmado_por_medico, firmante_tipo, id_paciente_encargado, firmado_por_firmante, fecha_obtencion) VALUES
    (1, 1, 'Apendicectomia videolaparoscopica', 'Extirpacion del apendice inflamado para evitar peritonitis', 'Abordaje mediante 3 puertos de laparoscopia bajo anestesia general', 'Sangrado infeccion de sitio quirurgico dano a asas intestinales', 2, True, 'Paciente', NULL, True, '2026-09-01 09:40:00-06'),
    (2, 2, 'Cesarea segmentaria transperitoneal', 'Nacimiento seguro de feto y extraccion de placenta', 'Incision transversa de Pfannenstiel e histerotomia bajo bloqueo regional', 'Hemorragia postparto atonia uterina infeccion de herida', 14, True, 'Paciente', NULL, True, '2026-09-04 10:15:00-06'),
    (3, 3, 'Osteosintesis de fractura de tibia', 'Alineacion anatomica y fijacion rigida de fragmentos oseos', 'Incision anteromedial en pierna reduccion y colocacion de placa LCP', 'No consolidacion infeccion oseomielitis lesion vasculo-nerviosa', 4, True, 'Familiar', 3, True, '2026-09-10 15:40:00-06');

-- Insercion de datos en evaluacion_preanestesica: Evaluacion de riesgo quirurgico escala ASA.
INSERT INTO evaluacion_preanestesica (id_evaluacion, id_cirugia, clasificacion_asa, id_medico_clasifica, firmado_medico_clasifica, plan_anestesia, id_anestesiologo, fecha_hora) VALUES
    (1, 1, 2, 2, True, 'Induccion intravenosa con fentanilo propofol intubacion orotraqueal y mantenimiento inhalatorio', 3, '2026-09-01 09:45:00-06'),
    (2, 2, 1, 14, True, 'Anestesia subaracnoidea con bupivacaina pesada 0.5% mas fentanilo a nivel L3-L4', 3, '2026-09-04 10:30:00-06'),
    (3, 3, 2, 4, True, 'Bloqueo neuroaxial raquideo con bupivacaina e isquemia controlada en muslo derecho', 3, '2026-09-10 15:45:00-06');

-- Insercion de datos en cirugia_verificacion: Registro de cada item del checklist por enfermeria.
INSERT INTO cirugia_verificacion (id_verificacion, id_cirugia, id_item, resultado, detalle, fecha_hora_registro, id_enfermero) VALUES
    (1, 1, 1, 'Exito', 'Tabla quirurgica revisada', '2026-09-01 09:50:00-06', 15),
    (2, 1, 2, 'Exito', 'Torre y equipos probados', '2026-09-01 09:55:00-06', 15),
    (3, 1, 3, 'Exito', 'Paciente recibido en quirofano', '2026-09-01 10:05:00-06', 15),
    (4, 1, 4, 'Exito', 'Brazalete verificado con DPI', '2026-09-01 10:08:00-06', 15),
    (5, 1, 5, 'Exito', 'Consentimiento revisado', '2026-09-01 10:09:00-06', 15),
    (6, 1, 6, 'Exito', 'Arsenal esteril confirmado', '2026-09-01 10:10:00-06', 15),
    (7, 1, 7, 'Exito', 'Farmacos anestesicos listos', '2026-09-01 10:10:00-06', 15),
    (8, 1, 8, 'Exito', 'Equipo quirurgico completo', '2026-09-01 10:12:00-06', 16),
    (9, 1, 9, 'Exito', 'Traslado a mesa operatoria', '2026-09-01 10:13:00-06', 16),
    (10, 1, 10, 'Exito', 'Posicion decubito supino', '2026-09-01 10:14:00-06', 16),
    (11, 1, 11, 'Exito', 'Placa en muslo izquierdo', '2026-09-01 10:15:00-06', 16),
    (12, 1, 12, 'Exito', 'Identidad confirmada en voz alta', '2026-09-01 10:18:00-06', 15),
    (13, 1, 13, 'Exito', 'Esterilidad verificada', '2026-09-01 10:19:00-06', 15),
    (14, 1, 14, 'Exito', 'Maquina de anestesia comprobada', '2026-09-01 10:19:00-06', 15),
    (15, 1, 15, 'Exito', 'Cirujano explico tecnica', '2026-09-01 10:20:00-06', 15),
    (16, 1, 16, 'Exito', 'Incision umbilical realizada', '2026-09-01 10:21:00-06', 15),
    (17, 1, 17, 'Aceptable', 'Balance hidrico neutro', '2026-09-01 11:30:00-06', 16),
    (18, 1, 18, 'Aceptable', 'Antibiotico profilactico administrado', '2026-09-01 11:35:00-06', 16),
    (19, 1, 19, 'Aceptable', 'Sin necesidad de transfusion', '2026-09-01 11:35:00-06', 16),
    (20, 1, 20, 'Exito', 'Fin de cirugia anunciado', '2026-09-01 11:40:00-06', 15),
    (21, 1, 21, 'Exito', 'Apendicectomia completada', '2026-09-01 11:42:00-06', 15),
    (22, 1, 22, 'Exito', 'Conteo de gasas completo 20/20', '2026-09-01 11:43:00-06', 15),
    (23, 1, 23, 'Exito', 'Sutura de piel con Nylon', '2026-09-01 11:45:00-06', 15),
    (24, 1, 24, 'Aceptable', 'Sin complicaciones transoperatorias', '2026-09-01 11:55:00-06', 15),
    (25, 1, 25, 'Exito', 'Cama de recuperacion asignada', '2026-09-01 11:56:00-06', 15),
    (26, 1, 26, 'Exito', 'Oxigeno y monitor instalados', '2026-09-01 11:57:00-06', 15),
    (27, 1, 27, 'Exito', 'Enfermera de recuperacion a cargo', '2026-09-01 11:58:00-06', 15),
    (28, 1, 28, 'Exito', 'Analgesia postoperatoria en perfusion', '2026-09-01 11:59:00-06', 15),
    (29, 1, 29, 'Exito', 'Presion 115/75 pulso 76', '2026-09-01 13:00:00-06', 15),
    (30, 1, 30, 'Exito', 'Apositos limpios y secos', '2026-09-01 13:00:00-06', 15),
    (31, 1, 31, 'Exito', 'Expediente completo', '2026-09-01 13:01:00-06', 15),
    (32, 1, 32, 'Exito', 'Solucion salina pasando permeable', '2026-09-01 13:02:00-06', 15);

-- Insercion de datos en cirugia_documento_fase: Cierre por fase enviado a secretaria.
INSERT INTO cirugia_documento_fase (id_documento, id_cirugia, fase, id_enfermero, fecha_envio_secretaria) VALUES
    (1, 1, 'Preoperatorio', 15, '2026-09-01'),
    (2, 1, 'Intraoperatorio', 15, '2026-09-01'),
    (3, 1, 'Postoperatorio', 15, '2026-09-01'),
    (4, 2, 'Preoperatorio', 16, '2026-09-05'),
    (5, 2, 'Intraoperatorio', 16, '2026-09-05'),
    (6, 2, 'Postoperatorio', 16, '2026-09-05'),
    (7, 3, 'Preoperatorio', 15, '2026-09-10'),
    (8, 3, 'Intraoperatorio', 15, '2026-09-10'),
    (9, 3, 'Postoperatorio', 15, '2026-09-10');

/* ============================================================================
   M7. FACTURACION Y PAGOS
   ============================================================================ */

-- Insercion de datos en tarifa_servicio: Arancel hospitalario por atencion y por dia.
INSERT INTO tarifa_servicio (id_hospital, id_servicio, costo_atencion, costo_dia) VALUES
    (1, 1, 350.00, NULL),
    (1, 7, 150.00, NULL),
    (1, 12, 200.00, NULL),
    (1, 16, 400.00, 300.00),
    (1, 17, 600.00, 350.00),
    (1, 19, 250.00, 200.00),
    (1, 22, 1500.00, 400.00),
    (1, 23, 1800.00, 450.00),
    (1, 24, 1600.00, 400.00),
    (1, 26, 2200.00, 450.00),
    (1, 32, 500.00, 350.00),
    (1, 28, 450.00, 300.00);

-- Insercion de datos en tarifa_procedimiento: Costo fijado por hospital por intervencion.
INSERT INTO tarifa_procedimiento (id_hospital, id_procedimiento, costo) VALUES
    (1, 1, 4500.00),
    (1, 2, 5500.00),
    (1, 3, 3800.00),
    (1, 4, 6500.00),
    (1, 5, 4200.00),
    (1, 6, 25000.00);

-- Insercion de datos en tarifa_insumo: Precio unitario de insumos por hospital.
INSERT INTO tarifa_insumo (id_hospital, id_insumo, precio_unitario) VALUES
    (1, 1, 25.00),
    (1, 2, 30.00),
    (1, 3, 85.00),
    (1, 4, 65.00),
    (1, 5, 40.00),
    (1, 6, 45.00),
    (1, 7, 20.00);

-- Insercion de datos en factura: Comprobante contable de servicios con plan de cuotas.
INSERT INTO factura (id_factura, serie, numero_factura, id_episodio, fecha_emision, nit_cliente, nombre_cliente, descripcion, numero_cuotas, id_personal_emite, estado) VALUES
    (1, 'A', 'FAC-0001', 4, '2026-09-12 11:15:00-06', 'CF', 'Sofia Elizabeth Cux Morales', 'Servicios ambulatorios de consulta pediatrica y emision de receta', 1, 25, 'Emitida'),
    (2, 'A', 'FAC-0002', 5, '2026-09-15 10:30:00-06', '45879632', 'Pedro Francisco Pop Chan', 'Reconsulta de especialidad en cardiologia con tarifa preferencial', 1, 25, 'Emitida'),
    (3, 'A', 'FAC-0003', 7, '2026-09-22 10:15:00-06', 'CF', 'Mario Rene Gomez Vasquez', 'Consulta de medicina general con recargo por cita anterior no avisada', 1, 25, 'Emitida'),
    (4, 'A', 'FAC-0004', 1, '2026-09-03 15:30:00-06', '78965412', 'Jose Miguel Yax Ixcoy', 'Atencion de urgencia intervencion videolaparoscopica y estancia en sala', 6, 27, 'Emitida'),
    (5, 'A', 'FAC-0005', 3, '2026-09-16 09:30:00-06', '12589634', 'Juan Carlos Chaj Tzun', 'Atencion politraumatizado cirugia ortopedica mayor y hospitalizacion prolongada', 12, 26, 'Emitida');

-- Insercion de datos en factura_detalle: Renglones de cobro con cantidad, precio y porcentaje.
INSERT INTO factura_detalle (id_factura_detalle, id_factura, concepto, descripcion, cantidad, precio_unitario, porcentaje_aplicado, id_consulta, id_ingreso, id_cirugia) VALUES
    (1, 1, 'Consulta', 'Consulta medica pediatrica primera vez', 1.00, 200.00, 100.00, 1, NULL, NULL),
    (2, 2, 'Consulta', 'Reconsulta especializada de cardiologia', 1.00, 350.00, 75.00, 2, NULL, NULL),
    (3, 3, 'Consulta', 'Consulta de medicina general con recargo del 10%', 1.00, 150.00, 110.00, 4, NULL, NULL),
    (4, 4, 'Cirugia', 'Procedimiento apendicectomia videolaparoscopica', 1.00, 4500.00, 100.00, NULL, NULL, 1),
    (5, 4, 'Emergencia', 'Atencion de estabilizacion y observacion inicial', 1.00, 250.00, 100.00, NULL, 1, NULL),
    (6, 4, 'Dias de internamiento', 'Estancia quirurgica postoperatoria (2 dias)', 2.00, 450.00, 100.00, NULL, 2, NULL),
    (7, 4, 'Insumos', 'Paquete de insumos quirurgicos y suturas', 1.00, 435.00, 100.00, NULL, NULL, NULL),
    (8, 5, 'Cirugia', 'Procedimiento osteosintesis de fractura de tibia', 1.00, 6500.00, 100.00, NULL, NULL, 3),
    (9, 5, 'Emergencia', 'Atencion de paciente politraumatizado', 1.00, 600.00, 100.00, NULL, 4, NULL),
    (10, 5, 'Dias de internamiento', 'Dias de internamiento ortopedia (6 dias)', 6.00, 350.00, 100.00, NULL, 6, NULL),
    (11, 5, 'Insumos', 'Material descartable ferulas y sueros de internamiento', 1.00, 650.00, 100.00, NULL, NULL, NULL);

-- Insercion de datos en pago: Cobro de cuotas amortizadas en caja con metodo de pago.
INSERT INTO pago (id_pago, id_factura, numero_cuota, monto, fecha_pago, id_metodo_pago, id_unidad_hospital, id_personal_recibe, referencia) VALUES
    (1, 1, 1, 200.00, '2026-09-12 11:20:00-06', 1, 1, 25, 'REC-CE-1001'),
    (2, 2, 1, 262.50, '2026-09-15 10:35:00-06', 2, 1, 25, 'POS-VISA-45892'),
    (3, 3, 1, 165.00, '2026-09-22 10:20:00-06', 1, 1, 25, 'REC-CE-1002'),
    (4, 4, 1, 1122.50, '2026-09-03 15:45:00-06', 3, 3, 27, 'TC-MASTERCARD-7814'),
    (5, 4, 2, 1122.50, '2026-09-28 10:00:00-06', 4, 3, 27, 'TRANSF-BANRURAL-98451'),
    (6, 5, 1, 820.83, '2026-09-16 09:45:00-06', 4, 4, 26, 'TRANSF-BI-332154'),
    (7, 5, 2, 820.83, '2026-09-27 11:30:00-06', 2, 4, 26, 'POS-VISA-98741');

/* ============================================================================
   M8. CALIDAD DEL SERVICIO
   ============================================================================ */

-- Insercion de datos en calificacion_hospital: Puntuacion (1-5) sobre la atencion del hospital.
INSERT INTO calificacion_hospital (id_calificacion_hospital, id_episodio, puntuacion, comentario, fecha_hora) VALUES
    (1, 1, 5, 'Excelente atencion en la emergencia y rapida intervencion en el quirofano personal muy atento', '2026-09-03 16:30:00-06'),
    (2, 3, 4, 'Muy buena atencion del equipo de traumatologia y las enfermeras de la sala de hospitalizacion', '2026-09-16 10:30:00-06'),
    (3, 4, 5, 'La doctora pediatra fue muy carinosa y explico con claridad el tratamiento para mi hija', '2026-09-12 11:45:00-06'),
    (4, 7, 4, 'Buena atencion en clinica general aunque hubo que esperar unos minutos antes de pasar', '2026-09-22 10:45:00-06');

-- Insercion de datos en calificacion_personal: Calificacion individual a medicos, enfermeros o encargados.
INSERT INTO calificacion_personal (id_calificacion_personal, id_episodio, id_personal, puntuacion, comentario, fecha_hora) VALUES
    (1, 1, 2, 5, 'Cirujano muy profesional y acertado en la apendicectomia laparoscopica', '2026-09-03 16:35:00-06'),
    (2, 1, 15, 5, 'Enfermera muy humana y pendiente de la recuperacion del dolor', '2026-09-03 16:35:00-06'),
    (3, 3, 4, 5, 'Excelente cirujano ortopedista la cirugia de pierna fue un exito', '2026-09-16 10:35:00-06'),
    (4, 4, 5, 5, 'Dra pediatra muy paciente y acertada con el medicamento de la nina', '2026-09-12 11:50:00-06'),
    (5, 5, 6, 5, 'Atencion cordial y excelente control de la presion arterial en cardiologia', '2026-09-15 11:00:00-06'),
    (6, 4, 25, 4, 'Amable y rapida en la asignacion de la cita y cobro en recepcion', '2026-09-12 11:55:00-06');

/* ============================================================================
   ============================================================================ */

SELECT setval(pg_get_serial_sequence('departamento', 'id_departamento'), COALESCE((SELECT MAX(id_departamento) FROM departamento), 1));
SELECT setval(pg_get_serial_sequence('municipio', 'id_municipio'), COALESCE((SELECT MAX(id_municipio) FROM municipio), 1));
SELECT setval(pg_get_serial_sequence('direccion', 'id_direccion'), COALESCE((SELECT MAX(id_direccion) FROM direccion), 1));
SELECT setval(pg_get_serial_sequence('parentesco', 'id_parentesco'), COALESCE((SELECT MAX(id_parentesco) FROM parentesco), 1));
SELECT setval(pg_get_serial_sequence('especialidad', 'id_especialidad'), COALESCE((SELECT MAX(id_especialidad) FROM especialidad), 1));
SELECT setval(pg_get_serial_sequence('diagnostico', 'id_diagnostico'), COALESCE((SELECT MAX(id_diagnostico) FROM diagnostico), 1));
SELECT setval(pg_get_serial_sequence('tipo_unidad', 'id_tipo_unidad'), COALESCE((SELECT MAX(id_tipo_unidad) FROM tipo_unidad), 1));
SELECT setval(pg_get_serial_sequence('servicio_medico', 'id_servicio'), COALESCE((SELECT MAX(id_servicio) FROM servicio_medico), 1));
SELECT setval(pg_get_serial_sequence('turno', 'id_turno'), COALESCE((SELECT MAX(id_turno) FROM turno), 1));
SELECT setval(pg_get_serial_sequence('metodo_pago', 'id_metodo_pago'), COALESCE((SELECT MAX(id_metodo_pago) FROM metodo_pago), 1));
SELECT setval(pg_get_serial_sequence('medicamento', 'id_medicamento'), COALESCE((SELECT MAX(id_medicamento) FROM medicamento), 1));
SELECT setval(pg_get_serial_sequence('examen_laboratorio', 'id_examen'), COALESCE((SELECT MAX(id_examen) FROM examen_laboratorio), 1));
SELECT setval(pg_get_serial_sequence('tipo_anestesia', 'id_tipo_anestesia'), COALESCE((SELECT MAX(id_tipo_anestesia) FROM tipo_anestesia), 1));
SELECT setval(pg_get_serial_sequence('procedimiento_quirurgico', 'id_procedimiento'), COALESCE((SELECT MAX(id_procedimiento) FROM procedimiento_quirurgico), 1));
SELECT setval(pg_get_serial_sequence('insumo', 'id_insumo'), COALESCE((SELECT MAX(id_insumo) FROM insumo), 1));
SELECT setval(pg_get_serial_sequence('instrumento', 'id_instrumento'), COALESCE((SELECT MAX(id_instrumento) FROM instrumento), 1));
SELECT setval(pg_get_serial_sequence('equipo', 'id_equipo'), COALESCE((SELECT MAX(id_equipo) FROM equipo), 1));
SELECT setval(pg_get_serial_sequence('momento_quirurgico', 'id_momento'), COALESCE((SELECT MAX(id_momento) FROM momento_quirurgico), 1));
SELECT setval(pg_get_serial_sequence('item_verificacion', 'id_item'), COALESCE((SELECT MAX(id_item) FROM item_verificacion), 1));
SELECT setval(pg_get_serial_sequence('hospital', 'id_hospital'), COALESCE((SELECT MAX(id_hospital) FROM hospital), 1));
SELECT setval(pg_get_serial_sequence('unidad_hospital', 'id_unidad_hospital'), COALESCE((SELECT MAX(id_unidad_hospital) FROM unidad_hospital), 1));
SELECT setval(pg_get_serial_sequence('espacio_atencion', 'id_espacio'), COALESCE((SELECT MAX(id_espacio) FROM espacio_atencion), 1));
SELECT setval(pg_get_serial_sequence('clinica', 'id_clinica'), COALESCE((SELECT MAX(id_clinica) FROM clinica), 1));
SELECT setval(pg_get_serial_sequence('persona', 'id_persona'), COALESCE((SELECT MAX(id_persona) FROM persona), 1));
SELECT setval(pg_get_serial_sequence('paciente', 'id_paciente'), COALESCE((SELECT MAX(id_paciente) FROM paciente), 1));
SELECT setval(pg_get_serial_sequence('paciente_encargado', 'id_paciente_encargado'), COALESCE((SELECT MAX(id_paciente_encargado) FROM paciente_encargado), 1));
SELECT setval(pg_get_serial_sequence('personal', 'id_personal'), COALESCE((SELECT MAX(id_personal) FROM personal), 1));
SELECT setval(pg_get_serial_sequence('asignacion_personal', 'id_asignacion'), COALESCE((SELECT MAX(id_asignacion) FROM asignacion_personal), 1));
SELECT setval(pg_get_serial_sequence('horario_medico', 'id_horario'), COALESCE((SELECT MAX(id_horario) FROM horario_medico), 1));
SELECT setval(pg_get_serial_sequence('episodio', 'id_episodio'), COALESCE((SELECT MAX(id_episodio) FROM episodio), 1));
SELECT setval(pg_get_serial_sequence('registro_signos_vitales', 'id_signos_vitales'), COALESCE((SELECT MAX(id_signos_vitales) FROM registro_signos_vitales), 1));
SELECT setval(pg_get_serial_sequence('ingreso', 'id_ingreso'), COALESCE((SELECT MAX(id_ingreso) FROM ingreso), 1));
SELECT setval(pg_get_serial_sequence('traslado', 'id_traslado'), COALESCE((SELECT MAX(id_traslado) FROM traslado), 1));
SELECT setval(pg_get_serial_sequence('egreso', 'id_egreso'), COALESCE((SELECT MAX(id_egreso) FROM egreso), 1));
SELECT setval(pg_get_serial_sequence('consumo_insumo', 'id_consumo_insumo'), COALESCE((SELECT MAX(id_consumo_insumo) FROM consumo_insumo), 1));
SELECT setval(pg_get_serial_sequence('cita', 'id_cita'), COALESCE((SELECT MAX(id_cita) FROM cita), 1));
SELECT setval(pg_get_serial_sequence('consulta', 'id_consulta'), COALESCE((SELECT MAX(id_consulta) FROM consulta), 1));
SELECT setval(pg_get_serial_sequence('receta', 'id_receta'), COALESCE((SELECT MAX(id_receta) FROM receta), 1));
SELECT setval(pg_get_serial_sequence('receta_detalle', 'id_receta_detalle'), COALESCE((SELECT MAX(id_receta_detalle) FROM receta_detalle), 1));
SELECT setval(pg_get_serial_sequence('orden_laboratorio', 'id_orden_laboratorio'), COALESCE((SELECT MAX(id_orden_laboratorio) FROM orden_laboratorio), 1));
SELECT setval(pg_get_serial_sequence('historia_clinica', 'id_historia_clinica'), COALESCE((SELECT MAX(id_historia_clinica) FROM historia_clinica), 1));
SELECT setval(pg_get_serial_sequence('solicitud_cirugia', 'id_solicitud_cirugia'), COALESCE((SELECT MAX(id_solicitud_cirugia) FROM solicitud_cirugia), 1));
SELECT setval(pg_get_serial_sequence('revision_solicitud', 'id_revision'), COALESCE((SELECT MAX(id_revision) FROM revision_solicitud), 1));
SELECT setval(pg_get_serial_sequence('cirugia', 'id_cirugia'), COALESCE((SELECT MAX(id_cirugia) FROM cirugia), 1));
SELECT setval(pg_get_serial_sequence('consentimiento_informado', 'id_consentimiento'), COALESCE((SELECT MAX(id_consentimiento) FROM consentimiento_informado), 1));
SELECT setval(pg_get_serial_sequence('evaluacion_preanestesica', 'id_evaluacion'), COALESCE((SELECT MAX(id_evaluacion) FROM evaluacion_preanestesica), 1));
SELECT setval(pg_get_serial_sequence('cirugia_verificacion', 'id_verificacion'), COALESCE((SELECT MAX(id_verificacion) FROM cirugia_verificacion), 1));
SELECT setval(pg_get_serial_sequence('cirugia_documento_fase', 'id_documento'), COALESCE((SELECT MAX(id_documento) FROM cirugia_documento_fase), 1));
SELECT setval(pg_get_serial_sequence('factura', 'id_factura'), COALESCE((SELECT MAX(id_factura) FROM factura), 1));
SELECT setval(pg_get_serial_sequence('factura_detalle', 'id_factura_detalle'), COALESCE((SELECT MAX(id_factura_detalle) FROM factura_detalle), 1));
SELECT setval(pg_get_serial_sequence('pago', 'id_pago'), COALESCE((SELECT MAX(id_pago) FROM pago), 1));
SELECT setval(pg_get_serial_sequence('calificacion_hospital', 'id_calificacion_hospital'), COALESCE((SELECT MAX(id_calificacion_hospital) FROM calificacion_hospital), 1));
SELECT setval(pg_get_serial_sequence('calificacion_personal', 'id_calificacion_personal'), COALESCE((SELECT MAX(id_calificacion_personal) FROM calificacion_personal), 1));

-- FIN
