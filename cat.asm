
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
   6:	eb 1b                	jmp    23 <cat+0x23>
    write(1, buf, n);
   8:	8b 45 f4             	mov    -0xc(%ebp),%eax
   b:	89 44 24 08          	mov    %eax,0x8(%esp)
   f:	c7 44 24 04 e0 0b 00 	movl   $0xbe0,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 82 03 00 00       	call   3a5 <write>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
  23:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  2a:	00 
  2b:	c7 44 24 04 e0 0b 00 	movl   $0xbe0,0x4(%esp)
  32:	00 
  33:	8b 45 08             	mov    0x8(%ebp),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 5f 03 00 00       	call   39d <read>
  3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  45:	7f c1                	jg     8 <cat+0x8>
    write(1, buf, n);
  if(n < 0){
  47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4b:	79 19                	jns    66 <cat+0x66>
    printf(1, "cat: read error\n");
  4d:	c7 44 24 04 01 09 00 	movl   $0x901,0x4(%esp)
  54:	00 
  55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5c:	e8 d4 04 00 00       	call   535 <printf>
    exit();
  61:	e8 1f 03 00 00       	call   385 <exit>
  }
}
  66:	c9                   	leave  
  67:	c3                   	ret    

00000068 <main>:

int
main(int argc, char *argv[])
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	83 e4 f0             	and    $0xfffffff0,%esp
  6e:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
  71:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  75:	7f 11                	jg     88 <main+0x20>
    cat(0);
  77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  7e:	e8 7d ff ff ff       	call   0 <cat>
    exit();
  83:	e8 fd 02 00 00       	call   385 <exit>
  }

  for(i = 1; i < argc; i++){
  88:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  8f:	00 
  90:	eb 79                	jmp    10b <main+0xa3>
    if((fd = open(argv[i], 0)) < 0){
  92:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  a0:	01 d0                	add    %edx,%eax
  a2:	8b 00                	mov    (%eax),%eax
  a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  ab:	00 
  ac:	89 04 24             	mov    %eax,(%esp)
  af:	e8 11 03 00 00       	call   3c5 <open>
  b4:	89 44 24 18          	mov    %eax,0x18(%esp)
  b8:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  bd:	79 2f                	jns    ee <main+0x86>
      printf(1, "cat: cannot open %s\n", argv[i]);
  bf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  cd:	01 d0                	add    %edx,%eax
  cf:	8b 00                	mov    (%eax),%eax
  d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  d5:	c7 44 24 04 12 09 00 	movl   $0x912,0x4(%esp)
  dc:	00 
  dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e4:	e8 4c 04 00 00       	call   535 <printf>
      exit();
  e9:	e8 97 02 00 00       	call   385 <exit>
    }
    cat(fd);
  ee:	8b 44 24 18          	mov    0x18(%esp),%eax
  f2:	89 04 24             	mov    %eax,(%esp)
  f5:	e8 06 ff ff ff       	call   0 <cat>
    close(fd);
  fa:	8b 44 24 18          	mov    0x18(%esp),%eax
  fe:	89 04 24             	mov    %eax,(%esp)
 101:	e8 a7 02 00 00       	call   3ad <close>
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
 106:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 10b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 10f:	3b 45 08             	cmp    0x8(%ebp),%eax
 112:	0f 8c 7a ff ff ff    	jl     92 <main+0x2a>
      exit();
    }
    cat(fd);
    close(fd);
  }
  exit();
 118:	e8 68 02 00 00       	call   385 <exit>

0000011d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 11d:	55                   	push   %ebp
 11e:	89 e5                	mov    %esp,%ebp
 120:	57                   	push   %edi
 121:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 122:	8b 4d 08             	mov    0x8(%ebp),%ecx
 125:	8b 55 10             	mov    0x10(%ebp),%edx
 128:	8b 45 0c             	mov    0xc(%ebp),%eax
 12b:	89 cb                	mov    %ecx,%ebx
 12d:	89 df                	mov    %ebx,%edi
 12f:	89 d1                	mov    %edx,%ecx
 131:	fc                   	cld    
 132:	f3 aa                	rep stos %al,%es:(%edi)
 134:	89 ca                	mov    %ecx,%edx
 136:	89 fb                	mov    %edi,%ebx
 138:	89 5d 08             	mov    %ebx,0x8(%ebp)
 13b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 13e:	5b                   	pop    %ebx
 13f:	5f                   	pop    %edi
 140:	5d                   	pop    %ebp
 141:	c3                   	ret    

