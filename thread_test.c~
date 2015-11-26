#include "types.h"
#include "mmu.h"
#include "stat.h"
#include "user.h"
#include "param.h"
#include "fs.h"
#include "proc.h"
#include "x86.h"

int shared_count = 0;
int locked = 1;
//mtx_create(locked);

void child (void* args) {
  //mtx_lock(1);
  shared_count = shared_count+2;
  //mtx_unlock(1);
  printf(1, "Shared count is at %p\n", shared_count);
  printf(1, "hello, this is child! passed argument = %x \n", *(int*)args);
  return;
}

int main (int argc, char** argv) {
  int a = 0xabcd;
  // allocate 1-page for new thread's stack.
  void* stack = malloc (sizeof(char)*PGSIZE);
  printf(1, "Stack is at %p\n", stack);
  printf(1, "Shared count is at %p\n", shared_count);
  //mtx_lock(1);
  shared_count = shared_count+1;
  //mtx_unlock(1);
  int rc = thread_create ( &child, stack, (void*)&a);
  if (rc < 0) {
    printf (1, "thread create failed \n");
  }
  if(rc!=0)
  printf(1, "thread id = %d \n", rc);
  thread_join(&stack);
  exit();
}


