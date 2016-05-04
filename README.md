===============================================================
# README: CIPAL

---------------------------------------------------------------
## Iniciando el Sistema Operativo desde el puerto USB

---------------------------------------------------------------
## Iniciando Sesi�n

---------------------------------------------------------------
## Descargando el Paquete

---------------------------------------------------------------
## Instalaci�n del Sistema

Para instalar el sistema son necesarios dos archivos: el
ejecutable Instalar y el paquete comprimido instalacion.tar.gz.

El proceso de instalaci�n es el siguiente:

1. Mover Instalar e instalacion.tar.gz a un directorio d,
   preferentemente vac�o. Tras el proceso de instalaci�n, 
   todos los archivos necesarios para poner en marcha el
   sistema habr�n sido extra�dos al directorio d.
2. Ejecutar Instalar desde el directorio d.

En d habr�n sido extra�dos los directorios del sistema,
y habr� sido generado en d/config el archivo de configuraci�n
CIPAL.cnf. El archivo de configuraci�n contiene las variables 
de entorno que ser�n inicializadas por el proceso de 
preparaci�n del ambiente.

---------------------------------------------------------------
## Preparaci�n del Ambiente

Para iniciar el sistema CIPAL una vez finalizado el proceso
de instalaci�n, se debe proceder a ejecutar el comando
PrepararAmbiente en el directorio donde CIPAL fue instalado.

$ cd <directorio instalaci�n>

$ . ./binarios/PrepararAmbiente

N�tese que la ejecuci�n debe hacerse en modo sourced.
PrepararAmbiente establece en el entorno las variables de
ambiente definidas en el archivo de configuraci�n creado
previamente por el instalador.

De ejecutarse el proceso de preparaci�n correctamente,
se mostrar� un mensaje de confirmaci�n en la pantalla.

---------------------------------------------------------------
## Ejecuci�n de Comandos

Para ejecutar y detener procesos de CIPAL, se debe utilizar
el comando LanzarProceso una vez ejecutado PrepararAmbiente.

$ $BINDIR/LanzarProceso [opciones] -c <nombre comando> <args>

Las opciones disponibles son:

-s: ejecuta el comando como un servicio (en segundo plano).

-b: graba en la bit�cora (en $LOGDIR) la ejecuci�n del comando.

Para detener un proceso, es necesario utilizar el comando
DetenerProceso ubicado en la carpeta de los binarios:

$ $BINDIR/DetenerProceso <nombre proceso>

---------------------------------------------------------------
## Comandos Disponibles

BINDIR/PepararAmbiente
Establece las variables de entorno necesarias para la ejecuci�n
del sistema. Debe ser ejecutado previo a cualquier otro
comando en el directorio de instalaci�n del sistema.

BINDIR/LanzarProceso
Documentado en la secci�n "Ejecuci�n de Comandos".

BINDIR/DetenerProceso <comando>
Detiene el proceso ejecutado con LanzarProceso -c <comando>,
de estar este en ejecuci�n.

BINDIR/RecibirOfertas
Comienza un proceso deamon encargado de determinar si los 
archivos que se encuentran en el directorio ARRDIR respetan
el formato necesario (<codigoConcesionario>_<A�oMesDia>.csv),
el codigoConcesionario se encuentre en el archivo maestro de
concesionarios y A�oMesDia sea una fecha correcta y anterior
a la fecha actual. Aquellos archivos que respeten dicho formato
son movidos al directorio OKDIR, los que no respeten son movidos
al directorio NOKDIR y escribe en el log el motivo por el cual
no es un archivo aceptado.

BINDIR/GenerarSorteo

BINDIR/DeterminarGanadores
