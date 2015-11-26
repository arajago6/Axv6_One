
_thread_test:     file format elf32-i386


Disassembly of section .text:

00000000 <child>:

int shared_count = 0;
int locked = 1;
//mtx_create(locked);

void child (void* args) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  //mtx_lock(1);
  shared_count = shared_count+2;
   6:	a1 0c 0c 00 00       	mov    0xc0c,%eax
   b:	83 c0 02             	add    $0x2,%eax
   e:	a3 0c 0c 00 00       	mov    %eax,0xc0c
  //mtx_unlock(1);
  printf(1, "Shared count is at %p\n", shared_count);
  13:	a1 0c 0c 00 00       	mov    0xc0c,%eax
  18:	89 44 24 08          	mov    %eax,0x8(%esp)
  1c:	c7 44 24 04 0c 09 00 	movl   $0x90c,0x4(%esp)
  23:	00 
  24:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  2b:	e8 0e 05 00 00       	call   53e <printf>
  printf(1, "hello, this is child! passed argument = %x \n", *(int*)args);
  30:	8b 45 08             	mov    0x8(%ebp),%eax
  33:	8b 00                	mov    (%eax),%eax
  35:	89 44 24 08          	mov    %eax,0x8(%esp)
  39:	c7 44 24 04 24 09 00 	movl   $0x924,0x4(%esp)
  40:	00 
  41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  48:	e8 f1 04 00 00       	call   53e <printf>
  return;
  4d:	90                   	nop
}
  4e:	c9                   	leave  
  4f:	c3                   	ret    

00000050 <main>:

int main (int argc, char** argv) {
  50:	55                   	push   %ebp
  51:	89 e5                	mov    %esp,%ebp
  53:	83 e4 f0             	and    $0xfffffff0,%esp
  56:	83 ec 20             	sub    $0x20,%esp
  int a = 0xabcd;
  59:	c7 44 24 18 cd ab 00 	movl   $0xabcd,0x18(%esp)
  60:	00 
  // allocate 1-page for new thread's stack.
  void* stack = malloc (sizeof(char)*PGSIZE);
  61:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  68:	e8 bd 07 00 00       	call   82a <malloc>
  6d:	89 44 24 14          	mov    %eax,0x14(%esp)
  printf(1, "Stack is at %p\n", stack);
  71:	8b 44 24 14          	mov    0x14(%esp),%eax
  75:	89 44 24 08          	mov    %eax,0x8(%esp)
  79:	c7 44 24 04 51 09 00 	movl   $0x951,0x4(%esp)
  80:	00 
  81:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  88:	e8 b1 04 00 00       	call   53e <printf>
  printf(1, "Shared count is at %p\n", shared_count);
  8d:	a1 0c 0c 00 00       	mov    0xc0c,%eax
  92:	89 44 24 08          	mov    %eax,0x8(%esp)
  96:	c7 44 24 04 0c 09 00 	movl   $0x90c,0x4(%esp)
  9d:	00 
  9e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a5:	e8 94 04 00 00       	call   53e <printf>
  //mtx_lock(1);
  shared_count = shared_count+1;
  aa:	a1 0c 0c 00 00       	mov    0xc0c,%eax
  af:	83 c0 01             	add    $0x1,%eax
  b2:	a3 0c 0c 00 00       	mov    %eax,0xc0c
  //mtx_unlock(1);
  int rc = thread_create ( &child, stack, (void*)&a);
  b7:	8b 44 24 14          	mov    0x14(%esp),%eax
  bb:	8d 54 24 18          	lea    0x18(%esp),%edx
  bf:	89 54 24 08          	mov    %edx,0x8(%esp)
  c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  ce:	e8 63 03 00 00       	call   436 <thread_create>
  d3:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  if (rc < 0) {
  d7:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  dc:	79 14                	jns    f2 <main+0xa2>
    printf (1, "thread create failed \n");
  de:	c7 44 24 04 61 09 00 	movl   $0x961,0x4(%esp)
  e5:	00 
  e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ed:	e8 4c 04 00 00       	call   53e <printf>
  }
  if(rc!=0)
  f2:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  f7:	74 1c                	je     115 <main+0xc5>
  printf(1, "thread id = %d \n", rc);
  f9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  fd:	89 44 24 08          	mov    %eax,0x8(%esp)
 101:	c7 44 24 04 78 09 00 	movl   $0x978,0x4(%esp)
 108:	00 
 109:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 110:	e8 29 04 00 00       	call   53e <printf>
  thread_join(&stack);
 115:	8d 44 24 14          	lea    0x14(%esp),%eax
 119:	89 04 24             	mov    %eax,(%esp)
 11c:	e8 1d 03 00 00       	call   43e <thread_join>
  exit();
 121:	e8 68 02 00 00       	call   38e <exit>

00000126 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 126:	55                   	push   %ebp
 127:	89 e5                	mov    %esp,%ebp
 129:	57                   	push   %edi
 12a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 12b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 12e:	8b 55 10             	mov    0x10(%ebp),%edx
 131:	8b 45 0c             	mov    0xc(%ebp),%eax
 134:	89 cb                	mov    %ecx,%ebx
 136:	89 df                	mov    %ebx,%edi
 138:	89 d1                	mov    %edx,%ecx
 13a:	fc                   	cld    
 13b:	f3 aa                	rep stos %al,%es:(%edi)
 13d:	89 ca                	mov    %ecx,%edx
 13f:	89 fb                	mov    %edi,%ebx
 141:	89 5d 08             	mov    %ebx,0x8(%ebp)
 144:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 147:	5b                   	pop    %ebx
 148:	5f                   	pop    %edi
 149:	5d                   	pop    %ebp
 14a:	c3                   	ret    

0000014b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 14b:	55                   	push   %ebp
 14c:	89 e5                	mov    %esp,%ebp
 14e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 151:	8b 45 08             	mov    0x8(%ebp),%eax
 154:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 157:	90                   	nop
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	8d 50 01             	lea    0x1(%eax),%edx
 15e:	89 55 08             	mov    %edx,0x8(%ebp)
 161:	8b 55 0c             	mov    0xc(%ebp),%edx
 164:	8d 4a 01             	lea    0x1(%edx),%ecx
 167:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 16a:	0f b6 12             	movzbl (%edx),%edx
 16d:	88 10                	mov    %dl,(%eax)
 16f:	0f b6 00             	movzbl (%eax),%eax
 172:	84 c0                	test   %al,%al
 174:	75 e2                	jne    158 <strcpy+0xd>
    ;
  return os;
 176:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 179:	c9                   	leave  
 17a:	c3                   	ret    

0000017b <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17b:	55                   	push   %ebp
 17c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 17e:	eb 08                	jmp    188 <strcmp+0xd>
    p++, q++;
 180:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 184:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 188:	8b 45 08             	mov    0x8(%ebp),%eax
 18b:	0f b6 00             	movzbl (%eax),%eax
 18e:	84 c0                	test   %al,%al
 190:	74 10                	je     1a2 <strcmp+0x27>
 192:	8b 45 08             	mov    0x8(%ebp),%eax
 195:	0f b6 10             	movzbl (%eax),%edx
 198:	8b 45 0c             	mov    0xc(%ebp),%eax
 19b:	0f b6 00             	movzbl (%eax),%eax
 19e:	38 c2                	cmp    %al,%dl
 1a0:	74 de                	je     180 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1a2:	8b 45 08             	mov    0x8(%ebp),%eax
 1a5:	0f b6 00             	movzbl (%eax),%eax
 1a8:	0f b6 d0             	movzbl %al,%edx
 1ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ae:	0f b6 00             	movzbl (%eax),%eax
 1b1:	0f b6 c0             	movzbl %al,%eax
 1b4:	29 c2                	sub    %eax,%edx
 1b6:	89 d0                	mov    %edx,%eax
}
 1b8:	5d                   	pop    %ebp
 1b9:	c3                   	ret    

