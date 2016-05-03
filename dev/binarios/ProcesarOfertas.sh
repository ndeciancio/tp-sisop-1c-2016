#!/bin/bash

# Listo archivos que estan en OKDIR/

IFS='
'
# Del padron, solo me interesa quedarme con el grupo y el número de orden y concatenarlos para formar el contrato_fusionado
contratos_fusionados=$(cut -c1-4,6-8 MAEDIR/temaL_padron.csv.xls)

# De grupos.csv, me interesan los que están en estado ABIERTO o NUEVO (es decir, todos los que son NO CERRADOS, -v invierte comportamiento)
#nuevos_o_abiertos=$(grep -v "^[0-9]\{1,4\};CERRADO;[^;]*;[^;]*;[^;]*;[^;]*" MAEDIR/Grupos.csv)
nuevos_o_abiertos=$(grep -v "^[0-9]\{1,4\};CERRADO;[^;]*;[^;]*;[^;]*;[^;]*" MAEDIR/Grupos.csv)
#echo $nuevos_o_abiertos

#nuevos_o_abiertos=$(grep "^[0-9]\{1,4\};ABIERTO;[^;]*;[^;]*;[^;]*;[^;]*" MAEDIR/Grupos.csv)

echo "---------------------------------------"

# Localizar proxima fecha de adjudicacion
hoy=$(date +"%Y%m%d")
while read -r fechas
do
	fechas=$(echo $fechas | cut -f1 -d';')
	fechas=$(echo $fechas | sed 's-\([0-1][0-9]\)/\([0-3][0-9]\)/\([0-9]\{4\}\)-\3\1\2-')
	if [ $fechas -ge $hoy ]
	then
		fecha_adj=$fechas
		break
	fi
done < MAEDIR/FechasAdj.csv.xls


for archivo in $(ls OKDIR)
do
	echo $archivo
	# Verificar que el archivo no este duplicado contra PROCDIR/procesados
	exito=$(find "PROCDIR/procesadas/" -type f -name "$archivo" | wc -l)
	if [ $exito -ne 0 ]
	then
		echo -e "\e[1;31m     Se rechaza el archivo por estar duplicado \e[0m"
		MoverArchivos.sh OKDIR/$archivo NOKDIR/$archivo ProcesarOfertas.sh
			# -------------------------------------
			# Pendiente: Mover archivo a NOKDIR
			# -------------------------------------
	else
		# Verificar la cantidad de campos del primer registro
	        read linea_archivo < OKDIR/$archivo
	        echo $linea_archivo | grep -q "^[0-9]\{7\};[0-9].*$"
	        # Verifico si la linea tiene el formato esperado. Si tuvo exito el grep (0) esta bien; sino fallo (1)
	        exito=$?
	        if [ $exito -ne 0 ]
	        then
			echo -e "\e[1;31m     Se rechaza el archivo porque su estructura no se corresponde con el formato esperado \e[0m"
			# -------------------------------------
			# Pendiente: Mover archivo a rechazados
			# -------------------------------------
	        else
               		echo -e "\e[1;34m     Archivo a procesar: $archivo \e[0m"
