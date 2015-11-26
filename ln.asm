
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(argc != 3){
   9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
   d:	74 19                	je     28 <main+0x28>
    printf(2, "Usage: ln old new\n");
   f:	c7 44 24 04 5d 08 00 	movl   $0x85d,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 6e 04 00 00       	call   491 <printf>
    exit();
  23:	e8 b9 02 00 00       	call   2e1 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	83 c0 08             	add    $0x8,%eax
  2e:	8b 10                	mov    (%eax),%edx
  30:	8b 45 0c             	mov    0xc(%ebp),%eax
  33:	83 c0 04             	add    $0x4,%eax
  36:	8b 00                	mov    (%eax),%eax
  38:	89 54 24 04          	mov    %edx,0x4(%esp)
  3c:	89 04 24             	mov    %eax,(%esp)
  3f:	e8 fd 02 00 00       	call   341 <link>
  44:	85 c0                	test   %eax,%eax
  46:	79 2c                	jns    74 <main+0x74>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	8b 45 0c             	mov    0xc(%ebp),%eax
  4b:	83 c0 08             	add    $0x8,%eax
  4e:	8b 10                	mov    (%eax),%edx
  50:	8b 45 0c             	mov    0xc(%ebp),%eax
  53:	83 c0 04             	add    $0x4,%eax
  56:	8b 00                	mov    (%eax),%eax
  58:	89 54 24 0c          	mov    %edx,0xc(%esp)
  5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  60:	c7 44 24 04 70 08 00 	movl   $0x870,0x4(%esp)
  67:	00 
  68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  6f:	e8 1d 04 00 00       	call   491 <printf>
  exit();
  74:	e8 68 02 00 00       	call   2e1 <exit>

00000079 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  79:	55                   	push   %ebp
  7a:	89 e5                	mov    %esp,%ebp
  7c:	57                   	push   %edi
  7d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  81:	8b 55 10             	mov    0x10(%ebp),%edx
  84:	8b 45 0c             	mov    0xc(%ebp),%eax
  87:	89 cb                	mov    %ecx,%ebx
  89:	89 df                	mov    %ebx,%edi
  8b:	89 d1                	mov    %edx,%ecx
  8d:	fc                   	cld    
  8e:	f3 aa                	rep stos %al,%es:(%edi)
  90:	89 ca                	mov    %ecx,%edx
  92:	89 fb                	mov    %edi,%ebx
  94:	89 5d 08             	mov    %ebx,0x8(%ebp)
  97:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  9a:	5b                   	pop    %ebx
  9b:	5f                   	pop    %edi
  9c:	5d                   	pop    %ebp
  9d:	c3                   	ret    

0000009e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  9e:	55                   	push   %ebp
  9f:	89 e5                	mov    %esp,%ebp
  a1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a4:	8b 45 08             	mov    0x8(%ebp),%eax
  a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  aa:	90                   	nop
  ab:	8b 45 08             	mov    0x8(%ebp),%eax
  ae:	8d 50 01             	lea    0x1(%eax),%edx
  b1:	89 55 08             	mov    %edx,0x8(%ebp)
  b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  ba:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  bd:	0f b6 12             	movzbl (%edx),%edx
  c0:	88 10                	mov    %dl,(%eax)
  c2:	0f b6 00             	movzbl (%eax),%eax
  c5:	84 c0                	test   %al,%al
  c7:	75 e2                	jne    ab <strcpy+0xd>
    ;
  return os;
  c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  cc:	c9                   	leave  
  cd:	c3                   	ret    

000000ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ce:	55                   	push   %ebp
  cf:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  d1:	eb 08                	jmp    db <strcmp+0xd>
    p++, q++;
  d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  d7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  db:	8b 45 08             	mov    0x8(%ebp),%eax
  de:	0f b6 00             	movzbl (%eax),%eax
  e1:	84 c0                	test   %al,%al
  e3:	74 10                	je     f5 <strcmp+0x27>
  e5:	8b 45 08             	mov    0x8(%ebp),%eax
  e8:	0f b6 10             	movzbl (%eax),%edx
  eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  ee:	0f b6 00             	movzbl (%eax),%eax
  f1:	38 c2                	cmp    %al,%dl
  f3:	74 de                	je     d3 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  f5:	8b 45 08             	mov    0x8(%ebp),%eax
  f8:	0f b6 00             	movzbl (%eax),%eax
  fb:	0f b6 d0             	movzbl %al,%edx
  fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 101:	0f b6 00             	movzbl (%eax),%eax
 104:	0f b6 c0             	movzbl %al,%eax
 107:	29 c2                	sub    %eax,%edx
 109:	89 d0                	mov    %edx,%eax
}
 10b:	5d                   	pop    %ebp
 10c:	c3                   	ret    

