/*
OBJETIVO 19: Analisis de normalizacion para Reporte_Cirugia

1. PROBLEMAS DE NORMALIZACION
- 1FN: Las columnas fijas de insumo 1 e insumo 2 limitan los registros y llenan la tabla de nulos si no se usan.
- 2FN y 3FN: Los datos del cirujano, paciente y diagnostico dependen del id de la cirugia en lugar de sus propias entidades, generando redundancia.

2. ANOMALIAS
- Insercion: No se pueden registrar nuevos insumos, cirujanos o pacientes sin asociarlos primero a una cirugia.
- Modificacion: Cambiar el nombre de un diagnostico o especialidad obliga a actualizar cientos de filas historicas.
- Eliminacion: Borrar una cirugia puede eliminar informacion de los catalogos si no esta en otro registro.

3. SOLUCION EN 3FN (6 TABLAS)
Se divide en tablas atomicas con integridad referencial:
- diagnostico
- paciente
- cirujano
- insumo
- cirugia (tabla principal del evento)
- cirugia_insumo (tabla intermedia N a M con la cantidad consumida)
*/

-- DDL DE IMPLEMENTACION 3fn


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



-- VISTA DE RECONSTRUCCION DEL REPORTE ORIGINAL (LOSSLESS RECONSTRUCTION)

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



-- VERIFICACION DE INTEGRIDAD Y RECONSTRUCCION DEL REPORTE

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
