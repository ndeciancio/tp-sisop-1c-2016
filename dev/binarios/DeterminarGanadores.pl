#!/usr/bin/perl

use strict;
use Env;
use Getopt::Long;
use Getopt::Long qw(GetOptionsFromString);
use List::Util qw(first);
use Data::Dumper;

my $help="";
my $grabar="";
my $ganSor="";
my $licitacion="";
my $sorteoFile="";
my $resultado="";
my %hash=();
my %temaLPadron=();
my %grupos=();
my %sorteoResponse=();
my %licitacionResponse=();
my @adjud;
my $sorteo="";
my $grupoRef="";
my @response;
my $exit="";
my $confPROCDIR="/home/nicolasdeciancio/tp-sisop/PROCDIR";
my $confMAEDIR="/home/nicolasdeciancio/tp-sisop/MAEDIR";
my $confINFODIR="/home/nicolasdeciancio/tp-sisop/INFODIR";

#configuracion para que incluya opciones de una sola letra, e ignore el case.
Getopt::Long::Configure('bundling','no_ignore_case');

# verificar_variables_de_ambiente();

if (@ARGV > 0){
	while(1){
		my $llamada_valida=GetOptions('a|ayuda' => \$help ,'g' => \$grabar ,'r=s' => \$ganSor, 'exit' => \$exit , 's=s' => \$sorteo , 'grupo=s' => \$grupoRef , 'l=s' => \$licitacion , 'p=s' => \$resultado);
		
		if($llamada_valida){
			esta_corriendo();
			cargar_directorios();
			cargar_hashes();
			if ($help){
				usage();
			}

			if($ganSor){
				cargar_sorteo();
				mostrar_sorteo();
			}

			if($sorteo){
				cargar_sorteo();
				ganadores_sorteo();
			}

			if($licitacion){
				cargar_sorteo();
				ganadores_licitacion();
			}

			if($grabar){
				my $existingdir = $confINFODIR;
				mkdir $existingdir unless -d $existingdir; # Check if dir exists. If not create it.
				opendir(INFODIR,"$existingdir") or die "No se encuentra o no se puede abrir el directorio $existingdir\n";
				my @indices=("0");
				
				my $extension=".txt";
				my $salida = "";
				if($ganSor){
					$salida = (split("\\.",$sorteoFile))[0];
				}
				if($sorteo or $licitacion){
					my $nombreSalida = nombre_archivo_salida();
					my $fechaSalida = (split("\\.",(split("\_", $sorteoFile))[1]))[0];
					my $sorteoSalida = (split("\_", $sorteoFile))[0];
					$salida = "$sorteoSalida\_$nombreSalida\_$fechaSalida";
				}
				open my $fileHandle, ">", "$existingdir/$salida$extension" or die "Can't open '$existingdir/$salida$extension'\n";
				foreach my $registro(@response){
					print $fileHandle "$registro";
				}
				close $fileHandle;
				
				close(INFODIR);
			}

			if($exit){
				exit 0;
			}
		}
		restart();
		print "$0 ~/Command-line % ";
		my $entrada=<STDIN>;
		my @arg_arr = split (/\s/, $entrada);
		@ARGV = @arg_arr;
	}
}

#Esta funcion verifica si esta corriendo el proceso, si ya esta corriendo lo deja correr, sino no lo corre otra vez
sub esta_corriendo {
	my @processid = `pgrep DeterminarGanadores`;
	if (@processid > 1){
		print "el proceso ya esta corriendo\n";
		exit 0;
	}else{
		print "el proceso puede correr\n";	
	}
}

sub nombre_archivo_salida{
	my @rango = split("-",$grupoRef);
	my @varios = sort(split(",",$grupoRef));
	if( $grupoRef eq "all" ){
		return "Grdxxxx-Grhyyyy";
	}else{
		my $rango = @rango;
		if( $rango == 2 ){
			return "Grd@rango[0]-Grh@rango[1]"
		}else{
			my $varios = @varios;
			if( $varios == 1 and $grupoRef ne "all" ){
				return "Grd$grupoRef-Grh$grupoRef"
			}else{
				if( $varios >= 1 and $grupoRef ne "all" ){
					return "Grd@varios[0]-Grh@varios[$varios]";
				}
			}
		}
	}
}

