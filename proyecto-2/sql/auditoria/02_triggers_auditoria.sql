SET search_path TO hospitales_occidente, public;
SET timezone TO 'America/Guatemala';

-- Funcion para capturar cambios sensibles en personal y medicos
CREATE OR REPLACE FUNCTION hospitales_occidente.fn_auditoria_personal_medico()
RETURNS TRIGGER 
SET search_path = hospitales_occidente, public
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
$$ LANGUAGE plpgsql;

-- Trigger sobre tabla personal
DROP TRIGGER IF EXISTS trg_auditoria_personal ON personal;
CREATE TRIGGER trg_auditoria_personal
    AFTER UPDATE ON personal
    FOR EACH ROW
    EXECUTE FUNCTION fn_auditoria_personal_medico();

-- Trigger sobre tabla medico
DROP TRIGGER IF EXISTS trg_auditoria_medico ON medico;
CREATE TRIGGER trg_auditoria_medico
    AFTER UPDATE ON medico
    FOR EACH ROW
    EXECUTE FUNCTION fn_auditoria_personal_medico();

-- Trigger sobre tabla medico_especialidad
DROP TRIGGER IF EXISTS trg_auditoria_medico_especialidad ON medico_especialidad;
CREATE TRIGGER trg_auditoria_medico_especialidad
    AFTER INSERT OR UPDATE OR DELETE ON medico_especialidad
    FOR EACH ROW
    EXECUTE FUNCTION fn_auditoria_personal_medico();
