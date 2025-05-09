
-- Procedimientos para clientes V3 (con más funcionalidades y logging)
CREATE TABLE IF NOT EXISTS audit_log (
    log_id SERIAL PRIMARY KEY,
    tabla VARCHAR(50),
    operacion VARCHAR(20),
    usuario VARCHAR(50),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    detalles JSON
);

CREATE OR REPLACE PROCEDURE crear_cliente(
    p_nombre VARCHAR,
    p_apellido VARCHAR,
    p_dni VARCHAR,
    p_fecha_nacimiento DATE,
    p_email VARCHAR,
    p_telefono VARCHAR,
    p_direccion TEXT,
    p_usuario_creacion VARCHAR
)
LANGUAGE plpgsql
AS 10799
DECLARE
    v_cliente_id INTEGER;
BEGIN
    -- Validaciones mejoradas
    IF p_fecha_nacimiento > CURRENT_DATE THEN
        RAISE EXCEPTION 'La fecha de nacimiento no puede ser futura';
    END IF;
    
    IF NOT p_email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
        RAISE EXCEPTION 'Formato de email inválido';
    END IF;

    -- Insertar cliente
    INSERT INTO clientes (nombre, apellido, dni, fecha_nacimiento, email, telefono, direccion)
    VALUES (p_nombre, p_apellido, p_dni, p_fecha_nacimiento, p_email, p_telefono, p_direccion)
    RETURNING cliente_id INTO v_cliente_id;

    -- Registrar en audit log
    INSERT INTO audit_log (tabla, operacion, usuario, detalles)
    VALUES (
        'clientes',
        'INSERT',
        p_usuario_creacion,
        json_build_object(
            'cliente_id', v_cliente_id,
            'dni', p_dni,
            'email', p_email
        )
    );
END;
10799;

CREATE OR REPLACE FUNCTION obtener_cliente(p_cliente_id INTEGER)
RETURNS TABLE (
    cliente_id INTEGER,
    nombre VARCHAR,
    apellido VARCHAR,
    dni VARCHAR,
    email VARCHAR,
    saldo_total DECIMAL(15,2),
    cantidad_cuentas INTEGER,
    ultima_transaccion TIMESTAMP
)
LANGUAGE plpgsql
AS 10799
BEGIN
    RETURN QUERY
    SELECT 
        c.cliente_id, 
        c.nombre, 
        c.apellido, 
        c.dni, 
        c.email,
        COALESCE(SUM(cu.saldo), 0.00) as saldo_total,
        COUNT(DISTINCT cu.cuenta_id) as cantidad_cuentas,
        MAX(t.fecha_transaccion) as ultima_transaccion
    FROM clientes c
    LEFT JOIN cuentas cu ON c.cliente_id = cu.cliente_id
    LEFT JOIN transacciones t ON cu.cuenta_id = t.cuenta_origen
    WHERE c.cliente_id = p_cliente_id
    GROUP BY c.cliente_id, c.nombre, c.apellido, c.dni, c.email;
END;
10799;

