SHOW GLOBAL VARIABLES LIKE 'local_infile';
use cafe_ventas;
-- creación de tablas 
create table productos(
	producto_id int auto_increment primary key,
    nombre varchar(50)not null,
    precio_unitario decimal(10,2) not null
);
create table  metodos_pago(
	metodo_id int auto_increment primary key,
    metodo varchar(50)
);
create table tiendas(
	tienda_id int auto_increment primary key,
    tienda varchar(50)
);
create table calendario(
	fecha_id int auto_increment primary key,
    fecha date not null,
    año int not null,
    mes int not null,
    dia int not null,
    dia_semana varchar(20) not null,
    mes_nombre varchar(20) not null
);
create table ventas(
	venta_id int auto_increment primary key,
    transaccion_id varchar(30) not null,
    producto_id int not null,
    cantidad int not null,
    precio_unitario decimal(10,2),
    total decimal(12,2),
    metodo_id int not null,
    tienda_id int not null,
    fecha_id int not null,
    foreign key (producto_id) references productos(producto_id),
    foreign key (tienda_id) references tiendas (tienda_id),
    foreign key (metodo_id) references metodos_pagos(metodo_id),
    foreign key (fecha_id) references calendario(fecha_id)
);
    
-- cración tabla stagin para cargar posteriormente el csv
CREATE TABLE staging_ventas (
    ID_transaccion      VARCHAR(50),
    item                VARCHAR(255),
    cantidad            INT,
    precio_unitario     DECIMAL(10,2),
    total               DECIMAL(10,2),
    metodo_pago         VARCHAR(50),
    location varchar(50),
    fecha               VARCHAR(50)
);
SHOW VARIABLES LIKE 'local_infile';
LOAD DATA LOCAL INFILE 'C:/Users/david/OneDrive/Escritorio/proyectos/cafeteria/clean_cafe_saless.csv'
INTO TABLE staging_ventas
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM staging_ventas;
SELECT * FROM staging_ventas LIMIT 11;
INSERT IGNORE INTO productos (nombre, precio_unitario)
SELECT item AS nombre,
       ROUND(AVG(precio_unitario),2) AS precio_unitario
FROM staging_ventas
WHERE item IS NOT NULL AND item <> ''
GROUP BY item;
INSERT IGNORE INTO metodos_pago (metodo)
SELECT DISTINCT metodo_pago
FROM staging_ventas
WHERE metodo_pago IS NOT NULL AND metodo_pago <> '';
INSERT IGNORE INTO tiendas (tienda)
SELECT DISTINCT location
FROM staging_ventas
WHERE location IS NOT NULL AND location <> '';
INSERT INTO fechas (fecha)
SELECT DISTINCT STR_TO_DATE(fecha, '%Y-%m-%d')
FROM staging_cafe;

SELECT COUNT(*) AS total_staging FROM staging_ventas;
SELECT COUNT(*) AS total_productos FROM productos;
SELECT COUNT(*) AS total_metodos_pago FROM metodos_pago;
SELECT COUNT(*) AS total_tiendas FROM tiendas;

alter table staging_ventas
modify fecha date;
insert into calendario (fecha,año,mes,dia,dia_semana,mes_nombre)
select
	fecha,
    year(fecha) as año,
     month(fecha) as mes,
     date_format(fecha,'%m'),
    day(fecha) as dia,
    date_format(fecha, '%w')
   
from (  
	select distinct fecha
    from staging_ventas
) as fecha;

SELECT 
    fecha,
    DATE_FORMAT(fecha, '%M') AS mes_nombre,
    DATE_FORMAT(fecha, '%W') AS dia_semana
FROM calendario
LIMIT 10;
SET SQL_SAFE_UPDATES = 0; -- desactivar modo seguro
SET SQL_SAFE_UPDATES = 1; -- activar modo seguro
SET lc_time_names = 'es_ES';
UPDATE calendario
SET 
    mes_nombre = DATE_FORMAT(fecha, '%M'),
    dia_semana = DATE_FORMAT(fecha, '%W');

alter table ventas
drop column total;
SELECT cantidad * precio_unitario AS total_venta
FROM ventas;

SELECT * FROM ventas;
SELECT * FROM metodos_pago;
SELECT * FROM tiendas;
SELECT * FROM calendario limit 20;
alter table ventas
add column total decimal(12,2) after precio_unitario;

-- poblar dimensiones de staging en ventas

 insert into ventas (
	transaccion_id,
    producto_id,
    cantidad,
    precio_unitario,
    total,
    metodo_id,
    tienda_id,
    fecha_id
)
select
	s.ID_transaccion,
    p.producto_id,
    s.cantidad,
    s.precio_unitario,
    s.total,
    mp.metodo_id,
    t.tienda_id,
    c.fecha_id
from staging_ventas s
join productos p
	on s.item = p.nombre
LEFT JOIN metodos_pago mp
    ON s.metodo_pago = mp.metodo
LEFT JOIN tiendas t
    ON s.location = t.tienda
LEFT JOIN calendario c
    ON s.fecha = c.fecha;

-- creamos algunas kpis
-- kpi 1 total ventas registradas
select
	count(*) as total_ventas
from ventas;
-- kpi 2 ingresos totales
select
	sum(total) as ingresos_totales
from ventas;
-- kpi 3 cantidad total de productos vendidos
select
	sum(cantidad) as unidades_vendidas
from ventas;
-- kpi4 ticket promedio
select
	sum(total)/count(*) as ticket_promedio
from ventas;
-- kpi 5 ingresos por mes
select
	c.año,
    c.mes,
    c.mes_nombre,
    sum(v.total) as ingresos_mes
from ventas v
join calendario c on v.fecha_id = c.fecha_id
group by c.año, c.mes , c.mes_nombre
order by c.año, c.mes;
-- kpi 6 producto mas vendido
select
	p.nombre,
    sum(v.cantidad) as total_unidades
from ventas v
join productos p on v.producto_id = p.producto_id
group by p.nombre
order by total_unidades desc 
limit 10;
-- kpi 7 ingresos por producto
select
	p.nombre,
    sum(v.total) as ingresos_productos
from ventas v
join productos p on v.producto_id = p.producto_id
group by p.nombre
order by ingresos_productos desc
limit 10;
-- kpi 8 ingresos por tienda
select
	t.tienda,
    sum(v.total) as ingresos_tienda
from ventas v
join tiendas t on v.tienda_id = t.tienda_id
group by t.tienda
order by ingresos_tienda desc;
-- kpi 9 ventas por metodo de pago
select
	mp.metodo,
    sum(v.total) as ingresos_mp
from ventas v
join metodos_pago mp on v.metodo_id = mp.metodo_id
group by mp.metodo
order by ingresos_mp desc;
