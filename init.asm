
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10:	00 
  11:	c7 04 24 f6 08 00 00 	movl   $0x8f6,(%esp)
  18:	e8 9a 03 00 00       	call   3b7 <open>
  1d:	85 c0                	test   %eax,%eax
  1f:	79 30                	jns    51 <main+0x51>
    mknod("console", 1, 1);
  21:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  28:	00 
  29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  30:	00 
  31:	c7 04 24 f6 08 00 00 	movl   $0x8f6,(%esp)
  38:	e8 82 03 00 00       	call   3bf <mknod>
    open("console", O_RDWR);
  3d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  44:	00 
  45:	c7 04 24 f6 08 00 00 	movl   $0x8f6,(%esp)
  4c:	e8 66 03 00 00       	call   3b7 <open>
  }
  dup(0);  // stdout
  51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  58:	e8 92 03 00 00       	call   3ef <dup>
  dup(0);  // stderr
  5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  64:	e8 86 03 00 00       	call   3ef <dup>

  for(;;){
    printf(1, "init: starting sh\n");
  69:	c7 44 24 04 fe 08 00 	movl   $0x8fe,0x4(%esp)
  70:	00 
  71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  78:	e8 aa 04 00 00       	call   527 <printf>
    pid = fork();
  7d:	e8 ed 02 00 00       	call   36f <fork>
  82:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(pid < 0){
  86:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  8b:	79 19                	jns    a6 <main+0xa6>
      printf(1, "init: fork failed\n");
  8d:	c7 44 24 04 11 09 00 	movl   $0x911,0x4(%esp)
  94:	00 
  95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9c:	e8 86 04 00 00       	call   527 <printf>
      exit();
  a1:	e8 d1 02 00 00       	call   377 <exit>
    }
    if(pid == 0){
  a6:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  ab:	75 2d                	jne    da <main+0xda>
      exec("sh", argv);
  ad:	c7 44 24 04 90 0b 00 	movl   $0xb90,0x4(%esp)
  b4:	00 
  b5:	c7 04 24 f3 08 00 00 	movl   $0x8f3,(%esp)
  bc:	e8 ee 02 00 00       	call   3af <exec>
      printf(1, "init: exec sh failed\n");
  c1:	c7 44 24 04 24 09 00 	movl   $0x924,0x4(%esp)
  c8:	00 
  c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d0:	e8 52 04 00 00       	call   527 <printf>
      exit();
  d5:	e8 9d 02 00 00       	call   377 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  da:	eb 14                	jmp    f0 <main+0xf0>
      printf(1, "zombie!\n");
  dc:	c7 44 24 04 3a 09 00 	movl   $0x93a,0x4(%esp)
  e3:	00 
  e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  eb:	e8 37 04 00 00       	call   527 <printf>
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  f0:	e8 8a 02 00 00       	call   37f <wait>
  f5:	89 44 24 18          	mov    %eax,0x18(%esp)
  f9:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  fe:	78 0a                	js     10a <main+0x10a>
 100:	8b 44 24 18          	mov    0x18(%esp),%eax
 104:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 108:	75 d2                	jne    dc <main+0xdc>
      printf(1, "zombie!\n");
  }
 10a:	e9 5a ff ff ff       	jmp    69 <main+0x69>

0000010f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 10f:	55                   	push   %ebp
 110:	89 e5                	mov    %esp,%ebp
 112:	57                   	push   %edi
 113:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 114:	8b 4d 08             	mov    0x8(%ebp),%ecx
 117:	8b 55 10             	mov    0x10(%ebp),%edx
 11a:	8b 45 0c             	mov    0xc(%ebp),%eax
 11d:	89 cb                	mov    %ecx,%ebx
 11f:	89 df                	mov    %ebx,%edi
 121:	89 d1                	mov    %edx,%ecx
 123:	fc                   	cld    
 124:	f3 aa                	rep stos %al,%es:(%edi)
 126:	89 ca                	mov    %ecx,%edx
 128:	89 fb                	mov    %edi,%ebx
 12a:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 130:	5b                   	pop    %ebx
 131:	5f                   	pop    %edi
 132:	5d                   	pop    %ebp
 133:	c3                   	ret    

00000134 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13a:	8b 45 08             	mov    0x8(%ebp),%eax
 13d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 140:	90                   	nop
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	8d 50 01             	lea    0x1(%eax),%edx
 147:	89 55 08             	mov    %edx,0x8(%ebp)
 14a:	8b 55 0c             	mov    0xc(%ebp),%edx
 14d:	8d 4a 01             	lea    0x1(%edx),%ecx
 150:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 153:	0f b6 12             	movzbl (%edx),%edx
 156:	88 10                	mov    %dl,(%eax)
 158:	0f b6 00             	movzbl (%eax),%eax
 15b:	84 c0                	test   %al,%al
 15d:	75 e2                	jne    141 <strcpy+0xd>
    ;
  return os;
 15f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 162:	c9                   	leave  
 163:	c3                   	ret    

00000164 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 167:	eb 08                	jmp    171 <strcmp+0xd>
    p++, q++;
 169:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 171:	8b 45 08             	mov    0x8(%ebp),%eax
 174:	0f b6 00             	movzbl (%eax),%eax
 177:	84 c0                	test   %al,%al
 179:	74 10                	je     18b <strcmp+0x27>
 17b:	8b 45 08             	mov    0x8(%ebp),%eax
 17e:	0f b6 10             	movzbl (%eax),%edx
 181:	8b 45 0c             	mov    0xc(%ebp),%eax
 184:	0f b6 00             	movzbl (%eax),%eax
 187:	38 c2                	cmp    %al,%dl
 189:	74 de                	je     169 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 18b:	8b 45 08             	mov    0x8(%ebp),%eax
 18e:	0f b6 00             	movzbl (%eax),%eax
 191:	0f b6 d0             	movzbl %al,%edx
 194:	8b 45 0c             	mov    0xc(%ebp),%eax
 197:	0f b6 00             	movzbl (%eax),%eax
 19a:	0f b6 c0             	movzbl %al,%eax
 19d:	29 c2                	sub    %eax,%edx
 19f:	89 d0                	mov    %edx,%eax
}
 1a1:	5d                   	pop    %ebp
 1a2:	c3                   	ret    

