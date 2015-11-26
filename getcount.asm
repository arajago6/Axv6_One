
_getcount:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "syscall.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 30             	sub    $0x30,%esp
  int cpid = getpid();
   9:	e8 8c 05 00 00       	call   59a <getpid>
   e:	89 44 24 2c          	mov    %eax,0x2c(%esp)
  char dirname[8] = "new_dir"; 
  12:	c7 44 24 24 6e 65 77 	movl   $0x5f77656e,0x24(%esp)
  19:	5f 
  1a:	c7 44 24 28 64 69 72 	movl   $0x726964,0x28(%esp)
  21:	00 
  char indirname[10] = "new_in_dir"; 
  22:	c7 44 24 1a 6e 65 77 	movl   $0x5f77656e,0x1a(%esp)
  29:	5f 
  2a:	c7 44 24 1e 69 6e 5f 	movl   $0x645f6e69,0x1e(%esp)
  31:	64 
  32:	66 c7 44 24 22 69 72 	movw   $0x7269,0x22(%esp)
  printf(1, "ID of current process %d\n", cpid);
  39:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  41:	c7 44 24 04 96 0a 00 	movl   $0xa96,0x4(%esp)
  48:	00 
  49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  50:	e8 75 06 00 00       	call   6ca <printf>
  sleep(1);
  55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5c:	e8 49 05 00 00       	call   5aa <sleep>
  printf(1, "initial fork count %d\n", getcount(SYS_fork));
  61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  68:	e8 4d 05 00 00       	call   5ba <getcount>
  6d:	89 44 24 08          	mov    %eax,0x8(%esp)
  71:	c7 44 24 04 b0 0a 00 	movl   $0xab0,0x4(%esp)
  78:	00 
  79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80:	e8 45 06 00 00       	call   6ca <printf>
  if (fork() == 0) {
  85:	e8 88 04 00 00       	call   512 <fork>
  8a:	85 c0                	test   %eax,%eax
  8c:	0f 85 02 01 00 00    	jne    194 <main+0x194>
    cpid = getpid();
  92:	e8 03 05 00 00       	call   59a <getpid>
  97:	89 44 24 2c          	mov    %eax,0x2c(%esp)
    mkdir(dirname);
  9b:	8d 44 24 24          	lea    0x24(%esp),%eax
  9f:	89 04 24             	mov    %eax,(%esp)
  a2:	e8 db 04 00 00       	call   582 <mkdir>
    chdir(dirname);
  a7:	8d 44 24 24          	lea    0x24(%esp),%eax
  ab:	89 04 24             	mov    %eax,(%esp)
  ae:	e8 d7 04 00 00       	call   58a <chdir>
    mkdir(indirname);
  b3:	8d 44 24 1a          	lea    0x1a(%esp),%eax
  b7:	89 04 24             	mov    %eax,(%esp)
  ba:	e8 c3 04 00 00       	call   582 <mkdir>
    sleep(1);
  bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c6:	e8 df 04 00 00       	call   5aa <sleep>
    printf(1, "ID of the child process %d\n", cpid);
  cb:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  d3:	c7 44 24 04 c7 0a 00 	movl   $0xac7,0x4(%esp)
  da:	00 
  db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e2:	e8 e3 05 00 00       	call   6ca <printf>
    sleep(1);
  e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ee:	e8 b7 04 00 00       	call   5aa <sleep>
    printf(1, "child fork count %d\n", getcount(SYS_fork));
  f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fa:	e8 bb 04 00 00       	call   5ba <getcount>
  ff:	89 44 24 08          	mov    %eax,0x8(%esp)
 103:	c7 44 24 04 e3 0a 00 	movl   $0xae3,0x4(%esp)
 10a:	00 
 10b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 112:	e8 b3 05 00 00       	call   6ca <printf>
    sleep(1);
 117:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 11e:	e8 87 04 00 00       	call   5aa <sleep>
    printf(1, "child write count %d\n", getcount(SYS_write));
 123:	c7 04 24 10 00 00 00 	movl   $0x10,(%esp)
 12a:	e8 8b 04 00 00       	call   5ba <getcount>
 12f:	89 44 24 08          	mov    %eax,0x8(%esp)
 133:	c7 44 24 04 f8 0a 00 	movl   $0xaf8,0x4(%esp)
 13a:	00 
 13b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 142:	e8 83 05 00 00       	call   6ca <printf>
    printf(1, "child getpid count %d\n", getcount(SYS_getpid));
 147:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
 14e:	e8 67 04 00 00       	call   5ba <getcount>
 153:	89 44 24 08          	mov    %eax,0x8(%esp)
 157:	c7 44 24 04 0e 0b 00 	movl   $0xb0e,0x4(%esp)
 15e:	00 
 15f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 166:	e8 5f 05 00 00       	call   6ca <printf>
    printf(1, "child sleep count %d\n", getcount(SYS_sleep));
 16b:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
 172:	e8 43 04 00 00       	call   5ba <getcount>
 177:	89 44 24 08          	mov    %eax,0x8(%esp)
 17b:	c7 44 24 04 25 0b 00 	movl   $0xb25,0x4(%esp)
 182:	00 
 183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18a:	e8 3b 05 00 00       	call   6ca <printf>
 18f:	e9 ad 00 00 00       	jmp    241 <main+0x241>
  } else {
    wait();
 194:	e8 89 03 00 00       	call   522 <wait>
    mkdir(indirname);
 199:	8d 44 24 1a          	lea    0x1a(%esp),%eax
 19d:	89 04 24             	mov    %eax,(%esp)
 1a0:	e8 dd 03 00 00       	call   582 <mkdir>
    printf(1, "parent fork count %d\n", getcount(SYS_fork));
 1a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ac:	e8 09 04 00 00       	call   5ba <getcount>
 1b1:	89 44 24 08          	mov    %eax,0x8(%esp)
 1b5:	c7 44 24 04 3b 0b 00 	movl   $0xb3b,0x4(%esp)
 1bc:	00 
 1bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1c4:	e8 01 05 00 00       	call   6ca <printf>
    printf(1, "parent write count %d\n", getcount(SYS_write));
 1c9:	c7 04 24 10 00 00 00 	movl   $0x10,(%esp)
 1d0:	e8 e5 03 00 00       	call   5ba <getcount>
 1d5:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d9:	c7 44 24 04 51 0b 00 	movl   $0xb51,0x4(%esp)
 1e0:	00 
 1e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1e8:	e8 dd 04 00 00       	call   6ca <printf>
    printf(1, "parent getpid count %d\n", getcount(SYS_getpid));
 1ed:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
 1f4:	e8 c1 03 00 00       	call   5ba <getcount>
 1f9:	89 44 24 08          	mov    %eax,0x8(%esp)
 1fd:	c7 44 24 04 68 0b 00 	movl   $0xb68,0x4(%esp)
 204:	00 
 205:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 20c:	e8 b9 04 00 00       	call   6ca <printf>
    sleep(1);
 211:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 218:	e8 8d 03 00 00       	call   5aa <sleep>
    printf(1, "parent sleep count %d\n", getcount(SYS_sleep));
 21d:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
 224:	e8 91 03 00 00       	call   5ba <getcount>
 229:	89 44 24 08          	mov    %eax,0x8(%esp)
 22d:	c7 44 24 04 80 0b 00 	movl   $0xb80,0x4(%esp)
 234:	00 
 235:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 23c:	e8 89 04 00 00       	call   6ca <printf>
  }
  printf(1, "wait count %d\n", getcount(SYS_wait));
 241:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
 248:	e8 6d 03 00 00       	call   5ba <getcount>
 24d:	89 44 24 08          	mov    %eax,0x8(%esp)
 251:	c7 44 24 04 97 0b 00 	movl   $0xb97,0x4(%esp)
 258:	00 
 259:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 260:	e8 65 04 00 00       	call   6ca <printf>
  printf(1, "mkdir count %d\n", getcount(SYS_mkdir));
 265:	c7 04 24 14 00 00 00 	movl   $0x14,(%esp)
 26c:	e8 49 03 00 00       	call   5ba <getcount>
 271:	89 44 24 08          	mov    %eax,0x8(%esp)
 275:	c7 44 24 04 a6 0b 00 	movl   $0xba6,0x4(%esp)
 27c:	00 
 27d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 284:	e8 41 04 00 00       	call   6ca <printf>
  printf(1, "chdir count %d\n", getcount(SYS_chdir));
 289:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
 290:	e8 25 03 00 00       	call   5ba <getcount>
 295:	89 44 24 08          	mov    %eax,0x8(%esp)
 299:	c7 44 24 04 b6 0b 00 	movl   $0xbb6,0x4(%esp)
 2a0:	00 
 2a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2a8:	e8 1d 04 00 00       	call   6ca <printf>
  
  exit();
 2ad:	e8 68 02 00 00       	call   51a <exit>