000001ba <strlen>:

uint
strlen(char *s)
{
 1ba:	55                   	push   %ebp
 1bb:	89 e5                	mov    %esp,%ebp
 1bd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1c0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1c7:	eb 04                	jmp    1cd <strlen+0x13>
 1c9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1cd:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1d0:	8b 45 08             	mov    0x8(%ebp),%eax
 1d3:	01 d0                	add    %edx,%eax
 1d5:	0f b6 00             	movzbl (%eax),%eax
 1d8:	84 c0                	test   %al,%al
 1da:	75 ed                	jne    1c9 <strlen+0xf>
    ;
  return n;
 1dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1df:	c9                   	leave  
 1e0:	c3                   	ret    

000001e1 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1e7:	8b 45 10             	mov    0x10(%ebp),%eax
 1ea:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f1:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f5:	8b 45 08             	mov    0x8(%ebp),%eax
 1f8:	89 04 24             	mov    %eax,(%esp)
 1fb:	e8 26 ff ff ff       	call   126 <stosb>
  return dst;
 200:	8b 45 08             	mov    0x8(%ebp),%eax
}
 203:	c9                   	leave  
 204:	c3                   	ret    

00000205 <strchr>:

char*
strchr(const char *s, char c)
{
 205:	55                   	push   %ebp
 206:	89 e5                	mov    %esp,%ebp
 208:	83 ec 04             	sub    $0x4,%esp
 20b:	8b 45 0c             	mov    0xc(%ebp),%eax
 20e:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 211:	eb 14                	jmp    227 <strchr+0x22>
    if(*s == c)
 213:	8b 45 08             	mov    0x8(%ebp),%eax
 216:	0f b6 00             	movzbl (%eax),%eax
 219:	3a 45 fc             	cmp    -0x4(%ebp),%al
 21c:	75 05                	jne    223 <strchr+0x1e>
      return (char*)s;
 21e:	8b 45 08             	mov    0x8(%ebp),%eax
 221:	eb 13                	jmp    236 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 223:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 227:	8b 45 08             	mov    0x8(%ebp),%eax
 22a:	0f b6 00             	movzbl (%eax),%eax
 22d:	84 c0                	test   %al,%al
 22f:	75 e2                	jne    213 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 231:	b8 00 00 00 00       	mov    $0x0,%eax
}
 236:	c9                   	leave  
 237:	c3                   	ret    

