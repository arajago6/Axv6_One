
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n, m;
  char *p, *q;
  
  m = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
   d:	e9 bb 00 00 00       	jmp    cd <grep+0xcd>
    m += n;
  12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  15:	01 45 f4             	add    %eax,-0xc(%ebp)
    p = buf;
  18:	c7 45 f0 80 0e 00 00 	movl   $0xe80,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  1f:	eb 51                	jmp    72 <grep+0x72>
      *q = 0;
  21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  24:	c6 00 00             	movb   $0x0,(%eax)
      if(match(pattern, p)){
  27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  2e:	8b 45 08             	mov    0x8(%ebp),%eax
  31:	89 04 24             	mov    %eax,(%esp)
  34:	e8 bc 01 00 00       	call   1f5 <match>
  39:	85 c0                	test   %eax,%eax
  3b:	74 2c                	je     69 <grep+0x69>
        *q = '\n';
  3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  40:	c6 00 0a             	movb   $0xa,(%eax)
        write(1, p, q+1 - p);
  43:	8b 45 e8             	mov    -0x18(%ebp),%eax
  46:	83 c0 01             	add    $0x1,%eax
  49:	89 c2                	mov    %eax,%edx
  4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  4e:	29 c2                	sub    %eax,%edx
  50:	89 d0                	mov    %edx,%eax
  52:	89 44 24 08          	mov    %eax,0x8(%esp)
  56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  59:	89 44 24 04          	mov    %eax,0x4(%esp)
  5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  64:	e8 74 05 00 00       	call   5dd <write>
      }
      p = q+1;
  69:	8b 45 e8             	mov    -0x18(%ebp),%eax
  6c:	83 c0 01             	add    $0x1,%eax
  6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
    m += n;
    p = buf;
    while((q = strchr(p, '\n')) != 0){
  72:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  79:	00 
  7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  7d:	89 04 24             	mov    %eax,(%esp)
  80:	e8 af 03 00 00       	call   434 <strchr>
  85:	89 45 e8             	mov    %eax,-0x18(%ebp)
  88:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8c:	75 93                	jne    21 <grep+0x21>
        *q = '\n';
        write(1, p, q+1 - p);
      }
      p = q+1;
    }
    if(p == buf)
  8e:	81 7d f0 80 0e 00 00 	cmpl   $0xe80,-0x10(%ebp)
  95:	75 07                	jne    9e <grep+0x9e>
      m = 0;
  97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a2:	7e 29                	jle    cd <grep+0xcd>
      m -= p - buf;
  a4:	ba 80 0e 00 00       	mov    $0xe80,%edx
  a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ac:	29 c2                	sub    %eax,%edx
  ae:	89 d0                	mov    %edx,%eax
  b0:	01 45 f4             	add    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  c1:	c7 04 24 80 0e 00 00 	movl   $0xe80,(%esp)
  c8:	e8 ab 04 00 00       	call   578 <memmove>
{
  int n, m;
  char *p, *q;
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
  cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d0:	ba 00 04 00 00       	mov    $0x400,%edx
  d5:	29 c2                	sub    %eax,%edx
  d7:	89 d0                	mov    %edx,%eax
  d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  dc:	81 c2 80 0e 00 00    	add    $0xe80,%edx
  e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  ed:	89 04 24             	mov    %eax,(%esp)
  f0:	e8 e0 04 00 00       	call   5d5 <read>
  f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  f8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  fc:	0f 8f 10 ff ff ff    	jg     12 <grep+0x12>
    if(m > 0){
      m -= p - buf;
      memmove(buf, p, m);
    }
  }
}
 102:	c9                   	leave  
 103:	c3                   	ret    

00000104 <main>:

