# Taller: Diseño e implementación de una base de datos relacional
## Parte 2

En esta segunda parte del taller, vamos a poblar la base de datos que creamos antes, con datos provenientes de archivos de tipo CSV (_Comma-Separated Values_). También mostraremos cómo 
generar los datos simulados usando un script escrito en lenguaje Ruby.

Después de poblar la base de datos, crearemos una vista para obtener un reporte consolidado de
pedidos de cerveza. A continuación, exportaremos la vista a un archivo CSV.

Finalmente, importaremos la base de datos en Microsoft Power BI.

## Pre-Requisitos

Para realizar este tutorial se requiere contar con los archivos que acompañan este documento:

* Archivo `beerdb.sqlite3` que contiene la base de datos creada en la parte 1, con sus tablas vacías.
* Archivo `create_tables.sql` en caso que sea necesario volver a crear la base de datos.

Además, se requiere el siguiente software:

* Microsoft Visual Studio Code (VSCode) con extensión de SQLite. Vimos en la [parte 1](https://github.com/claudio-alvarez/beerdb-tutorial-p1) cómo instalar este software.
* Microsoft Power BI: Descargable desde [aquí](https://www.microsoft.com/en-us/download/details.aspx?id=58494). Además, se requiere instalar un controlador de base de datos (driver ODBC) para usar SQLite con Power BI desde [aquí](http://www.ch-werner.de/sqliteodbc/sqliteodbc_w64.exe) (enlace de descarga directo) o desde [aquí](http://www.ch-werner.de/sqliteodbc/) (ver otras versiones).
* Para operaciones de importación y exportación de datos a formato CSV con la base de datos SQLite, se requiere instalar el programa de línea de comandos ([descarga directa Windows x64 aquí](https://www.sqlite.org/2021/sqlite-tools-win32-x86-3360000.zip), [otras versiones aquí](https://www.sqlite.org/download.html)).

## Paso 1: Poblar la base de datos (15 minutos)

Vamos a poblar nuestra base de datos con datos simulados de cervezas, pedidos, clientes, etc. Primero, mostraremos cómo esto puede realizarse con datos simulados utilizando un script. No es necesario que tú ejecutes el script pues al cabo de este ejercicio contarás con la base de datos completa. Luego, mostraremos cómo realizarlo importando archivos de tipo CSV en la base de datos.

### Script seed.rb (5 minutos)

El archivo `seed.rb` parte de este proyecto, contiene código que permite crear los datos simulados de la tienda de cerveza al detalle. En las líneas 50 a 55 se pueden ajustar parámetros como las cantidades de países, clientes, cervecerías, marcas, cervezas, y pedidos. El profesor mostrará la ejecución del script, en donde se podrá ver que la generación de 100000 pedidos es completamente factible, pero algo lenta con SQLite. Veremos también qué hace el script.

### Archivos CSV (10 minutos)

Mostraremos cómo es posible cargar archivos CSV en las tablas de la base de datos, a fin de dejarla completamente poblada. Para esto, contamos con un archivo CSV por cada tabla de la base de datos, en la carpeta `csv` junto a este enunciado.

En SQLite, la importación desde archivos CSV se realiza de la siguiente manera:

```sql
.mode csv
.import [ruta al archivo csv] [nombre de la tabla]
```

Se debe tener cuidado con que el archivo CSV en su primera fila comience con la primera tupla de datos de la tabla y que no contenga los rótulos de encabezado de columna.

El archivo `hydrate.sql` contiene los comandos necesarios para poblar la base de datos completa desde los archivos CSV con que contamos.

## Paso 2: Crear una vista (15 minutos)

Vamos a crear una _vista_ en la base de datos para obtener un reporte consolidado de los pedidos de cerveza. Una vista es una consulta que queda almacenada en la base de datos, y que puede consultarse como si se tratara da una tabla. Las vistas son útiles para crear reportes, y también para evitar la digitación manual de consultas extensas que se deben ejecutar en forma recurrente.

En SQLite, la creación de una vista es algo bastante sencillo (ver [documentación aquí](https://www.sqlite.org/lang_createview.html)):

```sql
CREATE [TEMP] VIEW [IF NOT EXISTS] view_name[(column-name-list)]
AS 
   select-statement;
```

Las partes que van entre corchetes son opcionales.

Vamos a crear una vista llamada `orders_summary` que nos permitirá obtener un reporte completo de las órdenes en la base de datos, con las siguientes columnas:

* `orders.id`
* `orders.date`
* `orders.total`
* `beers.id`
* `beers.name`
* `brands.name`
* `brewery.name`
* `beers_orders.amount`
* `beers.unit_price`
* `beers.alcvol`

Observando que es necesario crear una consulta `SELECT` primero con las uniones (joins) necesarios.
Para esto, podemos crear un archivo llamado `create_views.sql` y ahí escribir la sentencia `CREATE VIEW` necesaria para nuestra vista.

Una vez creada la vista, podemos ejecutar en VSCode la siguiente consulta para probarla:

```sql
SELECT * from orders_summary LIMIT 10
```

Si esto nos da resultados, podemos continuar al paso siguiente. De lo contrario, es necesario eliminar la vista y volverla a crear:

```SQL
DROP VIEW IF EXISTS orders_summary;
```

Es una buena idea agregar esta línea al comienzo del archivo `create_views.sql`, de manera que cada vez que se ejecute, se vuelva a crear la vista si ésta ya existe.

## Paso 3: Exportando la vista a un archivo CSV (10 minutos)

Desde SQLite es simple exportar una tabla o vista a CSV. Para exportar los datos en la vista `orders_summary`, podemos crear un archivo llamado `export_orders.sql` con el siguiente contenido:

```sql
.headers on
.mode csv
.output orders_summary.csv
SELECT * FROM orders_summary;
.quit
```

La primera línea `.headers on` permite que en el CSV aparezcan los nombres de las columnas al comienzo del archivo. Luego, se activa el modo de escritura a archivo CSV y se especifica que la salida debe ir al archivo `orders_summary.csv`. A continuación se ejecuta la consulta que extrae todos los datos de la vista y el proceso termina.

Para ejecutar los comandos anteriores, se requiere usar la aplicación de línea de comando de SQLite, pues desde la extensión que usamos en VSCode no es posible realizar operaciones de importación y exportación de datos con archivos CSV.

## Paso 4: Crear visualizaciones en Microsoft Power BI (Resto de la sesión)

Contando con la base de datos SQLite poblada con los datos, vamos a construir visualizaciones en Microsoft Power BI para explorar la información de pedidos de cerveza. Sigue atento(a) los pasos del profesor.