00000238 <gets>:

char*
gets(char *buf, int max)
{
 238:	55                   	push   %ebp
 239:	89 e5                	mov    %esp,%ebp
 23b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 245:	eb 4c                	jmp    293 <gets+0x5b>
    cc = read(0, &c, 1);
 247:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 24e:	00 
 24f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 252:	89 44 24 04          	mov    %eax,0x4(%esp)
 256:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 25d:	e8 44 01 00 00       	call   3a6 <read>
 262:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 265:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 269:	7f 02                	jg     26d <gets+0x35>
      break;
 26b:	eb 31                	jmp    29e <gets+0x66>
    buf[i++] = c;
 26d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 270:	8d 50 01             	lea    0x1(%eax),%edx
 273:	89 55 f4             	mov    %edx,-0xc(%ebp)
 276:	89 c2                	mov    %eax,%edx
 278:	8b 45 08             	mov    0x8(%ebp),%eax
 27b:	01 c2                	add    %eax,%edx
 27d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 281:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 283:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 287:	3c 0a                	cmp    $0xa,%al
 289:	74 13                	je     29e <gets+0x66>
 28b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 28f:	3c 0d                	cmp    $0xd,%al
 291:	74 0b                	je     29e <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 293:	8b 45 f4             	mov    -0xc(%ebp),%eax
 296:	83 c0 01             	add    $0x1,%eax
 299:	3b 45 0c             	cmp    0xc(%ebp),%eax
 29c:	7c a9                	jl     247 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 29e:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	01 d0                	add    %edx,%eax
 2a6:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2a9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ac:	c9                   	leave  
 2ad:	c3                   	ret    

000002ae <stat>:

int
stat(char *n, struct stat *st)
{
 2ae:	55                   	push   %ebp
 2af:	89 e5                	mov    %esp,%ebp
 2b1:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2bb:	00 
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
 2bf:	89 04 24             	mov    %eax,(%esp)
 2c2:	e8 07 01 00 00       	call   3ce <open>
 2c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2ce:	79 07                	jns    2d7 <stat+0x29>
    return -1;
 2d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2d5:	eb 23                	jmp    2fa <stat+0x4c>
  r = fstat(fd, st);
 2d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 2da:	89 44 24 04          	mov    %eax,0x4(%esp)
 2de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e1:	89 04 24             	mov    %eax,(%esp)
 2e4:	e8 fd 00 00 00       	call   3e6 <fstat>
 2e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ef:	89 04 24             	mov    %eax,(%esp)
 2f2:	e8 bf 00 00 00       	call   3b6 <close>
  return r;
 2f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2fa:	c9                   	leave  
 2fb:	c3                   	ret    

000002fc <atoi>:

int
atoi(const char *s)
{
 2fc:	55                   	push   %ebp
 2fd:	89 e5                	mov    %esp,%ebp
 2ff:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 302:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 309:	eb 25                	jmp    330 <atoi+0x34>
    n = n*10 + *s++ - '0';
 30b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 30e:	89 d0                	mov    %edx,%eax
 310:	c1 e0 02             	shl    $0x2,%eax
 313:	01 d0                	add    %edx,%eax
 315:	01 c0                	add    %eax,%eax
 317:	89 c1                	mov    %eax,%ecx
 319:	8b 45 08             	mov    0x8(%ebp),%eax
 31c:	8d 50 01             	lea    0x1(%eax),%edx
 31f:	89 55 08             	mov    %edx,0x8(%ebp)
 322:	0f b6 00             	movzbl (%eax),%eax
 325:	0f be c0             	movsbl %al,%eax
 328:	01 c8                	add    %ecx,%eax
 32a:	83 e8 30             	sub    $0x30,%eax
 32d:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 330:	8b 45 08             	mov    0x8(%ebp),%eax
 333:	0f b6 00             	movzbl (%eax),%eax
 336:	3c 2f                	cmp    $0x2f,%al
 338:	7e 0a                	jle    344 <atoi+0x48>
 33a:	8b 45 08             	mov    0x8(%ebp),%eax
 33d:	0f b6 00             	movzbl (%eax),%eax
 340:	3c 39                	cmp    $0x39,%al
 342:	7e c7                	jle    30b <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 344:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 347:	c9                   	leave  
 348:	c3                   	ret    

00000349 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 349:	55                   	push   %ebp
 34a:	89 e5                	mov    %esp,%ebp
 34c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
 352:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 355:	8b 45 0c             	mov    0xc(%ebp),%eax
 358:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 35b:	eb 17                	jmp    374 <memmove+0x2b>
    *dst++ = *src++;
 35d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 360:	8d 50 01             	lea    0x1(%eax),%edx
 363:	89 55 fc             	mov    %edx,-0x4(%ebp)
 366:	8b 55 f8             	mov    -0x8(%ebp),%edx
 369:	8d 4a 01             	lea    0x1(%edx),%ecx
 36c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 36f:	0f b6 12             	movzbl (%edx),%edx
 372:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 374:	8b 45 10             	mov    0x10(%ebp),%eax
 377:	8d 50 ff             	lea    -0x1(%eax),%edx
 37a:	89 55 10             	mov    %edx,0x10(%ebp)
 37d:	85 c0                	test   %eax,%eax
 37f:	7f dc                	jg     35d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 381:	8b 45 08             	mov    0x8(%ebp),%eax
}
 384:	c9                   	leave  
 385:	c3                   	ret    

00000386 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 386:	b8 01 00 00 00       	mov    $0x1,%eax
 38b:	cd 40                	int    $0x40
 38d:	c3                   	ret    

0000038e <exit>:
SYSCALL(exit)
 38e:	b8 02 00 00 00       	mov    $0x2,%eax
 393:	cd 40                	int    $0x40
 395:	c3                   	ret    

00000396 <wait>:
SYSCALL(wait)
 396:	b8 03 00 00 00       	mov    $0x3,%eax
 39b:	cd 40                	int    $0x40
 39d:	c3                   	ret    

0000039e <pipe>:
SYSCALL(pipe)
 39e:	b8 04 00 00 00       	mov    $0x4,%eax
 3a3:	cd 40                	int    $0x40
 3a5:	c3                   	ret    

000003a6 <read>:
SYSCALL(read)
 3a6:	b8 05 00 00 00       	mov    $0x5,%eax
 3ab:	cd 40                	int    $0x40
 3ad:	c3                   	ret    

000003ae <write>:
SYSCALL(write)
 3ae:	b8 10 00 00 00       	mov    $0x10,%eax
 3b3:	cd 40                	int    $0x40
 3b5:	c3                   	ret    

000003b6 <close>:
SYSCALL(close)
 3b6:	b8 15 00 00 00       	mov    $0x15,%eax
 3bb:	cd 40                	int    $0x40
 3bd:	c3                   	ret    

000003be <kill>:
SYSCALL(kill)
 3be:	b8 06 00 00 00       	mov    $0x6,%eax
 3c3:	cd 40                	int    $0x40
 3c5:	c3                   	ret    

000003c6 <exec>:
SYSCALL(exec)
 3c6:	b8 07 00 00 00       	mov    $0x7,%eax
 3cb:	cd 40                	int    $0x40
 3cd:	c3                   	ret    

000003ce <open>:
SYSCALL(open)
 3ce:	b8 0f 00 00 00       	mov    $0xf,%eax
 3d3:	cd 40                	int    $0x40
 3d5:	c3                   	ret    

000003d6 <mknod>:
SYSCALL(mknod)
 3d6:	b8 11 00 00 00       	mov    $0x11,%eax
 3db:	cd 40                	int    $0x40
 3dd:	c3                   	ret    

000003de <unlink>:
SYSCALL(unlink)
 3de:	b8 12 00 00 00       	mov    $0x12,%eax
 3e3:	cd 40                	int    $0x40
 3e5:	c3                   	ret    

000003e6 <fstat>:
SYSCALL(fstat)
 3e6:	b8 08 00 00 00       	mov    $0x8,%eax
 3eb:	cd 40                	int    $0x40
 3ed:	c3                   	ret    

000003ee <link>:
SYSCALL(link)
 3ee:	b8 13 00 00 00       	mov    $0x13,%eax
 3f3:	cd 40                	int    $0x40
 3f5:	c3                   	ret    

000003f6 <mkdir>:
SYSCALL(mkdir)
 3f6:	b8 14 00 00 00       	mov    $0x14,%eax
 3fb:	cd 40                	int    $0x40
 3fd:	c3                   	ret    

000003fe <chdir>:
SYSCALL(chdir)
 3fe:	b8 09 00 00 00       	mov    $0x9,%eax
 403:	cd 40                	int    $0x40
 405:	c3                   	ret    

00000406 <dup>:
SYSCALL(dup)
 406:	b8 0a 00 00 00       	mov    $0xa,%eax
 40b:	cd 40                	int    $0x40
 40d:	c3                   	ret    

0000040e <getpid>:
SYSCALL(getpid)
 40e:	b8 0b 00 00 00       	mov    $0xb,%eax
 413:	cd 40                	int    $0x40
 415:	c3                   	ret    

00000416 <sbrk>:
SYSCALL(sbrk)
 416:	b8 0c 00 00 00       	mov    $0xc,%eax
 41b:	cd 40                	int    $0x40
 41d:	c3                   	ret    

0000041e <sleep>:
SYSCALL(sleep)
 41e:	b8 0d 00 00 00       	mov    $0xd,%eax
 423:	cd 40                	int    $0x40
 425:	c3                   	ret    

00000426 <uptime>:
SYSCALL(uptime)
 426:	b8 0e 00 00 00       	mov    $0xe,%eax
 42b:	cd 40                	int    $0x40
 42d:	c3                   	ret    

0000042e <getcount>:
// To define asm routine for the new call.
SYSCALL(getcount)
 42e:	b8 16 00 00 00       	mov    $0x16,%eax
 433:	cd 40                	int    $0x40
 435:	c3                   	ret    

00000436 <thread_create>:
// To define asm routines for the new thread management calls.
SYSCALL(thread_create)
 436:	b8 17 00 00 00       	mov    $0x17,%eax
 43b:	cd 40                	int    $0x40
 43d:	c3                   	ret    

0000043e <thread_join>:
SYSCALL(thread_join)
 43e:	b8 18 00 00 00       	mov    $0x18,%eax
 443:	cd 40                	int    $0x40
 445:	c3                   	ret    

00000446 <mtx_create>:
SYSCALL(mtx_create)
 446:	b8 19 00 00 00       	mov    $0x19,%eax
 44b:	cd 40                	int    $0x40
 44d:	c3                   	ret    

0000044e <mtx_lock>:
SYSCALL(mtx_lock)
 44e:	b8 1a 00 00 00       	mov    $0x1a,%eax
 453:	cd 40                	int    $0x40
 455:	c3                   	ret    

00000456 <mtx_unlock>:
SYSCALL(mtx_unlock)
 456:	b8 1b 00 00 00       	mov    $0x1b,%eax
 45b:	cd 40                	int    $0x40
 45d:	c3                   	ret    

0000045e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 45e:	55                   	push   %ebp
 45f:	89 e5                	mov    %esp,%ebp
 461:	83 ec 18             	sub    $0x18,%esp
 464:	8b 45 0c             	mov    0xc(%ebp),%eax
 467:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 46a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 471:	00 
 472:	8d 45 f4             	lea    -0xc(%ebp),%eax
 475:	89 44 24 04          	mov    %eax,0x4(%esp)
 479:	8b 45 08             	mov    0x8(%ebp),%eax
 47c:	89 04 24             	mov    %eax,(%esp)
 47f:	e8 2a ff ff ff       	call   3ae <write>
}
 484:	c9                   	leave  
 485:	c3                   	ret    

00000486 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 486:	55                   	push   %ebp
 487:	89 e5                	mov    %esp,%ebp
 489:	56                   	push   %esi
 48a:	53                   	push   %ebx
 48b:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 48e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 495:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 499:	74 17                	je     4b2 <printint+0x2c>
 49b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 49f:	79 11                	jns    4b2 <printint+0x2c>
    neg = 1;
 4a1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ab:	f7 d8                	neg    %eax
 4ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4b0:	eb 06                	jmp    4b8 <printint+0x32>
  } else {
    x = xx;
 4b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4bf:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4c2:	8d 41 01             	lea    0x1(%ecx),%eax
 4c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4ce:	ba 00 00 00 00       	mov    $0x0,%edx
 4d3:	f7 f3                	div    %ebx
 4d5:	89 d0                	mov    %edx,%eax
 4d7:	0f b6 80 f8 0b 00 00 	movzbl 0xbf8(%eax),%eax
 4de:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4e2:	8b 75 10             	mov    0x10(%ebp),%esi
 4e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4e8:	ba 00 00 00 00       	mov    $0x0,%edx
 4ed:	f7 f6                	div    %esi
 4ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4f2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4f6:	75 c7                	jne    4bf <printint+0x39>
  if(neg)
 4f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4fc:	74 10                	je     50e <printint+0x88>
    buf[i++] = '-';
 4fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 501:	8d 50 01             	lea    0x1(%eax),%edx
 504:	89 55 f4             	mov    %edx,-0xc(%ebp)
 507:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 50c:	eb 1f                	jmp    52d <printint+0xa7>
 50e:	eb 1d                	jmp    52d <printint+0xa7>
    putc(fd, buf[i]);
 510:	8d 55 dc             	lea    -0x24(%ebp),%edx
 513:	8b 45 f4             	mov    -0xc(%ebp),%eax
 516:	01 d0                	add    %edx,%eax
 518:	0f b6 00             	movzbl (%eax),%eax
 51b:	0f be c0             	movsbl %al,%eax
 51e:	89 44 24 04          	mov    %eax,0x4(%esp)
 522:	8b 45 08             	mov    0x8(%ebp),%eax
 525:	89 04 24             	mov    %eax,(%esp)
 528:	e8 31 ff ff ff       	call   45e <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 52d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 531:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 535:	79 d9                	jns    510 <printint+0x8a>
    putc(fd, buf[i]);
}
 537:	83 c4 30             	add    $0x30,%esp
 53a:	5b                   	pop    %ebx
 53b:	5e                   	pop    %esi
 53c:	5d                   	pop    %ebp
 53d:	c3                   	ret    

