## INCAPACHE (Is Not Comparable to APACHE)
N.B. il nome si pronuncia "incapaci" ;-)

Programma sviluppato a supporto del laboratorio di
Sistemi di Elaborazione e Trasmissione del corso di laurea
in Informatica classe L-31 presso l'Universita` degli Studi di
Genova.

Copyright (C) 2012-2014,2016 by Giovanni Chiola <chiolag@acm.org>
Copyright (C) 2015-2016 by Giovanni Lagorio <giovanni.lagorio@unige.it>
Copyright (C) 2017-2018 by Giovanni Chiola <chiolag@acm.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

--------------------------------------

Implementazione di un sottoinsieme del protocollo HTTP, nelle versioni
3.0 e 3.1: la prima gestisce una sola richiesta per ogni connessione
(con HTTP/1.0), mentre la seconda gestisce piu` richieste HTTP/1.1
successive sulla stessa connessione in modalita` "pipeline", lanciando
in esecuzione piu` thread di risposta per velocizzare l'interazione
col browser.

Il makefile crea un binario di proprieta` dell'utente root con il flag
setuserid attivato, tramite sudo, quindi e` necessario avere i privilegi
di amministrazione (=il comando make potrebbe richiedere la vostra
password).
Questo serve per poter eseguire la chiamata di sistema chroot()
e restringere i file che possono essere inviati al browser al
solo contenuto della directory www root.

Se, per qualsiasi ragione, non volete utilizzare l'account di root,
e` possibile generare un file che non richiede il flag setuserid
(ovviamente non potra` fare chroot) tramite appositi flag di compilazione
(vedi Makefile).

L'eseguibile lancia in background un secondo processo, corrispondente
al comando "file", per ottenere il "mime-type" da restituire nell'header
della risposta.
Questa informazione puo` essere generata lanciando da shell il
comando:
file -i nomefile

Per lanciare il programma e` necessario specificare la directory www-root
e, opzionalmente, la porta TCP su cui mettersi in ascolto.
Per esempio:
bin/incapache www-root 80

Il sever usa il meccanismo dei Cookies per assegnare un identificatore
a ogni utente che lo contatta, e successivamente conta il numero di
richieste provenienti dallo stesso client.

## Laboratorio incApache
Nella terza e ultima esercitazione realizziamo un web server che vuole imitare il web server Apache ma riesce a fare molto meno. Per questo motivo lo chiameremo incApache (incApache is not comparable to Apache, pronunciato all'americana come "incapaci").
IncApache riconosce solo i metodi HEAD e GET, non è in grado di comprendere il metodo POST, il quale usa thread multipli per gestire più connessioni contemporanee da parte di client (browser) diversi. Per il momento il vantaggio dell'uso dei pthread invece di processi multipli creati con fork() è solo una (modesta) riduzione della quantità di risorse utilizzate a livello di sistema. Tuttavia l'uso dei thread ci consentirà successivamente di implementare le estensioni richieste per la versione 2.1 del server.

Nella versione 2.0 il processo che gestisce le richieste e risposte HTTP lancia un numero predeterminato di thread indipendenti nella fase di inizializzazione, e questi thread rimangono attivi fino alla terminazione del processo stesso (che può essere ottenuta solo da shell, mandando un SIGKILL). Ogni thread accetta una richiesta di connessione, interpreta la richiesta HTTP, manda la corrispondente risposta HTTP, chiude la connessione e torna ad accettare una nuova connessione. Poiché però tutti i thread accettano connessioni dallo stesso socket in modalità listen(), occorre prevenire corse critiche mediante l'uso delle primitive: pthread_mutex_lock() e pthread_mutex_unlock().

## Laboratorio IncApache: parte opzionale
### HTTP/1.1 con pipeline

Eccoci arrivati alla parte opzionale di incApache: si consiglia di procedere con questa parte solo dopo aver ottenuto il perfetto funzionamento della versione 3.0, anche in caso di apertura di connessioni multiple.

Nella rete odierna un servizio online in grado di gestire una richiesta alla volta non avrebbe alcun senso, si tratterebbe di un servizio destinato a fallimento certo. Per questo motivo già incApache 3.0 adotta la tecnica dei thread multipli, ciascuno dedicato a rispondere a una connessione diversa. Nella versione 3.1 incApache, oltre a usare i thread per gestire connessioni multiple (cioè richieste in arrivo da più client), prova anche a sfruttare i thread per aumentare la propria velocità di risposta nel caso in cui il client gestisca le connessioni in una modalità detta di pipeline.

HTTP/1.1 allows multiple HTTP requests to be written out to a socket together without waiting for the corresponding responses. The requestor then waits for the responses to arrive in the order in which they were requested. The act of pipelining the requests can result in a dramatic improvement in page loading times, especially over high latency connections.

