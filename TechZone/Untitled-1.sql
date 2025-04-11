

CREATE TABLE productos (
id_producto SERIAL PRIMARY KEY,
nombre TEXT NOT NULL,
precio NUMERIC NOT NULL CHECK (precio >= 0),
stock INT NOT NULL DEFAULT 0,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clientes (
id SERIAL PRIMARY KEY,
nombre TEXT NOT NULL
);
CREATE TABLE categorias (
id_categoria SERIAL PRIMARY KEY,
nombre TEXT NOT NULL
);

ALTER TABLE productos
ADD COLUMN id_categoria INT REFERENCES categorias(id_categoria);

CREATE TABLE ventas (
id_venta SERIAL PRIMARY KEY,
cliente_id INT NOT NULL REFERENCES clientes(id),
total NUMERIC(10,2) DEFAULT 0,
fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE detalle_venta (
id SERIAL PRIMARY KEY,
id_venta INT NOT NULL REFERENCES ventas(id_venta),
id_producto INT NOT NULL REFERENCES productos(id_producto),
cantidad INT NOT NULL CHECK (cantidad > 0),
precio_unitario NUMERIC(10, 2) NOT NULL
);

CREATE TABLE proveedores (
id_proveedor SERIAL PRIMARY KEY,
nombre TEXT NOT NULL,
contacto TEXT,
telefono TEXT
);

CREATE TABLE detalle_compra (
id SERIAL PRIMARY KEY,
id_compra INT NOT NULL REFERENCES compras(id_compra) ON DELETE CASCADE,
id_producto INT NOT NULL REFERENCES productos(id_producto),
cantidad INT NOT NULL CHECK (cantidad > 0),
precio_unitario NUMERIC(10,2) NOT NULL
);

CREATE TABLE compras (
id_compra SERIAL PRIMARY KEY,
id_proveedor INT NOT NULL REFERENCES proveedores(id_proveedor),
fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



INSERT INTO categorias (nombre) VALUES ('LAPTOS');
INSERT INTO categorias (nombre) VALUES ('TELEFONOS');
INSERT INTO categorias (nombre) VALUES ('AUDIFONOS');

INSERT INTO Proveedores (nombre, contacto, telefono) VALUES ('Daniel Arenas', 'Norma', '3115998706');
INSERT INTO Proveedores (nombre, contacto, telefono) VALUES ('Juana Jugan', 'Juan', '3125456789');
INSERT INTO Proveedores (nombre, contacto, telefono) VALUES ('Franco Alva', 'David', '3135643213');


INSERT INTO clientes (id,nombre, correo, telefono) VALUES ('0001','Erika Millan', 'eka98@hotmail.com', '311-599-8706');
INSERT INTO clientes (id,nombre, correo, telefono) VALUES ('0002','James Rodriguez', 'goleador@gmail.com', '311-549-8706');
INSERT INTO clientes (id,nombre, correo, telefono) VALUES ('0003','Alexis Higuera', 'higuera98@gmail.com', '312-599-8706');
INSERT INTO clientes (id,nombre, correo, telefono) VALUES ('0004','William Perez', 'williamp@gmail.com', '3154356242');
INSERT INTO clientes (id,nombre, correo, telefono) VALUES ('0005','Juan Villa', 'villaJuanda@gmail.com', '3154534251');


INSERT INTO productos (nombre, precio, stock, updated_at, id_categoria, id_proveedor) VALUES
('Lenovo  X1', 5500000, 10, CURRENT_TIMESTAMP, 1, 1),
('Samsung S25', 3800000, 15, CURRENT_TIMESTAMP, 2, 2),
('Lenovo x2', 450000, 20, CURRENT_TIMESTAMP, 3, 3),
('Iphone 15', 3200000, 8, CURRENT_TIMESTAMP, 1, 1),
('Xiaomi Redmi 12', 900000, 25, CURRENT_TIMESTAMP, 2, 2),
('Audífonos apple', 620000, 12, CURRENT_TIMESTAMP, 3, 3);

--Listar los productos con stock menor a 5 unidades
SELECT nombre, stock 
FROM productos 
WHERE stock < 5;


--Calcular ventas totales de un mes específico--
SELECT 
    TO_CHAR(fecha, 'YYYY-MM') AS mes,
    SUM(total) AS ventas_totales
FROM ventas
WHERE TO_CHAR(fecha, 'YYYY-MM') = '2023-10'
GROUP BY TO_CHAR(fecha, 'YYYY-MM');

--Obtener el cliente con más compras realizadas--

SELECT 
    c.nombre AS cliente,
    COUNT(v.id_venta) AS total_compras
FROM clientes c
JOIN ventas v ON c.id = v.cliente_id
GROUP BY c.id, c.nombre
ORDER BY total_compras DESC
LIMIT 1;

-- los 5 productos más vendidos.--

SELECT 
    p.nombre AS producto,
    SUM(dv.cantidad) AS total_vendidos
FROM detalle_venta dv
JOIN productos p ON dv.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY total_vendidos DESC
LIMIT 5;

-- Consultar ventas realizadas en un rango de fechas de tres Días y un Mes.--

SELECT 
    v.id_venta,
    v.fecha,
    c.nombre AS cliente,
    v.total
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
WHERE v.fecha BETWEEN '2023-10-01' AND '2023-10-03'
   OR EXTRACT(MONTH FROM v.fecha) = 10
ORDER BY v.fecha;


-- Identificar clientes que no han comprado en los últimos 6 meses.--

SELECT 
    c.nombre AS cliente
FROM clientes c
LEFT JOIN ventas v ON c.id = v.cliente_id
WHERE v.fecha IS NULL 
   OR v.fecha < CURRENT_DATE - INTERVAL '6 months';

--Un procedimiento almacenado para registrar una venta--

CREATE OR REPLACE FUNCTION registrar_venta(
    p_cliente_id INT,
    p_detalle JSON
) RETURNS VOID AS $$
DECLARE
    v_id_venta INT;
    v_total NUMERIC(10, 2) := 0;
    v_item JSON;
    v_id_producto INT;
    v_cantidad INT;
    v_precio_unitario NUMERIC(10, 2);
BEGIN
    -- Crear la venta
    INSERT INTO ventas (cliente_id, total)
    VALUES (p_cliente_id, 0)
    RETURNING id_venta INTO v_id_venta;

    -- Procesar el detalle de la venta
    FOR v_item IN SELECT * FROM json_array_elements(p_detalle)
    LOOP
        v_id_producto := (v_item->>'id_producto')::INT;
        v_cantidad := (v_item->>'cantidad')::INT;

        -- Obtener el precio unitario del producto
        SELECT precio INTO v_precio_unitario
        FROM productos
        WHERE id_producto = v_id_producto;

        -- Insertar el detalle de la venta
        INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
        VALUES (v_id_venta, v_id_producto, v_cantidad, v_precio_unitario);

        -- Actualizar el stock del producto
        UPDATE productos
        SET stock = stock - v_cantidad
        WHERE id_producto = v_id_producto;

        -- Calcular el total de la venta
        v_total := v_total + (v_cantidad * v_precio_unitario);
    END LOOP;

    -- Actualizar el total de la venta
    UPDATE ventas
    SET total = v_total
    WHERE id_venta = v_id_venta;
END;
$$ LANGUAGE plpgsql;

--Validar que el cliente exista.

-- Validar que el cliente exista
IF NOT EXISTS (
    SELECT 1 
    FROM clientes 
    WHERE id = p_cliente_id
) THEN
    RAISE EXCEPTION 'El cliente con ID % no existe', p_cliente_id;
END IF;


-- Verificar que el stock sea suficiente antes de procesar la venta
FOR v_item IN SELECT * FROM json_array_elements(p_detalle)
LOOP
    v_id_producto := (v_item->>'id_producto')::INT;
    v_cantidad := (v_item->>'cantidad')::INT;

    -- Verificar stock disponible
    IF (SELECT stock FROM productos WHERE id_producto = v_id_producto) < v_cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente para el producto con ID %', v_id_producto;
    END IF;

    -- Obtener el precio unitario del producto
    SELECT precio INTO v_precio_unitario
    FROM productos
    WHERE id_producto = v_id_producto;

    -- Insertar el detalle de la venta
    INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (v_id_venta, v_id_producto, v_cantidad, v_precio_unitario);

    -- Actualizar el stock del producto
    UPDATE productos
    SET stock = stock - v_cantidad
    WHERE id_producto = v_id_producto;

    -- Calcular el total de la venta
    v_total := v_total + (v_cantidad * v_precio_unitario);
END LOOP;


-- Si no hay stock suficiente, notificar por medio de un mensaje en consola usando RAISE
FOR v_item IN SELECT * FROM json_array_elements(p_detalle)
LOOP
    v_id_producto := (v_item->>'id_producto')::INT;
    v_cantidad := (v_item->>'cantidad')::INT;

    -- Verificar stock disponible
    IF (SELECT stock FROM productos WHERE id_producto = v_id_producto) < v_cantidad THEN
        RAISE NOTICE 'Stock insuficiente para el producto con ID %: Disponible %, Requerido %', 
            v_id_producto, 
            (SELECT stock FROM productos WHERE id_producto = v_id_producto), 
            v_cantidad;
        CONTINUE; -- Continuar con el siguiente producto
    END IF;

    -- Obtener el precio unitario del producto
    SELECT precio INTO v_precio_unitario
    FROM productos
    WHERE id_producto = v_id_producto;

    -- Insertar el detalle de la venta
    INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (v_id_venta, v_id_producto, v_cantidad, v_precio_unitario);

    -- Actualizar el stock del producto
    UPDATE productos
    SET stock = stock - v_cantidad
    WHERE id_producto = v_id_producto;

    -- Calcular el total de la venta
    v_total := v_total + (v_cantidad * v_precio_unitario);
END LOOP;

-- Si hay stock suficiente, realizar el registro de la venta
IF v_total > 0 THEN

    UPDATE ventas
    SET total = v_total
    WHERE id_venta = v_id_venta;

    RAISE NOTICE 'Venta registrada exitosamente con ID % y total %', v_id_venta, v_total;
ELSE
    RAISE NOTICE 'No se registró la venta debido a falta de stock.';
END IF;