0000053e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 53e:	55                   	push   %ebp
 53f:	89 e5                	mov    %esp,%ebp
 541:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 544:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 54b:	8d 45 0c             	lea    0xc(%ebp),%eax
 54e:	83 c0 04             	add    $0x4,%eax
 551:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 554:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 55b:	e9 7c 01 00 00       	jmp    6dc <printf+0x19e>
    c = fmt[i] & 0xff;
 560:	8b 55 0c             	mov    0xc(%ebp),%edx
 563:	8b 45 f0             	mov    -0x10(%ebp),%eax
 566:	01 d0                	add    %edx,%eax
 568:	0f b6 00             	movzbl (%eax),%eax
 56b:	0f be c0             	movsbl %al,%eax
 56e:	25 ff 00 00 00       	and    $0xff,%eax
 573:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 576:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 57a:	75 2c                	jne    5a8 <printf+0x6a>
      if(c == '%'){
 57c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 580:	75 0c                	jne    58e <printf+0x50>
        state = '%';
 582:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 589:	e9 4a 01 00 00       	jmp    6d8 <printf+0x19a>
      } else {
        putc(fd, c);
 58e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 591:	0f be c0             	movsbl %al,%eax
 594:	89 44 24 04          	mov    %eax,0x4(%esp)
 598:	8b 45 08             	mov    0x8(%ebp),%eax
 59b:	89 04 24             	mov    %eax,(%esp)
 59e:	e8 bb fe ff ff       	call   45e <putc>
 5a3:	e9 30 01 00 00       	jmp    6d8 <printf+0x19a>
      }
    } else if(state == '%'){
 5a8:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5ac:	0f 85 26 01 00 00    	jne    6d8 <printf+0x19a>
      if(c == 'd'){
 5b2:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5b6:	75 2d                	jne    5e5 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5bb:	8b 00                	mov    (%eax),%eax
 5bd:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5c4:	00 
 5c5:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5cc:	00 
 5cd:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d1:	8b 45 08             	mov    0x8(%ebp),%eax
 5d4:	89 04 24             	mov    %eax,(%esp)
 5d7:	e8 aa fe ff ff       	call   486 <printint>
        ap++;
 5dc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e0:	e9 ec 00 00 00       	jmp    6d1 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5e5:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5e9:	74 06                	je     5f1 <printf+0xb3>
 5eb:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5ef:	75 2d                	jne    61e <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f4:	8b 00                	mov    (%eax),%eax
 5f6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5fd:	00 
 5fe:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 605:	00 
 606:	89 44 24 04          	mov    %eax,0x4(%esp)
 60a:	8b 45 08             	mov    0x8(%ebp),%eax
 60d:	89 04 24             	mov    %eax,(%esp)
 610:	e8 71 fe ff ff       	call   486 <printint>
        ap++;
 615:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 619:	e9 b3 00 00 00       	jmp    6d1 <printf+0x193>
      } else if(c == 's'){
 61e:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 622:	75 45                	jne    669 <printf+0x12b>
        s = (char*)*ap;
 624:	8b 45 e8             	mov    -0x18(%ebp),%eax
 627:	8b 00                	mov    (%eax),%eax
 629:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 62c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 630:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 634:	75 09                	jne    63f <printf+0x101>
          s = "(null)";
 636:	c7 45 f4 89 09 00 00 	movl   $0x989,-0xc(%ebp)
        while(*s != 0){
 63d:	eb 1e                	jmp    65d <printf+0x11f>
 63f:	eb 1c                	jmp    65d <printf+0x11f>
          putc(fd, *s);
 641:	8b 45 f4             	mov    -0xc(%ebp),%eax
 644:	0f b6 00             	movzbl (%eax),%eax
 647:	0f be c0             	movsbl %al,%eax
 64a:	89 44 24 04          	mov    %eax,0x4(%esp)
 64e:	8b 45 08             	mov    0x8(%ebp),%eax
 651:	89 04 24             	mov    %eax,(%esp)
 654:	e8 05 fe ff ff       	call   45e <putc>
          s++;
 659:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 65d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 660:	0f b6 00             	movzbl (%eax),%eax
 663:	84 c0                	test   %al,%al
 665:	75 da                	jne    641 <printf+0x103>
 667:	eb 68                	jmp    6d1 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 669:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 66d:	75 1d                	jne    68c <printf+0x14e>
        putc(fd, *ap);
 66f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 672:	8b 00                	mov    (%eax),%eax
 674:	0f be c0             	movsbl %al,%eax
 677:	89 44 24 04          	mov    %eax,0x4(%esp)
 67b:	8b 45 08             	mov    0x8(%ebp),%eax
 67e:	89 04 24             	mov    %eax,(%esp)
 681:	e8 d8 fd ff ff       	call   45e <putc>
        ap++;
 686:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 68a:	eb 45                	jmp    6d1 <printf+0x193>
      } else if(c == '%'){
 68c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 690:	75 17                	jne    6a9 <printf+0x16b>
        putc(fd, c);
 692:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 695:	0f be c0             	movsbl %al,%eax
 698:	89 44 24 04          	mov    %eax,0x4(%esp)
 69c:	8b 45 08             	mov    0x8(%ebp),%eax
 69f:	89 04 24             	mov    %eax,(%esp)
 6a2:	e8 b7 fd ff ff       	call   45e <putc>
 6a7:	eb 28                	jmp    6d1 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6a9:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6b0:	00 
 6b1:	8b 45 08             	mov    0x8(%ebp),%eax
 6b4:	89 04 24             	mov    %eax,(%esp)
 6b7:	e8 a2 fd ff ff       	call   45e <putc>
        putc(fd, c);
 6bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6bf:	0f be c0             	movsbl %al,%eax
 6c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c6:	8b 45 08             	mov    0x8(%ebp),%eax
 6c9:	89 04 24             	mov    %eax,(%esp)
 6cc:	e8 8d fd ff ff       	call   45e <putc>
      }
      state = 0;
 6d1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6d8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6dc:	8b 55 0c             	mov    0xc(%ebp),%edx
 6df:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e2:	01 d0                	add    %edx,%eax
 6e4:	0f b6 00             	movzbl (%eax),%eax
 6e7:	84 c0                	test   %al,%al
 6e9:	0f 85 71 fe ff ff    	jne    560 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6ef:	c9                   	leave  
 6f0:	c3                   	ret    

000006f1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6f1:	55                   	push   %ebp
 6f2:	89 e5                	mov    %esp,%ebp
 6f4:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6f7:	8b 45 08             	mov    0x8(%ebp),%eax
 6fa:	83 e8 08             	sub    $0x8,%eax
 6fd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 700:	a1 18 0c 00 00       	mov    0xc18,%eax
 705:	89 45 fc             	mov    %eax,-0x4(%ebp)
 708:	eb 24                	jmp    72e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 70a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70d:	8b 00                	mov    (%eax),%eax
 70f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 712:	77 12                	ja     726 <free+0x35>
 714:	8b 45 f8             	mov    -0x8(%ebp),%eax
 717:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 71a:	77 24                	ja     740 <free+0x4f>
 71c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71f:	8b 00                	mov    (%eax),%eax
 721:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 724:	77 1a                	ja     740 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 726:	8b 45 fc             	mov    -0x4(%ebp),%eax
 729:	8b 00                	mov    (%eax),%eax
 72b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 72e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 731:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 734:	76 d4                	jbe    70a <free+0x19>
 736:	8b 45 fc             	mov    -0x4(%ebp),%eax
 739:	8b 00                	mov    (%eax),%eax
 73b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 73e:	76 ca                	jbe    70a <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 740:	8b 45 f8             	mov    -0x8(%ebp),%eax
 743:	8b 40 04             	mov    0x4(%eax),%eax
 746:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 74d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 750:	01 c2                	add    %eax,%edx
 752:	8b 45 fc             	mov    -0x4(%ebp),%eax
 755:	8b 00                	mov    (%eax),%eax
 757:	39 c2                	cmp    %eax,%edx
 759:	75 24                	jne    77f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 75b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75e:	8b 50 04             	mov    0x4(%eax),%edx
 761:	8b 45 fc             	mov    -0x4(%ebp),%eax
 764:	8b 00                	mov    (%eax),%eax
 766:	8b 40 04             	mov    0x4(%eax),%eax
 769:	01 c2                	add    %eax,%edx
 76b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 771:	8b 45 fc             	mov    -0x4(%ebp),%eax
 774:	8b 00                	mov    (%eax),%eax
 776:	8b 10                	mov    (%eax),%edx
 778:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77b:	89 10                	mov    %edx,(%eax)
 77d:	eb 0a                	jmp    789 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 77f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 782:	8b 10                	mov    (%eax),%edx
 784:	8b 45 f8             	mov    -0x8(%ebp),%eax
 787:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	8b 40 04             	mov    0x4(%eax),%eax
 78f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 796:	8b 45 fc             	mov    -0x4(%ebp),%eax
 799:	01 d0                	add    %edx,%eax
 79b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 79e:	75 20                	jne    7c0 <free+0xcf>
    p->s.size += bp->s.size;
 7a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a3:	8b 50 04             	mov    0x4(%eax),%edx
 7a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a9:	8b 40 04             	mov    0x4(%eax),%eax
 7ac:	01 c2                	add    %eax,%edx
 7ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b7:	8b 10                	mov    (%eax),%edx
 7b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bc:	89 10                	mov    %edx,(%eax)
 7be:	eb 08                	jmp    7c8 <free+0xd7>
  } else
    p->s.ptr = bp;
 7c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7c6:	89 10                	mov    %edx,(%eax)
  freep = p;
 7c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cb:	a3 18 0c 00 00       	mov    %eax,0xc18
}
 7d0:	c9                   	leave  
 7d1:	c3                   	ret    

