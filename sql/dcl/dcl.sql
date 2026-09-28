

SET search_path TO hospitales_occidente, public;
SET timezone TO 'America/Guatemala';


DO $$
DECLARE
    v_user TEXT;
    v_role TEXT;
    v_users TEXT[] := ARRAY[
        'usr_admin_occidente', 'usr_auditor_occidente', 'usr_medico_occidente', 'usr_caja_occidente'
    ];
    v_roles TEXT[] := ARRAY[
        'rol_admin_hospital', 'rol_auditor_consulta', 'rol_medico_asistencial', 'rol_caja_facturacion'
    ];
BEGIN
    FOREACH v_user IN ARRAY v_users LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = v_user) THEN
            EXECUTE format('REVOKE ALL PRIVILEGES ON DATABASE hospital_occidente FROM %I', v_user);
            IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'hospitales_occidente') THEN
                EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA hospitales_occidente FROM %I', v_user);
                EXECUTE format('REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA hospitales_occidente FROM %I', v_user);
                EXECUTE format('REVOKE ALL PRIVILEGES ON ALL ROUTINES IN SCHEMA hospitales_occidente FROM %I', v_user);
                EXECUTE format('REVOKE ALL PRIVILEGES ON SCHEMA hospitales_occidente FROM %I', v_user);
            END IF;
            EXECUTE format('DROP OWNED BY %I', v_user);
            EXECUTE format('DROP ROLE %I', v_user);
        END IF;
    END LOOP;

    FOREACH v_role IN ARRAY v_roles LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = v_role) THEN
            EXECUTE format('REVOKE ALL PRIVILEGES ON DATABASE hospital_occidente FROM %I', v_role);
            IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'hospitales_occidente') THEN
                EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA hospitales_occidente FROM %I', v_role);
                EXECUTE format('REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA hospitales_occidente FROM %I', v_role);
                EXECUTE format('REVOKE ALL PRIVILEGES ON ALL ROUTINES IN SCHEMA hospitales_occidente FROM %I', v_role);
                EXECUTE format('REVOKE ALL PRIVILEGES ON SCHEMA hospitales_occidente FROM %I', v_role);
            END IF;
            EXECUTE format('DROP OWNED BY %I', v_role);
            EXECUTE format('DROP ROLE %I', v_role);
        END IF;
    END LOOP;
END $$;

/* ============================================================================
    CREACION DE ROLES INSTITUCIONALES (GRUPOS DE PRIVILEGIOS)
   ============================================================================ */

-- Rol 1: Administrador con control total del esquema hospitales_occidente
CREATE ROLE rol_admin_hospital WITH NOLOGIN;

-- Rol 2: Auditoria y consulta con acceso de solo lectura (SELECT) en todas las tablas
CREATE ROLE rol_auditor_consulta WITH NOLOGIN;

-- Rol 3: Personal medico y asistencial (atencion clinica, consultas, cirugias e ingresos)
CREATE ROLE rol_medico_asistencial WITH NOLOGIN;

-- Rol 4: Facturacion y recepcion (agendamiento de citas, cobros y emision de facturas)
CREATE ROLE rol_caja_facturacion WITH NOLOGIN;

/* ============================================================================
    ASIGNACION DE PRIVILEGIOS A NIVEL DE BASE DE DATOS Y ESQUEMA
   ============================================================================ */

-- Permiso de conexion a la base de datos para todos los roles
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_database WHERE datname = 'hospital_occidente') THEN
        GRANT CONNECT ON DATABASE hospital_occidente TO rol_admin_hospital, rol_auditor_consulta, rol_medico_asistencial, rol_caja_facturacion;
    END IF;
END $$;

-- Permiso de uso del esquema institucional
GRANT USAGE ON SCHEMA hospitales_occidente TO rol_admin_hospital, rol_auditor_consulta, rol_medico_asistencial, rol_caja_facturacion;

/* ============================================================================
   PRIVILEGIOS ESPECIFICOS POR ROL
   ============================================================================ */

-- ----------------------------------------------------------------------------
-- ROL ADMINISTRADOR (rol_admin_hospital)
-- Control total sobre objetos, tablas, secuencias y funciones del esquema
-- ----------------------------------------------------------------------------
GRANT ALL PRIVILEGES ON SCHEMA hospitales_occidente TO rol_admin_hospital;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA hospitales_occidente TO rol_admin_hospital;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA hospitales_occidente TO rol_admin_hospital;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA hospitales_occidente TO rol_admin_hospital;

