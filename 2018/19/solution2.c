#include <stdlib.h>
#include <stdio.h>


int main(int argc, char *argv[]) {

  long var0 = 1;
  long var1 = 3*22+17;
  long var2 = 2*2*19*11;
  long var3;
  long var4 = 0;
  long var5 = 0;

  var2 += var1;

  if (var0) {
    var1 = (27*28+29)*30*14*32;
    var2 += var1;
  }

  var0 = 0;

  printf("var2: %ld\n", var2);

  for (var4 = 1; var4 <= var2; var4++) {
    for (var5 = 1; var5 <= var2; var5++) {
      var1 = var4*var5;
      if (var1 == var2) {
	printf("Adding %ld (%ld) = %ld\n", var4, var5, var1);
	var0 += var4;
      }
      if (var1 > var2)
	break;
    }
  }

  printf("Solution 2: %ld\n", var0);

  return 0;
}
