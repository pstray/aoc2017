#include <stdio.h>

int main(int argc, char *argv[]) {
  int x, y, xx, yy, zz, xm, ym, size, id;
  long power;
  int serial = 9306;
  int grid[300][300];
  long pgrid[300][300];
  int max_x, max_y, max_size;
  long max_power;

  for (y = 0; y<300; y++) {
    for (x = 0; x<300; x++) {
      id = x + 10;
      power = id * y + serial;
      power *= id;
      grid[x][y] = (power/100)%10 - 5;
    }
  }

  max_power = -100000;

  for (y=0; y<300-2; y++) {
    for (x=0; x<300-2; x++) {
      power = 0;
      for (yy=0; yy<3; yy++) {
	for (xx=0; xx<3; xx++) {
	  power += grid[x+xx][y+yy];
	}
      }
      if (power>max_power) {
	max_power = power;
	max_x = x;
	max_y = y;
      }
    }
  }
  printf("Solution 1: id=%d, level %ld at %d,%d\n",
	 serial, max_power, max_x+1, max_y+1);

  max_size = 3;

  for (y=0; y<300-1; y++) {
    for (x=0; x<300-1; x++) {
      power = grid[x][y] + grid[x+1][y] +
	grid[x][y+1] + grid[x+1][y+1];
      pgrid[x][y] = power;
      if (power>max_power) {
	max_power = power;
	max_x = x;
	max_y = y;
	max_size = 2;
      }
    }
  }

  for (size=3; size<=300; size++) {
    printf("  %d\r", size);
    for (y=0; y<300-size+1; y++) {
      for (x=0; x<300-size+1; x++) {
	xm = x+size-1;
	ym = y+size-1;
	power = pgrid[x][y];
	for (zz=0; zz<size-1; zz++) {
	  power += grid[xm][y+zz];
	  power += grid[x+zz][ym];
	}
	power += grid[xm][ym];
	pgrid[x][y] = power;
	if (power>max_power) {
	  max_power = power;
	  max_x = x;
	  max_y = y;
	  max_size = size;
	}
      }
    }
    printf("\rSolution 2: id=%d, level %ld at %d,%d,%d",
	   serial, max_power, max_x+1, max_y+1, max_size);
  }
  printf("\ndone\n");

  return 0;
}