000002b2 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2b2:	55                   	push   %ebp
 2b3:	89 e5                	mov    %esp,%ebp
 2b5:	57                   	push   %edi
 2b6:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2ba:	8b 55 10             	mov    0x10(%ebp),%edx
 2bd:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c0:	89 cb                	mov    %ecx,%ebx
 2c2:	89 df                	mov    %ebx,%edi
 2c4:	89 d1                	mov    %edx,%ecx
 2c6:	fc                   	cld    
 2c7:	f3 aa                	rep stos %al,%es:(%edi)
 2c9:	89 ca                	mov    %ecx,%edx
 2cb:	89 fb                	mov    %edi,%ebx
 2cd:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2d0:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2d3:	5b                   	pop    %ebx
 2d4:	5f                   	pop    %edi
 2d5:	5d                   	pop    %ebp
 2d6:	c3                   	ret    

000002d7 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2d7:	55                   	push   %ebp
 2d8:	89 e5                	mov    %esp,%ebp
 2da:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2dd:	8b 45 08             	mov    0x8(%ebp),%eax
 2e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2e3:	90                   	nop
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	8d 50 01             	lea    0x1(%eax),%edx
 2ea:	89 55 08             	mov    %edx,0x8(%ebp)
 2ed:	8b 55 0c             	mov    0xc(%ebp),%edx
 2f0:	8d 4a 01             	lea    0x1(%edx),%ecx
 2f3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 2f6:	0f b6 12             	movzbl (%edx),%edx
 2f9:	88 10                	mov    %dl,(%eax)
 2fb:	0f b6 00             	movzbl (%eax),%eax
 2fe:	84 c0                	test   %al,%al
 300:	75 e2                	jne    2e4 <strcpy+0xd>
    ;
  return os;
 302:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 305:	c9                   	leave  
 306:	c3                   	ret    