sub cargar_sorteo{
	my $dirname = "$confPROCDIR/sorteos";
	opendir(DIR,$dirname) or die "No se encuentra o no se puede abrir el directorio $dirname\n";
	while(my $file = readdir(DIR)){
		next if ($file =~ /^\.+$/);
		if( ($file =~ /^($ganSor)\_\d+.csv\.*/) or ($file =~ /^($sorteo)\_\d+.csv\.*/) or ($file =~ /^($licitacion)\_\d+.csv\.*/) ){
			$sorteoFile = $file;
			open(my $archivo, "$dirname/$file");
			while(my $linea=<$archivo>){
				chomp($linea);
				my @fields=split(";",$linea);
				$hash{@fields[0]} = @fields[1];
			}
			close($file);
		}
	}
	close(DIR);
}

sub mostrar_sorteo{
	if($grabar){
		foreach my $sorteo(sort {$hash{$a} <=> $hash{$b} } keys %hash){
			push(@response,"Nro. de Sorteo $hash{$sorteo}, le correspondió al número de orden $sorteo\n");
		}		
	}else{
		print "Resultado general del sorteo:\n\n";
		foreach my $sorteo(sort {$hash{$a} <=> $hash{$b} } keys %hash){
			print "Nro. de Sorteo $hash{$sorteo}, le correspondió al número de orden $sorteo\n";
		}
	}
}

sub restart{
	undef(@response);
	undef(@ARGV);
	undef($help);
	undef($grabar);
	undef($ganSor);
	undef(%hash);
	undef($ganSor);
	undef($grupoRef);
	undef($sorteo);
	undef(@adjud);
	undef(%sorteoResponse);
	undef(%licitacionResponse);
	undef($licitacion);
}

sub cargar_directorios{
	open(my $confCIPAL, "$ENV{'CONFDIR'}/CIPAL.cnf");
	while( my $linea = <$confCIPAL>){
		my @fields=split("=",$linea);
		if(@fields[0] eq "PROCDIR"){
			$confPROCDIR=@fields[1];
		}
		if(@fields[0] eq "MAEDIR"){
			$confMAEDIR=@fields[1];
		}
		if(@fields[0] eq "INFODIR"){
			$confINFODIR=@fields[1];
		}
	}
	close($confCIPAL);
}

sub verificar_variables_de_ambiente{
	if(!$ENV{'GRUPO'} or !$ENV{'BINDIR'} or !$ENV{'MAEDIR'} or !$ENV{'ARRIDIR'} or !$ENV{'OKDIR'} or !$ENV{'PROCDIR'} or !$ENV{'INFODIR'} or !$ENV{'LOGDIR'} or !$ENV{'NOKDIR'} or !$ENV{'LOGSIZE'} or !$ENV{'SLEEPTIME'}){
		print "debe realizar primero la inicializacion de ambiente\n";
		exit 0;
	}else{
		print "inicio de ejecucion";
	}
}

sub cargar_hashes{
	open(my $padron,"$confMAEDIR/temaL_padron.csv");
	open(my $grp,"$confMAEDIR/grupos.csv");
	while(my $linea=<$padron>){
		chomp($linea);
		my @fields=split(";",$linea);
		$temaLPadron{@fields[2]} = [@fields[0],@fields[1],@fields[2], @fields[3], @fields[4], @fields[5], @fields[6], @fields[7], @fields[8], @fields[9], @fields[10], @fields[11], @fields[12], @fields[13]] ;
	}
	while(my $linea=<$grp>){
		chomp($linea);
		my @fields=split(";",$linea);
		$grupos{@fields[0]} = [@fields[1],@fields[2],@fields[3],@fields[4],@fields[5],@fields[6]];
	}
	close($padron);
	close($grp);
	
}

sub cargar_fecha_adj{
	(my $fecha)=@_;
	my $archivo = "$fecha.txt";
	open(my $fechaAdj,"$confPROCDIR/validas/$archivo") or die "No se encuentra o no se puede abrir el archivo $archivo\n";
	while(my $linea=<$fechaAdj>){
		chomp($linea);
		my @fields=split(";",$linea);
		push(@adjud,[@fields]);
	}
	close($fechaAdj);
}

