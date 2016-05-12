=============================================================
# CIPAL README: MANUAL DE USUARIO
-------------------------------------------------------------
    1. Inicio del SO
    2. Instalación del Sistema CIPAL
    3. Inicio del Sistema CIPAL 
    4. Ejecución de Comandos
    5. Indicaciones Adicionales

---------------------------------------------------------------
## Inicio del SO

Para iniciar el Sistema Operativo desde el puerto USB se debe
insertar el dispositivo pendrive, reiniciar el ordenador y
bootear desde el pendrive.
Seleccionar la opción 'Try Ubuntu'.  Una vez iniciado el
sistema, se deberá descargar el trabajo práctico de este link:

drive.google.com/folderview?id=0BxlSXU6_y1F4NUF3UDdtejlpRWs&usp=sharing

-------------------------------------------------------------
## Instalación del Sistema CIPAL

Para instalar el sistema se requieren los archivos Instalar
e instalacion.tar.gz. Para instalar el sistema, mover dichos
archivos a un nuevo directorio d donde se desea instalar el
sistema y ejecutar Instalar en d. Por ejemplo:

   $ mkdir ~/Grupo10
   $ cp Instalar instalacion.tar.gz ~/Grupo10
   $ cd ~/Grupo10
   $ ./Instalar

El proceso de instalación deja en el directorio de
instalación los archivos necesarios para preparar el
ambiente y ejecutar el sistema, en adición a los
archivos de configuración necesarios.

Se recomienda no eliminar instalacion.tar.gz, ya que
puede ser utilizado para reparar una instalación dañada.

-------------------------------------------------------------
## Inicio del Sistema CIPAL

Antes de iniciar el sistema es necesario ejecutar
PrepararAmbiente en el directorio de instalación. Suponiendo
que el sistema se instaló en ~/Grupo10:

   $ cd ~/Grupo10
   $ . ./binarios/PrepararAmbiente

Nótese que el comando se ejecuta en modo sourced.
PrepararAmbiente inicializa las variables de ambiente
que el sistema CIPAL requiere para su funcionamiento en
el shell en el que es ejecutado. Para reiniciar el sistema,
reinicie primero la sesión.

PrepararAmbiente ofrece también la posibilidad de ejecutar
el servicio de RecibirOfertas. De querer ejecutar el
servicio, escribir si; en caso contrario escribir no;
en cualquier caso, ingresar la respuesta y luego presionar
return.

Si se desea ejecutar algún comando manualmente, referirse
a la sección 4.

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

Para ejecutar un comando provisto por CIPAL, es recomendable
hacerlo a través del ejecutable LanzarProceso, una vez
ejecutado PrepararAmbiente (nótese que la inicialización
del entorno es necesaria y LanzarProceso la exige).

   $ "$BINDIR"/LanzarProceso [-sb] -c <comando> <argumentos>

Las opciones disponibles son las siguientes:

  -s: ejecuta el comando como un servicio (en segundo plano)
  -b: se reporta la inicialización en el log del comando.
  -c: el comando a ejecutar; debe ser uno de los listados
      a continuación.

Si se desea detener un servicio ejecutado mediante
LanzarProceso, utilizar el complemento DetenerProceso:

   $ "$BINDIR"/DetenerProceso <comando>

Los comandos que provee CIPAL son los siguientes:

##### PepararAmbiente
Establece las variables de entorno necesarias para la
ejecución del sistema. Debe ser ejecutado previo a cualquier
otro comando en el directorio de instalación del sistema.

##### RecibirOfertas
Comienza un proceso deamon encargado de determinar si los
archivos que se encuentran en el directorio ARRDIR respetan
el formato necesario (_.csv), el codigoConcesionario se
encuentre en el archivo maestro de concesionarios y AñoMesDia
sea una fecha correcta y anterior a la fecha actual. Aquellos
archivos que respeten dicho formato son movidos al directorio
OKDIR, los que no respeten son movidos al directorio NOKDIR y
escribe en el log el motivo por el cual no es un archivo
aceptado.

##### ProcesarOfertas
Es disparado por RecibirOfertas, busca la proxima fecha de
adjudicacion y guarda en un archivo todas las ofertas validas
que participan en el acto de adjudicacion. Toma los datos de
OKDIR, a medida que se van validando las ofertas los archivos
pasan a PROCDIR/procesadas, el comando no acepta archivos ya
procesados que se encuentren en este directorio. Los archivos
ya procesados o que no contengan la estructura adecuada se
mueven a NOKDIR. Los registros rechazados van a ir a
PROCDIR/validas/ en el archivo .txt y los validos a
PROCDIR/validas/ en el archivo .rech.

##### GenerarSorteo
Se ejecuta con LanzarProceso, busca la proxima fecha de
adjudicacion y genera un archivo en PROCDIR/sorteos/ con el
nombre _, donde se encuentra un numero de sorteo para cada
uno de los 168 participantes.

Ejecucion:

$ "$BINDIR"/LanzarProceso -c GenerarSorteo

##### DeterminarGanadores
Se ejecuta manualmente, la opcion -a muestra la ayuda del
comando, y la opcion-g graba el resultado de la consulta
realizada en un archivo. Con -r se hacen las diferentes
consultas:

A. Consulta los resultados del sorteo pasado
   por parametros.
B. Consulta el ganador del sorteo de uno o mas grupos
   pasados por parametros.
C. Consulta el ganador por licitacion de uno o mas
   grupos pasados por parametros.
D. Consulta los ganadores de uno o mas grupos pasados por
   parametros.


### COMANDOS ADICIONALES:

##### GrabarBitacora <comando> <mensaje> [INFO|WAR|ERR]
Graba en <comando>.log, en el directorio de bitácoras,
el mensaje <mensaje>, indicando si es de tipo informe
(INFO), advertencia (WAR), o error (ERR). Por defecto,
el tipo de mensaje es INFO.

##### MostrarBitacora <comando> [filtro]
Muestra el contenido del archivo <comando>.log en
el directorio de las bitácoras. De ser provista
una secuencia de caracteres como segundo argumento,
se mostrarán solo las líneas que contengan dicha
secuencia.

-------------------------------------------------------------
## Indicaciones Adicionales