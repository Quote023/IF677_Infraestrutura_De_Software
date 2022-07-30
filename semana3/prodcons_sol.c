#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>

#define BUFFER_SIZE 3
#define NUM_ITEMS 200
#define THREADS 3

int buff[BUFFER_SIZE]; /* buffer size = 10; */
int items = 0;         // number of items in the buffer.
int first = 0;
int last = 0;

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t empty = PTHREAD_COND_INITIALIZER;
pthread_cond_t fill = PTHREAD_COND_INITIALIZER;

void *producer();
void *consumer();

main()
{

  pthread_t producer_thread;
  pthread_t consumer_thread[THREADS];
  int *ids[THREADS];

  int i = 0;
  for (i = 0; i < THREADS; i++)
  {
    ids[i] = (int *)malloc(sizeof(int));
    *ids[i] = i;
    pthread_create(&consumer_thread[i], NULL, consumer, (void *)ids[i]);
  }

  pthread_create(&producer_thread, NULL, producer, NULL);

  pthread_exit(NULL);
}

void put(int i)
{
  pthread_mutex_lock(&mutex);

  while (items == BUFFER_SIZE)
  {
    pthread_cond_wait(&empty, &mutex);
  }

  buff[last] = i;
  // printf("pos %d: ", last);
  items++;
  last++;

  if (last == BUFFER_SIZE)
  {
    last = 0;
  }

  if (items == 1)
  {
    pthread_cond_broadcast(&fill);
  }

  pthread_mutex_unlock(&mutex);
}
void *producer()
{
  int i = 0;
  printf("Produtor\n");
  int amount = NUM_ITEMS * THREADS;
  printf("Produtor iniciou\n");
  for (i = 0; i < amount; i++)
  {
    put(i);
    printf("Produzi %d \n", i);
  }
  printf("Produtor terminou\n");
  pthread_exit(NULL);
}

int get()
{
  int result;
  pthread_mutex_lock(&mutex);

  while (items == 0)
  {
    pthread_cond_wait(&fill, &mutex);
  }

  result = buff[first];

  //  printf("pos %d: ", first);

  items--;
  first++;

  if (first == BUFFER_SIZE)
  {
    first = 0;
  }

  if (items == BUFFER_SIZE - 1)
  {
    pthread_cond_signal(&empty);
  }

  pthread_mutex_unlock(&mutex);

  return result;
}

void *consumer(void *threadid)
{
  int i, v;
  printf("Consumidor %d iniciou \n", *((int *)threadid));
  for (i = 0; i < NUM_ITEMS; i++)
  {

    v = get();
    printf("Consumidor %d consumiu %d \n", *((int *)threadid), v);
  }

  printf("Consumidor %d terminou \n", *((int *)threadid));
  pthread_exit(NULL);
}