0000010d <strlen>:

uint
strlen(char *s)
{
 10d:	55                   	push   %ebp
 10e:	89 e5                	mov    %esp,%ebp
 110:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 113:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 11a:	eb 04                	jmp    120 <strlen+0x13>
 11c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 120:	8b 55 fc             	mov    -0x4(%ebp),%edx
 123:	8b 45 08             	mov    0x8(%ebp),%eax
 126:	01 d0                	add    %edx,%eax
 128:	0f b6 00             	movzbl (%eax),%eax
 12b:	84 c0                	test   %al,%al
 12d:	75 ed                	jne    11c <strlen+0xf>
    ;
  return n;
 12f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 132:	c9                   	leave  
 133:	c3                   	ret    

00000134 <memset>:

void*
memset(void *dst, int c, uint n)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 13a:	8b 45 10             	mov    0x10(%ebp),%eax
 13d:	89 44 24 08          	mov    %eax,0x8(%esp)
 141:	8b 45 0c             	mov    0xc(%ebp),%eax
 144:	89 44 24 04          	mov    %eax,0x4(%esp)
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	89 04 24             	mov    %eax,(%esp)
 14e:	e8 26 ff ff ff       	call   79 <stosb>
  return dst;
 153:	8b 45 08             	mov    0x8(%ebp),%eax
}
 156:	c9                   	leave  
 157:	c3                   	ret    

00000158 <strchr>:

char*
strchr(const char *s, char c)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	83 ec 04             	sub    $0x4,%esp
 15e:	8b 45 0c             	mov    0xc(%ebp),%eax
 161:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 164:	eb 14                	jmp    17a <strchr+0x22>
    if(*s == c)
 166:	8b 45 08             	mov    0x8(%ebp),%eax
 169:	0f b6 00             	movzbl (%eax),%eax
 16c:	3a 45 fc             	cmp    -0x4(%ebp),%al
 16f:	75 05                	jne    176 <strchr+0x1e>
      return (char*)s;
 171:	8b 45 08             	mov    0x8(%ebp),%eax
 174:	eb 13                	jmp    189 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 176:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17a:	8b 45 08             	mov    0x8(%ebp),%eax
 17d:	0f b6 00             	movzbl (%eax),%eax
 180:	84 c0                	test   %al,%al
 182:	75 e2                	jne    166 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 184:	b8 00 00 00 00       	mov    $0x0,%eax
}
 189:	c9                   	leave  
 18a:	c3                   	ret    

0000018b <gets>:

char*
gets(char *buf, int max)
{
 18b:	55                   	push   %ebp
 18c:	89 e5                	mov    %esp,%ebp
 18e:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 191:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 198:	eb 4c                	jmp    1e6 <gets+0x5b>
    cc = read(0, &c, 1);
 19a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1a1:	00 
 1a2:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1a5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1b0:	e8 44 01 00 00       	call   2f9 <read>
 1b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1bc:	7f 02                	jg     1c0 <gets+0x35>
      break;
 1be:	eb 31                	jmp    1f1 <gets+0x66>
    buf[i++] = c;
 1c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c3:	8d 50 01             	lea    0x1(%eax),%edx
 1c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1c9:	89 c2                	mov    %eax,%edx
 1cb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ce:	01 c2                	add    %eax,%edx
 1d0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1d6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1da:	3c 0a                	cmp    $0xa,%al
 1dc:	74 13                	je     1f1 <gets+0x66>
 1de:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e2:	3c 0d                	cmp    $0xd,%al
 1e4:	74 0b                	je     1f1 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e9:	83 c0 01             	add    $0x1,%eax
 1ec:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1ef:	7c a9                	jl     19a <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
 1f7:	01 d0                	add    %edx,%eax
 1f9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ff:	c9                   	leave  
 200:	c3                   	ret    

00000201 <stat>:

int
stat(char *n, struct stat *st)
{
 201:	55                   	push   %ebp
 202:	89 e5                	mov    %esp,%ebp
 204:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 207:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 20e:	00 
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	89 04 24             	mov    %eax,(%esp)
 215:	e8 07 01 00 00       	call   321 <open>
 21a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 21d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 221:	79 07                	jns    22a <stat+0x29>
    return -1;
 223:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 228:	eb 23                	jmp    24d <stat+0x4c>
  r = fstat(fd, st);
 22a:	8b 45 0c             	mov    0xc(%ebp),%eax
 22d:	89 44 24 04          	mov    %eax,0x4(%esp)
 231:	8b 45 f4             	mov    -0xc(%ebp),%eax
 234:	89 04 24             	mov    %eax,(%esp)
 237:	e8 fd 00 00 00       	call   339 <fstat>
 23c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 23f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 242:	89 04 24             	mov    %eax,(%esp)
 245:	e8 bf 00 00 00       	call   309 <close>
  return r;
 24a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 24d:	c9                   	leave  
 24e:	c3                   	ret    

0000024f <atoi>:

int
atoi(const char *s)
{
 24f:	55                   	push   %ebp
 250:	89 e5                	mov    %esp,%ebp
 252:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 255:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 25c:	eb 25                	jmp    283 <atoi+0x34>
    n = n*10 + *s++ - '0';
 25e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 261:	89 d0                	mov    %edx,%eax
 263:	c1 e0 02             	shl    $0x2,%eax
 266:	01 d0                	add    %edx,%eax
 268:	01 c0                	add    %eax,%eax
 26a:	89 c1                	mov    %eax,%ecx
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	8d 50 01             	lea    0x1(%eax),%edx
 272:	89 55 08             	mov    %edx,0x8(%ebp)
 275:	0f b6 00             	movzbl (%eax),%eax
 278:	0f be c0             	movsbl %al,%eax
 27b:	01 c8                	add    %ecx,%eax
 27d:	83 e8 30             	sub    $0x30,%eax
 280:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 283:	8b 45 08             	mov    0x8(%ebp),%eax
 286:	0f b6 00             	movzbl (%eax),%eax
 289:	3c 2f                	cmp    $0x2f,%al
 28b:	7e 0a                	jle    297 <atoi+0x48>
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
 290:	0f b6 00             	movzbl (%eax),%eax
 293:	3c 39                	cmp    $0x39,%al
 295:	7e c7                	jle    25e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 297:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29a:	c9                   	leave  
 29b:	c3                   	ret    

0000029c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 29c:	55                   	push   %ebp
 29d:	89 e5                	mov    %esp,%ebp
 29f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2a2:	8b 45 08             	mov    0x8(%ebp),%eax
 2a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2ae:	eb 17                	jmp    2c7 <memmove+0x2b>
    *dst++ = *src++;
 2b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2b3:	8d 50 01             	lea    0x1(%eax),%edx
 2b6:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2b9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2bc:	8d 4a 01             	lea    0x1(%edx),%ecx
 2bf:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2c2:	0f b6 12             	movzbl (%edx),%edx
 2c5:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2c7:	8b 45 10             	mov    0x10(%ebp),%eax
 2ca:	8d 50 ff             	lea    -0x1(%eax),%edx
 2cd:	89 55 10             	mov    %edx,0x10(%ebp)
 2d0:	85 c0                	test   %eax,%eax
 2d2:	7f dc                	jg     2b0 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2d4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d7:	c9                   	leave  
 2d8:	c3                   	ret    

000002d9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2d9:	b8 01 00 00 00       	mov    $0x1,%eax
 2de:	cd 40                	int    $0x40
 2e0:	c3                   	ret    

000002e1 <exit>:
SYSCALL(exit)
 2e1:	b8 02 00 00 00       	mov    $0x2,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret    

000002e9 <wait>:
SYSCALL(wait)
 2e9:	b8 03 00 00 00       	mov    $0x3,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret    

000002f1 <pipe>:
SYSCALL(pipe)
 2f1:	b8 04 00 00 00       	mov    $0x4,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret    

000002f9 <read>:
SYSCALL(read)
 2f9:	b8 05 00 00 00       	mov    $0x5,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <write>:
SYSCALL(write)
 301:	b8 10 00 00 00       	mov    $0x10,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <close>:
SYSCALL(close)
 309:	b8 15 00 00 00       	mov    $0x15,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <kill>:
SYSCALL(kill)
 311:	b8 06 00 00 00       	mov    $0x6,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <exec>:
SYSCALL(exec)
 319:	b8 07 00 00 00       	mov    $0x7,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <open>:
SYSCALL(open)
 321:	b8 0f 00 00 00       	mov    $0xf,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <mknod>:
SYSCALL(mknod)
 329:	b8 11 00 00 00       	mov    $0x11,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <unlink>:
SYSCALL(unlink)
 331:	b8 12 00 00 00       	mov    $0x12,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <fstat>:
SYSCALL(fstat)
 339:	b8 08 00 00 00       	mov    $0x8,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <link>:
SYSCALL(link)
 341:	b8 13 00 00 00       	mov    $0x13,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <mkdir>:
SYSCALL(mkdir)
 349:	b8 14 00 00 00       	mov    $0x14,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <chdir>:
SYSCALL(chdir)
 351:	b8 09 00 00 00       	mov    $0x9,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <dup>:
SYSCALL(dup)
 359:	b8 0a 00 00 00       	mov    $0xa,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <getpid>:
SYSCALL(getpid)
 361:	b8 0b 00 00 00       	mov    $0xb,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret    

00000369 <sbrk>:
SYSCALL(sbrk)
 369:	b8 0c 00 00 00       	mov    $0xc,%eax
 36e:	cd 40                	int    $0x40
 370:	c3                   	ret    

00000371 <sleep>:
SYSCALL(sleep)
 371:	b8 0d 00 00 00       	mov    $0xd,%eax
 376:	cd 40                	int    $0x40
 378:	c3                   	ret    

00000379 <uptime>:
SYSCALL(uptime)
 379:	b8 0e 00 00 00       	mov    $0xe,%eax
 37e:	cd 40                	int    $0x40
 380:	c3                   	ret    

00000381 <getcount>:
// To define asm routine for the new call.
SYSCALL(getcount)
 381:	b8 16 00 00 00       	mov    $0x16,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret    

00000389 <thread_create>:
// To define asm routines for the new thread management calls.
SYSCALL(thread_create)
 389:	b8 17 00 00 00       	mov    $0x17,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret    

00000391 <thread_join>:
SYSCALL(thread_join)
 391:	b8 18 00 00 00       	mov    $0x18,%eax
 396:	cd 40                	int    $0x40
 398:	c3                   	ret    

00000399 <mtx_create>:
SYSCALL(mtx_create)
 399:	b8 19 00 00 00       	mov    $0x19,%eax
 39e:	cd 40                	int    $0x40
 3a0:	c3                   	ret    

000003a1 <mtx_lock>:
SYSCALL(mtx_lock)
 3a1:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3a6:	cd 40                	int    $0x40
 3a8:	c3                   	ret    

000003a9 <mtx_unlock>:
SYSCALL(mtx_unlock)
 3a9:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3ae:	cd 40                	int    $0x40
 3b0:	c3                   	ret    

000003b1 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3b1:	55                   	push   %ebp
 3b2:	89 e5                	mov    %esp,%ebp
 3b4:	83 ec 18             	sub    $0x18,%esp
 3b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ba:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3bd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3c4:	00 
 3c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3c8:	89 44 24 04          	mov    %eax,0x4(%esp)
 3cc:	8b 45 08             	mov    0x8(%ebp),%eax
 3cf:	89 04 24             	mov    %eax,(%esp)
 3d2:	e8 2a ff ff ff       	call   301 <write>
}
 3d7:	c9                   	leave  
 3d8:	c3                   	ret    

000003d9 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d9:	55                   	push   %ebp
 3da:	89 e5                	mov    %esp,%ebp
 3dc:	56                   	push   %esi
 3dd:	53                   	push   %ebx
 3de:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3e8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3ec:	74 17                	je     405 <printint+0x2c>
 3ee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3f2:	79 11                	jns    405 <printint+0x2c>
    neg = 1;
 3f4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3fb:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fe:	f7 d8                	neg    %eax
 400:	89 45 ec             	mov    %eax,-0x14(%ebp)
 403:	eb 06                	jmp    40b <printint+0x32>
  } else {
    x = xx;
 405:	8b 45 0c             	mov    0xc(%ebp),%eax
 408:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 40b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 412:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 415:	8d 41 01             	lea    0x1(%ecx),%eax
 418:	89 45 f4             	mov    %eax,-0xc(%ebp)
 41b:	8b 5d 10             	mov    0x10(%ebp),%ebx
 41e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 421:	ba 00 00 00 00       	mov    $0x0,%edx
 426:	f7 f3                	div    %ebx
 428:	89 d0                	mov    %edx,%eax
 42a:	0f b6 80 d0 0a 00 00 	movzbl 0xad0(%eax),%eax
 431:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 435:	8b 75 10             	mov    0x10(%ebp),%esi
 438:	8b 45 ec             	mov    -0x14(%ebp),%eax
 43b:	ba 00 00 00 00       	mov    $0x0,%edx
 440:	f7 f6                	div    %esi
 442:	89 45 ec             	mov    %eax,-0x14(%ebp)
 445:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 449:	75 c7                	jne    412 <printint+0x39>
  if(neg)
 44b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 44f:	74 10                	je     461 <printint+0x88>
    buf[i++] = '-';
 451:	8b 45 f4             	mov    -0xc(%ebp),%eax
 454:	8d 50 01             	lea    0x1(%eax),%edx
 457:	89 55 f4             	mov    %edx,-0xc(%ebp)
 45a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 45f:	eb 1f                	jmp    480 <printint+0xa7>
 461:	eb 1d                	jmp    480 <printint+0xa7>
    putc(fd, buf[i]);
 463:	8d 55 dc             	lea    -0x24(%ebp),%edx
 466:	8b 45 f4             	mov    -0xc(%ebp),%eax
 469:	01 d0                	add    %edx,%eax
 46b:	0f b6 00             	movzbl (%eax),%eax
 46e:	0f be c0             	movsbl %al,%eax
 471:	89 44 24 04          	mov    %eax,0x4(%esp)
 475:	8b 45 08             	mov    0x8(%ebp),%eax
 478:	89 04 24             	mov    %eax,(%esp)
 47b:	e8 31 ff ff ff       	call   3b1 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 480:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 484:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 488:	79 d9                	jns    463 <printint+0x8a>
    putc(fd, buf[i]);
}
 48a:	83 c4 30             	add    $0x30,%esp
 48d:	5b                   	pop    %ebx
 48e:	5e                   	pop    %esi
 48f:	5d                   	pop    %ebp
 490:	c3                   	ret    

00000491 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 491:	55                   	push   %ebp
 492:	89 e5                	mov    %esp,%ebp
 494:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 497:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 49e:	8d 45 0c             	lea    0xc(%ebp),%eax
 4a1:	83 c0 04             	add    $0x4,%eax
 4a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4a7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4ae:	e9 7c 01 00 00       	jmp    62f <printf+0x19e>
    c = fmt[i] & 0xff;
 4b3:	8b 55 0c             	mov    0xc(%ebp),%edx
 4b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4b9:	01 d0                	add    %edx,%eax
 4bb:	0f b6 00             	movzbl (%eax),%eax
 4be:	0f be c0             	movsbl %al,%eax
 4c1:	25 ff 00 00 00       	and    $0xff,%eax
 4c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4cd:	75 2c                	jne    4fb <printf+0x6a>
      if(c == '%'){
 4cf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4d3:	75 0c                	jne    4e1 <printf+0x50>
        state = '%';
 4d5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4dc:	e9 4a 01 00 00       	jmp    62b <printf+0x19a>
      } else {
        putc(fd, c);
 4e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4e4:	0f be c0             	movsbl %al,%eax
 4e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4eb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ee:	89 04 24             	mov    %eax,(%esp)
 4f1:	e8 bb fe ff ff       	call   3b1 <putc>
 4f6:	e9 30 01 00 00       	jmp    62b <printf+0x19a>
      }
    } else if(state == '%'){
 4fb:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ff:	0f 85 26 01 00 00    	jne    62b <printf+0x19a>
      if(c == 'd'){
 505:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 509:	75 2d                	jne    538 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 50b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50e:	8b 00                	mov    (%eax),%eax
 510:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 517:	00 
 518:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 51f:	00 
 520:	89 44 24 04          	mov    %eax,0x4(%esp)
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	89 04 24             	mov    %eax,(%esp)
 52a:	e8 aa fe ff ff       	call   3d9 <printint>
        ap++;
 52f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 533:	e9 ec 00 00 00       	jmp    624 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 538:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 53c:	74 06                	je     544 <printf+0xb3>
 53e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 542:	75 2d                	jne    571 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 544:	8b 45 e8             	mov    -0x18(%ebp),%eax
 547:	8b 00                	mov    (%eax),%eax
 549:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 550:	00 
 551:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 558:	00 
 559:	89 44 24 04          	mov    %eax,0x4(%esp)
 55d:	8b 45 08             	mov    0x8(%ebp),%eax
 560:	89 04 24             	mov    %eax,(%esp)
 563:	e8 71 fe ff ff       	call   3d9 <printint>
        ap++;
 568:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 56c:	e9 b3 00 00 00       	jmp    624 <printf+0x193>
      } else if(c == 's'){
 571:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 575:	75 45                	jne    5bc <printf+0x12b>
        s = (char*)*ap;
 577:	8b 45 e8             	mov    -0x18(%ebp),%eax
 57a:	8b 00                	mov    (%eax),%eax
 57c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 57f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 583:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 587:	75 09                	jne    592 <printf+0x101>
          s = "(null)";
 589:	c7 45 f4 84 08 00 00 	movl   $0x884,-0xc(%ebp)
        while(*s != 0){
 590:	eb 1e                	jmp    5b0 <printf+0x11f>
 592:	eb 1c                	jmp    5b0 <printf+0x11f>
          putc(fd, *s);
 594:	8b 45 f4             	mov    -0xc(%ebp),%eax
 597:	0f b6 00             	movzbl (%eax),%eax
 59a:	0f be c0             	movsbl %al,%eax
 59d:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a1:	8b 45 08             	mov    0x8(%ebp),%eax
 5a4:	89 04 24             	mov    %eax,(%esp)
 5a7:	e8 05 fe ff ff       	call   3b1 <putc>
          s++;
 5ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b3:	0f b6 00             	movzbl (%eax),%eax
 5b6:	84 c0                	test   %al,%al
 5b8:	75 da                	jne    594 <printf+0x103>
 5ba:	eb 68                	jmp    624 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5bc:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5c0:	75 1d                	jne    5df <printf+0x14e>
        putc(fd, *ap);
 5c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c5:	8b 00                	mov    (%eax),%eax
 5c7:	0f be c0             	movsbl %al,%eax
 5ca:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ce:	8b 45 08             	mov    0x8(%ebp),%eax
 5d1:	89 04 24             	mov    %eax,(%esp)
 5d4:	e8 d8 fd ff ff       	call   3b1 <putc>
        ap++;
 5d9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5dd:	eb 45                	jmp    624 <printf+0x193>
      } else if(c == '%'){
 5df:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5e3:	75 17                	jne    5fc <printf+0x16b>
        putc(fd, c);
 5e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e8:	0f be c0             	movsbl %al,%eax
 5eb:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ef:	8b 45 08             	mov    0x8(%ebp),%eax
 5f2:	89 04 24             	mov    %eax,(%esp)
 5f5:	e8 b7 fd ff ff       	call   3b1 <putc>
 5fa:	eb 28                	jmp    624 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5fc:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 603:	00 
 604:	8b 45 08             	mov    0x8(%ebp),%eax
 607:	89 04 24             	mov    %eax,(%esp)
 60a:	e8 a2 fd ff ff       	call   3b1 <putc>
        putc(fd, c);
 60f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 612:	0f be c0             	movsbl %al,%eax
 615:	89 44 24 04          	mov    %eax,0x4(%esp)
 619:	8b 45 08             	mov    0x8(%ebp),%eax
 61c:	89 04 24             	mov    %eax,(%esp)
 61f:	e8 8d fd ff ff       	call   3b1 <putc>
      }
      state = 0;
 624:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 62b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 62f:	8b 55 0c             	mov    0xc(%ebp),%edx
 632:	8b 45 f0             	mov    -0x10(%ebp),%eax
 635:	01 d0                	add    %edx,%eax
 637:	0f b6 00             	movzbl (%eax),%eax
 63a:	84 c0                	test   %al,%al
 63c:	0f 85 71 fe ff ff    	jne    4b3 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 642:	c9                   	leave  
 643:	c3                   	ret    

00000644 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 644:	55                   	push   %ebp
 645:	89 e5                	mov    %esp,%ebp
 647:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 64a:	8b 45 08             	mov    0x8(%ebp),%eax
 64d:	83 e8 08             	sub    $0x8,%eax
 650:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 653:	a1 ec 0a 00 00       	mov    0xaec,%eax
 658:	89 45 fc             	mov    %eax,-0x4(%ebp)
 65b:	eb 24                	jmp    681 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 65d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 660:	8b 00                	mov    (%eax),%eax
 662:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 665:	77 12                	ja     679 <free+0x35>
 667:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 66d:	77 24                	ja     693 <free+0x4f>
 66f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 672:	8b 00                	mov    (%eax),%eax
 674:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 677:	77 1a                	ja     693 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 679:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67c:	8b 00                	mov    (%eax),%eax
 67e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 681:	8b 45 f8             	mov    -0x8(%ebp),%eax
 684:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 687:	76 d4                	jbe    65d <free+0x19>
 689:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68c:	8b 00                	mov    (%eax),%eax
 68e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 691:	76 ca                	jbe    65d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 693:	8b 45 f8             	mov    -0x8(%ebp),%eax
 696:	8b 40 04             	mov    0x4(%eax),%eax
 699:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a3:	01 c2                	add    %eax,%edx
 6a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a8:	8b 00                	mov    (%eax),%eax
 6aa:	39 c2                	cmp    %eax,%edx
 6ac:	75 24                	jne    6d2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b1:	8b 50 04             	mov    0x4(%eax),%edx
 6b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b7:	8b 00                	mov    (%eax),%eax
 6b9:	8b 40 04             	mov    0x4(%eax),%eax
 6bc:	01 c2                	add    %eax,%edx
 6be:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c7:	8b 00                	mov    (%eax),%eax
 6c9:	8b 10                	mov    (%eax),%edx
 6cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ce:	89 10                	mov    %edx,(%eax)
 6d0:	eb 0a                	jmp    6dc <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d5:	8b 10                	mov    (%eax),%edx
 6d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6da:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6df:	8b 40 04             	mov    0x4(%eax),%eax
 6e2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ec:	01 d0                	add    %edx,%eax
 6ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f1:	75 20                	jne    713 <free+0xcf>
    p->s.size += bp->s.size;
 6f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f6:	8b 50 04             	mov    0x4(%eax),%edx
 6f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fc:	8b 40 04             	mov    0x4(%eax),%eax
 6ff:	01 c2                	add    %eax,%edx
 701:	8b 45 fc             	mov    -0x4(%ebp),%eax
 704:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 707:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70a:	8b 10                	mov    (%eax),%edx
 70c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70f:	89 10                	mov    %edx,(%eax)
 711:	eb 08                	jmp    71b <free+0xd7>
  } else
    p->s.ptr = bp;
 713:	8b 45 fc             	mov    -0x4(%ebp),%eax
 716:	8b 55 f8             	mov    -0x8(%ebp),%edx
 719:	89 10                	mov    %edx,(%eax)
  freep = p;
 71b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71e:	a3 ec 0a 00 00       	mov    %eax,0xaec
}
 723:	c9                   	leave  
 724:	c3                   	ret    

