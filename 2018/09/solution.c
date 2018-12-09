#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "dll.h"

#define PLAYERS 464
#define MARBLES 7091800

int main(int argc, char *argv[]) {
  char *filename;
  FILE *input;
  char line[1024];
  long multiplier = 1;

  if (argc > 1) {
    filename = argv[1];
  }
  else {
    filename = "input";
  }
  if (argc > 2)
    multiplier = 100;

  input = fopen(filename, "r");
  if (!input) {
    perror("Could not open input file");
    exit(1);
  }

  while (fgets(line, sizeof(line), input)) {
    long players = PLAYERS;
    long marbles = MARBLES;
    int player = 0;
    dll_node_t *current, *tmp;
    long *hs;

    sscanf(line, "%ld players; last marble is worth %ld points", &players, &marbles);

    marbles *= multiplier;
    
    printf("Running game with %ld players and %ld marbles\n", players, marbles);

    hs = malloc(sizeof(long)*players);

    for (int player = 0; player < players; player++) {
      hs[player] = 0;
    }
    
    current = dll_init(0);
    
    for (int marble = 1; marble <= marbles; marble++) {
      player++;
      if (player >= players)
	player = 0;
      
      if (marble % 23) {
	current = dll_ib(current->next->next, marble);
      }
      else {
	hs[player] += marble;
	for (int i = 0; i<7; i++) {
	  current = current->prev;
	}
	hs[player] += current->data;
	//printf("-- %5d %5d\n", marble, current->points);
	current = dll_da(current);
      }
    }
    
    long max_hs = 0;
    for (player = 0; player<players; player++) {
      if (hs[player] > max_hs) {
	max_hs = hs[player];
      }
    }
    
    printf("Solution: %ld\n", max_hs);

    free(hs);
  }
}
    