int
main(int argc, char *argv[])
{
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	83 e4 f0             	and    $0xfffffff0,%esp
 10a:	83 ec 20             	sub    $0x20,%esp
  int fd, i;
  char *pattern;
  
  if(argc <= 1){
 10d:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 111:	7f 19                	jg     12c <main+0x28>
    printf(2, "usage: grep pattern [file ...]\n");
 113:	c7 44 24 04 3c 0b 00 	movl   $0xb3c,0x4(%esp)
 11a:	00 
 11b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 122:	e8 46 06 00 00       	call   76d <printf>
    exit();
 127:	e8 91 04 00 00       	call   5bd <exit>
  }
  pattern = argv[1];
 12c:	8b 45 0c             	mov    0xc(%ebp),%eax
 12f:	8b 40 04             	mov    0x4(%eax),%eax
 132:	89 44 24 18          	mov    %eax,0x18(%esp)
  
  if(argc <= 2){
 136:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 13a:	7f 19                	jg     155 <main+0x51>
    grep(pattern, 0);
 13c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 143:	00 
 144:	8b 44 24 18          	mov    0x18(%esp),%eax
 148:	89 04 24             	mov    %eax,(%esp)
 14b:	e8 b0 fe ff ff       	call   0 <grep>
    exit();
 150:	e8 68 04 00 00       	call   5bd <exit>
  }

  for(i = 2; i < argc; i++){
 155:	c7 44 24 1c 02 00 00 	movl   $0x2,0x1c(%esp)
 15c:	00 
 15d:	e9 81 00 00 00       	jmp    1e3 <main+0xdf>
    if((fd = open(argv[i], 0)) < 0){
 162:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 166:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 16d:	8b 45 0c             	mov    0xc(%ebp),%eax
 170:	01 d0                	add    %edx,%eax
 172:	8b 00                	mov    (%eax),%eax
 174:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 17b:	00 
 17c:	89 04 24             	mov    %eax,(%esp)
 17f:	e8 79 04 00 00       	call   5fd <open>
 184:	89 44 24 14          	mov    %eax,0x14(%esp)
 188:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 18d:	79 2f                	jns    1be <main+0xba>
      printf(1, "grep: cannot open %s\n", argv[i]);
 18f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 193:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 19a:	8b 45 0c             	mov    0xc(%ebp),%eax
 19d:	01 d0                	add    %edx,%eax
 19f:	8b 00                	mov    (%eax),%eax
 1a1:	89 44 24 08          	mov    %eax,0x8(%esp)
 1a5:	c7 44 24 04 5c 0b 00 	movl   $0xb5c,0x4(%esp)
 1ac:	00 
 1ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1b4:	e8 b4 05 00 00       	call   76d <printf>
      exit();
 1b9:	e8 ff 03 00 00       	call   5bd <exit>
    }
    grep(pattern, fd);
 1be:	8b 44 24 14          	mov    0x14(%esp),%eax
 1c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c6:	8b 44 24 18          	mov    0x18(%esp),%eax
 1ca:	89 04 24             	mov    %eax,(%esp)
 1cd:	e8 2e fe ff ff       	call   0 <grep>
    close(fd);
 1d2:	8b 44 24 14          	mov    0x14(%esp),%eax
 1d6:	89 04 24             	mov    %eax,(%esp)
 1d9:	e8 07 04 00 00       	call   5e5 <close>
  if(argc <= 2){
    grep(pattern, 0);
    exit();
  }

  for(i = 2; i < argc; i++){
 1de:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1e3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1e7:	3b 45 08             	cmp    0x8(%ebp),%eax
 1ea:	0f 8c 72 ff ff ff    	jl     162 <main+0x5e>
      exit();
    }
    grep(pattern, fd);
    close(fd);
  }
  exit();
 1f0:	e8 c8 03 00 00       	call   5bd <exit>

000001f5 <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 1f5:	55                   	push   %ebp
 1f6:	89 e5                	mov    %esp,%ebp
 1f8:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '^')
 1fb:	8b 45 08             	mov    0x8(%ebp),%eax
 1fe:	0f b6 00             	movzbl (%eax),%eax
 201:	3c 5e                	cmp    $0x5e,%al
 203:	75 17                	jne    21c <match+0x27>
    return matchhere(re+1, text);
 205:	8b 45 08             	mov    0x8(%ebp),%eax
 208:	8d 50 01             	lea    0x1(%eax),%edx
 20b:	8b 45 0c             	mov    0xc(%ebp),%eax
 20e:	89 44 24 04          	mov    %eax,0x4(%esp)
 212:	89 14 24             	mov    %edx,(%esp)
 215:	e8 36 00 00 00       	call   250 <matchhere>
 21a:	eb 32                	jmp    24e <match+0x59>
  do{  // must look at empty string
    if(matchhere(re, text))
 21c:	8b 45 0c             	mov    0xc(%ebp),%eax
 21f:	89 44 24 04          	mov    %eax,0x4(%esp)
 223:	8b 45 08             	mov    0x8(%ebp),%eax
 226:	89 04 24             	mov    %eax,(%esp)
 229:	e8 22 00 00 00       	call   250 <matchhere>
 22e:	85 c0                	test   %eax,%eax
 230:	74 07                	je     239 <match+0x44>
      return 1;
 232:	b8 01 00 00 00       	mov    $0x1,%eax
 237:	eb 15                	jmp    24e <match+0x59>
  }while(*text++ != '\0');
 239:	8b 45 0c             	mov    0xc(%ebp),%eax
 23c:	8d 50 01             	lea    0x1(%eax),%edx
 23f:	89 55 0c             	mov    %edx,0xc(%ebp)
 242:	0f b6 00             	movzbl (%eax),%eax
 245:	84 c0                	test   %al,%al
 247:	75 d3                	jne    21c <match+0x27>
  return 0;
 249:	b8 00 00 00 00       	mov    $0x0,%eax
}
 24e:	c9                   	leave  
 24f:	c3                   	ret    

00000250 <matchhere>:

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
 250:	55                   	push   %ebp
 251:	89 e5                	mov    %esp,%ebp
 253:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '\0')
 256:	8b 45 08             	mov    0x8(%ebp),%eax
 259:	0f b6 00             	movzbl (%eax),%eax
 25c:	84 c0                	test   %al,%al
 25e:	75 0a                	jne    26a <matchhere+0x1a>
    return 1;
 260:	b8 01 00 00 00       	mov    $0x1,%eax
 265:	e9 9b 00 00 00       	jmp    305 <matchhere+0xb5>
  if(re[1] == '*')
 26a:	8b 45 08             	mov    0x8(%ebp),%eax
 26d:	83 c0 01             	add    $0x1,%eax
 270:	0f b6 00             	movzbl (%eax),%eax
 273:	3c 2a                	cmp    $0x2a,%al
 275:	75 24                	jne    29b <matchhere+0x4b>
    return matchstar(re[0], re+2, text);
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	8d 48 02             	lea    0x2(%eax),%ecx
 27d:	8b 45 08             	mov    0x8(%ebp),%eax
 280:	0f b6 00             	movzbl (%eax),%eax
 283:	0f be c0             	movsbl %al,%eax
 286:	8b 55 0c             	mov    0xc(%ebp),%edx
 289:	89 54 24 08          	mov    %edx,0x8(%esp)
 28d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 291:	89 04 24             	mov    %eax,(%esp)
 294:	e8 6e 00 00 00       	call   307 <matchstar>
 299:	eb 6a                	jmp    305 <matchhere+0xb5>
  if(re[0] == '$' && re[1] == '\0')
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	0f b6 00             	movzbl (%eax),%eax
 2a1:	3c 24                	cmp    $0x24,%al
 2a3:	75 1d                	jne    2c2 <matchhere+0x72>
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	83 c0 01             	add    $0x1,%eax
 2ab:	0f b6 00             	movzbl (%eax),%eax
 2ae:	84 c0                	test   %al,%al
 2b0:	75 10                	jne    2c2 <matchhere+0x72>
    return *text == '\0';
 2b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b5:	0f b6 00             	movzbl (%eax),%eax
 2b8:	84 c0                	test   %al,%al
 2ba:	0f 94 c0             	sete   %al
 2bd:	0f b6 c0             	movzbl %al,%eax
 2c0:	eb 43                	jmp    305 <matchhere+0xb5>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 2c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c5:	0f b6 00             	movzbl (%eax),%eax
 2c8:	84 c0                	test   %al,%al
 2ca:	74 34                	je     300 <matchhere+0xb0>
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
 2cf:	0f b6 00             	movzbl (%eax),%eax
 2d2:	3c 2e                	cmp    $0x2e,%al
 2d4:	74 10                	je     2e6 <matchhere+0x96>
 2d6:	8b 45 08             	mov    0x8(%ebp),%eax
 2d9:	0f b6 10             	movzbl (%eax),%edx
 2dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2df:	0f b6 00             	movzbl (%eax),%eax
 2e2:	38 c2                	cmp    %al,%dl
 2e4:	75 1a                	jne    300 <matchhere+0xb0>
    return matchhere(re+1, text+1);
 2e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e9:	8d 50 01             	lea    0x1(%eax),%edx
 2ec:	8b 45 08             	mov    0x8(%ebp),%eax
 2ef:	83 c0 01             	add    $0x1,%eax
 2f2:	89 54 24 04          	mov    %edx,0x4(%esp)
 2f6:	89 04 24             	mov    %eax,(%esp)
 2f9:	e8 52 ff ff ff       	call   250 <matchhere>
 2fe:	eb 05                	jmp    305 <matchhere+0xb5>
  return 0;
 300:	b8 00 00 00 00       	mov    $0x0,%eax
}
 305:	c9                   	leave  
 306:	c3                   	ret    

