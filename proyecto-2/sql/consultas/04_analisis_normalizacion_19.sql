-- ============================================================================
-- OBJETIVO 19: Analisis de normalizacion y DDL para Reporte_Cirugia
-- ============================================================================

/*
1. DIAGNOSTICO DE FORMAS NORMALES

Tabla original monolytica:
Reporte_Cirugia(
    Id_cirugia, 
    Nombre_cirujano, 
    Especialidad_cirujano, 
    Nombre_paciente, 
    Codigo_diagnostico, 
    Descripcion_diagnostico, 
    Nombre_insumo_1, 
    Cantidad_insumo_1, 
    Nombre_insumo_2, 
    Cantidad_insumo_2, 
    Fecha
)

A. Violacion de la Primera Forma Normal (1FN):
- Grupos repetitivos: Columnas numeradas para insumos (insumo_1, insumo_2).
- Falta de atomicidad: Restringe a un maximo arbitrario de 2 insumos por intervencion.
- Nulos innecesarios: Si una cirugia usa un solo insumo o ninguno, deja campos NULL.

B. Violacion de la Segunda Forma Normal (2FN):
- Dependencias funcionales parciales respecto a la clave del evento quirurgico.
- Datos de catalogo (diagnostico, insumo, cirujano) quedan atados a la tupla del reporte.

C. Violacion de la Tercera Forma Normal (3FN):
- Dependencias transitivas entre atributos no primos:
  Id_cirugia -> Id_cirujano -> (Nombre_cirujano, Especialidad_cirujano)
  Id_cirugia -> Codigo_diagnostico -> Descripcion_diagnostico
  Id_cirugia -> Id_paciente -> Nombre_paciente


2. ANOMALIAS OPERATIVAS IDENTIFICADAS

- Anomalia de Insercion:
  No se puede registrar un nuevo cirujano, paciente, diagnostico o insumo en el catalogo
  sin tener una cirugia ficticia realizada.

- Anomalia de Modificacion:
  Si la descripcion de un diagnostico o la especialidad de un cirujano cambia, 
  se debe actualizar en cientos de filas historicas. De lo contrario se genera inconsistencia.

- Anomalia de Eliminacion:
  Si se borra una cirugia cancelada por error, se pierde la informacion del diagnostico
  o de los insumos si no existian en otra intervencion.


3. PROPUESTA DE DESCOMPOSICION EN TERCERA FORMA NORMAL (3FN)

Se divide el reporte en 6 tablas atomicas con integridad referencial:
1. diagnostico (catalogo formal de patologias)
2. paciente (sujeto de atencion)
3. cirujano (personal facultativo)
4. insumo (catalogo de materiales quirurgicos)
5. cirugia (evento o acto quirurgico principal)
6. cirugia_insumo (relacion N:M con cantidad consumida)
*/

-- ============================================================================
-- DDL DE IMPLEMENTACION PROPUESTA (3FN)
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS normalizacion_cirugia;
SET search_path TO normalizacion_cirugia, public;

-- 1. Diagnostico
CREATE TABLE IF NOT EXISTS diagnostico (
    id_diagnostico INTEGER GENERATED ALWAYS AS IDENTITY,
    codigo_diagnostico VARCHAR(20) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    CONSTRAINT pk_norm_diagnostico PRIMARY KEY (id_diagnostico),
    CONSTRAINT uq_norm_diag_codigo UNIQUE (codigo_diagnostico),
    CONSTRAINT ck_norm_diag_codigo CHECK (length(trim(codigo_diagnostico)) >= 2),
    CONSTRAINT ck_norm_diag_desc CHECK (length(trim(descripcion)) >= 3)
);

-- 2. Paciente
CREATE TABLE IF NOT EXISTS paciente (
    id_paciente INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(150) NOT NULL,
    CONSTRAINT pk_norm_paciente PRIMARY KEY (id_paciente),
    CONSTRAINT ck_norm_pac_nombre CHECK (length(trim(nombre)) >= 3)
);

-- 3. Cirujano
CREATE TABLE IF NOT EXISTS cirujano (
    id_cirujano INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(150) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,
    CONSTRAINT pk_norm_cirujano PRIMARY KEY (id_cirujano),
    CONSTRAINT ck_norm_cir_nombre CHECK (length(trim(nombre)) >= 3),
    CONSTRAINT ck_norm_cir_esp CHECK (length(trim(especialidad)) >= 3)
);

-- 4. Insumo
CREATE TABLE IF NOT EXISTS insumo (
    id_insumo INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(100) NOT NULL,
    unidad_medida VARCHAR(30) NOT NULL DEFAULT 'Unidad',
    CONSTRAINT pk_norm_insumo PRIMARY KEY (id_insumo),
    CONSTRAINT uq_norm_insumo_nombre UNIQUE (nombre),
    CONSTRAINT ck_norm_insumo_nombre CHECK (length(trim(nombre)) >= 2)
);