00000142 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 142:	55                   	push   %ebp
 143:	89 e5                	mov    %esp,%ebp
 145:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 14e:	90                   	nop
 14f:	8b 45 08             	mov    0x8(%ebp),%eax
 152:	8d 50 01             	lea    0x1(%eax),%edx
 155:	89 55 08             	mov    %edx,0x8(%ebp)
 158:	8b 55 0c             	mov    0xc(%ebp),%edx
 15b:	8d 4a 01             	lea    0x1(%edx),%ecx
 15e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 161:	0f b6 12             	movzbl (%edx),%edx
 164:	88 10                	mov    %dl,(%eax)
 166:	0f b6 00             	movzbl (%eax),%eax
 169:	84 c0                	test   %al,%al
 16b:	75 e2                	jne    14f <strcpy+0xd>
    ;
  return os;
 16d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 170:	c9                   	leave  
 171:	c3                   	ret    

00000172 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 172:	55                   	push   %ebp
 173:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 175:	eb 08                	jmp    17f <strcmp+0xd>
    p++, q++;
 177:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
 182:	0f b6 00             	movzbl (%eax),%eax
 185:	84 c0                	test   %al,%al
 187:	74 10                	je     199 <strcmp+0x27>
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	0f b6 10             	movzbl (%eax),%edx
 18f:	8b 45 0c             	mov    0xc(%ebp),%eax
 192:	0f b6 00             	movzbl (%eax),%eax
 195:	38 c2                	cmp    %al,%dl
 197:	74 de                	je     177 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 199:	8b 45 08             	mov    0x8(%ebp),%eax
 19c:	0f b6 00             	movzbl (%eax),%eax
 19f:	0f b6 d0             	movzbl %al,%edx
 1a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a5:	0f b6 00             	movzbl (%eax),%eax
 1a8:	0f b6 c0             	movzbl %al,%eax
 1ab:	29 c2                	sub    %eax,%edx
 1ad:	89 d0                	mov    %edx,%eax
}
 1af:	5d                   	pop    %ebp
 1b0:	c3                   	ret    

000001b1 <strlen>:

uint
strlen(char *s)
{
 1b1:	55                   	push   %ebp
 1b2:	89 e5                	mov    %esp,%ebp
 1b4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1be:	eb 04                	jmp    1c4 <strlen+0x13>
 1c0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1c4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1c7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ca:	01 d0                	add    %edx,%eax
 1cc:	0f b6 00             	movzbl (%eax),%eax
 1cf:	84 c0                	test   %al,%al
 1d1:	75 ed                	jne    1c0 <strlen+0xf>
    ;
  return n;
 1d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1d6:	c9                   	leave  
 1d7:	c3                   	ret    

000001d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1de:	8b 45 10             	mov    0x10(%ebp),%eax
 1e1:	89 44 24 08          	mov    %eax,0x8(%esp)
 1e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	89 04 24             	mov    %eax,(%esp)
 1f2:	e8 26 ff ff ff       	call   11d <stosb>
  return dst;
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1fa:	c9                   	leave  
 1fb:	c3                   	ret    

000001fc <strchr>:

char*
strchr(const char *s, char c)
{
 1fc:	55                   	push   %ebp
 1fd:	89 e5                	mov    %esp,%ebp
 1ff:	83 ec 04             	sub    $0x4,%esp
 202:	8b 45 0c             	mov    0xc(%ebp),%eax
 205:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 208:	eb 14                	jmp    21e <strchr+0x22>
    if(*s == c)
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
 20d:	0f b6 00             	movzbl (%eax),%eax
 210:	3a 45 fc             	cmp    -0x4(%ebp),%al
 213:	75 05                	jne    21a <strchr+0x1e>
      return (char*)s;
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	eb 13                	jmp    22d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 21a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 21e:	8b 45 08             	mov    0x8(%ebp),%eax
 221:	0f b6 00             	movzbl (%eax),%eax
 224:	84 c0                	test   %al,%al
 226:	75 e2                	jne    20a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 228:	b8 00 00 00 00       	mov    $0x0,%eax
}
 22d:	c9                   	leave  
 22e:	c3                   	ret    

0000022f <gets>:

char*
gets(char *buf, int max)
{
 22f:	55                   	push   %ebp
 230:	89 e5                	mov    %esp,%ebp
 232:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 235:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 23c:	eb 4c                	jmp    28a <gets+0x5b>
    cc = read(0, &c, 1);
 23e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 245:	00 
 246:	8d 45 ef             	lea    -0x11(%ebp),%eax
 249:	89 44 24 04          	mov    %eax,0x4(%esp)
 24d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 254:	e8 44 01 00 00       	call   39d <read>
 259:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 25c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 260:	7f 02                	jg     264 <gets+0x35>
      break;
 262:	eb 31                	jmp    295 <gets+0x66>
    buf[i++] = c;
 264:	8b 45 f4             	mov    -0xc(%ebp),%eax
 267:	8d 50 01             	lea    0x1(%eax),%edx
 26a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 26d:	89 c2                	mov    %eax,%edx
 26f:	8b 45 08             	mov    0x8(%ebp),%eax
 272:	01 c2                	add    %eax,%edx
 274:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 278:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 27a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 27e:	3c 0a                	cmp    $0xa,%al
 280:	74 13                	je     295 <gets+0x66>
 282:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 286:	3c 0d                	cmp    $0xd,%al
 288:	74 0b                	je     295 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 28a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28d:	83 c0 01             	add    $0x1,%eax
 290:	3b 45 0c             	cmp    0xc(%ebp),%eax
 293:	7c a9                	jl     23e <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 295:	8b 55 f4             	mov    -0xc(%ebp),%edx
 298:	8b 45 08             	mov    0x8(%ebp),%eax
 29b:	01 d0                	add    %edx,%eax
 29d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a3:	c9                   	leave  
 2a4:	c3                   	ret    

000002a5 <stat>:

int
stat(char *n, struct stat *st)
{
 2a5:	55                   	push   %ebp
 2a6:	89 e5                	mov    %esp,%ebp
 2a8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2b2:	00 
 2b3:	8b 45 08             	mov    0x8(%ebp),%eax
 2b6:	89 04 24             	mov    %eax,(%esp)
 2b9:	e8 07 01 00 00       	call   3c5 <open>
 2be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2c5:	79 07                	jns    2ce <stat+0x29>
    return -1;
 2c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2cc:	eb 23                	jmp    2f1 <stat+0x4c>
  r = fstat(fd, st);
 2ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d8:	89 04 24             	mov    %eax,(%esp)
 2db:	e8 fd 00 00 00       	call   3dd <fstat>
 2e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e6:	89 04 24             	mov    %eax,(%esp)
 2e9:	e8 bf 00 00 00       	call   3ad <close>
  return r;
 2ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2f1:	c9                   	leave  
 2f2:	c3                   	ret    

000002f3 <atoi>:

int
atoi(const char *s)
{
 2f3:	55                   	push   %ebp
 2f4:	89 e5                	mov    %esp,%ebp
 2f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 300:	eb 25                	jmp    327 <atoi+0x34>
    n = n*10 + *s++ - '0';
 302:	8b 55 fc             	mov    -0x4(%ebp),%edx
 305:	89 d0                	mov    %edx,%eax
 307:	c1 e0 02             	shl    $0x2,%eax
 30a:	01 d0                	add    %edx,%eax
 30c:	01 c0                	add    %eax,%eax
 30e:	89 c1                	mov    %eax,%ecx
 310:	8b 45 08             	mov    0x8(%ebp),%eax
 313:	8d 50 01             	lea    0x1(%eax),%edx
 316:	89 55 08             	mov    %edx,0x8(%ebp)
 319:	0f b6 00             	movzbl (%eax),%eax
 31c:	0f be c0             	movsbl %al,%eax
 31f:	01 c8                	add    %ecx,%eax
 321:	83 e8 30             	sub    $0x30,%eax
 324:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	0f b6 00             	movzbl (%eax),%eax
 32d:	3c 2f                	cmp    $0x2f,%al
 32f:	7e 0a                	jle    33b <atoi+0x48>
 331:	8b 45 08             	mov    0x8(%ebp),%eax
 334:	0f b6 00             	movzbl (%eax),%eax
 337:	3c 39                	cmp    $0x39,%al
 339:	7e c7                	jle    302 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 33b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 33e:	c9                   	leave  
 33f:	c3                   	ret    

00000340 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 340:	55                   	push   %ebp
 341:	89 e5                	mov    %esp,%ebp
 343:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 346:	8b 45 08             	mov    0x8(%ebp),%eax
 349:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 34c:	8b 45 0c             	mov    0xc(%ebp),%eax
 34f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 352:	eb 17                	jmp    36b <memmove+0x2b>
    *dst++ = *src++;
 354:	8b 45 fc             	mov    -0x4(%ebp),%eax
 357:	8d 50 01             	lea    0x1(%eax),%edx
 35a:	89 55 fc             	mov    %edx,-0x4(%ebp)
 35d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 360:	8d 4a 01             	lea    0x1(%edx),%ecx
 363:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 366:	0f b6 12             	movzbl (%edx),%edx
 369:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 36b:	8b 45 10             	mov    0x10(%ebp),%eax
 36e:	8d 50 ff             	lea    -0x1(%eax),%edx
 371:	89 55 10             	mov    %edx,0x10(%ebp)
 374:	85 c0                	test   %eax,%eax
 376:	7f dc                	jg     354 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 378:	8b 45 08             	mov    0x8(%ebp),%eax
}
 37b:	c9                   	leave  
 37c:	c3                   	ret    

0000037d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 37d:	b8 01 00 00 00       	mov    $0x1,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <exit>:
SYSCALL(exit)
 385:	b8 02 00 00 00       	mov    $0x2,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <wait>:
SYSCALL(wait)
 38d:	b8 03 00 00 00       	mov    $0x3,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <pipe>:
SYSCALL(pipe)
 395:	b8 04 00 00 00       	mov    $0x4,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <read>:
SYSCALL(read)
 39d:	b8 05 00 00 00       	mov    $0x5,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <write>:
SYSCALL(write)
 3a5:	b8 10 00 00 00       	mov    $0x10,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <close>:
SYSCALL(close)
 3ad:	b8 15 00 00 00       	mov    $0x15,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <kill>:
SYSCALL(kill)
 3b5:	b8 06 00 00 00       	mov    $0x6,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <exec>:
SYSCALL(exec)
 3bd:	b8 07 00 00 00       	mov    $0x7,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <open>:
SYSCALL(open)
 3c5:	b8 0f 00 00 00       	mov    $0xf,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <mknod>:
SYSCALL(mknod)
 3cd:	b8 11 00 00 00       	mov    $0x11,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <unlink>:
SYSCALL(unlink)
 3d5:	b8 12 00 00 00       	mov    $0x12,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <fstat>:
SYSCALL(fstat)
 3dd:	b8 08 00 00 00       	mov    $0x8,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <link>:
SYSCALL(link)
 3e5:	b8 13 00 00 00       	mov    $0x13,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <mkdir>:
SYSCALL(mkdir)
 3ed:	b8 14 00 00 00       	mov    $0x14,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret    

000003f5 <chdir>:
SYSCALL(chdir)
 3f5:	b8 09 00 00 00       	mov    $0x9,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <dup>:
SYSCALL(dup)
 3fd:	b8 0a 00 00 00       	mov    $0xa,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <getpid>:
SYSCALL(getpid)
 405:	b8 0b 00 00 00       	mov    $0xb,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <sbrk>:
SYSCALL(sbrk)
 40d:	b8 0c 00 00 00       	mov    $0xc,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <sleep>:
SYSCALL(sleep)
 415:	b8 0d 00 00 00       	mov    $0xd,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <uptime>:
SYSCALL(uptime)
 41d:	b8 0e 00 00 00       	mov    $0xe,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <getcount>:
// To define asm routine for the new call.
SYSCALL(getcount)
 425:	b8 16 00 00 00       	mov    $0x16,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret    

0000042d <thread_create>:
// To define asm routines for the new thread management calls.
SYSCALL(thread_create)
 42d:	b8 17 00 00 00       	mov    $0x17,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret    

00000435 <thread_join>:
SYSCALL(thread_join)
 435:	b8 18 00 00 00       	mov    $0x18,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret    

0000043d <mtx_create>:
SYSCALL(mtx_create)
 43d:	b8 19 00 00 00       	mov    $0x19,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret    

00000445 <mtx_lock>:
SYSCALL(mtx_lock)
 445:	b8 1a 00 00 00       	mov    $0x1a,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret    

0000044d <mtx_unlock>:
SYSCALL(mtx_unlock)
 44d:	b8 1b 00 00 00       	mov    $0x1b,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 455:	55                   	push   %ebp
 456:	89 e5                	mov    %esp,%ebp
 458:	83 ec 18             	sub    $0x18,%esp
 45b:	8b 45 0c             	mov    0xc(%ebp),%eax
 45e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 461:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 468:	00 
 469:	8d 45 f4             	lea    -0xc(%ebp),%eax
 46c:	89 44 24 04          	mov    %eax,0x4(%esp)
 470:	8b 45 08             	mov    0x8(%ebp),%eax
 473:	89 04 24             	mov    %eax,(%esp)
 476:	e8 2a ff ff ff       	call   3a5 <write>
}
 47b:	c9                   	leave  
 47c:	c3                   	ret    

0000047d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47d:	55                   	push   %ebp
 47e:	89 e5                	mov    %esp,%ebp
 480:	56                   	push   %esi
 481:	53                   	push   %ebx
 482:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 485:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 48c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 490:	74 17                	je     4a9 <printint+0x2c>
 492:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 496:	79 11                	jns    4a9 <printint+0x2c>
    neg = 1;
 498:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 49f:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a2:	f7 d8                	neg    %eax
 4a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a7:	eb 06                	jmp    4af <printint+0x32>
  } else {
    x = xx;
 4a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4b9:	8d 41 01             	lea    0x1(%ecx),%eax
 4bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c5:	ba 00 00 00 00       	mov    $0x0,%edx
 4ca:	f7 f3                	div    %ebx
 4cc:	89 d0                	mov    %edx,%eax
 4ce:	0f b6 80 94 0b 00 00 	movzbl 0xb94(%eax),%eax
 4d5:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4d9:	8b 75 10             	mov    0x10(%ebp),%esi
 4dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4df:	ba 00 00 00 00       	mov    $0x0,%edx
 4e4:	f7 f6                	div    %esi
 4e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ed:	75 c7                	jne    4b6 <printint+0x39>
  if(neg)
 4ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f3:	74 10                	je     505 <printint+0x88>
    buf[i++] = '-';
 4f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f8:	8d 50 01             	lea    0x1(%eax),%edx
 4fb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4fe:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 503:	eb 1f                	jmp    524 <printint+0xa7>
 505:	eb 1d                	jmp    524 <printint+0xa7>
    putc(fd, buf[i]);
 507:	8d 55 dc             	lea    -0x24(%ebp),%edx
 50a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50d:	01 d0                	add    %edx,%eax
 50f:	0f b6 00             	movzbl (%eax),%eax
 512:	0f be c0             	movsbl %al,%eax
 515:	89 44 24 04          	mov    %eax,0x4(%esp)
 519:	8b 45 08             	mov    0x8(%ebp),%eax
 51c:	89 04 24             	mov    %eax,(%esp)
 51f:	e8 31 ff ff ff       	call   455 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 524:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 528:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 52c:	79 d9                	jns    507 <printint+0x8a>
    putc(fd, buf[i]);
}
 52e:	83 c4 30             	add    $0x30,%esp
 531:	5b                   	pop    %ebx
 532:	5e                   	pop    %esi
 533:	5d                   	pop    %ebp
 534:	c3                   	ret    

00000535 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 535:	55                   	push   %ebp
 536:	89 e5                	mov    %esp,%ebp
 538:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 53b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 542:	8d 45 0c             	lea    0xc(%ebp),%eax
 545:	83 c0 04             	add    $0x4,%eax
 548:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 54b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 552:	e9 7c 01 00 00       	jmp    6d3 <printf+0x19e>
    c = fmt[i] & 0xff;
 557:	8b 55 0c             	mov    0xc(%ebp),%edx
 55a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 55d:	01 d0                	add    %edx,%eax
 55f:	0f b6 00             	movzbl (%eax),%eax
 562:	0f be c0             	movsbl %al,%eax
 565:	25 ff 00 00 00       	and    $0xff,%eax
 56a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 56d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 571:	75 2c                	jne    59f <printf+0x6a>
      if(c == '%'){
 573:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 577:	75 0c                	jne    585 <printf+0x50>
        state = '%';
 579:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 580:	e9 4a 01 00 00       	jmp    6cf <printf+0x19a>
      } else {
        putc(fd, c);
 585:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 588:	0f be c0             	movsbl %al,%eax
 58b:	89 44 24 04          	mov    %eax,0x4(%esp)
 58f:	8b 45 08             	mov    0x8(%ebp),%eax
 592:	89 04 24             	mov    %eax,(%esp)
 595:	e8 bb fe ff ff       	call   455 <putc>
 59a:	e9 30 01 00 00       	jmp    6cf <printf+0x19a>
      }
    } else if(state == '%'){
 59f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5a3:	0f 85 26 01 00 00    	jne    6cf <printf+0x19a>
      if(c == 'd'){
 5a9:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5ad:	75 2d                	jne    5dc <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5af:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b2:	8b 00                	mov    (%eax),%eax
 5b4:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5bb:	00 
 5bc:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5c3:	00 
 5c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c8:	8b 45 08             	mov    0x8(%ebp),%eax
 5cb:	89 04 24             	mov    %eax,(%esp)
 5ce:	e8 aa fe ff ff       	call   47d <printint>
        ap++;
 5d3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d7:	e9 ec 00 00 00       	jmp    6c8 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5dc:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5e0:	74 06                	je     5e8 <printf+0xb3>
 5e2:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5e6:	75 2d                	jne    615 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5eb:	8b 00                	mov    (%eax),%eax
 5ed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5f4:	00 
 5f5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5fc:	00 
 5fd:	89 44 24 04          	mov    %eax,0x4(%esp)
 601:	8b 45 08             	mov    0x8(%ebp),%eax
 604:	89 04 24             	mov    %eax,(%esp)
 607:	e8 71 fe ff ff       	call   47d <printint>
        ap++;
 60c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 610:	e9 b3 00 00 00       	jmp    6c8 <printf+0x193>
      } else if(c == 's'){
 615:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 619:	75 45                	jne    660 <printf+0x12b>
        s = (char*)*ap;
 61b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 61e:	8b 00                	mov    (%eax),%eax
 620:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 623:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 627:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 62b:	75 09                	jne    636 <printf+0x101>
          s = "(null)";
 62d:	c7 45 f4 27 09 00 00 	movl   $0x927,-0xc(%ebp)
        while(*s != 0){
 634:	eb 1e                	jmp    654 <printf+0x11f>
 636:	eb 1c                	jmp    654 <printf+0x11f>
          putc(fd, *s);
 638:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63b:	0f b6 00             	movzbl (%eax),%eax
 63e:	0f be c0             	movsbl %al,%eax
 641:	89 44 24 04          	mov    %eax,0x4(%esp)
 645:	8b 45 08             	mov    0x8(%ebp),%eax
 648:	89 04 24             	mov    %eax,(%esp)
 64b:	e8 05 fe ff ff       	call   455 <putc>
          s++;
 650:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 654:	8b 45 f4             	mov    -0xc(%ebp),%eax
 657:	0f b6 00             	movzbl (%eax),%eax
 65a:	84 c0                	test   %al,%al
 65c:	75 da                	jne    638 <printf+0x103>
 65e:	eb 68                	jmp    6c8 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 660:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 664:	75 1d                	jne    683 <printf+0x14e>
        putc(fd, *ap);
 666:	8b 45 e8             	mov    -0x18(%ebp),%eax
 669:	8b 00                	mov    (%eax),%eax
 66b:	0f be c0             	movsbl %al,%eax
 66e:	89 44 24 04          	mov    %eax,0x4(%esp)
 672:	8b 45 08             	mov    0x8(%ebp),%eax
 675:	89 04 24             	mov    %eax,(%esp)
 678:	e8 d8 fd ff ff       	call   455 <putc>
        ap++;
 67d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 681:	eb 45                	jmp    6c8 <printf+0x193>
      } else if(c == '%'){
 683:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 687:	75 17                	jne    6a0 <printf+0x16b>
        putc(fd, c);
 689:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68c:	0f be c0             	movsbl %al,%eax
 68f:	89 44 24 04          	mov    %eax,0x4(%esp)
 693:	8b 45 08             	mov    0x8(%ebp),%eax
 696:	89 04 24             	mov    %eax,(%esp)
 699:	e8 b7 fd ff ff       	call   455 <putc>
 69e:	eb 28                	jmp    6c8 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6a0:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6a7:	00 
 6a8:	8b 45 08             	mov    0x8(%ebp),%eax
 6ab:	89 04 24             	mov    %eax,(%esp)
 6ae:	e8 a2 fd ff ff       	call   455 <putc>
        putc(fd, c);
 6b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b6:	0f be c0             	movsbl %al,%eax
 6b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6bd:	8b 45 08             	mov    0x8(%ebp),%eax
 6c0:	89 04 24             	mov    %eax,(%esp)
 6c3:	e8 8d fd ff ff       	call   455 <putc>
      }
      state = 0;
 6c8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6cf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6d3:	8b 55 0c             	mov    0xc(%ebp),%edx
 6d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d9:	01 d0                	add    %edx,%eax
 6db:	0f b6 00             	movzbl (%eax),%eax
 6de:	84 c0                	test   %al,%al
 6e0:	0f 85 71 fe ff ff    	jne    557 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6e6:	c9                   	leave  
 6e7:	c3                   	ret    

000006e8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6e8:	55                   	push   %ebp
 6e9:	89 e5                	mov    %esp,%ebp
 6eb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ee:	8b 45 08             	mov    0x8(%ebp),%eax
 6f1:	83 e8 08             	sub    $0x8,%eax
 6f4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f7:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 6fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6ff:	eb 24                	jmp    725 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 701:	8b 45 fc             	mov    -0x4(%ebp),%eax
 704:	8b 00                	mov    (%eax),%eax
 706:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 709:	77 12                	ja     71d <free+0x35>
 70b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 711:	77 24                	ja     737 <free+0x4f>
 713:	8b 45 fc             	mov    -0x4(%ebp),%eax
 716:	8b 00                	mov    (%eax),%eax
 718:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 71b:	77 1a                	ja     737 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 720:	8b 00                	mov    (%eax),%eax
 722:	89 45 fc             	mov    %eax,-0x4(%ebp)
 725:	8b 45 f8             	mov    -0x8(%ebp),%eax
 728:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 72b:	76 d4                	jbe    701 <free+0x19>
 72d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 730:	8b 00                	mov    (%eax),%eax
 732:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 735:	76 ca                	jbe    701 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 737:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73a:	8b 40 04             	mov    0x4(%eax),%eax
 73d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 744:	8b 45 f8             	mov    -0x8(%ebp),%eax
 747:	01 c2                	add    %eax,%edx
 749:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74c:	8b 00                	mov    (%eax),%eax
 74e:	39 c2                	cmp    %eax,%edx
 750:	75 24                	jne    776 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 752:	8b 45 f8             	mov    -0x8(%ebp),%eax
 755:	8b 50 04             	mov    0x4(%eax),%edx
 758:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75b:	8b 00                	mov    (%eax),%eax
 75d:	8b 40 04             	mov    0x4(%eax),%eax
 760:	01 c2                	add    %eax,%edx
 762:	8b 45 f8             	mov    -0x8(%ebp),%eax
 765:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 768:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76b:	8b 00                	mov    (%eax),%eax
 76d:	8b 10                	mov    (%eax),%edx
 76f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 772:	89 10                	mov    %edx,(%eax)
 774:	eb 0a                	jmp    780 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 776:	8b 45 fc             	mov    -0x4(%ebp),%eax
 779:	8b 10                	mov    (%eax),%edx
 77b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 780:	8b 45 fc             	mov    -0x4(%ebp),%eax
 783:	8b 40 04             	mov    0x4(%eax),%eax
 786:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 78d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 790:	01 d0                	add    %edx,%eax
 792:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 795:	75 20                	jne    7b7 <free+0xcf>
    p->s.size += bp->s.size;
 797:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79a:	8b 50 04             	mov    0x4(%eax),%edx
 79d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a0:	8b 40 04             	mov    0x4(%eax),%eax
 7a3:	01 c2                	add    %eax,%edx
 7a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ae:	8b 10                	mov    (%eax),%edx
 7b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b3:	89 10                	mov    %edx,(%eax)
 7b5:	eb 08                	jmp    7bf <free+0xd7>
  } else
    p->s.ptr = bp;
 7b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ba:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7bd:	89 10                	mov    %edx,(%eax)
  freep = p;
 7bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c2:	a3 c8 0b 00 00       	mov    %eax,0xbc8
}
 7c7:	c9                   	leave  
 7c8:	c3                   	ret    

