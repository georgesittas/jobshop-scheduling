#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
   Usage: rand_js_data <seed> <number of jobs> <maximum tasks per job>
                       <maximum task duration> <maximum staff per task>
                       <number of machine types>
                       <maximum number of machines per type>
  
   Defaults:
      <seed>: Current time
      <number of jobs>: 5
      <maximum tasks per job>: 4
      <maximum task duration>: 4
      <maximum staff per task>: 3
      <number of machine types>: 2
      <maximum number of machines per type>: 3
*/

int main(int argc, char *argv[])
{  int i, j;
   int noofjobs = 5, maxtasksperjob = 4, maxtaskduration = 4;
   int maxstaffpertask = 3, noofmachinetypes = 2, maxmachinespertype = 3;
   int seed, *nooftasks, **durs, machinetype, duration, noofmachines, taskstaff;
   seed = time(NULL);
   if (argc > 1)
      seed = atoi(argv[1]);
   if (argc > 2) {
      noofjobs = atoi(argv[2]);
      if (noofjobs > 9) {
         fprintf(stderr,"Please, give up to 9 number of jobs\n");
         return 1;
      }
   }
   if (argc > 3) {
      maxtasksperjob = atoi(argv[3]);
      if (maxtasksperjob > 9) {
         fprintf(stderr,"Please, give up to 9 maximum tasks per job\n");
         return 1;
      }
   }
   if (argc > 4)
      maxtaskduration = atoi(argv[4]);
   if (argc > 5)
      maxstaffpertask = atoi(argv[5]);
   if (argc > 6)
      noofmachinetypes = atoi(argv[6]);
   if (argc > 7)
      maxmachinespertype = atoi(argv[7]);
   srand(seed);
   nooftasks = malloc(noofjobs * sizeof(int));
   durs = malloc(noofjobs * sizeof(int *));
   for (i = 1 ; i <= noofjobs ; i++ ) {
      printf("job(j%d, [", i);
      nooftasks[i-1] = rand() % maxtasksperjob + 1;
      durs[i-1] = malloc(nooftasks[i-1] * sizeof(int));
      for (j = 1 ; j <= nooftasks[i-1] ; j++) {
         if (j != 1)
            printf(",");
         printf("t%d%d", i, j);
      }
      printf("]).\n");
   }
   printf("\n");
   for (i = 1 ; i <= noofjobs ; i++)
      for (j = 1 ; j <= nooftasks[i-1] ; j++) {
         machinetype = rand() % noofmachinetypes + 1;
         duration = rand() % maxtaskduration + 1;
         taskstaff = rand() % maxstaffpertask + 1;
         printf("task(t%d%d, m%d, %d, %d).\n",
                i, j, machinetype, duration, taskstaff);
      }
   printf("\n");
   for (i = 1 ; i <= noofmachinetypes ; i++) {
      noofmachines = rand() % maxmachinespertype + 1;
      printf("machine(m%d, %d).\n", i, noofmachines);
   }
   for (i = 0 ; i < noofjobs ; i++)
      free(durs[i]);
   free(nooftasks);
   free(durs);
   return 0;
}

