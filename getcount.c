// This program is to demonstrate the functionality of getcount syscall.
#include "types.h"
#include "user.h"
#include "syscall.h"

int
main(int argc, char *argv[])
{
  int cpid = getpid();
  char dirname[8] = "new_dir"; 
  char indirname[10] = "new_in_dir"; 
  printf(1, "ID of current process %d\n", cpid);
  sleep(1);
  printf(1, "initial fork count %d\n", getcount(SYS_fork));
  if (fork() == 0) {
    cpid = getpid();
    mkdir(dirname);
    chdir(dirname);
    mkdir(indirname);
    sleep(1);
    printf(1, "ID of the child process %d\n", cpid);
    sleep(1);
    printf(1, "child fork count %d\n", getcount(SYS_fork));
    sleep(1);
    printf(1, "child write count %d\n", getcount(SYS_write));
    printf(1, "child getpid count %d\n", getcount(SYS_getpid));
    printf(1, "child sleep count %d\n", getcount(SYS_sleep));
  } else {
    wait();
    mkdir(indirname);
    printf(1, "parent fork count %d\n", getcount(SYS_fork));
    printf(1, "parent write count %d\n", getcount(SYS_write));
    printf(1, "parent getpid count %d\n", getcount(SYS_getpid));
    sleep(1);
    printf(1, "parent sleep count %d\n", getcount(SYS_sleep));
  }
  printf(1, "wait count %d\n", getcount(SYS_wait));
  printf(1, "mkdir count %d\n", getcount(SYS_mkdir));
  printf(1, "chdir count %d\n", getcount(SYS_chdir));
  
  exit();
}
