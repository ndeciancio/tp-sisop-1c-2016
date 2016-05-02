#!/bin/bash

#Mantengo vivo el deamon

SLEEPTIME=30
ciclo=1
ARRIDIR="/home/nicolas/Documents/SistemasOperativos/Pruebas/ARRIDIR"
OKDIR="/home/nicolas/Documents/SistemasOperativos/Pruebas/OKDIR"
NOKDIR="/home/nicolas/Documents/SistemasOperativos/Pruebas/NOKDIR"
MOVER="/home/nicolas/Documents/SistemasOperativos/Pruebas"
CONCESIONARIOS="/home/nicolas/Downloads/MaestrosyTablas_TemaL/concesionarios.csv"
LIBDIR=""

function verificarCodigo() {
	if grep ";$1" $CONCESIONARIOS >/dev/null; then
        return 0
    fi
	return 1
}

function fechaValida() {
	currentDate=`date +%Y%m%d`
	if [[ $1 =~ ^[0-9]{4}[0-9]{2}[0-9]{2}$ ]] && date -d "$1" >/dev/null 2>/dev/null; then
		if [ $currentDate -ge $1 ]; then
			return 0
		else
			return 1
		fi
	else
		return 1
	fi

	
}

while true  
        do
        ${LIBDIR}/GrabarBitacora.sh "RecibirOfertas" "Ciclo nro. $ciclo" "INFO"
        ciclo=$((ciclo+1))
        FILES=$(ls -A ${ARRIDIR}/* 2>/dev/null) 
        if test "$FILES";
        	then 
        	SAVEIFS=$IFS
        	IFS=$(echo -en "\n\b")
        	for fileName in $FILES; 
        	do
        		echo $fileName
        		if [ -s $fileName -a -f $fileName ] && [[ ( $fileName == *.csv.* ) || ( $fileName == *.csv ) ]] #Verifico que el archivo no este vacio, sea un archivo regular y tenga terminacion .csv
        			then
        			if [[ $fileName == *_* ]]; then #Verifico que tenga el formato de codigoConcesionario_Fecha
        				pathOrigen=${fileName%/*} #Me quedo con el path sin el nombre de archivo a levantar
						nombreFile=$(basename $fileName) #Nos quedamos solo con el nombre de file.
						codigoConcesionario=${nombreFile%_*} #Me quedo con el numero de concesionario
						auxiliarParaFecha=$(echo $nombreFile| cut -d'_' -f 2)
						#valorFecha=${auxiliarParaFecha%.*}
						valorFecha=$(echo $auxiliarParaFecha | cut -f 1 -d '.') #Me quedo con el numero de fecha
        				if verificarCodigo $codigoConcesionario; then #Verifico que sea un numero de concesionario valido
        					if fechaValida $valorFecha; then #Verifico que sea una fecha valida
        						#Archivo correcto
        						$MOVER/MoverArchivos.sh $fileName ${OKDIR} RecibirOfertas
        						
        					else
        						${LIBDIR}/GrabarBitacora.sh "RecibirOfertas" "El archivo $nombreFile fue rechazado por ser de una fecha invalida" "INFO"
        						$MOVER/MoverArchivos.sh $fileName ${NOKDIR} RecibirOfertas
        						
        					fi
        				else
        					${LIBDIR}/GrabarBitacora.sh "RecibirOfertas" "El archivo $nombreFile fue rechazado por ser de un concesionario inexistente" "INFO"
        					$MOVER/MoverArchivos.sh $fileName ${NOKDIR} RecibirOfertas
        				fi
        			else
        				${LIBDIR}/GrabarBitacora.sh "RecibirOfertas" "El archivo $nombreFile fue rechazado por no respetar el formato correcto en el nombre del archivo" "INFO"
        				$MOVER/MoverArchivos.sh $fileName ${NOKDIR} RecibirOfertas
        				
        				
        			fi



				else
					${LIBDIR}/GrabarBitacora.sh "RecibirOfertas" "El archivo "$nombreFile" fue rechazado por ser un tipo de archivo invalido" "INFO"
					$MOVER/MoverArchivos.sh $fileName ${NOKDIR} RecibirOfertas
        			
        		fi;

        	done
        	IFS=$SAVEIFS
        	#Procesar Ofertas
        	#echo "Hay Archivos"
        	
        else
 			#No hay archivos
        	echo "NO Hay Archivos"
        fi;

        filesInOKDIR=$(ls -A ${OKDIR}/* 2>/dev/null) 
        if test "$filesInOKDIR"; then
        	echo "Ejecutar Procesar Ofertas"
        fi

        sleep $SLEEPTIME
done  