00000307 <matchstar>:

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
 307:	55                   	push   %ebp
 308:	89 e5                	mov    %esp,%ebp
 30a:	83 ec 18             	sub    $0x18,%esp
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
 30d:	8b 45 10             	mov    0x10(%ebp),%eax
 310:	89 44 24 04          	mov    %eax,0x4(%esp)
 314:	8b 45 0c             	mov    0xc(%ebp),%eax
 317:	89 04 24             	mov    %eax,(%esp)
 31a:	e8 31 ff ff ff       	call   250 <matchhere>
 31f:	85 c0                	test   %eax,%eax
 321:	74 07                	je     32a <matchstar+0x23>
      return 1;
 323:	b8 01 00 00 00       	mov    $0x1,%eax
 328:	eb 29                	jmp    353 <matchstar+0x4c>
  }while(*text!='\0' && (*text++==c || c=='.'));
 32a:	8b 45 10             	mov    0x10(%ebp),%eax
 32d:	0f b6 00             	movzbl (%eax),%eax
 330:	84 c0                	test   %al,%al
 332:	74 1a                	je     34e <matchstar+0x47>
 334:	8b 45 10             	mov    0x10(%ebp),%eax
 337:	8d 50 01             	lea    0x1(%eax),%edx
 33a:	89 55 10             	mov    %edx,0x10(%ebp)
 33d:	0f b6 00             	movzbl (%eax),%eax
 340:	0f be c0             	movsbl %al,%eax
 343:	3b 45 08             	cmp    0x8(%ebp),%eax
 346:	74 c5                	je     30d <matchstar+0x6>
 348:	83 7d 08 2e          	cmpl   $0x2e,0x8(%ebp)
 34c:	74 bf                	je     30d <matchstar+0x6>
  return 0;
 34e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 353:	c9                   	leave  
 354:	c3                   	ret    

00000355 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 355:	55                   	push   %ebp
 356:	89 e5                	mov    %esp,%ebp
 358:	57                   	push   %edi
 359:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 35a:	8b 4d 08             	mov    0x8(%ebp),%ecx
 35d:	8b 55 10             	mov    0x10(%ebp),%edx
 360:	8b 45 0c             	mov    0xc(%ebp),%eax
 363:	89 cb                	mov    %ecx,%ebx
 365:	89 df                	mov    %ebx,%edi
 367:	89 d1                	mov    %edx,%ecx
 369:	fc                   	cld    
 36a:	f3 aa                	rep stos %al,%es:(%edi)
 36c:	89 ca                	mov    %ecx,%edx
 36e:	89 fb                	mov    %edi,%ebx
 370:	89 5d 08             	mov    %ebx,0x8(%ebp)
 373:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 376:	5b                   	pop    %ebx
 377:	5f                   	pop    %edi
 378:	5d                   	pop    %ebp
 379:	c3                   	ret    

0000037a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 37a:	55                   	push   %ebp
 37b:	89 e5                	mov    %esp,%ebp
 37d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 380:	8b 45 08             	mov    0x8(%ebp),%eax
 383:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 386:	90                   	nop
 387:	8b 45 08             	mov    0x8(%ebp),%eax
 38a:	8d 50 01             	lea    0x1(%eax),%edx
 38d:	89 55 08             	mov    %edx,0x8(%ebp)
 390:	8b 55 0c             	mov    0xc(%ebp),%edx
 393:	8d 4a 01             	lea    0x1(%edx),%ecx
 396:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 399:	0f b6 12             	movzbl (%edx),%edx
 39c:	88 10                	mov    %dl,(%eax)
 39e:	0f b6 00             	movzbl (%eax),%eax
 3a1:	84 c0                	test   %al,%al
 3a3:	75 e2                	jne    387 <strcpy+0xd>
    ;
  return os;
 3a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a8:	c9                   	leave  
 3a9:	c3                   	ret    

000003aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3aa:	55                   	push   %ebp
 3ab:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3ad:	eb 08                	jmp    3b7 <strcmp+0xd>
    p++, q++;
 3af:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3b7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ba:	0f b6 00             	movzbl (%eax),%eax
 3bd:	84 c0                	test   %al,%al
 3bf:	74 10                	je     3d1 <strcmp+0x27>
 3c1:	8b 45 08             	mov    0x8(%ebp),%eax
 3c4:	0f b6 10             	movzbl (%eax),%edx
 3c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ca:	0f b6 00             	movzbl (%eax),%eax
 3cd:	38 c2                	cmp    %al,%dl
 3cf:	74 de                	je     3af <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3d1:	8b 45 08             	mov    0x8(%ebp),%eax
 3d4:	0f b6 00             	movzbl (%eax),%eax
 3d7:	0f b6 d0             	movzbl %al,%edx
 3da:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dd:	0f b6 00             	movzbl (%eax),%eax
 3e0:	0f b6 c0             	movzbl %al,%eax
 3e3:	29 c2                	sub    %eax,%edx
 3e5:	89 d0                	mov    %edx,%eax
}
 3e7:	5d                   	pop    %ebp
 3e8:	c3                   	ret    

