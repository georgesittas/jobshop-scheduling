#include <stdlib.h>
#include <stdio.h>
#include <time.h>

int main(int argc, char *argv[]) {
  int n = 10, i, j, k, m, *p, seed;
  char *str1, *str2;

  seed = time(NULL);

  if (argc > 1)
    n = atoi(argv[1]);
  if (argc > 2)
    seed = atoi(argv[2]);

  srand(seed);
  str1 = "man";
  str2 = "men([";

  for (k = 0 ; k < 2 ; k++) {
    printf("%s", str2);
    for (i = 0 ; i < n ; i++) {
      printf("%s%03d", str1, i + 1);
      if (i != n - 1)
        printf(",");
      else
        printf("]).\n\n");
    }

    str1 = "wom";
    str2 = "women([";
  }

  p = malloc(n * sizeof(int));
  str1 = "man";
  str2 = "wom";
  for (k = 0 ; k < 2 ; k++) {
    for (j = 0 ; j < n ; j++) {
      printf("prefers(%s%03d,[", str1, j + 1);
      for (i = 0 ; i < n ; i++)
        *(p + i) = i + 1;
      for (i = 0 ; i < n ; i++) {
        m = rand() % n;
        while (*(p + m) == 0) {
          m = (++m) % n;
        }
        *(p + m) = 0;
        printf("%s%03d", str2, m + 1);
        if (i != n - 1)
          printf(",");
        else
          printf("]).\n");
        }
      }

    str1 = "wom";
    str2 = "man";
  }

   free(p);
   return 0;
}