000001a3 <strlen>:

uint
strlen(char *s)
{
 1a3:	55                   	push   %ebp
 1a4:	89 e5                	mov    %esp,%ebp
 1a6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b0:	eb 04                	jmp    1b6 <strlen+0x13>
 1b2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1b9:	8b 45 08             	mov    0x8(%ebp),%eax
 1bc:	01 d0                	add    %edx,%eax
 1be:	0f b6 00             	movzbl (%eax),%eax
 1c1:	84 c0                	test   %al,%al
 1c3:	75 ed                	jne    1b2 <strlen+0xf>
    ;
  return n;
 1c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c8:	c9                   	leave  
 1c9:	c3                   	ret    

000001ca <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ca:	55                   	push   %ebp
 1cb:	89 e5                	mov    %esp,%ebp
 1cd:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1d0:	8b 45 10             	mov    0x10(%ebp),%eax
 1d3:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1da:	89 44 24 04          	mov    %eax,0x4(%esp)
 1de:	8b 45 08             	mov    0x8(%ebp),%eax
 1e1:	89 04 24             	mov    %eax,(%esp)
 1e4:	e8 26 ff ff ff       	call   10f <stosb>
  return dst;
 1e9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ec:	c9                   	leave  
 1ed:	c3                   	ret    

000001ee <strchr>:

char*
strchr(const char *s, char c)
{
 1ee:	55                   	push   %ebp
 1ef:	89 e5                	mov    %esp,%ebp
 1f1:	83 ec 04             	sub    $0x4,%esp
 1f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f7:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1fa:	eb 14                	jmp    210 <strchr+0x22>
    if(*s == c)
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	0f b6 00             	movzbl (%eax),%eax
 202:	3a 45 fc             	cmp    -0x4(%ebp),%al
 205:	75 05                	jne    20c <strchr+0x1e>
      return (char*)s;
 207:	8b 45 08             	mov    0x8(%ebp),%eax
 20a:	eb 13                	jmp    21f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 20c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	0f b6 00             	movzbl (%eax),%eax
 216:	84 c0                	test   %al,%al
 218:	75 e2                	jne    1fc <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 21a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 21f:	c9                   	leave  
 220:	c3                   	ret    

00000221 <gets>:

char*
gets(char *buf, int max)
{
 221:	55                   	push   %ebp
 222:	89 e5                	mov    %esp,%ebp
 224:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 227:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 22e:	eb 4c                	jmp    27c <gets+0x5b>
    cc = read(0, &c, 1);
 230:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 237:	00 
 238:	8d 45 ef             	lea    -0x11(%ebp),%eax
 23b:	89 44 24 04          	mov    %eax,0x4(%esp)
 23f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 246:	e8 44 01 00 00       	call   38f <read>
 24b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 24e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 252:	7f 02                	jg     256 <gets+0x35>
      break;
 254:	eb 31                	jmp    287 <gets+0x66>
    buf[i++] = c;
 256:	8b 45 f4             	mov    -0xc(%ebp),%eax
 259:	8d 50 01             	lea    0x1(%eax),%edx
 25c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 25f:	89 c2                	mov    %eax,%edx
 261:	8b 45 08             	mov    0x8(%ebp),%eax
 264:	01 c2                	add    %eax,%edx
 266:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 26c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 270:	3c 0a                	cmp    $0xa,%al
 272:	74 13                	je     287 <gets+0x66>
 274:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 278:	3c 0d                	cmp    $0xd,%al
 27a:	74 0b                	je     287 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27f:	83 c0 01             	add    $0x1,%eax
 282:	3b 45 0c             	cmp    0xc(%ebp),%eax
 285:	7c a9                	jl     230 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 287:	8b 55 f4             	mov    -0xc(%ebp),%edx
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	01 d0                	add    %edx,%eax
 28f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 292:	8b 45 08             	mov    0x8(%ebp),%eax
}
 295:	c9                   	leave  
 296:	c3                   	ret    

00000297 <stat>:

int
stat(char *n, struct stat *st)
{
 297:	55                   	push   %ebp
 298:	89 e5                	mov    %esp,%ebp
 29a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2a4:	00 
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	89 04 24             	mov    %eax,(%esp)
 2ab:	e8 07 01 00 00       	call   3b7 <open>
 2b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b7:	79 07                	jns    2c0 <stat+0x29>
    return -1;
 2b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2be:	eb 23                	jmp    2e3 <stat+0x4c>
  r = fstat(fd, st);
 2c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ca:	89 04 24             	mov    %eax,(%esp)
 2cd:	e8 fd 00 00 00       	call   3cf <fstat>
 2d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d8:	89 04 24             	mov    %eax,(%esp)
 2db:	e8 bf 00 00 00       	call   39f <close>
  return r;
 2e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e3:	c9                   	leave  
 2e4:	c3                   	ret    

000002e5 <atoi>:

int
atoi(const char *s)
{
 2e5:	55                   	push   %ebp
 2e6:	89 e5                	mov    %esp,%ebp
 2e8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2eb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f2:	eb 25                	jmp    319 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2f4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f7:	89 d0                	mov    %edx,%eax
 2f9:	c1 e0 02             	shl    $0x2,%eax
 2fc:	01 d0                	add    %edx,%eax
 2fe:	01 c0                	add    %eax,%eax
 300:	89 c1                	mov    %eax,%ecx
 302:	8b 45 08             	mov    0x8(%ebp),%eax
 305:	8d 50 01             	lea    0x1(%eax),%edx
 308:	89 55 08             	mov    %edx,0x8(%ebp)
 30b:	0f b6 00             	movzbl (%eax),%eax
 30e:	0f be c0             	movsbl %al,%eax
 311:	01 c8                	add    %ecx,%eax
 313:	83 e8 30             	sub    $0x30,%eax
 316:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 319:	8b 45 08             	mov    0x8(%ebp),%eax
 31c:	0f b6 00             	movzbl (%eax),%eax
 31f:	3c 2f                	cmp    $0x2f,%al
 321:	7e 0a                	jle    32d <atoi+0x48>
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	0f b6 00             	movzbl (%eax),%eax
 329:	3c 39                	cmp    $0x39,%al
 32b:	7e c7                	jle    2f4 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 32d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 330:	c9                   	leave  
 331:	c3                   	ret    

00000332 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 332:	55                   	push   %ebp
 333:	89 e5                	mov    %esp,%ebp
 335:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 33e:	8b 45 0c             	mov    0xc(%ebp),%eax
 341:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 344:	eb 17                	jmp    35d <memmove+0x2b>
    *dst++ = *src++;
 346:	8b 45 fc             	mov    -0x4(%ebp),%eax
 349:	8d 50 01             	lea    0x1(%eax),%edx
 34c:	89 55 fc             	mov    %edx,-0x4(%ebp)
 34f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 352:	8d 4a 01             	lea    0x1(%edx),%ecx
 355:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 358:	0f b6 12             	movzbl (%edx),%edx
 35b:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 35d:	8b 45 10             	mov    0x10(%ebp),%eax
 360:	8d 50 ff             	lea    -0x1(%eax),%edx
 363:	89 55 10             	mov    %edx,0x10(%ebp)
 366:	85 c0                	test   %eax,%eax
 368:	7f dc                	jg     346 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 36a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36d:	c9                   	leave  
 36e:	c3                   	ret    

0000036f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 36f:	b8 01 00 00 00       	mov    $0x1,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <exit>:
SYSCALL(exit)
 377:	b8 02 00 00 00       	mov    $0x2,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <wait>:
SYSCALL(wait)
 37f:	b8 03 00 00 00       	mov    $0x3,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	ret    

00000387 <pipe>:
SYSCALL(pipe)
 387:	b8 04 00 00 00       	mov    $0x4,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <read>:
SYSCALL(read)
 38f:	b8 05 00 00 00       	mov    $0x5,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	ret    

00000397 <write>:
SYSCALL(write)
 397:	b8 10 00 00 00       	mov    $0x10,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	ret    

0000039f <close>:
SYSCALL(close)
 39f:	b8 15 00 00 00       	mov    $0x15,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	ret    

000003a7 <kill>:
SYSCALL(kill)
 3a7:	b8 06 00 00 00       	mov    $0x6,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	ret    

000003af <exec>:
SYSCALL(exec)
 3af:	b8 07 00 00 00       	mov    $0x7,%eax
 3b4:	cd 40                	int    $0x40
 3b6:	c3                   	ret    

000003b7 <open>:
SYSCALL(open)
 3b7:	b8 0f 00 00 00       	mov    $0xf,%eax
 3bc:	cd 40                	int    $0x40
 3be:	c3                   	ret    

000003bf <mknod>:
SYSCALL(mknod)
 3bf:	b8 11 00 00 00       	mov    $0x11,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	ret    

000003c7 <unlink>:
SYSCALL(unlink)
 3c7:	b8 12 00 00 00       	mov    $0x12,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	ret    

000003cf <fstat>:
SYSCALL(fstat)
 3cf:	b8 08 00 00 00       	mov    $0x8,%eax
 3d4:	cd 40                	int    $0x40
 3d6:	c3                   	ret    

000003d7 <link>:
SYSCALL(link)
 3d7:	b8 13 00 00 00       	mov    $0x13,%eax
 3dc:	cd 40                	int    $0x40
 3de:	c3                   	ret    

000003df <mkdir>:
SYSCALL(mkdir)
 3df:	b8 14 00 00 00       	mov    $0x14,%eax
 3e4:	cd 40                	int    $0x40
 3e6:	c3                   	ret    

000003e7 <chdir>:
SYSCALL(chdir)
 3e7:	b8 09 00 00 00       	mov    $0x9,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	ret    

000003ef <dup>:
SYSCALL(dup)
 3ef:	b8 0a 00 00 00       	mov    $0xa,%eax
 3f4:	cd 40                	int    $0x40
 3f6:	c3                   	ret    

000003f7 <getpid>:
SYSCALL(getpid)
 3f7:	b8 0b 00 00 00       	mov    $0xb,%eax
 3fc:	cd 40                	int    $0x40
 3fe:	c3                   	ret    

000003ff <sbrk>:
SYSCALL(sbrk)
 3ff:	b8 0c 00 00 00       	mov    $0xc,%eax
 404:	cd 40                	int    $0x40
 406:	c3                   	ret    

00000407 <sleep>:
SYSCALL(sleep)
 407:	b8 0d 00 00 00       	mov    $0xd,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	ret    

0000040f <uptime>:
SYSCALL(uptime)
 40f:	b8 0e 00 00 00       	mov    $0xe,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	ret    

00000417 <getcount>:
// To define asm routine for the new call.
SYSCALL(getcount)
 417:	b8 16 00 00 00       	mov    $0x16,%eax
 41c:	cd 40                	int    $0x40
 41e:	c3                   	ret    

0000041f <thread_create>:
// To define asm routines for the new thread management calls.
SYSCALL(thread_create)
 41f:	b8 17 00 00 00       	mov    $0x17,%eax
 424:	cd 40                	int    $0x40
 426:	c3                   	ret    

00000427 <thread_join>:
SYSCALL(thread_join)
 427:	b8 18 00 00 00       	mov    $0x18,%eax
 42c:	cd 40                	int    $0x40
 42e:	c3                   	ret    

0000042f <mtx_create>:
SYSCALL(mtx_create)
 42f:	b8 19 00 00 00       	mov    $0x19,%eax
 434:	cd 40                	int    $0x40
 436:	c3                   	ret    

00000437 <mtx_lock>:
SYSCALL(mtx_lock)
 437:	b8 1a 00 00 00       	mov    $0x1a,%eax
 43c:	cd 40                	int    $0x40
 43e:	c3                   	ret    

0000043f <mtx_unlock>:
SYSCALL(mtx_unlock)
 43f:	b8 1b 00 00 00       	mov    $0x1b,%eax
 444:	cd 40                	int    $0x40
 446:	c3                   	ret    

00000447 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 447:	55                   	push   %ebp
 448:	89 e5                	mov    %esp,%ebp
 44a:	83 ec 18             	sub    $0x18,%esp
 44d:	8b 45 0c             	mov    0xc(%ebp),%eax
 450:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 453:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 45a:	00 
 45b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 45e:	89 44 24 04          	mov    %eax,0x4(%esp)
 462:	8b 45 08             	mov    0x8(%ebp),%eax
 465:	89 04 24             	mov    %eax,(%esp)
 468:	e8 2a ff ff ff       	call   397 <write>
}
 46d:	c9                   	leave  
 46e:	c3                   	ret    

0000046f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 46f:	55                   	push   %ebp
 470:	89 e5                	mov    %esp,%ebp
 472:	56                   	push   %esi
 473:	53                   	push   %ebx
 474:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 477:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 47e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 482:	74 17                	je     49b <printint+0x2c>
 484:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 488:	79 11                	jns    49b <printint+0x2c>
    neg = 1;
 48a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 491:	8b 45 0c             	mov    0xc(%ebp),%eax
 494:	f7 d8                	neg    %eax
 496:	89 45 ec             	mov    %eax,-0x14(%ebp)
 499:	eb 06                	jmp    4a1 <printint+0x32>
  } else {
    x = xx;
 49b:	8b 45 0c             	mov    0xc(%ebp),%eax
 49e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4a8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4ab:	8d 41 01             	lea    0x1(%ecx),%eax
 4ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b7:	ba 00 00 00 00       	mov    $0x0,%edx
 4bc:	f7 f3                	div    %ebx
 4be:	89 d0                	mov    %edx,%eax
 4c0:	0f b6 80 98 0b 00 00 	movzbl 0xb98(%eax),%eax
 4c7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4cb:	8b 75 10             	mov    0x10(%ebp),%esi
 4ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4d1:	ba 00 00 00 00       	mov    $0x0,%edx
 4d6:	f7 f6                	div    %esi
 4d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4db:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4df:	75 c7                	jne    4a8 <printint+0x39>
  if(neg)
 4e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4e5:	74 10                	je     4f7 <printint+0x88>
    buf[i++] = '-';
 4e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ea:	8d 50 01             	lea    0x1(%eax),%edx
 4ed:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4f0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4f5:	eb 1f                	jmp    516 <printint+0xa7>
 4f7:	eb 1d                	jmp    516 <printint+0xa7>
    putc(fd, buf[i]);
 4f9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ff:	01 d0                	add    %edx,%eax
 501:	0f b6 00             	movzbl (%eax),%eax
 504:	0f be c0             	movsbl %al,%eax
 507:	89 44 24 04          	mov    %eax,0x4(%esp)
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
 50e:	89 04 24             	mov    %eax,(%esp)
 511:	e8 31 ff ff ff       	call   447 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 516:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 51a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 51e:	79 d9                	jns    4f9 <printint+0x8a>
    putc(fd, buf[i]);
}
 520:	83 c4 30             	add    $0x30,%esp
 523:	5b                   	pop    %ebx
 524:	5e                   	pop    %esi
 525:	5d                   	pop    %ebp
 526:	c3                   	ret    

00000527 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 527:	55                   	push   %ebp
 528:	89 e5                	mov    %esp,%ebp
 52a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 52d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 534:	8d 45 0c             	lea    0xc(%ebp),%eax
 537:	83 c0 04             	add    $0x4,%eax
 53a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 53d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 544:	e9 7c 01 00 00       	jmp    6c5 <printf+0x19e>
    c = fmt[i] & 0xff;
 549:	8b 55 0c             	mov    0xc(%ebp),%edx
 54c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 54f:	01 d0                	add    %edx,%eax
 551:	0f b6 00             	movzbl (%eax),%eax
 554:	0f be c0             	movsbl %al,%eax
 557:	25 ff 00 00 00       	and    $0xff,%eax
 55c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 55f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 563:	75 2c                	jne    591 <printf+0x6a>
      if(c == '%'){
 565:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 569:	75 0c                	jne    577 <printf+0x50>
        state = '%';
 56b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 572:	e9 4a 01 00 00       	jmp    6c1 <printf+0x19a>
      } else {
        putc(fd, c);
 577:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57a:	0f be c0             	movsbl %al,%eax
 57d:	89 44 24 04          	mov    %eax,0x4(%esp)
 581:	8b 45 08             	mov    0x8(%ebp),%eax
 584:	89 04 24             	mov    %eax,(%esp)
 587:	e8 bb fe ff ff       	call   447 <putc>
 58c:	e9 30 01 00 00       	jmp    6c1 <printf+0x19a>
      }
    } else if(state == '%'){
 591:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 595:	0f 85 26 01 00 00    	jne    6c1 <printf+0x19a>
      if(c == 'd'){
 59b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 59f:	75 2d                	jne    5ce <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a4:	8b 00                	mov    (%eax),%eax
 5a6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5ad:	00 
 5ae:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5b5:	00 
 5b6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ba:	8b 45 08             	mov    0x8(%ebp),%eax
 5bd:	89 04 24             	mov    %eax,(%esp)
 5c0:	e8 aa fe ff ff       	call   46f <printint>
        ap++;
 5c5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5c9:	e9 ec 00 00 00       	jmp    6ba <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5ce:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5d2:	74 06                	je     5da <printf+0xb3>
 5d4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5d8:	75 2d                	jne    607 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5da:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5dd:	8b 00                	mov    (%eax),%eax
 5df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5e6:	00 
 5e7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5ee:	00 
 5ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f3:	8b 45 08             	mov    0x8(%ebp),%eax
 5f6:	89 04 24             	mov    %eax,(%esp)
 5f9:	e8 71 fe ff ff       	call   46f <printint>
        ap++;
 5fe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 602:	e9 b3 00 00 00       	jmp    6ba <printf+0x193>
      } else if(c == 's'){
 607:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 60b:	75 45                	jne    652 <printf+0x12b>
        s = (char*)*ap;
 60d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 610:	8b 00                	mov    (%eax),%eax
 612:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 615:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 619:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 61d:	75 09                	jne    628 <printf+0x101>
          s = "(null)";
 61f:	c7 45 f4 43 09 00 00 	movl   $0x943,-0xc(%ebp)
        while(*s != 0){
 626:	eb 1e                	jmp    646 <printf+0x11f>
 628:	eb 1c                	jmp    646 <printf+0x11f>
          putc(fd, *s);
 62a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62d:	0f b6 00             	movzbl (%eax),%eax
 630:	0f be c0             	movsbl %al,%eax
 633:	89 44 24 04          	mov    %eax,0x4(%esp)
 637:	8b 45 08             	mov    0x8(%ebp),%eax
 63a:	89 04 24             	mov    %eax,(%esp)
 63d:	e8 05 fe ff ff       	call   447 <putc>
          s++;
 642:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 646:	8b 45 f4             	mov    -0xc(%ebp),%eax
 649:	0f b6 00             	movzbl (%eax),%eax
 64c:	84 c0                	test   %al,%al
 64e:	75 da                	jne    62a <printf+0x103>
 650:	eb 68                	jmp    6ba <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 652:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 656:	75 1d                	jne    675 <printf+0x14e>
        putc(fd, *ap);
 658:	8b 45 e8             	mov    -0x18(%ebp),%eax
 65b:	8b 00                	mov    (%eax),%eax
 65d:	0f be c0             	movsbl %al,%eax
 660:	89 44 24 04          	mov    %eax,0x4(%esp)
 664:	8b 45 08             	mov    0x8(%ebp),%eax
 667:	89 04 24             	mov    %eax,(%esp)
 66a:	e8 d8 fd ff ff       	call   447 <putc>
        ap++;
 66f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 673:	eb 45                	jmp    6ba <printf+0x193>
      } else if(c == '%'){
 675:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 679:	75 17                	jne    692 <printf+0x16b>
        putc(fd, c);
 67b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 67e:	0f be c0             	movsbl %al,%eax
 681:	89 44 24 04          	mov    %eax,0x4(%esp)
 685:	8b 45 08             	mov    0x8(%ebp),%eax
 688:	89 04 24             	mov    %eax,(%esp)
 68b:	e8 b7 fd ff ff       	call   447 <putc>
 690:	eb 28                	jmp    6ba <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 692:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 699:	00 
 69a:	8b 45 08             	mov    0x8(%ebp),%eax
 69d:	89 04 24             	mov    %eax,(%esp)
 6a0:	e8 a2 fd ff ff       	call   447 <putc>
        putc(fd, c);
 6a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6a8:	0f be c0             	movsbl %al,%eax
 6ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 6af:	8b 45 08             	mov    0x8(%ebp),%eax
 6b2:	89 04 24             	mov    %eax,(%esp)
 6b5:	e8 8d fd ff ff       	call   447 <putc>
      }
      state = 0;
 6ba:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6c1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6c5:	8b 55 0c             	mov    0xc(%ebp),%edx
 6c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6cb:	01 d0                	add    %edx,%eax
 6cd:	0f b6 00             	movzbl (%eax),%eax
 6d0:	84 c0                	test   %al,%al
 6d2:	0f 85 71 fe ff ff    	jne    549 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6d8:	c9                   	leave  
 6d9:	c3                   	ret    

000006da <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6da:	55                   	push   %ebp
 6db:	89 e5                	mov    %esp,%ebp
 6dd:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e0:	8b 45 08             	mov    0x8(%ebp),%eax
 6e3:	83 e8 08             	sub    $0x8,%eax
 6e6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e9:	a1 b4 0b 00 00       	mov    0xbb4,%eax
 6ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f1:	eb 24                	jmp    717 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f6:	8b 00                	mov    (%eax),%eax
 6f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6fb:	77 12                	ja     70f <free+0x35>
 6fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 700:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 703:	77 24                	ja     729 <free+0x4f>
 705:	8b 45 fc             	mov    -0x4(%ebp),%eax
 708:	8b 00                	mov    (%eax),%eax
 70a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 70d:	77 1a                	ja     729 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 712:	8b 00                	mov    (%eax),%eax
 714:	89 45 fc             	mov    %eax,-0x4(%ebp)
 717:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 71d:	76 d4                	jbe    6f3 <free+0x19>
 71f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 722:	8b 00                	mov    (%eax),%eax
 724:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 727:	76 ca                	jbe    6f3 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 729:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72c:	8b 40 04             	mov    0x4(%eax),%eax
 72f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 736:	8b 45 f8             	mov    -0x8(%ebp),%eax
 739:	01 c2                	add    %eax,%edx
 73b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73e:	8b 00                	mov    (%eax),%eax
 740:	39 c2                	cmp    %eax,%edx
 742:	75 24                	jne    768 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 744:	8b 45 f8             	mov    -0x8(%ebp),%eax
 747:	8b 50 04             	mov    0x4(%eax),%edx
 74a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74d:	8b 00                	mov    (%eax),%eax
 74f:	8b 40 04             	mov    0x4(%eax),%eax
 752:	01 c2                	add    %eax,%edx
 754:	8b 45 f8             	mov    -0x8(%ebp),%eax
 757:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 75a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75d:	8b 00                	mov    (%eax),%eax
 75f:	8b 10                	mov    (%eax),%edx
 761:	8b 45 f8             	mov    -0x8(%ebp),%eax
 764:	89 10                	mov    %edx,(%eax)
 766:	eb 0a                	jmp    772 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 768:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76b:	8b 10                	mov    (%eax),%edx
 76d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 770:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 772:	8b 45 fc             	mov    -0x4(%ebp),%eax
 775:	8b 40 04             	mov    0x4(%eax),%eax
 778:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 77f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 782:	01 d0                	add    %edx,%eax
 784:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 787:	75 20                	jne    7a9 <free+0xcf>
    p->s.size += bp->s.size;
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	8b 50 04             	mov    0x4(%eax),%edx
 78f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 792:	8b 40 04             	mov    0x4(%eax),%eax
 795:	01 c2                	add    %eax,%edx
 797:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 79d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a0:	8b 10                	mov    (%eax),%edx
 7a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a5:	89 10                	mov    %edx,(%eax)
 7a7:	eb 08                	jmp    7b1 <free+0xd7>
  } else
    p->s.ptr = bp;
 7a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ac:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7af:	89 10                	mov    %edx,(%eax)
  freep = p;
 7b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b4:	a3 b4 0b 00 00       	mov    %eax,0xbb4
}
 7b9:	c9                   	leave  
 7ba:	c3                   	ret    

000007bb <morecore>:

static Header*
morecore(uint nu)
{
 7bb:	55                   	push   %ebp
 7bc:	89 e5                	mov    %esp,%ebp
 7be:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7c1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7c8:	77 07                	ja     7d1 <morecore+0x16>
    nu = 4096;
 7ca:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7d1:	8b 45 08             	mov    0x8(%ebp),%eax
 7d4:	c1 e0 03             	shl    $0x3,%eax
 7d7:	89 04 24             	mov    %eax,(%esp)
 7da:	e8 20 fc ff ff       	call   3ff <sbrk>
 7df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7e2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7e6:	75 07                	jne    7ef <morecore+0x34>
    return 0;
 7e8:	b8 00 00 00 00       	mov    $0x0,%eax
 7ed:	eb 22                	jmp    811 <morecore+0x56>
  hp = (Header*)p;
 7ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f8:	8b 55 08             	mov    0x8(%ebp),%edx
 7fb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 801:	83 c0 08             	add    $0x8,%eax
 804:	89 04 24             	mov    %eax,(%esp)
 807:	e8 ce fe ff ff       	call   6da <free>
  return freep;
 80c:	a1 b4 0b 00 00       	mov    0xbb4,%eax
}
 811:	c9                   	leave  
 812:	c3                   	ret    

00000813 <malloc>:

void*
malloc(uint nbytes)
{
 813:	55                   	push   %ebp
 814:	89 e5                	mov    %esp,%ebp
 816:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 819:	8b 45 08             	mov    0x8(%ebp),%eax
 81c:	83 c0 07             	add    $0x7,%eax
 81f:	c1 e8 03             	shr    $0x3,%eax
 822:	83 c0 01             	add    $0x1,%eax
 825:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 828:	a1 b4 0b 00 00       	mov    0xbb4,%eax
 82d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 830:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 834:	75 23                	jne    859 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 836:	c7 45 f0 ac 0b 00 00 	movl   $0xbac,-0x10(%ebp)
 83d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 840:	a3 b4 0b 00 00       	mov    %eax,0xbb4
 845:	a1 b4 0b 00 00       	mov    0xbb4,%eax
 84a:	a3 ac 0b 00 00       	mov    %eax,0xbac
    base.s.size = 0;
 84f:	c7 05 b0 0b 00 00 00 	movl   $0x0,0xbb0
 856:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 859:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85c:	8b 00                	mov    (%eax),%eax
 85e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 861:	8b 45 f4             	mov    -0xc(%ebp),%eax
 864:	8b 40 04             	mov    0x4(%eax),%eax
 867:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 86a:	72 4d                	jb     8b9 <malloc+0xa6>
      if(p->s.size == nunits)
 86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86f:	8b 40 04             	mov    0x4(%eax),%eax
 872:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 875:	75 0c                	jne    883 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 877:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87a:	8b 10                	mov    (%eax),%edx
 87c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87f:	89 10                	mov    %edx,(%eax)
 881:	eb 26                	jmp    8a9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 883:	8b 45 f4             	mov    -0xc(%ebp),%eax
 886:	8b 40 04             	mov    0x4(%eax),%eax
 889:	2b 45 ec             	sub    -0x14(%ebp),%eax
 88c:	89 c2                	mov    %eax,%edx
 88e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 891:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 894:	8b 45 f4             	mov    -0xc(%ebp),%eax
 897:	8b 40 04             	mov    0x4(%eax),%eax
 89a:	c1 e0 03             	shl    $0x3,%eax
 89d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8a6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ac:	a3 b4 0b 00 00       	mov    %eax,0xbb4
      return (void*)(p + 1);
 8b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b4:	83 c0 08             	add    $0x8,%eax
 8b7:	eb 38                	jmp    8f1 <malloc+0xde>
    }
    if(p == freep)
 8b9:	a1 b4 0b 00 00       	mov    0xbb4,%eax
 8be:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8c1:	75 1b                	jne    8de <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8c6:	89 04 24             	mov    %eax,(%esp)
 8c9:	e8 ed fe ff ff       	call   7bb <morecore>
 8ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8d5:	75 07                	jne    8de <malloc+0xcb>
        return 0;
 8d7:	b8 00 00 00 00       	mov    $0x0,%eax
 8dc:	eb 13                	jmp    8f1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e7:	8b 00                	mov    (%eax),%eax
 8e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8ec:	e9 70 ff ff ff       	jmp    861 <malloc+0x4e>
}
 8f1:	c9                   	leave  
 8f2:	c3                   	ret    
