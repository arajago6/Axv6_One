// This is a test program that would validate threads and the
// mutex mechanism that have been implemented recently
#include "types.h"
#include "mmu.h"
#include "stat.h"
#include "user.h"
#include "param.h"
#include "fs.h"
#include "proc.h"
#include "x86.h"

// Declaring the mutex and the needed structure
int mutex;
struct shared_buffer 
{
  int item_count;
  int space_count;
  int depot_array[3];
};
struct shared_buffer shared_buffer;

// Here the queue size is 3 and the item count is 6
int run_consumer (void* inpt)
{
  int i,j;
  int is_present;
  shared_buffer.item_count = 0;
  shared_buffer.space_count = 3;

  // Looping to consume buffer with items
  for(i = 0; i < 6; i++)
  {
    mtx_lock(mutex);
    if(shared_buffer.item_count == 0)
    {
      mtx_unlock(mutex);
    }
    else
    {
      is_present = 0;
      j = 0;

      // Now consume buffer's depot with items from producer
      // and make according changes to spaces(--) and items(++) 
      while(is_present == 0 && j < 3)
      {
        if(shared_buffer.depot_array[j] != 0)
        {
          is_present = 1;
          printf(1,"Consumer: %d\n", shared_buffer.depot_array[j]);

          shared_buffer.depot_array[j] = 0;
          shared_buffer.item_count --;
          shared_buffer.space_count ++;
        }
        j++;
      }
      mtx_unlock(mutex);
    }

  }
  exit();
  return 0;
}

int run_producer (void* inpt)
{
  int i,j;
  int is_present;

  // Looping to fill buffer with items
  for(i = 0; i < 6; i++)
    {
    mtx_lock(mutex);
    if(shared_buffer.space_count == 0)
    {
      mtx_unlock(mutex);
    }
    else
    {
      is_present = 0;
      j = 0;

      // Now fill buffer's depot with items from producer
      // and make according changes to spaces(--) and items(++) 
      while(is_present ==0 && j < 3)
      {
        if(shared_buffer.depot_array[j] == 0)
        {
          is_present = 1;
          printf(1,"Producer: %d\n", i);

          shared_buffer.depot_array[j] = i;
          shared_buffer.item_count ++;
          shared_buffer.space_count --;

        }
        j++;
      }
      mtx_unlock(mutex);
    }
  }
  exit();
  return 0;
}

// Program execution starts here
int main(int argc, char**argv)
{
  int* result_stk = 0;
  int* producer_stk[100], consumer_stk[100];
  mutex = mtx_create(0);
  thread_create((void*)*run_producer,producer_stk,(void*)0);
  thread_create((void*)*run_consumer,consumer_stk,(void*)0);
  thread_join((void*)result_stk);
  thread_join((void*)result_stk);

  exit();
  return 0;
}

