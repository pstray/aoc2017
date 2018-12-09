#ifndef DLL_H
#define DLL_H

#include "config.h"

#ifndef DLL_TYPE
#warning Defaulting DLL_TYPE to long
#define DLL_TYPE long
#endif

typedef struct dll_node {
  struct dll_node *prev;
  struct dll_node *next;
  DLL_TYPE data;
} dll_node_t;

dll_node_t *dll_init(DLL_TYPE val);
dll_node_t *dll_ia(dll_node_t * current, DLL_TYPE val);
dll_node_t *dll_ib(dll_node_t * current, DLL_TYPE val);
dll_node_t *dll_da(dll_node_t * current);
dll_node_t *dll_db(dll_node_t * current);

#endif
