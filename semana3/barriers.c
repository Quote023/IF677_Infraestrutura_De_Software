#define _XOPEN_SOURCE 600
#define _POSIX_C_SOURCE 200112L /* Or higher */

#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#define THREADS 3
#define ITERACOES 100

#include "../pthread_barriers_macos.c"
pthread_barrier_t barrier;

void *codigo_thread();

int main()
{

  pthread_t threads[THREADS];
  int *ids[THREADS];
  int i;

  pthread_barrier_init(&barrier, NULL, 3);

  for (i = 0; i < THREADS; i++)
  {
    ids[i] = (int *)malloc(sizeof(int));
    *ids[i] = i;
    pthread_create(&threads[i], NULL, codigo_thread, (void *)ids[i]);
  }

  for (i = 0; i < THREADS; i++)
  {
    pthread_join(threads[i], NULL);
  }

  pthread_barrier_destroy(&barrier);

  pthread_exit(NULL);

  return 0;
}

void *codigo_thread(void *threadid)
{
  int i;

  printf("Thread %d iniciou \n", *((int *)threadid));

  for (i = 0; i < ITERACOES; i++)
  {
    printf("Thread %d iteracao %d \n", *((int *)threadid), i);
    pthread_barrier_wait(&barrier);
  }

  printf("Thread %d terminou \n", *((int *)threadid));
  pthread_exit(NULL);
}