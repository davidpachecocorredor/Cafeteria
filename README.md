# Análisis de ventas - Cafeteria

## SQL | Excel | Power Query | Power Pivot | Macros(VBA) |

## Descripción del Proyecto
Este proyecto consiste en analizar las ventas de una cafetería mediante el uso de SQL para modelamiento de datos, y excel para dashbord y automatizacion de informes
se creo modelo relacional de base de datos,ETL, consultas SQL para KPIs.
## Objetivos
- Visibilizar las ventas del negocio
- Identificar productos mas rentables y vendidos
- Optimizar tiempo con automatización de reportes
## Conjunto de datos usados

[clean cafe sales](Data)

Tablas creadas: 
- Ventas
- Productos
- Metodo pago
- Calendario
- Tiendas
- Staging ventas
  
[Imagen tablas](Images/tablas.png)

# # Modelado de datos (SQL)
Se implemento un modelo relacional de estrella :
- Tabla Hechos : Ventas
- Tablas Dimensión : Productos, Tiendas , Calendario , Metodo pago
- Tabla Staging : staging_ventas
- Relación de [Tablas dimensión] -> [Tabla Hechos] ( 1 a muchos, filtrado unidirecional)

[Imagen modelo estrella](Images/relacional.png)
  
## KPIS (SQL/Excel)
▪️Ventas totales = ingresos acumulados
▪️Ticket promedio = total ventas / numero de transacciones
▪️Top productos = ranking por ventas totales
▪️Ventas mensuales = estacionalidad y tendencias 
## Visualización Dashboard
- grafico de líneas -> Ventas Mensuales
- Barras horizontales -> Top productos
- Segmentadores -> Meses, tienda, Metodo de Pago
- Kpis -> ventas totales, ticket promedio, cantidad
  
[Imagen dashboard](Images/dashboard.png)

## Automatización macros (VBA)
- Actualizar dashboard -> Actualiza nuevos datos desde SQL
- Exportar PDF -> Genera PDF automatico con Fecha actual
## Mejoras Futuras
- Añadir modulo para insertar ventas nuevas desde Excel
- Conectar a Power bi para informes web en tiempo real
- Utilizar modelos para previsión de ventas
- Agregar variables para análisis de costos y rentabilidad
## Conclusiones del Análisis

