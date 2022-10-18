bush-- is a very simple (and extremely limited) shell for Unix, born as
a simplified version of Chiola's bush which, in turn, is a simplified version of bash
(bush is the recursive acronym of: "bush's unlike bash").

bush-- understands the following four built-in commands (square-brackets denote
optionality):

- @cd [pathname]
- @set identifier = name
- @show-variables
- @quit

and, as other shells, it can run any external command, redirecting its input
and/or output with the following syntax:
executable-name [arg1] [arg2] ... [< input-filename] [> output-filename]

Note that, for simplicity sake, input redirection, when present, must occur
before output redirection.

A variable name must be a "standard" identifier, while other names consist
of a non-empty sequence of:
- strings (without special characters); e.g.: foo
- value of variables; e.g.: $foo or ${bar}
- string literals, between single quotes; e.g.: '$foo is not a variable'
- escaped chars; e.g. \$ \n

A simple example session of bush-- is the following:

bush-- $ @set foo=SET
bush-- $ @set foo=${foo}'2015/2016'
bush-- $ echo $foo
SET2015/2016
bush-- $ ls -l
total 104
-rwxrwxr-x 1 gio gio 93904 nov  7 16:12 bmm

## Descrizione del problema

La seconda esercitazione ha come scopo il consolidamento della comprensione della struttura di un sistema operativo Unix-like e, in particolare, ci concentreremo sulla shell affrontando i seguenti argomenti:

    ruolo della shell
    uso delle system call POSIX per
        gestione dei processi (fork, execve, wait, exit)
        gestione delle pipe e dei file descriptor (pipe, dup2, open, fcntl)
        verifica dei permessi di accesso ai file access

Lo sviluppo di una "vera" shell richiederebbe uno sforzo di programmazione non indifferente per l'implementazione delle parti di analisi lessicale e sintattica delle stringhe che descrivono comandi e parametri. Per questo motivo, la parte del codice riferito al parsing dei comandi viene fornita già completa.

La shell richiesta (chiamata "bush--") è stata notevolmente semplificata nelle sue funzionalità rispetto alle altre shell normalmente disponibili su Linux e quindi potrebbe dare degli errori in caso di uso di comandi non implementati o implementati in modo solo parziale. Vedete il file README per avere una breve descrizione, e qualche esempio d'uso, dei comandi supportati.
File di supporto

Viene fornito un archivio contenente:

    il README: partite da questo file! Contiene una breve descrizione della shell, dei comandi supportati e un esempio d'uso
    il Makefile: durante la compilazione vengono creati, a partire dalle specifiche del lexer in flex (lexer.l) e del parser in bison (parser.y), dei sorgenti C chiamati autogen... (ovviamente, tali file non vanno modificati perché verrebbero sovrascritti in seguito a modifiche di lexer.l/parser.y)
    il file CMakeLists.txt, che potete tranquillamente ignorare se non sapete cos'è (viceversa, se usate un IDE che supporta quel tipo di file, come per esempio CLion, potete creare un progetto a partire da quello)
    ast.c/ast.h: implementazione dei nodi dell'Abstract Syntax Tree, prodotto dal parsing dei comandi
    bmc.c: file principale, contenente il main
    lexer.l: file di input per flex, definisce tutte le regole lessicali del linguaggio
    parser.y: file di input per bison che contiene la grammatica del linguaggio
    shell.c/shell.h: implementazione della "classe" shell
    str.c/str.h: implementazione della "classe" str, di supporto alla fase di parsing
    utils.c/utils.h: implementazione di alcune funzioni di utilità
    var_table.c/var_table.h: implementazione della "classe" var_table, corrispondente alla tabella delle variabili, usata dalla shell

I sorgenti contenuti all'interno dell'archivio fornito sono compilabili, ma incompleti. Prima di tutto, date un'occhiata alle parti già presenti, cercando di capire come interagiscono fra di loro e a cosa servono. Come descritto a lezione, abbiamo cercato di usare un approccio object-oriented che, in C, richiede un po' di lavoro "manuale" (per esempio, passare esplicitamente il this) ma dovrebbe rendere l'implementazione più semplice.

Poi, cercate le zone racchiuse fra /*** TO BE DONE START ***/ e /*** TO BE DONE END ***/ e completatele seguendo le indicazioni (che troverete nei commenti).

Per "debuggare" i problemi legati alla (de)allocazione della memoria e l'uso dei puntatori, suggeriamo di provare valgrind.
drwxrwxr-x 2 gio gio  4096 nov  7 15:47 Debug
bush-- $ ls -l | grep ebu > foobar
bush-- $ cat < foobar
drwxrwxr-x 2 gio gio  4096 nov  7 15:47 Debug
bush-- $ @cd Debug
bush-- $ pwd
[...]/bin/Debug
bush-- $

