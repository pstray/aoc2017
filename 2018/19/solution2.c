#include <stdlib.h>
#include <stdio.h>


int main(int argc, char *argv[]) {

  long reg0;
  long reg1;
  long reg2;
  long reg3;
  long reg4;
  long reg5;


  for (int i = 0; i < 2; i++) {
    long loop = 0;

    reg1 = 3*22+17;
    reg2 = 2*2*19*11 + reg1;

    if (i) {
      reg1 = (27*28+29)*30*14*32;
      reg2 += reg1;
    }

    reg0 = 0;

    printf("Running %d: $2 = %ld\n", i+1, reg2);

    for (reg4 = 1; reg4 <= reg2; reg4++) {
      for (reg5 = 1; reg5 <= reg2; reg5++) {
	loop++;
	reg1 = reg4*reg5;
	if (reg1 == reg2) {
	  reg0 += reg4;
	  printf("  Adding %ld (%ld) @%ld = %ld (%ld)\n", reg4, reg5, loop, reg1, reg0);
	  break;
	}
	if (reg1 > reg2)
	  break;
      }
    }

    printf("Solution %d: after loop %ld, $0 = %ld\n", i+1, loop, reg0);
  }

  return 0;
}
