-- Archivo SQL para crear la tabla de departamentos e insertar datos iniciales
-- Este archivo es leído por el changeset 1 de 01-automation-changes.yaml

-- Crear tabla de departamentos
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    budget DECIMAL(15,2) DEFAULT 0.00,
    location VARCHAR(100),
    manager_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos iniciales de departamentos
INSERT INTO departments (name, budget, location) VALUES 
('Desarrollo', 150000.00, 'Torre A, Piso 3'),
('Marketing', 75000.00, 'Torre B, Piso 2'),
('Ventas', 200000.00, 'Torre A, Piso 1'),
('Recursos Humanos', 100000.00, 'Torre B, Piso 1'),
('Finanzas', 125000.00, 'Torre A, Piso 2');

-- Crear índices para optimizar consultas
CREATE INDEX idx_departments_name ON departments(name);
CREATE INDEX idx_departments_budget ON departments(budget);

-- Agregar comentarios para documentación
COMMENT ON TABLE departments IS 'Tabla que almacena información de los departamentos de la empresa';
COMMENT ON COLUMN departments.name IS 'Nombre del departamento';
COMMENT ON COLUMN departments.budget IS 'Presupuesto anual asignado al departamento';
COMMENT ON COLUMN departments.location IS 'Ubicación física del departamento';
COMMENT ON COLUMN departments.manager_id IS 'ID del gerente del departamento (referencia a employees.id)';

-- Insertar datos adicionales para pruebas
INSERT INTO departments (name, budget, location) VALUES 
('Tecnología', 300000.00, 'Torre C, Piso 4'),
('Operaciones', 180000.00, 'Torre A, Piso 0');