-- Privilegios por defecto para futuros objetos creados por el administrador
ALTER DEFAULT PRIVILEGES IN SCHEMA hospitales_occidente GRANT ALL PRIVILEGES ON TABLES TO rol_admin_hospital;
ALTER DEFAULT PRIVILEGES IN SCHEMA hospitales_occidente GRANT ALL PRIVILEGES ON SEQUENCES TO rol_admin_hospital;
ALTER DEFAULT PRIVILEGES IN SCHEMA hospitales_occidente GRANT ALL PRIVILEGES ON FUNCTIONS TO rol_admin_hospital;

-- ----------------------------------------------------------------------------
--  ROL AUDITORIA Y REPORTES (rol_auditor_consulta)
-- Privilegio exclusivo de solo lectura (SELECT) en todas las tablas y vistas
-- ----------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA hospitales_occidente TO rol_auditor_consulta;
ALTER DEFAULT PRIVILEGES IN SCHEMA hospitales_occidente GRANT SELECT ON TABLES TO rol_auditor_consulta;

-- ----------------------------------------------------------------------------
-- ROL MEDICO Y ASISTENCIAL (rol_medico_asistencial)
-- Lectura general, uso de secuencias y gestion clinica (INSERT, UPDATE)
-- ----------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA hospitales_occidente TO rol_medico_asistencial;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA hospitales_occidente TO rol_medico_asistencial;

-- Privilegios de gestion clinica para el rol medico
GRANT INSERT, UPDATE ON TABLE
    persona,
    paciente,
    paciente_encargado,
    episodio,
    registro_signos_vitales,
    ingreso,
    traslado,
    egreso,
    egreso_diagnostico_secundario,
    consumo_insumo,
    cita,
    consulta,
    receta,
    receta_detalle,
    orden_laboratorio,
    orden_laboratorio_detalle,
    historia_clinica,
    solicitud_cirugia,
    solicitud_procedimiento,
    solicitud_insumo,
    solicitud_instrumento,
    solicitud_equipo,
    revision_solicitud,
    revision_miembro_comite,
    cirugia,
    cirugia_equipo_medico,
    consentimiento_informado,
    evaluacion_preanestesica,
    cirugia_verificacion,
    cirugia_documento_fase
TO rol_medico_asistencial;

-- ----------------------------------------------------------------------------
--  ROL CAJA Y FACTURACION (rol_caja_facturacion)
-- Lectura general, uso de secuencias, agendamiento de citas, cobro y facturas
-- ----------------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA hospitales_occidente TO rol_caja_facturacion;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA hospitales_occidente TO rol_caja_facturacion;

-- Privilegios de facturacion, citas y pagos para el rol de caja
GRANT INSERT, UPDATE ON TABLE
    cita,
    factura,
    factura_detalle,
    pago,
    calificacion_hospital,
    calificacion_personal
TO rol_caja_facturacion;

/* ============================================================================
    CREACION DE USUARIOS Y ASIGNACION DE ROLES
   ============================================================================ */

-- Usuario 1: Administrador General del Sistema
CREATE USER usr_admin_occidente WITH ENCRYPTED PASSWORD 'AdminPass2026!';
GRANT rol_admin_hospital TO usr_admin_occidente;

-- Usuario 2: Auditor y Revisor de Reportes de Calidad
CREATE USER usr_auditor_occidente WITH ENCRYPTED PASSWORD 'AuditorPass2026!';
GRANT rol_auditor_consulta TO usr_auditor_occidente;

-- Usuario 3: Medico Facultativo Asistencial
CREATE USER usr_medico_occidente WITH ENCRYPTED PASSWORD 'MedicoPass2026!';
GRANT rol_medico_asistencial TO usr_medico_occidente;

-- Usuario 4: Receptor y Cajero de Hospitalizacion/Consulta
CREATE USER usr_caja_occidente WITH ENCRYPTED PASSWORD 'CajaPass2026!';
GRANT rol_caja_facturacion TO usr_caja_occidente;

/* ============================================================================
   CONSULTAS DE AUDITORIA Y VERIFICACION DE PRIVILEGIOS
   ============================================================================ */

-- Verificacion de roles y usuarios creados
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin
FROM pg_roles
WHERE rolname IN ('rol_admin_hospital', 'rol_auditor_consulta', 'rol_medico_asistencial', 'rol_caja_facturacion',
                  'usr_admin_occidente', 'usr_auditor_occidente', 'usr_medico_occidente', 'usr_caja_occidente')
ORDER BY rolname;

-- Verificacion de pertenencia a roles
SELECT r.rolname AS usuario, m.rolname AS rol_asignado
FROM pg_roles r
JOIN pg_auth_members a ON a.member = r.oid
JOIN pg_roles m ON m.oid = a.roleid
WHERE r.rolname LIKE 'usr_%'
ORDER BY r.rolname;

-- FIN