00000307 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 307:	55                   	push   %ebp
 308:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 30a:	eb 08                	jmp    314 <strcmp+0xd>
    p++, q++;
 30c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 310:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 314:	8b 45 08             	mov    0x8(%ebp),%eax
 317:	0f b6 00             	movzbl (%eax),%eax
 31a:	84 c0                	test   %al,%al
 31c:	74 10                	je     32e <strcmp+0x27>
 31e:	8b 45 08             	mov    0x8(%ebp),%eax
 321:	0f b6 10             	movzbl (%eax),%edx
 324:	8b 45 0c             	mov    0xc(%ebp),%eax
 327:	0f b6 00             	movzbl (%eax),%eax
 32a:	38 c2                	cmp    %al,%dl
 32c:	74 de                	je     30c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 32e:	8b 45 08             	mov    0x8(%ebp),%eax
 331:	0f b6 00             	movzbl (%eax),%eax
 334:	0f b6 d0             	movzbl %al,%edx
 337:	8b 45 0c             	mov    0xc(%ebp),%eax
 33a:	0f b6 00             	movzbl (%eax),%eax
 33d:	0f b6 c0             	movzbl %al,%eax
 340:	29 c2                	sub    %eax,%edx
 342:	89 d0                	mov    %edx,%eax
}
 344:	5d                   	pop    %ebp
 345:	c3                   	ret    

00000346 <strlen>:

uint
strlen(char *s)
{
 346:	55                   	push   %ebp
 347:	89 e5                	mov    %esp,%ebp
 349:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 34c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 353:	eb 04                	jmp    359 <strlen+0x13>
 355:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 359:	8b 55 fc             	mov    -0x4(%ebp),%edx
 35c:	8b 45 08             	mov    0x8(%ebp),%eax
 35f:	01 d0                	add    %edx,%eax
 361:	0f b6 00             	movzbl (%eax),%eax
 364:	84 c0                	test   %al,%al
 366:	75 ed                	jne    355 <strlen+0xf>
    ;
  return n;
 368:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 36b:	c9                   	leave  
 36c:	c3                   	ret    

0000036d <memset>:

void*
memset(void *dst, int c, uint n)
{
 36d:	55                   	push   %ebp
 36e:	89 e5                	mov    %esp,%ebp
 370:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 373:	8b 45 10             	mov    0x10(%ebp),%eax
 376:	89 44 24 08          	mov    %eax,0x8(%esp)
 37a:	8b 45 0c             	mov    0xc(%ebp),%eax
 37d:	89 44 24 04          	mov    %eax,0x4(%esp)
 381:	8b 45 08             	mov    0x8(%ebp),%eax
 384:	89 04 24             	mov    %eax,(%esp)
 387:	e8 26 ff ff ff       	call   2b2 <stosb>
  return dst;
 38c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 38f:	c9                   	leave  
 390:	c3                   	ret    

00000391 <strchr>:

char*
strchr(const char *s, char c)
{
 391:	55                   	push   %ebp
 392:	89 e5                	mov    %esp,%ebp
 394:	83 ec 04             	sub    $0x4,%esp
 397:	8b 45 0c             	mov    0xc(%ebp),%eax
 39a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 39d:	eb 14                	jmp    3b3 <strchr+0x22>
    if(*s == c)
 39f:	8b 45 08             	mov    0x8(%ebp),%eax
 3a2:	0f b6 00             	movzbl (%eax),%eax
 3a5:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3a8:	75 05                	jne    3af <strchr+0x1e>
      return (char*)s;
 3aa:	8b 45 08             	mov    0x8(%ebp),%eax
 3ad:	eb 13                	jmp    3c2 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3af:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b3:	8b 45 08             	mov    0x8(%ebp),%eax
 3b6:	0f b6 00             	movzbl (%eax),%eax
 3b9:	84 c0                	test   %al,%al
 3bb:	75 e2                	jne    39f <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 3bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3c2:	c9                   	leave  
 3c3:	c3                   	ret    

000003c4 <gets>:

char*
gets(char *buf, int max)
{
 3c4:	55                   	push   %ebp
 3c5:	89 e5                	mov    %esp,%ebp
 3c7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3d1:	eb 4c                	jmp    41f <gets+0x5b>
    cc = read(0, &c, 1);
 3d3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3da:	00 
 3db:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3de:	89 44 24 04          	mov    %eax,0x4(%esp)
 3e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3e9:	e8 44 01 00 00       	call   532 <read>
 3ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3f5:	7f 02                	jg     3f9 <gets+0x35>
      break;
 3f7:	eb 31                	jmp    42a <gets+0x66>
    buf[i++] = c;
 3f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fc:	8d 50 01             	lea    0x1(%eax),%edx
 3ff:	89 55 f4             	mov    %edx,-0xc(%ebp)
 402:	89 c2                	mov    %eax,%edx
 404:	8b 45 08             	mov    0x8(%ebp),%eax
 407:	01 c2                	add    %eax,%edx
 409:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 40d:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 40f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 413:	3c 0a                	cmp    $0xa,%al
 415:	74 13                	je     42a <gets+0x66>
 417:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 41b:	3c 0d                	cmp    $0xd,%al
 41d:	74 0b                	je     42a <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 41f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 422:	83 c0 01             	add    $0x1,%eax
 425:	3b 45 0c             	cmp    0xc(%ebp),%eax
 428:	7c a9                	jl     3d3 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 42a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 42d:	8b 45 08             	mov    0x8(%ebp),%eax
 430:	01 d0                	add    %edx,%eax
 432:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 435:	8b 45 08             	mov    0x8(%ebp),%eax
}
 438:	c9                   	leave  
 439:	c3                   	ret    

0000043a <stat>:

int
stat(char *n, struct stat *st)
{
 43a:	55                   	push   %ebp
 43b:	89 e5                	mov    %esp,%ebp
 43d:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 440:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 447:	00 
 448:	8b 45 08             	mov    0x8(%ebp),%eax
 44b:	89 04 24             	mov    %eax,(%esp)
 44e:	e8 07 01 00 00       	call   55a <open>
 453:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 456:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 45a:	79 07                	jns    463 <stat+0x29>
    return -1;
 45c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 461:	eb 23                	jmp    486 <stat+0x4c>
  r = fstat(fd, st);
 463:	8b 45 0c             	mov    0xc(%ebp),%eax
 466:	89 44 24 04          	mov    %eax,0x4(%esp)
 46a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46d:	89 04 24             	mov    %eax,(%esp)
 470:	e8 fd 00 00 00       	call   572 <fstat>
 475:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 478:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47b:	89 04 24             	mov    %eax,(%esp)
 47e:	e8 bf 00 00 00       	call   542 <close>
  return r;
 483:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 486:	c9                   	leave  
 487:	c3                   	ret    

00000488 <atoi>:

int
atoi(const char *s)
{
 488:	55                   	push   %ebp
 489:	89 e5                	mov    %esp,%ebp
 48b:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 48e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 495:	eb 25                	jmp    4bc <atoi+0x34>
    n = n*10 + *s++ - '0';
 497:	8b 55 fc             	mov    -0x4(%ebp),%edx
 49a:	89 d0                	mov    %edx,%eax
 49c:	c1 e0 02             	shl    $0x2,%eax
 49f:	01 d0                	add    %edx,%eax
 4a1:	01 c0                	add    %eax,%eax
 4a3:	89 c1                	mov    %eax,%ecx
 4a5:	8b 45 08             	mov    0x8(%ebp),%eax
 4a8:	8d 50 01             	lea    0x1(%eax),%edx
 4ab:	89 55 08             	mov    %edx,0x8(%ebp)
 4ae:	0f b6 00             	movzbl (%eax),%eax
 4b1:	0f be c0             	movsbl %al,%eax
 4b4:	01 c8                	add    %ecx,%eax
 4b6:	83 e8 30             	sub    $0x30,%eax
 4b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4bc:	8b 45 08             	mov    0x8(%ebp),%eax
 4bf:	0f b6 00             	movzbl (%eax),%eax
 4c2:	3c 2f                	cmp    $0x2f,%al
 4c4:	7e 0a                	jle    4d0 <atoi+0x48>
 4c6:	8b 45 08             	mov    0x8(%ebp),%eax
 4c9:	0f b6 00             	movzbl (%eax),%eax
 4cc:	3c 39                	cmp    $0x39,%al
 4ce:	7e c7                	jle    497 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 4d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4d3:	c9                   	leave  
 4d4:	c3                   	ret    

000004d5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4d5:	55                   	push   %ebp
 4d6:	89 e5                	mov    %esp,%ebp
 4d8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4e7:	eb 17                	jmp    500 <memmove+0x2b>
    *dst++ = *src++;
 4e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4ec:	8d 50 01             	lea    0x1(%eax),%edx
 4ef:	89 55 fc             	mov    %edx,-0x4(%ebp)
 4f2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4f5:	8d 4a 01             	lea    0x1(%edx),%ecx
 4f8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 4fb:	0f b6 12             	movzbl (%edx),%edx
 4fe:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 500:	8b 45 10             	mov    0x10(%ebp),%eax
 503:	8d 50 ff             	lea    -0x1(%eax),%edx
 506:	89 55 10             	mov    %edx,0x10(%ebp)
 509:	85 c0                	test   %eax,%eax
 50b:	7f dc                	jg     4e9 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 50d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 510:	c9                   	leave  
 511:	c3                   	ret    

00000512 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 512:	b8 01 00 00 00       	mov    $0x1,%eax
 517:	cd 40                	int    $0x40
 519:	c3                   	ret    

0000051a <exit>:
SYSCALL(exit)
 51a:	b8 02 00 00 00       	mov    $0x2,%eax
 51f:	cd 40                	int    $0x40
 521:	c3                   	ret    

00000522 <wait>:
SYSCALL(wait)
 522:	b8 03 00 00 00       	mov    $0x3,%eax
 527:	cd 40                	int    $0x40
 529:	c3                   	ret    

0000052a <pipe>:
SYSCALL(pipe)
 52a:	b8 04 00 00 00       	mov    $0x4,%eax
 52f:	cd 40                	int    $0x40
 531:	c3                   	ret    

00000532 <read>:
SYSCALL(read)
 532:	b8 05 00 00 00       	mov    $0x5,%eax
 537:	cd 40                	int    $0x40
 539:	c3                   	ret    

0000053a <write>:
SYSCALL(write)
 53a:	b8 10 00 00 00       	mov    $0x10,%eax
 53f:	cd 40                	int    $0x40
 541:	c3                   	ret    

00000542 <close>:
SYSCALL(close)
 542:	b8 15 00 00 00       	mov    $0x15,%eax
 547:	cd 40                	int    $0x40
 549:	c3                   	ret    

0000054a <kill>:
SYSCALL(kill)
 54a:	b8 06 00 00 00       	mov    $0x6,%eax
 54f:	cd 40                	int    $0x40
 551:	c3                   	ret    

00000552 <exec>:
SYSCALL(exec)
 552:	b8 07 00 00 00       	mov    $0x7,%eax
 557:	cd 40                	int    $0x40
 559:	c3                   	ret    

0000055a <open>:
SYSCALL(open)
 55a:	b8 0f 00 00 00       	mov    $0xf,%eax
 55f:	cd 40                	int    $0x40
 561:	c3                   	ret    

00000562 <mknod>:
SYSCALL(mknod)
 562:	b8 11 00 00 00       	mov    $0x11,%eax
 567:	cd 40                	int    $0x40
 569:	c3                   	ret    

0000056a <unlink>:
SYSCALL(unlink)
 56a:	b8 12 00 00 00       	mov    $0x12,%eax
 56f:	cd 40                	int    $0x40
 571:	c3                   	ret    

00000572 <fstat>:
SYSCALL(fstat)
 572:	b8 08 00 00 00       	mov    $0x8,%eax
 577:	cd 40                	int    $0x40
 579:	c3                   	ret    

0000057a <link>:
SYSCALL(link)
 57a:	b8 13 00 00 00       	mov    $0x13,%eax
 57f:	cd 40                	int    $0x40
 581:	c3                   	ret    

00000582 <mkdir>:
SYSCALL(mkdir)
 582:	b8 14 00 00 00       	mov    $0x14,%eax
 587:	cd 40                	int    $0x40
 589:	c3                   	ret    

0000058a <chdir>:
SYSCALL(chdir)
 58a:	b8 09 00 00 00       	mov    $0x9,%eax
 58f:	cd 40                	int    $0x40
 591:	c3                   	ret    

00000592 <dup>:
SYSCALL(dup)
 592:	b8 0a 00 00 00       	mov    $0xa,%eax
 597:	cd 40                	int    $0x40
 599:	c3                   	ret    

0000059a <getpid>:
SYSCALL(getpid)
 59a:	b8 0b 00 00 00       	mov    $0xb,%eax
 59f:	cd 40                	int    $0x40
 5a1:	c3                   	ret    

000005a2 <sbrk>:
SYSCALL(sbrk)
 5a2:	b8 0c 00 00 00       	mov    $0xc,%eax
 5a7:	cd 40                	int    $0x40
 5a9:	c3                   	ret    

000005aa <sleep>:
SYSCALL(sleep)
 5aa:	b8 0d 00 00 00       	mov    $0xd,%eax
 5af:	cd 40                	int    $0x40
 5b1:	c3                   	ret    

000005b2 <uptime>:
SYSCALL(uptime)
 5b2:	b8 0e 00 00 00       	mov    $0xe,%eax
 5b7:	cd 40                	int    $0x40
 5b9:	c3                   	ret    

000005ba <getcount>:
// To define asm routine for the new call.
SYSCALL(getcount)
 5ba:	b8 16 00 00 00       	mov    $0x16,%eax
 5bf:	cd 40                	int    $0x40
 5c1:	c3                   	ret    

000005c2 <thread_create>:
// To define asm routines for the new thread management calls.
SYSCALL(thread_create)
 5c2:	b8 17 00 00 00       	mov    $0x17,%eax
 5c7:	cd 40                	int    $0x40
 5c9:	c3                   	ret    

000005ca <thread_join>:
SYSCALL(thread_join)
 5ca:	b8 18 00 00 00       	mov    $0x18,%eax
 5cf:	cd 40                	int    $0x40
 5d1:	c3                   	ret    

000005d2 <mtx_create>:
SYSCALL(mtx_create)
 5d2:	b8 19 00 00 00       	mov    $0x19,%eax
 5d7:	cd 40                	int    $0x40
 5d9:	c3                   	ret    

000005da <mtx_lock>:
SYSCALL(mtx_lock)
 5da:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5df:	cd 40                	int    $0x40
 5e1:	c3                   	ret    

000005e2 <mtx_unlock>:
 5e2:	b8 1b 00 00 00       	mov    $0x1b,%eax
 5e7:	cd 40                	int    $0x40
 5e9:	c3                   	ret    

000005ea <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5ea:	55                   	push   %ebp
 5eb:	89 e5                	mov    %esp,%ebp
 5ed:	83 ec 18             	sub    $0x18,%esp
 5f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f3:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5f6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5fd:	00 
 5fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
 601:	89 44 24 04          	mov    %eax,0x4(%esp)
 605:	8b 45 08             	mov    0x8(%ebp),%eax
 608:	89 04 24             	mov    %eax,(%esp)
 60b:	e8 2a ff ff ff       	call   53a <write>
}
 610:	c9                   	leave  
 611:	c3                   	ret    

00000612 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 612:	55                   	push   %ebp
 613:	89 e5                	mov    %esp,%ebp
 615:	56                   	push   %esi
 616:	53                   	push   %ebx
 617:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 61a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 621:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 625:	74 17                	je     63e <printint+0x2c>
 627:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 62b:	79 11                	jns    63e <printint+0x2c>
    neg = 1;
 62d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 634:	8b 45 0c             	mov    0xc(%ebp),%eax
 637:	f7 d8                	neg    %eax
 639:	89 45 ec             	mov    %eax,-0x14(%ebp)
 63c:	eb 06                	jmp    644 <printint+0x32>
  } else {
    x = xx;
 63e:	8b 45 0c             	mov    0xc(%ebp),%eax
 641:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 644:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 64b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 64e:	8d 41 01             	lea    0x1(%ecx),%eax
 651:	89 45 f4             	mov    %eax,-0xc(%ebp)
 654:	8b 5d 10             	mov    0x10(%ebp),%ebx
 657:	8b 45 ec             	mov    -0x14(%ebp),%eax
 65a:	ba 00 00 00 00       	mov    $0x0,%edx
 65f:	f7 f3                	div    %ebx
 661:	89 d0                	mov    %edx,%eax
 663:	0f b6 80 14 0e 00 00 	movzbl 0xe14(%eax),%eax
 66a:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 66e:	8b 75 10             	mov    0x10(%ebp),%esi
 671:	8b 45 ec             	mov    -0x14(%ebp),%eax
 674:	ba 00 00 00 00       	mov    $0x0,%edx
 679:	f7 f6                	div    %esi
 67b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 67e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 682:	75 c7                	jne    64b <printint+0x39>
  if(neg)
 684:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 688:	74 10                	je     69a <printint+0x88>
    buf[i++] = '-';
 68a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 68d:	8d 50 01             	lea    0x1(%eax),%edx
 690:	89 55 f4             	mov    %edx,-0xc(%ebp)
 693:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 698:	eb 1f                	jmp    6b9 <printint+0xa7>
 69a:	eb 1d                	jmp    6b9 <printint+0xa7>
    putc(fd, buf[i]);
 69c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 69f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a2:	01 d0                	add    %edx,%eax
 6a4:	0f b6 00             	movzbl (%eax),%eax
 6a7:	0f be c0             	movsbl %al,%eax
 6aa:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ae:	8b 45 08             	mov    0x8(%ebp),%eax
 6b1:	89 04 24             	mov    %eax,(%esp)
 6b4:	e8 31 ff ff ff       	call   5ea <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6b9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6c1:	79 d9                	jns    69c <printint+0x8a>
    putc(fd, buf[i]);
}
 6c3:	83 c4 30             	add    $0x30,%esp
 6c6:	5b                   	pop    %ebx
 6c7:	5e                   	pop    %esi
 6c8:	5d                   	pop    %ebp
 6c9:	c3                   	ret    

000006ca <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6ca:	55                   	push   %ebp
 6cb:	89 e5                	mov    %esp,%ebp
 6cd:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6d0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6d7:	8d 45 0c             	lea    0xc(%ebp),%eax
 6da:	83 c0 04             	add    $0x4,%eax
 6dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6e7:	e9 7c 01 00 00       	jmp    868 <printf+0x19e>
    c = fmt[i] & 0xff;
 6ec:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f2:	01 d0                	add    %edx,%eax
 6f4:	0f b6 00             	movzbl (%eax),%eax
 6f7:	0f be c0             	movsbl %al,%eax
 6fa:	25 ff 00 00 00       	and    $0xff,%eax
 6ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 702:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 706:	75 2c                	jne    734 <printf+0x6a>
      if(c == '%'){
 708:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 70c:	75 0c                	jne    71a <printf+0x50>
        state = '%';
 70e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 715:	e9 4a 01 00 00       	jmp    864 <printf+0x19a>
      } else {
        putc(fd, c);
 71a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 71d:	0f be c0             	movsbl %al,%eax
 720:	89 44 24 04          	mov    %eax,0x4(%esp)
 724:	8b 45 08             	mov    0x8(%ebp),%eax
 727:	89 04 24             	mov    %eax,(%esp)
 72a:	e8 bb fe ff ff       	call   5ea <putc>
 72f:	e9 30 01 00 00       	jmp    864 <printf+0x19a>
      }
    } else if(state == '%'){
 734:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 738:	0f 85 26 01 00 00    	jne    864 <printf+0x19a>
      if(c == 'd'){
 73e:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 742:	75 2d                	jne    771 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 744:	8b 45 e8             	mov    -0x18(%ebp),%eax
 747:	8b 00                	mov    (%eax),%eax
 749:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 750:	00 
 751:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 758:	00 
 759:	89 44 24 04          	mov    %eax,0x4(%esp)
 75d:	8b 45 08             	mov    0x8(%ebp),%eax
 760:	89 04 24             	mov    %eax,(%esp)
 763:	e8 aa fe ff ff       	call   612 <printint>
        ap++;
 768:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 76c:	e9 ec 00 00 00       	jmp    85d <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 771:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 775:	74 06                	je     77d <printf+0xb3>
 777:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 77b:	75 2d                	jne    7aa <printf+0xe0>
        printint(fd, *ap, 16, 0);
 77d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 780:	8b 00                	mov    (%eax),%eax
 782:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 789:	00 
 78a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 791:	00 
 792:	89 44 24 04          	mov    %eax,0x4(%esp)
 796:	8b 45 08             	mov    0x8(%ebp),%eax
 799:	89 04 24             	mov    %eax,(%esp)
 79c:	e8 71 fe ff ff       	call   612 <printint>
        ap++;
 7a1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a5:	e9 b3 00 00 00       	jmp    85d <printf+0x193>
      } else if(c == 's'){
 7aa:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7ae:	75 45                	jne    7f5 <printf+0x12b>
        s = (char*)*ap;
 7b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b3:	8b 00                	mov    (%eax),%eax
 7b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7b8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7c0:	75 09                	jne    7cb <printf+0x101>
          s = "(null)";
 7c2:	c7 45 f4 c6 0b 00 00 	movl   $0xbc6,-0xc(%ebp)
        while(*s != 0){
 7c9:	eb 1e                	jmp    7e9 <printf+0x11f>
 7cb:	eb 1c                	jmp    7e9 <printf+0x11f>
          putc(fd, *s);
 7cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d0:	0f b6 00             	movzbl (%eax),%eax
 7d3:	0f be c0             	movsbl %al,%eax
 7d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 7da:	8b 45 08             	mov    0x8(%ebp),%eax
 7dd:	89 04 24             	mov    %eax,(%esp)
 7e0:	e8 05 fe ff ff       	call   5ea <putc>
          s++;
 7e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ec:	0f b6 00             	movzbl (%eax),%eax
 7ef:	84 c0                	test   %al,%al
 7f1:	75 da                	jne    7cd <printf+0x103>
 7f3:	eb 68                	jmp    85d <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7f5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7f9:	75 1d                	jne    818 <printf+0x14e>
        putc(fd, *ap);
 7fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7fe:	8b 00                	mov    (%eax),%eax
 800:	0f be c0             	movsbl %al,%eax
 803:	89 44 24 04          	mov    %eax,0x4(%esp)
 807:	8b 45 08             	mov    0x8(%ebp),%eax
 80a:	89 04 24             	mov    %eax,(%esp)
 80d:	e8 d8 fd ff ff       	call   5ea <putc>
        ap++;
 812:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 816:	eb 45                	jmp    85d <printf+0x193>
      } else if(c == '%'){
 818:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 81c:	75 17                	jne    835 <printf+0x16b>
        putc(fd, c);
 81e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 821:	0f be c0             	movsbl %al,%eax
 824:	89 44 24 04          	mov    %eax,0x4(%esp)
 828:	8b 45 08             	mov    0x8(%ebp),%eax
 82b:	89 04 24             	mov    %eax,(%esp)
 82e:	e8 b7 fd ff ff       	call   5ea <putc>
 833:	eb 28                	jmp    85d <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 835:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 83c:	00 
 83d:	8b 45 08             	mov    0x8(%ebp),%eax
 840:	89 04 24             	mov    %eax,(%esp)
 843:	e8 a2 fd ff ff       	call   5ea <putc>
        putc(fd, c);
 848:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 84b:	0f be c0             	movsbl %al,%eax
 84e:	89 44 24 04          	mov    %eax,0x4(%esp)
 852:	8b 45 08             	mov    0x8(%ebp),%eax
 855:	89 04 24             	mov    %eax,(%esp)
 858:	e8 8d fd ff ff       	call   5ea <putc>
      }
      state = 0;
 85d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 864:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 868:	8b 55 0c             	mov    0xc(%ebp),%edx
 86b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86e:	01 d0                	add    %edx,%eax
 870:	0f b6 00             	movzbl (%eax),%eax
 873:	84 c0                	test   %al,%al
 875:	0f 85 71 fe ff ff    	jne    6ec <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 87b:	c9                   	leave  
 87c:	c3                   	ret    

0000087d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 87d:	55                   	push   %ebp
 87e:	89 e5                	mov    %esp,%ebp
 880:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 883:	8b 45 08             	mov    0x8(%ebp),%eax
 886:	83 e8 08             	sub    $0x8,%eax
 889:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88c:	a1 30 0e 00 00       	mov    0xe30,%eax
 891:	89 45 fc             	mov    %eax,-0x4(%ebp)
 894:	eb 24                	jmp    8ba <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 896:	8b 45 fc             	mov    -0x4(%ebp),%eax
 899:	8b 00                	mov    (%eax),%eax
 89b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 89e:	77 12                	ja     8b2 <free+0x35>
 8a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8a6:	77 24                	ja     8cc <free+0x4f>
 8a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ab:	8b 00                	mov    (%eax),%eax
 8ad:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8b0:	77 1a                	ja     8cc <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b5:	8b 00                	mov    (%eax),%eax
 8b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8c0:	76 d4                	jbe    896 <free+0x19>
 8c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c5:	8b 00                	mov    (%eax),%eax
 8c7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8ca:	76 ca                	jbe    896 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8cf:	8b 40 04             	mov    0x4(%eax),%eax
 8d2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8dc:	01 c2                	add    %eax,%edx
 8de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e1:	8b 00                	mov    (%eax),%eax
 8e3:	39 c2                	cmp    %eax,%edx
 8e5:	75 24                	jne    90b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ea:	8b 50 04             	mov    0x4(%eax),%edx
 8ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f0:	8b 00                	mov    (%eax),%eax
 8f2:	8b 40 04             	mov    0x4(%eax),%eax
 8f5:	01 c2                	add    %eax,%edx
 8f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fa:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 900:	8b 00                	mov    (%eax),%eax
 902:	8b 10                	mov    (%eax),%edx
 904:	8b 45 f8             	mov    -0x8(%ebp),%eax
 907:	89 10                	mov    %edx,(%eax)
 909:	eb 0a                	jmp    915 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 90b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90e:	8b 10                	mov    (%eax),%edx
 910:	8b 45 f8             	mov    -0x8(%ebp),%eax
 913:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 915:	8b 45 fc             	mov    -0x4(%ebp),%eax
 918:	8b 40 04             	mov    0x4(%eax),%eax
 91b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 922:	8b 45 fc             	mov    -0x4(%ebp),%eax
 925:	01 d0                	add    %edx,%eax
 927:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 92a:	75 20                	jne    94c <free+0xcf>
    p->s.size += bp->s.size;
 92c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92f:	8b 50 04             	mov    0x4(%eax),%edx
 932:	8b 45 f8             	mov    -0x8(%ebp),%eax
 935:	8b 40 04             	mov    0x4(%eax),%eax
 938:	01 c2                	add    %eax,%edx
 93a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 940:	8b 45 f8             	mov    -0x8(%ebp),%eax
 943:	8b 10                	mov    (%eax),%edx
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	89 10                	mov    %edx,(%eax)
 94a:	eb 08                	jmp    954 <free+0xd7>
  } else
    p->s.ptr = bp;
 94c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 952:	89 10                	mov    %edx,(%eax)
  freep = p;
 954:	8b 45 fc             	mov    -0x4(%ebp),%eax
 957:	a3 30 0e 00 00       	mov    %eax,0xe30
}
 95c:	c9                   	leave  
 95d:	c3                   	ret    

0000095e <morecore>:

static Header*
morecore(uint nu)
{
 95e:	55                   	push   %ebp
 95f:	89 e5                	mov    %esp,%ebp
 961:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 964:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 96b:	77 07                	ja     974 <morecore+0x16>
    nu = 4096;
 96d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 974:	8b 45 08             	mov    0x8(%ebp),%eax
 977:	c1 e0 03             	shl    $0x3,%eax
 97a:	89 04 24             	mov    %eax,(%esp)
 97d:	e8 20 fc ff ff       	call   5a2 <sbrk>
 982:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 985:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 989:	75 07                	jne    992 <morecore+0x34>
    return 0;
 98b:	b8 00 00 00 00       	mov    $0x0,%eax
 990:	eb 22                	jmp    9b4 <morecore+0x56>
  hp = (Header*)p;
 992:	8b 45 f4             	mov    -0xc(%ebp),%eax
 995:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 998:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99b:	8b 55 08             	mov    0x8(%ebp),%edx
 99e:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a4:	83 c0 08             	add    $0x8,%eax
 9a7:	89 04 24             	mov    %eax,(%esp)
 9aa:	e8 ce fe ff ff       	call   87d <free>
  return freep;
 9af:	a1 30 0e 00 00       	mov    0xe30,%eax
}
 9b4:	c9                   	leave  
 9b5:	c3                   	ret    

000009b6 <malloc>:

void*
malloc(uint nbytes)
{
 9b6:	55                   	push   %ebp
 9b7:	89 e5                	mov    %esp,%ebp
 9b9:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9bc:	8b 45 08             	mov    0x8(%ebp),%eax
 9bf:	83 c0 07             	add    $0x7,%eax
 9c2:	c1 e8 03             	shr    $0x3,%eax
 9c5:	83 c0 01             	add    $0x1,%eax
 9c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9cb:	a1 30 0e 00 00       	mov    0xe30,%eax
 9d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9d7:	75 23                	jne    9fc <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9d9:	c7 45 f0 28 0e 00 00 	movl   $0xe28,-0x10(%ebp)
 9e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e3:	a3 30 0e 00 00       	mov    %eax,0xe30
 9e8:	a1 30 0e 00 00       	mov    0xe30,%eax
 9ed:	a3 28 0e 00 00       	mov    %eax,0xe28
    base.s.size = 0;
 9f2:	c7 05 2c 0e 00 00 00 	movl   $0x0,0xe2c
 9f9:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ff:	8b 00                	mov    (%eax),%eax
 a01:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a07:	8b 40 04             	mov    0x4(%eax),%eax
 a0a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a0d:	72 4d                	jb     a5c <malloc+0xa6>
      if(p->s.size == nunits)
 a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a12:	8b 40 04             	mov    0x4(%eax),%eax
 a15:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a18:	75 0c                	jne    a26 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1d:	8b 10                	mov    (%eax),%edx
 a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a22:	89 10                	mov    %edx,(%eax)
 a24:	eb 26                	jmp    a4c <malloc+0x96>
      else {
        p->s.size -= nunits;
 a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a29:	8b 40 04             	mov    0x4(%eax),%eax
 a2c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a2f:	89 c2                	mov    %eax,%edx
 a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a34:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3a:	8b 40 04             	mov    0x4(%eax),%eax
 a3d:	c1 e0 03             	shl    $0x3,%eax
 a40:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a46:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a49:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4f:	a3 30 0e 00 00       	mov    %eax,0xe30
      return (void*)(p + 1);
 a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a57:	83 c0 08             	add    $0x8,%eax
 a5a:	eb 38                	jmp    a94 <malloc+0xde>
    }
    if(p == freep)
 a5c:	a1 30 0e 00 00       	mov    0xe30,%eax
 a61:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a64:	75 1b                	jne    a81 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a66:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a69:	89 04 24             	mov    %eax,(%esp)
 a6c:	e8 ed fe ff ff       	call   95e <morecore>
 a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a78:	75 07                	jne    a81 <malloc+0xcb>
        return 0;
 a7a:	b8 00 00 00 00       	mov    $0x0,%eax
 a7f:	eb 13                	jmp    a94 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a84:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8a:	8b 00                	mov    (%eax),%eax
 a8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a8f:	e9 70 ff ff ff       	jmp    a04 <malloc+0x4e>
}
 a94:	c9                   	leave  
 a95:	c3                   	ret    
