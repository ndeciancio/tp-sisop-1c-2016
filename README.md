# tp-sisop-1c-2016

## PrepararAmbiente

Ejecutar como: . ./PrepararAmbiente en el directorio de instalación o en el directorio de los binarios.

Nota 1: el instalador todavía no está arriba; igualmente PrepararAmbiente debería funcionar.

Nota 2: falta que PrepararAmbiente loguee con los utilitarios de bitácoras, porque todavía no están.

Nota 3: falta que PrepararAmbiente lance RecibirOfertas, porque faltan LanzarProceso y DetenerProceso.

1. Verifica si el ambiente fue inicializado. Cuando PrepararAmbiente finaliza exitosamente, guarda la variable AMTIENTE_INICIALIZADO con valor 1.
2. Busca el archivo CIPAL.cnf en el directorio config en la ruta de ejecución, o en ../config si no se encuentra config. Si no se encuentra, falla la inicialización.
3. Inicializa las variables de entorno definidas en CIPAL.cnf.
4. Verifica la existencia del archivo directorios.lst en $CONFDIR. directorios.lst es un archivo generado por el instalador que lista los directorios en $GRUPO. Se verifica luego la existencia de cada directorio listado en el archivo; si no se encuentra alguno, se intenta extraer de instalacion.tar.gz
5. Idem para inventario.lst, que lista binarios y maestros. También lo genera el instalador.
6. Se verifican los permisos sobre los ejecutables y los archivos de datos. Si alguno falta, se intenta setear. Si no se puede, PrepararAmbiente falla.
7. Se pregunta al usuario si quiere iniciar RecibirOfertas.
