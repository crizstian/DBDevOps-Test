
-- Procedimientos para clientes V2 (con validaciones adicionales)
CREATE OR REPLACE PROCEDURE crear_cliente(
    p_nombre VARCHAR,
    p_apellido VARCHAR,
    p_dni VARCHAR,
    p_fecha_nacimiento DATE,
    p_email VARCHAR,
    p_telefono VARCHAR,
    p_direccion TEXT
)
LANGUAGE plpgsql
AS 10799
BEGIN
    -- Validaciones adicionales
    IF p_fecha_nacimiento > CURRENT_DATE THEN
        RAISE EXCEPTION 'La fecha de nacimiento no puede ser futura';
    END IF;
    
    IF NOT p_email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
        RAISE EXCEPTION 'Formato de email inválido';
    END IF;

    INSERT INTO clientes (nombre, apellido, dni, fecha_nacimiento, email, telefono, direccion)
    VALUES (p_nombre, p_apellido, p_dni, p_fecha_nacimiento, p_email, p_telefono, p_direccion);
END;
10799;

CREATE OR REPLACE FUNCTION obtener_cliente(p_cliente_id INTEGER)
RETURNS TABLE (
    cliente_id INTEGER,
    nombre VARCHAR,
    apellido VARCHAR,
    dni VARCHAR,
    email VARCHAR,
    saldo_total DECIMAL(15,2)
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
        COALESCE(SUM(cu.saldo), 0.00) as saldo_total
    FROM clientes c
    LEFT JOIN cuentas cu ON c.cliente_id = cu.cliente_id
    WHERE c.cliente_id = p_cliente_id
    GROUP BY c.cliente_id, c.nombre, c.apellido, c.dni, c.email;
END;
10799;

