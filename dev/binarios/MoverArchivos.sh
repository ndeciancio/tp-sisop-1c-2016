#! /bin/bash 

#Funcion moverC - Se encarga de mover archivos de manera inteligente contemplando la posibilidad de archivos duplicados

#Hipótesis:
	#El número de secuencia es local a cada carpeta, es decir, se busca cuantos archivos con el mismo nombre y extensión habrá y luego se utiliza ese índice incrementado en 1 para el próximo nombre de file.

#Parametros:

	#Parametro 1(Obligatorio): Origen
	#Parametro 2(Obligatorio): Destino
	#Parametro 3(Opcional): Comando que invoca el moverC

LIBDIR=$BINDIR #Ruta del loger

rutaOrigen="$1"
rutaDestino="$2"
comandoInvocante="$3"

function chequearRuta(){
	ruta="$1"
	if ( [ -f  "$ruta" ] ) #Chequeamos formato de la ruta de origen.
  	then    
          	if  [[ ! (-e  "$ruta") ]]  #Chequeamos si existe el file.
          	then    
                	${LIBDIR}/GrabarBitacora "$comandoInvocante" "La ruta $2 no existe" "ERR"
			return 2
  		fi
	else
        	${LIBDIR}/GrabarBitacora "$comandoInvocante" "El formato de la ruta $2 es incompatible" "ERR" 
		return 1
  	fi

	return 0
}
function existeArchivoEnRuta(){
	pathOrigen="$1"
	pathDestino="$2"
	nombreFile=$"$3"
	existencia=`find "$pathDestino" -type f -name "$nombreFile" | wc -l` #wc cuenta el parametro que le pasemos, el -l es el numero de lineas.
	return $existencia
}


#Chequeamos la cantidad de parametros, por lo menos 2 y como maximo 3.

cantidadParametros=$#

if ( ([ $cantidadParametros -lt 2 ] ) || ( [ $cantidadParametros -gt 3 ] ))  #Puede reemplazarse por -o todo dentro del paréntesis
then
	${LIBDIR}/loguearC.sh "$comandoInvocante" "Error en cantidad de parametros" "ERR"
fi


#Chequeamos las rutas
#Ruta Origen
chequearRuta "$rutaOrigen" "origen"
resultadoChequearRuta=$?

if ( [ $resultadoChequearRuta -ne 0 ]  ) 
then
	exit 1
fi

#Ruta Destino
if [[ ! (-d "$rutaDestino") ]] #Chequamos que es un directorio
then
    	${LIBDIR}/GrabarBitacora "$comandoInvocante" "Error en el ingreso del archivo destino, el directorio no existe." "ERR"
        exit 1
fi

pathOrigen=${rutaOrigen%/*} #Me quedo con el path sin el nombre de archivo a levantar
nombreFile=$(basename $rutaOrigen) #Nos quedamos solo con el nombre de file.
existeArchivoEnRuta $pathOrigen $rutaDestino $nombreFile
existeArchivo=$?

#Corroboramos si existe el file en el destino
if ( [ $existeArchivo -ne 0 ] )
then
	${LIBDIR}/GrabarBitacora "$comandoInvocante" "Ya existe el archivo $nombreFile en $rutaDestino , se procede a hacer el duplicado." "WAR"

        if [[ ! (-d "$rutaDestino/dup") ]] #Comprobamos que exista la carpeta de depulicados y si no existe
        then
         	nuevoNombreFile=""       
		mkdir   "${rutaDestino}/dup" #creamos el directorio
                if [ -d "${rutaDestino}/dup" ] #nos fijamos si fue correcta la creacion
                then
                        ${LIBDIR}/GrabarBitacora "$comandoInvocante" "Se creo correctamente el directorio /dup en $rutaDestino." "INFO"
                        nuevoNombreFile="${nombreFile}.1"  #Nuevo nombre de archivo
                else
                        ${LIBDIR}/loguearC.sh "$comandoInvocante" "Error al crear el directorio /dup en $rutaDestino." "ERR"
                        exit 1
                fi
        else
		cantidadFiles=`find "$pathDestino/dup" -type f -name "$nombreFile.*" | wc -l` #Busco en la carpeta dup la cantidad de archivos nombreFile.N
		cantidadFiles=$(($cantidadFiles + 1))
		nuevoNombreFile="${nombreFile}.$cantidadFiles"
	fi
	if [[ ! (-z $nuevoNombreFile) ]] #Si no hubo ningun problema
	then
		cp $rutaOrigen $nuevoNombreFile  #copiamos el archivo original
        	mv $nuevoNombreFile "${rutaDestino}/dup"  #Movemos el archivo al directorio de duplicados
	        rm "$rutaOrigen" #Removemos el archivo original de su origen
       		if [ $cantidadParametros -eq 3 ]
        	then
        		${LIBDIR}/GrabarBitacora "$comandoInvocante" "El comando $comandoInvocante ejecutó el comando move." "INFO"
        		${LIBDIR}/GrabarBitacora "$comandoInvocante" "Se movio correctamente el archivo  $nombreFile  al destino ${rutaDestino}/dup ." "INFO"
        	fi
	else
		exit 1
	fi
else
	mv "$rutaOrigen" "$rutaDestino" #muevo el archivo al destino ya que no es duplicado
        if [ $cantidadParametros -eq 3  ] #Si viene comando invocante, informo resultados
        then
                ${LIBDIR}/GrabarBitacora "$comandoInvocante" "El comando $comandoInvocante ejecutó el comando move." "INFO"
                ${LIBDIR}/GrabarBitacora "$comandoInvocante" "Se movio correctamente el archivo $nombreFile  al destino $rutaDestino." "INFO"
        fi

fi
