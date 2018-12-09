#include <stdlib.h>
#include "dll.h"

dll_node_t *dll_init(DLL_TYPE val) {
  dll_node_t *temp;
  temp = malloc(sizeof(dll_node_t));
  temp->data = val;
  temp->next = temp->prev = temp;
  return temp;
}

dll_node_t *dll_ia(dll_node_t * current, DLL_TYPE val) {
  dll_node_t *temp;
  temp = malloc(sizeof(dll_node_t));
  temp->data = val;

  temp->prev = current;
  temp->next = current->next;
  current->next = temp;
  temp->next->prev = temp;

  return temp;
}

dll_node_t *dll_ib(dll_node_t * current, DLL_TYPE val) {
  dll_node_t *temp;
  temp = malloc(sizeof(dll_node_t));
  temp->data = val;

  temp->prev = current->prev;
  temp->next = current;

  temp->prev->next = temp;
  current->prev    = temp;

  return temp;
}

dll_node_t *dll_da(dll_node_t * current) {
  dll_node_t *temp;
  temp = current->next;
  current->prev->next = current->next;
  current->next->prev = current->prev;
  free(current);
  return temp;
}

dll_node_t *dll_db(dll_node_t * current) {
  dll_node_t *temp;
  temp = current->prev;
  current->prev->next = current->next;
  current->next->prev = current->prev;
  free(current);
  return temp;
}
  
