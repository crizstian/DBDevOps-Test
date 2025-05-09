
-- Creación de tablas base v1
CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    dni VARCHAR(20) UNIQUE NOT NULL,
    fecha_nacimiento DATE,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cuentas (
    cuenta_id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(cliente_id),
    tipo_cuenta VARCHAR(20) NOT NULL,
    numero_cuenta VARCHAR(20) UNIQUE NOT NULL,
    saldo DECIMAL(15,2) DEFAULT 0.00,
    estado VARCHAR(20) DEFAULT 'activa',
    fecha_apertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transacciones (
    transaccion_id SERIAL PRIMARY KEY,
    cuenta_origen INTEGER REFERENCES cuentas(cuenta_id),
    cuenta_destino INTEGER REFERENCES cuentas(cuenta_id),
    tipo_transaccion VARCHAR(20) NOT NULL,
    monto DECIMAL(15,2) NOT NULL,
    fecha_transaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT
);

CREATE TABLE tarjetas (
    tarjeta_id SERIAL PRIMARY KEY,
    cuenta_id INTEGER REFERENCES cuentas(cuenta_id),
    numero_tarjeta VARCHAR(16) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    cvv VARCHAR(3) NOT NULL,
    tipo_tarjeta VARCHAR(20) NOT NULL,
    estado VARCHAR(20) DEFAULT 'activa'
);

