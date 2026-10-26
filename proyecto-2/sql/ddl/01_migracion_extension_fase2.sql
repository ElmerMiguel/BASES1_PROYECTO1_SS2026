/* ****************************************************************************
   PROYECTO 2 - SISTEMA HOSPITALARIO DE OCCIDENTE
   MÓDULO DDL: Migración No Destructiva de la Fase 2
   Autor: Senior DBA & Database Architect
   Motor: PostgreSQL 16+ (Validado en PostgreSQL 18.x)
   Esquema: hospitales_occidente
   Descripción: Extensión no destructiva del modelo relacional en 3FN para:
     1. Extensión del supertipo personal (fecha_contratacion, salario).
     2. Cadena de mando del personal médico (relación recursiva id_superior y nivel_acceso).
     3. Creación de la entidad subtipo enfermero (TPT con PK/FK hacia personal).
     4. Migración segura de personal de enfermería existente.
   **************************************************************************** */

SET search_path TO hospitales_occidente, public;
SET timezone TO 'America/Guatemala';

BEGIN;

-- ============================================================================
-- 1. EXTENSIÓN DEL SUPERTIPO: personal
--    Propósito: Incorporar atributos laborales compartidos por médicos,
--               enfermeros y personal administrativo institucional.
-- ============================================================================

-- Agregar columna fecha_contratacion con valor predeterminado seguro
ALTER TABLE personal
    ADD COLUMN IF NOT EXISTS fecha_contratacion DATE NOT NULL DEFAULT CURRENT_DATE;

COMMENT ON COLUMN personal.fecha_contratacion IS 'Fecha oficial de inicio de relacion laboral institucional';

-- Agregar columna salario base con valor predeterminado coherente
ALTER TABLE personal
    ADD COLUMN IF NOT EXISTS salario NUMERIC(10,2) NOT NULL DEFAULT 8000.00;

COMMENT ON COLUMN personal.salario IS 'Salario base mensual asignado al colaborador';

-- Restricción de dominio: el salario no puede ser negativo
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_personal_salario' AND conrelid = 'personal'::regclass
    ) THEN
        ALTER TABLE personal
            ADD CONSTRAINT ck_personal_salario CHECK (salario >= 0);  -- salario nominal no negativo
    END IF;
END $$;


-- ============================================================================
-- 2. EXTENSIÓN DEL SUBTIPO: medico
--    Propósito: Modelar la cadena jerárquica de mando (relación recursiva)
--               y el nivel de acceso administrativo del facultativo.
-- ============================================================================

-- Agregar columna id_superior para la supervisión médica jerárquica
ALTER TABLE medico
    ADD COLUMN IF NOT EXISTS id_superior INTEGER NULL;

COMMENT ON COLUMN medico.id_superior IS 'Referencia foranea autorreferencial al medico superior inmediato en la linea de mando';

-- Agregar columna nivel_acceso para roles administrativos/asistenciales
ALTER TABLE medico
    ADD COLUMN IF NOT EXISTS nivel_acceso VARCHAR(30) NOT NULL DEFAULT 'Medico Asistencial';

COMMENT ON COLUMN medico.nivel_acceso IS 'Nivel funcional de responsabilidad y acceso dentro del escalafon medico';

-- Restricción de dominio: niveles de acceso médico autorizados
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_medico_nivel_acceso' AND conrelid = 'medico'::regclass
    ) THEN
        ALTER TABLE medico
            ADD CONSTRAINT ck_medico_nivel_acceso
            CHECK (nivel_acceso IN ('Medico Asistencial', 'Jefe de Guardia', 'Jefe de Servicio', 'Director Medico', 'Auditor Medico'));  -- categorias de mando medico
    END IF;
END $$;

-- Restricción de negocio: Prohibición estricta de auto-supervisión directa
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_medico_no_autosupervision' AND conrelid = 'medico'::regclass
    ) THEN
        ALTER TABLE medico
            ADD CONSTRAINT ck_medico_no_autosupervision
            CHECK (id_superior IS NULL OR id_superior <> id_personal);  -- un medico no puede ser superior jerarquico de si mismo
    END IF;
END $$;

-- Llave foránea autorreferenciada hacia medico(id_personal)
-- Regla de negocio ON DELETE SET NULL: Si un jefe de servicio o director es dado de baja,
-- sus subordinados jamás se eliminan en cascada; pasan a estado sin superior temporal.
-- Regla de negocio ON UPDATE CASCADE: Si se renombra o reasigna el identificador, se propaga.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_medico_superior' AND conrelid = 'medico'::regclass
    ) THEN
        ALTER TABLE medico
            ADD CONSTRAINT fk_medico_superior
            FOREIGN KEY (id_superior) REFERENCES medico (id_personal)
            ON DELETE SET NULL
            ON UPDATE CASCADE;
    END IF;
END $$;

-- Índice B-Tree para optimizar navegaciones jerárquicas y CTEs recursivas
CREATE INDEX IF NOT EXISTS ix_medico_superior ON medico (id_superior);


-- ============================================================================
-- 3. CREACIÓN DEL SUBTIPO: enfermero
--    Propósito: Representar al personal de enfermería bajo el patrón Table-per-Type (TPT),
--               heredando la identidad física del supertipo personal.
-- ============================================================================

