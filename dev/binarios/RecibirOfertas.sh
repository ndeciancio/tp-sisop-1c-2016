#!/bin/bash

#Mantengo vivo el deamon

SLEEPTIME=30
ciclo=1
ARRIDIR="/home/nicolas/Documents/SistemasOperativos/Pruebas/ARRIDIR"
OKDIR="/home/nicolas/Documents/SistemasOperativos/Pruebas/OKDIR"
NOKDIR="/home/nicolas/Documents/SistemasOperativos/Pruebas/NOKDIR"
MOVER="/home/nicolas/Documents/SistemasOperativos/Pruebas"
CONCESIONARIOS="/home/nicolas/Downloads/MaestrosyTablas_TemaL/concesionarios.csv"

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
        echo "Ciclo Num: $ciclo"
        ciclo=$((ciclo+1))
        FILES=$(ls -A $ARRIDIR/* 2>/dev/null) 
        if test "$FILES";
        	then 
        	SAVEIFS=$IFS
        	IFS=$(echo -en "\n\b")
        	for fileName in $FILES; 
        	do
        		if [ -s $fileName -a -f $fileName -a ${fileName: -4} == ".txt" ]
        			then
        			if [[ $fileName == *_* ]]; then
        				pathOrigen=${fileName%/*} #Me quedo con el path sin el nombre de archivo a levantar
						nombreFile=$(basename $fileName) #Nos quedamos solo con el nombre de file.
						codigoConcesionario=${nombreFile%_*} #Me quedo con el numero de concesionario
						auxiliarParaFecha=$(echo $nombreFile| cut -d'_' -f 2)
						valorFecha=${auxiliarParaFecha%.*}
        				if verificarCodigo $codigoConcesionario; then
        					if fechaValida $valorFecha; then
        						#Archivo correcto
        						$MOVER/MoverArchivos.sh $fileName $OKDIR RecibirOfertas
        						echo "MOVER ARCHIVO $nombreFile A LA CARPETA"
        					else
        						echo "Fecha INVALIDA"
        					fi
        				else
        					echo "codigo invalido"
        					#Archivo Incorrecto
        				fi
        			else
        				echo "formato incorrecto"
        				#Archivo Incorrecto
        			fi



				else
					#Archivo Incorrecto
        			echo "Archivo Malo"
        		fi;

        	done
        	IFS=$SAVEIFS
        	#Procesar Ofertas
        	#echo "Hay Archivos"
        	
        else
 			#No hay archivos
        	echo "NO Hay Archivos"
        fi;

        filesInOKDIR=$(ls -A $OKDIR/* 2>/dev/null) 
        if test "$filesInOKDIR"; then
        	echo "Ejecutar Procesar Ofertas"
        fi

        sleep $SLEEPTIME
done  




function