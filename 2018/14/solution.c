#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_STR 1000

int main(int argc, char *argv[]) {
  FILE *input;
  char *input_file = "input";

  char line[MAX_STR];
  char *input_str;
  long input_num;
  long input_len;

  char *data;
  size_t data_size;
  long data_len;
  long haystack_offset;
  char *haystack;

  long pos1, pos2, s1, s2, sum;
  char *pos_at;
  long pos;

  char out_str[MAX_STR];

  if (argc > 1)
    input_file = argv[1];

  input = fopen(input_file, "r");

  if (!input) {
    perror("Open");
    exit(1);
  }

  while (fgets(line,sizeof(line), input)) {
    input_str = line;
    while (*input_str != 0 && (*input_str < 0x30 || *input_str > 0x39))
      input_str++;
    input_len = 0;
    while (input_str[input_len] &&
	   input_str[input_len] >= 0x30 &&
	   input_str[input_len] <= 0x39)
      input_len++;
    input_str[input_len] = 0;
     
    haystack_offset = input_len+1;
    
    if (!sscanf(input_str, "%ld", &input_num)) {
      continue;
    }

    data_size = 1024;
    data = malloc(data_size);
    strcpy(data, "37");
    pos1 = 0;
    pos2 = 1;
    data_len = strlen(data);

    while (data_len < input_num + 10) {
      if (data_len+10 > data_size) {
	data_size *= 2;
	data = realloc(data, data_size);
	if (!data) {
	  printf("Realloc failed at %ld\n", data_size);
	  continue;
	}
      }
	
      s1 = data[pos1] - '0';
      s2 = data[pos2] - '0';
      sum = s1 + s2;
      if (sum > 9)
	data[data_len++] = sum/10 + '0';
      data[data_len++] = sum%10 + '0';
      data[data_len] = 0;

      pos1 = (pos1 + s1 + 1) % data_len;
      pos2 = (pos2 + s2 + 1) % data_len;

      // printf("[%s] %ld %ld\n", data+data_len-10, pos1, pos2);
    }

    strncpy(out_str, data+input_num, MAX_STR);

    printf("Solution 1: at %ld = %s\n", input_num, out_str);

    pos_at = strstr(data, input_str);
    // printf(":: [%s]\n", haystack);
    
    while (!pos_at) {
      if (data_len+10 > data_size) {
	data_size *= 2;
	data = realloc(data, data_size);
	if (!data) {
	  printf("Realloc failed at %ld\n", data_size);
	  continue;
	}
      }
      
      s1 = data[pos1] - '0';
      s2 = data[pos2] - '0';
      sum = s1 + s2;
      if (sum > 9)
	data[data_len++] = sum/10 + '0';
      data[data_len++] = sum%10 + '0';
      data[data_len] = 0;
      
      pos1 = (pos1 + s1 + 1) % data_len;
      pos2 = (pos2 + s2 + 1) % data_len;

      haystack = data+data_len-haystack_offset;
      pos_at = strstr(haystack, input_str);

      /*
      if (data_len % 1000 == 0) {
	printf("Looking for [%s] at in [%s] at lenght %10ld.\r",
	       input_str,
	       haystack,
	       data_len
	       );
      }
      */

    }

    printf("Solution 2: %s seen at %ld\n", input_str, pos_at-data);
      
  }    

  return 0;
}