sub mostrar_ganadores_sorteo{
	if(!$resultado){
		foreach my $index( sort keys %sorteoResponse){
			print "Ganador por sorteo del grupo $index Nro de Orden: $sorteoResponse{$index}[0], $sorteoResponse{$index}[1] (Nro de Sorteo $sorteoResponse{$index}[2])\n";
			if($grabar){
				push(@response,"Ganador por sorteo del grupo $index Nro de Orden: $sorteoResponse{$index}[0], $sorteoResponse{$index}[1] (Nro de Sorteo $sorteoResponse{$index}[2])\n");
			}
		}
	}
}

sub ganadores_sorteo{
	my @idFecha = split("\_", $sorteoFile);
	cargar_fecha_adj((split("\\.",@idFecha[1]))[0]);
	print "Ganadores del Sorteo @idFecha[0] de fecha @idFecha[1]\n\n";
	my @rango = split("-",$grupoRef);
	my @varios = sort(split(",",$grupoRef));
	if( $grupoRef eq "all" ){
		print "$grupoRef\n";
		foreach my $nroOrden( sort {$hash{$a} <=> $hash{$b} } keys %hash ){
			foreach my $registro(@adjud){
				if ( (@$registro[4] == $nroOrden ) and ($grupos{@$registro[3]}[0] =~ /^(ABIERTO|NUEVO)/) and ($temaLPadron{@$registro[6]}[5] != "") ){
					if( !$sorteoResponse{@$registro[3]} || $sorteoResponse{@$registro[3]}[2] > $hash{$nroOrden} ){
						$sorteoResponse{@$registro[3]} = [$nroOrden,@$registro[6],$hash{$nroOrden}];
					}
				}
			}
		}
		mostrar_ganadores_sorteo();
	}else{
		my $rango = @rango;
		if( $rango == 2 ){
			foreach my $nroOrden( sort {$hash{$a} <=> $hash{$b} } keys %hash ){
				foreach my $registro(@adjud){
					if ( @rango[0] <= @$registro[3] and @rango[1] >= @$registro[3] and (@$registro[4] == $nroOrden ) and ($grupos{@$registro[3]}[0] =~ /^(ABIERTO|NUEVO)/) and ($temaLPadron{@$registro[6]}[5] != "") ){
						if( !$sorteoResponse{@$registro[3]} || $sorteoResponse{@$registro[3]}[2] > $hash{$nroOrden} ){
							$sorteoResponse{@$registro[3]} = [$nroOrden,@$registro[6],$hash{$nroOrden}];
						}
					}
				}
			}
			mostrar_ganadores_sorteo();
		}else{
			my $varios = @varios;
			if( $varios >= 1 and $grupoRef ne "all" ){
				foreach my $grupo(@varios){
					foreach my $nroOrden( sort {$hash{$a} <=> $hash{$b} } keys %hash ){
						foreach my $registro(@adjud){
							if ( $grupo == @$registro[3] and (@$registro[4] == $nroOrden ) and ($grupos{@$registro[3]}[0] =~ /^(ABIERTO|NUEVO)/) and ($temaLPadron{@$registro[6]}[5] != "") ){
								if( !$sorteoResponse{@$registro[3]} || $sorteoResponse{@$registro[3]}[2] > $hash{$nroOrden} ){
									$sorteoResponse{@$registro[3]} = [$nroOrden,@$registro[6],$hash{$nroOrden}];
								}
							}
						}
					}
				}
				mostrar_ganadores_sorteo();
			}
		}
	}

}

sub mostrar_ganadores_licitacion{
	if(!$resultado){
		foreach my $index( sort keys %licitacionResponse){
			print "Ganador por licitación del grupo $index Nro de Orden: $licitacionResponse{$index}[0], $licitacionResponse{$index}[1] con \$$licitacionResponse{$index}[3] (Nro de Sorteo $licitacionResponse{$index}[2])\n";
			if($grabar){
				push(@response,"Ganador por licitación del grupo $index Nro de Orden: $licitacionResponse{$index}[0], $licitacionResponse{$index}[1] con \$$licitacionResponse{$index}[3] (Nro de Sorteo $licitacionResponse{$index}[2])\n");
			}
		}
	}
}