000007c9 <morecore>:

static Header*
morecore(uint nu)
{
 7c9:	55                   	push   %ebp
 7ca:	89 e5                	mov    %esp,%ebp
 7cc:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7cf:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7d6:	77 07                	ja     7df <morecore+0x16>
    nu = 4096;
 7d8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7df:	8b 45 08             	mov    0x8(%ebp),%eax
 7e2:	c1 e0 03             	shl    $0x3,%eax
 7e5:	89 04 24             	mov    %eax,(%esp)
 7e8:	e8 20 fc ff ff       	call   40d <sbrk>
 7ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7f0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7f4:	75 07                	jne    7fd <morecore+0x34>
    return 0;
 7f6:	b8 00 00 00 00       	mov    $0x0,%eax
 7fb:	eb 22                	jmp    81f <morecore+0x56>
  hp = (Header*)p;
 7fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 800:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 803:	8b 45 f0             	mov    -0x10(%ebp),%eax
 806:	8b 55 08             	mov    0x8(%ebp),%edx
 809:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 80c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80f:	83 c0 08             	add    $0x8,%eax
 812:	89 04 24             	mov    %eax,(%esp)
 815:	e8 ce fe ff ff       	call   6e8 <free>
  return freep;
 81a:	a1 c8 0b 00 00       	mov    0xbc8,%eax
}
 81f:	c9                   	leave  
 820:	c3                   	ret    