-- Subtipo de personal para enfermeros profesionales, técnicos y auxiliares.
CREATE TABLE IF NOT EXISTS enfermero (
    id_personal     INTEGER     NOT NULL,
    no_licencia     VARCHAR(30) NOT NULL,
    grado_academico VARCHAR(30) NOT NULL,
    area_asignada   VARCHAR(50) NOT NULL,
    CONSTRAINT pk_enfermero PRIMARY KEY (id_personal),
    CONSTRAINT uq_enfermero_licencia UNIQUE (no_licencia),
    CONSTRAINT ck_enfermero_licencia CHECK (length(trim(no_licencia)) >= 3),  -- numero de licencia profesional valido
    CONSTRAINT ck_enfermero_area     CHECK (length(trim(area_asignada)) >= 3),  -- area clinica de asignacion descriptiva
    CONSTRAINT ck_enfermero_grado    CHECK (grado_academico IN ('Auxiliar', 'Tecnico', 'Licenciado', 'Magister')),  -- nivel de formacion acreditado
    -- Regla de negocio ON DELETE CASCADE: La identidad del subtipo depende ontológicamente del supertipo personal.
    -- Regla de negocio ON UPDATE CASCADE: Propagación de modificaciones en la clave.
    CONSTRAINT fk_enfermero_personal FOREIGN KEY (id_personal)
        REFERENCES personal (id_personal) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE enfermero IS 'Subtipo de personal para colaboradores del cuerpo de enfermeria y asistencia quirurgica';
COMMENT ON COLUMN enfermero.id_personal IS 'Identificador compartido y clave foranea hacia el supertipo personal';
COMMENT ON COLUMN enfermero.no_licencia IS 'Numero oficial de colegiacion o licencia de enfermeria profesional';
COMMENT ON COLUMN enfermero.grado_academico IS 'Grado academico de enfermeria (Auxiliar, Tecnico, Licenciado, Magister)';
COMMENT ON COLUMN enfermero.area_asignada IS 'Area operativa o de servicio asignada al personal de enfermeria';


-- ============================================================================
-- 4. MIGRACIÓN DE DATOS PREVIOS DE ENFERMERÍA (NO DESTRUCTIVA)
--    Propósito: Poblar la tabla subtipo enfermero con los registros que ya
--               existían en personal con tipo_personal = 'Enfermero'.
-- ============================================================================

INSERT INTO enfermero (id_personal, no_licencia, grado_academico, area_asignada)
VALUES
    (15, 'LIC-ENF-0015', 'Licenciado', 'Quirófano'),
    (16, 'TEC-ENF-0016', 'Tecnico', 'Quirófano'),
    (17, 'LIC-ENF-0017', 'Licenciado', 'Emergencias'),
    (18, 'TEC-ENF-0018', 'Tecnico', 'Hospitalización'),
    (19, 'AUX-ENF-0019', 'Auxiliar', 'Recuperación')
ON CONFLICT (id_personal) DO NOTHING;


-- ============================================================================
-- 5. ACTUALIZACIÓN DE CONTROL DE ACCESO (DCL) Y ENTORNO DE CONEXIÓN
--    Propósito: Asegurar que los roles institucionales tengan permisos sobre
--               la nueva entidad enfermero, soporte administrativo y search_path
--               predeterminado para conexiones directas desde DBeaver/CLI.
-- ============================================================================

DO $$
DECLARE
    v_roles TEXT[] := ARRAY[
        'rol_admin_hospital', 'rol_auditor_consulta', 'rol_medico_asistencial', 'rol_caja_facturacion',
        'usr_admin_occidente', 'usr_auditor_occidente', 'usr_medico_occidente', 'usr_caja_occidente'
    ];
    v_role TEXT;
BEGIN
    -- 1. Permisos sobre la nueva tabla subtipo enfermero
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_auditor_consulta') THEN
        GRANT SELECT ON TABLE enfermero TO rol_auditor_consulta;
    END IF;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_medico_asistencial') THEN
        GRANT SELECT ON TABLE enfermero TO rol_medico_asistencial;
    END IF;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_caja_facturacion') THEN
        GRANT SELECT ON TABLE enfermero TO rol_caja_facturacion;
    END IF;

    -- 2. Privilegio CREATE en la base de datos para administracion (soporte esquemas analiticos)
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_admin_hospital') THEN
        EXECUTE format('GRANT CREATE ON DATABASE %I TO rol_admin_hospital', current_database());
    END IF;

    -- 3. Asignacion automatica de search_path a roles y usuarios institucionales
    FOREACH v_role IN ARRAY v_roles LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = v_role) THEN
            EXECUTE format('ALTER ROLE %I SET search_path TO hospitales_occidente, public', v_role);
        END IF;
    END LOOP;

    -- 4. Asignacion predeterminada de search_path a la base de datos actual
    EXECUTE format('ALTER DATABASE %I SET search_path TO hospitales_occidente, public', current_database());
END $$;

COMMIT;

-- FIN DEL SCRIPT DE MIGRACIÓN FASE 2
