=============================================================
# CIPAL README: MANUAL DE USUARIO
-------------------------------------------------------------
    1. Inicio del SO
    2. Instalación del Sistema CIPAL
    3. Inicio del Sistema CIPAL 
    4. Ejecución de Comandos
    5. Indicaciones Adicionales

---------------------------------------------------------------
## Iniciando el Sistema Operativo desde el puerto USB

Para iniciar el Sistema Operativo desde el puerto USB se debe
insertar el dispositivo pendrive, reiniciar el ordenador y
bootear desde el pendrive.
Seleccionar la opción 'Try Ubuntu'.  Una vez iniciado el 
sistema, se deberá descargar el trabajo práctico de este link:

https://drive.google.com/folderview?id=0BxlSXU6_y1F4NUF3UDdtejlpRWs&usp=sharing

---------------------------------------------------------------
## Instalación del Sistema

Para instalar el sistema son necesarios dos archivos: el
ejecutable Instalar y el paquete comprimido instalacion.tar.gz.

El proceso de instalación es el siguiente:

1. Mover Instalar e instalacion.tar.gz a un directorio d,
   preferentemente vacío. Tras el proceso de instalación, 
   todos los archivos necesarios para poner en marcha el
   sistema habrán sido extraídos al directorio d.
2. Ejecutar Instalar desde el directorio d.

En d habrán sido extraídos los directorios del sistema,
y habrá sido generado en d/config el archivo de configuración
CIPAL.cnf. El archivo de configuración contiene las variables 
de entorno que serán inicializadas por el proceso de 
preparación del ambiente.

---------------------------------------------------------------
## Preparación del Ambiente

Para iniciar el sistema CIPAL una vez finalizado el proceso
de instalación, se debe proceder a ejecutar el comando
PrepararAmbiente en el directorio donde CIPAL fue instalado.

$ cd <directorio instalación>

$ . ./binarios/PrepararAmbiente

Nótese que la ejecución debe hacerse en modo sourced.
PrepararAmbiente establece en el entorno las variables de
ambiente definidas en el archivo de configuración creado
previamente por el instalador.

De ejecutarse el proceso de preparación correctamente,
se mostrará un mensaje de confirmación en la pantalla.

---------------------------------------------------------------
## Ejecución de Comandos

Para ejecutar y detener procesos de CIPAL, se debe utilizar
el comando LanzarProceso una vez ejecutado PrepararAmbiente.

$ $BINDIR/LanzarProceso [opciones] -c <nombre comando> <args>

Las opciones disponibles son:

-s: ejecuta el comando como un servicio (en segundo plano).

-b: graba en la bitácora (en $LOGDIR) la ejecución del comando.

Para detener un proceso, es necesario utilizar el comando
DetenerProceso ubicado en la carpeta de los binarios:

$ $BINDIR/DetenerProceso <nombre proceso>

---------------------------------------------------------------
## Comandos Disponibles

#####BINDIR/PepararAmbiente
Establece las variables de entorno necesarias para la ejecución
del sistema. Debe ser ejecutado previo a cualquier otro
comando en el directorio de instalación del sistema.

#####BINDIR/LanzarProceso
Documentado en la sección "Ejecución de Comandos".

#####BINDIR/DetenerProceso <comando>
Detiene el proceso ejecutado con LanzarProceso -c <comando>,
de estar este en ejecución.

#####BINDIR/RecibirOfertas
Comienza un proceso deamon encargado de determinar si los 
archivos que se encuentran en el directorio ARRDIR respetan
el formato necesario (<codigoConcesionario>_<AñoMesDia>.csv),
el codigoConcesionario se encuentre en el archivo maestro de
concesionarios y AñoMesDia sea una fecha correcta y anterior
a la fecha actual. Aquellos archivos que respeten dicho formato
son movidos al directorio OKDIR, los que no respeten son movidos
al directorio NOKDIR y escribe en el log el motivo por el cual
no es un archivo aceptado.

#####BINDIR/ProcesarOfertas
Es disparado por RecibirOfertas, busca la proxima fecha de adjudicacion
y guarda en un archivo todas las ofertas validas que participan en el
acto de adjudicacion. Toma los datos de OKDIR, a medida que se van validando
las ofertas los archivos pasan a PROCDIR/procesadas, el comando no acepta
archivos ya procesados que se encuentren en este directorio. Los archivos ya
procesados o que no contengan la estructura adecuada se mueven a NOKDIR.
Los registros rechazados van a ir a PROCDIR/validas/ en el archivo
<fecha_de_adjudicación>.txt y los validos a PROCDIR/validas/ en el archivo
<cod_concesionario>.rech.

#####BINDIR/GenerarSorteo
Se ejecuta con LanzarProceso, busca la proxima fecha de adjudicacion
y genera un archivo en PROCDIR/sorteos/ con el nombre
<sorteo_id>_<fecha_de_adjudicación>, donde se encuentra un numero
de sorteo para cada uno de los 168 participantes.


#####BINDIR/DeterminarGanadores
Se ejecuta manualmente, la opcion -a muestra la ayuda del comando, y la
opcion-g graba el resultado de la consulta realizada en un archivo.
Con -r se hacen las diferentes consultas:

A. Consulta los resultados del sorteo pasado por parametros.

B. Consulta el ganador del sorteo de uno o mas grupos pasados por parametros.

C. Consulta el ganador por licitacion de uno o mas grupos pasados por parametros.

D. Consulta los ganadores de uno o mas grupos pasados por parametros.
