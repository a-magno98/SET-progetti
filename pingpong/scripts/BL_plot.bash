#!/bin/bash

set -e

readonly Dir='../data' 
declare -a arr=("tcp" "udp")



#DEVO CREARE 2 GRAFICI###############################################################
for ProtocolName in "${arr[@]}"
do
    #FILE DA PASSARE A GNUPLOT###############################################
    InputFile="${Dir}/${ProtocolName}_throughput.dat"
    
    #FILE PNG PER IL GRAFICO#################################################
    OutputPngFile="${Dir}/${ProtocolName}_banda_latenza.png"
    
    #FILE DAT PER SALVARE IL DELAY###########################################
    OutputDatFile="${Dir}/${ProtocolName}_delay.dat"
    
    
    #SE CI SONO VECCHIE VERSONI LE RIMUOVO###################################
    if [ -e ${OutputDatFile} ]
     then 
     	echo  "*** FOUND OLDER VERSION::: now removing ***"
        rm -v ${OutputDatFile} ${OutputPngFile} 
    fi
    
    #SALVO VALORI NECESSARI ALLA COSTRUZIONE GRAFICO IN VARIABILI 'N' E 'T'##
    #NB:: DECIDIAMO DI USARE IL VALORE MEDIO###############################
    
    #PRIMA RIGA#######
    N_MIN=$(head -n 1 ${InputFile}| cut -d' ' -f1 )
    T_MIN=$(head -n 1 ${InputFile}| cut -d' ' -f3 )
    
    #ULTIMA RIGA######
    N_MAX=$(tail -n 1 ${InputFile}| cut -d' ' -f1 )
    T_MAX=$(tail -n 1 ${InputFile}| cut -d' ' -f3 )
    
    #INTERFACCIA UTENTE####################################################
    echo "*** INPUT PARAMETERS::: using 1st and last line ***"
    echo "N_MIN:${N_MIN} T_MIN:${T_MIN} N_MAX:${N_MAX} T_MAX:${T_MAX}"
    
    #CALCOLO 'B' E 'L'###############################################
    echo "*** EVALUTATING EXPRESSION::: please wait! ***"
    
    #CHIAMATA A 'bc' PER EFFETTUARE I CALCOLI########################
    #CALCOLO IL DELAY#############################################
    DelayMin=$(bc <<<"scale=10;${N_MIN}/${T_MIN}")
    DelayMax=$(bc <<<"scale=10;${N_MAX}/${T_MAX}")
    
    Denominatore=$(bc <<< "scale=10;${DelayMax}-${DelayMin}")
    
    echo "Delay min:${DelayMin} Delay max:${DelayMax}"
    
    #CALCOLO BANDA E LATENZA######################################
    L=$(bc <<< "scale=10;( ( ${DelayMin} * ${N_MAX} ) - ( ${DelayMax} * ${N_MIN} ) ) / ( ${N_MAX} - ${N_MIN} )")
    B=$(bc <<< "scale=10;(${N_MAX}-${N_MIN})/${Denominatore}")
    
    echo "Latency:${L} Bandwidth:${B} "

    #SALVO I VALORI 'B' E 'L' NEL FILE DAT########################
    echo "*** WRITING DATA ON DAT FILE::: please wait! ***"
    
    #CICLO FOR PER CREARE E SCRIVERE SUL FILE I VALORI DI ASCISSE ED ORDINATE# 
    MinSize=${N_MIN}
    MaxSize=${N_MAX}

    for (( (NUMERO_LINEA=1 , sz=$MinSize, mid=$MinSize/2) ; $sz <= $MaxSize ; (++NUMERO_LINEA , mid=$sz, sz*=2) ))
    do 
    
        N=$sz
        
        D=$(bc <<<"scale=10;( ${L} + ( ${N} / ${B} ) )")
        Latency_Bandwith=$(bc <<<"scale=10;${N} / ( ${D} )")
        echo "${NUMERO_LINEA} N:${N} D:${D} L_B:${Latency_Bandwith} "
        printf "$N ${Latency_Bandwith} \n" >> ${OutputDatFile}
        
        
        let mid+=$sz
        
        
        if (( $mid <= $MaxSize )); 
        
        then 
            N=$mid
            
            let ++NUMERO_LINEA
            
            D=$(bc <<<"scale=10;( ${L} + ( ${N} / ${B} ) )")
            Latency_Bandwith=$(bc <<<"scale=10;${N} / ( ${D} )")
            echo "${NUMERO_LINEA} N:${N} D:${D} L_B:${Latency_Bandwith} "
            printf "$N ${Latency_Bandwith} \n" >> ${OutputDatFile}
            
            fi
            
        
    done
    
    
    #CREAZIONE DEL GRAFICO#############################################
    echo "*** CREATING GRAPH::: calling gnuplot! ***"
    
    #CHIAMO GNUPLOT###############################################
    #IMPOSTO DIMENSIONE OUTPUT 900*700##########################
    #IMPONGO ASSE X = log2####################################
    #IMPONGO ASSE Y = Log###################################
    #IMPONGO DIMENSIONE ASCISSE ED ORDINATE###############
    #PASSO IN INPUT I FILE NECESSARI####################
    
gnuplot <<-eNDgNUPLOTcOMMAND
    
    set term png size 900,700
    set xrange[${MinSize}:(${MaxSize}*2)]
	set yrange[10:${Latency_Bandwith}*10]
	
    set logscale x 2
	set logscale y 10
	set xlabel "msg size (B)"
	set ylabel "throughput (KB/s)"
	
	set output "../data/$OutputPngFile"
	plot "../data/${OutputDatFile}" using 1:2 title "Latency-Bandwidth model with L=${L} and B=${B}"\
	    with linespoint, \
	     "../data/${InputFile}" using 1:3 title "${ProtocolName} ping-pong Throughput (average)" \
			with linespoints
			
clear 
eNDgNUPLOTcOMMAND

#FINE#
echo "*** PROCESS COMPLETE: done! *** 

"
done 
