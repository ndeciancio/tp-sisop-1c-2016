# tp-sisop-1c-2016

## Instalación y Empaquetado
Para instalar la aplicación se requieren dos archivos: el ejecutable Instalar y el paquete instalacion.tar.gz.

Para ejecutar la instalación, copiar ambos archivos en un directorio vacío y ejecutar Instalar. Instalar extrae el contenido de instalacion.tar.gz y crea los archivos de configuración necesarios al momento de preparar el ambiente.

Para actualizar el paquete de instalación, mover instalacion.tar.gz a un directorio vacío, extraerlo allí y eliminarlo. Hacer luego los cambios necesarios, ya sea modificar, agregar o eliminar archivos, y ejecutar finalmente empaquetar.sh en el directorio donde se encuentra el archivo. Esto creará un tar ../instalacion.tar.gz (en el directorio por encima de donde empaquetar.sh fue ejecutado).

## PrepararAmbiente

Ejecutar como: . ./PrepararAmbiente en el directorio de instalación o en el directorio de los binarios.

1. Verifica si el ambiente fue inicializado. Cuando PrepararAmbiente finaliza exitosamente, guarda la variable AMTIENTE_INICIALIZADO con valor 1.
2. Busca el archivo CIPAL.cnf en el directorio config en la ruta de ejecución, o en ../config si no se encuentra config. Si no se encuentra, falla la inicialización.
3. Inicializa las variables de entorno definidas en CIPAL.cnf.
4. Verifica la existencia del archivo directorios.lst en $CONFDIR. directorios.lst es un archivo generado por el instalador que lista los directorios en $GRUPO. Se verifica luego la existencia de cada directorio listado en el archivo; si no se encuentra alguno, se intenta extraer de instalacion.tar.gz
5. Idem para inventario.lst, que lista binarios y maestros. También lo genera el instalador.
6. Se verifican los permisos sobre los ejecutables y los archivos de datos. Si alguno falta, se intentan setear. Si no se puede, PrepararAmbiente falla.
7. Se pregunta al usuario si quiere iniciar RecibirOfertas.
