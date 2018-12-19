#define _GNU_SOURCE

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_LINE 1024

typedef struct i_rec {
  void *op;
  int ra, rb, rc;
} i_rec;

void i_addr (long *reg, int ra, int rb, int rc) {
  reg[rc] = (reg[ra] + reg[rb]);
}
void i_addi (long *reg, int ra, int rb, int rc) {
  reg[rc] = (reg[ra] + rb);
}
void i_mulr (long *reg, int ra, int rb, int rc) {
  reg[rc] = (reg[ra] * reg[rb]);
}
void i_muli (long *reg, int ra, int rb, int rc) {
  reg[rc] = (reg[ra] * rb);
}
void i_banr (long *reg, int ra, int rb, int rc) {
  reg[rc] = (reg[ra] & reg[rb]);
}
void i_bani (long *reg, int ra, int rb, int rc) {
  reg[rc] = (reg[ra] & rb);
}
void i_borr (long *reg, int ra, int rb, int rc) {
  reg[rc] = (reg[ra] | reg[rb]);
}
void i_bori (long *reg, int ra, int rb, int rc) {
  reg[rc] = (reg[ra] | rb);
}
void i_setr (long *reg, int ra, int rb, int rc) {
  reg[rc] = reg[ra];
}
void i_seti (long *reg, int ra, int rb, int rc) {
  reg[rc] = ra;
}
void i_gtir (long *reg, int ra, int rb, int rc) {
  reg[rc] = (ra > reg[rb] ? 1 : 0);
}
void i_gtri (long *reg, int ra, int rb, int rc) {
  reg[rc] = (reg[ra] > rb ? 1 : 0);
}
void i_gtrr (long *reg, int ra, int rb, int rc) {
  reg[rc] = (reg[ra] > reg[rb] ? 1 : 0);
}
void i_eqir (long *reg, int ra, int rb, int rc) {
  reg[rc] = (ra == reg[rb] ? 1 : 0);
}
void i_eqri (long *reg, int ra, int rb, int rc) {
  reg[rc] = (reg[ra] == rb ? 1 : 0);
}
void i_eqrr (long *reg, int ra, int rb, int rc) {
  reg[rc] = (reg[ra] == reg[rb] ? 1 : 0);
}

int main(int argc, char *argv[]) {
  FILE *input;
  char *input_name;

  i_rec *code, *cc;
  long code_length;
  long code_size;
  long ip, rip, lip;
  long ra, rb, rc;

  void (*op)(long *reg, int ra, int rb, int rc);

  long reg[10];

  char line[MAX_LINE];

  long loop = 0;

  input_name = "input";
  if (argc>1)
    input_name = argv[1];
  input = fopen(input_name, "r");
  if (!input) {
    perror("open");
    exit(1);
  }

  code_size = 1024;
  code_length = 0;
  code = calloc(sizeof(i_rec), code_size);
  if (!code) {
    perror("malloc");
    exit(1);
  }

  while (fgets(line, MAX_LINE, input)) {
    char *in = line;
    char *par;
    in[strlen(in)-1]=0;
    while (*in && *in == ' ')
      in++;

    if (!strncmp(in, "#ip ", 4)) {
      sscanf(in+4, "%ld", &rip);
    }
    else {
      par = strstr(in," ");
      *par = 0;
      par++;

      while (code_length + 2 > code_size) {
	code_size *= 2;
	code = reallocarray(code, sizeof(i_rec), code_size);
	if (!code) {
	  perror("realloc");
	  exit(1);
	}
      }

      cc = &code[code_length++];

      sscanf(par,"%d %d %d", &cc->ra, &cc->rb, &cc->rc);

      if (!strcmp(in,"addr")) { cc->op = &i_addr; }
      else if (!strcmp(in,"addi")) { cc->op = &i_addi; }
      else if (!strcmp(in,"mulr")) { cc->op = &i_mulr; }
      else if (!strcmp(in,"muli")) { cc->op = &i_muli; }
      else if (!strcmp(in,"banr")) { cc->op = &i_banr; }
      else if (!strcmp(in,"bani")) { cc->op = &i_bani; }
      else if (!strcmp(in,"borr")) { cc->op = &i_borr; }
      else if (!strcmp(in,"bori")) { cc->op = &i_bori; }
      else if (!strcmp(in,"setr")) { cc->op = &i_setr; }
      else if (!strcmp(in,"seti")) { cc->op = &i_seti; }
      else if (!strcmp(in,"gtir")) { cc->op = &i_gtir; }
      else if (!strcmp(in,"gtri")) { cc->op = &i_gtri; }
      else if (!strcmp(in,"gtrr")) { cc->op = &i_gtrr; }
      else if (!strcmp(in,"eqir")) { cc->op = &i_eqir; }
      else if (!strcmp(in,"eqri")) { cc->op = &i_eqri; }
      else if (!strcmp(in,"eqrr")) { cc->op = &i_eqrr; }
      else {
	printf("Unknown op %s\n", in);
	exit(1);
      }

    }
  }

  ip = 0;
  reg[0] = reg[1] = reg[2] = reg[3] = reg[4] = reg[5] = 0;
  reg[0] = 1;

  loop = 0;
  while (ip >= 0 && ip < code_length) {
    loop++;
    if (loop % 100000 == 0) {
      printf("%6ld ip=%4ld [%3ld %3ld %3ld %3ld %3ld %3ld]\r", loop, ip,
	     reg[0], reg[1], reg[2], reg[3], reg[4], reg[5]
	     );
    }
    lip = ip;
    reg[rip] = ip;
    cc = &code[ip];
    op = cc->op;
    op(reg, cc->ra, cc->rb, cc->rc);
    ip = reg[rip];
    ip++;
    if (lip == ip) {
    }
  }
  printf("\n");

  printf("Solution 2: register 0 contains %ld\n", reg[0]);

  return 0;
}
