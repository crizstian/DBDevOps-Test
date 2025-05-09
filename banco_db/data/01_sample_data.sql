
-- Inserción de datos de prueba
INSERT INTO clientes (nombre, apellido, dni, fecha_nacimiento, email, telefono, direccion)
VALUES 
    ('Juan', 'Pérez', '12345678', '1990-05-15', 'juan.perez@email.com', '555-0101', 'Calle 123'),
    ('María', 'González', '87654321', '1985-08-22', 'maria.gz@email.com', '555-0102', 'Avenida 456'),
    ('Carlos', 'Rodríguez', '11223344', '1995-03-10', 'carlos.rod@email.com', '555-0103', 'Plaza 789');

INSERT INTO cuentas (cliente_id, tipo_cuenta, numero_cuenta, saldo)
VALUES 
    (1, 'AHORRO', '1001-2345-6789', 5000.00),
    (1, 'CORRIENTE', '1001-2345-6790', 15000.00),
    (2, 'AHORRO', '1001-2345-6791', 8000.00),
    (3, 'CORRIENTE', '1001-2345-6792', 12000.00);

INSERT INTO transacciones (cuenta_origen, cuenta_destino, tipo_transaccion, monto, descripcion)
VALUES 
    (1, 2, 'TRANSFERENCIA', 1000.00, 'Pago de servicios'),
    (2, 3, 'TRANSFERENCIA', 2500.00, 'Pago de alquiler'),
    (4, 1, 'TRANSFERENCIA', 800.00, 'Devolución préstamo');