# ACA
usuario=$(whoami)
concesionario=$(echo $archivo | sed "s/^\([^;]*\)_[^;]*$/\1/")
fecha_archivo=$(echo $archivo | sed "s/^[^;]*_\([^;]*\)\.[^;]*\.[^;]*$/\1/")
fecha_actual=$(date +"%Y%m%d_%T")

			# Verificar Ofertas Validas
			while read -r linea_archivo
			do
				linea_archivo=$(echo $linea_archivo | sed 's/\r//')
				contrato_fusionado=$(echo $linea_archivo | cut -c1-7)
				echo $contrato_fusionado
				IFS=' '
				echo $contratos_fusionados | grep -q "^$contrato_fusionado$" 
				resultado=$?
				if [ $resultado -eq 0 ]
				then
					# contrato_fusionado valido. Hay que validar que esté en abierto o nuevo
					grupo=$(echo $linea_archivo | cut -c1-4)
					orden=$(echo $linea_archivo | cut -c5-7)
					importe_ofrecido=$(echo $linea_archivo | sed "s/^[^;]*;\([^;]*\)$/\1/")

					# Reemplazo coma decimal por PUNTO decimal
					importe_ofrecido=$(echo $importe_ofrecido | sed 's/\,/\./')
					# Borro el retorno de carro que está al final de cada línea 
					#importe_ofrecido=$(echo $importe_ofrecido | sed 's/\r//')
					echo "     ofrecio: $importe_ofrecido"

					linea_val=$(echo $nuevos_o_abiertos | grep "^$grupo;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*$")
					hay_resultados=$?
					if [ $hay_resultados -ne 0 ]
					then
						echo -e "\e[1;34m Rechazado. Contrato no encontrado. \e[0m"
						# ACA
						echo "$archivo;Contrato no encontrado;$linea_archivo;$usuario;$fecha_actual" >> PROCDIR/rechazadas/$concesionario.rech
					else
						# Supero validación de Contrato Encontrado
						echo "     $linea_val"
	
						cuota_pura=$(echo $linea_val | sed "s/^[^;]*;[^;]*;[^;]*;\([^;]*\);[^;]*;[^;]*$/\1/")
						cuotas_pendientes=$(echo $linea_val | sed "s/^[^;]*;[^;]*;[^;]*;[^;]*;\([^;]*\);[^;]*$/\1/")
						cuotas_para_licitar=$(echo $linea_val | sed "s/^[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;\([^;]*\)$/\1/")
	
						#Reemplazo la coma por el punto en el monto
						valor_cuota=$(echo $cuota_pura | sed 's/\,/\./')
	
						valor_minimo_licitacion=$(echo $valor_cuota \* $cuotas_para_licitar | bc)
						valor_maximo_licitacion=$(echo $valor_cuota \* $cuotas_pendientes | bc)
	
						echo "     minimo: $valor_minimo_licitacion"
						echo "     maximo: $valor_maximo_licitacion"
	
						# ------------------------------------------	
						# Aca se debe validar el monto de la oferta
						# ------------------------------------------
	
						monto_debajo=$(echo "$importe_ofrecido < $valor_minimo_licitacion" | bc)
						if [ $monto_debajo -eq 1 ]
						then
							echo -e "\e[1;34m Rechazado. No alcanza el monto mínimo.  \e[0m"
						# ACA
						echo "$archivo;No alcanza monto mínimo;$linea_archivo;$usuario;$fecha_actual" >> PROCDIR/rechazadas/$concesionario.rech
						else
							monto_encima=$(echo "$importe_ofrecido > $valor_maximo_licitacion" | bc)
							if [ $monto_encima -eq 1 ]
							then
								echo -e "\e[1;34m Rechazado. Supera el monto máximo.  \e[0m"
								# ACA
								echo "$archivo;Supera el monto máximo;$linea_archivo;$usuario;$fecha_actual" >> PROCDIR/rechazadas/$concesionario.rech
							else
								# Supero validaciones de monto
								
								# -------------------------------------	
								# Aca se debe validar FLAG si participa
								# -------------------------------------

# temaL_padron.csv 
# grupo | orden	| nombre suscriptor | concesionario | coeficiente | participa | motivo | cuotas de recupero | cuotas de deuda | fecha 1º venc | 1º cuota con deuda |   deuda    | id susc 
#   4   |   3   |        N          |        4      |   num       |     1     |   2    |     000000         |        00       |     00000000  |         00         | 0000000000 |    num

linea_padron=$(grep "^$grupo;$orden;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*$" MAEDIR/temaL_padron.csv.xls)
echo "     $linea_padron"
flag_participa=$(echo $linea_padron | cut -f6 -d';')
nombre_suscriptor=$(echo $linea_padron | cut -f3 -d';')

echo "flag: $flag_participa"

if [ $flag_participa -eq 1 ] || [ $flag_participa -eq 2 ]
then
	# Supero validación de flag de participacion
	echo "ok. continuamos."
	echo "$concesionario;$fecha_archivo;$contrato_fusionado;$grupo;$orden;$importe_ofrecido;$nombre_suscriptor;$usuario;$fecha_actual" >> salida.txt
else
	echo -e "\e[1;34m Rechazado. Suscriptor no puede participar.  \e[0m"
	# ACA
	echo "$archivo;Suscriptor no puede participar;$linea_archivo;$usuario;$fecha_actual" >> PROCDIR/rechazadas/$concesionario.rech
fi
							fi
						fi
					fi
				fi
			done < OKDIR/$archivo
	        fi
	fi
	echo "---------------------------------------"
done

echo $fecha_adj

