ping-pong 5.3

Programma sviluppato a supporto del laboratorio di
Sistemi di Elaborazione e Trasmissione del corso di laurea
in Informatica classe L-31 presso l'Universita` degli Studi di
Genova, anno accademico 2018/2019.

Copyright (C) 2013-2014 by Giovanni Chiola <chiolag@acm.org>
Copyright (C) 2015-2016 by Giovanni Lagorio <giovanni.lagorio@unige.it>
Copyright (C) 2017-2018 by Giovanni Chiola <chiolag@acm.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

--------------------------------------

Implementazione di un server "pong" e di due client "ping" nelle
due versioni UDP e TCP.

Per compilare da shell lanciare "make" dalla directory che contiene il Makefile.
Nelle directory sono anche presenti dei file CMakeList.txt, che permettono di compilare tramite CMake, o aprire il tutto come "progetto" di CLion (https://www.jetbrains.com/clion/).

## Client Ping TCP

Nella prima esercitazione si deve realizzare un processo client Ping TCP che si connette ad un server Pong in ascolto su una porta alta (>= 1024). 

Troverete dei sorgenti INCOMPLETI nell'archivio TGZ su aulaweb; dovrete riempire le parti marcate con "TO BE DONE" per ottenere client/server funzionanti. Anche se l'archivio contiene già la parte UDP, per questa volta considerate solo il TCP.

Il processo Ping si connette al server Pong e invia un messaggio di richiesta contenente la stringa di caratteri "TCP " seguita dalla lunghezza dei messaggi (in byte) e dal numero di ripetizioni; la stringa è terminata dal carattere di terminazione di linea '\n'.

Es. "TCP 64 280\n"

Il server Pong, ricevuta e riconosciuta la stringa di richiesta, risponde "OK\n", dopo di che agisce come Pong secondo le modalità concordate.

In caso di errore, il server Pong risponde invece "ERROR\n" e chiude la connessione.

Dopo aver ricevuto la risposta OK, Ping invia il primo messaggio dati: una sequenza lunga quanto specificato nel messaggio di richiesta, formata da valori zero, che deve contenere all'inizio la stringa di caratteri "1\n". Pong si limita a restituirglielo il più rapidamente possibile. Ping calcola il RTT necessario perché il messaggio compia un percorso di "andata e ritorno", poi invia il secondo messaggio dati che inizia con la stringa "2\n", ecc., fino a completare il numero di tentativi concordato.


## Server Pong

Per testare il vostro client/server, prima di averli completati entrambi e/o per vedere cosa ci si aspetta in output, potete usare i binari precompilati disponibili su aulaweb.

Alternativamente, potete usare il pong-server che risponde alla porta 1491 dell'host webdev.dibris.unige.it

## Client  UDP Ping

Anche in questo caso il processo client UDP Ping si connette inizialmente a un server Pong in ascolto su una porta alta (>= 1024), mediante una connessione STREAM (TCP).

Ping si connette al server nello stesso modo già implementato la settimana scorsa per la versione TCP e invia un primo messaggio contenente la stringa di caratteri "UDP " seguita dalla lunghezza dei messaggi (in byte) e dal numero di ripetizioni; la stringa è terminata dal carattere di terminazione di linea '\n'. Il server Pong, ricevuta e riconosciuta la stringa di richiesta, risponde "OK numport\n", dopo di che agisce come Pong secondo le modalità concordate. In caso di errore, il server Pong risponde invece "ERROR\n" e chiude la connessione.

Dopo aver ricevuto la risposta OK, il client UDP Ping deve chiudere la connessione TCP, creare un nuovo socket di tipo DGRAM, e cominciare a inviare datagrammi UDP al server Pong sulla porta che il server ha precedentemente indicato. Anche in questo caso i datagrammi devono contenere in testa le stringhe di caratteri "1\n", "2\n", ecc. ad indicare il numero di invio fino a completare il numero di tentativi concordato.

Una delle principali differenze rispetto al ping-pong TCP deriva dalla inaffidabilità del protocollo UDP: i datagrammi possono andare persi, e quindi occorre gestire un meccanismo di time-out sul client Ping per gestire le situazioni di mancanza di risposta. Si richiede di contare il numero totale di datagrammi persi e di effettuare un numero limitato di tentativi di ritrasmissione prima di desistere e passare allo scambio del datagramma successivo, in modo da garantire comunque la terminazione del programma. Nel caso di perdita di un datagramma si ritorna come valore di RTT il tempo effettivamente speso in attesa (>= time-out).

Nell'archivio distribuito nella prima esercitazione trovate anche il file udp_ping.c, scheletro del processo  UDP Ping (da usare dopo aver completato la versione per TCP).

Il client  UDP Ping, usando le funzioni per la gestione dei socket, deve:

    Inizializzare una struttura dati di tipo addrinfo con le informazioni per la connessione: vedi funzione getaddrinfo() e i commenti alla sezione Strutture dati e funzioni di conversione (ricordandosi di disallocare le strutture dati dinamiche quando non servono più, vedi funzione freeaddrinfo()).
    Creare un canale di comunicazione: vedi funzione socket().
    Connettersi al server Pong: vedi funzione connect().
    Leggere da argv[] la dimensione del messaggio che il client intende spedire e il numero di ripetizioni.
    Preparare una richiesta di ping-pong scrivendo la stringa di caratteri "UDP " seguita dalla lunghezza dei messaggi (in byte) e dal numero di ripetizioni; la stringa è terminata dal carattere di terminazione di linea '\n'.
    Scrivere la stringa di richiesta sul socket: vedi funzione write().
    Leggere dal socket la risposta restituita dal server Pong: vedi funzione read().

    [Nota: da qui inizia la parte diversa rispetto al client TCP]
    Se il server risponde "OK numport\n" proseguire, altrimenti (risposta "ERROR\n") segnalare un errore.
    In caso di risposta positiva, il client Ping deve leggere il numero di porta sulla quale Pong si è messo in attesa di messaggi e chiudere la connessione TCP instaurata per negoziare il tipo di connessione successiva
    A questo punto, Pong deve creare un socket di tipo DGRAM e usarlo per inviare la sequenza di datagrammi concordata verso il server, usando il numero di porta alta appena ricevuto. Va quindi inizializzata una struttura dati addrinfo con gli opportuni parametri per connessioni UDP (come si può vedere nella funzione prepare_udp_socket() nello scheletro del programma).
    Sul nuovo socket devono essere inviati i messaggi concordati, ciascun messaggio deve contenere in testa una stringa di caratteri che rappresenta il numero di invio (cominciando da "1\n"): vedi funzione doPing().
    Al termine, si deve chiudere il socket: vedi funzione close().


## Il server Pong

Il server Pong è lo stesso dell'altra volta in ascolto sulla macchina webdev.dibris.unige.it sulla porta 1491. In alternativa potete anche usare gli eseguibili distribuiti nei file di supporto e lavorare in locale.


## Esperimenti ripetuti

Per raccogliere dei dati significativi dalle interazioni Ping/Pong si devono fare esperimenti ripetuti per smorzare gli effetti dovuti alla variabilità delle condizioni della rete. Maggiore il numero delle ripetizioni e migliore l'approssimazione calcolata mediante il valor medio oppure il valore mediano. Per costruire un insieme di esperimenti ripetuti in questa esercitazione useremo degli script bash, senza modificare ulteriormente i programmi C precedentemente sviluppati.

Uno script bash è un file contenente una lista di comandi che si possono lanciare in una shell bash. Il file deve essere eseguibile (chmod u+x nomefile). Uno script bash inizia con la direttiva #!/bin/bash; "#!" è detto shebang, /bin/bash indica l'interprete di comandi usato, in questo caso proprio bash.

Uno script bash può contenere dei commenti su righe che iniziano con il simbolo #. Si possono creare delle variabili assegnandovi dei valori (es. protocol=TCP, non si possono mettere blank prima e dopo =). Per usare le variabili si deve mettere un $ davanti al loro nome (es. $protocol). Le variabili possono essere dichiarate usando lo statement declare.

Uno script può chiedere dei dati in input all'utente, ad esempio:

#! /bin/bash
echo -n "Select the protocol (TCP, UDP): "
read -e protocol
echo "You have selected a $protocol socket"

E' anche possibile passare dei parametri a uno script (si devono elencare dopo il nome dello script). Il primo parametro è indicato con $1, il secondo parametro con $2, ecc. Si può inoltre controllare il numero di parametri passati allo script, come descritto nel frammento seguente.

#! /bin/bash
# Expects MaxUDPsize and MaxTCPsize as parameters
if [[ $# != 2 ]] ; then printf "\nError: MaxUDPsize and MaxTCPsize expected as parameters\n\n" ; exit 1; fi

Notate le analogie con i parametri argc e argv del main di un programma C. Notate anche l'analogia del comando printf con l'omologa funzione del C. Queste analogie non sono ovviamente casuali, ma derivano dalla lunga storia che ha portato alla attuale definizione di bash (derivante sia dalla shell di Bourne che da quella originariamente chiamata "csh", che incorporava parecchi costrutti del linguaggio C). Da questi esempi si dovrebbe intuire quindi che uno script può implementare algoritmi quasi altrettanto complessi di quelli implementabili in C.

I file di supporto forniti nell'archivio per questa settimana sono degli script bash mediamente complessi, contenuti nella directory scripts.

Lo script mkfile.bash permette di creare dinamicamente --- all'interno della directory data creata dal Makefile usato nelle settimane precedenti --- un altro Makefile che, a sua volta, si occuperà di lanciare i programmi specificati.

Gli eseguibili per TCP e UDP vengono lanciati con parametri via via crescenti che corrispondono alle dimensioni dei messaggi utilizzati nell'interazione Ping/Pong. Si può partire da una dimensione minima pari a 16 byte ogni volta aumentarla fino a raggiungere le dimensioni massime (MaxUDPsize e MaxTCPsize) richieste in input come parametri dello script mkfile.bash.

Dopo aver lanciato un certo numero di interazioni Ping/Pong TCP e UDP, nella directory data sono creati dei file che contengono i risultati delle interazioni stesse (es. tcp_32.out, udp_64.out, ecc.). Questi file di risultati vengono usati dallo script collect_throughput.bash per costruire i file tcp_throughput.dat e udp_throughput.dat.

Lo script collect_throughput.bash, tramite il comando grep, estrae dai file dei risultati le informazioni che servono per la generazione dei grafici. Un esempio di file udp_throughput.dat generato da collect_throughput.bash contiene, per ogni dimensione del messaggio, il throughput (mediana e media) appena calcolato ed è visualizzato qui sotto:

8 0.73956 0.696021
12 1.23311 1.14401
16 1.25886 1.25622
24 1.8297 1.81628
32 2.53767 2.41937
48 3.66279 3.44167
64 5.68966 5.59017
96 9.66534 8.96055
128 10.378 10.0636
192 16.8455 15.9299
256 22.2467 21.8459
384 39.2704 37.6286
512 49.021 47.9567
768 53.8102 51.9505
1024 80.414 80.0292
1536 92.0006 89.1886
2048 156.805 200.999

L'ultima parte dello script collect_throughput.bash è necessaria per ottenere un ordine crescente nella prima colonna relativa alla dimensione dei messaggi. I file di output nella directory data sono infatti elencati in ordine lessicografico (provate il comando ls nella directory stessa e guardate l'ordinamento dei file).

Infine, i file così creati vengono forniti in input allo script gplot.bash che contiene comandi propri di gnuplot per realizzare un grafico (in questo caso per visualizzare le curve di throughput in funzione della dimensione dei messaggi per le versioni UDP e TCP del Ping/Pong). Lo script genera un file .png che può essere aperto con un visualizzatore di immagini.

Per vedere i costrutti che si possono usare in uno script bash potete usare la pagina del man, leggere il libro (liberamente scaricabile) The Linux Command Line, oppure cercare un tutorial in rete.

Per la generazione dei grafici mediante gnuplot vi rimandiamo alla documentazione presente in rete, partendo per esempio da un sito ufficiale.

Banda, Latenza, Throughput e Delay

Il termine banda indica la massima velocità di trasmissione per il trasferimento di grandi quantità di dati attraverso un canale di comunicazione. Si misura in bit al secondo, abbreviato in bit/s o b/s o bps (bitrate), oppure in byte al secondo, abbreviato in Byte/s o B/s o Bps.

La latenza indica invece il minimo tempo di trasmissione per il trasferimento di una piccola quantità di bit, ed è determinata prevalentemente dalla distanza fisica tra mittente e destinatario e dalla velocità di propagazione dei segnali (spesso prossima alla velocità della luce). Si misura in secondi, abbreviato s.


Il throughput misura la quantità di dati trasmessi dal nodo sorgente al nodo destinatario nell'unità di tempo, e varia in funzione della lunghezza dei messaggi espressa in bit o byte. A volte si definisce come goodput (o throughput utile a livello utente) la quantità di bit o Byte del payload di un pacchetto incapsulato in un frame di un protocollo di comunicazione diviso per il ritardo medio di trasmissione del pacchetto, in modo da distinguerlo dal raw throughput che caratterizza il canale fisico utilizzato, scartando le informazioni di overhead associate ai protocolli durante la trasmissione e gli eventuali pacchetti reinviati.

In una rete packet-switched si indica col termine delay la misura del tempo medio che un pacchetto impiega per andare dal nodo sorgente al nodo destinatario (one-way trip). La misura più semplice da ottenere è tuttavia il tempo medio di round-trip misurato da una applicazione tipo Ping/Pong, che corrisponde alla somma dei due delay del messaggio inviato da Ping e della risposta di Pong (trascurando il tempo di elaborazione su Pong dopo la ricezione del messaggio e prima dell'invio della risposta). Se non ci sono motivi particolari per dubitare che il canale sia simmetrico, si assume che i due delay del messaggio e della risposta siano uguali e pari a un mezzo del round-trip time misurato.

Dato un messaggio lungo N byte, esiste una relazione tra le quantità misurabili che abbiamo definito, che può essere espressa dalla formula:

T(N) * D(N) = N


ovvero, il prodotto del delay (D) misurato per il throughput (utile a livello utente, T) misurato è sempre uguale al numero di Byte (o bit) trasmessi (N). Di conseguenza è sufficiente effettuare una sola misurazione (tipicamente quella del round-trip time) con messaggi di una certa lunghezza prefissata N per determinare sia il delay che il throughput corrispondenti a quella lunghezza di messaggi. Ovviamente, siccome siamo interessati a una stima di valor medio di valori non deterministici, la singola misurazione deve essere ripetuta tante volte in modo da raccogliere una statistica significativa.

Il modello Banda-Latenza permette di approssimare il delay di una rete mediante una semplice formula lineare:

D(N) = L_0 + \frac{N}{B}

dove D(N) indica il delay per la trasmissione di un messaggio di N byte, L0 indica la latenza per la trasmissione di un messaggio di zero byte e B indica la massima banda per la trasmissione di messaggi molto lunghi.

Per poter applicare il modello Banda-Latenza bisogna stimare i valori dei due parametri L0 e B che caratterizzano il canale di trasmissione utilizzato, e questo può essere fatto misurando il delay effettivo con due messaggi di dimensione diversa: un messaggio molto breve di dimensione N1 e un messaggio molto lungo di dimensione N2. Quindi si imposta e risolve un sistema lineare di due equazioni nelle due incognite L0 e B, ottenendo:

B= \frac{N_2-N_1}{D(N_2)-D(N_1)}

L_0 = \frac{D(N_1)*N_2 - D(N_2)*N_1}{N_2-N_1}

Task da svolgere per la terza parte del laboratorio

Leggete il file README per capire come lanciare il primo script che genera il  Makefile che viene salvato nella directory data.

Dopo aver familiarizzato con gli script bash nella directory scripts e con i file di output nella directory data dovete preparare uno script bash che, a partire dai file di output creati nella directory data, permetta di mettere a confronto l'andamento del throughput con la curva che si ottiene applicando il modello Banda-Latenza.

Le due immagini seguenti descrivono il risultato che deve essere prodotto dallo script nel caso di TCP e UDP. Sull'asse delle x si leggono le dimensioni dei messaggi, sull'asse delle y i valori di throughput effettivamente misurati confontati con i valori ottenuti dal modello (dopo averne stimato i parametri L0 e B).