00000821 <malloc>:

void*
malloc(uint nbytes)
{
 821:	55                   	push   %ebp
 822:	89 e5                	mov    %esp,%ebp
 824:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 827:	8b 45 08             	mov    0x8(%ebp),%eax
 82a:	83 c0 07             	add    $0x7,%eax
 82d:	c1 e8 03             	shr    $0x3,%eax
 830:	83 c0 01             	add    $0x1,%eax
 833:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 836:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 83b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 83e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 842:	75 23                	jne    867 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 844:	c7 45 f0 c0 0b 00 00 	movl   $0xbc0,-0x10(%ebp)
 84b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84e:	a3 c8 0b 00 00       	mov    %eax,0xbc8
 853:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 858:	a3 c0 0b 00 00       	mov    %eax,0xbc0
    base.s.size = 0;
 85d:	c7 05 c4 0b 00 00 00 	movl   $0x0,0xbc4
 864:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 867:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86a:	8b 00                	mov    (%eax),%eax
 86c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 86f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 872:	8b 40 04             	mov    0x4(%eax),%eax
 875:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 878:	72 4d                	jb     8c7 <malloc+0xa6>
      if(p->s.size == nunits)
 87a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87d:	8b 40 04             	mov    0x4(%eax),%eax
 880:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 883:	75 0c                	jne    891 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 885:	8b 45 f4             	mov    -0xc(%ebp),%eax
 888:	8b 10                	mov    (%eax),%edx
 88a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88d:	89 10                	mov    %edx,(%eax)
 88f:	eb 26                	jmp    8b7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 891:	8b 45 f4             	mov    -0xc(%ebp),%eax
 894:	8b 40 04             	mov    0x4(%eax),%eax
 897:	2b 45 ec             	sub    -0x14(%ebp),%eax
 89a:	89 c2                	mov    %eax,%edx
 89c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a5:	8b 40 04             	mov    0x4(%eax),%eax
 8a8:	c1 e0 03             	shl    $0x3,%eax
 8ab:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8b4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ba:	a3 c8 0b 00 00       	mov    %eax,0xbc8
      return (void*)(p + 1);
 8bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c2:	83 c0 08             	add    $0x8,%eax
 8c5:	eb 38                	jmp    8ff <malloc+0xde>
    }
    if(p == freep)
 8c7:	a1 c8 0b 00 00       	mov    0xbc8,%eax
 8cc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8cf:	75 1b                	jne    8ec <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8d4:	89 04 24             	mov    %eax,(%esp)
 8d7:	e8 ed fe ff ff       	call   7c9 <morecore>
 8dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8e3:	75 07                	jne    8ec <malloc+0xcb>
        return 0;
 8e5:	b8 00 00 00 00       	mov    $0x0,%eax
 8ea:	eb 13                	jmp    8ff <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f5:	8b 00                	mov    (%eax),%eax
 8f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8fa:	e9 70 ff ff ff       	jmp    86f <malloc+0x4e>
}
 8ff:	c9                   	leave  
 900:	c3                   	ret    
