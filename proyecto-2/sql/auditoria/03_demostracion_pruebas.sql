SET search_path TO hospitales_occidente, public;
SET timezone TO 'America/Guatemala';

-- ============================================================================
-- PRUEBA 1: Modificacion de salario en personal
-- ============================================================================
UPDATE personal
SET salario = 14500.00
WHERE id_personal = 1;


-- ============================================================================
-- PRUEBA 2: Modificacion de nivel de acceso y superior directo en medico
-- ============================================================================
UPDATE medico
SET nivel_acceso = 'Jefe de Servicio',
    id_superior = 5
WHERE id_personal = 2;


-- ============================================================================
-- PRUEBA 3: Cambio de especialidad medica
-- ============================================================================
UPDATE medico_especialidad
SET id_especialidad = 1
WHERE id_medico = 7 AND id_especialidad = 7;


-- ============================================================================
-- CONSULTA DE VERIFICACION: Registros capturados en la bitacora
-- ============================================================================
SELECT 
    id_auditoria,
    id_personal,
    tabla_afectada,
    campo_modificado,
    valor_anterior,
    valor_nuevo,
    usuario_db,
    to_char(fecha_hora, 'YYYY-MM-DD HH24:MI:SS') AS fecha_hora,
    operacion
FROM bitacora_auditoria_personal
ORDER BY id_auditoria DESC;
