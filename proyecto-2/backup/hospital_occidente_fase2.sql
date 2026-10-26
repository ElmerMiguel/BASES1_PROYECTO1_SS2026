--
-- PostgreSQL database dump
--

\restrict c0BWJ1Sj1M97iqjgCHrUiN6P5y6JpSPc2hcHCXKnqyrOfTduUyevmYIpVoaJtuY

-- Dumped from database version 18.6 (Debian 18.6-1.pgdg13+2)
-- Dumped by pg_dump version 18.6 (Debian 18.6-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hospitales_occidente; Type: SCHEMA; Schema: -; Owner: user1
--

CREATE SCHEMA hospitales_occidente;


ALTER SCHEMA hospitales_occidente OWNER TO user1;

--
-- Name: normalizacion_cirugia; Type: SCHEMA; Schema: -; Owner: usr_admin_occidente
--

CREATE SCHEMA normalizacion_cirugia;


ALTER SCHEMA normalizacion_cirugia OWNER TO usr_admin_occidente;

--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: fn_auditoria_personal_medico(); Type: FUNCTION; Schema: hospitales_occidente; Owner: user1
--

CREATE FUNCTION hospitales_occidente.fn_auditoria_personal_medico() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'hospitales_occidente', 'public'
    AS $$
BEGIN
    -- Cambios en la tabla personal (salario)
    IF TG_TABLE_NAME = 'personal' THEN
        IF OLD.salario IS DISTINCT FROM NEW.salario THEN
            INSERT INTO hospitales_occidente.bitacora_auditoria_personal (
                id_personal, tabla_afectada, campo_modificado,
                valor_anterior, valor_nuevo, usuario_db, fecha_hora, operacion
            ) VALUES (
                NEW.id_personal, 'personal', 'salario',
                OLD.salario::TEXT, NEW.salario::TEXT, CURRENT_USER, clock_timestamp(), TG_OP
            );
        END IF;
        RETURN NEW;
    END IF;

    -- Cambios en la tabla medico (nivel de acceso, superior directo)
    IF TG_TABLE_NAME = 'medico' THEN
        IF OLD.nivel_acceso IS DISTINCT FROM NEW.nivel_acceso THEN
            INSERT INTO hospitales_occidente.bitacora_auditoria_personal (
                id_personal, tabla_afectada, campo_modificado,
                valor_anterior, valor_nuevo, usuario_db, fecha_hora, operacion
            ) VALUES (
                NEW.id_personal, 'medico', 'nivel_acceso',
                OLD.nivel_acceso, NEW.nivel_acceso, CURRENT_USER, clock_timestamp(), TG_OP
            );
        END IF;

        IF OLD.id_superior IS DISTINCT FROM NEW.id_superior THEN
            INSERT INTO hospitales_occidente.bitacora_auditoria_personal (
                id_personal, tabla_afectada, campo_modificado,
                valor_anterior, valor_nuevo, usuario_db, fecha_hora, operacion
            ) VALUES (
                NEW.id_personal, 'medico', 'id_superior',
                OLD.id_superior::TEXT, NEW.id_superior::TEXT, CURRENT_USER, clock_timestamp(), TG_OP
            );
        END IF;
        RETURN NEW;
    END IF;

    -- Cambios en medico_especialidad (asignacion o retiro de especialidad)
    IF TG_TABLE_NAME = 'medico_especialidad' THEN
        IF TG_OP = 'UPDATE' THEN
            IF OLD.id_especialidad IS DISTINCT FROM NEW.id_especialidad THEN
                INSERT INTO hospitales_occidente.bitacora_auditoria_personal (
                    id_personal, tabla_afectada, campo_modificado,
                    valor_anterior, valor_nuevo, usuario_db, fecha_hora, operacion
                ) VALUES (
                    NEW.id_medico, 'medico_especialidad', 'id_especialidad',
                    OLD.id_especialidad::TEXT, NEW.id_especialidad::TEXT, CURRENT_USER, clock_timestamp(), TG_OP
                );
            END IF;
            IF OLD.es_principal IS DISTINCT FROM NEW.es_principal THEN
                INSERT INTO hospitales_occidente.bitacora_auditoria_personal (
                    id_personal, tabla_afectada, campo_modificado,
                    valor_anterior, valor_nuevo, usuario_db, fecha_hora, operacion
                ) VALUES (
                    NEW.id_medico, 'medico_especialidad', 'es_principal',
                    OLD.es_principal::TEXT, NEW.es_principal::TEXT, CURRENT_USER, clock_timestamp(), TG_OP
                );
            END IF;
            RETURN NEW;
        ELSIF TG_OP = 'INSERT' THEN
            INSERT INTO hospitales_occidente.bitacora_auditoria_personal (
                id_personal, tabla_afectada, campo_modificado,
                valor_anterior, valor_nuevo, usuario_db, fecha_hora, operacion
            ) VALUES (
                NEW.id_medico, 'medico_especialidad', 'id_especialidad',
                NULL, NEW.id_especialidad::TEXT, CURRENT_USER, clock_timestamp(), 'INSERT'
            );
            RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
            INSERT INTO hospitales_occidente.bitacora_auditoria_personal (
                id_personal, tabla_afectada, campo_modificado,
                valor_anterior, valor_nuevo, usuario_db, fecha_hora, operacion
            ) VALUES (
                OLD.id_medico, 'medico_especialidad', 'id_especialidad',
                OLD.id_especialidad::TEXT, NULL, CURRENT_USER, clock_timestamp(), 'DELETE'
            );
            RETURN OLD;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION hospitales_occidente.fn_auditoria_personal_medico() OWNER TO user1;

--
-- Name: fn_check_coherencia_paciente_consulta(); Type: FUNCTION; Schema: hospitales_occidente; Owner: user1
--

CREATE FUNCTION hospitales_occidente.fn_check_coherencia_paciente_consulta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_paciente_cita     INTEGER;
    v_paciente_episodio INTEGER;
BEGIN
    SELECT id_paciente INTO v_paciente_cita
    FROM cita
    WHERE id_cita = NEW.id_cita;

    SELECT id_paciente INTO v_paciente_episodio
    FROM episodio
    WHERE id_episodio = NEW.id_episodio;

    IF v_paciente_cita <> v_paciente_episodio THEN
        RAISE EXCEPTION 'Inconsistencia Clinica: El paciente de la cita (%) no coincide con el del episodio (%).',
            v_paciente_cita, v_paciente_episodio;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION hospitales_occidente.fn_check_coherencia_paciente_consulta() OWNER TO user1;

--
-- Name: fn_check_cuota_pago(); Type: FUNCTION; Schema: hospitales_occidente; Owner: user1
--

CREATE FUNCTION hospitales_occidente.fn_check_cuota_pago() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_cuotas_max SMALLINT;
BEGIN
    SELECT numero_cuotas INTO v_cuotas_max
    FROM factura
    WHERE id_factura = NEW.id_factura;

    IF NEW.numero_cuota > v_cuotas_max THEN
        RAISE EXCEPTION 'Regla Financiera: El numero de cuota (%) sobrepasa el financiamiento convenido en la factura (% cuotas).',
            NEW.numero_cuota, v_cuotas_max;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION hospitales_occidente.fn_check_cuota_pago() OWNER TO user1;

--
-- Name: fn_check_cuotas_factura(); Type: FUNCTION; Schema: hospitales_occidente; Owner: user1
--

CREATE FUNCTION hospitales_occidente.fn_check_cuotas_factura() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_tiene_otros_conceptos BOOLEAN;
BEGIN
    -- Comprobar si existen conceptos distintos a Consulta en el detalle
    SELECT EXISTS (
        SELECT 1 
        FROM factura_detalle 
        WHERE id_factura = NEW.id_factura 
          AND concepto <> 'Consulta'
    ) INTO v_tiene_otros_conceptos;

    -- Si la factura solo contiene consultas, no se permite el financiamiento en cuotas
    IF NOT v_tiene_otros_conceptos AND NEW.numero_cuotas > 1 THEN
        -- Comprobamos si efectivamente tiene al menos un concepto de Consulta
        IF EXISTS (SELECT 1 FROM factura_detalle WHERE id_factura = NEW.id_factura AND concepto = 'Consulta') THEN
            RAISE EXCEPTION 'Regla Financiera: Las atenciones de Consulta Externa deben cancelarse en un unico pago.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION hospitales_occidente.fn_check_cuotas_factura() OWNER TO user1;

--
-- Name: fn_check_fecha_egreso(); Type: FUNCTION; Schema: hospitales_occidente; Owner: user1
--

CREATE FUNCTION hospitales_occidente.fn_check_fecha_egreso() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_fecha_ingreso TIMESTAMPTZ;
BEGIN
    SELECT fecha_hora_ingreso INTO v_fecha_ingreso
    FROM ingreso
    WHERE id_ingreso = NEW.id_ingreso;

    IF NEW.fecha_hora_egreso < v_fecha_ingreso THEN
        RAISE EXCEPTION 'Regla Clínica Violada: La fecha y hora de egreso (%) no puede preceder al ingreso (%).',
            NEW.fecha_hora_egreso, v_fecha_ingreso;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION hospitales_occidente.fn_check_fecha_egreso() OWNER TO user1;

--
-- Name: fn_check_limite_quirofanos(); Type: FUNCTION; Schema: hospitales_occidente; Owner: user1
--

CREATE FUNCTION hospitales_occidente.fn_check_limite_quirofanos() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_tipo_unidad      VARCHAR(30);
    v_total_quirofanos INTEGER;
BEGIN
    IF NEW.tipo = 'Quirofano' THEN
        SELECT tu.nombre INTO v_tipo_unidad
        FROM unidad_hospital uh
        JOIN tipo_unidad tu ON tu.id_tipo_unidad = uh.id_tipo_unidad
        WHERE uh.id_unidad_hospital = NEW.id_unidad_hospital;

        IF v_tipo_unidad NOT ILIKE 'Cirug%' THEN
            RAISE EXCEPTION 'Regla Hospitalaria: Un quirofano solo puede habilitarse en la unidad de Cirugia (asignado a: %)',
                v_tipo_unidad;
        END IF;

        SELECT COUNT(*) INTO v_total_quirofanos
        FROM espacio_atencion ea
        WHERE ea.id_unidad_hospital = NEW.id_unidad_hospital
          AND ea.tipo = 'Quirofano'
          AND ea.id_espacio <> COALESCE(NEW.id_espacio, -1);

        IF v_total_quirofanos >= 4 THEN
            RAISE EXCEPTION 'Regla Hospitalaria: El hospital ya cuenta con los 4 quirofanos reglamentarios habilitados.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION hospitales_occidente.fn_check_limite_quirofanos() OWNER TO user1;

--
-- Name: fn_check_persona_fecha_nacimiento(); Type: FUNCTION; Schema: hospitales_occidente; Owner: user1
--

CREATE FUNCTION hospitales_occidente.fn_check_persona_fecha_nacimiento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.fecha_nacimiento > CURRENT_DATE THEN
        RAISE EXCEPTION 'Regla de Negocio Violada: La fecha de nacimiento (%) no puede ser futura.',
            NEW.fecha_nacimiento;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION hospitales_occidente.fn_check_persona_fecha_nacimiento() OWNER TO user1;

--
-- Name: fn_check_rol_equipo_quirurgico(); Type: FUNCTION; Schema: hospitales_occidente; Owner: user1
--

CREATE FUNCTION hospitales_occidente.fn_check_rol_equipo_quirurgico() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_tipo_personal VARCHAR(30);
BEGIN
    SELECT tipo_personal INTO v_tipo_personal
    FROM personal
    WHERE id_personal = NEW.id_personal;

    IF NEW.rol IN ('Cirujano principal', 'Cirujano ayudante', 'Anestesiologo') AND v_tipo_personal <> 'Medico' THEN
        RAISE EXCEPTION 'Regla Quirurgica: El rol de % requiere acreditacion de Medico (registrado como: %)',
            NEW.rol, v_tipo_personal;
    END IF;

    IF NEW.rol IN ('Enfermero instrumentista', 'Enfermero circulante') AND v_tipo_personal <> 'Enfermero' THEN
        RAISE EXCEPTION 'Regla Quirurgica: El rol de % requiere un profesional de Enfermeria',
            NEW.rol;
    END IF;

    IF NEW.rol = 'Practicante de medicina' AND v_tipo_personal <> 'Practicante de medicina' THEN
        RAISE EXCEPTION 'Regla Quirurgica: Rol reservado para personal clasificado como Practicante de medicina';
    END IF;

    IF NEW.rol = 'Practicante de enfermeria' AND v_tipo_personal <> 'Practicante de enfermeria' THEN
        RAISE EXCEPTION 'Regla Quirurgica: Rol reservado para personal clasificado como Practicante de enfermeria';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION hospitales_occidente.fn_check_rol_equipo_quirurgico() OWNER TO user1;

--
-- Name: fn_check_unidad_hospital_interno(); Type: FUNCTION; Schema: hospitales_occidente; Owner: user1
--

CREATE FUNCTION hospitales_occidente.fn_check_unidad_hospital_interno() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_es_interno BOOLEAN;
BEGIN
    SELECT es_interno INTO v_es_interno
    FROM hospital
    WHERE id_hospital = NEW.id_hospital;

    IF v_es_interno IS NOT TRUE THEN
        RAISE EXCEPTION 'Regla Institucional: No se pueden registrar unidades medicas en centros externos. Estos solo aplican para referencias y traslados.';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION hospitales_occidente.fn_check_unidad_hospital_interno() OWNER TO user1;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: asignacion_personal; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.asignacion_personal (
    id_asignacion integer NOT NULL,
    id_personal integer NOT NULL,
    id_unidad_hospital integer NOT NULL,
    id_turno integer NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date,
    CONSTRAINT ck_asignacion_fechas CHECK (((fecha_fin IS NULL) OR (fecha_fin >= fecha_inicio)))
);


ALTER TABLE hospitales_occidente.asignacion_personal OWNER TO user1;

--
-- Name: asignacion_personal_id_asignacion_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.asignacion_personal ALTER COLUMN id_asignacion ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.asignacion_personal_id_asignacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: bitacora_auditoria_personal; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.bitacora_auditoria_personal (
    id_auditoria bigint NOT NULL,
    id_personal integer NOT NULL,
    tabla_afectada character varying(50) NOT NULL,
    campo_modificado character varying(50) NOT NULL,
    valor_anterior text,
    valor_nuevo text,
    usuario_db character varying(100) DEFAULT CURRENT_USER NOT NULL,
    fecha_hora timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    operacion character varying(10) DEFAULT 'UPDATE'::character varying NOT NULL
);


ALTER TABLE hospitales_occidente.bitacora_auditoria_personal OWNER TO user1;

--
-- Name: bitacora_auditoria_personal_id_auditoria_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.bitacora_auditoria_personal ALTER COLUMN id_auditoria ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.bitacora_auditoria_personal_id_auditoria_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: calificacion_hospital; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.calificacion_hospital (
    id_calificacion_hospital bigint NOT NULL,
    id_episodio bigint NOT NULL,
    puntuacion smallint NOT NULL,
    comentario character varying(500),
    fecha_hora timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_calhosp_puntuacion CHECK (((puntuacion >= 1) AND (puntuacion <= 5)))
);


ALTER TABLE hospitales_occidente.calificacion_hospital OWNER TO user1;

--
-- Name: calificacion_hospital_id_calificacion_hospital_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.calificacion_hospital ALTER COLUMN id_calificacion_hospital ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.calificacion_hospital_id_calificacion_hospital_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: calificacion_personal; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.calificacion_personal (
    id_calificacion_personal bigint NOT NULL,
    id_episodio bigint NOT NULL,
    id_personal integer NOT NULL,
    puntuacion smallint NOT NULL,
    comentario character varying(500),
    fecha_hora timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_calpers_puntuacion CHECK (((puntuacion >= 1) AND (puntuacion <= 5)))
);


ALTER TABLE hospitales_occidente.calificacion_personal OWNER TO user1;

--
-- Name: calificacion_personal_id_calificacion_personal_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.calificacion_personal ALTER COLUMN id_calificacion_personal ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.calificacion_personal_id_calificacion_personal_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cirugia; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.cirugia (
    id_cirugia bigint NOT NULL,
    id_solicitud_cirugia bigint NOT NULL,
    id_quirofano integer NOT NULL,
    inicio_programado timestamp with time zone NOT NULL,
    fin_programado timestamp with time zone NOT NULL,
    inicio_real timestamp with time zone,
    fin_real timestamp with time zone,
    estado character varying(10) DEFAULT 'Programada'::character varying NOT NULL,
    id_ingreso bigint,
    condicion_evolucion character varying(20),
    CONSTRAINT ck_cirugia_estado CHECK (((estado)::text = ANY ((ARRAY['Programada'::character varying, 'En curso'::character varying, 'Finalizada'::character varying, 'Cancelada'::character varying])::text[]))),
    CONSTRAINT ck_cirugia_evolucion CHECK (((condicion_evolucion IS NULL) OR ((condicion_evolucion)::text = ANY ((ARRAY['Sin complicaciones'::character varying, 'Complicaciones'::character varying, 'Complicaciones graves'::character varying])::text[])))),
    CONSTRAINT ck_cirugia_evolucion_est CHECK (((condicion_evolucion IS NULL) OR ((estado)::text = 'Finalizada'::text))),
    CONSTRAINT ck_cirugia_programada CHECK ((fin_programado > inicio_programado)),
    CONSTRAINT ck_cirugia_real CHECK (((fin_real IS NULL) OR ((inicio_real IS NOT NULL) AND (fin_real > inicio_real))))
);


ALTER TABLE hospitales_occidente.cirugia OWNER TO user1;

--
-- Name: cirugia_documento_fase; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.cirugia_documento_fase (
    id_documento bigint NOT NULL,
    id_cirugia bigint NOT NULL,
    fase character varying(15) NOT NULL,
    id_enfermero integer NOT NULL,
    fecha_envio_secretaria date DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT ck_documento_fase CHECK (((fase)::text = ANY ((ARRAY['Preoperatorio'::character varying, 'Intraoperatorio'::character varying, 'Postoperatorio'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.cirugia_documento_fase OWNER TO user1;

--
-- Name: cirugia_documento_fase_id_documento_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.cirugia_documento_fase ALTER COLUMN id_documento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.cirugia_documento_fase_id_documento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cirugia_equipo_medico; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.cirugia_equipo_medico (
    id_cirugia bigint NOT NULL,
    id_personal integer NOT NULL,
    rol character varying(30) NOT NULL,
    CONSTRAINT ck_cirugia_equipo_rol CHECK (((rol)::text = ANY ((ARRAY['Cirujano principal'::character varying, 'Cirujano ayudante'::character varying, 'Anestesiologo'::character varying, 'Enfermero instrumentista'::character varying, 'Enfermero circulante'::character varying, 'Practicante de medicina'::character varying, 'Practicante de enfermeria'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.cirugia_equipo_medico OWNER TO user1;

--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.cirugia ALTER COLUMN id_cirugia ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.cirugia_id_cirugia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cirugia_verificacion; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.cirugia_verificacion (
    id_verificacion bigint NOT NULL,
    id_cirugia bigint NOT NULL,
    id_item integer NOT NULL,
    resultado character varying(25) NOT NULL,
    detalle character varying(500),
    fecha_hora_registro timestamp with time zone DEFAULT now() NOT NULL,
    id_enfermero integer NOT NULL,
    CONSTRAINT ck_verificacion_res CHECK (((resultado)::text = ANY ((ARRAY['Exito'::character varying, 'Fallo'::character varying, 'Aceptable'::character varying, 'Medianamente aceptable'::character varying, 'No aceptable'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.cirugia_verificacion OWNER TO user1;

--
-- Name: cirugia_verificacion_id_verificacion_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.cirugia_verificacion ALTER COLUMN id_verificacion ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.cirugia_verificacion_id_verificacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cita; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.cita (
    id_cita bigint NOT NULL,
    id_paciente integer NOT NULL,
    id_medico integer NOT NULL,
    id_clinica integer NOT NULL,
    fecha_hora timestamp with time zone NOT NULL,
    canal_asignacion character varying(20) NOT NULL,
    tipo_consulta character varying(12) NOT NULL,
    id_hospital_referente integer,
    estado character varying(13) DEFAULT 'Programada'::character varying NOT NULL,
    fecha_cancelacion timestamp with time zone,
    motivo_cancelacion character varying(200),
    cancelacion_notificada boolean,
    id_cita_anterior bigint,
    id_cita_recargo_origen bigint,
    creada_en timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_cita_canal CHECK (((canal_asignacion)::text = ANY ((ARRAY['Telefono'::character varying, 'Correo institucional'::character varying, 'Recepcion general'::character varying])::text[]))),
    CONSTRAINT ck_cita_cancelacion_aviso CHECK ((((estado)::text <> 'Cancelada'::text) OR (cancelacion_notificada IS NOT NULL))),
    CONSTRAINT ck_cita_cancelacion_datos CHECK ((((estado)::text = 'Cancelada'::text) OR ((fecha_cancelacion IS NULL) AND (motivo_cancelacion IS NULL) AND (cancelacion_notificada IS NULL)))),
    CONSTRAINT ck_cita_estado CHECK (((estado)::text = ANY ((ARRAY['Programada'::character varying, 'Realizada'::character varying, 'Reprogramada'::character varying, 'Cancelada'::character varying])::text[]))),
    CONSTRAINT ck_cita_referente CHECK (((((tipo_consulta)::text = 'Referido'::text) AND (id_hospital_referente IS NOT NULL)) OR (((tipo_consulta)::text <> 'Referido'::text) AND (id_hospital_referente IS NULL)))),
    CONSTRAINT ck_cita_tipo CHECK (((tipo_consulta)::text = ANY ((ARRAY['Primera vez'::character varying, 'Reconsulta'::character varying, 'Referido'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.cita OWNER TO user1;

--
-- Name: cita_id_cita_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.cita ALTER COLUMN id_cita ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.cita_id_cita_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: clinica; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.clinica (
    id_clinica integer NOT NULL,
    id_hospital integer NOT NULL,
    numero_clinica character varying(10) NOT NULL,
    habilitada boolean DEFAULT true NOT NULL,
    CONSTRAINT ck_clinica_numero CHECK ((length(TRIM(BOTH FROM numero_clinica)) >= 1))
);


ALTER TABLE hospitales_occidente.clinica OWNER TO user1;

--
-- Name: clinica_id_clinica_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.clinica ALTER COLUMN id_clinica ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.clinica_id_clinica_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: consentimiento_informado; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.consentimiento_informado (
    id_consentimiento bigint NOT NULL,
    id_cirugia bigint NOT NULL,
    nombre_procedimiento character varying(200) NOT NULL,
    objetivo_procedimiento text NOT NULL,
    caracteristicas_procedimiento text NOT NULL,
    riesgos_procedimiento text NOT NULL,
    id_medico integer NOT NULL,
    firmado_por_medico boolean DEFAULT false NOT NULL,
    firmante_tipo character varying(20) NOT NULL,
    id_paciente_encargado integer,
    firmado_por_firmante boolean DEFAULT false NOT NULL,
    fecha_obtencion timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_consentimiento_encargado CHECK (((((firmante_tipo)::text = 'Paciente'::text) AND (id_paciente_encargado IS NULL)) OR (((firmante_tipo)::text <> 'Paciente'::text) AND (id_paciente_encargado IS NOT NULL)))),
    CONSTRAINT ck_consentimiento_firmante CHECK (((firmante_tipo)::text = ANY ((ARRAY['Paciente'::character varying, 'Familiar'::character varying, 'Tutor'::character varying, 'Representante legal'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.consentimiento_informado OWNER TO user1;

--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.consentimiento_informado ALTER COLUMN id_consentimiento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.consentimiento_informado_id_consentimiento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: consulta; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.consulta (
    id_consulta bigint NOT NULL,
    id_cita bigint NOT NULL,
    id_episodio bigint NOT NULL,
    fecha_hora timestamp with time zone DEFAULT now() NOT NULL,
    id_diagnostico integer NOT NULL,
    otros_datos_interes text,
    notas_observaciones text
);


ALTER TABLE hospitales_occidente.consulta OWNER TO user1;

--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.consulta ALTER COLUMN id_consulta ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.consulta_id_consulta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: consumo_insumo; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.consumo_insumo (
    id_consumo_insumo bigint NOT NULL,
    id_ingreso bigint NOT NULL,
    id_insumo integer NOT NULL,
    cantidad integer NOT NULL,
    fecha_hora timestamp with time zone DEFAULT now() NOT NULL,
    id_personal integer,
    CONSTRAINT ck_consumo_cantidad CHECK ((cantidad > 0))
);


ALTER TABLE hospitales_occidente.consumo_insumo OWNER TO user1;

--
-- Name: consumo_insumo_id_consumo_insumo_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.consumo_insumo ALTER COLUMN id_consumo_insumo ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.consumo_insumo_id_consumo_insumo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: departamento; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.departamento (
    id_departamento integer NOT NULL,
    nombre character varying(50) NOT NULL,
    CONSTRAINT ck_departamento_nombre CHECK ((length(TRIM(BOTH FROM nombre)) >= 3))
);


ALTER TABLE hospitales_occidente.departamento OWNER TO user1;

--
-- Name: departamento_id_departamento_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.departamento ALTER COLUMN id_departamento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.departamento_id_departamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: diagnostico; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.diagnostico (
    id_diagnostico integer NOT NULL,
    codigo_cie10 character varying(10) NOT NULL,
    descripcion character varying(250) NOT NULL,
    CONSTRAINT ck_diagnostico_codigo CHECK (((codigo_cie10)::text ~ '^[A-Z][0-9]{2}(\.[0-9]{1,2})?$'::text))
);


ALTER TABLE hospitales_occidente.diagnostico OWNER TO user1;

--
-- Name: diagnostico_id_diagnostico_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.diagnostico ALTER COLUMN id_diagnostico ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.diagnostico_id_diagnostico_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: direccion; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.direccion (
    id_direccion integer NOT NULL,
    id_municipio integer NOT NULL,
    area character varying(7) NOT NULL,
    detalle character varying(200) NOT NULL,
    CONSTRAINT ck_direccion_area CHECK (((area)::text = ANY ((ARRAY['Urbana'::character varying, 'Rural'::character varying])::text[]))),
    CONSTRAINT ck_direccion_det CHECK ((length(TRIM(BOTH FROM detalle)) >= 5))
);


ALTER TABLE hospitales_occidente.direccion OWNER TO user1;

--
-- Name: direccion_id_direccion_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.direccion ALTER COLUMN id_direccion ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.direccion_id_direccion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: egreso; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.egreso (
    id_egreso bigint NOT NULL,
    id_ingreso bigint NOT NULL,
    fecha_hora_egreso timestamp with time zone DEFAULT now() NOT NULL,
    id_diagnostico_principal integer NOT NULL,
    motivo_egreso character varying(300) NOT NULL,
    id_medico integer NOT NULL,
    codigo_egreso character varying(10) NOT NULL,
    egreso_sin_consentimiento boolean DEFAULT false NOT NULL,
    motivo_sin_consentimiento character varying(300),
    id_traslado bigint,
    id_hospital_referido integer,
    CONSTRAINT ck_egreso_codigo CHECK (((codigo_egreso)::text = ANY ((ARRAY['Vivo'::character varying, 'Muerto'::character varying, 'Embarazo'::character varying, 'Parto'::character varying])::text[]))),
    CONSTRAINT ck_egreso_motivo CHECK ((length(TRIM(BOTH FROM motivo_egreso)) >= 4)),
    CONSTRAINT ck_egreso_sin_consentimiento CHECK (((egreso_sin_consentimiento AND (motivo_sin_consentimiento IS NOT NULL)) OR ((NOT egreso_sin_consentimiento) AND (motivo_sin_consentimiento IS NULL))))
);


ALTER TABLE hospitales_occidente.egreso OWNER TO user1;

--
-- Name: egreso_diagnostico_secundario; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.egreso_diagnostico_secundario (
    id_egreso bigint NOT NULL,
    id_diagnostico integer NOT NULL
);


ALTER TABLE hospitales_occidente.egreso_diagnostico_secundario OWNER TO user1;

--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.egreso ALTER COLUMN id_egreso ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.egreso_id_egreso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: enfermero; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.enfermero (
    id_personal integer NOT NULL,
    no_licencia character varying(30) NOT NULL,
    grado_academico character varying(30) NOT NULL,
    area_asignada character varying(50) NOT NULL,
    CONSTRAINT ck_enfermero_area CHECK ((length(TRIM(BOTH FROM area_asignada)) >= 3)),
    CONSTRAINT ck_enfermero_grado CHECK (((grado_academico)::text = ANY ((ARRAY['Auxiliar'::character varying, 'Tecnico'::character varying, 'Licenciado'::character varying, 'Magister'::character varying])::text[]))),
    CONSTRAINT ck_enfermero_licencia CHECK ((length(TRIM(BOTH FROM no_licencia)) >= 3))
);


ALTER TABLE hospitales_occidente.enfermero OWNER TO user1;

--
-- Name: TABLE enfermero; Type: COMMENT; Schema: hospitales_occidente; Owner: user1
--

COMMENT ON TABLE hospitales_occidente.enfermero IS 'Subtipo de personal para colaboradores del cuerpo de enfermeria y asistencia quirurgica';


--
-- Name: COLUMN enfermero.id_personal; Type: COMMENT; Schema: hospitales_occidente; Owner: user1
--

COMMENT ON COLUMN hospitales_occidente.enfermero.id_personal IS 'Identificador compartido y clave foranea hacia el supertipo personal';


--
-- Name: COLUMN enfermero.no_licencia; Type: COMMENT; Schema: hospitales_occidente; Owner: user1
--

COMMENT ON COLUMN hospitales_occidente.enfermero.no_licencia IS 'Numero oficial de colegiacion o licencia de enfermeria profesional';


--
-- Name: COLUMN enfermero.grado_academico; Type: COMMENT; Schema: hospitales_occidente; Owner: user1
--

COMMENT ON COLUMN hospitales_occidente.enfermero.grado_academico IS 'Grado academico de enfermeria (Auxiliar, Tecnico, Licenciado, Magister)';


--
-- Name: COLUMN enfermero.area_asignada; Type: COMMENT; Schema: hospitales_occidente; Owner: user1
--

COMMENT ON COLUMN hospitales_occidente.enfermero.area_asignada IS 'Area operativa o de servicio asignada al personal de enfermeria';


--
-- Name: episodio; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.episodio (
    id_episodio bigint NOT NULL,
    id_paciente integer NOT NULL,
    id_hospital integer NOT NULL,
    fecha_apertura timestamp with time zone DEFAULT now() NOT NULL,
    fecha_cierre timestamp with time zone,
    CONSTRAINT ck_episodio_fechas CHECK (((fecha_cierre IS NULL) OR (fecha_cierre >= fecha_apertura)))
);


ALTER TABLE hospitales_occidente.episodio OWNER TO user1;

--
-- Name: episodio_id_episodio_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.episodio ALTER COLUMN id_episodio ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.episodio_id_episodio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: equipo; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.equipo (
    id_equipo integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion character varying(300),
    tipo character varying(10) NOT NULL,
    funcion character varying(15) NOT NULL,
    CONSTRAINT ck_equipo_funcion CHECK (((funcion)::text = ANY ((ARRAY['Exploracion'::character varying, 'Diagnostico'::character varying, 'Tratamiento'::character varying, 'Rehabilitacion'::character varying, 'Otro'::character varying])::text[]))),
    CONSTRAINT ck_equipo_tipo CHECK (((tipo)::text = ANY ((ARRAY['Medico'::character varying, 'Quirurgico'::character varying, 'Otro'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.equipo OWNER TO user1;

--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.equipo ALTER COLUMN id_equipo ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.equipo_id_equipo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: espacio_atencion; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.espacio_atencion (
    id_espacio integer NOT NULL,
    id_unidad_hospital integer NOT NULL,
    tipo character varying(10) NOT NULL,
    codigo character varying(15) NOT NULL,
    habilitado boolean DEFAULT true NOT NULL,
    CONSTRAINT ck_espacio_codigo CHECK ((length(TRIM(BOTH FROM codigo)) >= 2)),
    CONSTRAINT ck_espacio_tipo CHECK (((tipo)::text = ANY ((ARRAY['Camilla'::character varying, 'Quirofano'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.espacio_atencion OWNER TO user1;

--
-- Name: espacio_atencion_id_espacio_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.espacio_atencion ALTER COLUMN id_espacio ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.espacio_atencion_id_espacio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: especialidad; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.especialidad (
    id_especialidad integer NOT NULL,
    nombre character varying(80) NOT NULL,
    tipo character varying(10) NOT NULL,
    CONSTRAINT ck_especialidad_tipo CHECK (((tipo)::text = ANY ((ARRAY['Clinica'::character varying, 'Quirurgica'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.especialidad OWNER TO user1;

--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.especialidad ALTER COLUMN id_especialidad ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.especialidad_id_especialidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: evaluacion_preanestesica; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.evaluacion_preanestesica (
    id_evaluacion bigint NOT NULL,
    id_cirugia bigint NOT NULL,
    clasificacion_asa smallint NOT NULL,
    id_medico_clasifica integer NOT NULL,
    firmado_medico_clasifica boolean DEFAULT false NOT NULL,
    plan_anestesia text NOT NULL,
    id_anestesiologo integer NOT NULL,
    fecha_hora timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_evaluacion_asa CHECK (((clasificacion_asa >= 1) AND (clasificacion_asa <= 6))),
    CONSTRAINT ck_evaluacion_plan CHECK ((length(TRIM(BOTH FROM plan_anestesia)) >= 5))
);


ALTER TABLE hospitales_occidente.evaluacion_preanestesica OWNER TO user1;

--
-- Name: evaluacion_preanestesica_id_evaluacion_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.evaluacion_preanestesica ALTER COLUMN id_evaluacion ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.evaluacion_preanestesica_id_evaluacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: examen_laboratorio; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.examen_laboratorio (
    id_examen integer NOT NULL,
    nombre character varying(120) NOT NULL,
    CONSTRAINT ck_examen_lab_nombre CHECK ((length(TRIM(BOTH FROM nombre)) >= 3))
);


ALTER TABLE hospitales_occidente.examen_laboratorio OWNER TO user1;

--
-- Name: examen_laboratorio_id_examen_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.examen_laboratorio ALTER COLUMN id_examen ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.examen_laboratorio_id_examen_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: factura; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.factura (
    id_factura bigint NOT NULL,
    serie character varying(10) DEFAULT 'A'::character varying NOT NULL,
    numero_factura character varying(20) NOT NULL,
    id_episodio bigint NOT NULL,
    fecha_emision timestamp with time zone DEFAULT now() NOT NULL,
    nit_cliente character varying(15) DEFAULT 'CF'::character varying NOT NULL,
    nombre_cliente character varying(150) NOT NULL,
    descripcion character varying(300) NOT NULL,
    numero_cuotas smallint DEFAULT 1 NOT NULL,
    id_personal_emite integer NOT NULL,
    estado character varying(10) DEFAULT 'Emitida'::character varying NOT NULL,
    CONSTRAINT ck_factura_cuotas CHECK (((numero_cuotas >= 1) AND (numero_cuotas <= 12))),
    CONSTRAINT ck_factura_desc CHECK ((length(TRIM(BOTH FROM descripcion)) >= 5)),
    CONSTRAINT ck_factura_estado CHECK (((estado)::text = ANY ((ARRAY['Emitida'::character varying, 'Anulada'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.factura OWNER TO user1;

--
-- Name: factura_detalle; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.factura_detalle (
    id_factura_detalle bigint NOT NULL,
    id_factura bigint NOT NULL,
    concepto character varying(25) NOT NULL,
    descripcion character varying(200) NOT NULL,
    cantidad numeric(10,2) DEFAULT 1 NOT NULL,
    precio_unitario numeric(12,2) NOT NULL,
    porcentaje_aplicado numeric(5,2) DEFAULT 100 NOT NULL,
    id_consulta bigint,
    id_ingreso bigint,
    id_cirugia bigint,
    CONSTRAINT ck_facdet_cantidad CHECK ((cantidad > (0)::numeric)),
    CONSTRAINT ck_facdet_concepto CHECK (((concepto)::text = ANY ((ARRAY['Consulta'::character varying, 'Emergencia'::character varying, 'Cirugia'::character varying, 'Hospitalizacion'::character varying, 'Dias de internamiento'::character varying, 'Insumos'::character varying, 'Otro'::character varying])::text[]))),
    CONSTRAINT ck_facdet_origen CHECK ((num_nonnulls(id_consulta, id_ingreso, id_cirugia) <= 1)),
    CONSTRAINT ck_facdet_porcentaje CHECK (((porcentaje_aplicado >= (0)::numeric) AND (porcentaje_aplicado <= (200)::numeric))),
    CONSTRAINT ck_facdet_precio CHECK ((precio_unitario >= (0)::numeric))
);


ALTER TABLE hospitales_occidente.factura_detalle OWNER TO user1;

--
-- Name: factura_detalle_id_factura_detalle_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.factura_detalle ALTER COLUMN id_factura_detalle ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.factura_detalle_id_factura_detalle_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: factura_id_factura_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.factura ALTER COLUMN id_factura ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.factura_id_factura_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: historia_clinica; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.historia_clinica (
    id_historia_clinica bigint NOT NULL,
    id_episodio bigint NOT NULL,
    id_medico integer NOT NULL,
    fecha_hora timestamp with time zone DEFAULT now() NOT NULL,
    tipo_interrogatorio character varying(10) NOT NULL,
    informante character varying(120),
    antecedentes_heredofamiliares text,
    antecedentes_personales_no_patologicos text,
    antecedentes_patologicos text,
    padecimiento_actual text NOT NULL,
    interrogatorio_aparatos_sistemas text,
    sintomas_generales_terapeutica text,
    estudios_previos text,
    id_signos_vitales bigint,
    exploracion_general text,
    explo_cabeza text,
    explo_cuello text,
    explo_torax text,
    explo_abdomen text,
    explo_extremidades text,
    explo_columna_vertebral text,
    explo_cavidad_bucal text,
    explo_cavidad_vaginal text,
    explo_cavidad_rectal text,
    explo_conducto_auditivo_externo text,
    CONSTRAINT ck_historia_informante CHECK (((((tipo_interrogatorio)::text = 'Indirecto'::text) AND (informante IS NOT NULL)) OR (((tipo_interrogatorio)::text = 'Directo'::text) AND (informante IS NULL)))),
    CONSTRAINT ck_historia_interrog CHECK (((tipo_interrogatorio)::text = ANY ((ARRAY['Directo'::character varying, 'Indirecto'::character varying])::text[]))),
    CONSTRAINT ck_historia_padecimiento CHECK ((length(TRIM(BOTH FROM padecimiento_actual)) >= 5))
);


ALTER TABLE hospitales_occidente.historia_clinica OWNER TO user1;

--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.historia_clinica ALTER COLUMN id_historia_clinica ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.historia_clinica_id_historia_clinica_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: horario_medico; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.horario_medico (
    id_horario integer NOT NULL,
    id_medico integer NOT NULL,
    id_clinica integer NOT NULL,
    dia_semana smallint NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone NOT NULL,
    CONSTRAINT ck_horario_dia CHECK (((dia_semana >= 1) AND (dia_semana <= 7))),
    CONSTRAINT ck_horario_horas CHECK ((hora_fin > hora_inicio)),
    CONSTRAINT ck_horario_matutino CHECK (((hora_inicio >= '06:00:00'::time without time zone) AND (hora_fin <= '13:00:00'::time without time zone)))
);


ALTER TABLE hospitales_occidente.horario_medico OWNER TO user1;

--
-- Name: horario_medico_id_horario_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.horario_medico ALTER COLUMN id_horario ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.horario_medico_id_horario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: hospital; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.hospital (
    id_hospital integer NOT NULL,
    codigo character varying(10) NOT NULL,
    nombre character varying(120) NOT NULL,
    id_direccion integer NOT NULL,
    telefono character varying(15),
    correo character varying(100),
    es_interno boolean DEFAULT true NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    CONSTRAINT ck_hospital_codigo CHECK (((codigo)::text ~ '^[A-Z0-9\-]{3,10}$'::text)),
    CONSTRAINT ck_hospital_correo CHECK (((correo IS NULL) OR ((correo)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text))),
    CONSTRAINT ck_hospital_telefono CHECK (((telefono IS NULL) OR ((telefono)::text ~ '^(\+?502)?[0-9]{8}$'::text)))
);


ALTER TABLE hospitales_occidente.hospital OWNER TO user1;

--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.hospital ALTER COLUMN id_hospital ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.hospital_id_hospital_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ingreso; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.ingreso (
    id_ingreso bigint NOT NULL,
    id_episodio bigint NOT NULL,
    id_unidad_hospital integer NOT NULL,
    id_servicio integer NOT NULL,
    fecha_hora_ingreso timestamp with time zone DEFAULT now() NOT NULL,
    motivo_ingreso character varying(300) NOT NULL,
    id_diagnostico_presuntivo integer NOT NULL,
    id_medico integer NOT NULL,
    id_espacio integer,
    id_paciente_encargado integer,
    estado_actual_paciente character varying(500) NOT NULL,
    prioridad_triage smallint,
    dias_estimados_estancia smallint,
    CONSTRAINT ck_ingreso_dias CHECK (((dias_estimados_estancia IS NULL) OR (dias_estimados_estancia > 0))),
    CONSTRAINT ck_ingreso_motivo CHECK ((length(TRIM(BOTH FROM motivo_ingreso)) >= 5)),
    CONSTRAINT ck_ingreso_triage CHECK (((prioridad_triage IS NULL) OR ((prioridad_triage >= 1) AND (prioridad_triage <= 5))))
);


ALTER TABLE hospitales_occidente.ingreso OWNER TO user1;

--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.ingreso ALTER COLUMN id_ingreso ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.ingreso_id_ingreso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: instrumento; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.instrumento (
    id_instrumento integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion character varying(300),
    tipo character varying(10) NOT NULL,
    funcion character varying(12) NOT NULL,
    CONSTRAINT ck_instrumento_funcion CHECK (((funcion)::text = ANY ((ARRAY['Corte'::character varying, 'Contenido'::character varying, 'Hemostatica'::character varying, 'Retractor'::character varying, 'Accesorio'::character varying, 'Implante'::character varying, 'Otro'::character varying])::text[]))),
    CONSTRAINT ck_instrumento_tipo CHECK (((tipo)::text = ANY ((ARRAY['Medico'::character varying, 'Quirurgico'::character varying, 'Otro'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.instrumento OWNER TO user1;

--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.instrumento ALTER COLUMN id_instrumento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.instrumento_id_instrumento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: insumo; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.insumo (
    id_insumo integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion character varying(300),
    material character varying(80),
    tipo character varying(10) NOT NULL,
    CONSTRAINT ck_insumo_tipo CHECK (((tipo)::text = ANY ((ARRAY['Medico'::character varying, 'Quirurgico'::character varying, 'Otro'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.insumo OWNER TO user1;

--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.insumo ALTER COLUMN id_insumo ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.insumo_id_insumo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: item_verificacion; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.item_verificacion (
    id_item integer NOT NULL,
    id_momento integer NOT NULL,
    descripcion character varying(250) NOT NULL,
    tipo_resultado character varying(15) NOT NULL,
    orden smallint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_item_orden CHECK ((orden > 0)),
    CONSTRAINT ck_item_tipo_resultado CHECK (((tipo_resultado)::text = ANY ((ARRAY['Exito o fallo'::character varying, 'Aceptabilidad'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.item_verificacion OWNER TO user1;

--
-- Name: item_verificacion_id_item_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.item_verificacion ALTER COLUMN id_item ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.item_verificacion_id_item_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: medicamento; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.medicamento (
    id_medicamento integer NOT NULL,
    nombre character varying(120) NOT NULL,
    presentacion character varying(80),
    CONSTRAINT ck_medicamento_nombre CHECK ((length(TRIM(BOTH FROM nombre)) >= 2))
);


ALTER TABLE hospitales_occidente.medicamento OWNER TO user1;

--
-- Name: medicamento_id_medicamento_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.medicamento ALTER COLUMN id_medicamento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.medicamento_id_medicamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: medico; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.medico (
    id_personal integer NOT NULL,
    no_colegiado character varying(20) NOT NULL,
    condicion character varying(10) NOT NULL,
    institucion_origen character varying(120),
    tarifa_consulta numeric(10,2) DEFAULT 0 NOT NULL,
    id_superior integer,
    nivel_acceso character varying(30) DEFAULT 'Medico Asistencial'::character varying NOT NULL,
    CONSTRAINT ck_medico_colegiado CHECK ((length(TRIM(BOTH FROM no_colegiado)) >= 3)),
    CONSTRAINT ck_medico_condicion CHECK (((condicion)::text = ANY ((ARRAY['Planta'::character varying, 'Residente'::character varying, 'Interno'::character varying, 'Externo'::character varying])::text[]))),
    CONSTRAINT ck_medico_externo CHECK (((((condicion)::text = 'Externo'::text) AND (institucion_origen IS NOT NULL)) OR (((condicion)::text <> 'Externo'::text) AND (institucion_origen IS NULL)))),
    CONSTRAINT ck_medico_nivel_acceso CHECK (((nivel_acceso)::text = ANY ((ARRAY['Medico Asistencial'::character varying, 'Jefe de Guardia'::character varying, 'Jefe de Servicio'::character varying, 'Director Medico'::character varying, 'Auditor Medico'::character varying])::text[]))),
    CONSTRAINT ck_medico_no_autosupervision CHECK (((id_superior IS NULL) OR (id_superior <> id_personal))),
    CONSTRAINT ck_medico_tarifa CHECK ((tarifa_consulta >= (0)::numeric))
);


ALTER TABLE hospitales_occidente.medico OWNER TO user1;

--
-- Name: COLUMN medico.id_superior; Type: COMMENT; Schema: hospitales_occidente; Owner: user1
--

COMMENT ON COLUMN hospitales_occidente.medico.id_superior IS 'Referencia foranea autorreferencial al medico superior inmediato en la linea de mando';


--
-- Name: COLUMN medico.nivel_acceso; Type: COMMENT; Schema: hospitales_occidente; Owner: user1
--

COMMENT ON COLUMN hospitales_occidente.medico.nivel_acceso IS 'Nivel funcional de responsabilidad y acceso dentro del escalafon medico';


--
-- Name: medico_especialidad; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.medico_especialidad (
    id_medico integer NOT NULL,
    id_especialidad integer NOT NULL,
    es_principal boolean DEFAULT false NOT NULL
);


ALTER TABLE hospitales_occidente.medico_especialidad OWNER TO user1;

--
-- Name: metodo_pago; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.metodo_pago (
    id_metodo_pago integer NOT NULL,
    nombre character varying(30) NOT NULL,
    CONSTRAINT ck_metodo_pago_nombre CHECK ((length(TRIM(BOTH FROM nombre)) >= 3))
);


ALTER TABLE hospitales_occidente.metodo_pago OWNER TO user1;

--
-- Name: metodo_pago_id_metodo_pago_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.metodo_pago ALTER COLUMN id_metodo_pago ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.metodo_pago_id_metodo_pago_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: momento_quirurgico; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.momento_quirurgico (
    id_momento integer NOT NULL,
    nombre character varying(60) NOT NULL,
    fase character varying(15) NOT NULL,
    orden smallint NOT NULL,
    CONSTRAINT ck_momento_fase CHECK (((fase)::text = ANY ((ARRAY['Preoperatorio'::character varying, 'Intraoperatorio'::character varying, 'Postoperatorio'::character varying])::text[]))),
    CONSTRAINT ck_momento_orden CHECK ((orden > 0))
);


ALTER TABLE hospitales_occidente.momento_quirurgico OWNER TO user1;

--
-- Name: momento_quirurgico_id_momento_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.momento_quirurgico ALTER COLUMN id_momento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.momento_quirurgico_id_momento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: municipio; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.municipio (
    id_municipio integer NOT NULL,
    id_departamento integer NOT NULL,
    nombre character varying(80) NOT NULL,
    CONSTRAINT ck_municipio_nombre CHECK ((length(TRIM(BOTH FROM nombre)) >= 2))
);


ALTER TABLE hospitales_occidente.municipio OWNER TO user1;

--
-- Name: municipio_id_municipio_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.municipio ALTER COLUMN id_municipio ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.municipio_id_municipio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: orden_laboratorio; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.orden_laboratorio (
    id_orden_laboratorio bigint NOT NULL,
    id_consulta bigint NOT NULL,
    fecha_emision date DEFAULT CURRENT_DATE NOT NULL,
    indicaciones text
);


ALTER TABLE hospitales_occidente.orden_laboratorio OWNER TO user1;

--
-- Name: orden_laboratorio_detalle; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.orden_laboratorio_detalle (
    id_orden_laboratorio bigint NOT NULL,
    id_examen integer NOT NULL
);


ALTER TABLE hospitales_occidente.orden_laboratorio_detalle OWNER TO user1;

--
-- Name: orden_laboratorio_id_orden_laboratorio_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.orden_laboratorio ALTER COLUMN id_orden_laboratorio ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.orden_laboratorio_id_orden_laboratorio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: paciente; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.paciente (
    id_paciente integer NOT NULL,
    id_persona integer NOT NULL,
    no_expediente character varying(20) NOT NULL,
    estado_civil character varying(15) DEFAULT 'Soltero'::character varying NOT NULL,
    no_seguro_social character varying(20),
    religion character varying(50),
    ocupacion character varying(80),
    id_municipio_nacimiento integer,
    CONSTRAINT ck_paciente_estado_civil CHECK (((estado_civil)::text = ANY ((ARRAY['Soltero'::character varying, 'Casado'::character varying, 'Divorciado'::character varying, 'Viudo'::character varying, 'Union de hecho'::character varying])::text[]))),
    CONSTRAINT ck_paciente_expediente CHECK ((length(TRIM(BOTH FROM no_expediente)) >= 3))
);


ALTER TABLE hospitales_occidente.paciente OWNER TO user1;

--
-- Name: paciente_encargado; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.paciente_encargado (
    id_paciente_encargado integer NOT NULL,
    id_paciente integer NOT NULL,
    id_persona integer NOT NULL,
    id_parentesco integer NOT NULL,
    es_principal boolean DEFAULT false NOT NULL
);


ALTER TABLE hospitales_occidente.paciente_encargado OWNER TO user1;

--
-- Name: paciente_encargado_id_paciente_encargado_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.paciente_encargado ALTER COLUMN id_paciente_encargado ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.paciente_encargado_id_paciente_encargado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.paciente ALTER COLUMN id_paciente ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.paciente_id_paciente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pago; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.pago (
    id_pago bigint NOT NULL,
    id_factura bigint NOT NULL,
    numero_cuota smallint NOT NULL,
    monto numeric(12,2) NOT NULL,
    fecha_pago timestamp with time zone DEFAULT now() NOT NULL,
    id_metodo_pago integer NOT NULL,
    id_unidad_hospital integer NOT NULL,
    id_personal_recibe integer NOT NULL,
    referencia character varying(50),
    CONSTRAINT ck_pago_cuota CHECK (((numero_cuota >= 1) AND (numero_cuota <= 12))),
    CONSTRAINT ck_pago_monto CHECK ((monto > (0)::numeric))
);


ALTER TABLE hospitales_occidente.pago OWNER TO user1;

--
-- Name: pago_id_pago_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.pago ALTER COLUMN id_pago ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.pago_id_pago_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: parentesco; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.parentesco (
    id_parentesco integer NOT NULL,
    nombre character varying(40) NOT NULL,
    CONSTRAINT ck_parentesco_nombre CHECK ((length(TRIM(BOTH FROM nombre)) >= 3))
);


ALTER TABLE hospitales_occidente.parentesco OWNER TO user1;

--
-- Name: parentesco_id_parentesco_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.parentesco ALTER COLUMN id_parentesco ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.parentesco_id_parentesco_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: persona; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.persona (
    id_persona integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    dpi character varying(13),
    fecha_nacimiento date NOT NULL,
    sexo character varying(9) NOT NULL,
    telefono character varying(15),
    id_direccion integer NOT NULL,
    creado_en timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_persona_apellidos CHECK ((length(TRIM(BOTH FROM apellidos)) >= 2)),
    CONSTRAINT ck_persona_dpi CHECK (((dpi IS NULL) OR ((dpi)::text ~ '^[0-9]{13}$'::text))),
    CONSTRAINT ck_persona_nacimiento CHECK ((fecha_nacimiento >= '1900-01-01'::date)),
    CONSTRAINT ck_persona_nombres CHECK ((length(TRIM(BOTH FROM nombres)) >= 2)),
    CONSTRAINT ck_persona_sexo CHECK (((sexo)::text = ANY ((ARRAY['Masculino'::character varying, 'Femenino'::character varying])::text[]))),
    CONSTRAINT ck_persona_telefono CHECK (((telefono IS NULL) OR ((telefono)::text ~ '^(\+?502)?[0-9]{8}$'::text)))
);


ALTER TABLE hospitales_occidente.persona OWNER TO user1;

--
-- Name: persona_id_persona_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.persona ALTER COLUMN id_persona ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.persona_id_persona_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: personal; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.personal (
    id_personal integer NOT NULL,
    id_persona integer NOT NULL,
    tipo_personal character varying(30) NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    fecha_contratacion date DEFAULT CURRENT_DATE NOT NULL,
    salario numeric(10,2) DEFAULT 8000.00 NOT NULL,
    CONSTRAINT ck_personal_salario CHECK ((salario >= (0)::numeric)),
    CONSTRAINT ck_personal_tipo CHECK (((tipo_personal)::text = ANY ((ARRAY['Medico'::character varying, 'Enfermero'::character varying, 'Practicante de medicina'::character varying, 'Practicante de enfermeria'::character varying, 'Administrativo'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.personal OWNER TO user1;

--
-- Name: COLUMN personal.fecha_contratacion; Type: COMMENT; Schema: hospitales_occidente; Owner: user1
--

COMMENT ON COLUMN hospitales_occidente.personal.fecha_contratacion IS 'Fecha oficial de inicio de relacion laboral institucional';


--
-- Name: COLUMN personal.salario; Type: COMMENT; Schema: hospitales_occidente; Owner: user1
--

COMMENT ON COLUMN hospitales_occidente.personal.salario IS 'Salario base mensual asignado al colaborador';


--
-- Name: personal_id_personal_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.personal ALTER COLUMN id_personal ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.personal_id_personal_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: procedimiento_quirurgico; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.procedimiento_quirurgico (
    id_procedimiento integer NOT NULL,
    id_especialidad integer NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion character varying(300),
    CONSTRAINT ck_proc_quirurgico_nombre CHECK ((length(TRIM(BOTH FROM nombre)) >= 4))
);


ALTER TABLE hospitales_occidente.procedimiento_quirurgico OWNER TO user1;

--
-- Name: procedimiento_quirurgico_id_procedimiento_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.procedimiento_quirurgico ALTER COLUMN id_procedimiento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.procedimiento_quirurgico_id_procedimiento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: receta; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.receta (
    id_receta bigint NOT NULL,
    id_consulta bigint NOT NULL,
    fecha_emision date DEFAULT CURRENT_DATE NOT NULL,
    id_cita_proxima bigint,
    orientacion_paciente text
);


ALTER TABLE hospitales_occidente.receta OWNER TO user1;

--
-- Name: receta_detalle; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.receta_detalle (
    id_receta_detalle bigint NOT NULL,
    id_receta bigint NOT NULL,
    id_medicamento integer NOT NULL,
    dosis character varying(100) NOT NULL,
    duracion_dias smallint NOT NULL,
    CONSTRAINT ck_receta_dosis CHECK ((length(TRIM(BOTH FROM dosis)) >= 2)),
    CONSTRAINT ck_receta_duracion CHECK ((duracion_dias > 0))
);


ALTER TABLE hospitales_occidente.receta_detalle OWNER TO user1;

--
-- Name: receta_detalle_id_receta_detalle_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.receta_detalle ALTER COLUMN id_receta_detalle ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.receta_detalle_id_receta_detalle_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: receta_id_receta_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.receta ALTER COLUMN id_receta ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.receta_id_receta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: registro_signos_vitales; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.registro_signos_vitales (
    id_signos_vitales bigint NOT NULL,
    id_episodio bigint NOT NULL,
    fecha_hora timestamp with time zone DEFAULT now() NOT NULL,
    presion_sistolica smallint,
    presion_diastolica smallint,
    frecuencia_cardiaca smallint,
    frecuencia_respiratoria smallint,
    temperatura_c numeric(4,1),
    saturacion_oxigeno smallint,
    peso_kg numeric(5,2),
    talla_cm numeric(5,1),
    id_personal integer,
    CONSTRAINT ck_signos_diastolica CHECK (((presion_diastolica IS NULL) OR ((presion_diastolica >= 20) AND (presion_diastolica <= 200)))),
    CONSTRAINT ck_signos_fc CHECK (((frecuencia_cardiaca IS NULL) OR ((frecuencia_cardiaca >= 20) AND (frecuencia_cardiaca <= 300)))),
    CONSTRAINT ck_signos_fr CHECK (((frecuencia_respiratoria IS NULL) OR ((frecuencia_respiratoria >= 4) AND (frecuencia_respiratoria <= 80)))),
    CONSTRAINT ck_signos_peso CHECK (((peso_kg IS NULL) OR ((peso_kg > (0)::numeric) AND (peso_kg <= 500.0)))),
    CONSTRAINT ck_signos_presion CHECK (((presion_sistolica IS NULL) OR (presion_diastolica IS NULL) OR (presion_sistolica > presion_diastolica))),
    CONSTRAINT ck_signos_sato2 CHECK (((saturacion_oxigeno IS NULL) OR ((saturacion_oxigeno >= 0) AND (saturacion_oxigeno <= 100)))),
    CONSTRAINT ck_signos_sistolica CHECK (((presion_sistolica IS NULL) OR ((presion_sistolica >= 40) AND (presion_sistolica <= 300)))),
    CONSTRAINT ck_signos_talla CHECK (((talla_cm IS NULL) OR ((talla_cm >= 20.0) AND (talla_cm <= 250.0)))),
    CONSTRAINT ck_signos_temp CHECK (((temperatura_c IS NULL) OR ((temperatura_c >= 25.0) AND (temperatura_c <= 45.0))))
);


ALTER TABLE hospitales_occidente.registro_signos_vitales OWNER TO user1;

--
-- Name: registro_signos_vitales_id_signos_vitales_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.registro_signos_vitales ALTER COLUMN id_signos_vitales ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.registro_signos_vitales_id_signos_vitales_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: revision_miembro_comite; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.revision_miembro_comite (
    id_revision bigint NOT NULL,
    id_medico integer NOT NULL
);


ALTER TABLE hospitales_occidente.revision_miembro_comite OWNER TO user1;

--
-- Name: revision_solicitud; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.revision_solicitud (
    id_revision bigint NOT NULL,
    id_solicitud_cirugia bigint NOT NULL,
    decision character varying(10) NOT NULL,
    fecha_hora timestamp with time zone DEFAULT now() NOT NULL,
    razones character varying(500),
    CONSTRAINT ck_revision_decision CHECK (((decision)::text = ANY ((ARRAY['Aprobada'::character varying, 'Rechazada'::character varying])::text[]))),
    CONSTRAINT ck_revision_razones CHECK (((((decision)::text = 'Rechazada'::text) AND (razones IS NOT NULL)) OR ((decision)::text = 'Aprobada'::text)))
);


ALTER TABLE hospitales_occidente.revision_solicitud OWNER TO user1;

--
-- Name: revision_solicitud_id_revision_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.revision_solicitud ALTER COLUMN id_revision ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.revision_solicitud_id_revision_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: servicio_medico; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.servicio_medico (
    id_servicio integer NOT NULL,
    id_tipo_unidad integer NOT NULL,
    nombre character varying(100) NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    CONSTRAINT ck_servicio_medico_nombre CHECK ((length(TRIM(BOTH FROM nombre)) >= 3))
);


ALTER TABLE hospitales_occidente.servicio_medico OWNER TO user1;

--
-- Name: servicio_medico_id_servicio_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.servicio_medico ALTER COLUMN id_servicio ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.servicio_medico_id_servicio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: solicitud_cirugia; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.solicitud_cirugia (
    id_solicitud_cirugia bigint NOT NULL,
    id_episodio bigint NOT NULL,
    id_historia_clinica bigint NOT NULL,
    id_cirujano integer NOT NULL,
    caracter character varying(10) NOT NULL,
    id_tipo_anestesia integer NOT NULL,
    tiempo_estimado_min smallint NOT NULL,
    fecha_hora_solicitud timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_solicitud_caracter CHECK (((caracter)::text = ANY ((ARRAY['Urgente'::character varying, 'Programado'::character varying])::text[]))),
    CONSTRAINT ck_solicitud_tiempo CHECK (((tiempo_estimado_min >= 15) AND (tiempo_estimado_min <= 1440)))
);


ALTER TABLE hospitales_occidente.solicitud_cirugia OWNER TO user1;

--
-- Name: solicitud_cirugia_id_solicitud_cirugia_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.solicitud_cirugia ALTER COLUMN id_solicitud_cirugia ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.solicitud_cirugia_id_solicitud_cirugia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: solicitud_equipo; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.solicitud_equipo (
    id_solicitud_cirugia bigint NOT NULL,
    id_equipo integer NOT NULL,
    cantidad integer DEFAULT 1 NOT NULL,
    CONSTRAINT ck_soleq_cantidad CHECK ((cantidad > 0))
);


ALTER TABLE hospitales_occidente.solicitud_equipo OWNER TO user1;

--
-- Name: solicitud_instrumento; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.solicitud_instrumento (
    id_solicitud_cirugia bigint NOT NULL,
    id_instrumento integer NOT NULL,
    cantidad integer DEFAULT 1 NOT NULL,
    CONSTRAINT ck_solinstr_cantidad CHECK ((cantidad > 0))
);


ALTER TABLE hospitales_occidente.solicitud_instrumento OWNER TO user1;

--
-- Name: solicitud_insumo; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.solicitud_insumo (
    id_solicitud_cirugia bigint NOT NULL,
    id_insumo integer NOT NULL,
    cantidad integer DEFAULT 1 NOT NULL,
    CONSTRAINT ck_solinsumo_cantidad CHECK ((cantidad > 0))
);


ALTER TABLE hospitales_occidente.solicitud_insumo OWNER TO user1;

--
-- Name: solicitud_procedimiento; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.solicitud_procedimiento (
    id_solicitud_cirugia bigint NOT NULL,
    id_procedimiento integer NOT NULL
);


ALTER TABLE hospitales_occidente.solicitud_procedimiento OWNER TO user1;

--
-- Name: tarifa_insumo; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.tarifa_insumo (
    id_hospital integer NOT NULL,
    id_insumo integer NOT NULL,
    precio_unitario numeric(12,2) NOT NULL,
    CONSTRAINT ck_tarifa_ins_precio CHECK ((precio_unitario >= (0)::numeric))
);


ALTER TABLE hospitales_occidente.tarifa_insumo OWNER TO user1;

--
-- Name: tarifa_procedimiento; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.tarifa_procedimiento (
    id_hospital integer NOT NULL,
    id_procedimiento integer NOT NULL,
    costo numeric(12,2) NOT NULL,
    CONSTRAINT ck_tarifa_proc_costo CHECK ((costo >= (0)::numeric))
);


ALTER TABLE hospitales_occidente.tarifa_procedimiento OWNER TO user1;

--
-- Name: tarifa_servicio; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.tarifa_servicio (
    id_hospital integer NOT NULL,
    id_servicio integer NOT NULL,
    costo_atencion numeric(12,2) NOT NULL,
    costo_dia numeric(12,2),
    CONSTRAINT ck_tarifa_serv_atenc CHECK ((costo_atencion >= (0)::numeric)),
    CONSTRAINT ck_tarifa_serv_dia CHECK (((costo_dia IS NULL) OR (costo_dia >= (0)::numeric)))
);


ALTER TABLE hospitales_occidente.tarifa_servicio OWNER TO user1;

--
-- Name: tipo_anestesia; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.tipo_anestesia (
    id_tipo_anestesia integer NOT NULL,
    nombre character varying(50) NOT NULL,
    CONSTRAINT ck_tipo_anestesia_nombre CHECK ((length(TRIM(BOTH FROM nombre)) >= 3))
);


ALTER TABLE hospitales_occidente.tipo_anestesia OWNER TO user1;

--
-- Name: tipo_anestesia_id_tipo_anestesia_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.tipo_anestesia ALTER COLUMN id_tipo_anestesia ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.tipo_anestesia_id_tipo_anestesia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tipo_unidad; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.tipo_unidad (
    id_tipo_unidad integer NOT NULL,
    nombre character varying(30) NOT NULL,
    CONSTRAINT ck_tipo_unidad_nombre CHECK (((nombre)::text = ANY ((ARRAY['Consulta externa'::character varying, 'Emergencias'::character varying, 'Cirugia'::character varying, 'Hospitalizacion'::character varying, 'Otro'::character varying])::text[])))
);


ALTER TABLE hospitales_occidente.tipo_unidad OWNER TO user1;

--
-- Name: tipo_unidad_id_tipo_unidad_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.tipo_unidad ALTER COLUMN id_tipo_unidad ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.tipo_unidad_id_tipo_unidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: traslado; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.traslado (
    id_traslado bigint NOT NULL,
    id_episodio bigint NOT NULL,
    fecha_hora timestamp with time zone DEFAULT now() NOT NULL,
    id_medico_indica integer NOT NULL,
    id_hospital_origen integer NOT NULL,
    id_tipo_unidad_origen integer NOT NULL,
    id_servicio_origen integer,
    id_hospital_destino integer NOT NULL,
    id_tipo_unidad_destino integer NOT NULL,
    id_servicio_destino integer,
    id_ingreso_destino bigint,
    motivo character varying(300) NOT NULL,
    consentimiento_otorgado boolean DEFAULT false NOT NULL,
    id_paciente_encargado integer,
    CONSTRAINT ck_traslado_motivo CHECK ((length(TRIM(BOTH FROM motivo)) >= 5)),
    CONSTRAINT ck_traslado_origen_destino CHECK (((id_hospital_origen <> id_hospital_destino) OR (id_tipo_unidad_origen <> id_tipo_unidad_destino)))
);


ALTER TABLE hospitales_occidente.traslado OWNER TO user1;

--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.traslado ALTER COLUMN id_traslado ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.traslado_id_traslado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: turno; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.turno (
    id_turno integer NOT NULL,
    nombre character varying(40) NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone NOT NULL,
    CONSTRAINT ck_turno_horas CHECK ((hora_inicio <> hora_fin))
);


ALTER TABLE hospitales_occidente.turno OWNER TO user1;

--
-- Name: turno_id_turno_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.turno ALTER COLUMN id_turno ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.turno_id_turno_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: unidad_hospital; Type: TABLE; Schema: hospitales_occidente; Owner: user1
--

CREATE TABLE hospitales_occidente.unidad_hospital (
    id_unidad_hospital integer NOT NULL,
    id_hospital integer NOT NULL,
    id_tipo_unidad integer NOT NULL
);


ALTER TABLE hospitales_occidente.unidad_hospital OWNER TO user1;

--
-- Name: unidad_hospital_id_unidad_hospital_seq; Type: SEQUENCE; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE hospitales_occidente.unidad_hospital ALTER COLUMN id_unidad_hospital ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME hospitales_occidente.unidad_hospital_id_unidad_hospital_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_calificacion_resumen_hospital; Type: VIEW; Schema: hospitales_occidente; Owner: user1
--

CREATE VIEW hospitales_occidente.vw_calificacion_resumen_hospital AS
 SELECT h.id_hospital,
    h.nombre AS hospital,
    count(ch.id_calificacion_hospital) AS total_evaluaciones,
    round(avg(ch.puntuacion), 2) AS promedio_estrellas
   FROM ((hospitales_occidente.hospital h
     LEFT JOIN hospitales_occidente.episodio ep ON ((ep.id_hospital = h.id_hospital)))
     LEFT JOIN hospitales_occidente.calificacion_hospital ch ON ((ch.id_episodio = ep.id_episodio)))
  WHERE (h.es_interno = true)
  GROUP BY h.id_hospital, h.nombre;


ALTER VIEW hospitales_occidente.vw_calificacion_resumen_hospital OWNER TO user1;

--
-- Name: vw_cirugias_rechazadas; Type: VIEW; Schema: hospitales_occidente; Owner: user1
--

CREATE VIEW hospitales_occidente.vw_cirugias_rechazadas AS
 SELECT r.id_revision,
    s.id_solicitud_cirugia,
    s.id_episodio,
    ep.id_paciente,
    s.id_cirujano,
    (((pe.nombres)::text || ' '::text) || (pe.apellidos)::text) AS cirujano,
    s.caracter,
    r.fecha_hora AS fecha_revision,
    r.razones AS motivo_rechazo
   FROM ((((hospitales_occidente.revision_solicitud r
     JOIN hospitales_occidente.solicitud_cirugia s ON ((s.id_solicitud_cirugia = r.id_solicitud_cirugia)))
     JOIN hospitales_occidente.episodio ep ON ((ep.id_episodio = s.id_episodio)))
     JOIN hospitales_occidente.personal pl ON ((pl.id_personal = s.id_cirujano)))
     JOIN hospitales_occidente.persona pe ON ((pe.id_persona = pl.id_persona)))
  WHERE ((r.decision)::text = 'Rechazada'::text);


ALTER VIEW hospitales_occidente.vw_cirugias_rechazadas OWNER TO user1;

--
-- Name: vw_egreso_dias; Type: VIEW; Schema: hospitales_occidente; Owner: user1
--

CREATE VIEW hospitales_occidente.vw_egreso_dias AS
 SELECT eg.id_egreso,
    ing.id_ingreso,
    ing.id_episodio,
    tu.nombre AS unidad,
    ing.fecha_hora_ingreso,
    eg.fecha_hora_egreso,
    (GREATEST((1)::numeric, ceil((EXTRACT(epoch FROM (eg.fecha_hora_egreso - ing.fecha_hora_ingreso)) / (86400)::numeric))))::integer AS dias_hospitalizado
   FROM (((hospitales_occidente.egreso eg
     JOIN hospitales_occidente.ingreso ing ON ((ing.id_ingreso = eg.id_ingreso)))
     JOIN hospitales_occidente.unidad_hospital uh ON ((uh.id_unidad_hospital = ing.id_unidad_hospital)))
     JOIN hospitales_occidente.tipo_unidad tu ON ((tu.id_tipo_unidad = uh.id_tipo_unidad)));


ALTER VIEW hospitales_occidente.vw_egreso_dias OWNER TO user1;

--
-- Name: vw_factura_resumen; Type: VIEW; Schema: hospitales_occidente; Owner: user1
--

CREATE VIEW hospitales_occidente.vw_factura_resumen AS
 SELECT f.id_factura,
    f.serie,
    f.numero_factura,
    f.id_episodio,
    f.numero_cuotas,
    f.estado,
    COALESCE(t.total, 0.00) AS total_facturado,
    COALESCE(p.pagado, 0.00) AS total_pagado,
    round((COALESCE(t.total, 0.00) - COALESCE(p.pagado, 0.00)), 2) AS saldo_pendiente
   FROM ((hospitales_occidente.factura f
     LEFT JOIN ( SELECT factura_detalle.id_factura,
            round(sum(((factura_detalle.cantidad * factura_detalle.precio_unitario) * (factura_detalle.porcentaje_aplicado / 100.0))), 2) AS total
           FROM hospitales_occidente.factura_detalle
          GROUP BY factura_detalle.id_factura) t ON ((t.id_factura = f.id_factura)))
     LEFT JOIN ( SELECT pago.id_factura,
            round(sum(pago.monto), 2) AS pagado
           FROM hospitales_occidente.pago
          GROUP BY pago.id_factura) p ON ((p.id_factura = f.id_factura)));


ALTER VIEW hospitales_occidente.vw_factura_resumen OWNER TO user1;

--
-- Name: vw_paciente; Type: VIEW; Schema: hospitales_occidente; Owner: user1
--

CREATE VIEW hospitales_occidente.vw_paciente AS
 SELECT pa.id_paciente,
    pa.no_expediente,
    pe.nombres,
    pe.apellidos,
    pe.dpi,
    pe.sexo,
    pe.fecha_nacimiento,
    (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (pe.fecha_nacimiento)::timestamp with time zone)))::integer AS edad_anios,
    pa.estado_civil,
    pe.telefono,
    di.area,
    di.detalle AS direccion_completa,
    mu.nombre AS municipio,
    de.nombre AS departamento
   FROM ((((hospitales_occidente.paciente pa
     JOIN hospitales_occidente.persona pe ON ((pe.id_persona = pa.id_persona)))
     JOIN hospitales_occidente.direccion di ON ((di.id_direccion = pe.id_direccion)))
     JOIN hospitales_occidente.municipio mu ON ((mu.id_municipio = di.id_municipio)))
     JOIN hospitales_occidente.departamento de ON ((de.id_departamento = mu.id_departamento)));


ALTER VIEW hospitales_occidente.vw_paciente OWNER TO user1;

--
-- Name: cirugia; Type: TABLE; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

CREATE TABLE normalizacion_cirugia.cirugia (
    id_cirugia bigint NOT NULL,
    id_paciente integer NOT NULL,
    id_cirujano integer NOT NULL,
    id_diagnostico integer NOT NULL,
    fecha timestamp with time zone NOT NULL
);


ALTER TABLE normalizacion_cirugia.cirugia OWNER TO usr_admin_occidente;

--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE normalizacion_cirugia.cirugia ALTER COLUMN id_cirugia ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME normalizacion_cirugia.cirugia_id_cirugia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cirugia_insumo; Type: TABLE; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

CREATE TABLE normalizacion_cirugia.cirugia_insumo (
    id_cirugia bigint NOT NULL,
    id_insumo integer NOT NULL,
    cantidad numeric(8,2) NOT NULL,
    CONSTRAINT ck_norm_det_cantidad CHECK ((cantidad > (0)::numeric))
);


ALTER TABLE normalizacion_cirugia.cirugia_insumo OWNER TO usr_admin_occidente;

--
-- Name: cirujano; Type: TABLE; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

CREATE TABLE normalizacion_cirugia.cirujano (
    id_cirujano integer NOT NULL,
    nombre character varying(150) NOT NULL,
    especialidad character varying(100) NOT NULL,
    CONSTRAINT ck_norm_cir_esp CHECK ((length(TRIM(BOTH FROM especialidad)) >= 3)),
    CONSTRAINT ck_norm_cir_nombre CHECK ((length(TRIM(BOTH FROM nombre)) >= 3))
);


ALTER TABLE normalizacion_cirugia.cirujano OWNER TO usr_admin_occidente;

--
-- Name: cirujano_id_cirujano_seq; Type: SEQUENCE; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE normalizacion_cirugia.cirujano ALTER COLUMN id_cirujano ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME normalizacion_cirugia.cirujano_id_cirujano_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: diagnostico; Type: TABLE; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

CREATE TABLE normalizacion_cirugia.diagnostico (
    id_diagnostico integer NOT NULL,
    codigo_diagnostico character varying(20) NOT NULL,
    descripcion character varying(255) NOT NULL,
    CONSTRAINT ck_norm_diag_codigo CHECK ((length(TRIM(BOTH FROM codigo_diagnostico)) >= 2)),
    CONSTRAINT ck_norm_diag_desc CHECK ((length(TRIM(BOTH FROM descripcion)) >= 3))
);


ALTER TABLE normalizacion_cirugia.diagnostico OWNER TO usr_admin_occidente;

--
-- Name: diagnostico_id_diagnostico_seq; Type: SEQUENCE; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE normalizacion_cirugia.diagnostico ALTER COLUMN id_diagnostico ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME normalizacion_cirugia.diagnostico_id_diagnostico_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: insumo; Type: TABLE; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

CREATE TABLE normalizacion_cirugia.insumo (
    id_insumo integer NOT NULL,
    nombre character varying(100) NOT NULL,
    unidad_medida character varying(30) DEFAULT 'Unidad'::character varying NOT NULL,
    CONSTRAINT ck_norm_insumo_nombre CHECK ((length(TRIM(BOTH FROM nombre)) >= 2))
);


ALTER TABLE normalizacion_cirugia.insumo OWNER TO usr_admin_occidente;

--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE normalizacion_cirugia.insumo ALTER COLUMN id_insumo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME normalizacion_cirugia.insumo_id_insumo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: paciente; Type: TABLE; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

CREATE TABLE normalizacion_cirugia.paciente (
    id_paciente integer NOT NULL,
    nombre character varying(150) NOT NULL,
    CONSTRAINT ck_norm_pac_nombre CHECK ((length(TRIM(BOTH FROM nombre)) >= 3))
);


ALTER TABLE normalizacion_cirugia.paciente OWNER TO usr_admin_occidente;

--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE normalizacion_cirugia.paciente ALTER COLUMN id_paciente ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME normalizacion_cirugia.paciente_id_paciente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vista_reporte_cirugia; Type: VIEW; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

CREATE VIEW normalizacion_cirugia.vista_reporte_cirugia AS
 SELECT c.id_cirugia,
    cir.nombre AS nombre_cirujano,
    cir.especialidad AS especialidad_cirujano,
    p.nombre AS nombre_paciente,
    d.codigo_diagnostico,
    d.descripcion AS descripcion_diagnostico,
    c.fecha,
    count(ci.id_insumo) AS total_insumos_usados
   FROM ((((normalizacion_cirugia.cirugia c
     JOIN normalizacion_cirugia.paciente p ON ((p.id_paciente = c.id_paciente)))
     JOIN normalizacion_cirugia.cirujano cir ON ((cir.id_cirujano = c.id_cirujano)))
     JOIN normalizacion_cirugia.diagnostico d ON ((d.id_diagnostico = c.id_diagnostico)))
     LEFT JOIN normalizacion_cirugia.cirugia_insumo ci ON ((ci.id_cirugia = c.id_cirugia)))
  GROUP BY c.id_cirugia, cir.nombre, cir.especialidad, p.nombre, d.codigo_diagnostico, d.descripcion, c.fecha;


ALTER VIEW normalizacion_cirugia.vista_reporte_cirugia OWNER TO usr_admin_occidente;

--
-- Data for Name: asignacion_personal; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.asignacion_personal (id_asignacion, id_personal, id_unidad_hospital, id_turno, fecha_inicio, fecha_fin) FROM stdin;
1	1	1	1	2026-01-01	\N
2	5	1	1	2026-01-01	\N
3	6	1	1	2026-01-01	\N
4	7	1	1	2026-01-01	\N
5	14	1	1	2026-01-01	\N
6	1	3	2	2026-01-01	\N
7	2	3	2	2026-01-01	\N
8	3	3	2	2026-01-01	\N
9	4	3	2	2026-01-01	\N
10	7	2	3	2026-01-01	\N
11	8	2	4	2026-01-01	\N
12	15	3	2	2026-01-01	\N
13	16	3	2	2026-01-01	\N
14	17	2	3	2026-01-01	\N
15	18	4	3	2026-01-01	\N
16	25	1	1	2026-01-01	\N
17	26	2	3	2026-01-01	\N
18	27	3	2	2026-01-01	\N
20	10	2	1	2026-01-01	\N
21	9	2	2	2026-01-01	\N
22	51	1	1	2026-01-01	\N
23	52	2	2	2026-01-01	\N
24	53	3	1	2026-01-01	\N
25	54	4	1	2026-01-01	\N
26	11	5	1	2026-01-01	\N
27	12	6	2	2026-01-01	\N
28	41	7	1	2026-01-01	\N
29	42	6	1	2026-01-01	\N
30	43	5	2	2026-01-01	\N
31	44	6	2	2026-01-01	\N
32	45	5	1	2026-01-01	\N
33	55	6	1	2026-01-01	\N
34	56	5	1	2026-01-01	\N
35	13	9	1	2026-01-01	\N
36	14	10	2	2026-01-01	\N
37	46	10	1	2026-01-01	\N
38	47	9	2	2026-01-01	\N
39	57	12	1	2026-01-01	\N
40	58	11	1	2026-01-01	\N
41	48	13	1	2026-01-01	\N
42	49	14	1	2026-01-01	\N
43	50	13	2	2026-01-01	\N
44	59	14	2	2026-01-01	\N
45	60	16	1	2026-01-01	\N
\.


--
-- Data for Name: bitacora_auditoria_personal; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.bitacora_auditoria_personal (id_auditoria, id_personal, tabla_afectada, campo_modificado, valor_anterior, valor_nuevo, usuario_db, fecha_hora, operacion) FROM stdin;
1	1	personal	salario	8000.00	14500.00	user1	2026-10-26 04:42:55.853857+00	UPDATE
2	2	medico	nivel_acceso	Medico Asistencial	Jefe de Servicio	user1	2026-10-26 04:42:55.862298+00	UPDATE
3	2	medico	id_superior	\N	5	user1	2026-10-26 04:42:55.862475+00	UPDATE
4	7	medico_especialidad	id_especialidad	7	1	user1	2026-10-26 04:42:55.865068+00	UPDATE
5	41	medico_especialidad	id_especialidad	\N	1	user1	2026-10-26 04:43:55.765923+00	INSERT
6	42	medico_especialidad	id_especialidad	\N	7	user1	2026-10-26 04:43:55.766037+00	INSERT
7	43	medico_especialidad	id_especialidad	\N	2	user1	2026-10-26 04:43:55.766123+00	INSERT
8	44	medico_especialidad	id_especialidad	\N	7	user1	2026-10-26 04:43:55.766187+00	INSERT
9	45	medico_especialidad	id_especialidad	\N	10	user1	2026-10-26 04:43:55.766243+00	INSERT
10	46	medico_especialidad	id_especialidad	\N	7	user1	2026-10-26 04:43:55.766288+00	INSERT
11	47	medico_especialidad	id_especialidad	\N	7	user1	2026-10-26 04:43:55.766315+00	INSERT
12	48	medico_especialidad	id_especialidad	\N	1	user1	2026-10-26 04:43:55.766338+00	INSERT
13	49	medico_especialidad	id_especialidad	\N	4	user1	2026-10-26 04:43:55.766362+00	INSERT
14	50	medico_especialidad	id_especialidad	\N	7	user1	2026-10-26 04:43:55.766387+00	INSERT
15	1	medico	nivel_acceso	Medico Asistencial	Director Medico	user1	2026-10-26 04:43:55.767063+00	UPDATE
16	3	medico	nivel_acceso	Medico Asistencial	Jefe de Servicio	user1	2026-10-26 04:43:55.767846+00	UPDATE
17	3	medico	id_superior	\N	1	user1	2026-10-26 04:43:55.767898+00	UPDATE
18	2	medico	id_superior	5	1	user1	2026-10-26 04:43:55.767965+00	UPDATE
19	4	medico	nivel_acceso	Medico Asistencial	Jefe de Guardia	user1	2026-10-26 04:43:55.768747+00	UPDATE
20	4	medico	id_superior	\N	2	user1	2026-10-26 04:43:55.768792+00	UPDATE
21	5	medico	nivel_acceso	Medico Asistencial	Jefe de Guardia	user1	2026-10-26 04:43:55.768855+00	UPDATE
22	5	medico	id_superior	\N	2	user1	2026-10-26 04:43:55.768886+00	UPDATE
23	6	medico	nivel_acceso	Medico Asistencial	Jefe de Guardia	user1	2026-10-26 04:43:55.769391+00	UPDATE
24	6	medico	id_superior	\N	3	user1	2026-10-26 04:43:55.769434+00	UPDATE
25	7	medico	id_superior	\N	4	user1	2026-10-26 04:43:55.769986+00	UPDATE
26	8	medico	id_superior	\N	4	user1	2026-10-26 04:43:55.770026+00	UPDATE
27	9	medico	id_superior	\N	5	user1	2026-10-26 04:43:55.770594+00	UPDATE
28	10	medico	id_superior	\N	6	user1	2026-10-26 04:43:55.771186+00	UPDATE
29	11	medico	nivel_acceso	Medico Asistencial	Director Medico	user1	2026-10-26 04:43:55.77184+00	UPDATE
30	12	medico	nivel_acceso	Medico Asistencial	Jefe de Servicio	user1	2026-10-26 04:43:55.772742+00	UPDATE
31	12	medico	id_superior	\N	11	user1	2026-10-26 04:43:55.772786+00	UPDATE
32	41	medico	id_superior	\N	11	user1	2026-10-26 04:43:55.772841+00	UPDATE
33	42	medico	id_superior	\N	12	user1	2026-10-26 04:43:55.773776+00	UPDATE
34	43	medico	id_superior	\N	41	user1	2026-10-26 04:43:55.774625+00	UPDATE
35	44	medico	id_superior	\N	42	user1	2026-10-26 04:43:55.775292+00	UPDATE
36	45	medico	id_superior	\N	43	user1	2026-10-26 04:43:55.775777+00	UPDATE
37	13	medico	nivel_acceso	Medico Asistencial	Director Medico	user1	2026-10-26 04:43:55.776421+00	UPDATE
38	14	medico	nivel_acceso	Medico Asistencial	Jefe de Servicio	user1	2026-10-26 04:43:55.776873+00	UPDATE
39	14	medico	id_superior	\N	13	user1	2026-10-26 04:43:55.7769+00	UPDATE
40	46	medico	id_superior	\N	14	user1	2026-10-26 04:43:55.777367+00	UPDATE
41	47	medico	id_superior	\N	46	user1	2026-10-26 04:43:55.778037+00	UPDATE
42	49	medico	id_superior	\N	48	user1	2026-10-26 04:43:55.779226+00	UPDATE
43	50	medico	id_superior	\N	49	user1	2026-10-26 04:43:55.779992+00	UPDATE
44	2	medico	id_superior	1	5	usr_admin_occidente	2026-10-26 05:24:08.025029+00	UPDATE
45	2	medico	id_superior	5	1	user1	2026-10-26 05:24:14.359107+00	UPDATE
\.


--
-- Data for Name: calificacion_hospital; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.calificacion_hospital (id_calificacion_hospital, id_episodio, puntuacion, comentario, fecha_hora) FROM stdin;
1	1	5	Excelente atencion en la emergencia y rapida intervencion en el quirofano personal muy atento	2026-09-03 22:30:00+00
2	3	4	Muy buena atencion del equipo de traumatologia y las enfermeras de la sala de hospitalizacion	2026-09-16 16:30:00+00
3	4	5	La doctora pediatra fue muy carinosa y explico con claridad el tratamiento para mi hija	2026-09-12 17:45:00+00
4	7	4	Buena atencion en clinica general aunque hubo que esperar unos minutos antes de pasar	2026-09-22 16:45:00+00
\.


--
-- Data for Name: calificacion_personal; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.calificacion_personal (id_calificacion_personal, id_episodio, id_personal, puntuacion, comentario, fecha_hora) FROM stdin;
1	1	2	5	Cirujano muy profesional y acertado en la apendicectomia laparoscopica	2026-09-03 22:35:00+00
2	1	15	5	Enfermera muy humana y pendiente de la recuperacion del dolor	2026-09-03 22:35:00+00
3	3	4	5	Excelente cirujano ortopedista la cirugia de pierna fue un exito	2026-09-16 16:35:00+00
4	4	5	5	Dra pediatra muy paciente y acertada con el medicamento de la nina	2026-09-12 17:50:00+00
5	5	6	5	Atencion cordial y excelente control de la presion arterial en cardiologia	2026-09-15 17:00:00+00
6	4	25	4	Amable y rapida en la asignacion de la cita y cobro en recepcion	2026-09-12 17:55:00+00
10	9	7	2	Atencion acelerada y poca explicacion del diagnostico	2026-02-01 18:00:00+00
11	21	7	1	Puntualidad deficiente y trato distante	2026-03-01 17:30:00+00
12	10	6	2	Tiempo de espera prolongado en la sala de emergencia	2026-03-11 02:30:00+00
13	13	8	2	Consulta con poca comunicacion al paciente	2026-02-15 19:15:00+00
14	17	42	2	El medico se mostro apurado durante la cita	2026-02-10 17:45:00+00
15	23	44	1	Mala atencion y explicacion confusa de recetas	2026-04-10 20:15:00+00
16	25	46	2	Atencion poco amable en clinica	2026-05-02 17:15:00+00
17	28	49	2	Retraso de casi dos horas para ingresar a consulta	2026-06-01 17:45:00+00
18	11	2	5	Excelente cirujano muy profesional y atento	2026-04-06 00:00:00+00
19	12	4	5	Cuidado de hospitalizacion impecable y humano	2026-05-16 17:15:00+00
20	15	2	5	Intervencion quirurgica sin ninguna queja	2026-04-18 22:15:00+00
21	16	5	5	Doctor muy pendiente de la evolucion	2026-06-05 20:15:00+00
22	19	41	5	Cirujano altamente calificado y puntual	2026-05-20 23:15:00+00
\.


--
-- Data for Name: cirugia; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.cirugia (id_cirugia, id_solicitud_cirugia, id_quirofano, inicio_programado, fin_programado, inicio_real, fin_real, estado, id_ingreso, condicion_evolucion) FROM stdin;
1	1	1	2026-09-01 16:00:00+00	2026-09-01 18:00:00+00	2026-09-01 16:10:00+00	2026-09-01 17:45:00+00	Finalizada	2	Sin complicaciones
2	2	2	2026-09-05 14:00:00+00	2026-09-05 16:00:00+00	2026-09-05 14:15:00+00	2026-09-05 15:40:00+00	Finalizada	3	Sin complicaciones
3	3	3	2026-09-10 22:00:00+00	2026-09-11 01:30:00+00	2026-09-10 22:15:00+00	2026-09-11 01:10:00+00	Finalizada	5	Sin complicaciones
10	10	1	2026-04-05 15:00:00+00	2026-04-05 17:00:00+00	2026-04-05 15:15:00+00	2026-04-05 16:55:00+00	Finalizada	10	Sin complicaciones
11	11	2	2026-04-18 14:30:00+00	2026-04-18 16:00:00+00	2026-04-18 14:40:00+00	2026-04-18 15:50:00+00	Finalizada	11	Sin complicaciones
12	12	15	2026-05-20 15:00:00+00	2026-05-20 17:00:00+00	2026-05-20 15:10:00+00	2026-05-20 16:45:00+00	Finalizada	15	Sin complicaciones
\.


--
-- Data for Name: cirugia_documento_fase; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.cirugia_documento_fase (id_documento, id_cirugia, fase, id_enfermero, fecha_envio_secretaria) FROM stdin;
1	1	Preoperatorio	15	2026-09-01
2	1	Intraoperatorio	15	2026-09-01
3	1	Postoperatorio	15	2026-09-01
4	2	Preoperatorio	16	2026-09-05
5	2	Intraoperatorio	16	2026-09-05
6	2	Postoperatorio	16	2026-09-05
7	3	Preoperatorio	15	2026-09-10
8	3	Intraoperatorio	15	2026-09-10
9	3	Postoperatorio	15	2026-09-10
\.


--
-- Data for Name: cirugia_equipo_medico; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.cirugia_equipo_medico (id_cirugia, id_personal, rol) FROM stdin;
1	2	Cirujano principal
1	9	Cirujano ayudante
1	3	Anestesiologo
1	15	Enfermero instrumentista
1	16	Enfermero circulante
1	20	Practicante de medicina
1	23	Practicante de enfermeria
2	14	Cirujano principal
2	1	Cirujano ayudante
2	3	Anestesiologo
2	16	Enfermero instrumentista
2	17	Enfermero circulante
3	4	Cirujano principal
3	11	Cirujano ayudante
3	3	Anestesiologo
3	15	Enfermero instrumentista
3	18	Enfermero circulante
\.


--
-- Data for Name: cirugia_verificacion; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.cirugia_verificacion (id_verificacion, id_cirugia, id_item, resultado, detalle, fecha_hora_registro, id_enfermero) FROM stdin;
1	1	1	Exito	Tabla quirurgica revisada	2026-09-01 15:50:00+00	15
2	1	2	Exito	Torre y equipos probados	2026-09-01 15:55:00+00	15
3	1	3	Exito	Paciente recibido en quirofano	2026-09-01 16:05:00+00	15
4	1	4	Exito	Brazalete verificado con DPI	2026-09-01 16:08:00+00	15
5	1	5	Exito	Consentimiento revisado	2026-09-01 16:09:00+00	15
6	1	6	Exito	Arsenal esteril confirmado	2026-09-01 16:10:00+00	15
7	1	7	Exito	Farmacos anestesicos listos	2026-09-01 16:10:00+00	15
8	1	8	Exito	Equipo quirurgico completo	2026-09-01 16:12:00+00	16
9	1	9	Exito	Traslado a mesa operatoria	2026-09-01 16:13:00+00	16
10	1	10	Exito	Posicion decubito supino	2026-09-01 16:14:00+00	16
11	1	11	Exito	Placa en muslo izquierdo	2026-09-01 16:15:00+00	16
12	1	12	Exito	Identidad confirmada en voz alta	2026-09-01 16:18:00+00	15
13	1	13	Exito	Esterilidad verificada	2026-09-01 16:19:00+00	15
14	1	14	Exito	Maquina de anestesia comprobada	2026-09-01 16:19:00+00	15
15	1	15	Exito	Cirujano explico tecnica	2026-09-01 16:20:00+00	15
16	1	16	Exito	Incision umbilical realizada	2026-09-01 16:21:00+00	15
17	1	17	Aceptable	Balance hidrico neutro	2026-09-01 17:30:00+00	16
18	1	18	Aceptable	Antibiotico profilactico administrado	2026-09-01 17:35:00+00	16
19	1	19	Aceptable	Sin necesidad de transfusion	2026-09-01 17:35:00+00	16
20	1	20	Exito	Fin de cirugia anunciado	2026-09-01 17:40:00+00	15
21	1	21	Exito	Apendicectomia completada	2026-09-01 17:42:00+00	15
22	1	22	Exito	Conteo de gasas completo 20/20	2026-09-01 17:43:00+00	15
23	1	23	Exito	Sutura de piel con Nylon	2026-09-01 17:45:00+00	15
24	1	24	Aceptable	Sin complicaciones transoperatorias	2026-09-01 17:55:00+00	15
25	1	25	Exito	Cama de recuperacion asignada	2026-09-01 17:56:00+00	15
26	1	26	Exito	Oxigeno y monitor instalados	2026-09-01 17:57:00+00	15
27	1	27	Exito	Enfermera de recuperacion a cargo	2026-09-01 17:58:00+00	15
28	1	28	Exito	Analgesia postoperatoria en perfusion	2026-09-01 17:59:00+00	15
29	1	29	Exito	Presion 115/75 pulso 76	2026-09-01 19:00:00+00	15
30	1	30	Exito	Apositos limpios y secos	2026-09-01 19:00:00+00	15
31	1	31	Exito	Expediente completo	2026-09-01 19:01:00+00	15
32	1	32	Exito	Solucion salina pasando permeable	2026-09-01 19:02:00+00	15
50	10	1	Exito	Checklist intraoperatorio verificado	2026-04-05 15:30:00+00	15
51	10	2	Exito	Instrumental completo al cierre	2026-04-05 16:45:00+00	15
52	11	1	Exito	Pausa quirurgica y conteo conforme	2026-04-18 14:50:00+00	16
53	11	2	Exito	Sin complicaciones en monitoreo anestesico	2026-04-18 15:40:00+00	16
54	12	1	Exito	Pausa de seguridad aprobada	2026-05-20 15:20:00+00	53
55	12	2	Exito	Conteo de gasas e instrumental exacto	2026-05-20 16:35:00+00	53
\.


--
-- Data for Name: cita; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.cita (id_cita, id_paciente, id_medico, id_clinica, fecha_hora, canal_asignacion, tipo_consulta, id_hospital_referente, estado, fecha_cancelacion, motivo_cancelacion, cancelacion_notificada, id_cita_anterior, id_cita_recargo_origen, creada_en) FROM stdin;
1	4	5	2	2026-09-12 15:00:00+00	Recepcion general	Primera vez	\N	Realizada	\N	\N	\N	\N	\N	2026-09-10 16:00:00+00
2	5	6	3	2026-09-15 15:30:00+00	Telefono	Reconsulta	\N	Realizada	\N	\N	\N	\N	\N	2026-09-11 17:30:00+00
3	6	7	4	2026-09-18 16:30:00+00	Correo institucional	Referido	5	Realizada	\N	\N	\N	\N	\N	2026-09-14 20:00:00+00
4	7	7	4	2026-09-19 14:30:00+00	Telefono	Primera vez	\N	Cancelada	2026-09-19 14:00:00+00	Incomparecencia del paciente sin aviso previo	f	\N	\N	2026-09-15 15:00:00+00
5	7	7	4	2026-09-22 14:30:00+00	Recepcion general	Primera vez	\N	Realizada	\N	\N	\N	4	4	2026-09-20 15:00:00+00
6	1	1	1	2026-09-28 14:30:00+00	Recepcion general	Primera vez	\N	Programada	\N	\N	\N	\N	\N	2026-09-24 16:00:00+00
10	1	7	1	2026-02-01 14:30:00+00	Recepcion general	Primera vez	\N	Realizada	\N	\N	\N	\N	\N	2026-10-26 04:43:55.744145+00
11	2	8	2	2026-02-15 16:00:00+00	Telefono	Primera vez	\N	Realizada	\N	\N	\N	\N	\N	2026-10-26 04:43:55.744145+00
12	10	7	1	2026-03-01 14:30:00+00	Telefono	Primera vez	\N	Realizada	\N	\N	\N	\N	\N	2026-10-26 04:43:55.744145+00
13	11	8	2	2026-03-15 15:00:00+00	Recepcion general	Primera vez	\N	Programada	\N	\N	\N	\N	\N	2026-10-26 04:43:55.744145+00
14	12	7	1	2026-03-20 17:00:00+00	Correo institucional	Reconsulta	\N	Cancelada	2026-03-19 20:00:00+00	Paciente no puede presentarse	t	\N	\N	2026-10-26 04:43:55.744145+00
15	9	42	3	2026-02-10 15:00:00+00	Recepcion general	Primera vez	\N	Realizada	\N	\N	\N	\N	\N	2026-10-26 04:43:55.744145+00
16	12	44	4	2026-04-10 14:00:00+00	Telefono	Primera vez	\N	Realizada	\N	\N	\N	\N	\N	2026-10-26 04:43:55.744145+00
17	13	42	3	2026-04-15 16:30:00+00	Recepcion general	Primera vez	\N	Programada	\N	\N	\N	\N	\N	2026-10-26 04:43:55.744145+00
18	13	46	5	2026-05-02 14:30:00+00	Recepcion general	Primera vez	\N	Realizada	\N	\N	\N	\N	\N	2026-10-26 04:43:55.744145+00
19	14	47	5	2026-05-10 15:00:00+00	Telefono	Primera vez	\N	Programada	\N	\N	\N	\N	\N	2026-10-26 04:43:55.744145+00
20	16	49	7	2026-06-01 15:00:00+00	Recepcion general	Primera vez	\N	Realizada	\N	\N	\N	\N	\N	2026-10-26 04:43:55.744145+00
21	17	50	7	2026-06-15 16:00:00+00	Telefono	Primera vez	\N	Programada	\N	\N	\N	\N	\N	2026-10-26 04:43:55.744145+00
\.


--
-- Data for Name: clinica; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.clinica (id_clinica, id_hospital, numero_clinica, habilitada) FROM stdin;
1	1	CLN-101	t
2	1	CLN-102	t
3	1	CLN-103	t
4	1	CLN-104	t
5	1	CLN-105	t
6	2	CLN-201	t
7	2	CLN-202	t
8	2	CLN-203	t
9	3	CLN-301	t
10	3	CLN-302	t
11	4	CLN-401	t
12	4	CLN-402	t
\.


--
-- Data for Name: consentimiento_informado; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.consentimiento_informado (id_consentimiento, id_cirugia, nombre_procedimiento, objetivo_procedimiento, caracteristicas_procedimiento, riesgos_procedimiento, id_medico, firmado_por_medico, firmante_tipo, id_paciente_encargado, firmado_por_firmante, fecha_obtencion) FROM stdin;
1	1	Apendicectomia videolaparoscopica	Extirpacion del apendice inflamado para evitar peritonitis	Abordaje mediante 3 puertos de laparoscopia bajo anestesia general	Sangrado infeccion de sitio quirurgico dano a asas intestinales	2	t	Paciente	\N	t	2026-09-01 15:40:00+00
2	2	Cesarea segmentaria transperitoneal	Nacimiento seguro de feto y extraccion de placenta	Incision transversa de Pfannenstiel e histerotomia bajo bloqueo regional	Hemorragia postparto atonia uterina infeccion de herida	14	t	Paciente	\N	t	2026-09-04 16:15:00+00
3	3	Osteosintesis de fractura de tibia	Alineacion anatomica y fijacion rigida de fragmentos oseos	Incision anteromedial en pierna reduccion y colocacion de placa LCP	No consolidacion infeccion oseomielitis lesion vasculo-nerviosa	4	t	Familiar	3	t	2026-09-10 21:40:00+00
\.


--
-- Data for Name: consulta; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.consulta (id_consulta, id_cita, id_episodio, fecha_hora, id_diagnostico, otros_datos_interes, notas_observaciones) FROM stdin;
1	1	4	2026-09-12 15:15:00+00	5	Paciente pediatrica presenta tos productiva fiebre de 2 dias y rinorrea	Se auscultan estertores crepitantes basales derechos sin cianosis
2	2	5	2026-09-15 15:40:00+00	1	Control periodico de paciente hipertenso bajo tratamiento regular	Cifras tensionales en meta terapeutica asintomatico cardiovascular
3	3	6	2026-09-18 16:45:00+00	14	Paciente remitida por epigastralgia urente de 3 meses de evolucion	Abdomen blando depresible doloroso a palpacion en epigastrio sin irritacion
4	5	7	2026-09-22 14:45:00+00	15	Dolor punzante lumbosacro desencadenado tras cargar bulto de mercaderia	Contractura paravertebral bilateral L4-S1 reflejos osteotendinosos conservados
10	10	9	2026-02-01 15:00:00+00	7	Evaluacion general rutinaria	Paciente refiere dolor abdominal leve
11	11	13	2026-02-15 16:30:00+00	1	Control cardiovascular	Hipertension arterial grado 1
12	12	21	2026-03-01 15:00:00+00	7	Evaluacion general	Paciente estable
13	15	17	2026-02-10 15:30:00+00	7	Evaluacion de primera vez	Se indican estudios complementarios
14	16	23	2026-04-10 14:30:00+00	1	Control cardiologico	Plan de seguimiento ambulatorio
15	18	25	2026-05-02 15:00:00+00	7	Chequeo ambulatorio	Paciente sin complicaciones agudas
16	20	28	2026-06-01 15:30:00+00	4	Control ginecologico	Evolucion adecuada
\.


--
-- Data for Name: consumo_insumo; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.consumo_insumo (id_consumo_insumo, id_ingreso, id_insumo, cantidad, fecha_hora, id_personal) FROM stdin;
1	2	1	4	2026-09-01 16:30:00+00	15
2	2	2	3	2026-09-01 16:35:00+00	15
3	2	3	2	2026-09-01 17:15:00+00	15
4	2	5	2	2026-09-01 16:15:00+00	16
5	3	1	4	2026-09-05 14:30:00+00	16
6	3	3	3	2026-09-05 15:15:00+00	16
7	3	6	2	2026-09-05 14:00:00+00	16
8	5	1	6	2026-09-10 22:30:00+00	15
9	5	4	3	2026-09-11 00:30:00+00	15
10	6	5	5	2026-09-11 14:00:00+00	18
11	6	7	2	2026-09-11 14:00:00+00	18
\.


--
-- Data for Name: departamento; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.departamento (id_departamento, nombre) FROM stdin;
1	Quetzaltenango
2	Totonicapan
3	San Marcos
4	Huehuetenango
5	Solola
6	Quiche
7	Suchitepequez
8	Retalhuleu
9	Chimaltenango
10	Escuintla
11	Guatemala
12	Sacatepequez
13	Alta Verapaz
14	Baja Verapaz
15	El Progreso
16	Izabal
17	Zacapa
18	Chiquimula
19	Jalapa
20	Jutiapa
21	Santa Rosa
22	Peten
\.


--
-- Data for Name: diagnostico; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.diagnostico (id_diagnostico, codigo_cie10, descripcion) FROM stdin;
1	I10	Hipertension esencial primaria
2	E11.9	Diabetes mellitus tipo 2 sin complicaciones
3	K35.8	Apendicitis aguda no especificada
4	K80.2	Calculo de la vesicula biliar sin colecistitis
5	J18.9	Neumonia no especificada
6	S82.2	Fractura de la diafisis de la tibia
7	O80.0	Parto unico espontaneo cefalico
8	K40.9	Hernia inguinal unilateral sin obstruccion
9	R10.0	Abdomen agudo
10	S06.0	Conmocion cerebral
11	J45.9	Asma no especificada
12	N39.0	Infeccion de vias urinarias sitio no especificado
13	I21.9	Infarto agudo del miocardio sin otra especificacion
14	K29.7	Gastritis no especificada
15	M54.5	Lumbago no especificado
\.


--
-- Data for Name: direccion; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.direccion (id_direccion, id_municipio, area, detalle) FROM stdin;
1	1	Urbana	Calle Rodolfo Robles 12-45 Zona 1 Quetzaltenango
2	1	Urbana	Avenida Las Americas 7-20 Zona 3 Quetzaltenango
3	11	Urbana	4a Calle 3-15 Zona 1 Totonicapan
4	16	Urbana	5a Avenida 8-30 Zona 2 San Marcos
5	33	Urbana	Calzada Roosevelt 14-25 Zona 11 Guatemala
6	33	Urbana	1a Avenida 10-50 Zona 1 Guatemala
7	20	Urbana	6a Calle 4-18 Zona 1 Huehuetenango
8	1	Urbana	Canton Choqui Sector 2 Lote 15 Quetzaltenango
9	1	Rural	Aldea San Jose Chiquilaja Sector Central Quetzaltenango
10	2	Urbana	Barrio San Jacinto 2a Avenida 4-10 Salcaja
11	4	Rural	Aldea Pasac Primero Cantel
12	5	Rural	Canton Las Flores Paraje Chitzun Almolonga
13	9	Urbana	Sector Las Rosas Lote 45 La Esperanza
14	10	Rural	Aldea Monrovia Sector Los Encuentros San Juan Ostuncalco
15	11	Urbana	Barrio Chuisuc Zona 3 Totonicapan
16	12	Rural	Canton Xecanchavox San Cristobal Totonicapan
17	13	Urbana	Barrio El Calvario 1a Calle 2-25 San Francisco El Alto
18	14	Rural	Aldea San Vicente Buenabaj Momostenango
19	17	Urbana	Canton San Sebastian 3a Avenida 5-12 San Pedro Sacatepequez
20	18	Rural	Aldea El Carmen Frontera Malacatan
21	21	Urbana	Canton Los Regadillos Chiantla
22	25	Urbana	Calle Santander 4-50 Panajachel
23	27	Urbana	Zona 2 Santa Cruz del Quiche
24	28	Rural	Canton Chupol Chichicastenango
25	29	Urbana	Colonia El Compromiso Mazatenango
26	31	Urbana	Zona 1 Retalhuleu
27	34	Urbana	Colonia San Cristobal Sector A Mixco
28	1	Urbana	Zona 3 Diagonal 2 15-40 Quetzaltenango
29	1	Urbana	Zona 5 Colonia El Maestro Quetzaltenango
30	2	Rural	Aldea Curruchique Salcaja
31	3	Rural	Canton Chuisuc Olintepeque
32	11	Rural	Paraje Chiyax Totonicapan
33	16	Urbana	Zona 1 Parque Central San Marcos
34	1	Urbana	Zona 10 Colonia Minerva Quetzaltenango
35	11	Urbana	Zona 2 Barrio La Cienega Totonicapan
\.


--
-- Data for Name: egreso; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.egreso (id_egreso, id_ingreso, fecha_hora_egreso, id_diagnostico_principal, motivo_egreso, id_medico, codigo_egreso, egreso_sin_consentimiento, motivo_sin_consentimiento, id_traslado, id_hospital_referido) FROM stdin;
1	1	2026-09-01 15:25:00+00	3	Traslado a cirugia por cuadro de apendicitis	7	Vivo	f	\N	1	\N
2	2	2026-09-03 22:00:00+00	3	Recuperacion postoperatoria exitosa de apendicectomia	2	Vivo	f	\N	\N	\N
3	3	2026-09-07 17:00:00+00	7	Puerperio quirurgico mediato sin complicaciones	14	Parto	f	\N	\N	\N
4	4	2026-09-10 21:20:00+00	6	Traslado a quirofano de traumatologia	8	Vivo	f	\N	2	\N
5	5	2026-09-11 01:50:00+00	6	Traslado a sala de hospitalizacion ortopedica	4	Vivo	f	\N	3	\N
6	6	2026-09-16 16:00:00+00	6	Consolidacion de herida y deambulacion asistida	4	Vivo	f	\N	\N	\N
7	7	2026-09-27 18:00:00+00	1	Cifras de presion arterial controladas con losartan	8	Vivo	f	\N	\N	\N
10	10	2026-03-11 02:00:00+00	1	Mejoria clinica evidente dolor controlado	6	Vivo	f	\N	\N	\N
11	11	2026-03-23 12:00:00+00	7	Inmovilizacion satisfactoria sin compromiso vascular	6	Vivo	f	\N	\N	\N
12	13	2026-05-16 17:00:00+00	1	Alta por completar ciclo de recuperacion hospitalaria	4	Vivo	f	\N	\N	\N
13	14	2026-06-05 20:00:00+00	1	Monitoreo completado sin arritmias detectadas	5	Vivo	f	\N	\N	\N
14	15	2026-03-15 14:00:00+00	7	Hidratacion adecuada euglicemico	42	Vivo	f	\N	\N	\N
15	16	2026-06-19 18:00:00+00	1	Tratamiento antibiotico concluido exitosamente	41	Vivo	f	\N	\N	\N
16	17	2026-05-19 13:00:00+00	7	Cefalea resuelta signos vitales estables	46	Vivo	f	\N	\N	\N
17	18	2026-06-15 16:00:00+00	7	Alta medica por buena evolucion	46	Vivo	f	\N	\N	\N
18	20	2026-07-10 20:00:00+00	7	Alta medica con cita de control	49	Vivo	f	\N	\N	\N
19	12	2026-08-15 22:30:00+00	1	Paro cardiorrespiratorio no refractario a maniobras	10	Muerto	f	\N	\N	\N
20	19	2026-08-16 05:45:00+00	7	Falla multiorganica aguda en choque septico	49	Muerto	f	\N	\N	\N
\.


--
-- Data for Name: egreso_diagnostico_secundario; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.egreso_diagnostico_secundario (id_egreso, id_diagnostico) FROM stdin;
2	14
3	2
6	15
\.


--
-- Data for Name: enfermero; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.enfermero (id_personal, no_licencia, grado_academico, area_asignada) FROM stdin;
15	LIC-ENF-0015	Licenciado	Quirófano
16	TEC-ENF-0016	Tecnico	Quirófano
17	LIC-ENF-0017	Licenciado	Emergencias
18	TEC-ENF-0018	Tecnico	Hospitalización
19	AUX-ENF-0019	Auxiliar	Recuperación
51	LIC-ENF-0051	Licenciado	Consulta Externa
52	TEC-ENF-0052	Tecnico	Emergencias
53	LIC-ENF-0053	Licenciado	Quirofano
54	MAG-ENF-0054	Magister	Hospitalizacion
55	LIC-ENF-0055	Licenciado	Emergencias
56	AUX-ENF-0056	Auxiliar	Consulta Externa
57	TEC-ENF-0057	Tecnico	Hospitalizacion
58	LIC-ENF-0058	Licenciado	Recuperacion
59	TEC-ENF-0059	Tecnico	Emergencias
60	AUX-ENF-0060	Auxiliar	Hospitalizacion
\.


--
-- Data for Name: episodio; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.episodio (id_episodio, id_paciente, id_hospital, fecha_apertura, fecha_cierre) FROM stdin;
1	1	1	2026-09-01 14:00:00+00	2026-09-03 22:00:00+00
2	2	1	2026-09-05 12:30:00+00	2026-09-07 17:00:00+00
3	3	1	2026-09-10 20:15:00+00	2026-09-16 16:00:00+00
4	4	1	2026-09-12 14:30:00+00	2026-09-12 17:30:00+00
5	5	1	2026-09-15 15:00:00+00	2026-09-15 16:45:00+00
6	6	1	2026-09-18 16:00:00+00	2026-09-18 18:00:00+00
7	7	1	2026-09-22 14:00:00+00	2026-09-22 16:30:00+00
8	8	1	2026-09-26 00:00:00+00	2026-09-27 18:00:00+00
9	1	1	2026-02-01 14:00:00+00	2026-02-01 18:00:00+00
10	1	1	2026-03-10 20:30:00+00	2026-03-11 02:00:00+00
11	1	1	2026-04-05 13:00:00+00	2026-04-06 00:00:00+00
12	1	1	2026-05-12 15:00:00+00	2026-05-16 17:00:00+00
13	2	1	2026-02-15 15:30:00+00	2026-02-15 19:00:00+00
14	2	1	2026-03-23 00:00:00+00	2026-03-23 12:00:00+00
15	2	1	2026-04-18 12:30:00+00	2026-04-18 22:00:00+00
16	2	1	2026-06-01 16:00:00+00	2026-06-05 20:00:00+00
17	9	2	2026-02-10 14:30:00+00	2026-02-10 17:30:00+00
18	9	2	2026-03-15 03:00:00+00	2026-03-15 14:00:00+00
19	9	2	2026-05-20 13:00:00+00	2026-05-20 23:00:00+00
20	9	2	2026-06-15 17:00:00+00	2026-06-19 18:00:00+00
21	10	1	2026-03-01 14:00:00+00	2026-03-01 17:00:00+00
22	11	1	2026-03-06 01:00:00+00	2026-03-06 08:00:00+00
23	12	2	2026-04-10 13:30:00+00	2026-04-10 20:00:00+00
24	12	2	2026-04-25 14:00:00+00	2026-04-25 18:00:00+00
25	13	3	2026-05-02 14:00:00+00	2026-05-02 17:00:00+00
26	14	3	2026-05-19 02:00:00+00	2026-05-19 13:00:00+00
27	15	3	2026-06-10 15:00:00+00	2026-06-15 16:00:00+00
28	16	4	2026-06-01 14:30:00+00	2026-06-01 17:30:00+00
29	17	4	2026-06-21 04:00:00+00	2026-06-21 12:00:00+00
30	18	4	2026-07-05 16:00:00+00	2026-07-10 20:00:00+00
\.


--
-- Data for Name: equipo; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.equipo (id_equipo, nombre, descripcion, tipo, funcion) FROM stdin;
1	Maquina de anestesia con monitor integrado	Estacion de trabajo de anestesia con ventilador	Quirurgico	Tratamiento
2	Monitor de signos vitales multiparametrico	Monitor continuo de ECG, SpO2, PNI, temperatura	Medico	Diagnostico
3	Unidad electroquirurgica bipolar monopolar	Generador electroquirurgico con coagulacion de precision	Quirurgico	Tratamiento
4	Torre de videolaparoscopia quirurgica HD	Camara HD, fuente de luz LED e insuflador CO2	Quirurgico	Exploracion
5	Desfibrilador bifasico con marcapasos	Monitor desfibrilador de reanimacion avanzada	Medico	Tratamiento
6	Lampara quirurgica de techo de luz LED	Lampara scialitica de doble satelite quirurgico	Quirurgico	Exploracion
7	Bomba de infusion continua volumetrica	Bomba electronica precisa para administracion de farmacos	Medico	Tratamiento
8	Arco en C radiologico quirurgico	Fluoroscopio digital portatil para cirugia ortopedica	Quirurgico	Diagnostico
9	Ventilador mecanico invasivo de intensivo	Respirador volumetrico para soporte respiratorio critico	Medico	Tratamiento
10	Electrocardiografo digital de 12 derivadas	Equipo portatil de registro cardiologico digital	Medico	Diagnostico
11	Ultrasonografo doppler color portatil	Equipo ultrasonico de exploracion hepatica y vascular	Medico	Diagnostico
\.


--
-- Data for Name: espacio_atencion; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.espacio_atencion (id_espacio, id_unidad_hospital, tipo, codigo, habilitado) FROM stdin;
1	3	Quirofano	QX-01-XELA	t
2	3	Quirofano	QX-02-XELA	t
3	3	Quirofano	QX-03-XELA	t
4	3	Quirofano	QX-04-XELA	t
5	2	Camilla	CAM-EM-101	t
6	2	Camilla	CAM-EM-102	t
7	2	Camilla	CAM-EM-103	t
8	2	Camilla	CAM-EM-104	t
9	2	Camilla	CAM-EM-105	t
10	4	Camilla	CAM-HOSP-201	t
11	4	Camilla	CAM-HOSP-202	t
12	4	Camilla	CAM-HOSP-203	t
13	4	Camilla	CAM-HOSP-204	t
14	4	Camilla	CAM-HOSP-205	t
15	7	Quirofano	QX-01-SJD	t
16	7	Quirofano	QX-02-SJD	t
17	7	Quirofano	QX-03-SJD	t
18	7	Quirofano	QX-04-SJD	t
19	6	Camilla	CAM-EM-201	t
20	6	Camilla	CAM-EM-202	t
21	6	Camilla	CAM-EM-203	t
22	11	Quirofano	QX-01-TOTO	t
23	11	Quirofano	QX-02-TOTO	t
24	11	Quirofano	QX-03-TOTO	t
25	12	Camilla	CAM-HOSP-301	t
26	12	Camilla	CAM-HOSP-302	t
27	12	Camilla	CAM-HOSP-303	t
\.


--
-- Data for Name: especialidad; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.especialidad (id_especialidad, nombre, tipo) FROM stdin;
1	Cardiologia	Clinica
2	Dermatologia	Clinica
3	Fisioterapia	Clinica
4	Ginecologia Oncologica	Clinica
5	Hematologia	Clinica
6	Medicina Fisica y Rehabilitacion	Clinica
7	Medicina General	Clinica
8	Nutricion y Dietetica	Clinica
9	Odontologia General	Clinica
10	Oftalmologia	Clinica
11	Psicologia	Clinica
12	Pediatria	Clinica
13	Urologia	Clinica
14	Terapia del Lenguaje	Clinica
15	Cirugia Cardiovascular (Adulto y Pediatrica)	Quirurgica
16	Cirugia de la Mano	Quirurgica
17	Cirugia General	Quirurgica
18	Videolaparoscopia Quirurgica	Quirurgica
19	Cirugia Ginecologica	Quirurgica
20	Cirugia Neurologica	Quirurgica
21	Cirugia Oftalmologica	Quirurgica
22	Cirugia Oncologica	Quirurgica
23	Cirugia Ortopedica	Quirurgica
24	Cirugia Otorrinolaringologica	Quirurgica
25	Cirugia Pediatrica	Quirurgica
26	Cirugia Plastica	Quirurgica
27	Cirugia de Torax	Quirurgica
28	Cirugia Urologica	Quirurgica
29	Medicina Interna	Clinica
30	Neumologia	Clinica
31	Neurologia	Clinica
32	Oncologia	Clinica
33	Ortopedia	Clinica
34	Anestesiologia	Quirurgica
\.


--
-- Data for Name: evaluacion_preanestesica; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.evaluacion_preanestesica (id_evaluacion, id_cirugia, clasificacion_asa, id_medico_clasifica, firmado_medico_clasifica, plan_anestesia, id_anestesiologo, fecha_hora) FROM stdin;
1	1	2	2	t	Induccion intravenosa con fentanilo propofol intubacion orotraqueal y mantenimiento inhalatorio	3	2026-09-01 15:45:00+00
2	2	1	14	t	Anestesia subaracnoidea con bupivacaina pesada 0.5% mas fentanilo a nivel L3-L4	3	2026-09-04 16:30:00+00
3	3	2	4	t	Bloqueo neuroaxial raquideo con bupivacaina e isquemia controlada en muslo derecho	3	2026-09-10 21:45:00+00
\.


--
-- Data for Name: examen_laboratorio; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.examen_laboratorio (id_examen, nombre) FROM stdin;
1	Hematologia completa
2	Quimica sanguinea 6 elementos
3	Tiempos de coagulacion TP y TTP
4	Examen general de orina
5	Perfil lipidico completo
6	Pruebas de funcion hepatica
7	Electrolitos sericos
8	Gasometria arterial
9	Prueba de embarazo hCG cualitativa
10	Grupo sanguineo y factor Rh
11	Coprocultivo
12	Urocultivo con antibiograma
\.


--
-- Data for Name: factura; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.factura (id_factura, serie, numero_factura, id_episodio, fecha_emision, nit_cliente, nombre_cliente, descripcion, numero_cuotas, id_personal_emite, estado) FROM stdin;
1	A	FAC-0001	4	2026-09-12 17:15:00+00	CF	Sofia Elizabeth Cux Morales	Servicios ambulatorios de consulta pediatrica y emision de receta	1	25	Emitida
2	A	FAC-0002	5	2026-09-15 16:30:00+00	45879632	Pedro Francisco Pop Chan	Reconsulta de especialidad en cardiologia con tarifa preferencial	1	25	Emitida
3	A	FAC-0003	7	2026-09-22 16:15:00+00	CF	Mario Rene Gomez Vasquez	Consulta de medicina general con recargo por cita anterior no avisada	1	25	Emitida
4	A	FAC-0004	1	2026-09-03 21:30:00+00	78965412	Jose Miguel Yax Ixcoy	Atencion de urgencia intervencion videolaparoscopica y estancia en sala	6	27	Emitida
5	A	FAC-0005	3	2026-09-16 15:30:00+00	12589634	Juan Carlos Chaj Tzun	Atencion politraumatizado cirugia ortopedica mayor y hospitalizacion prolongada	12	26	Emitida
10	A	FAC-2026-010	9	2026-02-01 17:30:00+00	CF	Josue Cifuentes	Atencion de consulta externa general	1	25	Emitida
11	A	FAC-2026-011	10	2026-03-11 01:30:00+00	CF	Josue Cifuentes	Atencion de urgencia y estabilizacion	3	25	Emitida
12	A	FAC-2026-012	11	2026-04-05 23:30:00+00	CF	Josue Cifuentes	Procedimiento quirurgico y quirofano	6	25	Emitida
13	A	FAC-2026-013	12	2026-05-16 16:30:00+00	CF	Josue Cifuentes	Hospitalizacion por 4 dias	4	25	Emitida
14	A	FAC-2026-014	13	2026-02-15 18:30:00+00	CF	Miriam Morales	Atencion consulta especializada	1	25	Emitida
15	A	FAC-2026-015	14	2026-03-23 11:30:00+00	CF	Miriam Morales	Manejo de emergencia traumatologica	2	25	Emitida
16	A	FAC-2026-016	15	2026-04-18 21:30:00+00	CF	Miriam Morales	Intervencion quirurgica programada	5	25	Emitida
17	A	FAC-2026-017	16	2026-06-05 19:30:00+00	CF	Miriam Morales	Internamiento hospitalario 5 dias	6	25	Emitida
18	A	FAC-2026-018	17	2026-02-10 17:00:00+00	CF	Cesar Gomez	Consulta ambulatoria Hospital 2	1	26	Emitida
19	A	FAC-2026-019	18	2026-03-15 13:30:00+00	CF	Cesar Gomez	Atencion de emergencia en Hospital 2	2	26	Emitida
20	A	FAC-2026-020	19	2026-05-20 22:30:00+00	CF	Cesar Gomez	Acto quirurgico en Hospital 2	6	26	Emitida
21	A	FAC-2026-021	20	2026-06-19 17:30:00+00	CF	Cesar Gomez	Servicio de hospitalizacion Hospital 2	4	26	Emitida
22	A	FAC-2026-022	25	2026-05-02 16:30:00+00	CF	Ramiro Ixcoy	Consulta externa Hospital 3	1	27	Emitida
23	A	FAC-2026-023	27	2026-06-15 15:30:00+00	CF	Ingrid Quiej	Hospitalizacion Hospital 3	3	27	Emitida
24	A	FAC-2026-024	28	2026-06-01 17:00:00+00	CF	Hector Yax	Consulta externa Hospital 4	1	27	Emitida
25	A	FAC-2026-025	30	2026-07-10 19:30:00+00	CF	Debora Chuc	Hospitalizacion Hospital 4	4	27	Emitida
\.


--
-- Data for Name: factura_detalle; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.factura_detalle (id_factura_detalle, id_factura, concepto, descripcion, cantidad, precio_unitario, porcentaje_aplicado, id_consulta, id_ingreso, id_cirugia) FROM stdin;
1	1	Consulta	Consulta medica pediatrica primera vez	1.00	200.00	100.00	1	\N	\N
2	2	Consulta	Reconsulta especializada de cardiologia	1.00	350.00	75.00	2	\N	\N
3	3	Consulta	Consulta de medicina general con recargo del 10%	1.00	150.00	110.00	4	\N	\N
4	4	Cirugia	Procedimiento apendicectomia videolaparoscopica	1.00	4500.00	100.00	\N	\N	1
5	4	Emergencia	Atencion de estabilizacion y observacion inicial	1.00	250.00	100.00	\N	1	\N
6	4	Dias de internamiento	Estancia quirurgica postoperatoria (2 dias)	2.00	450.00	100.00	\N	2	\N
7	4	Insumos	Paquete de insumos quirurgicos y suturas	1.00	435.00	100.00	\N	\N	\N
8	5	Cirugia	Procedimiento osteosintesis de fractura de tibia	1.00	6500.00	100.00	\N	\N	3
9	5	Emergencia	Atencion de paciente politraumatizado	1.00	600.00	100.00	\N	4	\N
10	5	Dias de internamiento	Dias de internamiento ortopedia (6 dias)	6.00	350.00	100.00	\N	6	\N
11	5	Insumos	Material descartable ferulas y sueros de internamiento	1.00	650.00	100.00	\N	\N	\N
12	12	Cirugia	Honorarios quirurgicos cirujano y quirofano	1.00	4500.00	100.00	\N	\N	10
13	13	Hospitalizacion	Estancia en cama hospitalaria por 4 dias	4.00	600.00	100.00	\N	13	\N
14	14	Consulta	Consulta medica de seguimiento	1.00	300.00	100.00	11	\N	\N
15	15	Emergencia	Emergencia y sutura menor	1.00	750.00	100.00	\N	11	\N
16	16	Cirugia	Intervencion quirurgica programada	1.00	5200.00	100.00	\N	\N	11
17	17	Hospitalizacion	Internamiento hospitalario por 5 dias	5.00	600.00	100.00	\N	14	\N
18	18	Consulta	Consulta externa facultativa	1.00	275.00	100.00	13	\N	\N
19	19	Emergencia	Atencion de urgencia y medicamentos	1.00	900.00	100.00	\N	15	\N
20	20	Cirugia	Procedimiento quirurgico Hospital 2	1.00	4800.00	100.00	\N	\N	12
21	21	Hospitalizacion	Estancia en sala de hospitalizacion 4 dias	4.00	550.00	100.00	\N	16	\N
22	22	Consulta	Consulta medica Hospital 3	1.00	200.00	100.00	15	\N	\N
23	23	Hospitalizacion	Estancia hospitalaria Hospital 3 por 5 dias	5.00	500.00	100.00	\N	18	\N
24	24	Consulta	Consulta medica Hospital 4	1.00	200.00	100.00	16	\N	\N
25	25	Hospitalizacion	Estancia hospitalaria Hospital 4 por 5 dias	5.00	500.00	100.00	\N	20	\N
\.


--
-- Data for Name: historia_clinica; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.historia_clinica (id_historia_clinica, id_episodio, id_medico, fecha_hora, tipo_interrogatorio, informante, antecedentes_heredofamiliares, antecedentes_personales_no_patologicos, antecedentes_patologicos, padecimiento_actual, interrogatorio_aparatos_sistemas, sintomas_generales_terapeutica, estudios_previos, id_signos_vitales, exploracion_general, explo_cabeza, explo_cuello, explo_torax, explo_abdomen, explo_extremidades, explo_columna_vertebral, explo_cavidad_bucal, explo_cavidad_vaginal, explo_cavidad_rectal, explo_conducto_auditivo_externo) FROM stdin;
1	1	1	2026-09-01 14:30:00+00	Directo	\N	Madre hipertensa padre con diabetes tipo 2	Vivienda formal con todos los servicios basicos dieta balanceada	Niega cirugias previas o alergias medicamentosas	Inicia hace 18 horas con dolor periumbilical que migro a fosa iliaca derecha con vomito	Aparato digestivo con nauseas y anorexia aparato respiratorio sin sintomas	Fiebre no cuantificada automedico analgesico comun sin mejoria	Ultrasonido abdominal con imagen en diana compatible con apendicitis	1	Paciente agudo facies dolorosa posicion antalgica cooperador	Normocefalo pupilas isocoricas reactivas escleras limpias	Movil simetrico no adenopatias ni ingurgitacion yugular	Campos pulmonares ventilados ruidos cardiacos ritmicos sin soplos	Dolor intenso a palpacion en punto de McBurney signo de Blumberg positivo defensa muscular	Tono y fuerza conservados pulsos perifericos presentes simetricos	Sin alteraciones posturales palpacion espinosa no dolorosa	Mucosa oral deshidratada piezas dentales completas	\N	Tono de esfinter anal conservado ampolla vacia dolor a palpacion anterior	Conductos auditivos permeables membranas timpanicas integras
2	2	14	2026-09-04 15:00:00+00	Directo	\N	Sin antecedentes familiares de importancia	Alimentacion adecuada vivienda con saneamiento basico	Gesta 2 Para 1 Cesarea 0 sin alergias	Embarazo de 39 semanas de gestacion acude para resolucion electiva	Movimientos fetales activos niega perdidas transvaginales	Asintomatica toma vitaminas prenatales y hierro	Monitoreo fetal reactivo y biometria ecografica con peso fetal de 3900 g	3	Paciente femenina orientada normohidratada en reposo confortable	Facies no caracteristica mucosas humedas	Cuello simetrico tiroides no palpable	Torax simetrico murmullo vesicular conservado	Abdomen globoso por utero gravido altura uterina 36 cm feto unico cefalico FCF 142 lpm	Extremidades con edema leve maleolar bilateral pulsos presentes	Columna con lordosis fisiologica gestacional conservada	Cavidad oral en buen estado higiene adecuada	Cuello posterior cerrado formado no sangrado ni liquido	No evaluado diferido	Pabellones auriculares bien implantados conductos libres
3	3	4	2026-09-10 20:45:00+00	Indirecto	Juana Maria Tzun Batres (Madre)	Padre fallecido por enfermedad cardiaca madre aparentemente sana	Trabajador de comercio viaja frecuentemente en motocicleta	Niega antecedentes medicos cronicos refiere fractura de clavicula en la infancia	Sufre colision en motocicleta contra vehiculo hace 1 hora presentando dolor intenso y deformidad	Perdida de fuerza funcional en extremidad inferior derecha no perdida de conciencia	Administraron analgesico en ambulancia de bomberos	Radiografia de pierna derecha muestra fractura diafisiaria de tibia conminuta cerrada	4	Paciente quejumbroso inmovilizado con ferula posterior algico pero reactivo	Craneo sin heridas evidentes no hematomas epicraneales	Cuello con collarin blando alineado sin crepitacion	Torax con buena expansion auscultacion simetrica	Abdomen plano blando no doloroso ruidos hidroaereos presentes	Extremidad inferior derecha con deformidad en tercio medio de tibia edema severo pulsos distales presentes	Eje vertebral alineado sin dolor a palpacion superficial	Dentadura integra sin cuerpos extranos	\N	No evaluado	Conductos auditivos sin otorragia
4	5	12	2026-09-16 16:00:00+00	Directo	\N	Padre fallecido por infarto agudo al miocardio a los 55 anos	Tabaquismo suspendido hace 5 anos sedentario	Hipertension arterial de 15 anos de evolucion	Disnea de medianos esfuerzos y dolor precordial opresivo ocasional	Aparato cardiovascular con palpitaciones gastrointestinal sin cambios	En tratamiento con Losartan y Aspirina	Electrocardiograma con cambios isquemicos anterolaterales	7	Paciente masculino en decubito supino consciente y orientado	Sin alteraciones morfologicas	Pulso carotideo amplio simetrico	Ruidos cardiacos apagados ritmo de galope ocasional	Abdomen globoso blando no doloroso	Extremidades con edema maleolar grado I	Columna dorsal sin desviaciones	Mucosa semihumeda	\N	No evaluado	Normoyentes
10	11	2	2026-04-05 13:30:00+00	Directo	\N	\N	\N	\N	Paciente evaluado para intervencion quirurgica programada	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
11	15	2	2026-04-18 13:00:00+00	Directo	\N	\N	\N	\N	Cuadro clinico estable para resolucion quirurgica electiva	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
12	19	41	2026-05-20 13:30:00+00	Directo	\N	\N	\N	\N	Evaluacion preoperatoria completa para procedimiento	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: horario_medico; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.horario_medico (id_horario, id_medico, id_clinica, dia_semana, hora_inicio, hora_fin) FROM stdin;
1	1	1	1	08:00:00	12:00:00
2	1	1	3	08:00:00	12:00:00
3	5	2	1	07:00:00	12:00:00
4	5	2	2	07:00:00	12:00:00
5	5	2	3	07:00:00	12:00:00
6	5	2	4	07:00:00	12:00:00
7	5	2	5	07:00:00	12:00:00
8	6	3	2	08:00:00	12:30:00
9	6	3	4	08:00:00	12:30:00
10	7	4	1	07:00:00	12:00:00
11	7	4	2	07:00:00	12:00:00
12	7	4	3	07:00:00	12:00:00
13	7	4	4	07:00:00	12:00:00
14	7	4	5	07:00:00	12:00:00
\.


--
-- Data for Name: hospital; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.hospital (id_hospital, codigo, nombre, id_direccion, telefono, correo, es_interno, activo) FROM stdin;
1	HOC-01	Hospital Central de Occidente Los Altos	1	77612000	info.xela@hospitalesoccidente.gt	t	t
2	HOC-02	Hospital Regional San Juan de Occidente	2	77654000	sanjuan.xela@hospitalesoccidente.gt	t	t
3	HOC-03	Hospital Departamental de Totonicapan Atanasio Tzul	3	77661000	totonicapan@hospitalesoccidente.gt	t	t
4	HOC-04	Hospital Regional de San Marcos La Union	4	77603000	sanmarcos@hospitalesoccidente.gt	t	t
5	EXT-01	Centro Medico Militar de Guatemala	5	23341000	referencias@cmmilitar.gob.gt	f	t
6	EXT-02	Hospital General San Juan de Dios Capital	6	22510000	direccion@hgsjd.gob.gt	f	t
7	EXT-03	Hospital Regional de Huehuetenango Doctor Jorge Vides	7	77642000	direccion@hrhuehue.gob.gt	f	t
\.


--
-- Data for Name: ingreso; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.ingreso (id_ingreso, id_episodio, id_unidad_hospital, id_servicio, fecha_hora_ingreso, motivo_ingreso, id_diagnostico_presuntivo, id_medico, id_espacio, id_paciente_encargado, estado_actual_paciente, prioridad_triage, dias_estimados_estancia) FROM stdin;
1	1	2	19	2026-09-01 14:10:00+00	Dolor abdominal agudo intenso en fosa iliaca derecha con fiebre y nauseas	9	7	5	1	Paciente agudo quejumbroso febril con abdomen en tabla	2	1
2	1	3	22	2026-09-01 15:30:00+00	Apendicitis aguda confirmada para intervencion videolaparoscopica urgente	3	2	1	1	Estable preparado en ayuno preoperatorio inmediato	1	2
3	2	3	24	2026-09-05 12:40:00+00	Embarazo a termino para cesarea electiva programada por macrosomia	7	14	2	2	Gestante en buen estado general con ayuno adecuado	3	2
4	3	2	17	2026-09-10 20:20:00+00	Accidente en motocicleta con deformidad y dolor en pierna derecha	6	8	6	3	Politraumatizado consciente con dolor severo e inmovilizacion	1	1
5	3	3	23	2026-09-10 21:30:00+00	Fractura diafisiaria de tibia derecha desplazada para osteosintesis	6	4	3	3	Inmovilizado con ferula y analgesia parenteral	2	5
6	3	4	32	2026-09-11 02:00:00+00	Recuperacion postoperatoria de osteosintesis tibial y terapia antibiotica	6	4	10	3	Evolucion favorable afebril con herida limpia	3	5
7	8	2	16	2026-09-26 00:10:00+00	Cefalea intensa mareo y cifras tensionales elevadas de 175/105	1	8	7	\N	Paciente con urgencia hipertensiva sin dano agudo a organo blanco	2	2
10	10	2	2	2026-03-10 20:30:00+00	Dolor precordial agudo de inicio subito	1	6	5	1	Paciente consciente orientado con dolor toracico	2	1
11	14	2	2	2026-03-23 00:00:00+00	Trauma en miembro inferior por caida	7	6	6	2	Dolor intenso con limitacion funcional	3	1
12	22	2	2	2026-03-06 01:00:00+00	Dificultad respiratoria moderada	7	10	7	3	Taquipneico en observacion de emergencia	2	1
13	12	4	4	2026-05-12 15:00:00+00	Ingreso para manejo postquirurgico y recuperacion	1	4	10	1	Estable afebril tolerando via oral	4	4
14	16	4	4	2026-06-01 16:00:00+00	Ingreso para monitoreo cardiovascular continuo	1	5	11	2	Hemodinamicamente estable en cama asignada	4	5
15	18	6	6	2026-03-15 03:00:00+00	Sindrome febril agudo y deshidratacion	7	42	19	1	Febril deshidratado en sala de choque	2	1
16	20	8	8	2026-06-15 17:00:00+00	Internamiento para tratamiento intravenoso	1	41	12	1	Evolucion favorable con tratamiento	4	4
17	26	10	10	2026-05-19 02:00:00+00	Cefalea intensa refractaria a analgesicos	7	46	20	1	Paciente orientado en camilla de observacion	3	1
18	27	12	12	2026-06-10 15:00:00+00	Internamiento para observacion medica	7	46	25	1	Estable bajo cuidado de enfermeria	4	5
19	29	14	14	2026-06-21 04:00:00+00	Dolor abdominal severo en fosa iliaca	7	49	21	1	En evaluacion diagnostica	2	1
20	30	16	16	2026-07-05 16:00:00+00	Recuperacion medica de proceso infeccioso	7	49	26	1	Mejoria clinica notable	4	5
\.


--
-- Data for Name: instrumento; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.instrumento (id_instrumento, nombre, descripcion, tipo, funcion) FROM stdin;
1	Mango de bisturi numero 3	Mango anatomico para hojas de bisturi pequenas	Quirurgico	Corte
2	Tijera de Metzenbaum curva 18 cm	Tijera fina para diseccion delicada de tejidos	Quirurgico	Corte
3	Tijera de Mayo recta 17 cm	Tijera robusta para corte de suturas y material	Quirurgico	Corte
4	Pinza de diseccion con dientes	Pinza de prension con dientes de raton 1x2	Quirurgico	Contenido
5	Pinza de diseccion sin dientes	Pinza atraumatica de tejido vascular y serosas	Quirurgico	Contenido
6	Pinza hemostatica Kelly curva	Pinza para oclusion vascular hemostatica	Quirurgico	Hemostatica
7	Pinza de Pean hemostatica grande	Pinza de hemostasia fuerte para pediculos gruesos	Quirurgico	Hemostatica
8	Separador de Farabeuf par	Separadores manuales de planos superficiales	Quirurgico	Retractor
9	Separador de Deaver mediano	Separador valva profunda abdominal y pelvica	Quirurgico	Retractor
10	Portaagujas de Mayo-Hegar 16 cm	Instrumento con bocas de tungsteno para suturar	Quirurgico	Accesorio
11	Canula de succion Yankauer	Tubo curvo rigido para aspiracion quirurgica	Quirurgico	Accesorio
12	Malla de polipropileno monofilamento	Protesis quirurgica de refuerzo tisular	Quirurgico	Implante
\.


--
-- Data for Name: insumo; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.insumo (id_insumo, nombre, descripcion, material, tipo) FROM stdin;
1	Guantes esteriles de latex quirurgicos	Par de guantes esteriles desechables numero 7.5	Latex natural	Quirurgico
2	Gasas esteriles radiopacas 10x10 cm	Paquete de 10 gasas con cinta detectable por rayos X	Algodon hidrofilo	Quirurgico
3	Sutura Vicryl 2-0 con aguja curva	Sutura absorbible sintetica trenzada de 70 cm	Poliglactina 910	Quirurgico
4	Sutura Nylon 3-0 con aguja cortante	Sutura monofilamento no absorbible para piel	Poliamida	Quirurgico
5	Solucion Salina 0.9% 1000 ml	Solucion fisiologica esteril para perfusion intravenosa	Cloruro de sodio en agua	Medico
6	Solucion Hartman 1000 ml	Solucion polielectrolitica balanceada para reposicion	Lactato de Ringer	Medico
7	Cateter intravenoso calibre 18G	Cateter periferico sobre aguja con aletas	Poliuretano biocompatible	Medico
8	Equipo de venoclisis normogotero	Linea de infusion con camara de goteo y filtro	Plastico grado medico	Medico
9	Sonda Foley calibre 16 Fr	Sonda vesical de dos vias con balon de retencion	Silicona transparente	Quirurgico
10	Bolsa recolectora de orina 2000 ml	Bolsa graduada con valvula antirreflujo	Polietileno resistente	Medico
11	Venda elastica 6 pulgadas	Venda de compresion elastica con ganchos de sujecion	Algodon y elastano	Medico
12	Hoja de bisturi numero 15	Hoja cortante quirurgica esteril desechable	Acero al carbono	Quirurgico
13	Mascarilla quirurgica triple capa	Mascarilla facial con ajuste nasal y elastico	Tela no tejida polipropileno	Medico
14	Tubo endotraqueal con balon 7.5 mm	Tubo traqueal con manguito de baja presion	PVC siliconado	Quirurgico
15	Esparadrapo microporoso 2 pulgadas	Cinta adhesiva hipoalergenica de tela transpirable	Papel poroso adhesivo	Medico
\.


--
-- Data for Name: item_verificacion; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.item_verificacion (id_item, id_momento, descripcion, tipo_resultado, orden) FROM stdin;
1	1	Disponibilidad de tabla quirurgica confirmada	Exito o fallo	1
2	1	Preparacion de equipos y quirofano previo al ingreso	Exito o fallo	2
3	1	Recepcion y acogida de paciente en el quirofano	Exito o fallo	3
4	2	Brazalete de identificacion del paciente confirmado	Exito o fallo	1
5	2	Ficha clinica con consentimientos y preanestesica en regla	Exito o fallo	2
6	2	Confirmacion de arsenal instrumental y esteril operativo	Exito o fallo	3
7	2	Disponibilidad de farmacos y tecnica anestesica comprobada	Exito o fallo	4
8	3	Presencia completa del equipo quirurgico en sala	Exito o fallo	1
9	3	Traslado correcto de camilla a mesa quirurgica	Exito o fallo	2
10	3	Posicionamiento ergonomico correcto en mesa operatoria	Exito o fallo	3
11	3	Placa neutra de electrobisturi instalada correctamente	Exito o fallo	4
12	4	Confirmacion verbal de identidad del paciente	Exito o fallo	1
13	4	Confirmacion de condiciones de esterilidad y campo	Exito o fallo	2
14	4	Revision de maquina de anestesia y via aerea permeable	Exito o fallo	3
15	4	Cirujano indica plan quirurgico y pasos criticos	Exito o fallo	4
16	4	Incision quirurgica autorizada formalmente	Exito o fallo	5
17	5	Registro y control de balance hidrico estricto	Aceptabilidad	1
18	5	Seguridad en administracion de medicamentos protocolizados	Aceptabilidad	2
19	5	Registro y monitoreo de transfusion de sangre	Aceptabilidad	3
20	6	Cirujano anuncia formalmente el fin de procedimientos	Exito o fallo	1
21	6	Confirmacion de procedimiento quirurgico realizado	Exito o fallo	2
22	6	Conteo de gasas, compresas e instrumental satisfactorio	Exito o fallo	3
23	6	Cierre correcto de incision quirurgica sin fugas	Exito o fallo	4
24	7	Condiciones de evolucion durante la cirugia	Aceptabilidad	1
25	7	Confirmacion de cama post anestesica adecuada	Exito o fallo	2
26	7	Gases clinicos, monitores y electrodos operativos	Exito o fallo	3
27	7	Disposicion de personal de enfermeria asignado	Exito o fallo	4
28	7	Medicamentos disponibles y portasueros colocados	Exito o fallo	5
29	8	Signos vitales dentro de limites fisiologicos normales	Exito o fallo	1
30	8	Zona operatoria limpia con aposito esteril integro	Exito o fallo	2
31	8	Documentacion clinica completa y boleta de traslado	Exito o fallo	3
32	8	Sueros de mantencion y venoclisis pasando correctamente	Exito o fallo	4
\.


--
-- Data for Name: medicamento; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.medicamento (id_medicamento, nombre, presentacion) FROM stdin;
1	Amoxicilina + Acido Clavulanico	Tabletas 500/125 mg
2	Paracetamol	Tabletas 500 mg
3	Ibuprofeno	Capsulas 400 mg
4	Losartan Potasico	Tabletas 50 mg
5	Metformina Clorhidrato	Tabletas 850 mg
6	Ceftriaxona	Frasco ampolla 1 g
7	Omeprazol	Capsulas 20 mg
8	Ciprofloxacina	Tabletas 500 mg
9	Diclofenaco Sodico	Ampolla 75 mg/3 ml
10	Salbutamol	Inhalador 100 mcg/dosis
11	Enoxaparina Sodica	Jeringa prellenada 40 mg
12	Fentanilo	Ampolla 0.5 mg/10 ml
13	Propofol	Ampolla 200 mg/20 ml
14	Ketorolaco	Ampolla 30 mg
15	Tramadol Clorhidrato	Ampolla 100 mg
\.


--
-- Data for Name: medico; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.medico (id_personal, no_colegiado, condicion, institucion_origen, tarifa_consulta, id_superior, nivel_acceso) FROM stdin;
1	COL-12450	Planta	\N	250.00	\N	Director Medico
3	COL-14100	Planta	\N	275.00	1	Jefe de Servicio
4	COL-11850	Planta	\N	300.00	2	Jefe de Guardia
5	COL-15600	Planta	\N	200.00	2	Jefe de Guardia
6	COL-16200	Planta	\N	350.00	3	Jefe de Guardia
7	COL-17400	Planta	\N	150.00	4	Medico Asistencial
8	COL-18100	Planta	\N	150.00	4	Medico Asistencial
9	COL-20150	Residente	\N	120.00	5	Medico Asistencial
10	COL-20890	Residente	\N	120.00	6	Medico Asistencial
11	COL-22400	Interno	\N	100.00	\N	Director Medico
12	COL-09850	Externo	Centro Medico Militar de Guatemala	500.00	11	Jefe de Servicio
41	COL-17100	Planta	\N	300.00	11	Jefe de Servicio
42	COL-18250	Planta	\N	275.00	12	Jefe de Guardia
43	COL-19300	Planta	\N	250.00	41	Jefe de Guardia
44	COL-20400	Residente	\N	200.00	42	Medico Asistencial
45	COL-21500	Residente	\N	200.00	43	Medico Asistencial
13	COL-08940	Externo	Hospital General San Juan de Dios Capital	600.00	\N	Director Medico
14	COL-14880	Planta	\N	350.00	13	Jefe de Servicio
46	COL-18900	Planta	\N	275.00	14	Jefe de Guardia
47	COL-22100	Residente	\N	200.00	46	Medico Asistencial
48	COL-10500	Planta	\N	350.00	\N	Director Medico
49	COL-16800	Planta	\N	300.00	48	Jefe de Servicio
50	COL-23200	Residente	\N	200.00	49	Medico Asistencial
2	COL-13200	Planta	\N	300.00	1	Jefe de Servicio
\.


--
-- Data for Name: medico_especialidad; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.medico_especialidad (id_medico, id_especialidad, es_principal) FROM stdin;
1	17	t
1	18	f
2	18	t
2	17	f
3	34	t
4	23	t
4	33	f
5	12	t
6	1	t
8	7	t
9	17	t
10	29	t
11	7	t
12	15	t
13	20	t
14	4	t
7	1	t
41	1	t
42	7	t
43	2	t
44	7	t
45	10	t
46	7	t
47	7	t
48	1	t
49	4	t
50	7	t
\.


--
-- Data for Name: metodo_pago; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.metodo_pago (id_metodo_pago, nombre) FROM stdin;
1	Efectivo
2	Tarjeta de debito
3	Tarjeta de credito
4	Transferencia bancaria
5	Cheque
\.


--
-- Data for Name: momento_quirurgico; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.momento_quirurgico (id_momento, nombre, fase, orden) FROM stdin;
1	Planificacion preoperatoria	Preoperatorio	1
2	Entrada a quirofano	Preoperatorio	2
3	Chequeo en quirofano	Intraoperatorio	3
4	Procedimientos de pausa quirurgica	Intraoperatorio	4
5	Gestion de cuidados intraoperatoria	Intraoperatorio	5
6	Salida quirurgica	Intraoperatorio	6
7	Ingreso a sala de recuperacion	Postoperatorio	7
8	Traslado seguro a sala	Postoperatorio	8
\.


--
-- Data for Name: municipio; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.municipio (id_municipio, id_departamento, nombre) FROM stdin;
1	1	Quetzaltenango
2	1	Salcaja
3	1	Olintepeque
4	1	Cantel
5	1	Almolonga
6	1	Zunil
7	1	San Carlos Sija
8	1	Coatepeque
9	1	La Esperanza
10	1	San Juan Ostuncalco
11	2	Totonicapan
12	2	San Cristobal Totonicapan
13	2	San Francisco El Alto
14	2	Momostenango
15	2	Santa Maria Chiquimula
16	3	San Marcos
17	3	San Pedro Sacatepequez
18	3	Malacatan
19	3	Esquipulas Palo Gordo
20	4	Huehuetenango
21	4	Chiantla
22	4	Malacatancito
23	4	Santa Cruz Barillas
24	5	Solola
25	5	Panajachel
26	5	Santiago Atitlan
27	6	Santa Cruz del Quiche
28	6	Chichicastenango
29	7	Mazatenango
30	7	Cuyotenango
31	8	Retalhuleu
32	8	San Sebastian
33	11	Guatemala
34	11	Mixco
35	11	Villa Nueva
\.


--
-- Data for Name: orden_laboratorio; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.orden_laboratorio (id_orden_laboratorio, id_consulta, fecha_emision, indicaciones) FROM stdin;
1	1	2026-09-12	Realizar en ayuno temprano para recuento leucocitario
2	3	2026-09-18	Evaluacion de perfil hematico y quimica sanguinea completa
\.


--
-- Data for Name: orden_laboratorio_detalle; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.orden_laboratorio_detalle (id_orden_laboratorio, id_examen) FROM stdin;
1	1
2	1
2	2
2	4
\.


--
-- Data for Name: paciente; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.paciente (id_paciente, id_persona, no_expediente, estado_civil, no_seguro_social, religion, ocupacion, id_municipio_nacimiento) FROM stdin;
1	28	EXP-2026-0001	Soltero	1002548960	Catolica	Agricultor	1
2	29	EXP-2026-0002	Casado	1003698520	Evangelica	Ama de casa	1
3	30	EXP-2026-0003	Soltero	1004785210	Catolica	Comerciante	11
4	31	EXP-2026-0004	Soltero	\N	Catolica	Estudiante	11
5	32	EXP-2026-0005	Casado	1001478520	Catolica	Jubilado	1
6	33	EXP-2026-0006	Casado	1005896320	Evangelica	Maestra	1
7	34	EXP-2026-0007	Casado	1006985410	Catolica	Transportista	11
8	35	EXP-2026-0008	Viudo	1007896540	Catolica	Tejedora artesanal	1
9	61	EXP-2026-009	Casado	IGSS-4012589	Catolica	Comerciante	1
10	62	EXP-2026-010	Casado	IGSS-4123698	Evangelica	Maestra	1
11	63	EXP-2026-011	Soltero	IGSS-4234589	Catolica	Perito Contador	1
12	64	EXP-2026-012	Casado	IGSS-4345698	Evangelica	Secretaria	1
13	65	EXP-2026-013	Casado	IGSS-4456789	Catolica	Agricultor	1
14	66	EXP-2026-014	Soltero	\N	Catolica	Estudiante	2
15	67	EXP-2026-015	Casado	IGSS-4678912	Evangelica	Transportista	2
16	68	EXP-2026-016	Soltero	\N	Catolica	Estudiante	2
17	69	EXP-2026-017	Union de hecho	IGSS-4891234	Evangelica	Mecanico	2
18	70	EXP-2026-018	Viudo	IGSS-4912345	Catolica	Ama de casa	3
19	71	EXP-2026-019	Soltero	IGSS-5012345	Evangelica	Albañil	3
20	72	EXP-2026-020	Soltero	\N	Catolica	Perito Administracion	3
21	73	EXP-2026-021	Casado	IGSS-5234567	Catolica	Comerciante	4
22	74	EXP-2026-022	Casado	IGSS-5345678	Evangelica	Enfermera auxiliar	4
23	75	EXP-2026-023	Soltero	IGSS-5456789	Catolica	Chofer profesional	4
\.


--
-- Data for Name: paciente_encargado; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.paciente_encargado (id_paciente_encargado, id_paciente, id_persona, id_parentesco, es_principal) FROM stdin;
1	1	36	1	t
2	2	37	3	t
3	3	38	2	t
4	4	39	1	t
5	7	40	3	t
\.


--
-- Data for Name: pago; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.pago (id_pago, id_factura, numero_cuota, monto, fecha_pago, id_metodo_pago, id_unidad_hospital, id_personal_recibe, referencia) FROM stdin;
1	1	1	200.00	2026-09-12 17:20:00+00	1	1	25	REC-CE-1001
2	2	1	262.50	2026-09-15 16:35:00+00	2	1	25	POS-VISA-45892
3	3	1	165.00	2026-09-22 16:20:00+00	1	1	25	REC-CE-1002
4	4	1	1122.50	2026-09-03 21:45:00+00	3	3	27	TC-MASTERCARD-7814
5	4	2	1122.50	2026-09-28 16:00:00+00	4	3	27	TRANSF-BANRURAL-98451
6	5	1	820.83	2026-09-16 15:45:00+00	4	4	26	TRANSF-BI-332154
7	5	2	820.83	2026-09-27 17:30:00+00	2	4	26	POS-VISA-98741
10	10	1	250.00	2026-02-01 17:45:00+00	1	1	25	PAG-EFE-010
11	11	1	850.00	2026-03-11 01:45:00+00	2	2	25	VOUCHER-CC-011
12	12	1	2250.00	2026-04-05 23:45:00+00	2	3	25	VOUCHER-CC-012A
13	12	2	2250.00	2026-05-05 16:00:00+00	3	3	25	DEB-TRANS-012B
14	13	1	1200.00	2026-05-16 16:45:00+00	1	4	25	PAG-EFE-013
15	14	1	300.00	2026-02-15 18:45:00+00	3	1	25	DEB-TRANS-014
16	15	1	750.00	2026-03-23 11:45:00+00	1	2	25	PAG-EFE-015
17	16	1	2600.00	2026-04-18 21:45:00+00	2	3	25	VOUCHER-CC-016
18	17	1	1500.00	2026-06-05 19:45:00+00	1	4	25	PAG-EFE-017
19	18	1	275.00	2026-02-10 17:15:00+00	1	5	26	PAG-EFE-018
20	19	1	900.00	2026-03-15 13:45:00+00	2	6	26	VOUCHER-CC-019
21	20	1	4800.00	2026-05-20 22:45:00+00	3	7	26	DEB-TRANS-020
22	21	1	1100.00	2026-06-19 17:45:00+00	1	8	26	PAG-EFE-021
23	22	1	200.00	2026-05-02 16:45:00+00	1	9	27	PAG-EFE-022
24	23	1	1250.00	2026-06-15 15:45:00+00	3	12	27	DEB-TRANS-023
25	24	1	200.00	2026-06-01 17:15:00+00	1	13	27	PAG-EFE-024
26	25	1	1250.00	2026-07-10 19:45:00+00	2	16	27	VOUCHER-CC-025
\.


--
-- Data for Name: parentesco; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.parentesco (id_parentesco, nombre) FROM stdin;
1	Padre
2	Madre
3	Conyuge
4	Hijo
5	Hija
6	Hermano
7	Hermana
8	Abuelo
9	Abuela
10	Tio
11	Tia
12	Tutor Legal
13	Representante Legal
14	Otro
\.


--
-- Data for Name: persona; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.persona (id_persona, nombres, apellidos, dpi, fecha_nacimiento, sexo, telefono, id_direccion, creado_en) FROM stdin;
1	Carlos Roberto	Ixcoy Rodriguez	2548963210901	1978-04-12	Masculino	77611101	8	2026-10-26 04:35:51.362851+00
2	Juan Francisco	Yax Sac	2145879630901	1982-08-25	Masculino	77611102	9	2026-10-26 04:35:51.362851+00
3	Elmer David	Chaj Morales	1987542360901	1980-11-14	Masculino	77611103	10	2026-10-26 04:35:51.362851+00
4	Pedro Luis	Tzun Cux	1874563210901	1975-02-18	Masculino	77611104	11	2026-10-26 04:35:51.362851+00
5	Maria Elena	Alvarez Garcia	2365412890901	1985-05-30	Femenino	77611105	12	2026-10-26 04:35:51.362851+00
6	Ana Sofia	Vasquez Hernandez	2258964120901	1984-09-15	Femenino	77611106	13	2026-10-26 04:35:51.362851+00
7	Mario Alejandro	Gomez Chan	2489631450901	1988-12-04	Masculino	77611107	14	2026-10-26 04:35:51.362851+00
8	Roberto Miguel	Pop Coj	2654123980901	1989-07-21	Masculino	77611108	15	2026-10-26 04:35:51.362851+00
9	Jorge Luis	Xiquin Chuc	2789654120901	1994-03-10	Masculino	77611109	16	2026-10-26 04:35:51.362851+00
10	Victor Manuel	Quiej Macario	2896541230901	1995-06-18	Masculino	77611110	17	2026-10-26 04:35:51.362851+00
11	Edgar Fernando	Batres Estrada	2987456320901	1998-01-22	Masculino	77611111	18	2026-10-26 04:35:51.362851+00
12	Hector Daniel	Castillo Barrios	1654897230101	1972-10-05	Masculino	23341112	27	2026-10-26 04:35:51.362851+00
13	Diego Alejandro	Fuentes Ovalle	1745896320101	1974-04-19	Masculino	22511113	27	2026-10-26 04:35:51.362851+00
14	Silvia Patricia	De Leon Lopez	2014589630901	1981-03-27	Femenino	77611114	28	2026-10-26 04:35:51.362851+00
15	Carmen Lucia	Ixcoy Yax	2569874120901	1986-09-12	Femenino	77622215	28	2026-10-26 04:35:51.362851+00
16	Rosa Maria	Sac Chaj	2458963210901	1988-02-14	Femenino	77622216	29	2026-10-26 04:35:51.362851+00
17	Claudia Andrea	Morales Tzun	2369854120801	1990-11-20	Femenino	77622217	15	2026-10-26 04:35:51.362851+00
18	Juana Teresa	Cux Alvarez	2145896320801	1987-04-05	Femenino	77622218	16	2026-10-26 04:35:51.362851+00
19	Marta Leticia	Garcia Vasquez	2258741231201	1989-08-30	Femenino	77622219	19	2026-10-26 04:35:51.362851+00
20	Daniel Alejandro	Gomez Pop	3014589630901	2000-05-14	Masculino	55441120	30	2026-10-26 04:35:51.362851+00
21	Manuel Antonio	Chan Coj	3125489630901	2001-09-23	Masculino	55441121	31	2026-10-26 04:35:51.362851+00
22	David Fernando	Xiquin Batres	3258964120801	2000-12-01	Masculino	55441122	32	2026-10-26 04:35:51.362851+00
23	Brenda Sofia	Quiej Estrada	3058964120901	2002-02-18	Femenino	55442223	30	2026-10-26 04:35:51.362851+00
24	Ingrid Paola	Macario Castillo	3145896320801	2001-07-09	Femenino	55442224	32	2026-10-26 04:35:51.362851+00
25	Sandra Elena	Barrios Fuentes	2489632140901	1991-03-15	Femenino	77633325	34	2026-10-26 04:35:51.362851+00
26	Leticia Andrea	Ovalle De Leon	2377889910901	1992-10-28	Femenino	77633326	34	2026-10-26 04:35:51.362851+00
27	Victor Hugo	Sop Ajpop	2158963240801	1985-06-11	Masculino	77633327	35	2026-10-26 04:35:51.362851+00
28	Jose Miguel	Yax Ixcoy	2658941230901	1993-07-14	Masculino	55661128	8	2026-10-26 04:35:51.362851+00
29	Maria Concepcion	Sac Rodriguez	2799112230901	1996-01-20	Femenino	55661129	9	2026-10-26 04:35:51.362851+00
30	Juan Carlos	Chaj Tzun	2896541230801	1990-11-08	Masculino	55661130	15	2026-10-26 04:35:51.362851+00
31	Sofia Elizabeth	Cux Morales	\N	2018-04-25	Femenino	55661131	16	2026-10-26 04:35:51.362851+00
32	Pedro Francisco	Pop Chan	1548963210901	1960-03-18	Masculino	55661132	10	2026-10-26 04:35:51.362851+00
33	Elena Beatriz	Alvarez Hernandez	2466778810901	1988-09-05	Femenino	55661133	13	2026-10-26 04:35:51.362851+00
34	Mario Rene	Gomez Vasquez	2365894120801	1982-12-14	Masculino	55661134	17	2026-10-26 04:35:51.362851+00
35	Lucia Carmen	Xiquin Coj	2258963140901	1975-06-22	Femenino	55661135	14	2026-10-26 04:35:51.362851+00
36	Tomas Antonio	Yax Macario	1896541230901	1965-02-10	Masculino	55771136	8	2026-10-26 04:35:51.362851+00
37	Francisco Javier	Sac Lopez	2688991120901	1992-05-18	Masculino	55771137	9	2026-10-26 04:35:51.362851+00
38	Juana Maria	Tzun Batres	1789654120801	1968-08-30	Femenino	55771138	15	2026-10-26 04:35:51.362851+00
39	Roberto Daniel	Cux Estrada	2489651230801	1987-10-12	Masculino	55771139	16	2026-10-26 04:35:51.362851+00
40	Silvia Andrea	Gomez Castillo	2398745610801	1985-04-03	Femenino	55771140	17	2026-10-26 04:35:51.362851+00
41	Gustavo Adolfo	Perez Monzon	2154879650901	1981-05-12	Masculino	77612241	8	2026-10-26 04:43:55.744145+00
42	Laura Beatriz	Castillo Reyes	2365412780901	1985-09-20	Femenino	77612242	9	2026-10-26 04:43:55.744145+00
43	Ricardo Antonio	Lopez Estrada	2489632540901	1983-11-15	Masculino	77612243	10	2026-10-26 04:43:55.744145+00
44	Patricia Eugenia	Mendez Soto	2589631470901	1989-02-28	Femenino	77612244	11	2026-10-26 04:43:55.744145+00
45	Fernando Jose	Morales Paz	2698745120901	1990-07-14	Masculino	77612245	12	2026-10-26 04:43:55.744145+00
46	Sofia Alejandra	Guzman Cabrera	2789654130801	1987-12-03	Femenino	77612246	15	2026-10-26 04:43:55.744145+00
47	Oscar Rene	Barillas Ruiz	2896541280801	1992-04-18	Masculino	77612247	16	2026-10-26 04:43:55.744145+00
48	Claudia Marcela	Herrera Rios	1987542311201	1979-08-22	Femenino	77612248	19	2026-10-26 04:43:55.744145+00
49	Julio Cesar	Sandoval Mejia	2258963411201	1984-01-30	Masculino	77612249	20	2026-10-26 04:43:55.744145+00
50	Monica Rocio	Navarro Fuentes	2987456121201	1993-06-11	Femenino	77612250	21	2026-10-26 04:43:55.744145+00
51	Karla Maria	Aguilar Santos	3014589620901	1991-03-14	Femenino	77623351	13	2026-10-26 04:43:55.744145+00
52	Brenda Leticia	Orozco Lima	3125489610901	1994-10-25	Femenino	77623352	14	2026-10-26 04:43:55.744145+00
53	Edgar Rolando	Chavez Ramos	3258964110901	1988-06-19	Masculino	77623353	8	2026-10-26 04:43:55.744145+00
54	Silvia Lorena	Cifuentes Cano	3369854120901	1993-12-05	Femenino	77623354	9	2026-10-26 04:43:55.744145+00
55	Hugo Leonel	Molina Prado	3487541230901	1986-04-17	Masculino	77623355	10	2026-10-26 04:43:55.744145+00
56	Glendy Paola	Reyes Alonzo	3598741250801	1995-08-09	Femenino	77623356	17	2026-10-26 04:43:55.744145+00
57	Marcos Vinicio	Cabrera Solis	3654128960801	1990-01-23	Masculino	77623357	18	2026-10-26 04:43:55.744145+00
58	Vilma Elizabeth	Godinez Lara	3789654121201	1992-07-31	Femenino	77623358	22	2026-10-26 04:43:55.744145+00
59	Jorge Mario	Valenzuela Paz	3896541231201	1989-11-12	Masculino	77623359	23	2026-10-26 04:43:55.744145+00
60	Sonia Raquel	Pineda Cruz	3987456321201	1996-05-27	Femenino	77623360	24	2026-10-26 04:43:55.744145+00
61	Josue Daniel	Cifuentes Sac	4012589630901	1980-02-14	Masculino	55112261	25	2026-10-26 04:43:55.744145+00
62	Miriam Elizabeth	Morales Pop	4123698540901	1975-07-19	Femenino	55112262	26	2026-10-26 04:43:55.744145+00
63	Cesar Augusto	Gomez Chaj	4234589650901	1992-11-03	Masculino	55112263	27	2026-10-26 04:43:55.744145+00
64	Gladys Noemi	Tzun Alvarez	4345698740901	1988-04-26	Femenino	55112264	28	2026-10-26 04:43:55.744145+00
65	Ramiro Estuardo	Ixcoy Vasquez	4456789650901	1968-09-15	Masculino	55112265	29	2026-10-26 04:43:55.744145+00
66	Ingrid Marleny	Quiej Gomez	4567891230801	1995-12-30	Femenino	55112266	15	2026-10-26 04:43:55.744145+00
67	Hector Manuel	Yax Hernandez	4678912340801	1973-03-08	Masculino	55112267	16	2026-10-26 04:43:55.744145+00
68	Debora Raquel	Chuc Batres	4789123450801	2001-08-21	Femenino	55112268	17	2026-10-26 04:43:55.744145+00
69	Alvaro Enrique	Macario Castillo	4891234560801	1983-05-17	Masculino	55112269	18	2026-10-26 04:43:55.744145+00
70	Marta Lidia	Fuentes Sop	4912345671201	1965-10-10	Femenino	55112270	19	2026-10-26 04:43:55.744145+00
71	Wilson Rene	Ovalle Lopez	5012345681201	1997-01-05	Masculino	55112271	20	2026-10-26 04:43:55.744145+00
72	Wendy Johana	Barrios Chan	5123456791201	1999-06-22	Femenino	55112272	21	2026-10-26 04:43:55.744145+00
73	Guillermo Alfonso	Coj Tzun	5234567810101	1970-12-18	Masculino	55112273	30	2026-10-26 04:43:55.744145+00
74	Evelyn Roxana	Estrada Pop	5345678920101	1986-07-04	Femenino	55112274	31	2026-10-26 04:43:55.744145+00
75	Byron Alexander	Ajpop Coj	5456789130101	1991-09-29	Masculino	55112275	32	2026-10-26 04:43:55.744145+00
\.


--
-- Data for Name: personal; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.personal (id_personal, id_persona, tipo_personal, activo, fecha_contratacion, salario) FROM stdin;
2	2	Medico	t	2026-10-25	8000.00
3	3	Medico	t	2026-10-25	8000.00
4	4	Medico	t	2026-10-25	8000.00
5	5	Medico	t	2026-10-25	8000.00
6	6	Medico	t	2026-10-25	8000.00
7	7	Medico	t	2026-10-25	8000.00
8	8	Medico	t	2026-10-25	8000.00
9	9	Medico	t	2026-10-25	8000.00
10	10	Medico	t	2026-10-25	8000.00
11	11	Medico	t	2026-10-25	8000.00
12	12	Medico	t	2026-10-25	8000.00
13	13	Medico	t	2026-10-25	8000.00
14	14	Medico	t	2026-10-25	8000.00
15	15	Enfermero	t	2026-10-25	8000.00
16	16	Enfermero	t	2026-10-25	8000.00
17	17	Enfermero	t	2026-10-25	8000.00
18	18	Enfermero	t	2026-10-25	8000.00
19	19	Enfermero	t	2026-10-25	8000.00
20	20	Practicante de medicina	t	2026-10-25	8000.00
21	21	Practicante de medicina	t	2026-10-25	8000.00
22	22	Practicante de medicina	t	2026-10-25	8000.00
23	23	Practicante de enfermeria	t	2026-10-25	8000.00
24	24	Practicante de enfermeria	t	2026-10-25	8000.00
25	25	Administrativo	t	2026-10-25	8000.00
26	26	Administrativo	t	2026-10-25	8000.00
27	27	Administrativo	t	2026-10-25	8000.00
41	41	Medico	t	2024-02-01	16000.00
42	42	Medico	t	2024-03-15	13500.00
43	43	Medico	t	2024-05-01	13000.00
44	44	Medico	t	2025-01-10	11500.00
45	45	Medico	t	2025-02-01	11000.00
46	46	Medico	t	2024-06-01	13500.00
47	47	Medico	t	2025-03-15	11000.00
48	48	Medico	t	2023-11-01	22000.00
49	49	Medico	t	2024-04-10	15500.00
50	50	Medico	t	2025-06-01	10500.00
51	51	Enfermero	t	2024-01-15	7500.00
52	52	Enfermero	t	2024-03-01	6800.00
53	53	Enfermero	t	2023-08-15	7200.00
54	54	Enfermero	t	2024-07-01	7800.00
55	55	Enfermero	t	2023-10-01	8200.00
56	56	Enfermero	t	2025-01-15	6500.00
57	57	Enfermero	t	2024-05-20	7000.00
58	58	Enfermero	t	2024-02-10	7300.00
59	59	Enfermero	t	2023-12-01	6900.00
60	60	Enfermero	t	2025-04-01	6500.00
1	1	Medico	t	2026-10-25	14500.00
\.


--
-- Data for Name: procedimiento_quirurgico; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.procedimiento_quirurgico (id_procedimiento, id_especialidad, nombre, descripcion) FROM stdin;
1	18	Apendicectomia videolaparoscopica	Extirpacion quirurgica de apendice cecal inflamado por via laparoscopica
2	18	Colecistectomia laparoscopica	Extirpacion de vesicula biliar con calculos mediante tecnica laparoscopica
3	17	Herniorrafia inguinal con malla	Reparacion quirurgica de defecto herniario inguinal con colocacion de protesis
4	23	Osteosintesis de fractura de tibia	Reduccion abierta y fijacion interna con placa y tornillos en diafisis tibial
5	19	Cesarea segmentaria transperitoneal	Extraccion quirurgica de feto a traves de histerotomia segmentaria
6	15	Revascularizacion miocardica coronaria	Puente coronario con injerto arterial o venoso
7	16	Liberacion de tunel carpiano	Seccion del ligamento anular anterior del carpo
8	20	Craneotomia descompresiva de urgencia	Apertura quirurgica de calota para alivio de hipertension endocraneal
9	21	Facoemulsificacion con lente intraocular	Cirugia de catarata con ultrasonido y colocacion de implante
10	22	Tiroidectomia total oncologica	Reseccion completa de glandula tiroides y vaciamiento ganglionar
11	28	Reseccion transuretral de prostata	Ablacion endoscopica de tejido prostatico obstructivo
12	24	Amigdalectomia con adenoidectomia	Extirpacion quirurgica de amigdalas palatinas y tejido adenoideo
\.


--
-- Data for Name: receta; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.receta (id_receta, id_consulta, fecha_emision, id_cita_proxima, orientacion_paciente) FROM stdin;
1	1	2026-09-12	\N	Reposo en cama, abundantes liquidos tibios y vigilancia de signos de alarma
2	2	2026-09-15	\N	Dieta hiposodica estricta, caminata diaria 30 minutos y control de peso
3	4	2026-09-22	\N	Aplicar compresas tibias en zona lumbar y evitar sobrecargas de fuerza
10	10	2026-02-01	13	Tomar medicamentos segun horario indicado
11	11	2026-02-15	17	Dieta baja en sodio y control de presion arterial
12	13	2026-02-10	19	Reposo relativo y abundante hidratacion
13	15	2026-05-02	21	Continuar con tratamiento prescrito
\.


--
-- Data for Name: receta_detalle; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.receta_detalle (id_receta_detalle, id_receta, id_medicamento, dosis, duracion_dias) FROM stdin;
1	1	1	500 mg cada 8 horas por via oral	7
2	1	2	500 mg cada 8 horas si hay fiebre o malestar	3
3	2	4	50 mg cada 24 horas por la manana en ayunas	30
4	3	3	400 mg cada 8 horas despues de alimentos	5
5	3	7	20 mg cada 24 horas antes del desayuno	15
\.


--
-- Data for Name: registro_signos_vitales; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.registro_signos_vitales (id_signos_vitales, id_episodio, fecha_hora, presion_sistolica, presion_diastolica, frecuencia_cardiaca, frecuencia_respiratoria, temperatura_c, saturacion_oxigeno, peso_kg, talla_cm, id_personal) FROM stdin;
1	1	2026-09-01 14:15:00+00	120	80	88	18	38.2	98	68.50	168.0	17
2	1	2026-09-01 19:00:00+00	115	75	76	16	37.0	99	68.50	168.0	15
3	2	2026-09-05 12:45:00+00	110	70	78	18	36.6	99	72.00	158.0	16
4	3	2026-09-10 20:30:00+00	135	85	102	22	36.8	96	75.00	172.0	17
5	3	2026-09-11 14:00:00+00	125	80	82	18	37.1	98	75.00	172.0	18
6	4	2026-09-12 14:45:00+00	95	60	95	20	37.5	98	22.00	115.0	15
7	5	2026-09-15 15:15:00+00	130	82	70	16	36.5	97	80.00	165.0	16
8	6	2026-09-18 16:15:00+00	118	76	74	16	36.7	98	62.00	160.0	15
9	7	2026-09-22 14:15:00+00	122	80	76	17	36.6	98	74.00	170.0	16
10	8	2026-09-26 00:15:00+00	175	105	98	20	36.8	95	66.00	155.0	17
\.


--
-- Data for Name: revision_miembro_comite; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.revision_miembro_comite (id_revision, id_medico) FROM stdin;
1	1
1	3
2	1
2	14
3	1
3	4
4	1
4	6
\.


--
-- Data for Name: revision_solicitud; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.revision_solicitud (id_revision, id_solicitud_cirugia, decision, fecha_hora, razones) FROM stdin;
1	1	Aprobada	2026-09-01 15:45:00+00	\N
2	2	Aprobada	2026-09-04 20:00:00+00	\N
3	3	Aprobada	2026-09-10 21:45:00+00	\N
4	4	Rechazada	2026-09-17 15:00:00+00	Paciente presenta descompensacion hemodinamica y requiere estabilizacion previa con cateterismo diagnostico antes de cirugia mayor
10	10	Aprobada	2026-04-05 14:30:00+00	Paciente apto con riesgo quirurgico controlado
11	11	Aprobada	2026-04-18 14:00:00+00	Procedimiento electivo con valoracion preanestesica lista
12	12	Aprobada	2026-05-20 14:30:00+00	Comite otorga autorizacion unanime
\.


--
-- Data for Name: servicio_medico; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.servicio_medico (id_servicio, id_tipo_unidad, nombre, activo) FROM stdin;
1	1	Atencion Cardiologica Ambulatoria	t
2	1	Atencion Dermatologica	t
3	1	Fisioterapia y Rehabilitacion	t
4	1	Ginecologia Oncologica Clinica	t
5	1	Hematologia Clinica Ambulatoria	t
6	1	Medicina Fisica y Readaptacion	t
7	1	Consulta Medicina General	t
8	1	Nutricion Clinica y Dietetica	t
9	1	Odontologia General Integral	t
10	1	Oftalmologia Clinica General	t
11	1	Psicologia Clinica y Consejeria	t
12	1	Pediatria Clinica Ambulatoria	t
13	1	Urologia Clinica Integral	t
14	1	Terapia del Lenguaje y Foniatria	t
15	2	Aislamiento y control de la via aerea y ventilacion	t
16	2	Control cardiocirculatorio	t
17	2	Atencion de pacientes politraumatizados	t
18	2	Manejo, control y administracion de drogas protocolizadas	t
19	2	Procedimientos de control y observacion	t
20	2	Procedimientos terapeuticos y diagnosticos	t
21	2	Procedimientos diagnosticos de urgencia	t
22	3	Cirugia General y Abdominal	t
23	3	Cirugia Traumatologica y de Fracturas	t
24	3	Cirugia Ginecologica y Obstetricia	t
25	3	Cirugia Cardiovascular y Toracica	t
26	3	Videolaparoscopia Quirurgica de Precision	t
27	4	Hospitalizacion Hematologia	t
28	4	Hospitalizacion Medicina Interna	t
29	4	Hospitalizacion Neumologia	t
30	4	Hospitalizacion Neurologia	t
31	4	Hospitalizacion Oncologia	t
32	4	Hospitalizacion Ortopedia	t
33	4	Hospitalizacion Pediatria	t
34	4	Unidad de Cuidados Intermedios	t
35	4	Unidad de Cuidado Critico de Adultos	t
36	5	Servicio Medico Externo Referido	t
\.


--
-- Data for Name: solicitud_cirugia; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.solicitud_cirugia (id_solicitud_cirugia, id_episodio, id_historia_clinica, id_cirujano, caracter, id_tipo_anestesia, tiempo_estimado_min, fecha_hora_solicitud) FROM stdin;
1	1	1	2	Urgente	1	60	2026-09-01 15:35:00+00
2	2	2	14	Programado	2	75	2026-09-04 16:00:00+00
3	3	3	4	Urgente	2	120	2026-09-10 21:35:00+00
4	5	4	12	Programado	1	240	2026-09-16 17:00:00+00
10	11	10	2	Programado	1	120	2026-04-05 14:00:00+00
11	15	11	2	Programado	1	90	2026-04-18 13:30:00+00
12	19	12	41	Programado	1	110	2026-05-20 14:00:00+00
\.


--
-- Data for Name: solicitud_equipo; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.solicitud_equipo (id_solicitud_cirugia, id_equipo, cantidad) FROM stdin;
1	1	1
1	2	1
1	4	1
2	1	1
2	2	1
2	3	1
3	1	1
3	2	1
3	8	1
4	1	1
4	2	1
4	7	2
10	1	1
11	1	1
12	1	2
\.


--
-- Data for Name: solicitud_instrumento; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.solicitud_instrumento (id_solicitud_cirugia, id_instrumento, cantidad) FROM stdin;
1	1	1
1	2	1
1	4	2
1	11	1
2	1	1
2	3	1
2	9	1
2	10	2
3	1	1
3	8	2
3	6	4
3	10	2
4	1	1
4	2	2
4	6	6
10	1	2
11	1	2
12	1	3
\.


--
-- Data for Name: solicitud_insumo; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.solicitud_insumo (id_solicitud_cirugia, id_insumo, cantidad) FROM stdin;
1	1	4
1	2	4
1	3	2
1	5	2
2	1	4
2	2	4
2	3	3
2	6	2
3	1	6
3	2	6
3	4	3
3	5	3
4	1	6
4	2	8
4	14	1
10	1	2
10	2	1
11	1	2
11	2	1
12	1	3
12	2	2
\.


--
-- Data for Name: solicitud_procedimiento; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.solicitud_procedimiento (id_solicitud_cirugia, id_procedimiento) FROM stdin;
1	1
2	5
3	4
4	6
10	1
11	1
12	1
\.


--
-- Data for Name: tarifa_insumo; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.tarifa_insumo (id_hospital, id_insumo, precio_unitario) FROM stdin;
1	1	25.00
1	2	30.00
1	3	85.00
1	4	65.00
1	5	40.00
1	6	45.00
1	7	20.00
\.


--
-- Data for Name: tarifa_procedimiento; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.tarifa_procedimiento (id_hospital, id_procedimiento, costo) FROM stdin;
1	1	4500.00
1	2	5500.00
1	3	3800.00
1	4	6500.00
1	5	4200.00
1	6	25000.00
\.


--
-- Data for Name: tarifa_servicio; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.tarifa_servicio (id_hospital, id_servicio, costo_atencion, costo_dia) FROM stdin;
1	1	350.00	\N
1	7	150.00	\N
1	12	200.00	\N
1	16	400.00	300.00
1	17	600.00	350.00
1	19	250.00	200.00
1	22	1500.00	400.00
1	23	1800.00	450.00
1	24	1600.00	400.00
1	26	2200.00	450.00
1	32	500.00	350.00
1	28	450.00	300.00
\.


--
-- Data for Name: tipo_anestesia; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.tipo_anestesia (id_tipo_anestesia, nombre) FROM stdin;
1	Anestesia general balanceada
2	Anestesia regional raquidea
3	Anestesia epidural
4	Sedacion consciente monitorizada
5	Anestesia local infiltrativa
\.


--
-- Data for Name: tipo_unidad; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.tipo_unidad (id_tipo_unidad, nombre) FROM stdin;
1	Consulta externa
2	Emergencias
3	Cirugia
4	Hospitalizacion
5	Otro
\.


--
-- Data for Name: traslado; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.traslado (id_traslado, id_episodio, fecha_hora, id_medico_indica, id_hospital_origen, id_tipo_unidad_origen, id_servicio_origen, id_hospital_destino, id_tipo_unidad_destino, id_servicio_destino, id_ingreso_destino, motivo, consentimiento_otorgado, id_paciente_encargado) FROM stdin;
1	1	2026-09-01 15:15:00+00	7	1	2	19	1	3	22	2	Hallazgo ultrasonografico de apendicitis aguda grado II requiere cirugia inmediata	t	1
2	3	2026-09-10 21:15:00+00	8	1	2	17	1	3	23	5	Fractura cerrada desplazada requiere resolucion quirurgica de urgencia	t	3
3	3	2026-09-11 01:45:00+00	4	1	3	23	1	4	32	6	Traslado seguro postquirurgico para estancia hospitalaria y fisioterapia	t	3
\.


--
-- Data for Name: turno; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.turno (id_turno, nombre, hora_inicio, hora_fin) FROM stdin;
1	Turno Matutino Consulta Externa	06:00:00	14:00:00
2	Turno Vespertino Quirurgico	14:00:00	22:00:00
3	Guardia Emergencia Diurna 12h	07:00:00	19:00:00
4	Guardia Emergencia Nocturna 12h	19:00:00	07:00:00
\.


--
-- Data for Name: unidad_hospital; Type: TABLE DATA; Schema: hospitales_occidente; Owner: user1
--

COPY hospitales_occidente.unidad_hospital (id_unidad_hospital, id_hospital, id_tipo_unidad) FROM stdin;
1	1	1
2	1	2
3	1	3
4	1	4
5	2	1
6	2	2
7	2	3
8	2	4
9	3	1
10	3	2
11	3	3
12	3	4
13	4	1
14	4	2
15	4	3
16	4	4
\.


--
-- Data for Name: cirugia; Type: TABLE DATA; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

COPY normalizacion_cirugia.cirugia (id_cirugia, id_paciente, id_cirujano, id_diagnostico, fecha) FROM stdin;
1	1	1	1	2026-06-15 16:30:00+00
\.


--
-- Data for Name: cirugia_insumo; Type: TABLE DATA; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

COPY normalizacion_cirugia.cirugia_insumo (id_cirugia, id_insumo, cantidad) FROM stdin;
1	1	2.00
1	2	4.00
\.


--
-- Data for Name: cirujano; Type: TABLE DATA; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

COPY normalizacion_cirugia.cirujano (id_cirujano, nombre, especialidad) FROM stdin;
1	Dr. Roberto Gomez	Cirugia General
\.


--
-- Data for Name: diagnostico; Type: TABLE DATA; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

COPY normalizacion_cirugia.diagnostico (id_diagnostico, codigo_diagnostico, descripcion) FROM stdin;
1	K35.8	Apendicitis aguda no especificada
\.


--
-- Data for Name: insumo; Type: TABLE DATA; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

COPY normalizacion_cirugia.insumo (id_insumo, nombre, unidad_medida) FROM stdin;
1	Bisturi Quirurgico No. 15	Unidad
2	Sutura Vicryl 3-0	Unidad
\.


--
-- Data for Name: paciente; Type: TABLE DATA; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

COPY normalizacion_cirugia.paciente (id_paciente, nombre) FROM stdin;
1	Carlos Daniel Mendez Perez
\.


--
-- Name: asignacion_personal_id_asignacion_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.asignacion_personal_id_asignacion_seq', 45, true);


--
-- Name: bitacora_auditoria_personal_id_auditoria_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.bitacora_auditoria_personal_id_auditoria_seq', 45, true);


--
-- Name: calificacion_hospital_id_calificacion_hospital_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.calificacion_hospital_id_calificacion_hospital_seq', 4, true);


--
-- Name: calificacion_personal_id_calificacion_personal_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.calificacion_personal_id_calificacion_personal_seq', 22, true);


--
-- Name: cirugia_documento_fase_id_documento_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.cirugia_documento_fase_id_documento_seq', 9, true);


--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.cirugia_id_cirugia_seq', 12, true);


--
-- Name: cirugia_verificacion_id_verificacion_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.cirugia_verificacion_id_verificacion_seq', 55, true);


--
-- Name: cita_id_cita_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.cita_id_cita_seq', 21, true);


--
-- Name: clinica_id_clinica_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.clinica_id_clinica_seq', 12, true);


--
-- Name: consentimiento_informado_id_consentimiento_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.consentimiento_informado_id_consentimiento_seq', 3, true);


--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.consulta_id_consulta_seq', 16, true);


--
-- Name: consumo_insumo_id_consumo_insumo_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.consumo_insumo_id_consumo_insumo_seq', 11, true);


--
-- Name: departamento_id_departamento_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.departamento_id_departamento_seq', 22, true);


--
-- Name: diagnostico_id_diagnostico_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.diagnostico_id_diagnostico_seq', 15, true);


--
-- Name: direccion_id_direccion_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.direccion_id_direccion_seq', 35, true);


--
-- Name: egreso_id_egreso_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.egreso_id_egreso_seq', 20, true);


--
-- Name: episodio_id_episodio_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.episodio_id_episodio_seq', 30, true);


--
-- Name: equipo_id_equipo_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.equipo_id_equipo_seq', 11, true);


--
-- Name: espacio_atencion_id_espacio_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.espacio_atencion_id_espacio_seq', 27, true);


--
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.especialidad_id_especialidad_seq', 34, true);


--
-- Name: evaluacion_preanestesica_id_evaluacion_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.evaluacion_preanestesica_id_evaluacion_seq', 3, true);


--
-- Name: examen_laboratorio_id_examen_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.examen_laboratorio_id_examen_seq', 12, true);


--
-- Name: factura_detalle_id_factura_detalle_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.factura_detalle_id_factura_detalle_seq', 25, true);


--
-- Name: factura_id_factura_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.factura_id_factura_seq', 25, true);


--
-- Name: historia_clinica_id_historia_clinica_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.historia_clinica_id_historia_clinica_seq', 12, true);


--
-- Name: horario_medico_id_horario_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.horario_medico_id_horario_seq', 14, true);


--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.hospital_id_hospital_seq', 7, true);


--
-- Name: ingreso_id_ingreso_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.ingreso_id_ingreso_seq', 20, true);


--
-- Name: instrumento_id_instrumento_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.instrumento_id_instrumento_seq', 12, true);


--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.insumo_id_insumo_seq', 15, true);


--
-- Name: item_verificacion_id_item_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.item_verificacion_id_item_seq', 32, true);


--
-- Name: medicamento_id_medicamento_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.medicamento_id_medicamento_seq', 15, true);


--
-- Name: metodo_pago_id_metodo_pago_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.metodo_pago_id_metodo_pago_seq', 5, true);


--
-- Name: momento_quirurgico_id_momento_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.momento_quirurgico_id_momento_seq', 8, true);


--
-- Name: municipio_id_municipio_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.municipio_id_municipio_seq', 35, true);


--
-- Name: orden_laboratorio_id_orden_laboratorio_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.orden_laboratorio_id_orden_laboratorio_seq', 2, true);


--
-- Name: paciente_encargado_id_paciente_encargado_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.paciente_encargado_id_paciente_encargado_seq', 5, true);


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.paciente_id_paciente_seq', 23, true);


--
-- Name: pago_id_pago_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.pago_id_pago_seq', 26, true);


--
-- Name: parentesco_id_parentesco_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.parentesco_id_parentesco_seq', 14, true);


--
-- Name: persona_id_persona_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.persona_id_persona_seq', 75, true);


--
-- Name: personal_id_personal_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.personal_id_personal_seq', 60, true);


--
-- Name: procedimiento_quirurgico_id_procedimiento_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.procedimiento_quirurgico_id_procedimiento_seq', 12, true);


--
-- Name: receta_detalle_id_receta_detalle_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.receta_detalle_id_receta_detalle_seq', 5, true);


--
-- Name: receta_id_receta_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.receta_id_receta_seq', 13, true);


--
-- Name: registro_signos_vitales_id_signos_vitales_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.registro_signos_vitales_id_signos_vitales_seq', 10, true);


--
-- Name: revision_solicitud_id_revision_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.revision_solicitud_id_revision_seq', 12, true);


--
-- Name: servicio_medico_id_servicio_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.servicio_medico_id_servicio_seq', 36, true);


--
-- Name: solicitud_cirugia_id_solicitud_cirugia_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.solicitud_cirugia_id_solicitud_cirugia_seq', 12, true);


--
-- Name: tipo_anestesia_id_tipo_anestesia_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.tipo_anestesia_id_tipo_anestesia_seq', 5, true);


--
-- Name: tipo_unidad_id_tipo_unidad_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.tipo_unidad_id_tipo_unidad_seq', 5, true);


--
-- Name: traslado_id_traslado_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.traslado_id_traslado_seq', 3, true);


--
-- Name: turno_id_turno_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.turno_id_turno_seq', 4, true);


--
-- Name: unidad_hospital_id_unidad_hospital_seq; Type: SEQUENCE SET; Schema: hospitales_occidente; Owner: user1
--

SELECT pg_catalog.setval('hospitales_occidente.unidad_hospital_id_unidad_hospital_seq', 16, true);


--
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE SET; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

SELECT pg_catalog.setval('normalizacion_cirugia.cirugia_id_cirugia_seq', 1, true);


--
-- Name: cirujano_id_cirujano_seq; Type: SEQUENCE SET; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

SELECT pg_catalog.setval('normalizacion_cirugia.cirujano_id_cirujano_seq', 1, true);


--
-- Name: diagnostico_id_diagnostico_seq; Type: SEQUENCE SET; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

SELECT pg_catalog.setval('normalizacion_cirugia.diagnostico_id_diagnostico_seq', 1, true);


--
-- Name: insumo_id_insumo_seq; Type: SEQUENCE SET; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

SELECT pg_catalog.setval('normalizacion_cirugia.insumo_id_insumo_seq', 2, true);


--
-- Name: paciente_id_paciente_seq; Type: SEQUENCE SET; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

SELECT pg_catalog.setval('normalizacion_cirugia.paciente_id_paciente_seq', 1, true);


--
-- Name: cirugia ex_cirugia_traslape; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia
    ADD CONSTRAINT ex_cirugia_traslape EXCLUDE USING gist (id_quirofano WITH =, tstzrange(inicio_programado, fin_programado) WITH &&) WHERE (((estado)::text <> 'Cancelada'::text));


--
-- Name: asignacion_personal pk_asignacion_personal; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.asignacion_personal
    ADD CONSTRAINT pk_asignacion_personal PRIMARY KEY (id_asignacion);


--
-- Name: bitacora_auditoria_personal pk_bitacora_auditoria; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.bitacora_auditoria_personal
    ADD CONSTRAINT pk_bitacora_auditoria PRIMARY KEY (id_auditoria);


--
-- Name: calificacion_hospital pk_calificacion_hospital; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.calificacion_hospital
    ADD CONSTRAINT pk_calificacion_hospital PRIMARY KEY (id_calificacion_hospital);


--
-- Name: calificacion_personal pk_calificacion_personal; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.calificacion_personal
    ADD CONSTRAINT pk_calificacion_personal PRIMARY KEY (id_calificacion_personal);


--
-- Name: cirugia pk_cirugia; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia
    ADD CONSTRAINT pk_cirugia PRIMARY KEY (id_cirugia);


--
-- Name: cirugia_documento_fase pk_cirugia_documento_fase; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia_documento_fase
    ADD CONSTRAINT pk_cirugia_documento_fase PRIMARY KEY (id_documento);


--
-- Name: cirugia_equipo_medico pk_cirugia_equipo_medico; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia_equipo_medico
    ADD CONSTRAINT pk_cirugia_equipo_medico PRIMARY KEY (id_cirugia, id_personal);


--
-- Name: cirugia_verificacion pk_cirugia_verificacion; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia_verificacion
    ADD CONSTRAINT pk_cirugia_verificacion PRIMARY KEY (id_verificacion);


--
-- Name: cita pk_cita; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cita
    ADD CONSTRAINT pk_cita PRIMARY KEY (id_cita);


--
-- Name: clinica pk_clinica; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.clinica
    ADD CONSTRAINT pk_clinica PRIMARY KEY (id_clinica);


--
-- Name: consentimiento_informado pk_consentimiento_informado; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consentimiento_informado
    ADD CONSTRAINT pk_consentimiento_informado PRIMARY KEY (id_consentimiento);


--
-- Name: consulta pk_consulta; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consulta
    ADD CONSTRAINT pk_consulta PRIMARY KEY (id_consulta);


--
-- Name: consumo_insumo pk_consumo_insumo; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consumo_insumo
    ADD CONSTRAINT pk_consumo_insumo PRIMARY KEY (id_consumo_insumo);


--
-- Name: departamento pk_departamento; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.departamento
    ADD CONSTRAINT pk_departamento PRIMARY KEY (id_departamento);


--
-- Name: diagnostico pk_diagnostico; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.diagnostico
    ADD CONSTRAINT pk_diagnostico PRIMARY KEY (id_diagnostico);


--
-- Name: direccion pk_direccion; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.direccion
    ADD CONSTRAINT pk_direccion PRIMARY KEY (id_direccion);


--
-- Name: egreso pk_egreso; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.egreso
    ADD CONSTRAINT pk_egreso PRIMARY KEY (id_egreso);


--
-- Name: egreso_diagnostico_secundario pk_egreso_diag_secundario; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.egreso_diagnostico_secundario
    ADD CONSTRAINT pk_egreso_diag_secundario PRIMARY KEY (id_egreso, id_diagnostico);


--
-- Name: enfermero pk_enfermero; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.enfermero
    ADD CONSTRAINT pk_enfermero PRIMARY KEY (id_personal);


--
-- Name: episodio pk_episodio; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.episodio
    ADD CONSTRAINT pk_episodio PRIMARY KEY (id_episodio);


--
-- Name: equipo pk_equipo; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.equipo
    ADD CONSTRAINT pk_equipo PRIMARY KEY (id_equipo);


--
-- Name: espacio_atencion pk_espacio_atencion; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.espacio_atencion
    ADD CONSTRAINT pk_espacio_atencion PRIMARY KEY (id_espacio);


--
-- Name: especialidad pk_especialidad; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.especialidad
    ADD CONSTRAINT pk_especialidad PRIMARY KEY (id_especialidad);


--
-- Name: evaluacion_preanestesica pk_evaluacion_preanestesica; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.evaluacion_preanestesica
    ADD CONSTRAINT pk_evaluacion_preanestesica PRIMARY KEY (id_evaluacion);


--
-- Name: examen_laboratorio pk_examen_laboratorio; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.examen_laboratorio
    ADD CONSTRAINT pk_examen_laboratorio PRIMARY KEY (id_examen);


--
-- Name: factura pk_factura; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.factura
    ADD CONSTRAINT pk_factura PRIMARY KEY (id_factura);


--
-- Name: factura_detalle pk_factura_detalle; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.factura_detalle
    ADD CONSTRAINT pk_factura_detalle PRIMARY KEY (id_factura_detalle);


--
-- Name: historia_clinica pk_historia_clinica; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.historia_clinica
    ADD CONSTRAINT pk_historia_clinica PRIMARY KEY (id_historia_clinica);


--
-- Name: horario_medico pk_horario_medico; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.horario_medico
    ADD CONSTRAINT pk_horario_medico PRIMARY KEY (id_horario);


--
-- Name: hospital pk_hospital; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.hospital
    ADD CONSTRAINT pk_hospital PRIMARY KEY (id_hospital);


--
-- Name: ingreso pk_ingreso; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.ingreso
    ADD CONSTRAINT pk_ingreso PRIMARY KEY (id_ingreso);


--
-- Name: instrumento pk_instrumento; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.instrumento
    ADD CONSTRAINT pk_instrumento PRIMARY KEY (id_instrumento);


--
-- Name: insumo pk_insumo; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.insumo
    ADD CONSTRAINT pk_insumo PRIMARY KEY (id_insumo);


--
-- Name: item_verificacion pk_item_verificacion; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.item_verificacion
    ADD CONSTRAINT pk_item_verificacion PRIMARY KEY (id_item);


--
-- Name: medicamento pk_medicamento; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.medicamento
    ADD CONSTRAINT pk_medicamento PRIMARY KEY (id_medicamento);


--
-- Name: medico pk_medico; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.medico
    ADD CONSTRAINT pk_medico PRIMARY KEY (id_personal);


--
-- Name: medico_especialidad pk_medico_especialidad; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.medico_especialidad
    ADD CONSTRAINT pk_medico_especialidad PRIMARY KEY (id_medico, id_especialidad);


--
-- Name: metodo_pago pk_metodo_pago; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.metodo_pago
    ADD CONSTRAINT pk_metodo_pago PRIMARY KEY (id_metodo_pago);


--
-- Name: momento_quirurgico pk_momento_quirurgico; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.momento_quirurgico
    ADD CONSTRAINT pk_momento_quirurgico PRIMARY KEY (id_momento);


--
-- Name: municipio pk_municipio; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.municipio
    ADD CONSTRAINT pk_municipio PRIMARY KEY (id_municipio);


--
-- Name: orden_laboratorio pk_orden_laboratorio; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.orden_laboratorio
    ADD CONSTRAINT pk_orden_laboratorio PRIMARY KEY (id_orden_laboratorio);


--
-- Name: orden_laboratorio_detalle pk_orden_laboratorio_detalle; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.orden_laboratorio_detalle
    ADD CONSTRAINT pk_orden_laboratorio_detalle PRIMARY KEY (id_orden_laboratorio, id_examen);


--
-- Name: paciente pk_paciente; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.paciente
    ADD CONSTRAINT pk_paciente PRIMARY KEY (id_paciente);


--
-- Name: paciente_encargado pk_paciente_encargado; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.paciente_encargado
    ADD CONSTRAINT pk_paciente_encargado PRIMARY KEY (id_paciente_encargado);


--
-- Name: pago pk_pago; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.pago
    ADD CONSTRAINT pk_pago PRIMARY KEY (id_pago);


--
-- Name: parentesco pk_parentesco; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.parentesco
    ADD CONSTRAINT pk_parentesco PRIMARY KEY (id_parentesco);


--
-- Name: persona pk_persona; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.persona
    ADD CONSTRAINT pk_persona PRIMARY KEY (id_persona);


--
-- Name: personal pk_personal; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.personal
    ADD CONSTRAINT pk_personal PRIMARY KEY (id_personal);


--
-- Name: procedimiento_quirurgico pk_procedimiento_quirurgico; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.procedimiento_quirurgico
    ADD CONSTRAINT pk_procedimiento_quirurgico PRIMARY KEY (id_procedimiento);


--
-- Name: receta pk_receta; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.receta
    ADD CONSTRAINT pk_receta PRIMARY KEY (id_receta);


--
-- Name: receta_detalle pk_receta_detalle; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.receta_detalle
    ADD CONSTRAINT pk_receta_detalle PRIMARY KEY (id_receta_detalle);


--
-- Name: registro_signos_vitales pk_registro_signos_vitales; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.registro_signos_vitales
    ADD CONSTRAINT pk_registro_signos_vitales PRIMARY KEY (id_signos_vitales);


--
-- Name: revision_miembro_comite pk_revision_miembro_comite; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.revision_miembro_comite
    ADD CONSTRAINT pk_revision_miembro_comite PRIMARY KEY (id_revision, id_medico);


--
-- Name: revision_solicitud pk_revision_solicitud; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.revision_solicitud
    ADD CONSTRAINT pk_revision_solicitud PRIMARY KEY (id_revision);


--
-- Name: servicio_medico pk_servicio_medico; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.servicio_medico
    ADD CONSTRAINT pk_servicio_medico PRIMARY KEY (id_servicio);


--
-- Name: solicitud_cirugia pk_solicitud_cirugia; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_cirugia
    ADD CONSTRAINT pk_solicitud_cirugia PRIMARY KEY (id_solicitud_cirugia);


--
-- Name: solicitud_equipo pk_solicitud_equipo; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_equipo
    ADD CONSTRAINT pk_solicitud_equipo PRIMARY KEY (id_solicitud_cirugia, id_equipo);


--
-- Name: solicitud_instrumento pk_solicitud_instrumento; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_instrumento
    ADD CONSTRAINT pk_solicitud_instrumento PRIMARY KEY (id_solicitud_cirugia, id_instrumento);


--
-- Name: solicitud_insumo pk_solicitud_insumo; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_insumo
    ADD CONSTRAINT pk_solicitud_insumo PRIMARY KEY (id_solicitud_cirugia, id_insumo);


--
-- Name: solicitud_procedimiento pk_solicitud_procedimiento; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_procedimiento
    ADD CONSTRAINT pk_solicitud_procedimiento PRIMARY KEY (id_solicitud_cirugia, id_procedimiento);


--
-- Name: tarifa_insumo pk_tarifa_insumo; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tarifa_insumo
    ADD CONSTRAINT pk_tarifa_insumo PRIMARY KEY (id_hospital, id_insumo);


--
-- Name: tarifa_procedimiento pk_tarifa_procedimiento; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tarifa_procedimiento
    ADD CONSTRAINT pk_tarifa_procedimiento PRIMARY KEY (id_hospital, id_procedimiento);


--
-- Name: tarifa_servicio pk_tarifa_servicio; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tarifa_servicio
    ADD CONSTRAINT pk_tarifa_servicio PRIMARY KEY (id_hospital, id_servicio);


--
-- Name: tipo_anestesia pk_tipo_anestesia; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tipo_anestesia
    ADD CONSTRAINT pk_tipo_anestesia PRIMARY KEY (id_tipo_anestesia);


--
-- Name: tipo_unidad pk_tipo_unidad; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tipo_unidad
    ADD CONSTRAINT pk_tipo_unidad PRIMARY KEY (id_tipo_unidad);


--
-- Name: traslado pk_traslado; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.traslado
    ADD CONSTRAINT pk_traslado PRIMARY KEY (id_traslado);


--
-- Name: turno pk_turno; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.turno
    ADD CONSTRAINT pk_turno PRIMARY KEY (id_turno);


--
-- Name: unidad_hospital pk_unidad_hospital; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.unidad_hospital
    ADD CONSTRAINT pk_unidad_hospital PRIMARY KEY (id_unidad_hospital);


--
-- Name: asignacion_personal uq_asignacion_personal; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.asignacion_personal
    ADD CONSTRAINT uq_asignacion_personal UNIQUE (id_personal, id_unidad_hospital, id_turno, fecha_inicio);


--
-- Name: calificacion_hospital uq_calificacion_hospital; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.calificacion_hospital
    ADD CONSTRAINT uq_calificacion_hospital UNIQUE (id_episodio);


--
-- Name: calificacion_personal uq_calificacion_personal; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.calificacion_personal
    ADD CONSTRAINT uq_calificacion_personal UNIQUE (id_episodio, id_personal);


--
-- Name: cirugia_documento_fase uq_cirugia_documento_fase; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia_documento_fase
    ADD CONSTRAINT uq_cirugia_documento_fase UNIQUE (id_cirugia, fase);


--
-- Name: cirugia uq_cirugia_solicitud; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia
    ADD CONSTRAINT uq_cirugia_solicitud UNIQUE (id_solicitud_cirugia);


--
-- Name: cirugia_verificacion uq_cirugia_verificacion; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia_verificacion
    ADD CONSTRAINT uq_cirugia_verificacion UNIQUE (id_cirugia, id_item);


--
-- Name: clinica uq_clinica_numero; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.clinica
    ADD CONSTRAINT uq_clinica_numero UNIQUE (id_hospital, numero_clinica);


--
-- Name: consentimiento_informado uq_consentimiento_cirugia; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consentimiento_informado
    ADD CONSTRAINT uq_consentimiento_cirugia UNIQUE (id_cirugia);


--
-- Name: consulta uq_consulta_cita; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consulta
    ADD CONSTRAINT uq_consulta_cita UNIQUE (id_cita);


--
-- Name: departamento uq_departamento_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.departamento
    ADD CONSTRAINT uq_departamento_nombre UNIQUE (nombre);


--
-- Name: diagnostico uq_diagnostico_codigo; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.diagnostico
    ADD CONSTRAINT uq_diagnostico_codigo UNIQUE (codigo_cie10);


--
-- Name: egreso uq_egreso_ingreso; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.egreso
    ADD CONSTRAINT uq_egreso_ingreso UNIQUE (id_ingreso);


--
-- Name: egreso uq_egreso_traslado; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.egreso
    ADD CONSTRAINT uq_egreso_traslado UNIQUE (id_traslado);


--
-- Name: enfermero uq_enfermero_licencia; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.enfermero
    ADD CONSTRAINT uq_enfermero_licencia UNIQUE (no_licencia);


--
-- Name: equipo uq_equipo_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.equipo
    ADD CONSTRAINT uq_equipo_nombre UNIQUE (nombre);


--
-- Name: espacio_atencion uq_espacio_codigo; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.espacio_atencion
    ADD CONSTRAINT uq_espacio_codigo UNIQUE (id_unidad_hospital, codigo);


--
-- Name: especialidad uq_especialidad_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.especialidad
    ADD CONSTRAINT uq_especialidad_nombre UNIQUE (nombre);


--
-- Name: evaluacion_preanestesica uq_evaluacion_cirugia; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.evaluacion_preanestesica
    ADD CONSTRAINT uq_evaluacion_cirugia UNIQUE (id_cirugia);


--
-- Name: examen_laboratorio uq_examen_laboratorio_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.examen_laboratorio
    ADD CONSTRAINT uq_examen_laboratorio_nombre UNIQUE (nombre);


--
-- Name: factura uq_factura_numero; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.factura
    ADD CONSTRAINT uq_factura_numero UNIQUE (serie, numero_factura);


--
-- Name: historia_clinica uq_historia_signos; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.historia_clinica
    ADD CONSTRAINT uq_historia_signos UNIQUE (id_signos_vitales);


--
-- Name: horario_medico uq_horario_medico; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.horario_medico
    ADD CONSTRAINT uq_horario_medico UNIQUE (id_medico, id_clinica, dia_semana, hora_inicio);


--
-- Name: hospital uq_hospital_codigo; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.hospital
    ADD CONSTRAINT uq_hospital_codigo UNIQUE (codigo);


--
-- Name: hospital uq_hospital_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.hospital
    ADD CONSTRAINT uq_hospital_nombre UNIQUE (nombre);


--
-- Name: instrumento uq_instrumento_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.instrumento
    ADD CONSTRAINT uq_instrumento_nombre UNIQUE (nombre);


--
-- Name: insumo uq_insumo_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.insumo
    ADD CONSTRAINT uq_insumo_nombre UNIQUE (nombre);


--
-- Name: item_verificacion uq_item_verificacion_desc; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.item_verificacion
    ADD CONSTRAINT uq_item_verificacion_desc UNIQUE (id_momento, descripcion);


--
-- Name: medicamento uq_medicamento_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.medicamento
    ADD CONSTRAINT uq_medicamento_nombre UNIQUE (nombre, presentacion);


--
-- Name: medico uq_medico_colegiado; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.medico
    ADD CONSTRAINT uq_medico_colegiado UNIQUE (no_colegiado);


--
-- Name: metodo_pago uq_metodo_pago_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.metodo_pago
    ADD CONSTRAINT uq_metodo_pago_nombre UNIQUE (nombre);


--
-- Name: momento_quirurgico uq_momento_quirurgico_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.momento_quirurgico
    ADD CONSTRAINT uq_momento_quirurgico_nombre UNIQUE (nombre);


--
-- Name: municipio uq_municipio_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.municipio
    ADD CONSTRAINT uq_municipio_nombre UNIQUE (id_departamento, nombre);


--
-- Name: paciente_encargado uq_paciente_encargado; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.paciente_encargado
    ADD CONSTRAINT uq_paciente_encargado UNIQUE (id_paciente, id_persona);


--
-- Name: paciente uq_paciente_expediente; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.paciente
    ADD CONSTRAINT uq_paciente_expediente UNIQUE (no_expediente);


--
-- Name: paciente uq_paciente_persona; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.paciente
    ADD CONSTRAINT uq_paciente_persona UNIQUE (id_persona);


--
-- Name: paciente uq_paciente_seguro_social; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.paciente
    ADD CONSTRAINT uq_paciente_seguro_social UNIQUE (no_seguro_social);


--
-- Name: pago uq_pago_cuota; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.pago
    ADD CONSTRAINT uq_pago_cuota UNIQUE (id_factura, numero_cuota);


--
-- Name: parentesco uq_parentesco_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.parentesco
    ADD CONSTRAINT uq_parentesco_nombre UNIQUE (nombre);


--
-- Name: persona uq_persona_dpi; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.persona
    ADD CONSTRAINT uq_persona_dpi UNIQUE (dpi);


--
-- Name: personal uq_personal_persona; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.personal
    ADD CONSTRAINT uq_personal_persona UNIQUE (id_persona);


--
-- Name: procedimiento_quirurgico uq_procedimiento_quirurgico_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.procedimiento_quirurgico
    ADD CONSTRAINT uq_procedimiento_quirurgico_nombre UNIQUE (nombre);


--
-- Name: receta uq_receta_cita_proxima; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.receta
    ADD CONSTRAINT uq_receta_cita_proxima UNIQUE (id_cita_proxima);


--
-- Name: receta uq_receta_consulta; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.receta
    ADD CONSTRAINT uq_receta_consulta UNIQUE (id_consulta);


--
-- Name: receta_detalle uq_receta_detalle; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.receta_detalle
    ADD CONSTRAINT uq_receta_detalle UNIQUE (id_receta, id_medicamento);


--
-- Name: revision_solicitud uq_revision_solicitud; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.revision_solicitud
    ADD CONSTRAINT uq_revision_solicitud UNIQUE (id_solicitud_cirugia);


--
-- Name: servicio_medico uq_servicio_medico_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.servicio_medico
    ADD CONSTRAINT uq_servicio_medico_nombre UNIQUE (id_tipo_unidad, nombre);


--
-- Name: tipo_anestesia uq_tipo_anestesia_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tipo_anestesia
    ADD CONSTRAINT uq_tipo_anestesia_nombre UNIQUE (nombre);


--
-- Name: tipo_unidad uq_tipo_unidad_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tipo_unidad
    ADD CONSTRAINT uq_tipo_unidad_nombre UNIQUE (nombre);


--
-- Name: traslado uq_traslado_ingreso_destino; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.traslado
    ADD CONSTRAINT uq_traslado_ingreso_destino UNIQUE (id_ingreso_destino);


--
-- Name: turno uq_turno_nombre; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.turno
    ADD CONSTRAINT uq_turno_nombre UNIQUE (nombre);


--
-- Name: unidad_hospital uq_unidad_hospital; Type: CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.unidad_hospital
    ADD CONSTRAINT uq_unidad_hospital UNIQUE (id_hospital, id_tipo_unidad);


--
-- Name: cirugia pk_norm_cirugia; Type: CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.cirugia
    ADD CONSTRAINT pk_norm_cirugia PRIMARY KEY (id_cirugia);


--
-- Name: cirugia_insumo pk_norm_cirugia_insumo; Type: CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.cirugia_insumo
    ADD CONSTRAINT pk_norm_cirugia_insumo PRIMARY KEY (id_cirugia, id_insumo);


--
-- Name: cirujano pk_norm_cirujano; Type: CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.cirujano
    ADD CONSTRAINT pk_norm_cirujano PRIMARY KEY (id_cirujano);


--
-- Name: diagnostico pk_norm_diagnostico; Type: CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.diagnostico
    ADD CONSTRAINT pk_norm_diagnostico PRIMARY KEY (id_diagnostico);


--
-- Name: insumo pk_norm_insumo; Type: CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.insumo
    ADD CONSTRAINT pk_norm_insumo PRIMARY KEY (id_insumo);


--
-- Name: paciente pk_norm_paciente; Type: CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.paciente
    ADD CONSTRAINT pk_norm_paciente PRIMARY KEY (id_paciente);


--
-- Name: diagnostico uq_norm_diag_codigo; Type: CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.diagnostico
    ADD CONSTRAINT uq_norm_diag_codigo UNIQUE (codigo_diagnostico);


--
-- Name: insumo uq_norm_insumo_nombre; Type: CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.insumo
    ADD CONSTRAINT uq_norm_insumo_nombre UNIQUE (nombre);


--
-- Name: ix_asignacion_personal; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_asignacion_personal ON hospitales_occidente.asignacion_personal USING btree (id_personal);


--
-- Name: ix_asignacion_unidad; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_asignacion_unidad ON hospitales_occidente.asignacion_personal USING btree (id_unidad_hospital);


--
-- Name: ix_bitacora_fecha; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_bitacora_fecha ON hospitales_occidente.bitacora_auditoria_personal USING btree (fecha_hora);


--
-- Name: ix_bitacora_personal; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_bitacora_personal ON hospitales_occidente.bitacora_auditoria_personal USING btree (id_personal);


--
-- Name: ix_calpers_personal; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_calpers_personal ON hospitales_occidente.calificacion_personal USING btree (id_personal);


--
-- Name: ix_cireq_personal; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_cireq_personal ON hospitales_occidente.cirugia_equipo_medico USING btree (id_personal);


--
-- Name: ix_cirugia_estado_inicio; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_cirugia_estado_inicio ON hospitales_occidente.cirugia USING btree (estado, inicio_programado);


--
-- Name: ix_cirugia_quirofano; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_cirugia_quirofano ON hospitales_occidente.cirugia USING btree (id_quirofano);


--
-- Name: ix_cirver_enfermero; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_cirver_enfermero ON hospitales_occidente.cirugia_verificacion USING btree (id_enfermero);


--
-- Name: ix_cita_clinica_fecha; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_cita_clinica_fecha ON hospitales_occidente.cita USING btree (id_clinica, fecha_hora);


--
-- Name: ix_cita_paciente; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_cita_paciente ON hospitales_occidente.cita USING btree (id_paciente, fecha_hora);


--
-- Name: ix_clinica_hospital; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_clinica_hospital ON hospitales_occidente.clinica USING btree (id_hospital);


--
-- Name: ix_consulta_episodio; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_consulta_episodio ON hospitales_occidente.consulta USING btree (id_episodio);


--
-- Name: ix_consumo_ingreso; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_consumo_ingreso ON hospitales_occidente.consumo_insumo USING btree (id_ingreso);


--
-- Name: ix_consumo_insumo; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_consumo_insumo ON hospitales_occidente.consumo_insumo USING btree (id_insumo);


--
-- Name: ix_direccion_municipio; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_direccion_municipio ON hospitales_occidente.direccion USING btree (id_municipio);


--
-- Name: ix_egdiag_diagnostico; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_egdiag_diagnostico ON hospitales_occidente.egreso_diagnostico_secundario USING btree (id_diagnostico);


--
-- Name: ix_egreso_fecha; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_egreso_fecha ON hospitales_occidente.egreso USING btree (fecha_hora_egreso);


--
-- Name: ix_egreso_medico; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_egreso_medico ON hospitales_occidente.egreso USING btree (id_medico);


--
-- Name: ix_episodio_hospital; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_episodio_hospital ON hospitales_occidente.episodio USING btree (id_hospital, fecha_apertura);


--
-- Name: ix_episodio_paciente; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_episodio_paciente ON hospitales_occidente.episodio USING btree (id_paciente, fecha_apertura);


--
-- Name: ix_espacio_unidad; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_espacio_unidad ON hospitales_occidente.espacio_atencion USING btree (id_unidad_hospital);


--
-- Name: ix_factura_detalle_factura; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_factura_detalle_factura ON hospitales_occidente.factura_detalle USING btree (id_factura);


--
-- Name: ix_historia_episodio; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_historia_episodio ON hospitales_occidente.historia_clinica USING btree (id_episodio);


--
-- Name: ix_horario_clinica; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_horario_clinica ON hospitales_occidente.horario_medico USING btree (id_clinica);


--
-- Name: ix_hospital_direccion; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_hospital_direccion ON hospitales_occidente.hospital USING btree (id_direccion);


--
-- Name: ix_ingreso_diagnostico; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_ingreso_diagnostico ON hospitales_occidente.ingreso USING btree (id_diagnostico_presuntivo);


--
-- Name: ix_ingreso_episodio; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_ingreso_episodio ON hospitales_occidente.ingreso USING btree (id_episodio);


--
-- Name: ix_ingreso_espacio; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_ingreso_espacio ON hospitales_occidente.ingreso USING btree (id_espacio);


--
-- Name: ix_ingreso_medico; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_ingreso_medico ON hospitales_occidente.ingreso USING btree (id_medico);


--
-- Name: ix_ingreso_unidad_fecha; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_ingreso_unidad_fecha ON hospitales_occidente.ingreso USING btree (id_unidad_hospital, fecha_hora_ingreso);


--
-- Name: ix_item_verif_momento; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_item_verif_momento ON hospitales_occidente.item_verificacion USING btree (id_momento);


--
-- Name: ix_medesp_especialidad; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_medesp_especialidad ON hospitales_occidente.medico_especialidad USING btree (id_especialidad);


--
-- Name: ix_medico_superior; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_medico_superior ON hospitales_occidente.medico USING btree (id_superior);


--
-- Name: ix_municipio_departamento; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_municipio_departamento ON hospitales_occidente.municipio USING btree (id_departamento);


--
-- Name: ix_orden_lab_consulta; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_orden_lab_consulta ON hospitales_occidente.orden_laboratorio USING btree (id_consulta);


--
-- Name: ix_orden_lab_det_examen; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_orden_lab_det_examen ON hospitales_occidente.orden_laboratorio_detalle USING btree (id_examen);


--
-- Name: ix_paciente_encargado_pers; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_paciente_encargado_pers ON hospitales_occidente.paciente_encargado USING btree (id_persona);


--
-- Name: ix_paciente_persona; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_paciente_persona ON hospitales_occidente.paciente USING btree (id_persona);


--
-- Name: ix_pago_factura; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_pago_factura ON hospitales_occidente.pago USING btree (id_factura);


--
-- Name: ix_pago_fecha; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_pago_fecha ON hospitales_occidente.pago USING btree (fecha_pago);


--
-- Name: ix_persona_apellidos; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_persona_apellidos ON hospitales_occidente.persona USING btree (apellidos, nombres);


--
-- Name: ix_persona_direccion; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_persona_direccion ON hospitales_occidente.persona USING btree (id_direccion);


--
-- Name: ix_persona_dpi; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_persona_dpi ON hospitales_occidente.persona USING btree (dpi);


--
-- Name: ix_personal_persona; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_personal_persona ON hospitales_occidente.personal USING btree (id_persona);


--
-- Name: ix_personal_tipo; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_personal_tipo ON hospitales_occidente.personal USING btree (tipo_personal);


--
-- Name: ix_proc_especialidad; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_proc_especialidad ON hospitales_occidente.procedimiento_quirurgico USING btree (id_especialidad);


--
-- Name: ix_receta_detalle_med; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_receta_detalle_med ON hospitales_occidente.receta_detalle USING btree (id_medicamento);


--
-- Name: ix_servicio_tipo_unidad; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_servicio_tipo_unidad ON hospitales_occidente.servicio_medico USING btree (id_tipo_unidad);


--
-- Name: ix_signos_episodio; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_signos_episodio ON hospitales_occidente.registro_signos_vitales USING btree (id_episodio, fecha_hora);


--
-- Name: ix_solicitud_cirujano; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_solicitud_cirujano ON hospitales_occidente.solicitud_cirugia USING btree (id_cirujano);


--
-- Name: ix_solicitud_episodio; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_solicitud_episodio ON hospitales_occidente.solicitud_cirugia USING btree (id_episodio);


--
-- Name: ix_solproc_procedimiento; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_solproc_procedimiento ON hospitales_occidente.solicitud_procedimiento USING btree (id_procedimiento);


--
-- Name: ix_traslado_destino; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_traslado_destino ON hospitales_occidente.traslado USING btree (id_hospital_destino, id_tipo_unidad_destino);


--
-- Name: ix_traslado_episodio; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_traslado_episodio ON hospitales_occidente.traslado USING btree (id_episodio);


--
-- Name: ix_traslado_origen; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_traslado_origen ON hospitales_occidente.traslado USING btree (id_hospital_origen, id_tipo_unidad_origen);


--
-- Name: ix_unidad_hosp_hospital; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_unidad_hosp_hospital ON hospitales_occidente.unidad_hospital USING btree (id_hospital);


--
-- Name: ix_unidad_hosp_tipo; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE INDEX ix_unidad_hosp_tipo ON hospitales_occidente.unidad_hospital USING btree (id_tipo_unidad);


--
-- Name: uq_cirugia_cirujano_principal; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE UNIQUE INDEX uq_cirugia_cirujano_principal ON hospitales_occidente.cirugia_equipo_medico USING btree (id_cirugia) WHERE ((rol)::text = 'Cirujano principal'::text);


--
-- Name: uq_cita_medico_horario; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE UNIQUE INDEX uq_cita_medico_horario ON hospitales_occidente.cita USING btree (id_medico, fecha_hora) WHERE ((estado)::text = ANY ((ARRAY['Programada'::character varying, 'Realizada'::character varying])::text[]));


--
-- Name: uq_factura_episodio_emitida; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE UNIQUE INDEX uq_factura_episodio_emitida ON hospitales_occidente.factura USING btree (id_episodio) WHERE ((estado)::text = 'Emitida'::text);


--
-- Name: uq_medico_especialidad_principal; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE UNIQUE INDEX uq_medico_especialidad_principal ON hospitales_occidente.medico_especialidad USING btree (id_medico) WHERE es_principal;


--
-- Name: uq_paciente_encargado_principal; Type: INDEX; Schema: hospitales_occidente; Owner: user1
--

CREATE UNIQUE INDEX uq_paciente_encargado_principal ON hospitales_occidente.paciente_encargado USING btree (id_paciente) WHERE es_principal;


--
-- Name: ix_norm_cirugia_cirujano; Type: INDEX; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

CREATE INDEX ix_norm_cirugia_cirujano ON normalizacion_cirugia.cirugia USING btree (id_cirujano);


--
-- Name: ix_norm_cirugia_diagnostico; Type: INDEX; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

CREATE INDEX ix_norm_cirugia_diagnostico ON normalizacion_cirugia.cirugia USING btree (id_diagnostico);


--
-- Name: ix_norm_cirugia_fecha; Type: INDEX; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

CREATE INDEX ix_norm_cirugia_fecha ON normalizacion_cirugia.cirugia USING btree (fecha);


--
-- Name: ix_norm_cirugia_paciente; Type: INDEX; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

CREATE INDEX ix_norm_cirugia_paciente ON normalizacion_cirugia.cirugia USING btree (id_paciente);


--
-- Name: ix_norm_det_insumo; Type: INDEX; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

CREATE INDEX ix_norm_det_insumo ON normalizacion_cirugia.cirugia_insumo USING btree (id_insumo);


--
-- Name: medico trg_auditoria_medico; Type: TRIGGER; Schema: hospitales_occidente; Owner: user1
--

CREATE TRIGGER trg_auditoria_medico AFTER UPDATE ON hospitales_occidente.medico FOR EACH ROW EXECUTE FUNCTION hospitales_occidente.fn_auditoria_personal_medico();


--
-- Name: medico_especialidad trg_auditoria_medico_especialidad; Type: TRIGGER; Schema: hospitales_occidente; Owner: user1
--

CREATE TRIGGER trg_auditoria_medico_especialidad AFTER INSERT OR DELETE OR UPDATE ON hospitales_occidente.medico_especialidad FOR EACH ROW EXECUTE FUNCTION hospitales_occidente.fn_auditoria_personal_medico();


--
-- Name: personal trg_auditoria_personal; Type: TRIGGER; Schema: hospitales_occidente; Owner: user1
--

CREATE TRIGGER trg_auditoria_personal AFTER UPDATE ON hospitales_occidente.personal FOR EACH ROW EXECUTE FUNCTION hospitales_occidente.fn_auditoria_personal_medico();


--
-- Name: consulta trg_check_coherencia_paciente_consulta; Type: TRIGGER; Schema: hospitales_occidente; Owner: user1
--

CREATE TRIGGER trg_check_coherencia_paciente_consulta BEFORE INSERT OR UPDATE ON hospitales_occidente.consulta FOR EACH ROW EXECUTE FUNCTION hospitales_occidente.fn_check_coherencia_paciente_consulta();


--
-- Name: pago trg_check_cuota_pago; Type: TRIGGER; Schema: hospitales_occidente; Owner: user1
--

CREATE TRIGGER trg_check_cuota_pago BEFORE INSERT OR UPDATE ON hospitales_occidente.pago FOR EACH ROW EXECUTE FUNCTION hospitales_occidente.fn_check_cuota_pago();


--
-- Name: factura trg_check_cuotas_factura; Type: TRIGGER; Schema: hospitales_occidente; Owner: user1
--

CREATE TRIGGER trg_check_cuotas_factura BEFORE UPDATE ON hospitales_occidente.factura FOR EACH ROW EXECUTE FUNCTION hospitales_occidente.fn_check_cuotas_factura();


--
-- Name: egreso trg_check_fecha_egreso; Type: TRIGGER; Schema: hospitales_occidente; Owner: user1
--

CREATE TRIGGER trg_check_fecha_egreso BEFORE INSERT OR UPDATE ON hospitales_occidente.egreso FOR EACH ROW EXECUTE FUNCTION hospitales_occidente.fn_check_fecha_egreso();


--
-- Name: espacio_atencion trg_check_limite_quirofanos; Type: TRIGGER; Schema: hospitales_occidente; Owner: user1
--

CREATE TRIGGER trg_check_limite_quirofanos BEFORE INSERT OR UPDATE ON hospitales_occidente.espacio_atencion FOR EACH ROW EXECUTE FUNCTION hospitales_occidente.fn_check_limite_quirofanos();


--
-- Name: persona trg_check_persona_fecha_nacimiento; Type: TRIGGER; Schema: hospitales_occidente; Owner: user1
--

CREATE TRIGGER trg_check_persona_fecha_nacimiento BEFORE INSERT OR UPDATE ON hospitales_occidente.persona FOR EACH ROW EXECUTE FUNCTION hospitales_occidente.fn_check_persona_fecha_nacimiento();


--
-- Name: cirugia_equipo_medico trg_check_rol_equipo_quirurgico; Type: TRIGGER; Schema: hospitales_occidente; Owner: user1
--

CREATE TRIGGER trg_check_rol_equipo_quirurgico BEFORE INSERT OR UPDATE ON hospitales_occidente.cirugia_equipo_medico FOR EACH ROW EXECUTE FUNCTION hospitales_occidente.fn_check_rol_equipo_quirurgico();


--
-- Name: unidad_hospital trg_check_unidad_hospital_interno; Type: TRIGGER; Schema: hospitales_occidente; Owner: user1
--

CREATE TRIGGER trg_check_unidad_hospital_interno BEFORE INSERT OR UPDATE ON hospitales_occidente.unidad_hospital FOR EACH ROW EXECUTE FUNCTION hospitales_occidente.fn_check_unidad_hospital_interno();


--
-- Name: asignacion_personal fk_asignacion_personal; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.asignacion_personal
    ADD CONSTRAINT fk_asignacion_personal FOREIGN KEY (id_personal) REFERENCES hospitales_occidente.personal(id_personal) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: asignacion_personal fk_asignacion_turno; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.asignacion_personal
    ADD CONSTRAINT fk_asignacion_turno FOREIGN KEY (id_turno) REFERENCES hospitales_occidente.turno(id_turno) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: asignacion_personal fk_asignacion_unidad; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.asignacion_personal
    ADD CONSTRAINT fk_asignacion_unidad FOREIGN KEY (id_unidad_hospital) REFERENCES hospitales_occidente.unidad_hospital(id_unidad_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: bitacora_auditoria_personal fk_bitacora_personal; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.bitacora_auditoria_personal
    ADD CONSTRAINT fk_bitacora_personal FOREIGN KEY (id_personal) REFERENCES hospitales_occidente.personal(id_personal) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: calificacion_hospital fk_calhosp_episodio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.calificacion_hospital
    ADD CONSTRAINT fk_calhosp_episodio FOREIGN KEY (id_episodio) REFERENCES hospitales_occidente.episodio(id_episodio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion_personal fk_calpers_episodio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.calificacion_personal
    ADD CONSTRAINT fk_calpers_episodio FOREIGN KEY (id_episodio) REFERENCES hospitales_occidente.episodio(id_episodio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: calificacion_personal fk_calpers_personal; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.calificacion_personal
    ADD CONSTRAINT fk_calpers_personal FOREIGN KEY (id_personal) REFERENCES hospitales_occidente.personal(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_documento_fase fk_cirdoc_cirugia; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia_documento_fase
    ADD CONSTRAINT fk_cirdoc_cirugia FOREIGN KEY (id_cirugia) REFERENCES hospitales_occidente.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_documento_fase fk_cirdoc_enfermero; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia_documento_fase
    ADD CONSTRAINT fk_cirdoc_enfermero FOREIGN KEY (id_enfermero) REFERENCES hospitales_occidente.personal(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_equipo_medico fk_cireq_cirugia; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia_equipo_medico
    ADD CONSTRAINT fk_cireq_cirugia FOREIGN KEY (id_cirugia) REFERENCES hospitales_occidente.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_equipo_medico fk_cireq_personal; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia_equipo_medico
    ADD CONSTRAINT fk_cireq_personal FOREIGN KEY (id_personal) REFERENCES hospitales_occidente.personal(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia fk_cirugia_ingreso; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia
    ADD CONSTRAINT fk_cirugia_ingreso FOREIGN KEY (id_ingreso) REFERENCES hospitales_occidente.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia fk_cirugia_quirofano; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia
    ADD CONSTRAINT fk_cirugia_quirofano FOREIGN KEY (id_quirofano) REFERENCES hospitales_occidente.espacio_atencion(id_espacio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia fk_cirugia_solicitud; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia
    ADD CONSTRAINT fk_cirugia_solicitud FOREIGN KEY (id_solicitud_cirugia) REFERENCES hospitales_occidente.solicitud_cirugia(id_solicitud_cirugia) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_verificacion fk_cirver_cirugia; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia_verificacion
    ADD CONSTRAINT fk_cirver_cirugia FOREIGN KEY (id_cirugia) REFERENCES hospitales_occidente.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_verificacion fk_cirver_enfermero; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia_verificacion
    ADD CONSTRAINT fk_cirver_enfermero FOREIGN KEY (id_enfermero) REFERENCES hospitales_occidente.personal(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_verificacion fk_cirver_item; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cirugia_verificacion
    ADD CONSTRAINT fk_cirver_item FOREIGN KEY (id_item) REFERENCES hospitales_occidente.item_verificacion(id_item) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cita fk_cita_anterior; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cita
    ADD CONSTRAINT fk_cita_anterior FOREIGN KEY (id_cita_anterior) REFERENCES hospitales_occidente.cita(id_cita) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cita fk_cita_clinica; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cita
    ADD CONSTRAINT fk_cita_clinica FOREIGN KEY (id_clinica) REFERENCES hospitales_occidente.clinica(id_clinica) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cita fk_cita_hospital_referente; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cita
    ADD CONSTRAINT fk_cita_hospital_referente FOREIGN KEY (id_hospital_referente) REFERENCES hospitales_occidente.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cita fk_cita_medico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cita
    ADD CONSTRAINT fk_cita_medico FOREIGN KEY (id_medico) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cita fk_cita_paciente; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cita
    ADD CONSTRAINT fk_cita_paciente FOREIGN KEY (id_paciente) REFERENCES hospitales_occidente.paciente(id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cita fk_cita_recargo_origen; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.cita
    ADD CONSTRAINT fk_cita_recargo_origen FOREIGN KEY (id_cita_recargo_origen) REFERENCES hospitales_occidente.cita(id_cita) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: clinica fk_clinica_hospital; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.clinica
    ADD CONSTRAINT fk_clinica_hospital FOREIGN KEY (id_hospital) REFERENCES hospitales_occidente.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consentimiento_informado fk_consent_cirugia; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consentimiento_informado
    ADD CONSTRAINT fk_consent_cirugia FOREIGN KEY (id_cirugia) REFERENCES hospitales_occidente.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: consentimiento_informado fk_consent_encargado; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consentimiento_informado
    ADD CONSTRAINT fk_consent_encargado FOREIGN KEY (id_paciente_encargado) REFERENCES hospitales_occidente.paciente_encargado(id_paciente_encargado) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consentimiento_informado fk_consent_medico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consentimiento_informado
    ADD CONSTRAINT fk_consent_medico FOREIGN KEY (id_medico) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consulta fk_consulta_cita; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consulta
    ADD CONSTRAINT fk_consulta_cita FOREIGN KEY (id_cita) REFERENCES hospitales_occidente.cita(id_cita) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consulta fk_consulta_diagnostico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consulta
    ADD CONSTRAINT fk_consulta_diagnostico FOREIGN KEY (id_diagnostico) REFERENCES hospitales_occidente.diagnostico(id_diagnostico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consulta fk_consulta_episodio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consulta
    ADD CONSTRAINT fk_consulta_episodio FOREIGN KEY (id_episodio) REFERENCES hospitales_occidente.episodio(id_episodio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consumo_insumo fk_consumo_ingreso; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consumo_insumo
    ADD CONSTRAINT fk_consumo_ingreso FOREIGN KEY (id_ingreso) REFERENCES hospitales_occidente.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consumo_insumo fk_consumo_insumo; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consumo_insumo
    ADD CONSTRAINT fk_consumo_insumo FOREIGN KEY (id_insumo) REFERENCES hospitales_occidente.insumo(id_insumo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consumo_insumo fk_consumo_personal; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.consumo_insumo
    ADD CONSTRAINT fk_consumo_personal FOREIGN KEY (id_personal) REFERENCES hospitales_occidente.personal(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: direccion fk_direccion_municipio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.direccion
    ADD CONSTRAINT fk_direccion_municipio FOREIGN KEY (id_municipio) REFERENCES hospitales_occidente.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso_diagnostico_secundario fk_egdiag_diagnostico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.egreso_diagnostico_secundario
    ADD CONSTRAINT fk_egdiag_diagnostico FOREIGN KEY (id_diagnostico) REFERENCES hospitales_occidente.diagnostico(id_diagnostico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso_diagnostico_secundario fk_egdiag_egreso; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.egreso_diagnostico_secundario
    ADD CONSTRAINT fk_egdiag_egreso FOREIGN KEY (id_egreso) REFERENCES hospitales_occidente.egreso(id_egreso) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: egreso fk_egreso_diagnostico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.egreso
    ADD CONSTRAINT fk_egreso_diagnostico FOREIGN KEY (id_diagnostico_principal) REFERENCES hospitales_occidente.diagnostico(id_diagnostico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso fk_egreso_hospital_referido; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.egreso
    ADD CONSTRAINT fk_egreso_hospital_referido FOREIGN KEY (id_hospital_referido) REFERENCES hospitales_occidente.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso fk_egreso_ingreso; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.egreso
    ADD CONSTRAINT fk_egreso_ingreso FOREIGN KEY (id_ingreso) REFERENCES hospitales_occidente.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso fk_egreso_medico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.egreso
    ADD CONSTRAINT fk_egreso_medico FOREIGN KEY (id_medico) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: egreso fk_egreso_traslado; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.egreso
    ADD CONSTRAINT fk_egreso_traslado FOREIGN KEY (id_traslado) REFERENCES hospitales_occidente.traslado(id_traslado) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: enfermero fk_enfermero_personal; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.enfermero
    ADD CONSTRAINT fk_enfermero_personal FOREIGN KEY (id_personal) REFERENCES hospitales_occidente.personal(id_personal) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: episodio fk_episodio_hospital; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.episodio
    ADD CONSTRAINT fk_episodio_hospital FOREIGN KEY (id_hospital) REFERENCES hospitales_occidente.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: episodio fk_episodio_paciente; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.episodio
    ADD CONSTRAINT fk_episodio_paciente FOREIGN KEY (id_paciente) REFERENCES hospitales_occidente.paciente(id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: espacio_atencion fk_espacio_unidad; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.espacio_atencion
    ADD CONSTRAINT fk_espacio_unidad FOREIGN KEY (id_unidad_hospital) REFERENCES hospitales_occidente.unidad_hospital(id_unidad_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: evaluacion_preanestesica fk_evalpre_anestesiologo; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.evaluacion_preanestesica
    ADD CONSTRAINT fk_evalpre_anestesiologo FOREIGN KEY (id_anestesiologo) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: evaluacion_preanestesica fk_evalpre_cirugia; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.evaluacion_preanestesica
    ADD CONSTRAINT fk_evalpre_cirugia FOREIGN KEY (id_cirugia) REFERENCES hospitales_occidente.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: evaluacion_preanestesica fk_evalpre_clasifica; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.evaluacion_preanestesica
    ADD CONSTRAINT fk_evalpre_clasifica FOREIGN KEY (id_medico_clasifica) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: factura_detalle fk_facdet_cirugia; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.factura_detalle
    ADD CONSTRAINT fk_facdet_cirugia FOREIGN KEY (id_cirugia) REFERENCES hospitales_occidente.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: factura_detalle fk_facdet_consulta; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.factura_detalle
    ADD CONSTRAINT fk_facdet_consulta FOREIGN KEY (id_consulta) REFERENCES hospitales_occidente.consulta(id_consulta) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: factura_detalle fk_facdet_factura; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.factura_detalle
    ADD CONSTRAINT fk_facdet_factura FOREIGN KEY (id_factura) REFERENCES hospitales_occidente.factura(id_factura) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: factura_detalle fk_facdet_ingreso; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.factura_detalle
    ADD CONSTRAINT fk_facdet_ingreso FOREIGN KEY (id_ingreso) REFERENCES hospitales_occidente.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: factura fk_factura_episodio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.factura
    ADD CONSTRAINT fk_factura_episodio FOREIGN KEY (id_episodio) REFERENCES hospitales_occidente.episodio(id_episodio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: factura fk_factura_personal; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.factura
    ADD CONSTRAINT fk_factura_personal FOREIGN KEY (id_personal_emite) REFERENCES hospitales_occidente.personal(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: historia_clinica fk_historia_episodio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.historia_clinica
    ADD CONSTRAINT fk_historia_episodio FOREIGN KEY (id_episodio) REFERENCES hospitales_occidente.episodio(id_episodio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: historia_clinica fk_historia_medico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.historia_clinica
    ADD CONSTRAINT fk_historia_medico FOREIGN KEY (id_medico) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: historia_clinica fk_historia_signos; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.historia_clinica
    ADD CONSTRAINT fk_historia_signos FOREIGN KEY (id_signos_vitales) REFERENCES hospitales_occidente.registro_signos_vitales(id_signos_vitales) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: horario_medico fk_horario_clinica; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.horario_medico
    ADD CONSTRAINT fk_horario_clinica FOREIGN KEY (id_clinica) REFERENCES hospitales_occidente.clinica(id_clinica) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: horario_medico fk_horario_medico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.horario_medico
    ADD CONSTRAINT fk_horario_medico FOREIGN KEY (id_medico) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hospital fk_hospital_direccion; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.hospital
    ADD CONSTRAINT fk_hospital_direccion FOREIGN KEY (id_direccion) REFERENCES hospitales_occidente.direccion(id_direccion) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso fk_ingreso_diagnostico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.ingreso
    ADD CONSTRAINT fk_ingreso_diagnostico FOREIGN KEY (id_diagnostico_presuntivo) REFERENCES hospitales_occidente.diagnostico(id_diagnostico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso fk_ingreso_encargado; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.ingreso
    ADD CONSTRAINT fk_ingreso_encargado FOREIGN KEY (id_paciente_encargado) REFERENCES hospitales_occidente.paciente_encargado(id_paciente_encargado) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso fk_ingreso_episodio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.ingreso
    ADD CONSTRAINT fk_ingreso_episodio FOREIGN KEY (id_episodio) REFERENCES hospitales_occidente.episodio(id_episodio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso fk_ingreso_espacio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.ingreso
    ADD CONSTRAINT fk_ingreso_espacio FOREIGN KEY (id_espacio) REFERENCES hospitales_occidente.espacio_atencion(id_espacio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso fk_ingreso_medico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.ingreso
    ADD CONSTRAINT fk_ingreso_medico FOREIGN KEY (id_medico) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso fk_ingreso_servicio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.ingreso
    ADD CONSTRAINT fk_ingreso_servicio FOREIGN KEY (id_servicio) REFERENCES hospitales_occidente.servicio_medico(id_servicio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ingreso fk_ingreso_unidad; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.ingreso
    ADD CONSTRAINT fk_ingreso_unidad FOREIGN KEY (id_unidad_hospital) REFERENCES hospitales_occidente.unidad_hospital(id_unidad_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: item_verificacion fk_item_momento; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.item_verificacion
    ADD CONSTRAINT fk_item_momento FOREIGN KEY (id_momento) REFERENCES hospitales_occidente.momento_quirurgico(id_momento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: medico_especialidad fk_medesp_especialidad; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.medico_especialidad
    ADD CONSTRAINT fk_medesp_especialidad FOREIGN KEY (id_especialidad) REFERENCES hospitales_occidente.especialidad(id_especialidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: medico_especialidad fk_medesp_medico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.medico_especialidad
    ADD CONSTRAINT fk_medesp_medico FOREIGN KEY (id_medico) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: medico fk_medico_personal; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.medico
    ADD CONSTRAINT fk_medico_personal FOREIGN KEY (id_personal) REFERENCES hospitales_occidente.personal(id_personal) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: medico fk_medico_superior; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.medico
    ADD CONSTRAINT fk_medico_superior FOREIGN KEY (id_superior) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: municipio fk_municipio_departamento; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.municipio
    ADD CONSTRAINT fk_municipio_departamento FOREIGN KEY (id_departamento) REFERENCES hospitales_occidente.departamento(id_departamento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: orden_laboratorio fk_orden_consulta; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.orden_laboratorio
    ADD CONSTRAINT fk_orden_consulta FOREIGN KEY (id_consulta) REFERENCES hospitales_occidente.consulta(id_consulta) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: orden_laboratorio_detalle fk_ordendet_examen; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.orden_laboratorio_detalle
    ADD CONSTRAINT fk_ordendet_examen FOREIGN KEY (id_examen) REFERENCES hospitales_occidente.examen_laboratorio(id_examen) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: orden_laboratorio_detalle fk_ordendet_orden; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.orden_laboratorio_detalle
    ADD CONSTRAINT fk_ordendet_orden FOREIGN KEY (id_orden_laboratorio) REFERENCES hospitales_occidente.orden_laboratorio(id_orden_laboratorio) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paciente_encargado fk_pacenc_paciente; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.paciente_encargado
    ADD CONSTRAINT fk_pacenc_paciente FOREIGN KEY (id_paciente) REFERENCES hospitales_occidente.paciente(id_paciente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paciente_encargado fk_pacenc_parentesco; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.paciente_encargado
    ADD CONSTRAINT fk_pacenc_parentesco FOREIGN KEY (id_parentesco) REFERENCES hospitales_occidente.parentesco(id_parentesco) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: paciente_encargado fk_pacenc_persona; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.paciente_encargado
    ADD CONSTRAINT fk_pacenc_persona FOREIGN KEY (id_persona) REFERENCES hospitales_occidente.persona(id_persona) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: paciente fk_paciente_municipio_nac; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.paciente
    ADD CONSTRAINT fk_paciente_municipio_nac FOREIGN KEY (id_municipio_nacimiento) REFERENCES hospitales_occidente.municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: paciente fk_paciente_persona; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.paciente
    ADD CONSTRAINT fk_paciente_persona FOREIGN KEY (id_persona) REFERENCES hospitales_occidente.persona(id_persona) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pago fk_pago_factura; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.pago
    ADD CONSTRAINT fk_pago_factura FOREIGN KEY (id_factura) REFERENCES hospitales_occidente.factura(id_factura) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pago fk_pago_metodo; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.pago
    ADD CONSTRAINT fk_pago_metodo FOREIGN KEY (id_metodo_pago) REFERENCES hospitales_occidente.metodo_pago(id_metodo_pago) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pago fk_pago_personal; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.pago
    ADD CONSTRAINT fk_pago_personal FOREIGN KEY (id_personal_recibe) REFERENCES hospitales_occidente.personal(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pago fk_pago_unidad; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.pago
    ADD CONSTRAINT fk_pago_unidad FOREIGN KEY (id_unidad_hospital) REFERENCES hospitales_occidente.unidad_hospital(id_unidad_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: persona fk_persona_direccion; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.persona
    ADD CONSTRAINT fk_persona_direccion FOREIGN KEY (id_direccion) REFERENCES hospitales_occidente.direccion(id_direccion) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: personal fk_personal_persona; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.personal
    ADD CONSTRAINT fk_personal_persona FOREIGN KEY (id_persona) REFERENCES hospitales_occidente.persona(id_persona) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: procedimiento_quirurgico fk_procedimiento_especialidad; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.procedimiento_quirurgico
    ADD CONSTRAINT fk_procedimiento_especialidad FOREIGN KEY (id_especialidad) REFERENCES hospitales_occidente.especialidad(id_especialidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: receta_detalle fk_recdet_medicamento; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.receta_detalle
    ADD CONSTRAINT fk_recdet_medicamento FOREIGN KEY (id_medicamento) REFERENCES hospitales_occidente.medicamento(id_medicamento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: receta_detalle fk_recdet_receta; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.receta_detalle
    ADD CONSTRAINT fk_recdet_receta FOREIGN KEY (id_receta) REFERENCES hospitales_occidente.receta(id_receta) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: receta fk_receta_cita_proxima; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.receta
    ADD CONSTRAINT fk_receta_cita_proxima FOREIGN KEY (id_cita_proxima) REFERENCES hospitales_occidente.cita(id_cita) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: receta fk_receta_consulta; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.receta
    ADD CONSTRAINT fk_receta_consulta FOREIGN KEY (id_consulta) REFERENCES hospitales_occidente.consulta(id_consulta) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: revision_solicitud fk_revision_solicitud; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.revision_solicitud
    ADD CONSTRAINT fk_revision_solicitud FOREIGN KEY (id_solicitud_cirugia) REFERENCES hospitales_occidente.solicitud_cirugia(id_solicitud_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: revision_miembro_comite fk_revmiem_medico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.revision_miembro_comite
    ADD CONSTRAINT fk_revmiem_medico FOREIGN KEY (id_medico) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: revision_miembro_comite fk_revmiem_revision; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.revision_miembro_comite
    ADD CONSTRAINT fk_revmiem_revision FOREIGN KEY (id_revision) REFERENCES hospitales_occidente.revision_solicitud(id_revision) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: servicio_medico fk_servicio_tipo_unidad; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.servicio_medico
    ADD CONSTRAINT fk_servicio_tipo_unidad FOREIGN KEY (id_tipo_unidad) REFERENCES hospitales_occidente.tipo_unidad(id_tipo_unidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: registro_signos_vitales fk_signos_episodio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.registro_signos_vitales
    ADD CONSTRAINT fk_signos_episodio FOREIGN KEY (id_episodio) REFERENCES hospitales_occidente.episodio(id_episodio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: registro_signos_vitales fk_signos_personal; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.registro_signos_vitales
    ADD CONSTRAINT fk_signos_personal FOREIGN KEY (id_personal) REFERENCES hospitales_occidente.personal(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: solicitud_equipo fk_soleq_equipo; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_equipo
    ADD CONSTRAINT fk_soleq_equipo FOREIGN KEY (id_equipo) REFERENCES hospitales_occidente.equipo(id_equipo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: solicitud_equipo fk_soleq_solicitud; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_equipo
    ADD CONSTRAINT fk_soleq_solicitud FOREIGN KEY (id_solicitud_cirugia) REFERENCES hospitales_occidente.solicitud_cirugia(id_solicitud_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: solicitud_cirugia fk_solicitud_anestesia; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_cirugia
    ADD CONSTRAINT fk_solicitud_anestesia FOREIGN KEY (id_tipo_anestesia) REFERENCES hospitales_occidente.tipo_anestesia(id_tipo_anestesia) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: solicitud_cirugia fk_solicitud_cirujano; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_cirugia
    ADD CONSTRAINT fk_solicitud_cirujano FOREIGN KEY (id_cirujano) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: solicitud_cirugia fk_solicitud_episodio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_cirugia
    ADD CONSTRAINT fk_solicitud_episodio FOREIGN KEY (id_episodio) REFERENCES hospitales_occidente.episodio(id_episodio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: solicitud_cirugia fk_solicitud_historia; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_cirugia
    ADD CONSTRAINT fk_solicitud_historia FOREIGN KEY (id_historia_clinica) REFERENCES hospitales_occidente.historia_clinica(id_historia_clinica) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: solicitud_insumo fk_solins_insumo; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_insumo
    ADD CONSTRAINT fk_solins_insumo FOREIGN KEY (id_insumo) REFERENCES hospitales_occidente.insumo(id_insumo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: solicitud_insumo fk_solins_solicitud; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_insumo
    ADD CONSTRAINT fk_solins_solicitud FOREIGN KEY (id_solicitud_cirugia) REFERENCES hospitales_occidente.solicitud_cirugia(id_solicitud_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: solicitud_instrumento fk_solinstr_instrumento; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_instrumento
    ADD CONSTRAINT fk_solinstr_instrumento FOREIGN KEY (id_instrumento) REFERENCES hospitales_occidente.instrumento(id_instrumento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: solicitud_instrumento fk_solinstr_solicitud; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_instrumento
    ADD CONSTRAINT fk_solinstr_solicitud FOREIGN KEY (id_solicitud_cirugia) REFERENCES hospitales_occidente.solicitud_cirugia(id_solicitud_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: solicitud_procedimiento fk_solproc_procedimiento; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_procedimiento
    ADD CONSTRAINT fk_solproc_procedimiento FOREIGN KEY (id_procedimiento) REFERENCES hospitales_occidente.procedimiento_quirurgico(id_procedimiento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: solicitud_procedimiento fk_solproc_solicitud; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.solicitud_procedimiento
    ADD CONSTRAINT fk_solproc_solicitud FOREIGN KEY (id_solicitud_cirugia) REFERENCES hospitales_occidente.solicitud_cirugia(id_solicitud_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tarifa_insumo fk_tarins_hospital; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tarifa_insumo
    ADD CONSTRAINT fk_tarins_hospital FOREIGN KEY (id_hospital) REFERENCES hospitales_occidente.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tarifa_insumo fk_tarins_insumo; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tarifa_insumo
    ADD CONSTRAINT fk_tarins_insumo FOREIGN KEY (id_insumo) REFERENCES hospitales_occidente.insumo(id_insumo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: tarifa_procedimiento fk_tarproc_hospital; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tarifa_procedimiento
    ADD CONSTRAINT fk_tarproc_hospital FOREIGN KEY (id_hospital) REFERENCES hospitales_occidente.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tarifa_procedimiento fk_tarproc_procedimiento; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tarifa_procedimiento
    ADD CONSTRAINT fk_tarproc_procedimiento FOREIGN KEY (id_procedimiento) REFERENCES hospitales_occidente.procedimiento_quirurgico(id_procedimiento) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: tarifa_servicio fk_tarserv_hospital; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tarifa_servicio
    ADD CONSTRAINT fk_tarserv_hospital FOREIGN KEY (id_hospital) REFERENCES hospitales_occidente.hospital(id_hospital) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tarifa_servicio fk_tarserv_servicio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.tarifa_servicio
    ADD CONSTRAINT fk_tarserv_servicio FOREIGN KEY (id_servicio) REFERENCES hospitales_occidente.servicio_medico(id_servicio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado fk_traslado_encargado; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.traslado
    ADD CONSTRAINT fk_traslado_encargado FOREIGN KEY (id_paciente_encargado) REFERENCES hospitales_occidente.paciente_encargado(id_paciente_encargado) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado fk_traslado_episodio; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.traslado
    ADD CONSTRAINT fk_traslado_episodio FOREIGN KEY (id_episodio) REFERENCES hospitales_occidente.episodio(id_episodio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado fk_traslado_hosp_destino; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.traslado
    ADD CONSTRAINT fk_traslado_hosp_destino FOREIGN KEY (id_hospital_destino) REFERENCES hospitales_occidente.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado fk_traslado_hosp_origen; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.traslado
    ADD CONSTRAINT fk_traslado_hosp_origen FOREIGN KEY (id_hospital_origen) REFERENCES hospitales_occidente.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado fk_traslado_ingreso_destino; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.traslado
    ADD CONSTRAINT fk_traslado_ingreso_destino FOREIGN KEY (id_ingreso_destino) REFERENCES hospitales_occidente.ingreso(id_ingreso) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: traslado fk_traslado_medico; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.traslado
    ADD CONSTRAINT fk_traslado_medico FOREIGN KEY (id_medico_indica) REFERENCES hospitales_occidente.medico(id_personal) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado fk_traslado_serv_destino; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.traslado
    ADD CONSTRAINT fk_traslado_serv_destino FOREIGN KEY (id_servicio_destino) REFERENCES hospitales_occidente.servicio_medico(id_servicio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado fk_traslado_serv_origen; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.traslado
    ADD CONSTRAINT fk_traslado_serv_origen FOREIGN KEY (id_servicio_origen) REFERENCES hospitales_occidente.servicio_medico(id_servicio) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado fk_traslado_tipo_destino; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.traslado
    ADD CONSTRAINT fk_traslado_tipo_destino FOREIGN KEY (id_tipo_unidad_destino) REFERENCES hospitales_occidente.tipo_unidad(id_tipo_unidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: traslado fk_traslado_tipo_origen; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.traslado
    ADD CONSTRAINT fk_traslado_tipo_origen FOREIGN KEY (id_tipo_unidad_origen) REFERENCES hospitales_occidente.tipo_unidad(id_tipo_unidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: unidad_hospital fk_unidad_hospital; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.unidad_hospital
    ADD CONSTRAINT fk_unidad_hospital FOREIGN KEY (id_hospital) REFERENCES hospitales_occidente.hospital(id_hospital) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: unidad_hospital fk_unidad_tipo; Type: FK CONSTRAINT; Schema: hospitales_occidente; Owner: user1
--

ALTER TABLE ONLY hospitales_occidente.unidad_hospital
    ADD CONSTRAINT fk_unidad_tipo FOREIGN KEY (id_tipo_unidad) REFERENCES hospitales_occidente.tipo_unidad(id_tipo_unidad) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia fk_norm_cirugia_cirujano; Type: FK CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.cirugia
    ADD CONSTRAINT fk_norm_cirugia_cirujano FOREIGN KEY (id_cirujano) REFERENCES normalizacion_cirugia.cirujano(id_cirujano) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia fk_norm_cirugia_diagnostico; Type: FK CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.cirugia
    ADD CONSTRAINT fk_norm_cirugia_diagnostico FOREIGN KEY (id_diagnostico) REFERENCES normalizacion_cirugia.diagnostico(id_diagnostico) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia fk_norm_cirugia_paciente; Type: FK CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.cirugia
    ADD CONSTRAINT fk_norm_cirugia_paciente FOREIGN KEY (id_paciente) REFERENCES normalizacion_cirugia.paciente(id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cirugia_insumo fk_norm_det_cirugia; Type: FK CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.cirugia_insumo
    ADD CONSTRAINT fk_norm_det_cirugia FOREIGN KEY (id_cirugia) REFERENCES normalizacion_cirugia.cirugia(id_cirugia) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cirugia_insumo fk_norm_det_insumo; Type: FK CONSTRAINT; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

ALTER TABLE ONLY normalizacion_cirugia.cirugia_insumo
    ADD CONSTRAINT fk_norm_det_insumo FOREIGN KEY (id_insumo) REFERENCES normalizacion_cirugia.insumo(id_insumo) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA hospitales_occidente; Type: ACL; Schema: -; Owner: user1
--

GRANT ALL ON SCHEMA hospitales_occidente TO rol_admin_hospital;
GRANT USAGE ON SCHEMA hospitales_occidente TO rol_auditor_consulta;
GRANT USAGE ON SCHEMA hospitales_occidente TO rol_medico_asistencial;
GRANT USAGE ON SCHEMA hospitales_occidente TO rol_caja_facturacion;


--
-- Name: SCHEMA normalizacion_cirugia; Type: ACL; Schema: -; Owner: usr_admin_occidente
--

GRANT USAGE ON SCHEMA normalizacion_cirugia TO rol_auditor_consulta;


--
-- Name: FUNCTION fn_auditoria_personal_medico(); Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON FUNCTION hospitales_occidente.fn_auditoria_personal_medico() TO rol_admin_hospital;


--
-- Name: FUNCTION fn_check_coherencia_paciente_consulta(); Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON FUNCTION hospitales_occidente.fn_check_coherencia_paciente_consulta() TO rol_admin_hospital;


--
-- Name: FUNCTION fn_check_cuota_pago(); Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON FUNCTION hospitales_occidente.fn_check_cuota_pago() TO rol_admin_hospital;


--
-- Name: FUNCTION fn_check_cuotas_factura(); Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON FUNCTION hospitales_occidente.fn_check_cuotas_factura() TO rol_admin_hospital;


--
-- Name: FUNCTION fn_check_fecha_egreso(); Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON FUNCTION hospitales_occidente.fn_check_fecha_egreso() TO rol_admin_hospital;


--
-- Name: FUNCTION fn_check_limite_quirofanos(); Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON FUNCTION hospitales_occidente.fn_check_limite_quirofanos() TO rol_admin_hospital;


--
-- Name: FUNCTION fn_check_persona_fecha_nacimiento(); Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON FUNCTION hospitales_occidente.fn_check_persona_fecha_nacimiento() TO rol_admin_hospital;


--
-- Name: FUNCTION fn_check_rol_equipo_quirurgico(); Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON FUNCTION hospitales_occidente.fn_check_rol_equipo_quirurgico() TO rol_admin_hospital;


--
-- Name: FUNCTION fn_check_unidad_hospital_interno(); Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON FUNCTION hospitales_occidente.fn_check_unidad_hospital_interno() TO rol_admin_hospital;


--
-- Name: TABLE asignacion_personal; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.asignacion_personal TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.asignacion_personal TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.asignacion_personal TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.asignacion_personal TO rol_caja_facturacion;


--
-- Name: SEQUENCE asignacion_personal_id_asignacion_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.asignacion_personal_id_asignacion_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.asignacion_personal_id_asignacion_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.asignacion_personal_id_asignacion_seq TO rol_caja_facturacion;


--
-- Name: TABLE bitacora_auditoria_personal; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.bitacora_auditoria_personal TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.bitacora_auditoria_personal TO rol_auditor_consulta;


--
-- Name: SEQUENCE bitacora_auditoria_personal_id_auditoria_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.bitacora_auditoria_personal_id_auditoria_seq TO rol_admin_hospital;


--
-- Name: TABLE calificacion_hospital; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.calificacion_hospital TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.calificacion_hospital TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.calificacion_hospital TO rol_medico_asistencial;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.calificacion_hospital TO rol_caja_facturacion;


--
-- Name: SEQUENCE calificacion_hospital_id_calificacion_hospital_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.calificacion_hospital_id_calificacion_hospital_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.calificacion_hospital_id_calificacion_hospital_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.calificacion_hospital_id_calificacion_hospital_seq TO rol_caja_facturacion;


--
-- Name: TABLE calificacion_personal; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.calificacion_personal TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.calificacion_personal TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.calificacion_personal TO rol_medico_asistencial;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.calificacion_personal TO rol_caja_facturacion;


--
-- Name: SEQUENCE calificacion_personal_id_calificacion_personal_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.calificacion_personal_id_calificacion_personal_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.calificacion_personal_id_calificacion_personal_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.calificacion_personal_id_calificacion_personal_seq TO rol_caja_facturacion;


--
-- Name: TABLE cirugia; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.cirugia TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.cirugia TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.cirugia TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.cirugia TO rol_caja_facturacion;


--
-- Name: TABLE cirugia_documento_fase; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.cirugia_documento_fase TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.cirugia_documento_fase TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.cirugia_documento_fase TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.cirugia_documento_fase TO rol_caja_facturacion;


--
-- Name: SEQUENCE cirugia_documento_fase_id_documento_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.cirugia_documento_fase_id_documento_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.cirugia_documento_fase_id_documento_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.cirugia_documento_fase_id_documento_seq TO rol_caja_facturacion;


--
-- Name: TABLE cirugia_equipo_medico; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.cirugia_equipo_medico TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.cirugia_equipo_medico TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.cirugia_equipo_medico TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.cirugia_equipo_medico TO rol_caja_facturacion;


--
-- Name: SEQUENCE cirugia_id_cirugia_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.cirugia_id_cirugia_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.cirugia_id_cirugia_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.cirugia_id_cirugia_seq TO rol_caja_facturacion;


--
-- Name: TABLE cirugia_verificacion; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.cirugia_verificacion TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.cirugia_verificacion TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.cirugia_verificacion TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.cirugia_verificacion TO rol_caja_facturacion;


--
-- Name: SEQUENCE cirugia_verificacion_id_verificacion_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.cirugia_verificacion_id_verificacion_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.cirugia_verificacion_id_verificacion_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.cirugia_verificacion_id_verificacion_seq TO rol_caja_facturacion;


--
-- Name: TABLE cita; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.cita TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.cita TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.cita TO rol_medico_asistencial;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.cita TO rol_caja_facturacion;


--
-- Name: SEQUENCE cita_id_cita_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.cita_id_cita_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.cita_id_cita_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.cita_id_cita_seq TO rol_caja_facturacion;


--
-- Name: TABLE clinica; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.clinica TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.clinica TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.clinica TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.clinica TO rol_caja_facturacion;


--
-- Name: SEQUENCE clinica_id_clinica_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.clinica_id_clinica_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.clinica_id_clinica_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.clinica_id_clinica_seq TO rol_caja_facturacion;


--
-- Name: TABLE consentimiento_informado; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.consentimiento_informado TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.consentimiento_informado TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.consentimiento_informado TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.consentimiento_informado TO rol_caja_facturacion;


--
-- Name: SEQUENCE consentimiento_informado_id_consentimiento_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.consentimiento_informado_id_consentimiento_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.consentimiento_informado_id_consentimiento_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.consentimiento_informado_id_consentimiento_seq TO rol_caja_facturacion;


--
-- Name: TABLE consulta; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.consulta TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.consulta TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.consulta TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.consulta TO rol_caja_facturacion;


--
-- Name: SEQUENCE consulta_id_consulta_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.consulta_id_consulta_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.consulta_id_consulta_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.consulta_id_consulta_seq TO rol_caja_facturacion;


--
-- Name: TABLE consumo_insumo; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.consumo_insumo TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.consumo_insumo TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.consumo_insumo TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.consumo_insumo TO rol_caja_facturacion;


--
-- Name: SEQUENCE consumo_insumo_id_consumo_insumo_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.consumo_insumo_id_consumo_insumo_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.consumo_insumo_id_consumo_insumo_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.consumo_insumo_id_consumo_insumo_seq TO rol_caja_facturacion;


--
-- Name: TABLE departamento; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.departamento TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.departamento TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.departamento TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.departamento TO rol_caja_facturacion;


--
-- Name: SEQUENCE departamento_id_departamento_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.departamento_id_departamento_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.departamento_id_departamento_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.departamento_id_departamento_seq TO rol_caja_facturacion;


--
-- Name: TABLE diagnostico; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.diagnostico TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.diagnostico TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.diagnostico TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.diagnostico TO rol_caja_facturacion;


--
-- Name: SEQUENCE diagnostico_id_diagnostico_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.diagnostico_id_diagnostico_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.diagnostico_id_diagnostico_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.diagnostico_id_diagnostico_seq TO rol_caja_facturacion;


--
-- Name: TABLE direccion; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.direccion TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.direccion TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.direccion TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.direccion TO rol_caja_facturacion;


--
-- Name: SEQUENCE direccion_id_direccion_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.direccion_id_direccion_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.direccion_id_direccion_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.direccion_id_direccion_seq TO rol_caja_facturacion;


--
-- Name: TABLE egreso; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.egreso TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.egreso TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.egreso TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.egreso TO rol_caja_facturacion;


--
-- Name: TABLE egreso_diagnostico_secundario; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.egreso_diagnostico_secundario TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.egreso_diagnostico_secundario TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.egreso_diagnostico_secundario TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.egreso_diagnostico_secundario TO rol_caja_facturacion;


--
-- Name: SEQUENCE egreso_id_egreso_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.egreso_id_egreso_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.egreso_id_egreso_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.egreso_id_egreso_seq TO rol_caja_facturacion;


--
-- Name: TABLE enfermero; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.enfermero TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.enfermero TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.enfermero TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.enfermero TO rol_caja_facturacion;


--
-- Name: TABLE episodio; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.episodio TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.episodio TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.episodio TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.episodio TO rol_caja_facturacion;


--
-- Name: SEQUENCE episodio_id_episodio_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.episodio_id_episodio_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.episodio_id_episodio_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.episodio_id_episodio_seq TO rol_caja_facturacion;


--
-- Name: TABLE equipo; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.equipo TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.equipo TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.equipo TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.equipo TO rol_caja_facturacion;


--
-- Name: SEQUENCE equipo_id_equipo_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.equipo_id_equipo_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.equipo_id_equipo_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.equipo_id_equipo_seq TO rol_caja_facturacion;


--
-- Name: TABLE espacio_atencion; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.espacio_atencion TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.espacio_atencion TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.espacio_atencion TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.espacio_atencion TO rol_caja_facturacion;


--
-- Name: SEQUENCE espacio_atencion_id_espacio_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.espacio_atencion_id_espacio_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.espacio_atencion_id_espacio_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.espacio_atencion_id_espacio_seq TO rol_caja_facturacion;


--
-- Name: TABLE especialidad; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.especialidad TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.especialidad TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.especialidad TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.especialidad TO rol_caja_facturacion;


--
-- Name: SEQUENCE especialidad_id_especialidad_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.especialidad_id_especialidad_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.especialidad_id_especialidad_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.especialidad_id_especialidad_seq TO rol_caja_facturacion;


--
-- Name: TABLE evaluacion_preanestesica; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.evaluacion_preanestesica TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.evaluacion_preanestesica TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.evaluacion_preanestesica TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.evaluacion_preanestesica TO rol_caja_facturacion;


--
-- Name: SEQUENCE evaluacion_preanestesica_id_evaluacion_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.evaluacion_preanestesica_id_evaluacion_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.evaluacion_preanestesica_id_evaluacion_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.evaluacion_preanestesica_id_evaluacion_seq TO rol_caja_facturacion;


--
-- Name: TABLE examen_laboratorio; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.examen_laboratorio TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.examen_laboratorio TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.examen_laboratorio TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.examen_laboratorio TO rol_caja_facturacion;


--
-- Name: SEQUENCE examen_laboratorio_id_examen_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.examen_laboratorio_id_examen_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.examen_laboratorio_id_examen_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.examen_laboratorio_id_examen_seq TO rol_caja_facturacion;


--
-- Name: TABLE factura; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.factura TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.factura TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.factura TO rol_medico_asistencial;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.factura TO rol_caja_facturacion;


--
-- Name: TABLE factura_detalle; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.factura_detalle TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.factura_detalle TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.factura_detalle TO rol_medico_asistencial;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.factura_detalle TO rol_caja_facturacion;


--
-- Name: SEQUENCE factura_detalle_id_factura_detalle_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.factura_detalle_id_factura_detalle_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.factura_detalle_id_factura_detalle_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.factura_detalle_id_factura_detalle_seq TO rol_caja_facturacion;


--
-- Name: SEQUENCE factura_id_factura_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.factura_id_factura_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.factura_id_factura_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.factura_id_factura_seq TO rol_caja_facturacion;


--
-- Name: TABLE historia_clinica; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.historia_clinica TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.historia_clinica TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.historia_clinica TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.historia_clinica TO rol_caja_facturacion;


--
-- Name: SEQUENCE historia_clinica_id_historia_clinica_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.historia_clinica_id_historia_clinica_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.historia_clinica_id_historia_clinica_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.historia_clinica_id_historia_clinica_seq TO rol_caja_facturacion;


--
-- Name: TABLE horario_medico; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.horario_medico TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.horario_medico TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.horario_medico TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.horario_medico TO rol_caja_facturacion;


--
-- Name: SEQUENCE horario_medico_id_horario_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.horario_medico_id_horario_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.horario_medico_id_horario_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.horario_medico_id_horario_seq TO rol_caja_facturacion;


--
-- Name: TABLE hospital; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.hospital TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.hospital TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.hospital TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.hospital TO rol_caja_facturacion;


--
-- Name: SEQUENCE hospital_id_hospital_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.hospital_id_hospital_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.hospital_id_hospital_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.hospital_id_hospital_seq TO rol_caja_facturacion;


--
-- Name: TABLE ingreso; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.ingreso TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.ingreso TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.ingreso TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.ingreso TO rol_caja_facturacion;


--
-- Name: SEQUENCE ingreso_id_ingreso_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.ingreso_id_ingreso_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.ingreso_id_ingreso_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.ingreso_id_ingreso_seq TO rol_caja_facturacion;


--
-- Name: TABLE instrumento; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.instrumento TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.instrumento TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.instrumento TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.instrumento TO rol_caja_facturacion;


--
-- Name: SEQUENCE instrumento_id_instrumento_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.instrumento_id_instrumento_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.instrumento_id_instrumento_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.instrumento_id_instrumento_seq TO rol_caja_facturacion;


--
-- Name: TABLE insumo; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.insumo TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.insumo TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.insumo TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.insumo TO rol_caja_facturacion;


--
-- Name: SEQUENCE insumo_id_insumo_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.insumo_id_insumo_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.insumo_id_insumo_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.insumo_id_insumo_seq TO rol_caja_facturacion;


--
-- Name: TABLE item_verificacion; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.item_verificacion TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.item_verificacion TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.item_verificacion TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.item_verificacion TO rol_caja_facturacion;


--
-- Name: SEQUENCE item_verificacion_id_item_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.item_verificacion_id_item_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.item_verificacion_id_item_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.item_verificacion_id_item_seq TO rol_caja_facturacion;


--
-- Name: TABLE medicamento; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.medicamento TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.medicamento TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.medicamento TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.medicamento TO rol_caja_facturacion;


--
-- Name: SEQUENCE medicamento_id_medicamento_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.medicamento_id_medicamento_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.medicamento_id_medicamento_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.medicamento_id_medicamento_seq TO rol_caja_facturacion;


--
-- Name: TABLE medico; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.medico TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.medico TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.medico TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.medico TO rol_caja_facturacion;


--
-- Name: TABLE medico_especialidad; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.medico_especialidad TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.medico_especialidad TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.medico_especialidad TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.medico_especialidad TO rol_caja_facturacion;


--
-- Name: TABLE metodo_pago; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.metodo_pago TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.metodo_pago TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.metodo_pago TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.metodo_pago TO rol_caja_facturacion;


--
-- Name: SEQUENCE metodo_pago_id_metodo_pago_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.metodo_pago_id_metodo_pago_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.metodo_pago_id_metodo_pago_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.metodo_pago_id_metodo_pago_seq TO rol_caja_facturacion;


--
-- Name: TABLE momento_quirurgico; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.momento_quirurgico TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.momento_quirurgico TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.momento_quirurgico TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.momento_quirurgico TO rol_caja_facturacion;


--
-- Name: SEQUENCE momento_quirurgico_id_momento_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.momento_quirurgico_id_momento_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.momento_quirurgico_id_momento_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.momento_quirurgico_id_momento_seq TO rol_caja_facturacion;


--
-- Name: TABLE municipio; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.municipio TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.municipio TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.municipio TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.municipio TO rol_caja_facturacion;


--
-- Name: SEQUENCE municipio_id_municipio_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.municipio_id_municipio_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.municipio_id_municipio_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.municipio_id_municipio_seq TO rol_caja_facturacion;


--
-- Name: TABLE orden_laboratorio; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.orden_laboratorio TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.orden_laboratorio TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.orden_laboratorio TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.orden_laboratorio TO rol_caja_facturacion;


--
-- Name: TABLE orden_laboratorio_detalle; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.orden_laboratorio_detalle TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.orden_laboratorio_detalle TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.orden_laboratorio_detalle TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.orden_laboratorio_detalle TO rol_caja_facturacion;


--
-- Name: SEQUENCE orden_laboratorio_id_orden_laboratorio_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.orden_laboratorio_id_orden_laboratorio_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.orden_laboratorio_id_orden_laboratorio_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.orden_laboratorio_id_orden_laboratorio_seq TO rol_caja_facturacion;


--
-- Name: TABLE paciente; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.paciente TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.paciente TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.paciente TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.paciente TO rol_caja_facturacion;


--
-- Name: TABLE paciente_encargado; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.paciente_encargado TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.paciente_encargado TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.paciente_encargado TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.paciente_encargado TO rol_caja_facturacion;


--
-- Name: SEQUENCE paciente_encargado_id_paciente_encargado_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.paciente_encargado_id_paciente_encargado_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.paciente_encargado_id_paciente_encargado_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.paciente_encargado_id_paciente_encargado_seq TO rol_caja_facturacion;


--
-- Name: SEQUENCE paciente_id_paciente_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.paciente_id_paciente_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.paciente_id_paciente_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.paciente_id_paciente_seq TO rol_caja_facturacion;


--
-- Name: TABLE pago; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.pago TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.pago TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.pago TO rol_medico_asistencial;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.pago TO rol_caja_facturacion;


--
-- Name: SEQUENCE pago_id_pago_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.pago_id_pago_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.pago_id_pago_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.pago_id_pago_seq TO rol_caja_facturacion;


--
-- Name: TABLE parentesco; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.parentesco TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.parentesco TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.parentesco TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.parentesco TO rol_caja_facturacion;


--
-- Name: SEQUENCE parentesco_id_parentesco_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.parentesco_id_parentesco_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.parentesco_id_parentesco_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.parentesco_id_parentesco_seq TO rol_caja_facturacion;


--
-- Name: TABLE persona; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.persona TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.persona TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.persona TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.persona TO rol_caja_facturacion;


--
-- Name: SEQUENCE persona_id_persona_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.persona_id_persona_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.persona_id_persona_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.persona_id_persona_seq TO rol_caja_facturacion;


--
-- Name: TABLE personal; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.personal TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.personal TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.personal TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.personal TO rol_caja_facturacion;


--
-- Name: SEQUENCE personal_id_personal_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.personal_id_personal_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.personal_id_personal_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.personal_id_personal_seq TO rol_caja_facturacion;


--
-- Name: TABLE procedimiento_quirurgico; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.procedimiento_quirurgico TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.procedimiento_quirurgico TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.procedimiento_quirurgico TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.procedimiento_quirurgico TO rol_caja_facturacion;


--
-- Name: SEQUENCE procedimiento_quirurgico_id_procedimiento_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.procedimiento_quirurgico_id_procedimiento_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.procedimiento_quirurgico_id_procedimiento_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.procedimiento_quirurgico_id_procedimiento_seq TO rol_caja_facturacion;


--
-- Name: TABLE receta; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.receta TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.receta TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.receta TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.receta TO rol_caja_facturacion;


--
-- Name: TABLE receta_detalle; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.receta_detalle TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.receta_detalle TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.receta_detalle TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.receta_detalle TO rol_caja_facturacion;


--
-- Name: SEQUENCE receta_detalle_id_receta_detalle_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.receta_detalle_id_receta_detalle_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.receta_detalle_id_receta_detalle_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.receta_detalle_id_receta_detalle_seq TO rol_caja_facturacion;


--
-- Name: SEQUENCE receta_id_receta_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.receta_id_receta_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.receta_id_receta_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.receta_id_receta_seq TO rol_caja_facturacion;


--
-- Name: TABLE registro_signos_vitales; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.registro_signos_vitales TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.registro_signos_vitales TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.registro_signos_vitales TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.registro_signos_vitales TO rol_caja_facturacion;


--
-- Name: SEQUENCE registro_signos_vitales_id_signos_vitales_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.registro_signos_vitales_id_signos_vitales_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.registro_signos_vitales_id_signos_vitales_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.registro_signos_vitales_id_signos_vitales_seq TO rol_caja_facturacion;


--
-- Name: TABLE revision_miembro_comite; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.revision_miembro_comite TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.revision_miembro_comite TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.revision_miembro_comite TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.revision_miembro_comite TO rol_caja_facturacion;


--
-- Name: TABLE revision_solicitud; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.revision_solicitud TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.revision_solicitud TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.revision_solicitud TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.revision_solicitud TO rol_caja_facturacion;


--
-- Name: SEQUENCE revision_solicitud_id_revision_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.revision_solicitud_id_revision_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.revision_solicitud_id_revision_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.revision_solicitud_id_revision_seq TO rol_caja_facturacion;


--
-- Name: TABLE servicio_medico; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.servicio_medico TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.servicio_medico TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.servicio_medico TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.servicio_medico TO rol_caja_facturacion;


--
-- Name: SEQUENCE servicio_medico_id_servicio_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.servicio_medico_id_servicio_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.servicio_medico_id_servicio_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.servicio_medico_id_servicio_seq TO rol_caja_facturacion;


--
-- Name: TABLE solicitud_cirugia; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.solicitud_cirugia TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.solicitud_cirugia TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.solicitud_cirugia TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.solicitud_cirugia TO rol_caja_facturacion;


--
-- Name: SEQUENCE solicitud_cirugia_id_solicitud_cirugia_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.solicitud_cirugia_id_solicitud_cirugia_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.solicitud_cirugia_id_solicitud_cirugia_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.solicitud_cirugia_id_solicitud_cirugia_seq TO rol_caja_facturacion;


--
-- Name: TABLE solicitud_equipo; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.solicitud_equipo TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.solicitud_equipo TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.solicitud_equipo TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.solicitud_equipo TO rol_caja_facturacion;


--
-- Name: TABLE solicitud_instrumento; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.solicitud_instrumento TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.solicitud_instrumento TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.solicitud_instrumento TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.solicitud_instrumento TO rol_caja_facturacion;


--
-- Name: TABLE solicitud_insumo; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.solicitud_insumo TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.solicitud_insumo TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.solicitud_insumo TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.solicitud_insumo TO rol_caja_facturacion;


--
-- Name: TABLE solicitud_procedimiento; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.solicitud_procedimiento TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.solicitud_procedimiento TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.solicitud_procedimiento TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.solicitud_procedimiento TO rol_caja_facturacion;


--
-- Name: TABLE tarifa_insumo; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.tarifa_insumo TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.tarifa_insumo TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.tarifa_insumo TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.tarifa_insumo TO rol_caja_facturacion;


--
-- Name: TABLE tarifa_procedimiento; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.tarifa_procedimiento TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.tarifa_procedimiento TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.tarifa_procedimiento TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.tarifa_procedimiento TO rol_caja_facturacion;


--
-- Name: TABLE tarifa_servicio; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.tarifa_servicio TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.tarifa_servicio TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.tarifa_servicio TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.tarifa_servicio TO rol_caja_facturacion;


--
-- Name: TABLE tipo_anestesia; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.tipo_anestesia TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.tipo_anestesia TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.tipo_anestesia TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.tipo_anestesia TO rol_caja_facturacion;


--
-- Name: SEQUENCE tipo_anestesia_id_tipo_anestesia_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.tipo_anestesia_id_tipo_anestesia_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.tipo_anestesia_id_tipo_anestesia_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.tipo_anestesia_id_tipo_anestesia_seq TO rol_caja_facturacion;


--
-- Name: TABLE tipo_unidad; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.tipo_unidad TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.tipo_unidad TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.tipo_unidad TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.tipo_unidad TO rol_caja_facturacion;


--
-- Name: SEQUENCE tipo_unidad_id_tipo_unidad_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.tipo_unidad_id_tipo_unidad_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.tipo_unidad_id_tipo_unidad_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.tipo_unidad_id_tipo_unidad_seq TO rol_caja_facturacion;


--
-- Name: TABLE traslado; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.traslado TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.traslado TO rol_auditor_consulta;
GRANT SELECT,INSERT,UPDATE ON TABLE hospitales_occidente.traslado TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.traslado TO rol_caja_facturacion;


--
-- Name: SEQUENCE traslado_id_traslado_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.traslado_id_traslado_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.traslado_id_traslado_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.traslado_id_traslado_seq TO rol_caja_facturacion;


--
-- Name: TABLE turno; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.turno TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.turno TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.turno TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.turno TO rol_caja_facturacion;


--
-- Name: SEQUENCE turno_id_turno_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.turno_id_turno_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.turno_id_turno_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.turno_id_turno_seq TO rol_caja_facturacion;


--
-- Name: TABLE unidad_hospital; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.unidad_hospital TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.unidad_hospital TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.unidad_hospital TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.unidad_hospital TO rol_caja_facturacion;


--
-- Name: SEQUENCE unidad_hospital_id_unidad_hospital_seq; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON SEQUENCE hospitales_occidente.unidad_hospital_id_unidad_hospital_seq TO rol_admin_hospital;
GRANT USAGE ON SEQUENCE hospitales_occidente.unidad_hospital_id_unidad_hospital_seq TO rol_medico_asistencial;
GRANT USAGE ON SEQUENCE hospitales_occidente.unidad_hospital_id_unidad_hospital_seq TO rol_caja_facturacion;


--
-- Name: TABLE vw_calificacion_resumen_hospital; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.vw_calificacion_resumen_hospital TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.vw_calificacion_resumen_hospital TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.vw_calificacion_resumen_hospital TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.vw_calificacion_resumen_hospital TO rol_caja_facturacion;


--
-- Name: TABLE vw_cirugias_rechazadas; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.vw_cirugias_rechazadas TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.vw_cirugias_rechazadas TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.vw_cirugias_rechazadas TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.vw_cirugias_rechazadas TO rol_caja_facturacion;


--
-- Name: TABLE vw_egreso_dias; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.vw_egreso_dias TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.vw_egreso_dias TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.vw_egreso_dias TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.vw_egreso_dias TO rol_caja_facturacion;


--
-- Name: TABLE vw_factura_resumen; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.vw_factura_resumen TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.vw_factura_resumen TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.vw_factura_resumen TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.vw_factura_resumen TO rol_caja_facturacion;


--
-- Name: TABLE vw_paciente; Type: ACL; Schema: hospitales_occidente; Owner: user1
--

GRANT ALL ON TABLE hospitales_occidente.vw_paciente TO rol_admin_hospital;
GRANT SELECT ON TABLE hospitales_occidente.vw_paciente TO rol_auditor_consulta;
GRANT SELECT ON TABLE hospitales_occidente.vw_paciente TO rol_medico_asistencial;
GRANT SELECT ON TABLE hospitales_occidente.vw_paciente TO rol_caja_facturacion;


--
-- Name: TABLE cirugia; Type: ACL; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

GRANT SELECT ON TABLE normalizacion_cirugia.cirugia TO rol_auditor_consulta;


--
-- Name: TABLE cirugia_insumo; Type: ACL; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

GRANT SELECT ON TABLE normalizacion_cirugia.cirugia_insumo TO rol_auditor_consulta;


--
-- Name: TABLE cirujano; Type: ACL; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

GRANT SELECT ON TABLE normalizacion_cirugia.cirujano TO rol_auditor_consulta;


--
-- Name: TABLE diagnostico; Type: ACL; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

GRANT SELECT ON TABLE normalizacion_cirugia.diagnostico TO rol_auditor_consulta;


--
-- Name: TABLE insumo; Type: ACL; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

GRANT SELECT ON TABLE normalizacion_cirugia.insumo TO rol_auditor_consulta;


--
-- Name: TABLE paciente; Type: ACL; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

GRANT SELECT ON TABLE normalizacion_cirugia.paciente TO rol_auditor_consulta;


--
-- Name: TABLE vista_reporte_cirugia; Type: ACL; Schema: normalizacion_cirugia; Owner: usr_admin_occidente
--

GRANT SELECT ON TABLE normalizacion_cirugia.vista_reporte_cirugia TO rol_auditor_consulta;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: hospitales_occidente; Owner: user1
--

ALTER DEFAULT PRIVILEGES FOR ROLE user1 IN SCHEMA hospitales_occidente GRANT ALL ON SEQUENCES TO rol_admin_hospital;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: hospitales_occidente; Owner: user1
--

ALTER DEFAULT PRIVILEGES FOR ROLE user1 IN SCHEMA hospitales_occidente GRANT ALL ON FUNCTIONS TO rol_admin_hospital;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: hospitales_occidente; Owner: user1
--

ALTER DEFAULT PRIVILEGES FOR ROLE user1 IN SCHEMA hospitales_occidente GRANT ALL ON TABLES TO rol_admin_hospital;
ALTER DEFAULT PRIVILEGES FOR ROLE user1 IN SCHEMA hospitales_occidente GRANT SELECT ON TABLES TO rol_auditor_consulta;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: normalizacion_cirugia; Owner: user1
--

ALTER DEFAULT PRIVILEGES FOR ROLE user1 IN SCHEMA normalizacion_cirugia GRANT SELECT ON TABLES TO rol_auditor_consulta;


--
-- PostgreSQL database dump complete
--

\unrestrict c0BWJ1Sj1M97iqjgCHrUiN6P5y6JpSPc2hcHCXKnqyrOfTduUyevmYIpVoaJtuY


-- ============================================================================
-- AJUSTES DE AMBIENTE INSTITUCIONAL Y SEARCH_PATH POR DEFECTO
-- ============================================================================
ALTER DATABASE hospital_occidente SET search_path TO hospitales_occidente, public;
ALTER ROLE rol_admin_hospital SET search_path TO hospitales_occidente, public;
ALTER ROLE rol_auditor_consulta SET search_path TO hospitales_occidente, public;
ALTER ROLE rol_medico_asistencial SET search_path TO hospitales_occidente, public;
ALTER ROLE rol_caja_facturacion SET search_path TO hospitales_occidente, public;
ALTER ROLE usr_admin_occidente SET search_path TO hospitales_occidente, public;
ALTER ROLE usr_auditor_occidente SET search_path TO hospitales_occidente, public;
ALTER ROLE usr_medico_occidente SET search_path TO hospitales_occidente, public;
ALTER ROLE usr_caja_occidente SET search_path TO hospitales_occidente, public;
ALTER ROLE user1 SET search_path TO hospitales_occidente, public;
GRANT CREATE ON DATABASE hospital_occidente TO rol_admin_hospital;