00000725 <morecore>:

static Header*
morecore(uint nu)
{
 725:	55                   	push   %ebp
 726:	89 e5                	mov    %esp,%ebp
 728:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 72b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 732:	77 07                	ja     73b <morecore+0x16>
    nu = 4096;
 734:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 73b:	8b 45 08             	mov    0x8(%ebp),%eax
 73e:	c1 e0 03             	shl    $0x3,%eax
 741:	89 04 24             	mov    %eax,(%esp)
 744:	e8 20 fc ff ff       	call   369 <sbrk>
 749:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 74c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 750:	75 07                	jne    759 <morecore+0x34>
    return 0;
 752:	b8 00 00 00 00       	mov    $0x0,%eax
 757:	eb 22                	jmp    77b <morecore+0x56>
  hp = (Header*)p;
 759:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 75f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 762:	8b 55 08             	mov    0x8(%ebp),%edx
 765:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 768:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76b:	83 c0 08             	add    $0x8,%eax
 76e:	89 04 24             	mov    %eax,(%esp)
 771:	e8 ce fe ff ff       	call   644 <free>
  return freep;
 776:	a1 ec 0a 00 00       	mov    0xaec,%eax
}
 77b:	c9                   	leave  
 77c:	c3                   	ret    

0000077d <malloc>:

void*
malloc(uint nbytes)
{
 77d:	55                   	push   %ebp
 77e:	89 e5                	mov    %esp,%ebp
 780:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 783:	8b 45 08             	mov    0x8(%ebp),%eax
 786:	83 c0 07             	add    $0x7,%eax
 789:	c1 e8 03             	shr    $0x3,%eax
 78c:	83 c0 01             	add    $0x1,%eax
 78f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 792:	a1 ec 0a 00 00       	mov    0xaec,%eax
 797:	89 45 f0             	mov    %eax,-0x10(%ebp)
 79a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 79e:	75 23                	jne    7c3 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7a0:	c7 45 f0 e4 0a 00 00 	movl   $0xae4,-0x10(%ebp)
 7a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7aa:	a3 ec 0a 00 00       	mov    %eax,0xaec
 7af:	a1 ec 0a 00 00       	mov    0xaec,%eax
 7b4:	a3 e4 0a 00 00       	mov    %eax,0xae4
    base.s.size = 0;
 7b9:	c7 05 e8 0a 00 00 00 	movl   $0x0,0xae8
 7c0:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c6:	8b 00                	mov    (%eax),%eax
 7c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ce:	8b 40 04             	mov    0x4(%eax),%eax
 7d1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7d4:	72 4d                	jb     823 <malloc+0xa6>
      if(p->s.size == nunits)
 7d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d9:	8b 40 04             	mov    0x4(%eax),%eax
 7dc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7df:	75 0c                	jne    7ed <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e4:	8b 10                	mov    (%eax),%edx
 7e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e9:	89 10                	mov    %edx,(%eax)
 7eb:	eb 26                	jmp    813 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f0:	8b 40 04             	mov    0x4(%eax),%eax
 7f3:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7f6:	89 c2                	mov    %eax,%edx
 7f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fb:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 801:	8b 40 04             	mov    0x4(%eax),%eax
 804:	c1 e0 03             	shl    $0x3,%eax
 807:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 80a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80d:	8b 55 ec             	mov    -0x14(%ebp),%edx
 810:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 813:	8b 45 f0             	mov    -0x10(%ebp),%eax
 816:	a3 ec 0a 00 00       	mov    %eax,0xaec
      return (void*)(p + 1);
 81b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81e:	83 c0 08             	add    $0x8,%eax
 821:	eb 38                	jmp    85b <malloc+0xde>
    }
    if(p == freep)
 823:	a1 ec 0a 00 00       	mov    0xaec,%eax
 828:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 82b:	75 1b                	jne    848 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 82d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 830:	89 04 24             	mov    %eax,(%esp)
 833:	e8 ed fe ff ff       	call   725 <morecore>
 838:	89 45 f4             	mov    %eax,-0xc(%ebp)
 83b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 83f:	75 07                	jne    848 <malloc+0xcb>
        return 0;
 841:	b8 00 00 00 00       	mov    $0x0,%eax
 846:	eb 13                	jmp    85b <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 848:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 84e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 851:	8b 00                	mov    (%eax),%eax
 853:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 856:	e9 70 ff ff ff       	jmp    7cb <malloc+0x4e>
}
 85b:	c9                   	leave  
 85c:	c3                   	ret    