000007d2 <morecore>:

static Header*
morecore(uint nu)
{
 7d2:	55                   	push   %ebp
 7d3:	89 e5                	mov    %esp,%ebp
 7d5:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7d8:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7df:	77 07                	ja     7e8 <morecore+0x16>
    nu = 4096;
 7e1:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7e8:	8b 45 08             	mov    0x8(%ebp),%eax
 7eb:	c1 e0 03             	shl    $0x3,%eax
 7ee:	89 04 24             	mov    %eax,(%esp)
 7f1:	e8 20 fc ff ff       	call   416 <sbrk>
 7f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7f9:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7fd:	75 07                	jne    806 <morecore+0x34>
    return 0;
 7ff:	b8 00 00 00 00       	mov    $0x0,%eax
 804:	eb 22                	jmp    828 <morecore+0x56>
  hp = (Header*)p;
 806:	8b 45 f4             	mov    -0xc(%ebp),%eax
 809:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 80c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80f:	8b 55 08             	mov    0x8(%ebp),%edx
 812:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 815:	8b 45 f0             	mov    -0x10(%ebp),%eax
 818:	83 c0 08             	add    $0x8,%eax
 81b:	89 04 24             	mov    %eax,(%esp)
 81e:	e8 ce fe ff ff       	call   6f1 <free>
  return freep;
 823:	a1 18 0c 00 00       	mov    0xc18,%eax
}
 828:	c9                   	leave  
 829:	c3                   	ret    

