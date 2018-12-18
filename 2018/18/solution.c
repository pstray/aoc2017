#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_LINE 1024

int main(int argc, char *argv[]) {
  FILE *input;
  char *input_name;

  char *data, *ndata;
  long data_size;
  long data_length;
  char line[MAX_LINE];
  long max_x = 0;
  long max_y = 0;
  long x, y;

  long time = 0;
  long count[256];

  input_name = "input";
  if (argc>1)
    input_name = argv[1];
  input = fopen(input_name, "r");
  if (!input) {
    perror("open");
    exit(1);
  }

  data_size = 1024;
  data_length = 0;
  data = malloc(data_size);
  if (!data) {
    perror("malloc");
    exit(1);
  }
  data[0] = '\0';

  max_x = 0;
  line[0] = '*';
  while (fgets(line+1, MAX_LINE-2, input)) {
    int ll;
    ll = strlen(line);
    max_x = ll;
    
    while (data_length + max_x * 3 >= data_size) {
      data_size *= 2;
      data = realloc(data, data_size);
      if (!data) {
	perror("realloc");
	exit(1);
      }
    }
    
    if (!data_length) {
      memset(data, '*', ll);
      data[ll-1] = '\n';
      data[ll] = 0;
      max_y = 1;
      data_length = strlen(data);
    }
    
    memcpy(data+data_length, line, data_size-data_length);
    data_length = strlen(data);
    max_y++;
  }
  
  memcpy(data+data_length, data, max_x);
  data_length = strlen(data);
  max_y++;
  
  // printf("[%s] %ld %ld\n", data, max_x, max_y);

  while (time < 10) {

    ndata = strdup(data);
    for (y=1; y<max_y-1; y++) {
      for (x=1; x<max_x-1; x++) {
	count['.'] = 0;
	printf("%c", data[y*max_x+x]);
      }
      printf("]\n");
    }

    free(data);
    data = ndata;

    break;


  }
  
  
  
  
  

  return 0;
}
