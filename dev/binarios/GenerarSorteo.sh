#!/bin/bash

echo ""
echo "CIPAL: Generando sorteo."
echo ""

IFS='
'

# Cantidad de cambios que se va a ejecutar en el vactor
cambios=5000
RANGO=168

function echoerr {
  echo $1 1>&2
}

# Se crea un arreglo con los 168 numeros
for i in $(seq 1 $RANGO); do numeros[$i]=$i; done

function cambiar_indices {
  aux=${numeros[$1]}
  numeros[$1]=${numeros[$2]}
  numeros[$2]=$aux
}

# Se cambian aleatoriamente los numeros en el arreglo
for i in $(seq 1 $cambios)
do
  let "index_a=($RANDOM%$RANGO)+1"
  let "index_b=($RANDOM%$RANGO)+1"
  cambiar_indices $index_a $index_b
done

entrada="$MAEDIR/FechasAdj.csv"
ruta_salida="$PROCDIR/sorteos"
#entrada="/home/fran/Downloads/asdddd/MaestrosyTablas_TemaL/FechasAdj.csv"
#ruta_salida="/home/fran/Downloads/asdddd"

# Se esta trayendo la ultima fecha, nose si es lo esperado o se tiene que dejar como un parametro esto
ultima_fecha=$(tail -1 $entrada)
ultima_fecha=$(echo ${ultima_fecha%%;*} | sed 's!/!-!g')

# Si ya existen sorteos en la fecha se aumenta el numero de id
salida=$ruta_salida"/1_"$ultima_fecha".csv"
count=1
while [ -f $salida ]
do
    let count++
    salida=$ruta_salida"/"$count"_"$ultima_fecha
done


# Esto hay que loguearlo ademas de meterlo en la salida, nose si el inicio y fin de sorteo van solo al log o tmb al archivo
$BINDIR/GrabarBitacora PrepararAmbiente "Inicio de Sorteo" INFO
for i in $(seq 1 $RANGO)
do
    echo "$i;${numeros[$i]}" >> $salida
    $BINDIR/GrabarBitacora PrepararAmbiente "Numero de orden $i le corresponde el numero de sorteo ${numeros[$i]}" INFO
done
$BINDIR/GrabarBitacora PrepararAmbiente "Fin de Sorteo" INFO

echo "Sorteo generado"
