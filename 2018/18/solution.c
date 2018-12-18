#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_LINE 1024
#define MAX_LOOP 1000000000

typedef struct solution_rec {
  char *solution;
  long time;
  struct solution_rec *next;
} solution_rec;

int main(int argc, char *argv[]) {
  FILE *input;
  char *input_name;

  char *data, *ndata, *pdata;
  long data_size;
  long data_length;
  char line[MAX_LINE];
  long max_x = 0;
  long max_y = 0;
  long x, y;
  char t;

  solution_rec *solutions = NULL, *s_rec;

  long time = 0;
  long count[256], tcount[256];
  long p, pc;
  char *pp;

  long found = -1;

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
  line[0] = ' ';
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
      memset(data, ' ', ll);
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

  ndata = data;

  while (time < MAX_LOOP) {
    ++time;
    //printf("After time=%ld\n", time);

    pdata = ndata;
    ndata = strdup(pdata);
    /*
    // swap data
      data = pdata;
      pdata = ndata;
      ndata = data;
    */

    p = 0;
    pc = max_x+1;
    tcount['.'] = tcount['|'] = tcount['#'] = 0;
    for (y=1; y<max_y-1; y++) {
      for (x=1; x<max_x-1; x++) {
	count['.'] = count['|'] = count['#'] = 0;
	pp = pdata+p;
	count[*(pp++)]++;
	count[*(pp++)]++;
	count[*(pp++)]++;
	pp += max_x-3;
	count[*(pp++)]++;
	t = *(pp++);
	count[*(pp++)]++;
	pp += max_x-3;
	count[*(pp++)]++;
	count[*(pp++)]++;
	count[*(pp++)]++;

	if (t == '.' && count['|']>2) {
	  t = '|';
	}
	else if (t == '|' && count['#']>2) {
	  t = '#';
	}
	else if (t == '#' && (count['#']==0 || count['|']==0)) {
	  t = '.';
	}
	ndata[pc] = t;
	tcount[t]++;

	// printf("%c", t);

	p++;
	pc++;
      }

      //printf("\n");

      p += 2;
      pc += 2;
    }

    if (time == 10) {
      printf("Solution 1: %ld trees, %ld lumberyards = %ld\n",
	     tcount['|'], tcount['#'], tcount['|'] * tcount['#']);
    }

    found = -1;
    s_rec = solutions;
    while (s_rec) {
      if (strcmp(s_rec->solution, ndata)) {
	s_rec = s_rec->next;
      }
      else {
	found = s_rec->time;
	break;
      }
    }

    if (found >= 0) {
      long diff, left;
      diff = time-found;
      left = MAX_LOOP-time;

      printf("Repeating map found at %ld, seen %ld min ago", time, diff);

      time += diff*(left/diff);

      printf(", skipping ahead to %ld\n", time);
      solutions = NULL;
    }

    s_rec = malloc(sizeof(solution_rec));
    s_rec->next = solutions;
    s_rec->time = time;
    s_rec->solution = ndata;
    solutions = s_rec;
  }

  printf("Solution 2: %ld trees, %ld lumberyards = %ld\n",
	 tcount['|'], tcount['#'], tcount['|'] * tcount['#']);

  return 0;
}
