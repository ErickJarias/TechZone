# TechZone
Gestión de Inventario para una
Tienda de Tecnología

Descripción del proyecto explicando su propósito y funcionalidad.

 funcionalidades:

🔹 Gestión de productos
🔹 Control de inventario
🔹 Gestión de proveedores
🔹 Registro de ventas y compras
🔹 Gestión de clientes
🔹 Reportes y análisis

Tecnologías utilizadas:

🔹 PostgreSQL.
🔹 pgSQL.

Instrucciones detalladas para importar y ejecutar los archivos SQL en PostgreSQL.


1. Abre pgAdmin y conecta a tu servidor
2. Crea una nueva base de datos:
Haz clic derecho en "Databases" → "Create" - "Database..."

Escribe el nombre de la base de datos (techzone) y guarda.

3. Importar el archivo .sql:
Selecciona tu base de datos → Haz clic en Tools → Query Tool.

En el ícono de carpeta, abre tu archivo .sql.

Presiona el botón de Ejecutar.

 Descripción de Archivos SQL del Proyecto

--db.sql – Definición de la estructura de la base de datos
    
 Este script contiene todas las instrucciones necesarias para crear las tablas, relaciones, llaves primarias y foráneas del sistema.

Incluye:
Sentencias CREATE TABLE
Tipos de datos (TEXT, NUMERIC, DATE)
Claves primarias (PRIMARY KEY)
Relaciones (FOREIGN KEY)
Restricciones (CHECK, NOT NULL).

--insert.sql – cuerpo de la base de datos

Productos disponibles en inventario

Categorías como "Smartphones", "Laptops", etc.

Proveedores
Clientes
Ventas y detalles de ventas

 Se ejecuta después de db.sql. Sirve para tener datos con los cuales probar consultas y procedimientos.

queries.sql – Consultas SQL para análisis o reportes

--Listar productos con stock bajo.

Calcular las ventas de un mes específico.
Obtener el cliente que más ha comprado.
Ver los productos más vendidos.

--procedure.sql – Funciones y procedimientos almacenados

Registrar una venta (y actualizar stock automáticamente).
Calcular total de una compra o venta.
Validar si un cliente existe antes de ejecutar una operación.

--Ejemplo de cómo ejecutar las consultas y el procedimiento almacenado en PostgreSQ
 En pgAdmin:

Abre tu base de datos.
Ve a Tools > Query Tool.
escribe o pega la consulta y presiona Ejecutar.

hecho por :https://github.com/ErickJarias



