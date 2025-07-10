-- liquibase formatted sql
-- changeset system:01-initial-setup splitStatements:true endDelimiter:;

-- =============================================================================
-- SCRIPT DE CONFIGURACIÓN INICIAL
-- Tutorial Liquibase + Harness DB DevOps
-- =============================================================================

-- Crear extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- =============================================================================
-- TABLA: change_history
-- Propósito: Rastrear todos los cambios realizados por Liquibase
-- =============================================================================

CREATE TABLE change_history (
    id SERIAL PRIMARY KEY,
    change_type VARCHAR(50) NOT NULL,
    table_affected VARCHAR(100),
    description TEXT,
    executed_by VARCHAR(100) NOT NULL,
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    rollback_sql TEXT,
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    changeset_id VARCHAR(100),
    changeset_author VARCHAR(100)
);

-- Índices para optimización
CREATE INDEX idx_change_history_type ON change_history(change_type);
CREATE INDEX idx_change_history_time ON change_history(execution_time);
CREATE INDEX idx_change_history_table ON change_history(table_affected);

-- =============================================================================
-- TABLA: application_config
-- Propósito: Configuraciones de la aplicación
-- =============================================================================

CREATE TABLE application_config (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT NOT NULL,
    description TEXT,
    is_sensitive BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(100)
);

-- =============================================================================
-- TABLA: database_versions
-- Propósito: Tracking de versiones de base de datos
-- =============================================================================

CREATE TABLE database_versions (
    id SERIAL PRIMARY KEY,
    version_number VARCHAR(50) NOT NULL,
    release_date DATE NOT NULL,
    description TEXT,
    is_current BOOLEAN DEFAULT FALSE,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    applied_by VARCHAR(100)
);

-- =============================================================================
-- FUNCIÓN: update_timestamp
-- Propósito: Actualizar automáticamente campos de timestamp
-- =============================================================================

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- FUNCIÓN: log_change
-- Propósito: Registrar cambios en la tabla change_history
-- =============================================================================

CREATE OR REPLACE FUNCTION log_change(
    p_change_type VARCHAR(50),
    p_table_affected VARCHAR(100),
    p_description TEXT,
    p_executed_by VARCHAR(100) DEFAULT 'system'
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO change_history (change_type, table_affected, description, executed_by)
    VALUES (p_change_type, p_table_affected, p_description, p_executed_by);
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- CONFIGURACIONES INICIALES
-- =============================================================================

-- Insertar configuraciones base
INSERT INTO application_config (config_key, config_value, description, is_sensitive) VALUES
('app_name', 'Tutorial Liquibase', 'Nombre de la aplicación', FALSE),
('app_version', '1.0.0', 'Versión actual de la aplicación', FALSE),
('environment', 'development', 'Entorno actual', FALSE),
('max_connections', '100', 'Máximo número de conexiones', FALSE),
('backup_retention_days', '30', 'Días de retención de backups', FALSE),
('log_level', 'INFO', 'Nivel de logging', FALSE),
('enable_audit', 'true', 'Habilitar auditoría', FALSE),
('database_timezone', 'UTC', 'Zona horaria de la base de datos', FALSE);

-- Insertar versión inicial
INSERT INTO database_versions (version_number, release_date, description, is_current, applied_by)
VALUES ('1.0.0', CURRENT_DATE, 'Configuración inicial del tutorial Liquibase', TRUE, 'system');

-- =============================================================================
-- TRIGGER: application_config_update
-- Propósito: Actualizar timestamp en cambios de configuración
-- =============================================================================

CREATE TRIGGER application_config_update
    BEFORE UPDATE ON application_config
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

-- =============================================================================
-- VISTA: current_configuration
-- Propósito: Vista de configuración actual (sin datos sensibles)
-- =============================================================================

CREATE VIEW current_configuration AS
SELECT 
    config_key,
    CASE 
        WHEN is_sensitive THEN '***HIDDEN***'
        ELSE config_value
    END AS config_value,
    description,
    created_at,
    updated_at,
    updated_by
FROM application_config
ORDER BY config_key;

-- =============================================================================
-- REGISTRAR CAMBIO INICIAL
-- =============================================================================

SELECT log_change('INITIAL_SETUP', 'ALL', 'Configuración inicial de la base de datos completada', 'system');

-- =============================================================================
-- VALIDACIONES FINALES
-- =============================================================================

-- Verificar que todas las tablas fueron creadas
DO $$
DECLARE
    table_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name IN ('change_history', 'application_config', 'database_versions');
    
    IF table_count != 3 THEN
        RAISE EXCEPTION 'No se crearon todas las tablas necesarias. Esperadas: 3, Encontradas: %', table_count;
    END IF;
    
    RAISE NOTICE 'Configuración inicial completada exitosamente. Tablas creadas: %', table_count;
END $$;

-- =============================================================================
-- COMENTARIOS EN TABLAS
-- =============================================================================

COMMENT ON TABLE change_history IS 'Historial de cambios realizados por Liquibase';
COMMENT ON TABLE application_config IS 'Configuraciones de la aplicación';
COMMENT ON TABLE database_versions IS 'Versiones de la base de datos';

COMMENT ON COLUMN change_history.change_type IS 'Tipo de cambio: CREATE, ALTER, DROP, INSERT, UPDATE, DELETE';
COMMENT ON COLUMN change_history.table_affected IS 'Tabla afectada por el cambio';
COMMENT ON COLUMN change_history.description IS 'Descripción del cambio realizado';
COMMENT ON COLUMN change_history.executed_by IS 'Usuario que ejecutó el cambio';
COMMENT ON COLUMN change_history.rollback_sql IS 'SQL necesario para revertir el cambio';

COMMENT ON COLUMN application_config.is_sensitive IS 'Indica si el valor es sensible (password, etc.)';
COMMENT ON COLUMN database_versions.is_current IS 'Indica si es la versión actual';

-- rollback DROP TABLE IF EXISTS change_history CASCADE;
-- rollback DROP TABLE IF EXISTS application_config CASCADE;
-- rollback DROP TABLE IF EXISTS database_versions CASCADE;
-- rollback DROP FUNCTION IF EXISTS update_timestamp() CASCADE;
-- rollback DROP FUNCTION IF EXISTS log_change(VARCHAR, VARCHAR, TEXT, VARCHAR) CASCADE;
-- rollback DROP VIEW IF EXISTS current_configuration CASCADE;
-- rollback DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE;
-- rollback DROP EXTENSION IF EXISTS "pg_stat_statements" CASCADE;