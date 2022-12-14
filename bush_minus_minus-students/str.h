/*
 * bush--
 *
 * Programma sviluppato a supporto del laboratorio di
 * Sistemi di Elaborazione e Trasmissione del corso di laurea
 * in Informatica classe L-31 presso l'Universita` degli Studi di
 * Genova, anno accademico 2018/2019.
 *
 * Copyright (C) 2015-2018 by Giovanni Lagorio <giovanni.lagorio@unige.it>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

#ifndef STR_H
#define STR_H

struct str;
struct str *str_new();
void str_destroy(struct str * const this);
char *str_destroy_stealing_chars(struct str * const this);
void str_append(struct str * const this, const char *chars);

#endif /* #ifndef STR_H */