0000082a <malloc>:

void*
malloc(uint nbytes)
{
 82a:	55                   	push   %ebp
 82b:	89 e5                	mov    %esp,%ebp
 82d:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 830:	8b 45 08             	mov    0x8(%ebp),%eax
 833:	83 c0 07             	add    $0x7,%eax
 836:	c1 e8 03             	shr    $0x3,%eax
 839:	83 c0 01             	add    $0x1,%eax
 83c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 83f:	a1 18 0c 00 00       	mov    0xc18,%eax
 844:	89 45 f0             	mov    %eax,-0x10(%ebp)
 847:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 84b:	75 23                	jne    870 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 84d:	c7 45 f0 10 0c 00 00 	movl   $0xc10,-0x10(%ebp)
 854:	8b 45 f0             	mov    -0x10(%ebp),%eax
 857:	a3 18 0c 00 00       	mov    %eax,0xc18
 85c:	a1 18 0c 00 00       	mov    0xc18,%eax
 861:	a3 10 0c 00 00       	mov    %eax,0xc10
    base.s.size = 0;
 866:	c7 05 14 0c 00 00 00 	movl   $0x0,0xc14
 86d:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 870:	8b 45 f0             	mov    -0x10(%ebp),%eax
 873:	8b 00                	mov    (%eax),%eax
 875:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 878:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87b:	8b 40 04             	mov    0x4(%eax),%eax
 87e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 881:	72 4d                	jb     8d0 <malloc+0xa6>
      if(p->s.size == nunits)
 883:	8b 45 f4             	mov    -0xc(%ebp),%eax
 886:	8b 40 04             	mov    0x4(%eax),%eax
 889:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 88c:	75 0c                	jne    89a <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 88e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 891:	8b 10                	mov    (%eax),%edx
 893:	8b 45 f0             	mov    -0x10(%ebp),%eax
 896:	89 10                	mov    %edx,(%eax)
 898:	eb 26                	jmp    8c0 <malloc+0x96>
      else {
        p->s.size -= nunits;
 89a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89d:	8b 40 04             	mov    0x4(%eax),%eax
 8a0:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8a3:	89 c2                	mov    %eax,%edx
 8a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a8:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ae:	8b 40 04             	mov    0x4(%eax),%eax
 8b1:	c1 e0 03             	shl    $0x3,%eax
 8b4:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ba:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8bd:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c3:	a3 18 0c 00 00       	mov    %eax,0xc18
      return (void*)(p + 1);
 8c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cb:	83 c0 08             	add    $0x8,%eax
 8ce:	eb 38                	jmp    908 <malloc+0xde>
    }
    if(p == freep)
 8d0:	a1 18 0c 00 00       	mov    0xc18,%eax
 8d5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8d8:	75 1b                	jne    8f5 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8da:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8dd:	89 04 24             	mov    %eax,(%esp)
 8e0:	e8 ed fe ff ff       	call   7d2 <morecore>
 8e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8ec:	75 07                	jne    8f5 <malloc+0xcb>
        return 0;
 8ee:	b8 00 00 00 00       	mov    $0x0,%eax
 8f3:	eb 13                	jmp    908 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fe:	8b 00                	mov    (%eax),%eax
 900:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 903:	e9 70 ff ff ff       	jmp    878 <malloc+0x4e>
}
 908:	c9                   	leave  
 909:	c3                   	ret    
