// Mutual exclusion spin locks.

#include "types.h"
#include "defs.h"
#include "param.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"

#define NUMMUTEXES 27

int mutex_var = 0;
struct spinlock mut_array[NUMMUTEXES];

// Following are for the new mutex functions
//int mutex_index = 0;
//int mutex_array[NUMMUTEXES];
//struct spinlock mutex_locks[NUMMUTEXES];

void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
  lk->locked = 0;
  lk->cpu = 0;
}

// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
    panic("acquire");

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
  getcallerpcs(&lk, lk->pcs);
}

// Release the lock.
void
release(struct spinlock *lk)
{
  if(!holding(lk))
    panic("release");

  lk->pcs[0] = 0;
  lk->cpu = 0;

  // The xchg serializes, so that reads before release are 
  // not reordered after it.  The 1996 PentiumPro manual (Volume 3,
  // 7.2) says reads can be carried out speculatively and in
  // any order, which implies we need to serialize here.
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);

  popcli();
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
  return lock->locked && lock->cpu == cpu;
}


// Pushcli/popcli are like cli/sti except that they are matched:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
  int eflags;
  
  eflags = readeflags();
  cli();
  if(cpu->ncli++ == 0)
    cpu->intena = eflags & FL_IF;
}

void
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--cpu->ncli < 0)
    panic("popcli");
  if(cpu->ncli == 0 && cpu->intena)
    sti();
}

// New functions for mutex creation, locking and unlocking

// Mutex unlocking function using xv6 atomicity (xchg)
// Unlock a thread that is waiting
/*
int 
mtx_unlock(int lock_id){
  
  xchg((volatile uint *)&lock_id, 0);
  return 0;
}
*/

int 
mtx_unlock(int lock_id)
{
  // Test if lock_id is valid, if yes, release
  if(lock_id < 0 || lock_id > mutex_var)
  {
    return -1;
  }
  release(&mut_array[lock_id]);
  return 0;
}

// Mutex locking function using xv6 atomicity (xchg)
// Lock using the provided id
/*
int 
mtx_lock(int lock_id){

  while(xchg((volatile uint *)&lock_id, 1) == 1)
    ;// Loop until xchg retrun is not 1
  return 0;
}
*/

int 
mtx_lock(int lock_id)
{
  // Test if lock_id is valid, if yes, acquire
  if(lock_id < 0 || lock_id > mutex_var)
  {
    return -1;
  }
  acquire(&mut_array[lock_id]);
  return 0;
}

// Mutex creation function using xv6 atomicity (xchg)
/*
int 
mtx_create(int lock_id){

  xchg((volatile uint *)&lock_id, 0);
  return 0;

}
*/

int 
mtx_create(int locked)
{
  // Create a mutex if it is possible
  char* name = "mutex";
  if(mutex_var < NUMMUTEXES)
    {
    initlock(&mut_array[mutex_var], name);
    if(locked){
      mtx_lock(mutex_var);
    }
    return(mutex_var++);
  }
  return -1;
}