sub ganadores_licitacion{
	my @idFecha = split("\_", $sorteoFile);
	cargar_fecha_adj((split("\\.",@idFecha[1]))[0]);
	print "Ganadores por Licitación @idFecha[0] de fecha @idFecha[1]\n\n";
	my @rango = split("-",$grupoRef);
	my @varios = sort(split(",",$grupoRef));
	if( $grupoRef eq "all" ){
		foreach my $nroOrden( sort {$hash{$a} <=> $hash{$b} } keys %hash ){
			foreach my $registro(@adjud){
				if ( (@$registro[4] == $nroOrden ) and ($grupos{@$registro[3]}[0] =~ /^(ABIERTO|NUEVO)/) and ($temaLPadron{@$registro[6]}[5] != "") ){
					if( !$licitacionResponse{@$registro[3]} || $licitacionResponse{@$registro[3]}[3] < @$registro[5] ){
						$licitacionResponse{@$registro[3]} = [$nroOrden,@$registro[6],$hash{$nroOrden},@$registro[5]];
					}else{
						if(($licitacionResponse{@$registro[3]}[3] == @$registro[5]) and ($licitacionResponse{@$registro[3]}[2] > $hash{$nroOrden})){
							$licitacionResponse{@$registro[3]} = [$nroOrden,@$registro[6],$hash{$nroOrden},@$registro[5]];
						}
					}
				}
			}
		}
		mostrar_ganadores_licitacion();
	}else{
		my $rango = @rango;
		if( $rango == 2 ){
			foreach my $nroOrden( sort {$hash{$a} <=> $hash{$b} } keys %hash ){
				foreach my $registro(@adjud){
					if ( @rango[0] <= @$registro[3] and @rango[1] >= @$registro[3] and (@$registro[4] == $nroOrden ) and ($grupos{@$registro[3]}[0] =~ /^(ABIERTO|NUEVO)/) and ($temaLPadron{@$registro[6]}[5] != "") ){
						if( !$licitacionResponse{@$registro[3]} || $licitacionResponse{@$registro[3]}[3] < @$registro[5] ){
							$licitacionResponse{@$registro[3]} = [$nroOrden,@$registro[6],$hash{$nroOrden},@$registro[5]];
						}else{
							if(($licitacionResponse{@$registro[3]}[3] == @$registro[5]) and ($licitacionResponse{@$registro[3]}[2] > $hash{$nroOrden})){
								$licitacionResponse{@$registro[3]} = [$nroOrden,@$registro[6],$hash{$nroOrden},@$registro[5]];
							}
						}
					}
				}
			}
			mostrar_ganadores_licitacion();
		}else{
			my $varios = @varios;
			if( $varios >= 1 and $grupoRef ne "all" ){
				foreach my $grupo(@varios){
					foreach my $nroOrden( sort {$hash{$a} <=> $hash{$b} } keys %hash ){
						foreach my $registro(@adjud){
							if ( $grupo == @$registro[3] and (@$registro[4] == $nroOrden ) and ($grupos{@$registro[3]}[0] =~ /^(ABIERTO|NUEVO)/) and ($temaLPadron{@$registro[6]}[5] != "") ){
								if( !$licitacionResponse{@$registro[3]} || $licitacionResponse{@$registro[3]}[3] < @$registro[5] ){
									$licitacionResponse{@$registro[3]} = [$nroOrden,@$registro[6],$hash{$nroOrden},@$registro[5]];
								}else{
									if(($licitacionResponse{@$registro[3]}[3] == @$registro[5]) and ($licitacionResponse{@$registro[3]}[2] > $hash{$nroOrden})){
										$licitacionResponse{@$registro[3]} = [$nroOrden,@$registro[6],$hash{$nroOrden},@$registro[5]];
									}
								}
							}
						}
					}
				}
				mostrar_ganadores_licitacion();
			}
		}
	}

}

sub usage{
	print << "NL";

        syntax:
                --a -ayuda
                       imprime este texto de ayuda
                -g
                       escribe el resultado de la consulta en un archivo luego de realizada una consulta, en caso de no indicar este comando el resultado de la consulta se mostrara por pantalla
                       perl DeterminarGanadores -r <consulta> -g
                -r
                       comando de consultas, puede realizar una consulta especificando codigo de oficina o aniomes, debe especificar al menos un filtro para la consulta
                       perl AFLIST -r <consulta> [-filtro] <parametro> 
                -s
                       comando para consultar estadisticas
                --exit
                			 salir de la ejecucion


       example: $0 -r RUV -c SIS -w
                $0 -r RUV	-a ALBANESIVALERIA,DOMINGUEZRAMON
                $0 -r RUV -t DDN --numB 11-34101307,11-43280820

NL
}