000003e9 <strlen>:

uint
strlen(char *s)
{
 3e9:	55                   	push   %ebp
 3ea:	89 e5                	mov    %esp,%ebp
 3ec:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3ef:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3f6:	eb 04                	jmp    3fc <strlen+0x13>
 3f8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3ff:	8b 45 08             	mov    0x8(%ebp),%eax
 402:	01 d0                	add    %edx,%eax
 404:	0f b6 00             	movzbl (%eax),%eax
 407:	84 c0                	test   %al,%al
 409:	75 ed                	jne    3f8 <strlen+0xf>
    ;
  return n;
 40b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 40e:	c9                   	leave  
 40f:	c3                   	ret    

00000410 <memset>:

void*
memset(void *dst, int c, uint n)
{
 410:	55                   	push   %ebp
 411:	89 e5                	mov    %esp,%ebp
 413:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 416:	8b 45 10             	mov    0x10(%ebp),%eax
 419:	89 44 24 08          	mov    %eax,0x8(%esp)
 41d:	8b 45 0c             	mov    0xc(%ebp),%eax
 420:	89 44 24 04          	mov    %eax,0x4(%esp)
 424:	8b 45 08             	mov    0x8(%ebp),%eax
 427:	89 04 24             	mov    %eax,(%esp)
 42a:	e8 26 ff ff ff       	call   355 <stosb>
  return dst;
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 432:	c9                   	leave  
 433:	c3                   	ret    

00000434 <strchr>:

char*
strchr(const char *s, char c)
{
 434:	55                   	push   %ebp
 435:	89 e5                	mov    %esp,%ebp
 437:	83 ec 04             	sub    $0x4,%esp
 43a:	8b 45 0c             	mov    0xc(%ebp),%eax
 43d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 440:	eb 14                	jmp    456 <strchr+0x22>
    if(*s == c)
 442:	8b 45 08             	mov    0x8(%ebp),%eax
 445:	0f b6 00             	movzbl (%eax),%eax
 448:	3a 45 fc             	cmp    -0x4(%ebp),%al
 44b:	75 05                	jne    452 <strchr+0x1e>
      return (char*)s;
 44d:	8b 45 08             	mov    0x8(%ebp),%eax
 450:	eb 13                	jmp    465 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 452:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 456:	8b 45 08             	mov    0x8(%ebp),%eax
 459:	0f b6 00             	movzbl (%eax),%eax
 45c:	84 c0                	test   %al,%al
 45e:	75 e2                	jne    442 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 460:	b8 00 00 00 00       	mov    $0x0,%eax
}
 465:	c9                   	leave  
 466:	c3                   	ret    

00000467 <gets>:

char*
gets(char *buf, int max)
{
 467:	55                   	push   %ebp
 468:	89 e5                	mov    %esp,%ebp
 46a:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 46d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 474:	eb 4c                	jmp    4c2 <gets+0x5b>
    cc = read(0, &c, 1);
 476:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 47d:	00 
 47e:	8d 45 ef             	lea    -0x11(%ebp),%eax
 481:	89 44 24 04          	mov    %eax,0x4(%esp)
 485:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 48c:	e8 44 01 00 00       	call   5d5 <read>
 491:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 494:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 498:	7f 02                	jg     49c <gets+0x35>
      break;
 49a:	eb 31                	jmp    4cd <gets+0x66>
    buf[i++] = c;
 49c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49f:	8d 50 01             	lea    0x1(%eax),%edx
 4a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4a5:	89 c2                	mov    %eax,%edx
 4a7:	8b 45 08             	mov    0x8(%ebp),%eax
 4aa:	01 c2                	add    %eax,%edx
 4ac:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4b2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b6:	3c 0a                	cmp    $0xa,%al
 4b8:	74 13                	je     4cd <gets+0x66>
 4ba:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4be:	3c 0d                	cmp    $0xd,%al
 4c0:	74 0b                	je     4cd <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c5:	83 c0 01             	add    $0x1,%eax
 4c8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4cb:	7c a9                	jl     476 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4d0:	8b 45 08             	mov    0x8(%ebp),%eax
 4d3:	01 d0                	add    %edx,%eax
 4d5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4db:	c9                   	leave  
 4dc:	c3                   	ret    

000004dd <stat>:

int
stat(char *n, struct stat *st)
{
 4dd:	55                   	push   %ebp
 4de:	89 e5                	mov    %esp,%ebp
 4e0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4ea:	00 
 4eb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ee:	89 04 24             	mov    %eax,(%esp)
 4f1:	e8 07 01 00 00       	call   5fd <open>
 4f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4fd:	79 07                	jns    506 <stat+0x29>
    return -1;
 4ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 504:	eb 23                	jmp    529 <stat+0x4c>
  r = fstat(fd, st);
 506:	8b 45 0c             	mov    0xc(%ebp),%eax
 509:	89 44 24 04          	mov    %eax,0x4(%esp)
 50d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 510:	89 04 24             	mov    %eax,(%esp)
 513:	e8 fd 00 00 00       	call   615 <fstat>
 518:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 51b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51e:	89 04 24             	mov    %eax,(%esp)
 521:	e8 bf 00 00 00       	call   5e5 <close>
  return r;
 526:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 529:	c9                   	leave  
 52a:	c3                   	ret    

0000052b <atoi>:

int
atoi(const char *s)
{
 52b:	55                   	push   %ebp
 52c:	89 e5                	mov    %esp,%ebp
 52e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 531:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 538:	eb 25                	jmp    55f <atoi+0x34>
    n = n*10 + *s++ - '0';
 53a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 53d:	89 d0                	mov    %edx,%eax
 53f:	c1 e0 02             	shl    $0x2,%eax
 542:	01 d0                	add    %edx,%eax
 544:	01 c0                	add    %eax,%eax
 546:	89 c1                	mov    %eax,%ecx
 548:	8b 45 08             	mov    0x8(%ebp),%eax
 54b:	8d 50 01             	lea    0x1(%eax),%edx
 54e:	89 55 08             	mov    %edx,0x8(%ebp)
 551:	0f b6 00             	movzbl (%eax),%eax
 554:	0f be c0             	movsbl %al,%eax
 557:	01 c8                	add    %ecx,%eax
 559:	83 e8 30             	sub    $0x30,%eax
 55c:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 55f:	8b 45 08             	mov    0x8(%ebp),%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	3c 2f                	cmp    $0x2f,%al
 567:	7e 0a                	jle    573 <atoi+0x48>
 569:	8b 45 08             	mov    0x8(%ebp),%eax
 56c:	0f b6 00             	movzbl (%eax),%eax
 56f:	3c 39                	cmp    $0x39,%al
 571:	7e c7                	jle    53a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 573:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 576:	c9                   	leave  
 577:	c3                   	ret    

00000578 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 578:	55                   	push   %ebp
 579:	89 e5                	mov    %esp,%ebp
 57b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 57e:	8b 45 08             	mov    0x8(%ebp),%eax
 581:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 584:	8b 45 0c             	mov    0xc(%ebp),%eax
 587:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 58a:	eb 17                	jmp    5a3 <memmove+0x2b>
    *dst++ = *src++;
 58c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 58f:	8d 50 01             	lea    0x1(%eax),%edx
 592:	89 55 fc             	mov    %edx,-0x4(%ebp)
 595:	8b 55 f8             	mov    -0x8(%ebp),%edx
 598:	8d 4a 01             	lea    0x1(%edx),%ecx
 59b:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 59e:	0f b6 12             	movzbl (%edx),%edx
 5a1:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5a3:	8b 45 10             	mov    0x10(%ebp),%eax
 5a6:	8d 50 ff             	lea    -0x1(%eax),%edx
 5a9:	89 55 10             	mov    %edx,0x10(%ebp)
 5ac:	85 c0                	test   %eax,%eax
 5ae:	7f dc                	jg     58c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5b0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5b3:	c9                   	leave  
 5b4:	c3                   	ret    

000005b5 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5b5:	b8 01 00 00 00       	mov    $0x1,%eax
 5ba:	cd 40                	int    $0x40
 5bc:	c3                   	ret    

000005bd <exit>:
SYSCALL(exit)
 5bd:	b8 02 00 00 00       	mov    $0x2,%eax
 5c2:	cd 40                	int    $0x40
 5c4:	c3                   	ret    

000005c5 <wait>:
SYSCALL(wait)
 5c5:	b8 03 00 00 00       	mov    $0x3,%eax
 5ca:	cd 40                	int    $0x40
 5cc:	c3                   	ret    

000005cd <pipe>:
SYSCALL(pipe)
 5cd:	b8 04 00 00 00       	mov    $0x4,%eax
 5d2:	cd 40                	int    $0x40
 5d4:	c3                   	ret    

000005d5 <read>:
SYSCALL(read)
 5d5:	b8 05 00 00 00       	mov    $0x5,%eax
 5da:	cd 40                	int    $0x40
 5dc:	c3                   	ret    

000005dd <write>:
SYSCALL(write)
 5dd:	b8 10 00 00 00       	mov    $0x10,%eax
 5e2:	cd 40                	int    $0x40
 5e4:	c3                   	ret    

000005e5 <close>:
SYSCALL(close)
 5e5:	b8 15 00 00 00       	mov    $0x15,%eax
 5ea:	cd 40                	int    $0x40
 5ec:	c3                   	ret    

000005ed <kill>:
SYSCALL(kill)
 5ed:	b8 06 00 00 00       	mov    $0x6,%eax
 5f2:	cd 40                	int    $0x40
 5f4:	c3                   	ret    

000005f5 <exec>:
SYSCALL(exec)
 5f5:	b8 07 00 00 00       	mov    $0x7,%eax
 5fa:	cd 40                	int    $0x40
 5fc:	c3                   	ret    

000005fd <open>:
SYSCALL(open)
 5fd:	b8 0f 00 00 00       	mov    $0xf,%eax
 602:	cd 40                	int    $0x40
 604:	c3                   	ret    

00000605 <mknod>:
SYSCALL(mknod)
 605:	b8 11 00 00 00       	mov    $0x11,%eax
 60a:	cd 40                	int    $0x40
 60c:	c3                   	ret    

0000060d <unlink>:
SYSCALL(unlink)
 60d:	b8 12 00 00 00       	mov    $0x12,%eax
 612:	cd 40                	int    $0x40
 614:	c3                   	ret    

00000615 <fstat>:
SYSCALL(fstat)
 615:	b8 08 00 00 00       	mov    $0x8,%eax
 61a:	cd 40                	int    $0x40
 61c:	c3                   	ret    

0000061d <link>:
SYSCALL(link)
 61d:	b8 13 00 00 00       	mov    $0x13,%eax
 622:	cd 40                	int    $0x40
 624:	c3                   	ret    

00000625 <mkdir>:
SYSCALL(mkdir)
 625:	b8 14 00 00 00       	mov    $0x14,%eax
 62a:	cd 40                	int    $0x40
 62c:	c3                   	ret    

0000062d <chdir>:
SYSCALL(chdir)
 62d:	b8 09 00 00 00       	mov    $0x9,%eax
 632:	cd 40                	int    $0x40
 634:	c3                   	ret    

00000635 <dup>:
SYSCALL(dup)
 635:	b8 0a 00 00 00       	mov    $0xa,%eax
 63a:	cd 40                	int    $0x40
 63c:	c3                   	ret    

0000063d <getpid>:
SYSCALL(getpid)
 63d:	b8 0b 00 00 00       	mov    $0xb,%eax
 642:	cd 40                	int    $0x40
 644:	c3                   	ret    

00000645 <sbrk>:
SYSCALL(sbrk)
 645:	b8 0c 00 00 00       	mov    $0xc,%eax
 64a:	cd 40                	int    $0x40
 64c:	c3                   	ret    

0000064d <sleep>:
SYSCALL(sleep)
 64d:	b8 0d 00 00 00       	mov    $0xd,%eax
 652:	cd 40                	int    $0x40
 654:	c3                   	ret    

00000655 <uptime>:
SYSCALL(uptime)
 655:	b8 0e 00 00 00       	mov    $0xe,%eax
 65a:	cd 40                	int    $0x40
 65c:	c3                   	ret    

0000065d <getcount>:
// To define asm routine for the new call.
SYSCALL(getcount)
 65d:	b8 16 00 00 00       	mov    $0x16,%eax
 662:	cd 40                	int    $0x40
 664:	c3                   	ret    

00000665 <thread_create>:
// To define asm routines for the new thread management calls.
SYSCALL(thread_create)
 665:	b8 17 00 00 00       	mov    $0x17,%eax
 66a:	cd 40                	int    $0x40
 66c:	c3                   	ret    

0000066d <thread_join>:
SYSCALL(thread_join)
 66d:	b8 18 00 00 00       	mov    $0x18,%eax
 672:	cd 40                	int    $0x40
 674:	c3                   	ret    

00000675 <mtx_create>:
SYSCALL(mtx_create)
 675:	b8 19 00 00 00       	mov    $0x19,%eax
 67a:	cd 40                	int    $0x40
 67c:	c3                   	ret    

0000067d <mtx_lock>:
SYSCALL(mtx_lock)
 67d:	b8 1a 00 00 00       	mov    $0x1a,%eax
 682:	cd 40                	int    $0x40
 684:	c3                   	ret    

00000685 <mtx_unlock>:
SYSCALL(mtx_unlock)
 685:	b8 1b 00 00 00       	mov    $0x1b,%eax
 68a:	cd 40                	int    $0x40
 68c:	c3                   	ret    

0000068d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 68d:	55                   	push   %ebp
 68e:	89 e5                	mov    %esp,%ebp
 690:	83 ec 18             	sub    $0x18,%esp
 693:	8b 45 0c             	mov    0xc(%ebp),%eax
 696:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 699:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6a0:	00 
 6a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6a4:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a8:	8b 45 08             	mov    0x8(%ebp),%eax
 6ab:	89 04 24             	mov    %eax,(%esp)
 6ae:	e8 2a ff ff ff       	call   5dd <write>
}
 6b3:	c9                   	leave  
 6b4:	c3                   	ret    

000006b5 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6b5:	55                   	push   %ebp
 6b6:	89 e5                	mov    %esp,%ebp
 6b8:	56                   	push   %esi
 6b9:	53                   	push   %ebx
 6ba:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6bd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6c4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6c8:	74 17                	je     6e1 <printint+0x2c>
 6ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6ce:	79 11                	jns    6e1 <printint+0x2c>
    neg = 1;
 6d0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 6da:	f7 d8                	neg    %eax
 6dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6df:	eb 06                	jmp    6e7 <printint+0x32>
  } else {
    x = xx;
 6e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 6e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6ee:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6f1:	8d 41 01             	lea    0x1(%ecx),%eax
 6f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6fd:	ba 00 00 00 00       	mov    $0x0,%edx
 702:	f7 f3                	div    %ebx
 704:	89 d0                	mov    %edx,%eax
 706:	0f b6 80 40 0e 00 00 	movzbl 0xe40(%eax),%eax
 70d:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 711:	8b 75 10             	mov    0x10(%ebp),%esi
 714:	8b 45 ec             	mov    -0x14(%ebp),%eax
 717:	ba 00 00 00 00       	mov    $0x0,%edx
 71c:	f7 f6                	div    %esi
 71e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 721:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 725:	75 c7                	jne    6ee <printint+0x39>
  if(neg)
 727:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 72b:	74 10                	je     73d <printint+0x88>
    buf[i++] = '-';
 72d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 730:	8d 50 01             	lea    0x1(%eax),%edx
 733:	89 55 f4             	mov    %edx,-0xc(%ebp)
 736:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 73b:	eb 1f                	jmp    75c <printint+0xa7>
 73d:	eb 1d                	jmp    75c <printint+0xa7>
    putc(fd, buf[i]);
 73f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 742:	8b 45 f4             	mov    -0xc(%ebp),%eax
 745:	01 d0                	add    %edx,%eax
 747:	0f b6 00             	movzbl (%eax),%eax
 74a:	0f be c0             	movsbl %al,%eax
 74d:	89 44 24 04          	mov    %eax,0x4(%esp)
 751:	8b 45 08             	mov    0x8(%ebp),%eax
 754:	89 04 24             	mov    %eax,(%esp)
 757:	e8 31 ff ff ff       	call   68d <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 75c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 760:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 764:	79 d9                	jns    73f <printint+0x8a>
    putc(fd, buf[i]);
}
 766:	83 c4 30             	add    $0x30,%esp
 769:	5b                   	pop    %ebx
 76a:	5e                   	pop    %esi
 76b:	5d                   	pop    %ebp
 76c:	c3                   	ret    

0000076d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 76d:	55                   	push   %ebp
 76e:	89 e5                	mov    %esp,%ebp
 770:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 773:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 77a:	8d 45 0c             	lea    0xc(%ebp),%eax
 77d:	83 c0 04             	add    $0x4,%eax
 780:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 783:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 78a:	e9 7c 01 00 00       	jmp    90b <printf+0x19e>
    c = fmt[i] & 0xff;
 78f:	8b 55 0c             	mov    0xc(%ebp),%edx
 792:	8b 45 f0             	mov    -0x10(%ebp),%eax
 795:	01 d0                	add    %edx,%eax
 797:	0f b6 00             	movzbl (%eax),%eax
 79a:	0f be c0             	movsbl %al,%eax
 79d:	25 ff 00 00 00       	and    $0xff,%eax
 7a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7a9:	75 2c                	jne    7d7 <printf+0x6a>
      if(c == '%'){
 7ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7af:	75 0c                	jne    7bd <printf+0x50>
        state = '%';
 7b1:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7b8:	e9 4a 01 00 00       	jmp    907 <printf+0x19a>
      } else {
        putc(fd, c);
 7bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7c0:	0f be c0             	movsbl %al,%eax
 7c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ca:	89 04 24             	mov    %eax,(%esp)
 7cd:	e8 bb fe ff ff       	call   68d <putc>
 7d2:	e9 30 01 00 00       	jmp    907 <printf+0x19a>
      }
    } else if(state == '%'){
 7d7:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7db:	0f 85 26 01 00 00    	jne    907 <printf+0x19a>
      if(c == 'd'){
 7e1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7e5:	75 2d                	jne    814 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ea:	8b 00                	mov    (%eax),%eax
 7ec:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7f3:	00 
 7f4:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7fb:	00 
 7fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 800:	8b 45 08             	mov    0x8(%ebp),%eax
 803:	89 04 24             	mov    %eax,(%esp)
 806:	e8 aa fe ff ff       	call   6b5 <printint>
        ap++;
 80b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 80f:	e9 ec 00 00 00       	jmp    900 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 814:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 818:	74 06                	je     820 <printf+0xb3>
 81a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 81e:	75 2d                	jne    84d <printf+0xe0>
        printint(fd, *ap, 16, 0);
 820:	8b 45 e8             	mov    -0x18(%ebp),%eax
 823:	8b 00                	mov    (%eax),%eax
 825:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 82c:	00 
 82d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 834:	00 
 835:	89 44 24 04          	mov    %eax,0x4(%esp)
 839:	8b 45 08             	mov    0x8(%ebp),%eax
 83c:	89 04 24             	mov    %eax,(%esp)
 83f:	e8 71 fe ff ff       	call   6b5 <printint>
        ap++;
 844:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 848:	e9 b3 00 00 00       	jmp    900 <printf+0x193>
      } else if(c == 's'){
 84d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 851:	75 45                	jne    898 <printf+0x12b>
        s = (char*)*ap;
 853:	8b 45 e8             	mov    -0x18(%ebp),%eax
 856:	8b 00                	mov    (%eax),%eax
 858:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 85b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 85f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 863:	75 09                	jne    86e <printf+0x101>
          s = "(null)";
 865:	c7 45 f4 72 0b 00 00 	movl   $0xb72,-0xc(%ebp)
        while(*s != 0){
 86c:	eb 1e                	jmp    88c <printf+0x11f>
 86e:	eb 1c                	jmp    88c <printf+0x11f>
          putc(fd, *s);
 870:	8b 45 f4             	mov    -0xc(%ebp),%eax
 873:	0f b6 00             	movzbl (%eax),%eax
 876:	0f be c0             	movsbl %al,%eax
 879:	89 44 24 04          	mov    %eax,0x4(%esp)
 87d:	8b 45 08             	mov    0x8(%ebp),%eax
 880:	89 04 24             	mov    %eax,(%esp)
 883:	e8 05 fe ff ff       	call   68d <putc>
          s++;
 888:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 88c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88f:	0f b6 00             	movzbl (%eax),%eax
 892:	84 c0                	test   %al,%al
 894:	75 da                	jne    870 <printf+0x103>
 896:	eb 68                	jmp    900 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 898:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 89c:	75 1d                	jne    8bb <printf+0x14e>
        putc(fd, *ap);
 89e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8a1:	8b 00                	mov    (%eax),%eax
 8a3:	0f be c0             	movsbl %al,%eax
 8a6:	89 44 24 04          	mov    %eax,0x4(%esp)
 8aa:	8b 45 08             	mov    0x8(%ebp),%eax
 8ad:	89 04 24             	mov    %eax,(%esp)
 8b0:	e8 d8 fd ff ff       	call   68d <putc>
        ap++;
 8b5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8b9:	eb 45                	jmp    900 <printf+0x193>
      } else if(c == '%'){
 8bb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8bf:	75 17                	jne    8d8 <printf+0x16b>
        putc(fd, c);
 8c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8c4:	0f be c0             	movsbl %al,%eax
 8c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 8cb:	8b 45 08             	mov    0x8(%ebp),%eax
 8ce:	89 04 24             	mov    %eax,(%esp)
 8d1:	e8 b7 fd ff ff       	call   68d <putc>
 8d6:	eb 28                	jmp    900 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8d8:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8df:	00 
 8e0:	8b 45 08             	mov    0x8(%ebp),%eax
 8e3:	89 04 24             	mov    %eax,(%esp)
 8e6:	e8 a2 fd ff ff       	call   68d <putc>
        putc(fd, c);
 8eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8ee:	0f be c0             	movsbl %al,%eax
 8f1:	89 44 24 04          	mov    %eax,0x4(%esp)
 8f5:	8b 45 08             	mov    0x8(%ebp),%eax
 8f8:	89 04 24             	mov    %eax,(%esp)
 8fb:	e8 8d fd ff ff       	call   68d <putc>
      }
      state = 0;
 900:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 907:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 90b:	8b 55 0c             	mov    0xc(%ebp),%edx
 90e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 911:	01 d0                	add    %edx,%eax
 913:	0f b6 00             	movzbl (%eax),%eax
 916:	84 c0                	test   %al,%al
 918:	0f 85 71 fe ff ff    	jne    78f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 91e:	c9                   	leave  
 91f:	c3                   	ret    

00000920 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 920:	55                   	push   %ebp
 921:	89 e5                	mov    %esp,%ebp
 923:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 926:	8b 45 08             	mov    0x8(%ebp),%eax
 929:	83 e8 08             	sub    $0x8,%eax
 92c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 92f:	a1 68 0e 00 00       	mov    0xe68,%eax
 934:	89 45 fc             	mov    %eax,-0x4(%ebp)
 937:	eb 24                	jmp    95d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 939:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93c:	8b 00                	mov    (%eax),%eax
 93e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 941:	77 12                	ja     955 <free+0x35>
 943:	8b 45 f8             	mov    -0x8(%ebp),%eax
 946:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 949:	77 24                	ja     96f <free+0x4f>
 94b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94e:	8b 00                	mov    (%eax),%eax
 950:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 953:	77 1a                	ja     96f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 955:	8b 45 fc             	mov    -0x4(%ebp),%eax
 958:	8b 00                	mov    (%eax),%eax
 95a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 95d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 960:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 963:	76 d4                	jbe    939 <free+0x19>
 965:	8b 45 fc             	mov    -0x4(%ebp),%eax
 968:	8b 00                	mov    (%eax),%eax
 96a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 96d:	76 ca                	jbe    939 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 96f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 972:	8b 40 04             	mov    0x4(%eax),%eax
 975:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 97c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97f:	01 c2                	add    %eax,%edx
 981:	8b 45 fc             	mov    -0x4(%ebp),%eax
 984:	8b 00                	mov    (%eax),%eax
 986:	39 c2                	cmp    %eax,%edx
 988:	75 24                	jne    9ae <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 98a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98d:	8b 50 04             	mov    0x4(%eax),%edx
 990:	8b 45 fc             	mov    -0x4(%ebp),%eax
 993:	8b 00                	mov    (%eax),%eax
 995:	8b 40 04             	mov    0x4(%eax),%eax
 998:	01 c2                	add    %eax,%edx
 99a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a3:	8b 00                	mov    (%eax),%eax
 9a5:	8b 10                	mov    (%eax),%edx
 9a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9aa:	89 10                	mov    %edx,(%eax)
 9ac:	eb 0a                	jmp    9b8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 9ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b1:	8b 10                	mov    (%eax),%edx
 9b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bb:	8b 40 04             	mov    0x4(%eax),%eax
 9be:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c8:	01 d0                	add    %edx,%eax
 9ca:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9cd:	75 20                	jne    9ef <free+0xcf>
    p->s.size += bp->s.size;
 9cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d2:	8b 50 04             	mov    0x4(%eax),%edx
 9d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d8:	8b 40 04             	mov    0x4(%eax),%eax
 9db:	01 c2                	add    %eax,%edx
 9dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e6:	8b 10                	mov    (%eax),%edx
 9e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9eb:	89 10                	mov    %edx,(%eax)
 9ed:	eb 08                	jmp    9f7 <free+0xd7>
  } else
    p->s.ptr = bp;
 9ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9f5:	89 10                	mov    %edx,(%eax)
  freep = p;
 9f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fa:	a3 68 0e 00 00       	mov    %eax,0xe68
}
 9ff:	c9                   	leave  
 a00:	c3                   	ret    

00000a01 <morecore>:

static Header*
morecore(uint nu)
{
 a01:	55                   	push   %ebp
 a02:	89 e5                	mov    %esp,%ebp
 a04:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a07:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a0e:	77 07                	ja     a17 <morecore+0x16>
    nu = 4096;
 a10:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a17:	8b 45 08             	mov    0x8(%ebp),%eax
 a1a:	c1 e0 03             	shl    $0x3,%eax
 a1d:	89 04 24             	mov    %eax,(%esp)
 a20:	e8 20 fc ff ff       	call   645 <sbrk>
 a25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a28:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a2c:	75 07                	jne    a35 <morecore+0x34>
    return 0;
 a2e:	b8 00 00 00 00       	mov    $0x0,%eax
 a33:	eb 22                	jmp    a57 <morecore+0x56>
  hp = (Header*)p;
 a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a3e:	8b 55 08             	mov    0x8(%ebp),%edx
 a41:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a47:	83 c0 08             	add    $0x8,%eax
 a4a:	89 04 24             	mov    %eax,(%esp)
 a4d:	e8 ce fe ff ff       	call   920 <free>
  return freep;
 a52:	a1 68 0e 00 00       	mov    0xe68,%eax
}
 a57:	c9                   	leave  
 a58:	c3                   	ret    

00000a59 <malloc>:

void*
malloc(uint nbytes)
{
 a59:	55                   	push   %ebp
 a5a:	89 e5                	mov    %esp,%ebp
 a5c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a5f:	8b 45 08             	mov    0x8(%ebp),%eax
 a62:	83 c0 07             	add    $0x7,%eax
 a65:	c1 e8 03             	shr    $0x3,%eax
 a68:	83 c0 01             	add    $0x1,%eax
 a6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a6e:	a1 68 0e 00 00       	mov    0xe68,%eax
 a73:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a76:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a7a:	75 23                	jne    a9f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a7c:	c7 45 f0 60 0e 00 00 	movl   $0xe60,-0x10(%ebp)
 a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a86:	a3 68 0e 00 00       	mov    %eax,0xe68
 a8b:	a1 68 0e 00 00       	mov    0xe68,%eax
 a90:	a3 60 0e 00 00       	mov    %eax,0xe60
    base.s.size = 0;
 a95:	c7 05 64 0e 00 00 00 	movl   $0x0,0xe64
 a9c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa2:	8b 00                	mov    (%eax),%eax
 aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aaa:	8b 40 04             	mov    0x4(%eax),%eax
 aad:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ab0:	72 4d                	jb     aff <malloc+0xa6>
      if(p->s.size == nunits)
 ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab5:	8b 40 04             	mov    0x4(%eax),%eax
 ab8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 abb:	75 0c                	jne    ac9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac0:	8b 10                	mov    (%eax),%edx
 ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac5:	89 10                	mov    %edx,(%eax)
 ac7:	eb 26                	jmp    aef <malloc+0x96>
      else {
        p->s.size -= nunits;
 ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acc:	8b 40 04             	mov    0x4(%eax),%eax
 acf:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ad2:	89 c2                	mov    %eax,%edx
 ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
 add:	8b 40 04             	mov    0x4(%eax),%eax
 ae0:	c1 e0 03             	shl    $0x3,%eax
 ae3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 aec:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
 af2:	a3 68 0e 00 00       	mov    %eax,0xe68
      return (void*)(p + 1);
 af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afa:	83 c0 08             	add    $0x8,%eax
 afd:	eb 38                	jmp    b37 <malloc+0xde>
    }
    if(p == freep)
 aff:	a1 68 0e 00 00       	mov    0xe68,%eax
 b04:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b07:	75 1b                	jne    b24 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 b09:	8b 45 ec             	mov    -0x14(%ebp),%eax
 b0c:	89 04 24             	mov    %eax,(%esp)
 b0f:	e8 ed fe ff ff       	call   a01 <morecore>
 b14:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b17:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b1b:	75 07                	jne    b24 <malloc+0xcb>
        return 0;
 b1d:	b8 00 00 00 00       	mov    $0x0,%eax
 b22:	eb 13                	jmp    b37 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b27:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b2d:	8b 00                	mov    (%eax),%eax
 b2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b32:	e9 70 ff ff ff       	jmp    aa7 <malloc+0x4e>
}
 b37:	c9                   	leave  
 b38:	c3                   	ret    
