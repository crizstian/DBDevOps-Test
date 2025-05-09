
-- Procedimientos para clientes V1
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
    email VARCHAR
)
LANGUAGE plpgsql
AS 10799
BEGIN
    RETURN QUERY
    SELECT c.cliente_id, c.nombre, c.apellido, c.dni, c.email
    FROM clientes c
    WHERE c.cliente_id = p_cliente_id;
END;
10799;