-- 5. Cirugia
CREATE TABLE IF NOT EXISTS cirugia (
    id_cirugia BIGINT GENERATED ALWAYS AS IDENTITY,
    id_paciente INTEGER NOT NULL,
    id_cirujano INTEGER NOT NULL,
    id_diagnostico INTEGER NOT NULL,
    fecha TIMESTAMPTZ NOT NULL,
    CONSTRAINT pk_norm_cirugia PRIMARY KEY (id_cirugia),
    CONSTRAINT fk_norm_cirugia_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente (id_paciente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_norm_cirugia_cirujano FOREIGN KEY (id_cirujano)
        REFERENCES cirujano (id_cirujano)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_norm_cirugia_diagnostico FOREIGN KEY (id_diagnostico)
        REFERENCES diagnostico (id_diagnostico)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 6. Cirugia_Insumo (N:M)
CREATE TABLE IF NOT EXISTS cirugia_insumo (
    id_cirugia BIGINT NOT NULL,
    id_insumo INTEGER NOT NULL,
    cantidad NUMERIC(8,2) NOT NULL,
    CONSTRAINT pk_norm_cirugia_insumo PRIMARY KEY (id_cirugia, id_insumo),
    CONSTRAINT fk_norm_det_cirugia FOREIGN KEY (id_cirugia)
        REFERENCES cirugia (id_cirugia)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_norm_det_insumo FOREIGN KEY (id_insumo)
        REFERENCES insumo (id_insumo)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_norm_det_cantidad CHECK (cantidad > 0)
);

-- Indices para optimizacion de busquedas y uniones
CREATE INDEX IF NOT EXISTS ix_norm_cirugia_paciente ON cirugia (id_paciente);
CREATE INDEX IF NOT EXISTS ix_norm_cirugia_cirujano ON cirugia (id_cirujano);
CREATE INDEX IF NOT EXISTS ix_norm_cirugia_diagnostico ON cirugia (id_diagnostico);
CREATE INDEX IF NOT EXISTS ix_norm_cirugia_fecha ON cirugia (fecha);
CREATE INDEX IF NOT EXISTS ix_norm_det_insumo ON cirugia_insumo (id_insumo);


-- ============================================================================
-- VISTA DE RECONSTRUCCION DEL REPORTE ORIGINAL (LOSSLESS RECONSTRUCTION)
-- ============================================================================
CREATE OR REPLACE VIEW vista_reporte_cirugia AS
SELECT 
    c.id_cirugia,
    cir.nombre AS nombre_cirujano,
    cir.especialidad AS especialidad_cirujano,
    p.nombre AS nombre_paciente,
    d.codigo_diagnostico,
    d.descripcion AS descripcion_diagnostico,
    c.fecha,
    COUNT(ci.id_insumo) AS total_insumos_usados
FROM cirugia c
JOIN paciente p ON p.id_paciente = c.id_paciente
JOIN cirujano cir ON cir.id_cirujano = c.id_cirujano
JOIN diagnostico d ON d.id_diagnostico = c.id_diagnostico
LEFT JOIN cirugia_insumo ci ON ci.id_cirugia = c.id_cirugia
GROUP BY 
    c.id_cirugia, 
    cir.nombre, 
    cir.especialidad, 
    p.nombre, 
    d.codigo_diagnostico, 
    d.descripcion, 
    c.fecha;


-- ============================================================================
-- VERIFICACION DE INTEGRIDAD Y RECONSTRUCCION DEL REPORTE
-- ============================================================================
INSERT INTO diagnostico (codigo_diagnostico, descripcion) 
VALUES ('K35.8', 'Apendicitis aguda no especificada') 
ON CONFLICT (codigo_diagnostico) DO NOTHING;

INSERT INTO paciente (nombre) 
VALUES ('Carlos Daniel Mendez Perez')
ON CONFLICT DO NOTHING;

INSERT INTO cirujano (nombre, especialidad) 
VALUES ('Dr. Roberto Gomez', 'Cirugia General')
ON CONFLICT DO NOTHING;

INSERT INTO insumo (nombre, unidad_medida) 
VALUES ('Bisturi Quirurgico No. 15', 'Unidad')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO insumo (nombre, unidad_medida) 
VALUES ('Sutura Vicryl 3-0', 'Unidad')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO cirugia (id_paciente, id_cirujano, id_diagnostico, fecha)
VALUES (1, 1, 1, '2026-06-15 10:30:00-06')
ON CONFLICT DO NOTHING;

INSERT INTO cirugia_insumo (id_cirugia, id_insumo, cantidad)
VALUES (1, 1, 2.00), (1, 2, 4.00)
ON CONFLICT (id_cirugia, id_insumo) DO NOTHING;

SELECT * FROM vista_reporte_cirugia;
