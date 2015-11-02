
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 b1 33 10 80       	mov    $0x801033b1,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 94 80 10 	movl   $0x80108094,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 2c 4a 00 00       	call   80104a7a <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 db 10 80 84 	movl   $0x8010db84,0x8010db90
80100055:	db 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 db 10 80 84 	movl   $0x8010db84,0x8010db94
8010005f:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 db 10 80       	mov    0x8010db94,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 db 10 80       	mov    %eax,0x8010db94

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000bd:	e8 d9 49 00 00       	call   80104a9b <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 db 10 80       	mov    0x8010db94,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100104:	e8 f4 49 00 00       	call   80104afd <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 a4 46 00 00       	call   801047c8 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 db 10 80       	mov    0x8010db90,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017c:	e8 7c 49 00 00       	call   80104afd <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 9b 80 10 80 	movl   $0x8010809b,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 b5 25 00 00       	call   8010278d <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 ac 80 10 80 	movl   $0x801080ac,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 78 25 00 00       	call   8010278d <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 b3 80 10 80 	movl   $0x801080b3,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 5a 48 00 00       	call   80104a9b <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 db 10 80       	mov    0x8010db94,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 db 10 80       	mov    %eax,0x8010db94

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 02 46 00 00       	call   801048a4 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 4f 48 00 00       	call   80104afd <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 c1 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003bb:	e8 db 46 00 00       	call   80104a9b <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 ba 80 10 80 	movl   $0x801080ba,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 5a 03 00 00       	call   80100750 <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec c3 80 10 80 	movl   $0x801080c3,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 84 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100533:	e8 c5 45 00 00       	call   80104afd <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 ca 80 10 80 	movl   $0x801080ca,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 d9 80 10 80 	movl   $0x801080d9,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 b8 45 00 00       	call   80104b4c <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 db 80 10 80 	movl   $0x801080db,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x11c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 90 10 80       	mov    0x80109000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 90 10 80       	mov    0x80109000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 07 47 00 00       	call   80104dbe <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006c6:	a1 00 90 10 80       	mov    0x80109000,%eax
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 c8                	add    %ecx,%eax
801006d2:	89 54 24 08          	mov    %edx,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 04 24             	mov    %eax,(%esp)
801006e1:	e8 09 46 00 00       	call   80104cef <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 d3 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 ba fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 a6 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 90 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 90 10 80       	mov    0x80109000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 87 fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 5c 5f 00 00       	call   801066d7 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 50 5f 00 00       	call   801066d7 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 44 5f 00 00       	call   801066d7 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 37 5f 00 00       	call   801066d7 <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 1f fe ff ff       	call   801005ca <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
801007ba:	e8 dc 42 00 00       	call   80104a9b <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 37 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 64                	je     8010083a <consoleintr+0x8d>
801007d6:	e9 91 00 00 00       	jmp    8010086c <consoleintr+0xbf>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 55                	je     8010083a <consoleintr+0x8d>
801007e5:	e9 82 00 00 00       	jmp    8010086c <consoleintr+0xbf>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 5b 41 00 00       	call   8010494a <procdump>
      break;
801007ef:	e9 07 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100816:	a1 58 de 10 80       	mov    0x8010de58,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	74 16                	je     80100835 <consoleintr+0x88>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100824:	83 e8 01             	sub    $0x1,%eax
80100827:	83 e0 7f             	and    $0x7f,%eax
8010082a:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100831:	3c 0a                	cmp    $0xa,%al
80100833:	75 bf                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100835:	e9 c1 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083a:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100840:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100845:	39 c2                	cmp    %eax,%edx
80100847:	74 1e                	je     80100867 <consoleintr+0xba>
        input.e--;
80100849:	a1 5c de 10 80       	mov    0x8010de5c,%eax
8010084e:	83 e8 01             	sub    $0x1,%eax
80100851:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
80100856:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010085d:	e8 ee fe ff ff       	call   80100750 <consputc>
      }
      break;
80100862:	e9 94 00 00 00       	jmp    801008fb <consoleintr+0x14e>
80100867:	e9 8f 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100870:	0f 84 84 00 00 00    	je     801008fa <consoleintr+0x14d>
80100876:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010087c:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100881:	29 c2                	sub    %eax,%edx
80100883:	89 d0                	mov    %edx,%eax
80100885:	83 f8 7f             	cmp    $0x7f,%eax
80100888:	77 70                	ja     801008fa <consoleintr+0x14d>
        c = (c == '\r') ? '\n' : c;
8010088a:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
8010088e:	74 05                	je     80100895 <consoleintr+0xe8>
80100890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100893:	eb 05                	jmp    8010089a <consoleintr+0xed>
80100895:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010089d:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008a2:	8d 50 01             	lea    0x1(%eax),%edx
801008a5:	89 15 5c de 10 80    	mov    %edx,0x8010de5c
801008ab:	83 e0 7f             	and    $0x7f,%eax
801008ae:	89 c2                	mov    %eax,%edx
801008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008b3:	88 82 d4 dd 10 80    	mov    %al,-0x7fef222c(%edx)
        consputc(c);
801008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bc:	89 04 24             	mov    %eax,(%esp)
801008bf:	e8 8c fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c4:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008c8:	74 18                	je     801008e2 <consoleintr+0x135>
801008ca:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008ce:	74 12                	je     801008e2 <consoleintr+0x135>
801008d0:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008d5:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
801008db:	83 ea 80             	sub    $0xffffff80,%edx
801008de:	39 d0                	cmp    %edx,%eax
801008e0:	75 18                	jne    801008fa <consoleintr+0x14d>
          input.w = input.e;
801008e2:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008e7:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
801008ec:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
801008f3:	e8 ac 3f 00 00       	call   801048a4 <wakeup>
        }
      }
      break;
801008f8:	eb 00                	jmp    801008fa <consoleintr+0x14d>
801008fa:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
801008fb:	8b 45 08             	mov    0x8(%ebp),%eax
801008fe:	ff d0                	call   *%eax
80100900:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100903:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100907:	0f 89 b7 fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010090d:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100914:	e8 e4 41 00 00       	call   80104afd <release>
}
80100919:	c9                   	leave  
8010091a:	c3                   	ret    

8010091b <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010091b:	55                   	push   %ebp
8010091c:	89 e5                	mov    %esp,%ebp
8010091e:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100921:	8b 45 08             	mov    0x8(%ebp),%eax
80100924:	89 04 24             	mov    %eax,(%esp)
80100927:	e8 69 10 00 00       	call   80101995 <iunlock>
  target = n;
8010092c:	8b 45 10             	mov    0x10(%ebp),%eax
8010092f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100932:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100939:	e8 5d 41 00 00       	call   80104a9b <acquire>
  while(n > 0){
8010093e:	e9 aa 00 00 00       	jmp    801009ed <consoleread+0xd2>
    while(input.r == input.w){
80100943:	eb 42                	jmp    80100987 <consoleread+0x6c>
      if(proc->killed){
80100945:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010094b:	8b 40 24             	mov    0x24(%eax),%eax
8010094e:	85 c0                	test   %eax,%eax
80100950:	74 21                	je     80100973 <consoleread+0x58>
        release(&input.lock);
80100952:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100959:	e8 9f 41 00 00       	call   80104afd <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 de 0e 00 00       	call   80101847 <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100982:	e8 41 3e 00 00       	call   801047c8 <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100987:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
8010098d:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100992:	39 c2                	cmp    %eax,%edx
80100994:	74 af                	je     80100945 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100996:	a1 54 de 10 80       	mov    0x8010de54,%eax
8010099b:	8d 50 01             	lea    0x1(%eax),%edx
8010099e:	89 15 54 de 10 80    	mov    %edx,0x8010de54
801009a4:	83 e0 7f             	and    $0x7f,%eax
801009a7:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
801009ae:	0f be c0             	movsbl %al,%eax
801009b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009b4:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009b8:	75 19                	jne    801009d3 <consoleread+0xb8>
      if(n < target){
801009ba:	8b 45 10             	mov    0x10(%ebp),%eax
801009bd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009c0:	73 0f                	jae    801009d1 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009c2:	a1 54 de 10 80       	mov    0x8010de54,%eax
801009c7:	83 e8 01             	sub    $0x1,%eax
801009ca:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
801009cf:	eb 26                	jmp    801009f7 <consoleread+0xdc>
801009d1:	eb 24                	jmp    801009f7 <consoleread+0xdc>
    }
    *dst++ = c;
801009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801009d6:	8d 50 01             	lea    0x1(%eax),%edx
801009d9:	89 55 0c             	mov    %edx,0xc(%ebp)
801009dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009df:	88 10                	mov    %dl,(%eax)
    --n;
801009e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009e5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009e9:	75 02                	jne    801009ed <consoleread+0xd2>
      break;
801009eb:	eb 0a                	jmp    801009f7 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f1:	0f 8f 4c ff ff ff    	jg     80100943 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
801009f7:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
801009fe:	e8 fa 40 00 00       	call   80104afd <release>
  ilock(ip);
80100a03:	8b 45 08             	mov    0x8(%ebp),%eax
80100a06:	89 04 24             	mov    %eax,(%esp)
80100a09:	e8 39 0e 00 00       	call   80101847 <ilock>

  return target - n;
80100a0e:	8b 45 10             	mov    0x10(%ebp),%eax
80100a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a14:	29 c2                	sub    %eax,%edx
80100a16:	89 d0                	mov    %edx,%eax
}
80100a18:	c9                   	leave  
80100a19:	c3                   	ret    

80100a1a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a1a:	55                   	push   %ebp
80100a1b:	89 e5                	mov    %esp,%ebp
80100a1d:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	89 04 24             	mov    %eax,(%esp)
80100a26:	e8 6a 0f 00 00       	call   80101995 <iunlock>
  acquire(&cons.lock);
80100a2b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a32:	e8 64 40 00 00       	call   80104a9b <acquire>
  for(i = 0; i < n; i++)
80100a37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a3e:	eb 1d                	jmp    80100a5d <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a46:	01 d0                	add    %edx,%eax
80100a48:	0f b6 00             	movzbl (%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	0f b6 c0             	movzbl %al,%eax
80100a51:	89 04 24             	mov    %eax,(%esp)
80100a54:	e8 f7 fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a60:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a63:	7c db                	jl     80100a40 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a65:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a6c:	e8 8c 40 00 00       	call   80104afd <release>
  ilock(ip);
80100a71:	8b 45 08             	mov    0x8(%ebp),%eax
80100a74:	89 04 24             	mov    %eax,(%esp)
80100a77:	e8 cb 0d 00 00       	call   80101847 <ilock>

  return n;
80100a7c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a7f:	c9                   	leave  
80100a80:	c3                   	ret    

80100a81 <consoleinit>:

void
consoleinit(void)
{
80100a81:	55                   	push   %ebp
80100a82:	89 e5                	mov    %esp,%ebp
80100a84:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a87:	c7 44 24 04 df 80 10 	movl   $0x801080df,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a96:	e8 df 3f 00 00       	call   80104a7a <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 e7 80 10 	movl   $0x801080e7,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100aaa:	e8 cb 3f 00 00       	call   80104a7a <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aaf:	c7 05 0c e8 10 80 1a 	movl   $0x80100a1a,0x8010e80c
80100ab6:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ab9:	c7 05 08 e8 10 80 1b 	movl   $0x8010091b,0x8010e808
80100ac0:	09 10 80 
  cons.locking = 1;
80100ac3:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100aca:	00 00 00 

  picenable(IRQ_KBD);
80100acd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ad4:	e8 75 2f 00 00       	call   80103a4e <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100ae0:	00 
80100ae1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae8:	e8 5c 1e 00 00       	call   80102949 <ioapicenable>
}
80100aed:	c9                   	leave  
80100aee:	c3                   	ret    

80100aef <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100aef:	55                   	push   %ebp
80100af0:	89 e5                	mov    %esp,%ebp
80100af2:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100af8:	8b 45 08             	mov    0x8(%ebp),%eax
80100afb:	89 04 24             	mov    %eax,(%esp)
80100afe:	e8 ef 18 00 00       	call   801023f2 <namei>
80100b03:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b06:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b0a:	75 0a                	jne    80100b16 <exec+0x27>
    return -1;
80100b0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b11:	e9 de 03 00 00       	jmp    80100ef4 <exec+0x405>
  ilock(ip);
80100b16:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b19:	89 04 24             	mov    %eax,(%esp)
80100b1c:	e8 26 0d 00 00       	call   80101847 <ilock>
  pgdir = 0;
80100b21:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b28:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b2f:	00 
80100b30:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b37:	00 
80100b38:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b42:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b45:	89 04 24             	mov    %eax,(%esp)
80100b48:	e8 07 12 00 00       	call   80101d54 <readi>
80100b4d:	83 f8 33             	cmp    $0x33,%eax
80100b50:	77 05                	ja     80100b57 <exec+0x68>
    goto bad;
80100b52:	e9 76 03 00 00       	jmp    80100ecd <exec+0x3de>
  if(elf.magic != ELF_MAGIC)
80100b57:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b5d:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b62:	74 05                	je     80100b69 <exec+0x7a>
    goto bad;
80100b64:	e9 64 03 00 00       	jmp    80100ecd <exec+0x3de>

  if((pgdir = setupkvm()) == 0)
80100b69:	e8 ba 6c 00 00       	call   80107828 <setupkvm>
80100b6e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b71:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b75:	75 05                	jne    80100b7c <exec+0x8d>
    goto bad;
80100b77:	e9 51 03 00 00       	jmp    80100ecd <exec+0x3de>

  // Load program into memory.
  sz = 0;
80100b7c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b83:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b8a:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100b90:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100b93:	e9 cb 00 00 00       	jmp    80100c63 <exec+0x174>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100b98:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b9b:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100ba2:	00 
80100ba3:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ba7:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bad:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bb4:	89 04 24             	mov    %eax,(%esp)
80100bb7:	e8 98 11 00 00       	call   80101d54 <readi>
80100bbc:	83 f8 20             	cmp    $0x20,%eax
80100bbf:	74 05                	je     80100bc6 <exec+0xd7>
      goto bad;
80100bc1:	e9 07 03 00 00       	jmp    80100ecd <exec+0x3de>
    if(ph.type != ELF_PROG_LOAD)
80100bc6:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bcc:	83 f8 01             	cmp    $0x1,%eax
80100bcf:	74 05                	je     80100bd6 <exec+0xe7>
      continue;
80100bd1:	e9 80 00 00 00       	jmp    80100c56 <exec+0x167>
    if(ph.memsz < ph.filesz)
80100bd6:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100bdc:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100be2:	39 c2                	cmp    %eax,%edx
80100be4:	73 05                	jae    80100beb <exec+0xfc>
      goto bad;
80100be6:	e9 e2 02 00 00       	jmp    80100ecd <exec+0x3de>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100beb:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bf1:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100bf7:	01 d0                	add    %edx,%eax
80100bf9:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c00:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c07:	89 04 24             	mov    %eax,(%esp)
80100c0a:	e8 e7 6f 00 00       	call   80107bf6 <allocuvm>
80100c0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c12:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c16:	75 05                	jne    80100c1d <exec+0x12e>
      goto bad;
80100c18:	e9 b0 02 00 00       	jmp    80100ecd <exec+0x3de>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c1d:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c23:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c29:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c2f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c33:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c37:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c3a:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c42:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c45:	89 04 24             	mov    %eax,(%esp)
80100c48:	e8 be 6e 00 00       	call   80107b0b <loaduvm>
80100c4d:	85 c0                	test   %eax,%eax
80100c4f:	79 05                	jns    80100c56 <exec+0x167>
      goto bad;
80100c51:	e9 77 02 00 00       	jmp    80100ecd <exec+0x3de>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c56:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c5d:	83 c0 20             	add    $0x20,%eax
80100c60:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c63:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c6a:	0f b7 c0             	movzwl %ax,%eax
80100c6d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c70:	0f 8f 22 ff ff ff    	jg     80100b98 <exec+0xa9>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c76:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c79:	89 04 24             	mov    %eax,(%esp)
80100c7c:	e8 4a 0e 00 00       	call   80101acb <iunlockput>
  ip = 0;
80100c81:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c88:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c8b:	05 ff 0f 00 00       	add    $0xfff,%eax
80100c90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100c95:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c9b:	05 00 20 00 00       	add    $0x2000,%eax
80100ca0:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ca4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cae:	89 04 24             	mov    %eax,(%esp)
80100cb1:	e8 40 6f 00 00       	call   80107bf6 <allocuvm>
80100cb6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cb9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cbd:	75 05                	jne    80100cc4 <exec+0x1d5>
    goto bad;
80100cbf:	e9 09 02 00 00       	jmp    80100ecd <exec+0x3de>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc7:	2d 00 20 00 00       	sub    $0x2000,%eax
80100ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cd0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cd3:	89 04 24             	mov    %eax,(%esp)
80100cd6:	e8 4b 71 00 00       	call   80107e26 <clearpteu>
  sp = sz;
80100cdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cde:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ce1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100ce8:	e9 9a 00 00 00       	jmp    80100d87 <exec+0x298>
    if(argc >= MAXARG)
80100ced:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100cf1:	76 05                	jbe    80100cf8 <exec+0x209>
      goto bad;
80100cf3:	e9 d5 01 00 00       	jmp    80100ecd <exec+0x3de>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100cf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100cfb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d05:	01 d0                	add    %edx,%eax
80100d07:	8b 00                	mov    (%eax),%eax
80100d09:	89 04 24             	mov    %eax,(%esp)
80100d0c:	e8 48 42 00 00       	call   80104f59 <strlen>
80100d11:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d14:	29 c2                	sub    %eax,%edx
80100d16:	89 d0                	mov    %edx,%eax
80100d18:	83 e8 01             	sub    $0x1,%eax
80100d1b:	83 e0 fc             	and    $0xfffffffc,%eax
80100d1e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d2e:	01 d0                	add    %edx,%eax
80100d30:	8b 00                	mov    (%eax),%eax
80100d32:	89 04 24             	mov    %eax,(%esp)
80100d35:	e8 1f 42 00 00       	call   80104f59 <strlen>
80100d3a:	83 c0 01             	add    $0x1,%eax
80100d3d:	89 c2                	mov    %eax,%edx
80100d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d42:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d4c:	01 c8                	add    %ecx,%eax
80100d4e:	8b 00                	mov    (%eax),%eax
80100d50:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d54:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d58:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d5b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d5f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d62:	89 04 24             	mov    %eax,(%esp)
80100d65:	e8 81 72 00 00       	call   80107feb <copyout>
80100d6a:	85 c0                	test   %eax,%eax
80100d6c:	79 05                	jns    80100d73 <exec+0x284>
      goto bad;
80100d6e:	e9 5a 01 00 00       	jmp    80100ecd <exec+0x3de>
    ustack[3+argc] = sp;
80100d73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d76:	8d 50 03             	lea    0x3(%eax),%edx
80100d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d7c:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d83:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d94:	01 d0                	add    %edx,%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	85 c0                	test   %eax,%eax
80100d9a:	0f 85 4d ff ff ff    	jne    80100ced <exec+0x1fe>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100da0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da3:	83 c0 03             	add    $0x3,%eax
80100da6:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100dad:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100db1:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100db8:	ff ff ff 
  ustack[1] = argc;
80100dbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dbe:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc7:	83 c0 01             	add    $0x1,%eax
80100dca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd4:	29 d0                	sub    %edx,%eax
80100dd6:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100ddc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ddf:	83 c0 04             	add    $0x4,%eax
80100de2:	c1 e0 02             	shl    $0x2,%eax
80100de5:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100de8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100deb:	83 c0 04             	add    $0x4,%eax
80100dee:	c1 e0 02             	shl    $0x2,%eax
80100df1:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100df5:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100dfb:	89 44 24 08          	mov    %eax,0x8(%esp)
80100dff:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e02:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e09:	89 04 24             	mov    %eax,(%esp)
80100e0c:	e8 da 71 00 00       	call   80107feb <copyout>
80100e11:	85 c0                	test   %eax,%eax
80100e13:	79 05                	jns    80100e1a <exec+0x32b>
    goto bad;
80100e15:	e9 b3 00 00 00       	jmp    80100ecd <exec+0x3de>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80100e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e23:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e26:	eb 17                	jmp    80100e3f <exec+0x350>
    if(*s == '/')
80100e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e2b:	0f b6 00             	movzbl (%eax),%eax
80100e2e:	3c 2f                	cmp    $0x2f,%al
80100e30:	75 09                	jne    80100e3b <exec+0x34c>
      last = s+1;
80100e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e35:	83 c0 01             	add    $0x1,%eax
80100e38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e3b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e42:	0f b6 00             	movzbl (%eax),%eax
80100e45:	84 c0                	test   %al,%al
80100e47:	75 df                	jne    80100e28 <exec+0x339>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e4f:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e52:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e59:	00 
80100e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e61:	89 14 24             	mov    %edx,(%esp)
80100e64:	e8 a6 40 00 00       	call   80104f0f <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e6f:	8b 40 04             	mov    0x4(%eax),%eax
80100e72:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e7e:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e87:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e8a:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e92:	8b 40 18             	mov    0x18(%eax),%eax
80100e95:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100e9b:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100e9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea4:	8b 40 18             	mov    0x18(%eax),%eax
80100ea7:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eaa:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ead:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb3:	89 04 24             	mov    %eax,(%esp)
80100eb6:	e8 5e 6a 00 00       	call   80107919 <switchuvm>
  freevm(oldpgdir);
80100ebb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ebe:	89 04 24             	mov    %eax,(%esp)
80100ec1:	e8 c6 6e 00 00       	call   80107d8c <freevm>
  return 0;
80100ec6:	b8 00 00 00 00       	mov    $0x0,%eax
80100ecb:	eb 27                	jmp    80100ef4 <exec+0x405>

 bad:
  if(pgdir)
80100ecd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ed1:	74 0b                	je     80100ede <exec+0x3ef>
    freevm(pgdir);
80100ed3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ed6:	89 04 24             	mov    %eax,(%esp)
80100ed9:	e8 ae 6e 00 00       	call   80107d8c <freevm>
  if(ip)
80100ede:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ee2:	74 0b                	je     80100eef <exec+0x400>
    iunlockput(ip);
80100ee4:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ee7:	89 04 24             	mov    %eax,(%esp)
80100eea:	e8 dc 0b 00 00       	call   80101acb <iunlockput>
  return -1;
80100eef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100ef4:	c9                   	leave  
80100ef5:	c3                   	ret    

80100ef6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100ef6:	55                   	push   %ebp
80100ef7:	89 e5                	mov    %esp,%ebp
80100ef9:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100efc:	c7 44 24 04 ed 80 10 	movl   $0x801080ed,0x4(%esp)
80100f03:	80 
80100f04:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f0b:	e8 6a 3b 00 00       	call   80104a7a <initlock>
}
80100f10:	c9                   	leave  
80100f11:	c3                   	ret    

80100f12 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f12:	55                   	push   %ebp
80100f13:	89 e5                	mov    %esp,%ebp
80100f15:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f18:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f1f:	e8 77 3b 00 00       	call   80104a9b <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f24:	c7 45 f4 94 de 10 80 	movl   $0x8010de94,-0xc(%ebp)
80100f2b:	eb 29                	jmp    80100f56 <filealloc+0x44>
    if(f->ref == 0){
80100f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f30:	8b 40 04             	mov    0x4(%eax),%eax
80100f33:	85 c0                	test   %eax,%eax
80100f35:	75 1b                	jne    80100f52 <filealloc+0x40>
      f->ref = 1;
80100f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f3a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f41:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f48:	e8 b0 3b 00 00       	call   80104afd <release>
      return f;
80100f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f50:	eb 1e                	jmp    80100f70 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f52:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f56:	81 7d f4 f4 e7 10 80 	cmpl   $0x8010e7f4,-0xc(%ebp)
80100f5d:	72 ce                	jb     80100f2d <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f5f:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f66:	e8 92 3b 00 00       	call   80104afd <release>
  return 0;
80100f6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f70:	c9                   	leave  
80100f71:	c3                   	ret    

80100f72 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f72:	55                   	push   %ebp
80100f73:	89 e5                	mov    %esp,%ebp
80100f75:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f78:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f7f:	e8 17 3b 00 00       	call   80104a9b <acquire>
  if(f->ref < 1)
80100f84:	8b 45 08             	mov    0x8(%ebp),%eax
80100f87:	8b 40 04             	mov    0x4(%eax),%eax
80100f8a:	85 c0                	test   %eax,%eax
80100f8c:	7f 0c                	jg     80100f9a <filedup+0x28>
    panic("filedup");
80100f8e:	c7 04 24 f4 80 10 80 	movl   $0x801080f4,(%esp)
80100f95:	e8 a0 f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9d:	8b 40 04             	mov    0x4(%eax),%eax
80100fa0:	8d 50 01             	lea    0x1(%eax),%edx
80100fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa6:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fa9:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100fb0:	e8 48 3b 00 00       	call   80104afd <release>
  return f;
80100fb5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fb8:	c9                   	leave  
80100fb9:	c3                   	ret    

80100fba <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fba:	55                   	push   %ebp
80100fbb:	89 e5                	mov    %esp,%ebp
80100fbd:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fc0:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100fc7:	e8 cf 3a 00 00       	call   80104a9b <acquire>
  if(f->ref < 1)
80100fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80100fcf:	8b 40 04             	mov    0x4(%eax),%eax
80100fd2:	85 c0                	test   %eax,%eax
80100fd4:	7f 0c                	jg     80100fe2 <fileclose+0x28>
    panic("fileclose");
80100fd6:	c7 04 24 fc 80 10 80 	movl   $0x801080fc,(%esp)
80100fdd:	e8 58 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80100fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe5:	8b 40 04             	mov    0x4(%eax),%eax
80100fe8:	8d 50 ff             	lea    -0x1(%eax),%edx
80100feb:	8b 45 08             	mov    0x8(%ebp),%eax
80100fee:	89 50 04             	mov    %edx,0x4(%eax)
80100ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff4:	8b 40 04             	mov    0x4(%eax),%eax
80100ff7:	85 c0                	test   %eax,%eax
80100ff9:	7e 11                	jle    8010100c <fileclose+0x52>
    release(&ftable.lock);
80100ffb:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80101002:	e8 f6 3a 00 00       	call   80104afd <release>
80101007:	e9 82 00 00 00       	jmp    8010108e <fileclose+0xd4>
    return;
  }
  ff = *f;
8010100c:	8b 45 08             	mov    0x8(%ebp),%eax
8010100f:	8b 10                	mov    (%eax),%edx
80101011:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101014:	8b 50 04             	mov    0x4(%eax),%edx
80101017:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010101a:	8b 50 08             	mov    0x8(%eax),%edx
8010101d:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101020:	8b 50 0c             	mov    0xc(%eax),%edx
80101023:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101026:	8b 50 10             	mov    0x10(%eax),%edx
80101029:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010102c:	8b 40 14             	mov    0x14(%eax),%eax
8010102f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101032:	8b 45 08             	mov    0x8(%ebp),%eax
80101035:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010103c:	8b 45 08             	mov    0x8(%ebp),%eax
8010103f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101045:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
8010104c:	e8 ac 3a 00 00       	call   80104afd <release>
  
  if(ff.type == FD_PIPE)
80101051:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101054:	83 f8 01             	cmp    $0x1,%eax
80101057:	75 18                	jne    80101071 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101059:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010105d:	0f be d0             	movsbl %al,%edx
80101060:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101063:	89 54 24 04          	mov    %edx,0x4(%esp)
80101067:	89 04 24             	mov    %eax,(%esp)
8010106a:	e8 8f 2c 00 00       	call   80103cfe <pipeclose>
8010106f:	eb 1d                	jmp    8010108e <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101071:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101074:	83 f8 02             	cmp    $0x2,%eax
80101077:	75 15                	jne    8010108e <fileclose+0xd4>
    begin_trans();
80101079:	e8 53 21 00 00       	call   801031d1 <begin_trans>
    iput(ff.ip);
8010107e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101081:	89 04 24             	mov    %eax,(%esp)
80101084:	e8 71 09 00 00       	call   801019fa <iput>
    commit_trans();
80101089:	e8 8c 21 00 00       	call   8010321a <commit_trans>
  }
}
8010108e:	c9                   	leave  
8010108f:	c3                   	ret    

80101090 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101090:	55                   	push   %ebp
80101091:	89 e5                	mov    %esp,%ebp
80101093:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101096:	8b 45 08             	mov    0x8(%ebp),%eax
80101099:	8b 00                	mov    (%eax),%eax
8010109b:	83 f8 02             	cmp    $0x2,%eax
8010109e:	75 38                	jne    801010d8 <filestat+0x48>
    ilock(f->ip);
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
801010a3:	8b 40 10             	mov    0x10(%eax),%eax
801010a6:	89 04 24             	mov    %eax,(%esp)
801010a9:	e8 99 07 00 00       	call   80101847 <ilock>
    stati(f->ip, st);
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 10             	mov    0x10(%eax),%eax
801010b4:	8b 55 0c             	mov    0xc(%ebp),%edx
801010b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801010bb:	89 04 24             	mov    %eax,(%esp)
801010be:	e8 4c 0c 00 00       	call   80101d0f <stati>
    iunlock(f->ip);
801010c3:	8b 45 08             	mov    0x8(%ebp),%eax
801010c6:	8b 40 10             	mov    0x10(%eax),%eax
801010c9:	89 04 24             	mov    %eax,(%esp)
801010cc:	e8 c4 08 00 00       	call   80101995 <iunlock>
    return 0;
801010d1:	b8 00 00 00 00       	mov    $0x0,%eax
801010d6:	eb 05                	jmp    801010dd <filestat+0x4d>
  }
  return -1;
801010d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010dd:	c9                   	leave  
801010de:	c3                   	ret    

801010df <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010df:	55                   	push   %ebp
801010e0:	89 e5                	mov    %esp,%ebp
801010e2:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010e5:	8b 45 08             	mov    0x8(%ebp),%eax
801010e8:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801010ec:	84 c0                	test   %al,%al
801010ee:	75 0a                	jne    801010fa <fileread+0x1b>
    return -1;
801010f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801010f5:	e9 9f 00 00 00       	jmp    80101199 <fileread+0xba>
  if(f->type == FD_PIPE)
801010fa:	8b 45 08             	mov    0x8(%ebp),%eax
801010fd:	8b 00                	mov    (%eax),%eax
801010ff:	83 f8 01             	cmp    $0x1,%eax
80101102:	75 1e                	jne    80101122 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101104:	8b 45 08             	mov    0x8(%ebp),%eax
80101107:	8b 40 0c             	mov    0xc(%eax),%eax
8010110a:	8b 55 10             	mov    0x10(%ebp),%edx
8010110d:	89 54 24 08          	mov    %edx,0x8(%esp)
80101111:	8b 55 0c             	mov    0xc(%ebp),%edx
80101114:	89 54 24 04          	mov    %edx,0x4(%esp)
80101118:	89 04 24             	mov    %eax,(%esp)
8010111b:	e8 5f 2d 00 00       	call   80103e7f <piperead>
80101120:	eb 77                	jmp    80101199 <fileread+0xba>
  if(f->type == FD_INODE){
80101122:	8b 45 08             	mov    0x8(%ebp),%eax
80101125:	8b 00                	mov    (%eax),%eax
80101127:	83 f8 02             	cmp    $0x2,%eax
8010112a:	75 61                	jne    8010118d <fileread+0xae>
    ilock(f->ip);
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	8b 40 10             	mov    0x10(%eax),%eax
80101132:	89 04 24             	mov    %eax,(%esp)
80101135:	e8 0d 07 00 00       	call   80101847 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010113a:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010113d:	8b 45 08             	mov    0x8(%ebp),%eax
80101140:	8b 50 14             	mov    0x14(%eax),%edx
80101143:	8b 45 08             	mov    0x8(%ebp),%eax
80101146:	8b 40 10             	mov    0x10(%eax),%eax
80101149:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010114d:	89 54 24 08          	mov    %edx,0x8(%esp)
80101151:	8b 55 0c             	mov    0xc(%ebp),%edx
80101154:	89 54 24 04          	mov    %edx,0x4(%esp)
80101158:	89 04 24             	mov    %eax,(%esp)
8010115b:	e8 f4 0b 00 00       	call   80101d54 <readi>
80101160:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101163:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101167:	7e 11                	jle    8010117a <fileread+0x9b>
      f->off += r;
80101169:	8b 45 08             	mov    0x8(%ebp),%eax
8010116c:	8b 50 14             	mov    0x14(%eax),%edx
8010116f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101172:	01 c2                	add    %eax,%edx
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010117a:	8b 45 08             	mov    0x8(%ebp),%eax
8010117d:	8b 40 10             	mov    0x10(%eax),%eax
80101180:	89 04 24             	mov    %eax,(%esp)
80101183:	e8 0d 08 00 00       	call   80101995 <iunlock>
    return r;
80101188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010118b:	eb 0c                	jmp    80101199 <fileread+0xba>
  }
  panic("fileread");
8010118d:	c7 04 24 06 81 10 80 	movl   $0x80108106,(%esp)
80101194:	e8 a1 f3 ff ff       	call   8010053a <panic>
}
80101199:	c9                   	leave  
8010119a:	c3                   	ret    

8010119b <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010119b:	55                   	push   %ebp
8010119c:	89 e5                	mov    %esp,%ebp
8010119e:	53                   	push   %ebx
8010119f:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011a2:	8b 45 08             	mov    0x8(%ebp),%eax
801011a5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011a9:	84 c0                	test   %al,%al
801011ab:	75 0a                	jne    801011b7 <filewrite+0x1c>
    return -1;
801011ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011b2:	e9 20 01 00 00       	jmp    801012d7 <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011b7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ba:	8b 00                	mov    (%eax),%eax
801011bc:	83 f8 01             	cmp    $0x1,%eax
801011bf:	75 21                	jne    801011e2 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011c1:	8b 45 08             	mov    0x8(%ebp),%eax
801011c4:	8b 40 0c             	mov    0xc(%eax),%eax
801011c7:	8b 55 10             	mov    0x10(%ebp),%edx
801011ca:	89 54 24 08          	mov    %edx,0x8(%esp)
801011ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801011d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801011d5:	89 04 24             	mov    %eax,(%esp)
801011d8:	e8 b3 2b 00 00       	call   80103d90 <pipewrite>
801011dd:	e9 f5 00 00 00       	jmp    801012d7 <filewrite+0x13c>
  if(f->type == FD_INODE){
801011e2:	8b 45 08             	mov    0x8(%ebp),%eax
801011e5:	8b 00                	mov    (%eax),%eax
801011e7:	83 f8 02             	cmp    $0x2,%eax
801011ea:	0f 85 db 00 00 00    	jne    801012cb <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801011f0:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801011f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801011fe:	e9 a8 00 00 00       	jmp    801012ab <filewrite+0x110>
      int n1 = n - i;
80101203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101206:	8b 55 10             	mov    0x10(%ebp),%edx
80101209:	29 c2                	sub    %eax,%edx
8010120b:	89 d0                	mov    %edx,%eax
8010120d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101210:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101213:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101216:	7e 06                	jle    8010121e <filewrite+0x83>
        n1 = max;
80101218:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010121b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010121e:	e8 ae 1f 00 00       	call   801031d1 <begin_trans>
      ilock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	89 04 24             	mov    %eax,(%esp)
8010122c:	e8 16 06 00 00       	call   80101847 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101231:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101234:	8b 45 08             	mov    0x8(%ebp),%eax
80101237:	8b 50 14             	mov    0x14(%eax),%edx
8010123a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010123d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101240:	01 c3                	add    %eax,%ebx
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 40 10             	mov    0x10(%eax),%eax
80101248:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010124c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101250:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101254:	89 04 24             	mov    %eax,(%esp)
80101257:	e8 5c 0c 00 00       	call   80101eb8 <writei>
8010125c:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010125f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101263:	7e 11                	jle    80101276 <filewrite+0xdb>
        f->off += r;
80101265:	8b 45 08             	mov    0x8(%ebp),%eax
80101268:	8b 50 14             	mov    0x14(%eax),%edx
8010126b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010126e:	01 c2                	add    %eax,%edx
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101276:	8b 45 08             	mov    0x8(%ebp),%eax
80101279:	8b 40 10             	mov    0x10(%eax),%eax
8010127c:	89 04 24             	mov    %eax,(%esp)
8010127f:	e8 11 07 00 00       	call   80101995 <iunlock>
      commit_trans();
80101284:	e8 91 1f 00 00       	call   8010321a <commit_trans>

      if(r < 0)
80101289:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010128d:	79 02                	jns    80101291 <filewrite+0xf6>
        break;
8010128f:	eb 26                	jmp    801012b7 <filewrite+0x11c>
      if(r != n1)
80101291:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101294:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101297:	74 0c                	je     801012a5 <filewrite+0x10a>
        panic("short filewrite");
80101299:	c7 04 24 0f 81 10 80 	movl   $0x8010810f,(%esp)
801012a0:	e8 95 f2 ff ff       	call   8010053a <panic>
      i += r;
801012a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012a8:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ae:	3b 45 10             	cmp    0x10(%ebp),%eax
801012b1:	0f 8c 4c ff ff ff    	jl     80101203 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ba:	3b 45 10             	cmp    0x10(%ebp),%eax
801012bd:	75 05                	jne    801012c4 <filewrite+0x129>
801012bf:	8b 45 10             	mov    0x10(%ebp),%eax
801012c2:	eb 05                	jmp    801012c9 <filewrite+0x12e>
801012c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012c9:	eb 0c                	jmp    801012d7 <filewrite+0x13c>
  }
  panic("filewrite");
801012cb:	c7 04 24 1f 81 10 80 	movl   $0x8010811f,(%esp)
801012d2:	e8 63 f2 ff ff       	call   8010053a <panic>
}
801012d7:	83 c4 24             	add    $0x24,%esp
801012da:	5b                   	pop    %ebx
801012db:	5d                   	pop    %ebp
801012dc:	c3                   	ret    

801012dd <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012dd:	55                   	push   %ebp
801012de:	89 e5                	mov    %esp,%ebp
801012e0:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012e3:	8b 45 08             	mov    0x8(%ebp),%eax
801012e6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801012ed:	00 
801012ee:	89 04 24             	mov    %eax,(%esp)
801012f1:	e8 b0 ee ff ff       	call   801001a6 <bread>
801012f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801012f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012fc:	83 c0 18             	add    $0x18,%eax
801012ff:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101306:	00 
80101307:	89 44 24 04          	mov    %eax,0x4(%esp)
8010130b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010130e:	89 04 24             	mov    %eax,(%esp)
80101311:	e8 a8 3a 00 00       	call   80104dbe <memmove>
  brelse(bp);
80101316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101319:	89 04 24             	mov    %eax,(%esp)
8010131c:	e8 f6 ee ff ff       	call   80100217 <brelse>
}
80101321:	c9                   	leave  
80101322:	c3                   	ret    

80101323 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101323:	55                   	push   %ebp
80101324:	89 e5                	mov    %esp,%ebp
80101326:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101329:	8b 55 0c             	mov    0xc(%ebp),%edx
8010132c:	8b 45 08             	mov    0x8(%ebp),%eax
8010132f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101333:	89 04 24             	mov    %eax,(%esp)
80101336:	e8 6b ee ff ff       	call   801001a6 <bread>
8010133b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010133e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101341:	83 c0 18             	add    $0x18,%eax
80101344:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010134b:	00 
8010134c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101353:	00 
80101354:	89 04 24             	mov    %eax,(%esp)
80101357:	e8 93 39 00 00       	call   80104cef <memset>
  log_write(bp);
8010135c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010135f:	89 04 24             	mov    %eax,(%esp)
80101362:	e8 0b 1f 00 00       	call   80103272 <log_write>
  brelse(bp);
80101367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136a:	89 04 24             	mov    %eax,(%esp)
8010136d:	e8 a5 ee ff ff       	call   80100217 <brelse>
}
80101372:	c9                   	leave  
80101373:	c3                   	ret    

80101374 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101374:	55                   	push   %ebp
80101375:	89 e5                	mov    %esp,%ebp
80101377:	83 ec 38             	sub    $0x38,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010137a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101381:	8b 45 08             	mov    0x8(%ebp),%eax
80101384:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101387:	89 54 24 04          	mov    %edx,0x4(%esp)
8010138b:	89 04 24             	mov    %eax,(%esp)
8010138e:	e8 4a ff ff ff       	call   801012dd <readsb>
  for(b = 0; b < sb.size; b += BPB){
80101393:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010139a:	e9 07 01 00 00       	jmp    801014a6 <balloc+0x132>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
8010139f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013a8:	85 c0                	test   %eax,%eax
801013aa:	0f 48 c2             	cmovs  %edx,%eax
801013ad:	c1 f8 0c             	sar    $0xc,%eax
801013b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013b3:	c1 ea 03             	shr    $0x3,%edx
801013b6:	01 d0                	add    %edx,%eax
801013b8:	83 c0 03             	add    $0x3,%eax
801013bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801013bf:	8b 45 08             	mov    0x8(%ebp),%eax
801013c2:	89 04 24             	mov    %eax,(%esp)
801013c5:	e8 dc ed ff ff       	call   801001a6 <bread>
801013ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013d4:	e9 9d 00 00 00       	jmp    80101476 <balloc+0x102>
      m = 1 << (bi % 8);
801013d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013dc:	99                   	cltd   
801013dd:	c1 ea 1d             	shr    $0x1d,%edx
801013e0:	01 d0                	add    %edx,%eax
801013e2:	83 e0 07             	and    $0x7,%eax
801013e5:	29 d0                	sub    %edx,%eax
801013e7:	ba 01 00 00 00       	mov    $0x1,%edx
801013ec:	89 c1                	mov    %eax,%ecx
801013ee:	d3 e2                	shl    %cl,%edx
801013f0:	89 d0                	mov    %edx,%eax
801013f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801013f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f8:	8d 50 07             	lea    0x7(%eax),%edx
801013fb:	85 c0                	test   %eax,%eax
801013fd:	0f 48 c2             	cmovs  %edx,%eax
80101400:	c1 f8 03             	sar    $0x3,%eax
80101403:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101406:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010140b:	0f b6 c0             	movzbl %al,%eax
8010140e:	23 45 e8             	and    -0x18(%ebp),%eax
80101411:	85 c0                	test   %eax,%eax
80101413:	75 5d                	jne    80101472 <balloc+0xfe>
        bp->data[bi/8] |= m;  // Mark block in use.
80101415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101418:	8d 50 07             	lea    0x7(%eax),%edx
8010141b:	85 c0                	test   %eax,%eax
8010141d:	0f 48 c2             	cmovs  %edx,%eax
80101420:	c1 f8 03             	sar    $0x3,%eax
80101423:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101426:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010142b:	89 d1                	mov    %edx,%ecx
8010142d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101430:	09 ca                	or     %ecx,%edx
80101432:	89 d1                	mov    %edx,%ecx
80101434:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101437:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010143b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010143e:	89 04 24             	mov    %eax,(%esp)
80101441:	e8 2c 1e 00 00       	call   80103272 <log_write>
        brelse(bp);
80101446:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101449:	89 04 24             	mov    %eax,(%esp)
8010144c:	e8 c6 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101454:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101457:	01 c2                	add    %eax,%edx
80101459:	8b 45 08             	mov    0x8(%ebp),%eax
8010145c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101460:	89 04 24             	mov    %eax,(%esp)
80101463:	e8 bb fe ff ff       	call   80101323 <bzero>
        return b + bi;
80101468:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010146e:	01 d0                	add    %edx,%eax
80101470:	eb 4e                	jmp    801014c0 <balloc+0x14c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101472:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101476:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010147d:	7f 15                	jg     80101494 <balloc+0x120>
8010147f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101482:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101485:	01 d0                	add    %edx,%eax
80101487:	89 c2                	mov    %eax,%edx
80101489:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010148c:	39 c2                	cmp    %eax,%edx
8010148e:	0f 82 45 ff ff ff    	jb     801013d9 <balloc+0x65>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101494:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101497:	89 04 24             	mov    %eax,(%esp)
8010149a:	e8 78 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
8010149f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014ac:	39 c2                	cmp    %eax,%edx
801014ae:	0f 82 eb fe ff ff    	jb     8010139f <balloc+0x2b>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014b4:	c7 04 24 29 81 10 80 	movl   $0x80108129,(%esp)
801014bb:	e8 7a f0 ff ff       	call   8010053a <panic>
}
801014c0:	c9                   	leave  
801014c1:	c3                   	ret    

801014c2 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014c2:	55                   	push   %ebp
801014c3:	89 e5                	mov    %esp,%ebp
801014c5:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014c8:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801014cf:	8b 45 08             	mov    0x8(%ebp),%eax
801014d2:	89 04 24             	mov    %eax,(%esp)
801014d5:	e8 03 fe ff ff       	call   801012dd <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014da:	8b 45 0c             	mov    0xc(%ebp),%eax
801014dd:	c1 e8 0c             	shr    $0xc,%eax
801014e0:	89 c2                	mov    %eax,%edx
801014e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014e5:	c1 e8 03             	shr    $0x3,%eax
801014e8:	01 d0                	add    %edx,%eax
801014ea:	8d 50 03             	lea    0x3(%eax),%edx
801014ed:	8b 45 08             	mov    0x8(%ebp),%eax
801014f0:	89 54 24 04          	mov    %edx,0x4(%esp)
801014f4:	89 04 24             	mov    %eax,(%esp)
801014f7:	e8 aa ec ff ff       	call   801001a6 <bread>
801014fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801014ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80101502:	25 ff 0f 00 00       	and    $0xfff,%eax
80101507:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010150a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150d:	99                   	cltd   
8010150e:	c1 ea 1d             	shr    $0x1d,%edx
80101511:	01 d0                	add    %edx,%eax
80101513:	83 e0 07             	and    $0x7,%eax
80101516:	29 d0                	sub    %edx,%eax
80101518:	ba 01 00 00 00       	mov    $0x1,%edx
8010151d:	89 c1                	mov    %eax,%ecx
8010151f:	d3 e2                	shl    %cl,%edx
80101521:	89 d0                	mov    %edx,%eax
80101523:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101526:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101529:	8d 50 07             	lea    0x7(%eax),%edx
8010152c:	85 c0                	test   %eax,%eax
8010152e:	0f 48 c2             	cmovs  %edx,%eax
80101531:	c1 f8 03             	sar    $0x3,%eax
80101534:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101537:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010153c:	0f b6 c0             	movzbl %al,%eax
8010153f:	23 45 ec             	and    -0x14(%ebp),%eax
80101542:	85 c0                	test   %eax,%eax
80101544:	75 0c                	jne    80101552 <bfree+0x90>
    panic("freeing free block");
80101546:	c7 04 24 3f 81 10 80 	movl   $0x8010813f,(%esp)
8010154d:	e8 e8 ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
80101552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101555:	8d 50 07             	lea    0x7(%eax),%edx
80101558:	85 c0                	test   %eax,%eax
8010155a:	0f 48 c2             	cmovs  %edx,%eax
8010155d:	c1 f8 03             	sar    $0x3,%eax
80101560:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101563:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101568:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010156b:	f7 d1                	not    %ecx
8010156d:	21 ca                	and    %ecx,%edx
8010156f:	89 d1                	mov    %edx,%ecx
80101571:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101574:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010157b:	89 04 24             	mov    %eax,(%esp)
8010157e:	e8 ef 1c 00 00       	call   80103272 <log_write>
  brelse(bp);
80101583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101586:	89 04 24             	mov    %eax,(%esp)
80101589:	e8 89 ec ff ff       	call   80100217 <brelse>
}
8010158e:	c9                   	leave  
8010158f:	c3                   	ret    

80101590 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101590:	55                   	push   %ebp
80101591:	89 e5                	mov    %esp,%ebp
80101593:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101596:	c7 44 24 04 52 81 10 	movl   $0x80108152,0x4(%esp)
8010159d:	80 
8010159e:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801015a5:	e8 d0 34 00 00       	call   80104a7a <initlock>
}
801015aa:	c9                   	leave  
801015ab:	c3                   	ret    

801015ac <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015ac:	55                   	push   %ebp
801015ad:	89 e5                	mov    %esp,%ebp
801015af:	83 ec 38             	sub    $0x38,%esp
801015b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801015b5:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015b9:	8b 45 08             	mov    0x8(%ebp),%eax
801015bc:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015bf:	89 54 24 04          	mov    %edx,0x4(%esp)
801015c3:	89 04 24             	mov    %eax,(%esp)
801015c6:	e8 12 fd ff ff       	call   801012dd <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015cb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015d2:	e9 98 00 00 00       	jmp    8010166f <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801015d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015da:	c1 e8 03             	shr    $0x3,%eax
801015dd:	83 c0 02             	add    $0x2,%eax
801015e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801015e4:	8b 45 08             	mov    0x8(%ebp),%eax
801015e7:	89 04 24             	mov    %eax,(%esp)
801015ea:	e8 b7 eb ff ff       	call   801001a6 <bread>
801015ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f5:	8d 50 18             	lea    0x18(%eax),%edx
801015f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015fb:	83 e0 07             	and    $0x7,%eax
801015fe:	c1 e0 06             	shl    $0x6,%eax
80101601:	01 d0                	add    %edx,%eax
80101603:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101606:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101609:	0f b7 00             	movzwl (%eax),%eax
8010160c:	66 85 c0             	test   %ax,%ax
8010160f:	75 4f                	jne    80101660 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101611:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101618:	00 
80101619:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101620:	00 
80101621:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101624:	89 04 24             	mov    %eax,(%esp)
80101627:	e8 c3 36 00 00       	call   80104cef <memset>
      dip->type = type;
8010162c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010162f:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101633:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101636:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101639:	89 04 24             	mov    %eax,(%esp)
8010163c:	e8 31 1c 00 00       	call   80103272 <log_write>
      brelse(bp);
80101641:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101644:	89 04 24             	mov    %eax,(%esp)
80101647:	e8 cb eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010164c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010164f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101653:	8b 45 08             	mov    0x8(%ebp),%eax
80101656:	89 04 24             	mov    %eax,(%esp)
80101659:	e8 e5 00 00 00       	call   80101743 <iget>
8010165e:	eb 29                	jmp    80101689 <ialloc+0xdd>
    }
    brelse(bp);
80101660:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101663:	89 04 24             	mov    %eax,(%esp)
80101666:	e8 ac eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010166b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010166f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101672:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101675:	39 c2                	cmp    %eax,%edx
80101677:	0f 82 5a ff ff ff    	jb     801015d7 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010167d:	c7 04 24 59 81 10 80 	movl   $0x80108159,(%esp)
80101684:	e8 b1 ee ff ff       	call   8010053a <panic>
}
80101689:	c9                   	leave  
8010168a:	c3                   	ret    

8010168b <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010168b:	55                   	push   %ebp
8010168c:	89 e5                	mov    %esp,%ebp
8010168e:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101691:	8b 45 08             	mov    0x8(%ebp),%eax
80101694:	8b 40 04             	mov    0x4(%eax),%eax
80101697:	c1 e8 03             	shr    $0x3,%eax
8010169a:	8d 50 02             	lea    0x2(%eax),%edx
8010169d:	8b 45 08             	mov    0x8(%ebp),%eax
801016a0:	8b 00                	mov    (%eax),%eax
801016a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801016a6:	89 04 24             	mov    %eax,(%esp)
801016a9:	e8 f8 ea ff ff       	call   801001a6 <bread>
801016ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016b4:	8d 50 18             	lea    0x18(%eax),%edx
801016b7:	8b 45 08             	mov    0x8(%ebp),%eax
801016ba:	8b 40 04             	mov    0x4(%eax),%eax
801016bd:	83 e0 07             	and    $0x7,%eax
801016c0:	c1 e0 06             	shl    $0x6,%eax
801016c3:	01 d0                	add    %edx,%eax
801016c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016c8:	8b 45 08             	mov    0x8(%ebp),%eax
801016cb:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d2:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016d5:	8b 45 08             	mov    0x8(%ebp),%eax
801016d8:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801016dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016df:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801016e3:	8b 45 08             	mov    0x8(%ebp),%eax
801016e6:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801016ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ed:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801016f1:	8b 45 08             	mov    0x8(%ebp),%eax
801016f4:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801016f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016fb:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801016ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101702:	8b 50 18             	mov    0x18(%eax),%edx
80101705:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101708:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010170b:	8b 45 08             	mov    0x8(%ebp),%eax
8010170e:	8d 50 1c             	lea    0x1c(%eax),%edx
80101711:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101714:	83 c0 0c             	add    $0xc,%eax
80101717:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010171e:	00 
8010171f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101723:	89 04 24             	mov    %eax,(%esp)
80101726:	e8 93 36 00 00       	call   80104dbe <memmove>
  log_write(bp);
8010172b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010172e:	89 04 24             	mov    %eax,(%esp)
80101731:	e8 3c 1b 00 00       	call   80103272 <log_write>
  brelse(bp);
80101736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101739:	89 04 24             	mov    %eax,(%esp)
8010173c:	e8 d6 ea ff ff       	call   80100217 <brelse>
}
80101741:	c9                   	leave  
80101742:	c3                   	ret    

80101743 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101743:	55                   	push   %ebp
80101744:	89 e5                	mov    %esp,%ebp
80101746:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101749:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101750:	e8 46 33 00 00       	call   80104a9b <acquire>

  // Is the inode already cached?
  empty = 0;
80101755:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010175c:	c7 45 f4 94 e8 10 80 	movl   $0x8010e894,-0xc(%ebp)
80101763:	eb 59                	jmp    801017be <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101768:	8b 40 08             	mov    0x8(%eax),%eax
8010176b:	85 c0                	test   %eax,%eax
8010176d:	7e 35                	jle    801017a4 <iget+0x61>
8010176f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101772:	8b 00                	mov    (%eax),%eax
80101774:	3b 45 08             	cmp    0x8(%ebp),%eax
80101777:	75 2b                	jne    801017a4 <iget+0x61>
80101779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177c:	8b 40 04             	mov    0x4(%eax),%eax
8010177f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101782:	75 20                	jne    801017a4 <iget+0x61>
      ip->ref++;
80101784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101787:	8b 40 08             	mov    0x8(%eax),%eax
8010178a:	8d 50 01             	lea    0x1(%eax),%edx
8010178d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101790:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101793:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
8010179a:	e8 5e 33 00 00       	call   80104afd <release>
      return ip;
8010179f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a2:	eb 6f                	jmp    80101813 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017a8:	75 10                	jne    801017ba <iget+0x77>
801017aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ad:	8b 40 08             	mov    0x8(%eax),%eax
801017b0:	85 c0                	test   %eax,%eax
801017b2:	75 06                	jne    801017ba <iget+0x77>
      empty = ip;
801017b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017ba:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017be:	81 7d f4 34 f8 10 80 	cmpl   $0x8010f834,-0xc(%ebp)
801017c5:	72 9e                	jb     80101765 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017cb:	75 0c                	jne    801017d9 <iget+0x96>
    panic("iget: no inodes");
801017cd:	c7 04 24 6b 81 10 80 	movl   $0x8010816b,(%esp)
801017d4:	e8 61 ed ff ff       	call   8010053a <panic>

  ip = empty;
801017d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801017df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e2:	8b 55 08             	mov    0x8(%ebp),%edx
801017e5:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801017e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ea:	8b 55 0c             	mov    0xc(%ebp),%edx
801017ed:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801017f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801017fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101804:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
8010180b:	e8 ed 32 00 00       	call   80104afd <release>

  return ip;
80101810:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101813:	c9                   	leave  
80101814:	c3                   	ret    

80101815 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101815:	55                   	push   %ebp
80101816:	89 e5                	mov    %esp,%ebp
80101818:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
8010181b:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101822:	e8 74 32 00 00       	call   80104a9b <acquire>
  ip->ref++;
80101827:	8b 45 08             	mov    0x8(%ebp),%eax
8010182a:	8b 40 08             	mov    0x8(%eax),%eax
8010182d:	8d 50 01             	lea    0x1(%eax),%edx
80101830:	8b 45 08             	mov    0x8(%ebp),%eax
80101833:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101836:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
8010183d:	e8 bb 32 00 00       	call   80104afd <release>
  return ip;
80101842:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101845:	c9                   	leave  
80101846:	c3                   	ret    

80101847 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101847:	55                   	push   %ebp
80101848:	89 e5                	mov    %esp,%ebp
8010184a:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010184d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101851:	74 0a                	je     8010185d <ilock+0x16>
80101853:	8b 45 08             	mov    0x8(%ebp),%eax
80101856:	8b 40 08             	mov    0x8(%eax),%eax
80101859:	85 c0                	test   %eax,%eax
8010185b:	7f 0c                	jg     80101869 <ilock+0x22>
    panic("ilock");
8010185d:	c7 04 24 7b 81 10 80 	movl   $0x8010817b,(%esp)
80101864:	e8 d1 ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
80101869:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101870:	e8 26 32 00 00       	call   80104a9b <acquire>
  while(ip->flags & I_BUSY)
80101875:	eb 13                	jmp    8010188a <ilock+0x43>
    sleep(ip, &icache.lock);
80101877:	c7 44 24 04 60 e8 10 	movl   $0x8010e860,0x4(%esp)
8010187e:	80 
8010187f:	8b 45 08             	mov    0x8(%ebp),%eax
80101882:	89 04 24             	mov    %eax,(%esp)
80101885:	e8 3e 2f 00 00       	call   801047c8 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
8010188a:	8b 45 08             	mov    0x8(%ebp),%eax
8010188d:	8b 40 0c             	mov    0xc(%eax),%eax
80101890:	83 e0 01             	and    $0x1,%eax
80101893:	85 c0                	test   %eax,%eax
80101895:	75 e0                	jne    80101877 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101897:	8b 45 08             	mov    0x8(%ebp),%eax
8010189a:	8b 40 0c             	mov    0xc(%eax),%eax
8010189d:	83 c8 01             	or     $0x1,%eax
801018a0:	89 c2                	mov    %eax,%edx
801018a2:	8b 45 08             	mov    0x8(%ebp),%eax
801018a5:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018a8:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801018af:	e8 49 32 00 00       	call   80104afd <release>

  if(!(ip->flags & I_VALID)){
801018b4:	8b 45 08             	mov    0x8(%ebp),%eax
801018b7:	8b 40 0c             	mov    0xc(%eax),%eax
801018ba:	83 e0 02             	and    $0x2,%eax
801018bd:	85 c0                	test   %eax,%eax
801018bf:	0f 85 ce 00 00 00    	jne    80101993 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018c5:	8b 45 08             	mov    0x8(%ebp),%eax
801018c8:	8b 40 04             	mov    0x4(%eax),%eax
801018cb:	c1 e8 03             	shr    $0x3,%eax
801018ce:	8d 50 02             	lea    0x2(%eax),%edx
801018d1:	8b 45 08             	mov    0x8(%ebp),%eax
801018d4:	8b 00                	mov    (%eax),%eax
801018d6:	89 54 24 04          	mov    %edx,0x4(%esp)
801018da:	89 04 24             	mov    %eax,(%esp)
801018dd:	e8 c4 e8 ff ff       	call   801001a6 <bread>
801018e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801018e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e8:	8d 50 18             	lea    0x18(%eax),%edx
801018eb:	8b 45 08             	mov    0x8(%ebp),%eax
801018ee:	8b 40 04             	mov    0x4(%eax),%eax
801018f1:	83 e0 07             	and    $0x7,%eax
801018f4:	c1 e0 06             	shl    $0x6,%eax
801018f7:	01 d0                	add    %edx,%eax
801018f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801018fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ff:	0f b7 10             	movzwl (%eax),%edx
80101902:	8b 45 08             	mov    0x8(%ebp),%eax
80101905:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101909:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101910:	8b 45 08             	mov    0x8(%ebp),%eax
80101913:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101917:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101928:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010192c:	8b 45 08             	mov    0x8(%ebp),%eax
8010192f:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101933:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101936:	8b 50 08             	mov    0x8(%eax),%edx
80101939:	8b 45 08             	mov    0x8(%ebp),%eax
8010193c:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010193f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101942:	8d 50 0c             	lea    0xc(%eax),%edx
80101945:	8b 45 08             	mov    0x8(%ebp),%eax
80101948:	83 c0 1c             	add    $0x1c,%eax
8010194b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101952:	00 
80101953:	89 54 24 04          	mov    %edx,0x4(%esp)
80101957:	89 04 24             	mov    %eax,(%esp)
8010195a:	e8 5f 34 00 00       	call   80104dbe <memmove>
    brelse(bp);
8010195f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101962:	89 04 24             	mov    %eax,(%esp)
80101965:	e8 ad e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010196a:	8b 45 08             	mov    0x8(%ebp),%eax
8010196d:	8b 40 0c             	mov    0xc(%eax),%eax
80101970:	83 c8 02             	or     $0x2,%eax
80101973:	89 c2                	mov    %eax,%edx
80101975:	8b 45 08             	mov    0x8(%ebp),%eax
80101978:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
8010197b:	8b 45 08             	mov    0x8(%ebp),%eax
8010197e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101982:	66 85 c0             	test   %ax,%ax
80101985:	75 0c                	jne    80101993 <ilock+0x14c>
      panic("ilock: no type");
80101987:	c7 04 24 81 81 10 80 	movl   $0x80108181,(%esp)
8010198e:	e8 a7 eb ff ff       	call   8010053a <panic>
  }
}
80101993:	c9                   	leave  
80101994:	c3                   	ret    

80101995 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101995:	55                   	push   %ebp
80101996:	89 e5                	mov    %esp,%ebp
80101998:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
8010199b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010199f:	74 17                	je     801019b8 <iunlock+0x23>
801019a1:	8b 45 08             	mov    0x8(%ebp),%eax
801019a4:	8b 40 0c             	mov    0xc(%eax),%eax
801019a7:	83 e0 01             	and    $0x1,%eax
801019aa:	85 c0                	test   %eax,%eax
801019ac:	74 0a                	je     801019b8 <iunlock+0x23>
801019ae:	8b 45 08             	mov    0x8(%ebp),%eax
801019b1:	8b 40 08             	mov    0x8(%eax),%eax
801019b4:	85 c0                	test   %eax,%eax
801019b6:	7f 0c                	jg     801019c4 <iunlock+0x2f>
    panic("iunlock");
801019b8:	c7 04 24 90 81 10 80 	movl   $0x80108190,(%esp)
801019bf:	e8 76 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019c4:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801019cb:	e8 cb 30 00 00       	call   80104a9b <acquire>
  ip->flags &= ~I_BUSY;
801019d0:	8b 45 08             	mov    0x8(%ebp),%eax
801019d3:	8b 40 0c             	mov    0xc(%eax),%eax
801019d6:	83 e0 fe             	and    $0xfffffffe,%eax
801019d9:	89 c2                	mov    %eax,%edx
801019db:	8b 45 08             	mov    0x8(%ebp),%eax
801019de:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
801019e1:	8b 45 08             	mov    0x8(%ebp),%eax
801019e4:	89 04 24             	mov    %eax,(%esp)
801019e7:	e8 b8 2e 00 00       	call   801048a4 <wakeup>
  release(&icache.lock);
801019ec:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801019f3:	e8 05 31 00 00       	call   80104afd <release>
}
801019f8:	c9                   	leave  
801019f9:	c3                   	ret    

801019fa <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
801019fa:	55                   	push   %ebp
801019fb:	89 e5                	mov    %esp,%ebp
801019fd:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a00:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a07:	e8 8f 30 00 00       	call   80104a9b <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0f:	8b 40 08             	mov    0x8(%eax),%eax
80101a12:	83 f8 01             	cmp    $0x1,%eax
80101a15:	0f 85 93 00 00 00    	jne    80101aae <iput+0xb4>
80101a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1e:	8b 40 0c             	mov    0xc(%eax),%eax
80101a21:	83 e0 02             	and    $0x2,%eax
80101a24:	85 c0                	test   %eax,%eax
80101a26:	0f 84 82 00 00 00    	je     80101aae <iput+0xb4>
80101a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a33:	66 85 c0             	test   %ax,%ax
80101a36:	75 76                	jne    80101aae <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101a38:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3b:	8b 40 0c             	mov    0xc(%eax),%eax
80101a3e:	83 e0 01             	and    $0x1,%eax
80101a41:	85 c0                	test   %eax,%eax
80101a43:	74 0c                	je     80101a51 <iput+0x57>
      panic("iput busy");
80101a45:	c7 04 24 98 81 10 80 	movl   $0x80108198,(%esp)
80101a4c:	e8 e9 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	8b 40 0c             	mov    0xc(%eax),%eax
80101a57:	83 c8 01             	or     $0x1,%eax
80101a5a:	89 c2                	mov    %eax,%edx
80101a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5f:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a62:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a69:	e8 8f 30 00 00       	call   80104afd <release>
    itrunc(ip);
80101a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a71:	89 04 24             	mov    %eax,(%esp)
80101a74:	e8 7d 01 00 00       	call   80101bf6 <itrunc>
    ip->type = 0;
80101a79:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7c:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101a82:	8b 45 08             	mov    0x8(%ebp),%eax
80101a85:	89 04 24             	mov    %eax,(%esp)
80101a88:	e8 fe fb ff ff       	call   8010168b <iupdate>
    acquire(&icache.lock);
80101a8d:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a94:	e8 02 30 00 00       	call   80104a9b <acquire>
    ip->flags = 0;
80101a99:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	89 04 24             	mov    %eax,(%esp)
80101aa9:	e8 f6 2d 00 00       	call   801048a4 <wakeup>
  }
  ip->ref--;
80101aae:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab1:	8b 40 08             	mov    0x8(%eax),%eax
80101ab4:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aba:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101abd:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101ac4:	e8 34 30 00 00       	call   80104afd <release>
}
80101ac9:	c9                   	leave  
80101aca:	c3                   	ret    

80101acb <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101acb:	55                   	push   %ebp
80101acc:	89 e5                	mov    %esp,%ebp
80101ace:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad4:	89 04 24             	mov    %eax,(%esp)
80101ad7:	e8 b9 fe ff ff       	call   80101995 <iunlock>
  iput(ip);
80101adc:	8b 45 08             	mov    0x8(%ebp),%eax
80101adf:	89 04 24             	mov    %eax,(%esp)
80101ae2:	e8 13 ff ff ff       	call   801019fa <iput>
}
80101ae7:	c9                   	leave  
80101ae8:	c3                   	ret    

80101ae9 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101ae9:	55                   	push   %ebp
80101aea:	89 e5                	mov    %esp,%ebp
80101aec:	53                   	push   %ebx
80101aed:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101af0:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101af4:	77 3e                	ja     80101b34 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101af6:	8b 45 08             	mov    0x8(%ebp),%eax
80101af9:	8b 55 0c             	mov    0xc(%ebp),%edx
80101afc:	83 c2 04             	add    $0x4,%edx
80101aff:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b03:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b0a:	75 20                	jne    80101b2c <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0f:	8b 00                	mov    (%eax),%eax
80101b11:	89 04 24             	mov    %eax,(%esp)
80101b14:	e8 5b f8 ff ff       	call   80101374 <balloc>
80101b19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b22:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b28:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b2f:	e9 bc 00 00 00       	jmp    80101bf0 <bmap+0x107>
  }
  bn -= NDIRECT;
80101b34:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b38:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b3c:	0f 87 a2 00 00 00    	ja     80101be4 <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b42:	8b 45 08             	mov    0x8(%ebp),%eax
80101b45:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b48:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b4f:	75 19                	jne    80101b6a <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	8b 00                	mov    (%eax),%eax
80101b56:	89 04 24             	mov    %eax,(%esp)
80101b59:	e8 16 f8 ff ff       	call   80101374 <balloc>
80101b5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b61:	8b 45 08             	mov    0x8(%ebp),%eax
80101b64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b67:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6d:	8b 00                	mov    (%eax),%eax
80101b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b72:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b76:	89 04 24             	mov    %eax,(%esp)
80101b79:	e8 28 e6 ff ff       	call   801001a6 <bread>
80101b7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b84:	83 c0 18             	add    $0x18,%eax
80101b87:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101b8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101b94:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b97:	01 d0                	add    %edx,%eax
80101b99:	8b 00                	mov    (%eax),%eax
80101b9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ba2:	75 30                	jne    80101bd4 <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ba7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bb1:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb7:	8b 00                	mov    (%eax),%eax
80101bb9:	89 04 24             	mov    %eax,(%esp)
80101bbc:	e8 b3 f7 ff ff       	call   80101374 <balloc>
80101bc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bc7:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bcc:	89 04 24             	mov    %eax,(%esp)
80101bcf:	e8 9e 16 00 00       	call   80103272 <log_write>
    }
    brelse(bp);
80101bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd7:	89 04 24             	mov    %eax,(%esp)
80101bda:	e8 38 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101be2:	eb 0c                	jmp    80101bf0 <bmap+0x107>
  }

  panic("bmap: out of range");
80101be4:	c7 04 24 a2 81 10 80 	movl   $0x801081a2,(%esp)
80101beb:	e8 4a e9 ff ff       	call   8010053a <panic>
}
80101bf0:	83 c4 24             	add    $0x24,%esp
80101bf3:	5b                   	pop    %ebx
80101bf4:	5d                   	pop    %ebp
80101bf5:	c3                   	ret    

80101bf6 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101bf6:	55                   	push   %ebp
80101bf7:	89 e5                	mov    %esp,%ebp
80101bf9:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101bfc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c03:	eb 44                	jmp    80101c49 <itrunc+0x53>
    if(ip->addrs[i]){
80101c05:	8b 45 08             	mov    0x8(%ebp),%eax
80101c08:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c0b:	83 c2 04             	add    $0x4,%edx
80101c0e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c12:	85 c0                	test   %eax,%eax
80101c14:	74 2f                	je     80101c45 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c16:	8b 45 08             	mov    0x8(%ebp),%eax
80101c19:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c1c:	83 c2 04             	add    $0x4,%edx
80101c1f:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c23:	8b 45 08             	mov    0x8(%ebp),%eax
80101c26:	8b 00                	mov    (%eax),%eax
80101c28:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c2c:	89 04 24             	mov    %eax,(%esp)
80101c2f:	e8 8e f8 ff ff       	call   801014c2 <bfree>
      ip->addrs[i] = 0;
80101c34:	8b 45 08             	mov    0x8(%ebp),%eax
80101c37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c3a:	83 c2 04             	add    $0x4,%edx
80101c3d:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c44:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c45:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c49:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c4d:	7e b6                	jle    80101c05 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c52:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c55:	85 c0                	test   %eax,%eax
80101c57:	0f 84 9b 00 00 00    	je     80101cf8 <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c60:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c63:	8b 45 08             	mov    0x8(%ebp),%eax
80101c66:	8b 00                	mov    (%eax),%eax
80101c68:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c6c:	89 04 24             	mov    %eax,(%esp)
80101c6f:	e8 32 e5 ff ff       	call   801001a6 <bread>
80101c74:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c7a:	83 c0 18             	add    $0x18,%eax
80101c7d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101c80:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101c87:	eb 3b                	jmp    80101cc4 <itrunc+0xce>
      if(a[j])
80101c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c8c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101c96:	01 d0                	add    %edx,%eax
80101c98:	8b 00                	mov    (%eax),%eax
80101c9a:	85 c0                	test   %eax,%eax
80101c9c:	74 22                	je     80101cc0 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ca1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ca8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101cab:	01 d0                	add    %edx,%eax
80101cad:	8b 10                	mov    (%eax),%edx
80101caf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb2:	8b 00                	mov    (%eax),%eax
80101cb4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cb8:	89 04 24             	mov    %eax,(%esp)
80101cbb:	e8 02 f8 ff ff       	call   801014c2 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101cc0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cc7:	83 f8 7f             	cmp    $0x7f,%eax
80101cca:	76 bd                	jbe    80101c89 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ccc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ccf:	89 04 24             	mov    %eax,(%esp)
80101cd2:	e8 40 e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cda:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce0:	8b 00                	mov    (%eax),%eax
80101ce2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ce6:	89 04 24             	mov    %eax,(%esp)
80101ce9:	e8 d4 f7 ff ff       	call   801014c2 <bfree>
    ip->addrs[NDIRECT] = 0;
80101cee:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf1:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfb:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d02:	8b 45 08             	mov    0x8(%ebp),%eax
80101d05:	89 04 24             	mov    %eax,(%esp)
80101d08:	e8 7e f9 ff ff       	call   8010168b <iupdate>
}
80101d0d:	c9                   	leave  
80101d0e:	c3                   	ret    

80101d0f <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d0f:	55                   	push   %ebp
80101d10:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d12:	8b 45 08             	mov    0x8(%ebp),%eax
80101d15:	8b 00                	mov    (%eax),%eax
80101d17:	89 c2                	mov    %eax,%edx
80101d19:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1c:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d22:	8b 50 04             	mov    0x4(%eax),%edx
80101d25:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d28:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2e:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d32:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d35:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d38:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3b:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d42:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d46:	8b 45 08             	mov    0x8(%ebp),%eax
80101d49:	8b 50 18             	mov    0x18(%eax),%edx
80101d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d4f:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d52:	5d                   	pop    %ebp
80101d53:	c3                   	ret    

80101d54 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d54:	55                   	push   %ebp
80101d55:	89 e5                	mov    %esp,%ebp
80101d57:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d61:	66 83 f8 03          	cmp    $0x3,%ax
80101d65:	75 60                	jne    80101dc7 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d67:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d6e:	66 85 c0             	test   %ax,%ax
80101d71:	78 20                	js     80101d93 <readi+0x3f>
80101d73:	8b 45 08             	mov    0x8(%ebp),%eax
80101d76:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d7a:	66 83 f8 09          	cmp    $0x9,%ax
80101d7e:	7f 13                	jg     80101d93 <readi+0x3f>
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d87:	98                   	cwtl   
80101d88:	8b 04 c5 00 e8 10 80 	mov    -0x7fef1800(,%eax,8),%eax
80101d8f:	85 c0                	test   %eax,%eax
80101d91:	75 0a                	jne    80101d9d <readi+0x49>
      return -1;
80101d93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101d98:	e9 19 01 00 00       	jmp    80101eb6 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101d9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101da0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101da4:	98                   	cwtl   
80101da5:	8b 04 c5 00 e8 10 80 	mov    -0x7fef1800(,%eax,8),%eax
80101dac:	8b 55 14             	mov    0x14(%ebp),%edx
80101daf:	89 54 24 08          	mov    %edx,0x8(%esp)
80101db3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101db6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dba:	8b 55 08             	mov    0x8(%ebp),%edx
80101dbd:	89 14 24             	mov    %edx,(%esp)
80101dc0:	ff d0                	call   *%eax
80101dc2:	e9 ef 00 00 00       	jmp    80101eb6 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dca:	8b 40 18             	mov    0x18(%eax),%eax
80101dcd:	3b 45 10             	cmp    0x10(%ebp),%eax
80101dd0:	72 0d                	jb     80101ddf <readi+0x8b>
80101dd2:	8b 45 14             	mov    0x14(%ebp),%eax
80101dd5:	8b 55 10             	mov    0x10(%ebp),%edx
80101dd8:	01 d0                	add    %edx,%eax
80101dda:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ddd:	73 0a                	jae    80101de9 <readi+0x95>
    return -1;
80101ddf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101de4:	e9 cd 00 00 00       	jmp    80101eb6 <readi+0x162>
  if(off + n > ip->size)
80101de9:	8b 45 14             	mov    0x14(%ebp),%eax
80101dec:	8b 55 10             	mov    0x10(%ebp),%edx
80101def:	01 c2                	add    %eax,%edx
80101df1:	8b 45 08             	mov    0x8(%ebp),%eax
80101df4:	8b 40 18             	mov    0x18(%eax),%eax
80101df7:	39 c2                	cmp    %eax,%edx
80101df9:	76 0c                	jbe    80101e07 <readi+0xb3>
    n = ip->size - off;
80101dfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfe:	8b 40 18             	mov    0x18(%eax),%eax
80101e01:	2b 45 10             	sub    0x10(%ebp),%eax
80101e04:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e0e:	e9 94 00 00 00       	jmp    80101ea7 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e13:	8b 45 10             	mov    0x10(%ebp),%eax
80101e16:	c1 e8 09             	shr    $0x9,%eax
80101e19:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e1d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e20:	89 04 24             	mov    %eax,(%esp)
80101e23:	e8 c1 fc ff ff       	call   80101ae9 <bmap>
80101e28:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2b:	8b 12                	mov    (%edx),%edx
80101e2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e31:	89 14 24             	mov    %edx,(%esp)
80101e34:	e8 6d e3 ff ff       	call   801001a6 <bread>
80101e39:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e3c:	8b 45 10             	mov    0x10(%ebp),%eax
80101e3f:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e44:	89 c2                	mov    %eax,%edx
80101e46:	b8 00 02 00 00       	mov    $0x200,%eax
80101e4b:	29 d0                	sub    %edx,%eax
80101e4d:	89 c2                	mov    %eax,%edx
80101e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e52:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e55:	29 c1                	sub    %eax,%ecx
80101e57:	89 c8                	mov    %ecx,%eax
80101e59:	39 c2                	cmp    %eax,%edx
80101e5b:	0f 46 c2             	cmovbe %edx,%eax
80101e5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e61:	8b 45 10             	mov    0x10(%ebp),%eax
80101e64:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e69:	8d 50 10             	lea    0x10(%eax),%edx
80101e6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e6f:	01 d0                	add    %edx,%eax
80101e71:	8d 50 08             	lea    0x8(%eax),%edx
80101e74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e77:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e7b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e82:	89 04 24             	mov    %eax,(%esp)
80101e85:	e8 34 2f 00 00       	call   80104dbe <memmove>
    brelse(bp);
80101e8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e8d:	89 04 24             	mov    %eax,(%esp)
80101e90:	e8 82 e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e98:	01 45 f4             	add    %eax,-0xc(%ebp)
80101e9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e9e:	01 45 10             	add    %eax,0x10(%ebp)
80101ea1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ea4:	01 45 0c             	add    %eax,0xc(%ebp)
80101ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eaa:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ead:	0f 82 60 ff ff ff    	jb     80101e13 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101eb3:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101eb6:	c9                   	leave  
80101eb7:	c3                   	ret    

80101eb8 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101eb8:	55                   	push   %ebp
80101eb9:	89 e5                	mov    %esp,%ebp
80101ebb:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ec5:	66 83 f8 03          	cmp    $0x3,%ax
80101ec9:	75 60                	jne    80101f2b <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ece:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ed2:	66 85 c0             	test   %ax,%ax
80101ed5:	78 20                	js     80101ef7 <writei+0x3f>
80101ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eda:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ede:	66 83 f8 09          	cmp    $0x9,%ax
80101ee2:	7f 13                	jg     80101ef7 <writei+0x3f>
80101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eeb:	98                   	cwtl   
80101eec:	8b 04 c5 04 e8 10 80 	mov    -0x7fef17fc(,%eax,8),%eax
80101ef3:	85 c0                	test   %eax,%eax
80101ef5:	75 0a                	jne    80101f01 <writei+0x49>
      return -1;
80101ef7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101efc:	e9 44 01 00 00       	jmp    80102045 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f01:	8b 45 08             	mov    0x8(%ebp),%eax
80101f04:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f08:	98                   	cwtl   
80101f09:	8b 04 c5 04 e8 10 80 	mov    -0x7fef17fc(,%eax,8),%eax
80101f10:	8b 55 14             	mov    0x14(%ebp),%edx
80101f13:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f17:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f1a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f1e:	8b 55 08             	mov    0x8(%ebp),%edx
80101f21:	89 14 24             	mov    %edx,(%esp)
80101f24:	ff d0                	call   *%eax
80101f26:	e9 1a 01 00 00       	jmp    80102045 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2e:	8b 40 18             	mov    0x18(%eax),%eax
80101f31:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f34:	72 0d                	jb     80101f43 <writei+0x8b>
80101f36:	8b 45 14             	mov    0x14(%ebp),%eax
80101f39:	8b 55 10             	mov    0x10(%ebp),%edx
80101f3c:	01 d0                	add    %edx,%eax
80101f3e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f41:	73 0a                	jae    80101f4d <writei+0x95>
    return -1;
80101f43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f48:	e9 f8 00 00 00       	jmp    80102045 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101f4d:	8b 45 14             	mov    0x14(%ebp),%eax
80101f50:	8b 55 10             	mov    0x10(%ebp),%edx
80101f53:	01 d0                	add    %edx,%eax
80101f55:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f5a:	76 0a                	jbe    80101f66 <writei+0xae>
    return -1;
80101f5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f61:	e9 df 00 00 00       	jmp    80102045 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f6d:	e9 9f 00 00 00       	jmp    80102011 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f72:	8b 45 10             	mov    0x10(%ebp),%eax
80101f75:	c1 e8 09             	shr    $0x9,%eax
80101f78:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7f:	89 04 24             	mov    %eax,(%esp)
80101f82:	e8 62 fb ff ff       	call   80101ae9 <bmap>
80101f87:	8b 55 08             	mov    0x8(%ebp),%edx
80101f8a:	8b 12                	mov    (%edx),%edx
80101f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f90:	89 14 24             	mov    %edx,(%esp)
80101f93:	e8 0e e2 ff ff       	call   801001a6 <bread>
80101f98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f9b:	8b 45 10             	mov    0x10(%ebp),%eax
80101f9e:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fa3:	89 c2                	mov    %eax,%edx
80101fa5:	b8 00 02 00 00       	mov    $0x200,%eax
80101faa:	29 d0                	sub    %edx,%eax
80101fac:	89 c2                	mov    %eax,%edx
80101fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fb1:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fb4:	29 c1                	sub    %eax,%ecx
80101fb6:	89 c8                	mov    %ecx,%eax
80101fb8:	39 c2                	cmp    %eax,%edx
80101fba:	0f 46 c2             	cmovbe %edx,%eax
80101fbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101fc0:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc3:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc8:	8d 50 10             	lea    0x10(%eax),%edx
80101fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fce:	01 d0                	add    %edx,%eax
80101fd0:	8d 50 08             	lea    0x8(%eax),%edx
80101fd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fd6:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fda:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fe1:	89 14 24             	mov    %edx,(%esp)
80101fe4:	e8 d5 2d 00 00       	call   80104dbe <memmove>
    log_write(bp);
80101fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fec:	89 04 24             	mov    %eax,(%esp)
80101fef:	e8 7e 12 00 00       	call   80103272 <log_write>
    brelse(bp);
80101ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff7:	89 04 24             	mov    %eax,(%esp)
80101ffa:	e8 18 e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101fff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102002:	01 45 f4             	add    %eax,-0xc(%ebp)
80102005:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102008:	01 45 10             	add    %eax,0x10(%ebp)
8010200b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200e:	01 45 0c             	add    %eax,0xc(%ebp)
80102011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102014:	3b 45 14             	cmp    0x14(%ebp),%eax
80102017:	0f 82 55 ff ff ff    	jb     80101f72 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010201d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102021:	74 1f                	je     80102042 <writei+0x18a>
80102023:	8b 45 08             	mov    0x8(%ebp),%eax
80102026:	8b 40 18             	mov    0x18(%eax),%eax
80102029:	3b 45 10             	cmp    0x10(%ebp),%eax
8010202c:	73 14                	jae    80102042 <writei+0x18a>
    ip->size = off;
8010202e:	8b 45 08             	mov    0x8(%ebp),%eax
80102031:	8b 55 10             	mov    0x10(%ebp),%edx
80102034:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	89 04 24             	mov    %eax,(%esp)
8010203d:	e8 49 f6 ff ff       	call   8010168b <iupdate>
  }
  return n;
80102042:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102045:	c9                   	leave  
80102046:	c3                   	ret    

80102047 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102047:	55                   	push   %ebp
80102048:	89 e5                	mov    %esp,%ebp
8010204a:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010204d:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102054:	00 
80102055:	8b 45 0c             	mov    0xc(%ebp),%eax
80102058:	89 44 24 04          	mov    %eax,0x4(%esp)
8010205c:	8b 45 08             	mov    0x8(%ebp),%eax
8010205f:	89 04 24             	mov    %eax,(%esp)
80102062:	e8 fa 2d 00 00       	call   80104e61 <strncmp>
}
80102067:	c9                   	leave  
80102068:	c3                   	ret    

80102069 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102069:	55                   	push   %ebp
8010206a:	89 e5                	mov    %esp,%ebp
8010206c:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010206f:	8b 45 08             	mov    0x8(%ebp),%eax
80102072:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102076:	66 83 f8 01          	cmp    $0x1,%ax
8010207a:	74 0c                	je     80102088 <dirlookup+0x1f>
    panic("dirlookup not DIR");
8010207c:	c7 04 24 b5 81 10 80 	movl   $0x801081b5,(%esp)
80102083:	e8 b2 e4 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102088:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010208f:	e9 88 00 00 00       	jmp    8010211c <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102094:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010209b:	00 
8010209c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010209f:	89 44 24 08          	mov    %eax,0x8(%esp)
801020a3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801020aa:	8b 45 08             	mov    0x8(%ebp),%eax
801020ad:	89 04 24             	mov    %eax,(%esp)
801020b0:	e8 9f fc ff ff       	call   80101d54 <readi>
801020b5:	83 f8 10             	cmp    $0x10,%eax
801020b8:	74 0c                	je     801020c6 <dirlookup+0x5d>
      panic("dirlink read");
801020ba:	c7 04 24 c7 81 10 80 	movl   $0x801081c7,(%esp)
801020c1:	e8 74 e4 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801020c6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020ca:	66 85 c0             	test   %ax,%ax
801020cd:	75 02                	jne    801020d1 <dirlookup+0x68>
      continue;
801020cf:	eb 47                	jmp    80102118 <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
801020d1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020d4:	83 c0 02             	add    $0x2,%eax
801020d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801020db:	8b 45 0c             	mov    0xc(%ebp),%eax
801020de:	89 04 24             	mov    %eax,(%esp)
801020e1:	e8 61 ff ff ff       	call   80102047 <namecmp>
801020e6:	85 c0                	test   %eax,%eax
801020e8:	75 2e                	jne    80102118 <dirlookup+0xaf>
      // entry matches path element
      if(poff)
801020ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801020ee:	74 08                	je     801020f8 <dirlookup+0x8f>
        *poff = off;
801020f0:	8b 45 10             	mov    0x10(%ebp),%eax
801020f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801020f6:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801020f8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020fc:	0f b7 c0             	movzwl %ax,%eax
801020ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102102:	8b 45 08             	mov    0x8(%ebp),%eax
80102105:	8b 00                	mov    (%eax),%eax
80102107:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010210a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010210e:	89 04 24             	mov    %eax,(%esp)
80102111:	e8 2d f6 ff ff       	call   80101743 <iget>
80102116:	eb 18                	jmp    80102130 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102118:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010211c:	8b 45 08             	mov    0x8(%ebp),%eax
8010211f:	8b 40 18             	mov    0x18(%eax),%eax
80102122:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102125:	0f 87 69 ff ff ff    	ja     80102094 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010212b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102130:	c9                   	leave  
80102131:	c3                   	ret    

80102132 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102132:	55                   	push   %ebp
80102133:	89 e5                	mov    %esp,%ebp
80102135:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102138:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010213f:	00 
80102140:	8b 45 0c             	mov    0xc(%ebp),%eax
80102143:	89 44 24 04          	mov    %eax,0x4(%esp)
80102147:	8b 45 08             	mov    0x8(%ebp),%eax
8010214a:	89 04 24             	mov    %eax,(%esp)
8010214d:	e8 17 ff ff ff       	call   80102069 <dirlookup>
80102152:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102155:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102159:	74 15                	je     80102170 <dirlink+0x3e>
    iput(ip);
8010215b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010215e:	89 04 24             	mov    %eax,(%esp)
80102161:	e8 94 f8 ff ff       	call   801019fa <iput>
    return -1;
80102166:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010216b:	e9 b7 00 00 00       	jmp    80102227 <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102170:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102177:	eb 46                	jmp    801021bf <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217c:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102183:	00 
80102184:	89 44 24 08          	mov    %eax,0x8(%esp)
80102188:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010218b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010218f:	8b 45 08             	mov    0x8(%ebp),%eax
80102192:	89 04 24             	mov    %eax,(%esp)
80102195:	e8 ba fb ff ff       	call   80101d54 <readi>
8010219a:	83 f8 10             	cmp    $0x10,%eax
8010219d:	74 0c                	je     801021ab <dirlink+0x79>
      panic("dirlink read");
8010219f:	c7 04 24 c7 81 10 80 	movl   $0x801081c7,(%esp)
801021a6:	e8 8f e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
801021ab:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021af:	66 85 c0             	test   %ax,%ax
801021b2:	75 02                	jne    801021b6 <dirlink+0x84>
      break;
801021b4:	eb 16                	jmp    801021cc <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021b9:	83 c0 10             	add    $0x10,%eax
801021bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021c2:	8b 45 08             	mov    0x8(%ebp),%eax
801021c5:	8b 40 18             	mov    0x18(%eax),%eax
801021c8:	39 c2                	cmp    %eax,%edx
801021ca:	72 ad                	jb     80102179 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801021cc:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021d3:	00 
801021d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801021d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801021db:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021de:	83 c0 02             	add    $0x2,%eax
801021e1:	89 04 24             	mov    %eax,(%esp)
801021e4:	e8 ce 2c 00 00       	call   80104eb7 <strncpy>
  de.inum = inum;
801021e9:	8b 45 10             	mov    0x10(%ebp),%eax
801021ec:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021f3:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021fa:	00 
801021fb:	89 44 24 08          	mov    %eax,0x8(%esp)
801021ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102202:	89 44 24 04          	mov    %eax,0x4(%esp)
80102206:	8b 45 08             	mov    0x8(%ebp),%eax
80102209:	89 04 24             	mov    %eax,(%esp)
8010220c:	e8 a7 fc ff ff       	call   80101eb8 <writei>
80102211:	83 f8 10             	cmp    $0x10,%eax
80102214:	74 0c                	je     80102222 <dirlink+0xf0>
    panic("dirlink");
80102216:	c7 04 24 d4 81 10 80 	movl   $0x801081d4,(%esp)
8010221d:	e8 18 e3 ff ff       	call   8010053a <panic>
  
  return 0;
80102222:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102227:	c9                   	leave  
80102228:	c3                   	ret    

80102229 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102229:	55                   	push   %ebp
8010222a:	89 e5                	mov    %esp,%ebp
8010222c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010222f:	eb 04                	jmp    80102235 <skipelem+0xc>
    path++;
80102231:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102235:	8b 45 08             	mov    0x8(%ebp),%eax
80102238:	0f b6 00             	movzbl (%eax),%eax
8010223b:	3c 2f                	cmp    $0x2f,%al
8010223d:	74 f2                	je     80102231 <skipelem+0x8>
    path++;
  if(*path == 0)
8010223f:	8b 45 08             	mov    0x8(%ebp),%eax
80102242:	0f b6 00             	movzbl (%eax),%eax
80102245:	84 c0                	test   %al,%al
80102247:	75 0a                	jne    80102253 <skipelem+0x2a>
    return 0;
80102249:	b8 00 00 00 00       	mov    $0x0,%eax
8010224e:	e9 86 00 00 00       	jmp    801022d9 <skipelem+0xb0>
  s = path;
80102253:	8b 45 08             	mov    0x8(%ebp),%eax
80102256:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102259:	eb 04                	jmp    8010225f <skipelem+0x36>
    path++;
8010225b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010225f:	8b 45 08             	mov    0x8(%ebp),%eax
80102262:	0f b6 00             	movzbl (%eax),%eax
80102265:	3c 2f                	cmp    $0x2f,%al
80102267:	74 0a                	je     80102273 <skipelem+0x4a>
80102269:	8b 45 08             	mov    0x8(%ebp),%eax
8010226c:	0f b6 00             	movzbl (%eax),%eax
8010226f:	84 c0                	test   %al,%al
80102271:	75 e8                	jne    8010225b <skipelem+0x32>
    path++;
  len = path - s;
80102273:	8b 55 08             	mov    0x8(%ebp),%edx
80102276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102279:	29 c2                	sub    %eax,%edx
8010227b:	89 d0                	mov    %edx,%eax
8010227d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102280:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102284:	7e 1c                	jle    801022a2 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
80102286:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010228d:	00 
8010228e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102291:	89 44 24 04          	mov    %eax,0x4(%esp)
80102295:	8b 45 0c             	mov    0xc(%ebp),%eax
80102298:	89 04 24             	mov    %eax,(%esp)
8010229b:	e8 1e 2b 00 00       	call   80104dbe <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022a0:	eb 2a                	jmp    801022cc <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022a5:	89 44 24 08          	mov    %eax,0x8(%esp)
801022a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801022b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801022b3:	89 04 24             	mov    %eax,(%esp)
801022b6:	e8 03 2b 00 00       	call   80104dbe <memmove>
    name[len] = 0;
801022bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801022be:	8b 45 0c             	mov    0xc(%ebp),%eax
801022c1:	01 d0                	add    %edx,%eax
801022c3:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022c6:	eb 04                	jmp    801022cc <skipelem+0xa3>
    path++;
801022c8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022cc:	8b 45 08             	mov    0x8(%ebp),%eax
801022cf:	0f b6 00             	movzbl (%eax),%eax
801022d2:	3c 2f                	cmp    $0x2f,%al
801022d4:	74 f2                	je     801022c8 <skipelem+0x9f>
    path++;
  return path;
801022d6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022d9:	c9                   	leave  
801022da:	c3                   	ret    

801022db <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022db:	55                   	push   %ebp
801022dc:	89 e5                	mov    %esp,%ebp
801022de:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801022e1:	8b 45 08             	mov    0x8(%ebp),%eax
801022e4:	0f b6 00             	movzbl (%eax),%eax
801022e7:	3c 2f                	cmp    $0x2f,%al
801022e9:	75 1c                	jne    80102307 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
801022eb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801022f2:	00 
801022f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801022fa:	e8 44 f4 ff ff       	call   80101743 <iget>
801022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102302:	e9 af 00 00 00       	jmp    801023b6 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102307:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010230d:	8b 40 68             	mov    0x68(%eax),%eax
80102310:	89 04 24             	mov    %eax,(%esp)
80102313:	e8 fd f4 ff ff       	call   80101815 <idup>
80102318:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010231b:	e9 96 00 00 00       	jmp    801023b6 <namex+0xdb>
    ilock(ip);
80102320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102323:	89 04 24             	mov    %eax,(%esp)
80102326:	e8 1c f5 ff ff       	call   80101847 <ilock>
    if(ip->type != T_DIR){
8010232b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010232e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102332:	66 83 f8 01          	cmp    $0x1,%ax
80102336:	74 15                	je     8010234d <namex+0x72>
      iunlockput(ip);
80102338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233b:	89 04 24             	mov    %eax,(%esp)
8010233e:	e8 88 f7 ff ff       	call   80101acb <iunlockput>
      return 0;
80102343:	b8 00 00 00 00       	mov    $0x0,%eax
80102348:	e9 a3 00 00 00       	jmp    801023f0 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
8010234d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102351:	74 1d                	je     80102370 <namex+0x95>
80102353:	8b 45 08             	mov    0x8(%ebp),%eax
80102356:	0f b6 00             	movzbl (%eax),%eax
80102359:	84 c0                	test   %al,%al
8010235b:	75 13                	jne    80102370 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
8010235d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102360:	89 04 24             	mov    %eax,(%esp)
80102363:	e8 2d f6 ff ff       	call   80101995 <iunlock>
      return ip;
80102368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010236b:	e9 80 00 00 00       	jmp    801023f0 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102370:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102377:	00 
80102378:	8b 45 10             	mov    0x10(%ebp),%eax
8010237b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010237f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102382:	89 04 24             	mov    %eax,(%esp)
80102385:	e8 df fc ff ff       	call   80102069 <dirlookup>
8010238a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010238d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102391:	75 12                	jne    801023a5 <namex+0xca>
      iunlockput(ip);
80102393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102396:	89 04 24             	mov    %eax,(%esp)
80102399:	e8 2d f7 ff ff       	call   80101acb <iunlockput>
      return 0;
8010239e:	b8 00 00 00 00       	mov    $0x0,%eax
801023a3:	eb 4b                	jmp    801023f0 <namex+0x115>
    }
    iunlockput(ip);
801023a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a8:	89 04 24             	mov    %eax,(%esp)
801023ab:	e8 1b f7 ff ff       	call   80101acb <iunlockput>
    ip = next;
801023b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023b6:	8b 45 10             	mov    0x10(%ebp),%eax
801023b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801023bd:	8b 45 08             	mov    0x8(%ebp),%eax
801023c0:	89 04 24             	mov    %eax,(%esp)
801023c3:	e8 61 fe ff ff       	call   80102229 <skipelem>
801023c8:	89 45 08             	mov    %eax,0x8(%ebp)
801023cb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801023cf:	0f 85 4b ff ff ff    	jne    80102320 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801023d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023d9:	74 12                	je     801023ed <namex+0x112>
    iput(ip);
801023db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023de:	89 04 24             	mov    %eax,(%esp)
801023e1:	e8 14 f6 ff ff       	call   801019fa <iput>
    return 0;
801023e6:	b8 00 00 00 00       	mov    $0x0,%eax
801023eb:	eb 03                	jmp    801023f0 <namex+0x115>
  }
  return ip;
801023ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801023f0:	c9                   	leave  
801023f1:	c3                   	ret    

801023f2 <namei>:

struct inode*
namei(char *path)
{
801023f2:	55                   	push   %ebp
801023f3:	89 e5                	mov    %esp,%ebp
801023f5:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801023f8:	8d 45 ea             	lea    -0x16(%ebp),%eax
801023fb:	89 44 24 08          	mov    %eax,0x8(%esp)
801023ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102406:	00 
80102407:	8b 45 08             	mov    0x8(%ebp),%eax
8010240a:	89 04 24             	mov    %eax,(%esp)
8010240d:	e8 c9 fe ff ff       	call   801022db <namex>
}
80102412:	c9                   	leave  
80102413:	c3                   	ret    

80102414 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102414:	55                   	push   %ebp
80102415:	89 e5                	mov    %esp,%ebp
80102417:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010241a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010241d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102421:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102428:	00 
80102429:	8b 45 08             	mov    0x8(%ebp),%eax
8010242c:	89 04 24             	mov    %eax,(%esp)
8010242f:	e8 a7 fe ff ff       	call   801022db <namex>
}
80102434:	c9                   	leave  
80102435:	c3                   	ret    

80102436 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102436:	55                   	push   %ebp
80102437:	89 e5                	mov    %esp,%ebp
80102439:	83 ec 14             	sub    $0x14,%esp
8010243c:	8b 45 08             	mov    0x8(%ebp),%eax
8010243f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102443:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102447:	89 c2                	mov    %eax,%edx
80102449:	ec                   	in     (%dx),%al
8010244a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010244d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102451:	c9                   	leave  
80102452:	c3                   	ret    

80102453 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102453:	55                   	push   %ebp
80102454:	89 e5                	mov    %esp,%ebp
80102456:	57                   	push   %edi
80102457:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102458:	8b 55 08             	mov    0x8(%ebp),%edx
8010245b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010245e:	8b 45 10             	mov    0x10(%ebp),%eax
80102461:	89 cb                	mov    %ecx,%ebx
80102463:	89 df                	mov    %ebx,%edi
80102465:	89 c1                	mov    %eax,%ecx
80102467:	fc                   	cld    
80102468:	f3 6d                	rep insl (%dx),%es:(%edi)
8010246a:	89 c8                	mov    %ecx,%eax
8010246c:	89 fb                	mov    %edi,%ebx
8010246e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102471:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102474:	5b                   	pop    %ebx
80102475:	5f                   	pop    %edi
80102476:	5d                   	pop    %ebp
80102477:	c3                   	ret    

80102478 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102478:	55                   	push   %ebp
80102479:	89 e5                	mov    %esp,%ebp
8010247b:	83 ec 08             	sub    $0x8,%esp
8010247e:	8b 55 08             	mov    0x8(%ebp),%edx
80102481:	8b 45 0c             	mov    0xc(%ebp),%eax
80102484:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102488:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010248b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010248f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102493:	ee                   	out    %al,(%dx)
}
80102494:	c9                   	leave  
80102495:	c3                   	ret    

80102496 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102496:	55                   	push   %ebp
80102497:	89 e5                	mov    %esp,%ebp
80102499:	56                   	push   %esi
8010249a:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010249b:	8b 55 08             	mov    0x8(%ebp),%edx
8010249e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024a1:	8b 45 10             	mov    0x10(%ebp),%eax
801024a4:	89 cb                	mov    %ecx,%ebx
801024a6:	89 de                	mov    %ebx,%esi
801024a8:	89 c1                	mov    %eax,%ecx
801024aa:	fc                   	cld    
801024ab:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024ad:	89 c8                	mov    %ecx,%eax
801024af:	89 f3                	mov    %esi,%ebx
801024b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024b4:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024b7:	5b                   	pop    %ebx
801024b8:	5e                   	pop    %esi
801024b9:	5d                   	pop    %ebp
801024ba:	c3                   	ret    

801024bb <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024bb:	55                   	push   %ebp
801024bc:	89 e5                	mov    %esp,%ebp
801024be:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024c1:	90                   	nop
801024c2:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024c9:	e8 68 ff ff ff       	call   80102436 <inb>
801024ce:	0f b6 c0             	movzbl %al,%eax
801024d1:	89 45 fc             	mov    %eax,-0x4(%ebp)
801024d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024d7:	25 c0 00 00 00       	and    $0xc0,%eax
801024dc:	83 f8 40             	cmp    $0x40,%eax
801024df:	75 e1                	jne    801024c2 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801024e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024e5:	74 11                	je     801024f8 <idewait+0x3d>
801024e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024ea:	83 e0 21             	and    $0x21,%eax
801024ed:	85 c0                	test   %eax,%eax
801024ef:	74 07                	je     801024f8 <idewait+0x3d>
    return -1;
801024f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024f6:	eb 05                	jmp    801024fd <idewait+0x42>
  return 0;
801024f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024fd:	c9                   	leave  
801024fe:	c3                   	ret    

801024ff <ideinit>:

void
ideinit(void)
{
801024ff:	55                   	push   %ebp
80102500:	89 e5                	mov    %esp,%ebp
80102502:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102505:	c7 44 24 04 dc 81 10 	movl   $0x801081dc,0x4(%esp)
8010250c:	80 
8010250d:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102514:	e8 61 25 00 00       	call   80104a7a <initlock>
  picenable(IRQ_IDE);
80102519:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102520:	e8 29 15 00 00       	call   80103a4e <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102525:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010252a:	83 e8 01             	sub    $0x1,%eax
8010252d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102531:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102538:	e8 0c 04 00 00       	call   80102949 <ioapicenable>
  idewait(0);
8010253d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102544:	e8 72 ff ff ff       	call   801024bb <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102549:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102550:	00 
80102551:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102558:	e8 1b ff ff ff       	call   80102478 <outb>
  for(i=0; i<1000; i++){
8010255d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102564:	eb 20                	jmp    80102586 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102566:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010256d:	e8 c4 fe ff ff       	call   80102436 <inb>
80102572:	84 c0                	test   %al,%al
80102574:	74 0c                	je     80102582 <ideinit+0x83>
      havedisk1 = 1;
80102576:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
8010257d:	00 00 00 
      break;
80102580:	eb 0d                	jmp    8010258f <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102582:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102586:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010258d:	7e d7                	jle    80102566 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010258f:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102596:	00 
80102597:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010259e:	e8 d5 fe ff ff       	call   80102478 <outb>
}
801025a3:	c9                   	leave  
801025a4:	c3                   	ret    

801025a5 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025a5:	55                   	push   %ebp
801025a6:	89 e5                	mov    %esp,%ebp
801025a8:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025ab:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025af:	75 0c                	jne    801025bd <idestart+0x18>
    panic("idestart");
801025b1:	c7 04 24 e0 81 10 80 	movl   $0x801081e0,(%esp)
801025b8:	e8 7d df ff ff       	call   8010053a <panic>

  idewait(0);
801025bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025c4:	e8 f2 fe ff ff       	call   801024bb <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025d0:	00 
801025d1:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801025d8:	e8 9b fe ff ff       	call   80102478 <outb>
  outb(0x1f2, 1);  // number of sectors
801025dd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801025e4:	00 
801025e5:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801025ec:	e8 87 fe ff ff       	call   80102478 <outb>
  outb(0x1f3, b->sector & 0xff);
801025f1:	8b 45 08             	mov    0x8(%ebp),%eax
801025f4:	8b 40 08             	mov    0x8(%eax),%eax
801025f7:	0f b6 c0             	movzbl %al,%eax
801025fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801025fe:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102605:	e8 6e fe ff ff       	call   80102478 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010260a:	8b 45 08             	mov    0x8(%ebp),%eax
8010260d:	8b 40 08             	mov    0x8(%eax),%eax
80102610:	c1 e8 08             	shr    $0x8,%eax
80102613:	0f b6 c0             	movzbl %al,%eax
80102616:	89 44 24 04          	mov    %eax,0x4(%esp)
8010261a:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102621:	e8 52 fe ff ff       	call   80102478 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102626:	8b 45 08             	mov    0x8(%ebp),%eax
80102629:	8b 40 08             	mov    0x8(%eax),%eax
8010262c:	c1 e8 10             	shr    $0x10,%eax
8010262f:	0f b6 c0             	movzbl %al,%eax
80102632:	89 44 24 04          	mov    %eax,0x4(%esp)
80102636:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010263d:	e8 36 fe ff ff       	call   80102478 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102642:	8b 45 08             	mov    0x8(%ebp),%eax
80102645:	8b 40 04             	mov    0x4(%eax),%eax
80102648:	83 e0 01             	and    $0x1,%eax
8010264b:	c1 e0 04             	shl    $0x4,%eax
8010264e:	89 c2                	mov    %eax,%edx
80102650:	8b 45 08             	mov    0x8(%ebp),%eax
80102653:	8b 40 08             	mov    0x8(%eax),%eax
80102656:	c1 e8 18             	shr    $0x18,%eax
80102659:	83 e0 0f             	and    $0xf,%eax
8010265c:	09 d0                	or     %edx,%eax
8010265e:	83 c8 e0             	or     $0xffffffe0,%eax
80102661:	0f b6 c0             	movzbl %al,%eax
80102664:	89 44 24 04          	mov    %eax,0x4(%esp)
80102668:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010266f:	e8 04 fe ff ff       	call   80102478 <outb>
  if(b->flags & B_DIRTY){
80102674:	8b 45 08             	mov    0x8(%ebp),%eax
80102677:	8b 00                	mov    (%eax),%eax
80102679:	83 e0 04             	and    $0x4,%eax
8010267c:	85 c0                	test   %eax,%eax
8010267e:	74 34                	je     801026b4 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102680:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102687:	00 
80102688:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010268f:	e8 e4 fd ff ff       	call   80102478 <outb>
    outsl(0x1f0, b->data, 512/4);
80102694:	8b 45 08             	mov    0x8(%ebp),%eax
80102697:	83 c0 18             	add    $0x18,%eax
8010269a:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026a1:	00 
801026a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801026a6:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026ad:	e8 e4 fd ff ff       	call   80102496 <outsl>
801026b2:	eb 14                	jmp    801026c8 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026b4:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026bb:	00 
801026bc:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026c3:	e8 b0 fd ff ff       	call   80102478 <outb>
  }
}
801026c8:	c9                   	leave  
801026c9:	c3                   	ret    

801026ca <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026ca:	55                   	push   %ebp
801026cb:	89 e5                	mov    %esp,%ebp
801026cd:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801026d0:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801026d7:	e8 bf 23 00 00       	call   80104a9b <acquire>
  if((b = idequeue) == 0){
801026dc:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801026e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801026e8:	75 11                	jne    801026fb <ideintr+0x31>
    release(&idelock);
801026ea:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801026f1:	e8 07 24 00 00       	call   80104afd <release>
    // cprintf("spurious IDE interrupt\n");
    return;
801026f6:	e9 90 00 00 00       	jmp    8010278b <ideintr+0xc1>
  }
  idequeue = b->qnext;
801026fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026fe:	8b 40 14             	mov    0x14(%eax),%eax
80102701:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102709:	8b 00                	mov    (%eax),%eax
8010270b:	83 e0 04             	and    $0x4,%eax
8010270e:	85 c0                	test   %eax,%eax
80102710:	75 2e                	jne    80102740 <ideintr+0x76>
80102712:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102719:	e8 9d fd ff ff       	call   801024bb <idewait>
8010271e:	85 c0                	test   %eax,%eax
80102720:	78 1e                	js     80102740 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102722:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102725:	83 c0 18             	add    $0x18,%eax
80102728:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010272f:	00 
80102730:	89 44 24 04          	mov    %eax,0x4(%esp)
80102734:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010273b:	e8 13 fd ff ff       	call   80102453 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102743:	8b 00                	mov    (%eax),%eax
80102745:	83 c8 02             	or     $0x2,%eax
80102748:	89 c2                	mov    %eax,%edx
8010274a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010274d:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010274f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102752:	8b 00                	mov    (%eax),%eax
80102754:	83 e0 fb             	and    $0xfffffffb,%eax
80102757:	89 c2                	mov    %eax,%edx
80102759:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010275c:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010275e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102761:	89 04 24             	mov    %eax,(%esp)
80102764:	e8 3b 21 00 00       	call   801048a4 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102769:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010276e:	85 c0                	test   %eax,%eax
80102770:	74 0d                	je     8010277f <ideintr+0xb5>
    idestart(idequeue);
80102772:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102777:	89 04 24             	mov    %eax,(%esp)
8010277a:	e8 26 fe ff ff       	call   801025a5 <idestart>

  release(&idelock);
8010277f:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102786:	e8 72 23 00 00       	call   80104afd <release>
}
8010278b:	c9                   	leave  
8010278c:	c3                   	ret    

8010278d <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010278d:	55                   	push   %ebp
8010278e:	89 e5                	mov    %esp,%ebp
80102790:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102793:	8b 45 08             	mov    0x8(%ebp),%eax
80102796:	8b 00                	mov    (%eax),%eax
80102798:	83 e0 01             	and    $0x1,%eax
8010279b:	85 c0                	test   %eax,%eax
8010279d:	75 0c                	jne    801027ab <iderw+0x1e>
    panic("iderw: buf not busy");
8010279f:	c7 04 24 e9 81 10 80 	movl   $0x801081e9,(%esp)
801027a6:	e8 8f dd ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027ab:	8b 45 08             	mov    0x8(%ebp),%eax
801027ae:	8b 00                	mov    (%eax),%eax
801027b0:	83 e0 06             	and    $0x6,%eax
801027b3:	83 f8 02             	cmp    $0x2,%eax
801027b6:	75 0c                	jne    801027c4 <iderw+0x37>
    panic("iderw: nothing to do");
801027b8:	c7 04 24 fd 81 10 80 	movl   $0x801081fd,(%esp)
801027bf:	e8 76 dd ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
801027c4:	8b 45 08             	mov    0x8(%ebp),%eax
801027c7:	8b 40 04             	mov    0x4(%eax),%eax
801027ca:	85 c0                	test   %eax,%eax
801027cc:	74 15                	je     801027e3 <iderw+0x56>
801027ce:	a1 38 b6 10 80       	mov    0x8010b638,%eax
801027d3:	85 c0                	test   %eax,%eax
801027d5:	75 0c                	jne    801027e3 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027d7:	c7 04 24 12 82 10 80 	movl   $0x80108212,(%esp)
801027de:	e8 57 dd ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
801027e3:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801027ea:	e8 ac 22 00 00       	call   80104a9b <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801027ef:	8b 45 08             	mov    0x8(%ebp),%eax
801027f2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801027f9:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102800:	eb 0b                	jmp    8010280d <iderw+0x80>
80102802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102805:	8b 00                	mov    (%eax),%eax
80102807:	83 c0 14             	add    $0x14,%eax
8010280a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010280d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102810:	8b 00                	mov    (%eax),%eax
80102812:	85 c0                	test   %eax,%eax
80102814:	75 ec                	jne    80102802 <iderw+0x75>
    ;
  *pp = b;
80102816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102819:	8b 55 08             	mov    0x8(%ebp),%edx
8010281c:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
8010281e:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102823:	3b 45 08             	cmp    0x8(%ebp),%eax
80102826:	75 0d                	jne    80102835 <iderw+0xa8>
    idestart(b);
80102828:	8b 45 08             	mov    0x8(%ebp),%eax
8010282b:	89 04 24             	mov    %eax,(%esp)
8010282e:	e8 72 fd ff ff       	call   801025a5 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102833:	eb 15                	jmp    8010284a <iderw+0xbd>
80102835:	eb 13                	jmp    8010284a <iderw+0xbd>
    sleep(b, &idelock);
80102837:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
8010283e:	80 
8010283f:	8b 45 08             	mov    0x8(%ebp),%eax
80102842:	89 04 24             	mov    %eax,(%esp)
80102845:	e8 7e 1f 00 00       	call   801047c8 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010284a:	8b 45 08             	mov    0x8(%ebp),%eax
8010284d:	8b 00                	mov    (%eax),%eax
8010284f:	83 e0 06             	and    $0x6,%eax
80102852:	83 f8 02             	cmp    $0x2,%eax
80102855:	75 e0                	jne    80102837 <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
80102857:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010285e:	e8 9a 22 00 00       	call   80104afd <release>
}
80102863:	c9                   	leave  
80102864:	c3                   	ret    

80102865 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102865:	55                   	push   %ebp
80102866:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102868:	a1 34 f8 10 80       	mov    0x8010f834,%eax
8010286d:	8b 55 08             	mov    0x8(%ebp),%edx
80102870:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102872:	a1 34 f8 10 80       	mov    0x8010f834,%eax
80102877:	8b 40 10             	mov    0x10(%eax),%eax
}
8010287a:	5d                   	pop    %ebp
8010287b:	c3                   	ret    

8010287c <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010287c:	55                   	push   %ebp
8010287d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010287f:	a1 34 f8 10 80       	mov    0x8010f834,%eax
80102884:	8b 55 08             	mov    0x8(%ebp),%edx
80102887:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102889:	a1 34 f8 10 80       	mov    0x8010f834,%eax
8010288e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102891:	89 50 10             	mov    %edx,0x10(%eax)
}
80102894:	5d                   	pop    %ebp
80102895:	c3                   	ret    

80102896 <ioapicinit>:

void
ioapicinit(void)
{
80102896:	55                   	push   %ebp
80102897:	89 e5                	mov    %esp,%ebp
80102899:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
8010289c:	a1 04 f9 10 80       	mov    0x8010f904,%eax
801028a1:	85 c0                	test   %eax,%eax
801028a3:	75 05                	jne    801028aa <ioapicinit+0x14>
    return;
801028a5:	e9 9d 00 00 00       	jmp    80102947 <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
801028aa:	c7 05 34 f8 10 80 00 	movl   $0xfec00000,0x8010f834
801028b1:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028bb:	e8 a5 ff ff ff       	call   80102865 <ioapicread>
801028c0:	c1 e8 10             	shr    $0x10,%eax
801028c3:	25 ff 00 00 00       	and    $0xff,%eax
801028c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801028cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028d2:	e8 8e ff ff ff       	call   80102865 <ioapicread>
801028d7:	c1 e8 18             	shr    $0x18,%eax
801028da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801028dd:	0f b6 05 00 f9 10 80 	movzbl 0x8010f900,%eax
801028e4:	0f b6 c0             	movzbl %al,%eax
801028e7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801028ea:	74 0c                	je     801028f8 <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801028ec:	c7 04 24 30 82 10 80 	movl   $0x80108230,(%esp)
801028f3:	e8 a8 da ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801028f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028ff:	eb 3e                	jmp    8010293f <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102904:	83 c0 20             	add    $0x20,%eax
80102907:	0d 00 00 01 00       	or     $0x10000,%eax
8010290c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010290f:	83 c2 08             	add    $0x8,%edx
80102912:	01 d2                	add    %edx,%edx
80102914:	89 44 24 04          	mov    %eax,0x4(%esp)
80102918:	89 14 24             	mov    %edx,(%esp)
8010291b:	e8 5c ff ff ff       	call   8010287c <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102923:	83 c0 08             	add    $0x8,%eax
80102926:	01 c0                	add    %eax,%eax
80102928:	83 c0 01             	add    $0x1,%eax
8010292b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102932:	00 
80102933:	89 04 24             	mov    %eax,(%esp)
80102936:	e8 41 ff ff ff       	call   8010287c <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010293b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010293f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102942:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102945:	7e ba                	jle    80102901 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102947:	c9                   	leave  
80102948:	c3                   	ret    

80102949 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102949:	55                   	push   %ebp
8010294a:	89 e5                	mov    %esp,%ebp
8010294c:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
8010294f:	a1 04 f9 10 80       	mov    0x8010f904,%eax
80102954:	85 c0                	test   %eax,%eax
80102956:	75 02                	jne    8010295a <ioapicenable+0x11>
    return;
80102958:	eb 37                	jmp    80102991 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010295a:	8b 45 08             	mov    0x8(%ebp),%eax
8010295d:	83 c0 20             	add    $0x20,%eax
80102960:	8b 55 08             	mov    0x8(%ebp),%edx
80102963:	83 c2 08             	add    $0x8,%edx
80102966:	01 d2                	add    %edx,%edx
80102968:	89 44 24 04          	mov    %eax,0x4(%esp)
8010296c:	89 14 24             	mov    %edx,(%esp)
8010296f:	e8 08 ff ff ff       	call   8010287c <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102974:	8b 45 0c             	mov    0xc(%ebp),%eax
80102977:	c1 e0 18             	shl    $0x18,%eax
8010297a:	8b 55 08             	mov    0x8(%ebp),%edx
8010297d:	83 c2 08             	add    $0x8,%edx
80102980:	01 d2                	add    %edx,%edx
80102982:	83 c2 01             	add    $0x1,%edx
80102985:	89 44 24 04          	mov    %eax,0x4(%esp)
80102989:	89 14 24             	mov    %edx,(%esp)
8010298c:	e8 eb fe ff ff       	call   8010287c <ioapicwrite>
}
80102991:	c9                   	leave  
80102992:	c3                   	ret    

80102993 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102993:	55                   	push   %ebp
80102994:	89 e5                	mov    %esp,%ebp
80102996:	8b 45 08             	mov    0x8(%ebp),%eax
80102999:	05 00 00 00 80       	add    $0x80000000,%eax
8010299e:	5d                   	pop    %ebp
8010299f:	c3                   	ret    

801029a0 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029a0:	55                   	push   %ebp
801029a1:	89 e5                	mov    %esp,%ebp
801029a3:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029a6:	c7 44 24 04 62 82 10 	movl   $0x80108262,0x4(%esp)
801029ad:	80 
801029ae:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
801029b5:	e8 c0 20 00 00       	call   80104a7a <initlock>
  kmem.use_lock = 0;
801029ba:	c7 05 74 f8 10 80 00 	movl   $0x0,0x8010f874
801029c1:	00 00 00 
  freerange(vstart, vend);
801029c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801029c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801029cb:	8b 45 08             	mov    0x8(%ebp),%eax
801029ce:	89 04 24             	mov    %eax,(%esp)
801029d1:	e8 26 00 00 00       	call   801029fc <freerange>
}
801029d6:	c9                   	leave  
801029d7:	c3                   	ret    

801029d8 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801029d8:	55                   	push   %ebp
801029d9:	89 e5                	mov    %esp,%ebp
801029db:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
801029de:	8b 45 0c             	mov    0xc(%ebp),%eax
801029e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801029e5:	8b 45 08             	mov    0x8(%ebp),%eax
801029e8:	89 04 24             	mov    %eax,(%esp)
801029eb:	e8 0c 00 00 00       	call   801029fc <freerange>
  kmem.use_lock = 1;
801029f0:	c7 05 74 f8 10 80 01 	movl   $0x1,0x8010f874
801029f7:	00 00 00 
}
801029fa:	c9                   	leave  
801029fb:	c3                   	ret    

801029fc <freerange>:

void
freerange(void *vstart, void *vend)
{
801029fc:	55                   	push   %ebp
801029fd:	89 e5                	mov    %esp,%ebp
801029ff:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a02:	8b 45 08             	mov    0x8(%ebp),%eax
80102a05:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a12:	eb 12                	jmp    80102a26 <freerange+0x2a>
    kfree(p);
80102a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a17:	89 04 24             	mov    %eax,(%esp)
80102a1a:	e8 16 00 00 00       	call   80102a35 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a1f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a29:	05 00 10 00 00       	add    $0x1000,%eax
80102a2e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a31:	76 e1                	jbe    80102a14 <freerange+0x18>
    kfree(p);
}
80102a33:	c9                   	leave  
80102a34:	c3                   	ret    

80102a35 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a35:	55                   	push   %ebp
80102a36:	89 e5                	mov    %esp,%ebp
80102a38:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a3b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a3e:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a43:	85 c0                	test   %eax,%eax
80102a45:	75 1b                	jne    80102a62 <kfree+0x2d>
80102a47:	81 7d 08 fc 44 11 80 	cmpl   $0x801144fc,0x8(%ebp)
80102a4e:	72 12                	jb     80102a62 <kfree+0x2d>
80102a50:	8b 45 08             	mov    0x8(%ebp),%eax
80102a53:	89 04 24             	mov    %eax,(%esp)
80102a56:	e8 38 ff ff ff       	call   80102993 <v2p>
80102a5b:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a60:	76 0c                	jbe    80102a6e <kfree+0x39>
    panic("kfree");
80102a62:	c7 04 24 67 82 10 80 	movl   $0x80108267,(%esp)
80102a69:	e8 cc da ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a6e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a75:	00 
80102a76:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a7d:	00 
80102a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a81:	89 04 24             	mov    %eax,(%esp)
80102a84:	e8 66 22 00 00       	call   80104cef <memset>

  if(kmem.use_lock)
80102a89:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102a8e:	85 c0                	test   %eax,%eax
80102a90:	74 0c                	je     80102a9e <kfree+0x69>
    acquire(&kmem.lock);
80102a92:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102a99:	e8 fd 1f 00 00       	call   80104a9b <acquire>
  r = (struct run*)v;
80102a9e:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102aa4:	8b 15 78 f8 10 80    	mov    0x8010f878,%edx
80102aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aad:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab2:	a3 78 f8 10 80       	mov    %eax,0x8010f878
  if(kmem.use_lock)
80102ab7:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102abc:	85 c0                	test   %eax,%eax
80102abe:	74 0c                	je     80102acc <kfree+0x97>
    release(&kmem.lock);
80102ac0:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102ac7:	e8 31 20 00 00       	call   80104afd <release>
}
80102acc:	c9                   	leave  
80102acd:	c3                   	ret    

80102ace <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102ace:	55                   	push   %ebp
80102acf:	89 e5                	mov    %esp,%ebp
80102ad1:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102ad4:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102ad9:	85 c0                	test   %eax,%eax
80102adb:	74 0c                	je     80102ae9 <kalloc+0x1b>
    acquire(&kmem.lock);
80102add:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102ae4:	e8 b2 1f 00 00       	call   80104a9b <acquire>
  r = kmem.freelist;
80102ae9:	a1 78 f8 10 80       	mov    0x8010f878,%eax
80102aee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102af1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102af5:	74 0a                	je     80102b01 <kalloc+0x33>
    kmem.freelist = r->next;
80102af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102afa:	8b 00                	mov    (%eax),%eax
80102afc:	a3 78 f8 10 80       	mov    %eax,0x8010f878
  if(kmem.use_lock)
80102b01:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102b06:	85 c0                	test   %eax,%eax
80102b08:	74 0c                	je     80102b16 <kalloc+0x48>
    release(&kmem.lock);
80102b0a:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102b11:	e8 e7 1f 00 00       	call   80104afd <release>
  return (char*)r;
80102b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b19:	c9                   	leave  
80102b1a:	c3                   	ret    

80102b1b <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b1b:	55                   	push   %ebp
80102b1c:	89 e5                	mov    %esp,%ebp
80102b1e:	83 ec 14             	sub    $0x14,%esp
80102b21:	8b 45 08             	mov    0x8(%ebp),%eax
80102b24:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b28:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102b2c:	89 c2                	mov    %eax,%edx
80102b2e:	ec                   	in     (%dx),%al
80102b2f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102b32:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102b36:	c9                   	leave  
80102b37:	c3                   	ret    

80102b38 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b38:	55                   	push   %ebp
80102b39:	89 e5                	mov    %esp,%ebp
80102b3b:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b3e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b45:	e8 d1 ff ff ff       	call   80102b1b <inb>
80102b4a:	0f b6 c0             	movzbl %al,%eax
80102b4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b53:	83 e0 01             	and    $0x1,%eax
80102b56:	85 c0                	test   %eax,%eax
80102b58:	75 0a                	jne    80102b64 <kbdgetc+0x2c>
    return -1;
80102b5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b5f:	e9 25 01 00 00       	jmp    80102c89 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102b64:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102b6b:	e8 ab ff ff ff       	call   80102b1b <inb>
80102b70:	0f b6 c0             	movzbl %al,%eax
80102b73:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102b76:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102b7d:	75 17                	jne    80102b96 <kbdgetc+0x5e>
    shift |= E0ESC;
80102b7f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102b84:	83 c8 40             	or     $0x40,%eax
80102b87:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102b8c:	b8 00 00 00 00       	mov    $0x0,%eax
80102b91:	e9 f3 00 00 00       	jmp    80102c89 <kbdgetc+0x151>
  } else if(data & 0x80){
80102b96:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102b99:	25 80 00 00 00       	and    $0x80,%eax
80102b9e:	85 c0                	test   %eax,%eax
80102ba0:	74 45                	je     80102be7 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ba2:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ba7:	83 e0 40             	and    $0x40,%eax
80102baa:	85 c0                	test   %eax,%eax
80102bac:	75 08                	jne    80102bb6 <kbdgetc+0x7e>
80102bae:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bb1:	83 e0 7f             	and    $0x7f,%eax
80102bb4:	eb 03                	jmp    80102bb9 <kbdgetc+0x81>
80102bb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bb9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102bbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bbf:	05 20 90 10 80       	add    $0x80109020,%eax
80102bc4:	0f b6 00             	movzbl (%eax),%eax
80102bc7:	83 c8 40             	or     $0x40,%eax
80102bca:	0f b6 c0             	movzbl %al,%eax
80102bcd:	f7 d0                	not    %eax
80102bcf:	89 c2                	mov    %eax,%edx
80102bd1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bd6:	21 d0                	and    %edx,%eax
80102bd8:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102bdd:	b8 00 00 00 00       	mov    $0x0,%eax
80102be2:	e9 a2 00 00 00       	jmp    80102c89 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102be7:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bec:	83 e0 40             	and    $0x40,%eax
80102bef:	85 c0                	test   %eax,%eax
80102bf1:	74 14                	je     80102c07 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102bf3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102bfa:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bff:	83 e0 bf             	and    $0xffffffbf,%eax
80102c02:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102c07:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c0a:	05 20 90 10 80       	add    $0x80109020,%eax
80102c0f:	0f b6 00             	movzbl (%eax),%eax
80102c12:	0f b6 d0             	movzbl %al,%edx
80102c15:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c1a:	09 d0                	or     %edx,%eax
80102c1c:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102c21:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c24:	05 20 91 10 80       	add    $0x80109120,%eax
80102c29:	0f b6 00             	movzbl (%eax),%eax
80102c2c:	0f b6 d0             	movzbl %al,%edx
80102c2f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c34:	31 d0                	xor    %edx,%eax
80102c36:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c3b:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c40:	83 e0 03             	and    $0x3,%eax
80102c43:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102c4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c4d:	01 d0                	add    %edx,%eax
80102c4f:	0f b6 00             	movzbl (%eax),%eax
80102c52:	0f b6 c0             	movzbl %al,%eax
80102c55:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c58:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c5d:	83 e0 08             	and    $0x8,%eax
80102c60:	85 c0                	test   %eax,%eax
80102c62:	74 22                	je     80102c86 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102c64:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102c68:	76 0c                	jbe    80102c76 <kbdgetc+0x13e>
80102c6a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102c6e:	77 06                	ja     80102c76 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102c70:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102c74:	eb 10                	jmp    80102c86 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102c76:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102c7a:	76 0a                	jbe    80102c86 <kbdgetc+0x14e>
80102c7c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102c80:	77 04                	ja     80102c86 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102c82:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102c86:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102c89:	c9                   	leave  
80102c8a:	c3                   	ret    

80102c8b <kbdintr>:

void
kbdintr(void)
{
80102c8b:	55                   	push   %ebp
80102c8c:	89 e5                	mov    %esp,%ebp
80102c8e:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102c91:	c7 04 24 38 2b 10 80 	movl   $0x80102b38,(%esp)
80102c98:	e8 10 db ff ff       	call   801007ad <consoleintr>
}
80102c9d:	c9                   	leave  
80102c9e:	c3                   	ret    

80102c9f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102c9f:	55                   	push   %ebp
80102ca0:	89 e5                	mov    %esp,%ebp
80102ca2:	83 ec 08             	sub    $0x8,%esp
80102ca5:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102caf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cb2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102cb6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102cba:	ee                   	out    %al,(%dx)
}
80102cbb:	c9                   	leave  
80102cbc:	c3                   	ret    

80102cbd <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102cbd:	55                   	push   %ebp
80102cbe:	89 e5                	mov    %esp,%ebp
80102cc0:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102cc3:	9c                   	pushf  
80102cc4:	58                   	pop    %eax
80102cc5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102cc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102ccb:	c9                   	leave  
80102ccc:	c3                   	ret    

80102ccd <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102ccd:	55                   	push   %ebp
80102cce:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102cd0:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102cd5:	8b 55 08             	mov    0x8(%ebp),%edx
80102cd8:	c1 e2 02             	shl    $0x2,%edx
80102cdb:	01 c2                	add    %eax,%edx
80102cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ce0:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ce2:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102ce7:	83 c0 20             	add    $0x20,%eax
80102cea:	8b 00                	mov    (%eax),%eax
}
80102cec:	5d                   	pop    %ebp
80102ced:	c3                   	ret    

80102cee <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102cee:	55                   	push   %ebp
80102cef:	89 e5                	mov    %esp,%ebp
80102cf1:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102cf4:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102cf9:	85 c0                	test   %eax,%eax
80102cfb:	75 05                	jne    80102d02 <lapicinit+0x14>
    return;
80102cfd:	e9 43 01 00 00       	jmp    80102e45 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d02:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d09:	00 
80102d0a:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d11:	e8 b7 ff ff ff       	call   80102ccd <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d16:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d1d:	00 
80102d1e:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d25:	e8 a3 ff ff ff       	call   80102ccd <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102d2a:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d31:	00 
80102d32:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d39:	e8 8f ff ff ff       	call   80102ccd <lapicw>
  lapicw(TICR, 10000000); 
80102d3e:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102d45:	00 
80102d46:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102d4d:	e8 7b ff ff ff       	call   80102ccd <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102d52:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d59:	00 
80102d5a:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102d61:	e8 67 ff ff ff       	call   80102ccd <lapicw>
  lapicw(LINT1, MASKED);
80102d66:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d6d:	00 
80102d6e:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102d75:	e8 53 ff ff ff       	call   80102ccd <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102d7a:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102d7f:	83 c0 30             	add    $0x30,%eax
80102d82:	8b 00                	mov    (%eax),%eax
80102d84:	c1 e8 10             	shr    $0x10,%eax
80102d87:	0f b6 c0             	movzbl %al,%eax
80102d8a:	83 f8 03             	cmp    $0x3,%eax
80102d8d:	76 14                	jbe    80102da3 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102d8f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d96:	00 
80102d97:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102d9e:	e8 2a ff ff ff       	call   80102ccd <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102da3:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102daa:	00 
80102dab:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102db2:	e8 16 ff ff ff       	call   80102ccd <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102db7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102dbe:	00 
80102dbf:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102dc6:	e8 02 ff ff ff       	call   80102ccd <lapicw>
  lapicw(ESR, 0);
80102dcb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102dd2:	00 
80102dd3:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102dda:	e8 ee fe ff ff       	call   80102ccd <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ddf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102de6:	00 
80102de7:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102dee:	e8 da fe ff ff       	call   80102ccd <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102df3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102dfa:	00 
80102dfb:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e02:	e8 c6 fe ff ff       	call   80102ccd <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e07:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e0e:	00 
80102e0f:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e16:	e8 b2 fe ff ff       	call   80102ccd <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e1b:	90                   	nop
80102e1c:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102e21:	05 00 03 00 00       	add    $0x300,%eax
80102e26:	8b 00                	mov    (%eax),%eax
80102e28:	25 00 10 00 00       	and    $0x1000,%eax
80102e2d:	85 c0                	test   %eax,%eax
80102e2f:	75 eb                	jne    80102e1c <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102e31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e38:	00 
80102e39:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102e40:	e8 88 fe ff ff       	call   80102ccd <lapicw>
}
80102e45:	c9                   	leave  
80102e46:	c3                   	ret    

80102e47 <cpunum>:

int
cpunum(void)
{
80102e47:	55                   	push   %ebp
80102e48:	89 e5                	mov    %esp,%ebp
80102e4a:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102e4d:	e8 6b fe ff ff       	call   80102cbd <readeflags>
80102e52:	25 00 02 00 00       	and    $0x200,%eax
80102e57:	85 c0                	test   %eax,%eax
80102e59:	74 25                	je     80102e80 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102e5b:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102e60:	8d 50 01             	lea    0x1(%eax),%edx
80102e63:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102e69:	85 c0                	test   %eax,%eax
80102e6b:	75 13                	jne    80102e80 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102e6d:	8b 45 04             	mov    0x4(%ebp),%eax
80102e70:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e74:	c7 04 24 70 82 10 80 	movl   $0x80108270,(%esp)
80102e7b:	e8 20 d5 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102e80:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102e85:	85 c0                	test   %eax,%eax
80102e87:	74 0f                	je     80102e98 <cpunum+0x51>
    return lapic[ID]>>24;
80102e89:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102e8e:	83 c0 20             	add    $0x20,%eax
80102e91:	8b 00                	mov    (%eax),%eax
80102e93:	c1 e8 18             	shr    $0x18,%eax
80102e96:	eb 05                	jmp    80102e9d <cpunum+0x56>
  return 0;
80102e98:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102e9d:	c9                   	leave  
80102e9e:	c3                   	ret    

80102e9f <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102e9f:	55                   	push   %ebp
80102ea0:	89 e5                	mov    %esp,%ebp
80102ea2:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102ea5:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102eaa:	85 c0                	test   %eax,%eax
80102eac:	74 14                	je     80102ec2 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102eae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eb5:	00 
80102eb6:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102ebd:	e8 0b fe ff ff       	call   80102ccd <lapicw>
}
80102ec2:	c9                   	leave  
80102ec3:	c3                   	ret    

80102ec4 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102ec4:	55                   	push   %ebp
80102ec5:	89 e5                	mov    %esp,%ebp
}
80102ec7:	5d                   	pop    %ebp
80102ec8:	c3                   	ret    

80102ec9 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102ec9:	55                   	push   %ebp
80102eca:	89 e5                	mov    %esp,%ebp
80102ecc:	83 ec 1c             	sub    $0x1c,%esp
80102ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ed2:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80102ed5:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102edc:	00 
80102edd:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102ee4:	e8 b6 fd ff ff       	call   80102c9f <outb>
  outb(IO_RTC+1, 0x0A);
80102ee9:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102ef0:	00 
80102ef1:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102ef8:	e8 a2 fd ff ff       	call   80102c9f <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102efd:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f04:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f07:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f0c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f0f:	8d 50 02             	lea    0x2(%eax),%edx
80102f12:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f15:	c1 e8 04             	shr    $0x4,%eax
80102f18:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f1b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f1f:	c1 e0 18             	shl    $0x18,%eax
80102f22:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f26:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f2d:	e8 9b fd ff ff       	call   80102ccd <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102f32:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102f39:	00 
80102f3a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f41:	e8 87 fd ff ff       	call   80102ccd <lapicw>
  microdelay(200);
80102f46:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f4d:	e8 72 ff ff ff       	call   80102ec4 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102f52:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102f59:	00 
80102f5a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f61:	e8 67 fd ff ff       	call   80102ccd <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102f66:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102f6d:	e8 52 ff ff ff       	call   80102ec4 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102f72:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102f79:	eb 40                	jmp    80102fbb <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102f7b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f7f:	c1 e0 18             	shl    $0x18,%eax
80102f82:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f86:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f8d:	e8 3b fd ff ff       	call   80102ccd <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102f92:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f95:	c1 e8 0c             	shr    $0xc,%eax
80102f98:	80 cc 06             	or     $0x6,%ah
80102f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f9f:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fa6:	e8 22 fd ff ff       	call   80102ccd <lapicw>
    microdelay(200);
80102fab:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fb2:	e8 0d ff ff ff       	call   80102ec4 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fb7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102fbb:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102fbf:	7e ba                	jle    80102f7b <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80102fc1:	c9                   	leave  
80102fc2:	c3                   	ret    

80102fc3 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80102fc3:	55                   	push   %ebp
80102fc4:	89 e5                	mov    %esp,%ebp
80102fc6:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102fc9:	c7 44 24 04 9c 82 10 	movl   $0x8010829c,0x4(%esp)
80102fd0:	80 
80102fd1:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80102fd8:	e8 9d 1a 00 00       	call   80104a7a <initlock>
  readsb(ROOTDEV, &sb);
80102fdd:	8d 45 e8             	lea    -0x18(%ebp),%eax
80102fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fe4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102feb:	e8 ed e2 ff ff       	call   801012dd <readsb>
  log.start = sb.size - sb.nlog;
80102ff0:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ff6:	29 c2                	sub    %eax,%edx
80102ff8:	89 d0                	mov    %edx,%eax
80102ffa:	a3 b4 f8 10 80       	mov    %eax,0x8010f8b4
  log.size = sb.nlog;
80102fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103002:	a3 b8 f8 10 80       	mov    %eax,0x8010f8b8
  log.dev = ROOTDEV;
80103007:	c7 05 c0 f8 10 80 01 	movl   $0x1,0x8010f8c0
8010300e:	00 00 00 
  recover_from_log();
80103011:	e8 9a 01 00 00       	call   801031b0 <recover_from_log>
}
80103016:	c9                   	leave  
80103017:	c3                   	ret    

80103018 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103018:	55                   	push   %ebp
80103019:	89 e5                	mov    %esp,%ebp
8010301b:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010301e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103025:	e9 8c 00 00 00       	jmp    801030b6 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010302a:	8b 15 b4 f8 10 80    	mov    0x8010f8b4,%edx
80103030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103033:	01 d0                	add    %edx,%eax
80103035:	83 c0 01             	add    $0x1,%eax
80103038:	89 c2                	mov    %eax,%edx
8010303a:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
8010303f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103043:	89 04 24             	mov    %eax,(%esp)
80103046:	e8 5b d1 ff ff       	call   801001a6 <bread>
8010304b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010304e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103051:	83 c0 10             	add    $0x10,%eax
80103054:	8b 04 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%eax
8010305b:	89 c2                	mov    %eax,%edx
8010305d:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
80103062:	89 54 24 04          	mov    %edx,0x4(%esp)
80103066:	89 04 24             	mov    %eax,(%esp)
80103069:	e8 38 d1 ff ff       	call   801001a6 <bread>
8010306e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103071:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103074:	8d 50 18             	lea    0x18(%eax),%edx
80103077:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010307a:	83 c0 18             	add    $0x18,%eax
8010307d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103084:	00 
80103085:	89 54 24 04          	mov    %edx,0x4(%esp)
80103089:	89 04 24             	mov    %eax,(%esp)
8010308c:	e8 2d 1d 00 00       	call   80104dbe <memmove>
    bwrite(dbuf);  // write dst to disk
80103091:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103094:	89 04 24             	mov    %eax,(%esp)
80103097:	e8 41 d1 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
8010309c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010309f:	89 04 24             	mov    %eax,(%esp)
801030a2:	e8 70 d1 ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801030a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030aa:	89 04 24             	mov    %eax,(%esp)
801030ad:	e8 65 d1 ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801030b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030b6:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801030bb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801030be:	0f 8f 66 ff ff ff    	jg     8010302a <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801030c4:	c9                   	leave  
801030c5:	c3                   	ret    

801030c6 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801030c6:	55                   	push   %ebp
801030c7:	89 e5                	mov    %esp,%ebp
801030c9:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801030cc:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
801030d1:	89 c2                	mov    %eax,%edx
801030d3:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
801030d8:	89 54 24 04          	mov    %edx,0x4(%esp)
801030dc:	89 04 24             	mov    %eax,(%esp)
801030df:	e8 c2 d0 ff ff       	call   801001a6 <bread>
801030e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801030e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030ea:	83 c0 18             	add    $0x18,%eax
801030ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801030f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030f3:	8b 00                	mov    (%eax),%eax
801030f5:	a3 c4 f8 10 80       	mov    %eax,0x8010f8c4
  for (i = 0; i < log.lh.n; i++) {
801030fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103101:	eb 1b                	jmp    8010311e <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103103:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103106:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103109:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010310d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103110:	83 c2 10             	add    $0x10,%edx
80103113:	89 04 95 88 f8 10 80 	mov    %eax,-0x7fef0778(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010311a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010311e:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103123:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103126:	7f db                	jg     80103103 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010312b:	89 04 24             	mov    %eax,(%esp)
8010312e:	e8 e4 d0 ff ff       	call   80100217 <brelse>
}
80103133:	c9                   	leave  
80103134:	c3                   	ret    

80103135 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103135:	55                   	push   %ebp
80103136:	89 e5                	mov    %esp,%ebp
80103138:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010313b:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
80103140:	89 c2                	mov    %eax,%edx
80103142:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
80103147:	89 54 24 04          	mov    %edx,0x4(%esp)
8010314b:	89 04 24             	mov    %eax,(%esp)
8010314e:	e8 53 d0 ff ff       	call   801001a6 <bread>
80103153:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103156:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103159:	83 c0 18             	add    $0x18,%eax
8010315c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010315f:	8b 15 c4 f8 10 80    	mov    0x8010f8c4,%edx
80103165:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103168:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010316a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103171:	eb 1b                	jmp    8010318e <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
80103173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103176:	83 c0 10             	add    $0x10,%eax
80103179:	8b 0c 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%ecx
80103180:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103183:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103186:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010318a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010318e:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103193:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103196:	7f db                	jg     80103173 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103198:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010319b:	89 04 24             	mov    %eax,(%esp)
8010319e:	e8 3a d0 ff ff       	call   801001dd <bwrite>
  brelse(buf);
801031a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031a6:	89 04 24             	mov    %eax,(%esp)
801031a9:	e8 69 d0 ff ff       	call   80100217 <brelse>
}
801031ae:	c9                   	leave  
801031af:	c3                   	ret    

801031b0 <recover_from_log>:

static void
recover_from_log(void)
{
801031b0:	55                   	push   %ebp
801031b1:	89 e5                	mov    %esp,%ebp
801031b3:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801031b6:	e8 0b ff ff ff       	call   801030c6 <read_head>
  install_trans(); // if committed, copy from log to disk
801031bb:	e8 58 fe ff ff       	call   80103018 <install_trans>
  log.lh.n = 0;
801031c0:	c7 05 c4 f8 10 80 00 	movl   $0x0,0x8010f8c4
801031c7:	00 00 00 
  write_head(); // clear the log
801031ca:	e8 66 ff ff ff       	call   80103135 <write_head>
}
801031cf:	c9                   	leave  
801031d0:	c3                   	ret    

801031d1 <begin_trans>:

void
begin_trans(void)
{
801031d1:	55                   	push   %ebp
801031d2:	89 e5                	mov    %esp,%ebp
801031d4:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801031d7:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
801031de:	e8 b8 18 00 00       	call   80104a9b <acquire>
  while (log.busy) {
801031e3:	eb 14                	jmp    801031f9 <begin_trans+0x28>
    sleep(&log, &log.lock);
801031e5:	c7 44 24 04 80 f8 10 	movl   $0x8010f880,0x4(%esp)
801031ec:	80 
801031ed:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
801031f4:	e8 cf 15 00 00       	call   801047c8 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
801031f9:	a1 bc f8 10 80       	mov    0x8010f8bc,%eax
801031fe:	85 c0                	test   %eax,%eax
80103200:	75 e3                	jne    801031e5 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
80103202:	c7 05 bc f8 10 80 01 	movl   $0x1,0x8010f8bc
80103209:	00 00 00 
  release(&log.lock);
8010320c:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80103213:	e8 e5 18 00 00       	call   80104afd <release>
}
80103218:	c9                   	leave  
80103219:	c3                   	ret    

8010321a <commit_trans>:

void
commit_trans(void)
{
8010321a:	55                   	push   %ebp
8010321b:	89 e5                	mov    %esp,%ebp
8010321d:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
80103220:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103225:	85 c0                	test   %eax,%eax
80103227:	7e 19                	jle    80103242 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
80103229:	e8 07 ff ff ff       	call   80103135 <write_head>
    install_trans(); // Now install writes to home locations
8010322e:	e8 e5 fd ff ff       	call   80103018 <install_trans>
    log.lh.n = 0; 
80103233:	c7 05 c4 f8 10 80 00 	movl   $0x0,0x8010f8c4
8010323a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010323d:	e8 f3 fe ff ff       	call   80103135 <write_head>
  }
  
  acquire(&log.lock);
80103242:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80103249:	e8 4d 18 00 00       	call   80104a9b <acquire>
  log.busy = 0;
8010324e:	c7 05 bc f8 10 80 00 	movl   $0x0,0x8010f8bc
80103255:	00 00 00 
  wakeup(&log);
80103258:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
8010325f:	e8 40 16 00 00       	call   801048a4 <wakeup>
  release(&log.lock);
80103264:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
8010326b:	e8 8d 18 00 00       	call   80104afd <release>
}
80103270:	c9                   	leave  
80103271:	c3                   	ret    

80103272 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103272:	55                   	push   %ebp
80103273:	89 e5                	mov    %esp,%ebp
80103275:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103278:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
8010327d:	83 f8 09             	cmp    $0x9,%eax
80103280:	7f 12                	jg     80103294 <log_write+0x22>
80103282:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103287:	8b 15 b8 f8 10 80    	mov    0x8010f8b8,%edx
8010328d:	83 ea 01             	sub    $0x1,%edx
80103290:	39 d0                	cmp    %edx,%eax
80103292:	7c 0c                	jl     801032a0 <log_write+0x2e>
    panic("too big a transaction");
80103294:	c7 04 24 a0 82 10 80 	movl   $0x801082a0,(%esp)
8010329b:	e8 9a d2 ff ff       	call   8010053a <panic>
  if (!log.busy)
801032a0:	a1 bc f8 10 80       	mov    0x8010f8bc,%eax
801032a5:	85 c0                	test   %eax,%eax
801032a7:	75 0c                	jne    801032b5 <log_write+0x43>
    panic("write outside of trans");
801032a9:	c7 04 24 b6 82 10 80 	movl   $0x801082b6,(%esp)
801032b0:	e8 85 d2 ff ff       	call   8010053a <panic>

  for (i = 0; i < log.lh.n; i++) {
801032b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032bc:	eb 1f                	jmp    801032dd <log_write+0x6b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
801032be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032c1:	83 c0 10             	add    $0x10,%eax
801032c4:	8b 04 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%eax
801032cb:	89 c2                	mov    %eax,%edx
801032cd:	8b 45 08             	mov    0x8(%ebp),%eax
801032d0:	8b 40 08             	mov    0x8(%eax),%eax
801032d3:	39 c2                	cmp    %eax,%edx
801032d5:	75 02                	jne    801032d9 <log_write+0x67>
      break;
801032d7:	eb 0e                	jmp    801032e7 <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
801032d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032dd:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801032e2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801032e5:	7f d7                	jg     801032be <log_write+0x4c>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
  }
  log.lh.sector[i] = b->sector;
801032e7:	8b 45 08             	mov    0x8(%ebp),%eax
801032ea:	8b 40 08             	mov    0x8(%eax),%eax
801032ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801032f0:	83 c2 10             	add    $0x10,%edx
801032f3:	89 04 95 88 f8 10 80 	mov    %eax,-0x7fef0778(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
801032fa:	8b 15 b4 f8 10 80    	mov    0x8010f8b4,%edx
80103300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103303:	01 d0                	add    %edx,%eax
80103305:	83 c0 01             	add    $0x1,%eax
80103308:	89 c2                	mov    %eax,%edx
8010330a:	8b 45 08             	mov    0x8(%ebp),%eax
8010330d:	8b 40 04             	mov    0x4(%eax),%eax
80103310:	89 54 24 04          	mov    %edx,0x4(%esp)
80103314:	89 04 24             	mov    %eax,(%esp)
80103317:	e8 8a ce ff ff       	call   801001a6 <bread>
8010331c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
8010331f:	8b 45 08             	mov    0x8(%ebp),%eax
80103322:	8d 50 18             	lea    0x18(%eax),%edx
80103325:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103328:	83 c0 18             	add    $0x18,%eax
8010332b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103332:	00 
80103333:	89 54 24 04          	mov    %edx,0x4(%esp)
80103337:	89 04 24             	mov    %eax,(%esp)
8010333a:	e8 7f 1a 00 00       	call   80104dbe <memmove>
  bwrite(lbuf);
8010333f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103342:	89 04 24             	mov    %eax,(%esp)
80103345:	e8 93 ce ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
8010334a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010334d:	89 04 24             	mov    %eax,(%esp)
80103350:	e8 c2 ce ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
80103355:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
8010335a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010335d:	75 0d                	jne    8010336c <log_write+0xfa>
    log.lh.n++;
8010335f:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103364:	83 c0 01             	add    $0x1,%eax
80103367:	a3 c4 f8 10 80       	mov    %eax,0x8010f8c4
  b->flags |= B_DIRTY; // XXX prevent eviction
8010336c:	8b 45 08             	mov    0x8(%ebp),%eax
8010336f:	8b 00                	mov    (%eax),%eax
80103371:	83 c8 04             	or     $0x4,%eax
80103374:	89 c2                	mov    %eax,%edx
80103376:	8b 45 08             	mov    0x8(%ebp),%eax
80103379:	89 10                	mov    %edx,(%eax)
}
8010337b:	c9                   	leave  
8010337c:	c3                   	ret    

8010337d <v2p>:
8010337d:	55                   	push   %ebp
8010337e:	89 e5                	mov    %esp,%ebp
80103380:	8b 45 08             	mov    0x8(%ebp),%eax
80103383:	05 00 00 00 80       	add    $0x80000000,%eax
80103388:	5d                   	pop    %ebp
80103389:	c3                   	ret    

8010338a <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010338a:	55                   	push   %ebp
8010338b:	89 e5                	mov    %esp,%ebp
8010338d:	8b 45 08             	mov    0x8(%ebp),%eax
80103390:	05 00 00 00 80       	add    $0x80000000,%eax
80103395:	5d                   	pop    %ebp
80103396:	c3                   	ret    

80103397 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103397:	55                   	push   %ebp
80103398:	89 e5                	mov    %esp,%ebp
8010339a:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010339d:	8b 55 08             	mov    0x8(%ebp),%edx
801033a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801033a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801033a6:	f0 87 02             	lock xchg %eax,(%edx)
801033a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801033ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801033af:	c9                   	leave  
801033b0:	c3                   	ret    

801033b1 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801033b1:	55                   	push   %ebp
801033b2:	89 e5                	mov    %esp,%ebp
801033b4:	83 e4 f0             	and    $0xfffffff0,%esp
801033b7:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801033ba:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801033c1:	80 
801033c2:	c7 04 24 fc 44 11 80 	movl   $0x801144fc,(%esp)
801033c9:	e8 d2 f5 ff ff       	call   801029a0 <kinit1>
  kvmalloc();      // kernel page table
801033ce:	e8 12 45 00 00       	call   801078e5 <kvmalloc>
  mpinit();        // collect info about this machine
801033d3:	e8 46 04 00 00       	call   8010381e <mpinit>
  lapicinit();
801033d8:	e8 11 f9 ff ff       	call   80102cee <lapicinit>
  seginit();       // set up segments
801033dd:	e8 96 3e 00 00       	call   80107278 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801033e2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801033e8:	0f b6 00             	movzbl (%eax),%eax
801033eb:	0f b6 c0             	movzbl %al,%eax
801033ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801033f2:	c7 04 24 cd 82 10 80 	movl   $0x801082cd,(%esp)
801033f9:	e8 a2 cf ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
801033fe:	e8 79 06 00 00       	call   80103a7c <picinit>
  ioapicinit();    // another interrupt controller
80103403:	e8 8e f4 ff ff       	call   80102896 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103408:	e8 74 d6 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
8010340d:	e8 b5 31 00 00       	call   801065c7 <uartinit>
  pinit();         // process table
80103412:	e8 6f 0b 00 00       	call   80103f86 <pinit>
  tvinit();        // trap vectors
80103417:	e8 5d 2d 00 00       	call   80106179 <tvinit>
  binit();         // buffer cache
8010341c:	e8 13 cc ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103421:	e8 d0 da ff ff       	call   80100ef6 <fileinit>
  iinit();         // inode cache
80103426:	e8 65 e1 ff ff       	call   80101590 <iinit>
  ideinit();       // disk
8010342b:	e8 cf f0 ff ff       	call   801024ff <ideinit>
  if(!ismp)
80103430:	a1 04 f9 10 80       	mov    0x8010f904,%eax
80103435:	85 c0                	test   %eax,%eax
80103437:	75 05                	jne    8010343e <main+0x8d>
    timerinit();   // uniprocessor timer
80103439:	e8 86 2c 00 00       	call   801060c4 <timerinit>
  startothers();   // start other processors
8010343e:	e8 7f 00 00 00       	call   801034c2 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103443:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
8010344a:	8e 
8010344b:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103452:	e8 81 f5 ff ff       	call   801029d8 <kinit2>
  userinit();      // first user process
80103457:	e8 6c 0c 00 00       	call   801040c8 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010345c:	e8 1a 00 00 00       	call   8010347b <mpmain>

80103461 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103461:	55                   	push   %ebp
80103462:	89 e5                	mov    %esp,%ebp
80103464:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103467:	e8 90 44 00 00       	call   801078fc <switchkvm>
  seginit();
8010346c:	e8 07 3e 00 00       	call   80107278 <seginit>
  lapicinit();
80103471:	e8 78 f8 ff ff       	call   80102cee <lapicinit>
  mpmain();
80103476:	e8 00 00 00 00       	call   8010347b <mpmain>

8010347b <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010347b:	55                   	push   %ebp
8010347c:	89 e5                	mov    %esp,%ebp
8010347e:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103481:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103487:	0f b6 00             	movzbl (%eax),%eax
8010348a:	0f b6 c0             	movzbl %al,%eax
8010348d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103491:	c7 04 24 e4 82 10 80 	movl   $0x801082e4,(%esp)
80103498:	e8 03 cf ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
8010349d:	e8 4b 2e 00 00       	call   801062ed <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801034a2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801034a8:	05 a8 00 00 00       	add    $0xa8,%eax
801034ad:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801034b4:	00 
801034b5:	89 04 24             	mov    %eax,(%esp)
801034b8:	e8 da fe ff ff       	call   80103397 <xchg>
  scheduler();     // start running processes
801034bd:	e8 5b 11 00 00       	call   8010461d <scheduler>

801034c2 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801034c2:	55                   	push   %ebp
801034c3:	89 e5                	mov    %esp,%ebp
801034c5:	53                   	push   %ebx
801034c6:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801034c9:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801034d0:	e8 b5 fe ff ff       	call   8010338a <p2v>
801034d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801034d8:	b8 8a 00 00 00       	mov    $0x8a,%eax
801034dd:	89 44 24 08          	mov    %eax,0x8(%esp)
801034e1:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
801034e8:	80 
801034e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ec:	89 04 24             	mov    %eax,(%esp)
801034ef:	e8 ca 18 00 00       	call   80104dbe <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801034f4:	c7 45 f4 20 f9 10 80 	movl   $0x8010f920,-0xc(%ebp)
801034fb:	e9 85 00 00 00       	jmp    80103585 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103500:	e8 42 f9 ff ff       	call   80102e47 <cpunum>
80103505:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010350b:	05 20 f9 10 80       	add    $0x8010f920,%eax
80103510:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103513:	75 02                	jne    80103517 <startothers+0x55>
      continue;
80103515:	eb 67                	jmp    8010357e <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103517:	e8 b2 f5 ff ff       	call   80102ace <kalloc>
8010351c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010351f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103522:	83 e8 04             	sub    $0x4,%eax
80103525:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103528:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010352e:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103533:	83 e8 08             	sub    $0x8,%eax
80103536:	c7 00 61 34 10 80    	movl   $0x80103461,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010353c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010353f:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103542:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103549:	e8 2f fe ff ff       	call   8010337d <v2p>
8010354e:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103550:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103553:	89 04 24             	mov    %eax,(%esp)
80103556:	e8 22 fe ff ff       	call   8010337d <v2p>
8010355b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010355e:	0f b6 12             	movzbl (%edx),%edx
80103561:	0f b6 d2             	movzbl %dl,%edx
80103564:	89 44 24 04          	mov    %eax,0x4(%esp)
80103568:	89 14 24             	mov    %edx,(%esp)
8010356b:	e8 59 f9 ff ff       	call   80102ec9 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103570:	90                   	nop
80103571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103574:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010357a:	85 c0                	test   %eax,%eax
8010357c:	74 f3                	je     80103571 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010357e:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103585:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010358a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103590:	05 20 f9 10 80       	add    $0x8010f920,%eax
80103595:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103598:	0f 87 62 ff ff ff    	ja     80103500 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010359e:	83 c4 24             	add    $0x24,%esp
801035a1:	5b                   	pop    %ebx
801035a2:	5d                   	pop    %ebp
801035a3:	c3                   	ret    

801035a4 <p2v>:
801035a4:	55                   	push   %ebp
801035a5:	89 e5                	mov    %esp,%ebp
801035a7:	8b 45 08             	mov    0x8(%ebp),%eax
801035aa:	05 00 00 00 80       	add    $0x80000000,%eax
801035af:	5d                   	pop    %ebp
801035b0:	c3                   	ret    

801035b1 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801035b1:	55                   	push   %ebp
801035b2:	89 e5                	mov    %esp,%ebp
801035b4:	83 ec 14             	sub    $0x14,%esp
801035b7:	8b 45 08             	mov    0x8(%ebp),%eax
801035ba:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801035be:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801035c2:	89 c2                	mov    %eax,%edx
801035c4:	ec                   	in     (%dx),%al
801035c5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801035c8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801035cc:	c9                   	leave  
801035cd:	c3                   	ret    

801035ce <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801035ce:	55                   	push   %ebp
801035cf:	89 e5                	mov    %esp,%ebp
801035d1:	83 ec 08             	sub    $0x8,%esp
801035d4:	8b 55 08             	mov    0x8(%ebp),%edx
801035d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801035da:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801035de:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801035e1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801035e5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801035e9:	ee                   	out    %al,(%dx)
}
801035ea:	c9                   	leave  
801035eb:	c3                   	ret    

801035ec <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801035ec:	55                   	push   %ebp
801035ed:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801035ef:	a1 44 b6 10 80       	mov    0x8010b644,%eax
801035f4:	89 c2                	mov    %eax,%edx
801035f6:	b8 20 f9 10 80       	mov    $0x8010f920,%eax
801035fb:	29 c2                	sub    %eax,%edx
801035fd:	89 d0                	mov    %edx,%eax
801035ff:	c1 f8 02             	sar    $0x2,%eax
80103602:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103608:	5d                   	pop    %ebp
80103609:	c3                   	ret    

8010360a <sum>:

static uchar
sum(uchar *addr, int len)
{
8010360a:	55                   	push   %ebp
8010360b:	89 e5                	mov    %esp,%ebp
8010360d:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103610:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103617:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010361e:	eb 15                	jmp    80103635 <sum+0x2b>
    sum += addr[i];
80103620:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103623:	8b 45 08             	mov    0x8(%ebp),%eax
80103626:	01 d0                	add    %edx,%eax
80103628:	0f b6 00             	movzbl (%eax),%eax
8010362b:	0f b6 c0             	movzbl %al,%eax
8010362e:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103631:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103635:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103638:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010363b:	7c e3                	jl     80103620 <sum+0x16>
    sum += addr[i];
  return sum;
8010363d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103640:	c9                   	leave  
80103641:	c3                   	ret    

80103642 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103642:	55                   	push   %ebp
80103643:	89 e5                	mov    %esp,%ebp
80103645:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103648:	8b 45 08             	mov    0x8(%ebp),%eax
8010364b:	89 04 24             	mov    %eax,(%esp)
8010364e:	e8 51 ff ff ff       	call   801035a4 <p2v>
80103653:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103656:	8b 55 0c             	mov    0xc(%ebp),%edx
80103659:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010365c:	01 d0                	add    %edx,%eax
8010365e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103661:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103664:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103667:	eb 3f                	jmp    801036a8 <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103669:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103670:	00 
80103671:	c7 44 24 04 f8 82 10 	movl   $0x801082f8,0x4(%esp)
80103678:	80 
80103679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010367c:	89 04 24             	mov    %eax,(%esp)
8010367f:	e8 e2 16 00 00       	call   80104d66 <memcmp>
80103684:	85 c0                	test   %eax,%eax
80103686:	75 1c                	jne    801036a4 <mpsearch1+0x62>
80103688:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010368f:	00 
80103690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103693:	89 04 24             	mov    %eax,(%esp)
80103696:	e8 6f ff ff ff       	call   8010360a <sum>
8010369b:	84 c0                	test   %al,%al
8010369d:	75 05                	jne    801036a4 <mpsearch1+0x62>
      return (struct mp*)p;
8010369f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036a2:	eb 11                	jmp    801036b5 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801036a4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801036a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ab:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801036ae:	72 b9                	jb     80103669 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801036b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801036b5:	c9                   	leave  
801036b6:	c3                   	ret    

801036b7 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801036b7:	55                   	push   %ebp
801036b8:	89 e5                	mov    %esp,%ebp
801036ba:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801036bd:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801036c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036c7:	83 c0 0f             	add    $0xf,%eax
801036ca:	0f b6 00             	movzbl (%eax),%eax
801036cd:	0f b6 c0             	movzbl %al,%eax
801036d0:	c1 e0 08             	shl    $0x8,%eax
801036d3:	89 c2                	mov    %eax,%edx
801036d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d8:	83 c0 0e             	add    $0xe,%eax
801036db:	0f b6 00             	movzbl (%eax),%eax
801036de:	0f b6 c0             	movzbl %al,%eax
801036e1:	09 d0                	or     %edx,%eax
801036e3:	c1 e0 04             	shl    $0x4,%eax
801036e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801036e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801036ed:	74 21                	je     80103710 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
801036ef:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
801036f6:	00 
801036f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036fa:	89 04 24             	mov    %eax,(%esp)
801036fd:	e8 40 ff ff ff       	call   80103642 <mpsearch1>
80103702:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103705:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103709:	74 50                	je     8010375b <mpsearch+0xa4>
      return mp;
8010370b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010370e:	eb 5f                	jmp    8010376f <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103713:	83 c0 14             	add    $0x14,%eax
80103716:	0f b6 00             	movzbl (%eax),%eax
80103719:	0f b6 c0             	movzbl %al,%eax
8010371c:	c1 e0 08             	shl    $0x8,%eax
8010371f:	89 c2                	mov    %eax,%edx
80103721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103724:	83 c0 13             	add    $0x13,%eax
80103727:	0f b6 00             	movzbl (%eax),%eax
8010372a:	0f b6 c0             	movzbl %al,%eax
8010372d:	09 d0                	or     %edx,%eax
8010372f:	c1 e0 0a             	shl    $0xa,%eax
80103732:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103735:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103738:	2d 00 04 00 00       	sub    $0x400,%eax
8010373d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103744:	00 
80103745:	89 04 24             	mov    %eax,(%esp)
80103748:	e8 f5 fe ff ff       	call   80103642 <mpsearch1>
8010374d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103750:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103754:	74 05                	je     8010375b <mpsearch+0xa4>
      return mp;
80103756:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103759:	eb 14                	jmp    8010376f <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
8010375b:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103762:	00 
80103763:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
8010376a:	e8 d3 fe ff ff       	call   80103642 <mpsearch1>
}
8010376f:	c9                   	leave  
80103770:	c3                   	ret    

80103771 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103771:	55                   	push   %ebp
80103772:	89 e5                	mov    %esp,%ebp
80103774:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103777:	e8 3b ff ff ff       	call   801036b7 <mpsearch>
8010377c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010377f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103783:	74 0a                	je     8010378f <mpconfig+0x1e>
80103785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103788:	8b 40 04             	mov    0x4(%eax),%eax
8010378b:	85 c0                	test   %eax,%eax
8010378d:	75 0a                	jne    80103799 <mpconfig+0x28>
    return 0;
8010378f:	b8 00 00 00 00       	mov    $0x0,%eax
80103794:	e9 83 00 00 00       	jmp    8010381c <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010379c:	8b 40 04             	mov    0x4(%eax),%eax
8010379f:	89 04 24             	mov    %eax,(%esp)
801037a2:	e8 fd fd ff ff       	call   801035a4 <p2v>
801037a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801037aa:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801037b1:	00 
801037b2:	c7 44 24 04 fd 82 10 	movl   $0x801082fd,0x4(%esp)
801037b9:	80 
801037ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037bd:	89 04 24             	mov    %eax,(%esp)
801037c0:	e8 a1 15 00 00       	call   80104d66 <memcmp>
801037c5:	85 c0                	test   %eax,%eax
801037c7:	74 07                	je     801037d0 <mpconfig+0x5f>
    return 0;
801037c9:	b8 00 00 00 00       	mov    $0x0,%eax
801037ce:	eb 4c                	jmp    8010381c <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
801037d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037d3:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801037d7:	3c 01                	cmp    $0x1,%al
801037d9:	74 12                	je     801037ed <mpconfig+0x7c>
801037db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037de:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801037e2:	3c 04                	cmp    $0x4,%al
801037e4:	74 07                	je     801037ed <mpconfig+0x7c>
    return 0;
801037e6:	b8 00 00 00 00       	mov    $0x0,%eax
801037eb:	eb 2f                	jmp    8010381c <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
801037ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037f0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801037f4:	0f b7 c0             	movzwl %ax,%eax
801037f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801037fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037fe:	89 04 24             	mov    %eax,(%esp)
80103801:	e8 04 fe ff ff       	call   8010360a <sum>
80103806:	84 c0                	test   %al,%al
80103808:	74 07                	je     80103811 <mpconfig+0xa0>
    return 0;
8010380a:	b8 00 00 00 00       	mov    $0x0,%eax
8010380f:	eb 0b                	jmp    8010381c <mpconfig+0xab>
  *pmp = mp;
80103811:	8b 45 08             	mov    0x8(%ebp),%eax
80103814:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103817:	89 10                	mov    %edx,(%eax)
  return conf;
80103819:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010381c:	c9                   	leave  
8010381d:	c3                   	ret    

8010381e <mpinit>:

void
mpinit(void)
{
8010381e:	55                   	push   %ebp
8010381f:	89 e5                	mov    %esp,%ebp
80103821:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103824:	c7 05 44 b6 10 80 20 	movl   $0x8010f920,0x8010b644
8010382b:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
8010382e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103831:	89 04 24             	mov    %eax,(%esp)
80103834:	e8 38 ff ff ff       	call   80103771 <mpconfig>
80103839:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010383c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103840:	75 05                	jne    80103847 <mpinit+0x29>
    return;
80103842:	e9 9c 01 00 00       	jmp    801039e3 <mpinit+0x1c5>
  ismp = 1;
80103847:	c7 05 04 f9 10 80 01 	movl   $0x1,0x8010f904
8010384e:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103854:	8b 40 24             	mov    0x24(%eax),%eax
80103857:	a3 7c f8 10 80       	mov    %eax,0x8010f87c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010385c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010385f:	83 c0 2c             	add    $0x2c,%eax
80103862:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103868:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010386c:	0f b7 d0             	movzwl %ax,%edx
8010386f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103872:	01 d0                	add    %edx,%eax
80103874:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103877:	e9 f4 00 00 00       	jmp    80103970 <mpinit+0x152>
    switch(*p){
8010387c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010387f:	0f b6 00             	movzbl (%eax),%eax
80103882:	0f b6 c0             	movzbl %al,%eax
80103885:	83 f8 04             	cmp    $0x4,%eax
80103888:	0f 87 bf 00 00 00    	ja     8010394d <mpinit+0x12f>
8010388e:	8b 04 85 40 83 10 80 	mov    -0x7fef7cc0(,%eax,4),%eax
80103895:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010389a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
8010389d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801038a0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801038a4:	0f b6 d0             	movzbl %al,%edx
801038a7:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801038ac:	39 c2                	cmp    %eax,%edx
801038ae:	74 2d                	je     801038dd <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801038b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801038b3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801038b7:	0f b6 d0             	movzbl %al,%edx
801038ba:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801038bf:	89 54 24 08          	mov    %edx,0x8(%esp)
801038c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801038c7:	c7 04 24 02 83 10 80 	movl   $0x80108302,(%esp)
801038ce:	e8 cd ca ff ff       	call   801003a0 <cprintf>
        ismp = 0;
801038d3:	c7 05 04 f9 10 80 00 	movl   $0x0,0x8010f904
801038da:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801038dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801038e0:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801038e4:	0f b6 c0             	movzbl %al,%eax
801038e7:	83 e0 02             	and    $0x2,%eax
801038ea:	85 c0                	test   %eax,%eax
801038ec:	74 15                	je     80103903 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
801038ee:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801038f3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038f9:	05 20 f9 10 80       	add    $0x8010f920,%eax
801038fe:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103903:	8b 15 00 ff 10 80    	mov    0x8010ff00,%edx
80103909:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010390e:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103914:	81 c2 20 f9 10 80    	add    $0x8010f920,%edx
8010391a:	88 02                	mov    %al,(%edx)
      ncpu++;
8010391c:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80103921:	83 c0 01             	add    $0x1,%eax
80103924:	a3 00 ff 10 80       	mov    %eax,0x8010ff00
      p += sizeof(struct mpproc);
80103929:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
8010392d:	eb 41                	jmp    80103970 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010392f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103932:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103935:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103938:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010393c:	a2 00 f9 10 80       	mov    %al,0x8010f900
      p += sizeof(struct mpioapic);
80103941:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103945:	eb 29                	jmp    80103970 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103947:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010394b:	eb 23                	jmp    80103970 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
8010394d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103950:	0f b6 00             	movzbl (%eax),%eax
80103953:	0f b6 c0             	movzbl %al,%eax
80103956:	89 44 24 04          	mov    %eax,0x4(%esp)
8010395a:	c7 04 24 20 83 10 80 	movl   $0x80108320,(%esp)
80103961:	e8 3a ca ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103966:	c7 05 04 f9 10 80 00 	movl   $0x0,0x8010f904
8010396d:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103973:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103976:	0f 82 00 ff ff ff    	jb     8010387c <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
8010397c:	a1 04 f9 10 80       	mov    0x8010f904,%eax
80103981:	85 c0                	test   %eax,%eax
80103983:	75 1d                	jne    801039a2 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103985:	c7 05 00 ff 10 80 01 	movl   $0x1,0x8010ff00
8010398c:	00 00 00 
    lapic = 0;
8010398f:	c7 05 7c f8 10 80 00 	movl   $0x0,0x8010f87c
80103996:	00 00 00 
    ioapicid = 0;
80103999:	c6 05 00 f9 10 80 00 	movb   $0x0,0x8010f900
    return;
801039a0:	eb 41                	jmp    801039e3 <mpinit+0x1c5>
  }

  if(mp->imcrp){
801039a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801039a5:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801039a9:	84 c0                	test   %al,%al
801039ab:	74 36                	je     801039e3 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801039ad:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
801039b4:	00 
801039b5:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
801039bc:	e8 0d fc ff ff       	call   801035ce <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801039c1:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
801039c8:	e8 e4 fb ff ff       	call   801035b1 <inb>
801039cd:	83 c8 01             	or     $0x1,%eax
801039d0:	0f b6 c0             	movzbl %al,%eax
801039d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801039d7:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
801039de:	e8 eb fb ff ff       	call   801035ce <outb>
  }
}
801039e3:	c9                   	leave  
801039e4:	c3                   	ret    

801039e5 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039e5:	55                   	push   %ebp
801039e6:	89 e5                	mov    %esp,%ebp
801039e8:	83 ec 08             	sub    $0x8,%esp
801039eb:	8b 55 08             	mov    0x8(%ebp),%edx
801039ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801039f1:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039f5:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039f8:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039fc:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a00:	ee                   	out    %al,(%dx)
}
80103a01:	c9                   	leave  
80103a02:	c3                   	ret    

80103a03 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103a03:	55                   	push   %ebp
80103a04:	89 e5                	mov    %esp,%ebp
80103a06:	83 ec 0c             	sub    $0xc,%esp
80103a09:	8b 45 08             	mov    0x8(%ebp),%eax
80103a0c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103a10:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a14:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103a1a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a1e:	0f b6 c0             	movzbl %al,%eax
80103a21:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a25:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103a2c:	e8 b4 ff ff ff       	call   801039e5 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103a31:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a35:	66 c1 e8 08          	shr    $0x8,%ax
80103a39:	0f b6 c0             	movzbl %al,%eax
80103a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a40:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103a47:	e8 99 ff ff ff       	call   801039e5 <outb>
}
80103a4c:	c9                   	leave  
80103a4d:	c3                   	ret    

80103a4e <picenable>:

void
picenable(int irq)
{
80103a4e:	55                   	push   %ebp
80103a4f:	89 e5                	mov    %esp,%ebp
80103a51:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103a54:	8b 45 08             	mov    0x8(%ebp),%eax
80103a57:	ba 01 00 00 00       	mov    $0x1,%edx
80103a5c:	89 c1                	mov    %eax,%ecx
80103a5e:	d3 e2                	shl    %cl,%edx
80103a60:	89 d0                	mov    %edx,%eax
80103a62:	f7 d0                	not    %eax
80103a64:	89 c2                	mov    %eax,%edx
80103a66:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103a6d:	21 d0                	and    %edx,%eax
80103a6f:	0f b7 c0             	movzwl %ax,%eax
80103a72:	89 04 24             	mov    %eax,(%esp)
80103a75:	e8 89 ff ff ff       	call   80103a03 <picsetmask>
}
80103a7a:	c9                   	leave  
80103a7b:	c3                   	ret    

80103a7c <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103a7c:	55                   	push   %ebp
80103a7d:	89 e5                	mov    %esp,%ebp
80103a7f:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103a82:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103a89:	00 
80103a8a:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103a91:	e8 4f ff ff ff       	call   801039e5 <outb>
  outb(IO_PIC2+1, 0xFF);
80103a96:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103a9d:	00 
80103a9e:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103aa5:	e8 3b ff ff ff       	call   801039e5 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103aaa:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ab1:	00 
80103ab2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ab9:	e8 27 ff ff ff       	call   801039e5 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103abe:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103ac5:	00 
80103ac6:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103acd:	e8 13 ff ff ff       	call   801039e5 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103ad2:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ad9:	00 
80103ada:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ae1:	e8 ff fe ff ff       	call   801039e5 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ae6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103aed:	00 
80103aee:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103af5:	e8 eb fe ff ff       	call   801039e5 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103afa:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103b01:	00 
80103b02:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103b09:	e8 d7 fe ff ff       	call   801039e5 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103b0e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103b15:	00 
80103b16:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b1d:	e8 c3 fe ff ff       	call   801039e5 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103b22:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103b29:	00 
80103b2a:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b31:	e8 af fe ff ff       	call   801039e5 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103b36:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103b3d:	00 
80103b3e:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b45:	e8 9b fe ff ff       	call   801039e5 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103b4a:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103b51:	00 
80103b52:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103b59:	e8 87 fe ff ff       	call   801039e5 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103b5e:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103b65:	00 
80103b66:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103b6d:	e8 73 fe ff ff       	call   801039e5 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103b72:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103b79:	00 
80103b7a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103b81:	e8 5f fe ff ff       	call   801039e5 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103b86:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103b8d:	00 
80103b8e:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103b95:	e8 4b fe ff ff       	call   801039e5 <outb>

  if(irqmask != 0xFFFF)
80103b9a:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103ba1:	66 83 f8 ff          	cmp    $0xffff,%ax
80103ba5:	74 12                	je     80103bb9 <picinit+0x13d>
    picsetmask(irqmask);
80103ba7:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103bae:	0f b7 c0             	movzwl %ax,%eax
80103bb1:	89 04 24             	mov    %eax,(%esp)
80103bb4:	e8 4a fe ff ff       	call   80103a03 <picsetmask>
}
80103bb9:	c9                   	leave  
80103bba:	c3                   	ret    

80103bbb <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103bbb:	55                   	push   %ebp
80103bbc:	89 e5                	mov    %esp,%ebp
80103bbe:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103bc1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bcb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103bd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bd4:	8b 10                	mov    (%eax),%edx
80103bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103bd9:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103bdb:	e8 32 d3 ff ff       	call   80100f12 <filealloc>
80103be0:	8b 55 08             	mov    0x8(%ebp),%edx
80103be3:	89 02                	mov    %eax,(%edx)
80103be5:	8b 45 08             	mov    0x8(%ebp),%eax
80103be8:	8b 00                	mov    (%eax),%eax
80103bea:	85 c0                	test   %eax,%eax
80103bec:	0f 84 c8 00 00 00    	je     80103cba <pipealloc+0xff>
80103bf2:	e8 1b d3 ff ff       	call   80100f12 <filealloc>
80103bf7:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bfa:	89 02                	mov    %eax,(%edx)
80103bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bff:	8b 00                	mov    (%eax),%eax
80103c01:	85 c0                	test   %eax,%eax
80103c03:	0f 84 b1 00 00 00    	je     80103cba <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103c09:	e8 c0 ee ff ff       	call   80102ace <kalloc>
80103c0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c15:	75 05                	jne    80103c1c <pipealloc+0x61>
    goto bad;
80103c17:	e9 9e 00 00 00       	jmp    80103cba <pipealloc+0xff>
  p->readopen = 1;
80103c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1f:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103c26:	00 00 00 
  p->writeopen = 1;
80103c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2c:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103c33:	00 00 00 
  p->nwrite = 0;
80103c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c39:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103c40:	00 00 00 
  p->nread = 0;
80103c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c46:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103c4d:	00 00 00 
  initlock(&p->lock, "pipe");
80103c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c53:	c7 44 24 04 54 83 10 	movl   $0x80108354,0x4(%esp)
80103c5a:	80 
80103c5b:	89 04 24             	mov    %eax,(%esp)
80103c5e:	e8 17 0e 00 00       	call   80104a7a <initlock>
  (*f0)->type = FD_PIPE;
80103c63:	8b 45 08             	mov    0x8(%ebp),%eax
80103c66:	8b 00                	mov    (%eax),%eax
80103c68:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c71:	8b 00                	mov    (%eax),%eax
80103c73:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103c77:	8b 45 08             	mov    0x8(%ebp),%eax
80103c7a:	8b 00                	mov    (%eax),%eax
80103c7c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103c80:	8b 45 08             	mov    0x8(%ebp),%eax
80103c83:	8b 00                	mov    (%eax),%eax
80103c85:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c88:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c8e:	8b 00                	mov    (%eax),%eax
80103c90:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103c96:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c99:	8b 00                	mov    (%eax),%eax
80103c9b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ca2:	8b 00                	mov    (%eax),%eax
80103ca4:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103ca8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cab:	8b 00                	mov    (%eax),%eax
80103cad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cb0:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103cb3:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb8:	eb 42                	jmp    80103cfc <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103cba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cbe:	74 0b                	je     80103ccb <pipealloc+0x110>
    kfree((char*)p);
80103cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc3:	89 04 24             	mov    %eax,(%esp)
80103cc6:	e8 6a ed ff ff       	call   80102a35 <kfree>
  if(*f0)
80103ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80103cce:	8b 00                	mov    (%eax),%eax
80103cd0:	85 c0                	test   %eax,%eax
80103cd2:	74 0d                	je     80103ce1 <pipealloc+0x126>
    fileclose(*f0);
80103cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd7:	8b 00                	mov    (%eax),%eax
80103cd9:	89 04 24             	mov    %eax,(%esp)
80103cdc:	e8 d9 d2 ff ff       	call   80100fba <fileclose>
  if(*f1)
80103ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ce4:	8b 00                	mov    (%eax),%eax
80103ce6:	85 c0                	test   %eax,%eax
80103ce8:	74 0d                	je     80103cf7 <pipealloc+0x13c>
    fileclose(*f1);
80103cea:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ced:	8b 00                	mov    (%eax),%eax
80103cef:	89 04 24             	mov    %eax,(%esp)
80103cf2:	e8 c3 d2 ff ff       	call   80100fba <fileclose>
  return -1;
80103cf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103cfc:	c9                   	leave  
80103cfd:	c3                   	ret    

80103cfe <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103cfe:	55                   	push   %ebp
80103cff:	89 e5                	mov    %esp,%ebp
80103d01:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103d04:	8b 45 08             	mov    0x8(%ebp),%eax
80103d07:	89 04 24             	mov    %eax,(%esp)
80103d0a:	e8 8c 0d 00 00       	call   80104a9b <acquire>
  if(writable){
80103d0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103d13:	74 1f                	je     80103d34 <pipeclose+0x36>
    p->writeopen = 0;
80103d15:	8b 45 08             	mov    0x8(%ebp),%eax
80103d18:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103d1f:	00 00 00 
    wakeup(&p->nread);
80103d22:	8b 45 08             	mov    0x8(%ebp),%eax
80103d25:	05 34 02 00 00       	add    $0x234,%eax
80103d2a:	89 04 24             	mov    %eax,(%esp)
80103d2d:	e8 72 0b 00 00       	call   801048a4 <wakeup>
80103d32:	eb 1d                	jmp    80103d51 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103d34:	8b 45 08             	mov    0x8(%ebp),%eax
80103d37:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103d3e:	00 00 00 
    wakeup(&p->nwrite);
80103d41:	8b 45 08             	mov    0x8(%ebp),%eax
80103d44:	05 38 02 00 00       	add    $0x238,%eax
80103d49:	89 04 24             	mov    %eax,(%esp)
80103d4c:	e8 53 0b 00 00       	call   801048a4 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103d51:	8b 45 08             	mov    0x8(%ebp),%eax
80103d54:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103d5a:	85 c0                	test   %eax,%eax
80103d5c:	75 25                	jne    80103d83 <pipeclose+0x85>
80103d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d61:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103d67:	85 c0                	test   %eax,%eax
80103d69:	75 18                	jne    80103d83 <pipeclose+0x85>
    release(&p->lock);
80103d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103d6e:	89 04 24             	mov    %eax,(%esp)
80103d71:	e8 87 0d 00 00       	call   80104afd <release>
    kfree((char*)p);
80103d76:	8b 45 08             	mov    0x8(%ebp),%eax
80103d79:	89 04 24             	mov    %eax,(%esp)
80103d7c:	e8 b4 ec ff ff       	call   80102a35 <kfree>
80103d81:	eb 0b                	jmp    80103d8e <pipeclose+0x90>
  } else
    release(&p->lock);
80103d83:	8b 45 08             	mov    0x8(%ebp),%eax
80103d86:	89 04 24             	mov    %eax,(%esp)
80103d89:	e8 6f 0d 00 00       	call   80104afd <release>
}
80103d8e:	c9                   	leave  
80103d8f:	c3                   	ret    

80103d90 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103d90:	55                   	push   %ebp
80103d91:	89 e5                	mov    %esp,%ebp
80103d93:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103d96:	8b 45 08             	mov    0x8(%ebp),%eax
80103d99:	89 04 24             	mov    %eax,(%esp)
80103d9c:	e8 fa 0c 00 00       	call   80104a9b <acquire>
  for(i = 0; i < n; i++){
80103da1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103da8:	e9 a6 00 00 00       	jmp    80103e53 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103dad:	eb 57                	jmp    80103e06 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
80103daf:	8b 45 08             	mov    0x8(%ebp),%eax
80103db2:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103db8:	85 c0                	test   %eax,%eax
80103dba:	74 0d                	je     80103dc9 <pipewrite+0x39>
80103dbc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103dc2:	8b 40 24             	mov    0x24(%eax),%eax
80103dc5:	85 c0                	test   %eax,%eax
80103dc7:	74 15                	je     80103dde <pipewrite+0x4e>
        release(&p->lock);
80103dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dcc:	89 04 24             	mov    %eax,(%esp)
80103dcf:	e8 29 0d 00 00       	call   80104afd <release>
        return -1;
80103dd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dd9:	e9 9f 00 00 00       	jmp    80103e7d <pipewrite+0xed>
      }
      wakeup(&p->nread);
80103dde:	8b 45 08             	mov    0x8(%ebp),%eax
80103de1:	05 34 02 00 00       	add    $0x234,%eax
80103de6:	89 04 24             	mov    %eax,(%esp)
80103de9:	e8 b6 0a 00 00       	call   801048a4 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103dee:	8b 45 08             	mov    0x8(%ebp),%eax
80103df1:	8b 55 08             	mov    0x8(%ebp),%edx
80103df4:	81 c2 38 02 00 00    	add    $0x238,%edx
80103dfa:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dfe:	89 14 24             	mov    %edx,(%esp)
80103e01:	e8 c2 09 00 00       	call   801047c8 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103e06:	8b 45 08             	mov    0x8(%ebp),%eax
80103e09:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103e0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e12:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103e18:	05 00 02 00 00       	add    $0x200,%eax
80103e1d:	39 c2                	cmp    %eax,%edx
80103e1f:	74 8e                	je     80103daf <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103e21:	8b 45 08             	mov    0x8(%ebp),%eax
80103e24:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103e2a:	8d 48 01             	lea    0x1(%eax),%ecx
80103e2d:	8b 55 08             	mov    0x8(%ebp),%edx
80103e30:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103e36:	25 ff 01 00 00       	and    $0x1ff,%eax
80103e3b:	89 c1                	mov    %eax,%ecx
80103e3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e40:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e43:	01 d0                	add    %edx,%eax
80103e45:	0f b6 10             	movzbl (%eax),%edx
80103e48:	8b 45 08             	mov    0x8(%ebp),%eax
80103e4b:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103e4f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e56:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e59:	0f 8c 4e ff ff ff    	jl     80103dad <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103e5f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e62:	05 34 02 00 00       	add    $0x234,%eax
80103e67:	89 04 24             	mov    %eax,(%esp)
80103e6a:	e8 35 0a 00 00       	call   801048a4 <wakeup>
  release(&p->lock);
80103e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e72:	89 04 24             	mov    %eax,(%esp)
80103e75:	e8 83 0c 00 00       	call   80104afd <release>
  return n;
80103e7a:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103e7d:	c9                   	leave  
80103e7e:	c3                   	ret    

80103e7f <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103e7f:	55                   	push   %ebp
80103e80:	89 e5                	mov    %esp,%ebp
80103e82:	53                   	push   %ebx
80103e83:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103e86:	8b 45 08             	mov    0x8(%ebp),%eax
80103e89:	89 04 24             	mov    %eax,(%esp)
80103e8c:	e8 0a 0c 00 00       	call   80104a9b <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103e91:	eb 3a                	jmp    80103ecd <piperead+0x4e>
    if(proc->killed){
80103e93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e99:	8b 40 24             	mov    0x24(%eax),%eax
80103e9c:	85 c0                	test   %eax,%eax
80103e9e:	74 15                	je     80103eb5 <piperead+0x36>
      release(&p->lock);
80103ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea3:	89 04 24             	mov    %eax,(%esp)
80103ea6:	e8 52 0c 00 00       	call   80104afd <release>
      return -1;
80103eab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103eb0:	e9 b5 00 00 00       	jmp    80103f6a <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb8:	8b 55 08             	mov    0x8(%ebp),%edx
80103ebb:	81 c2 34 02 00 00    	add    $0x234,%edx
80103ec1:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ec5:	89 14 24             	mov    %edx,(%esp)
80103ec8:	e8 fb 08 00 00       	call   801047c8 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103edf:	39 c2                	cmp    %eax,%edx
80103ee1:	75 0d                	jne    80103ef0 <piperead+0x71>
80103ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee6:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103eec:	85 c0                	test   %eax,%eax
80103eee:	75 a3                	jne    80103e93 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103ef0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ef7:	eb 4b                	jmp    80103f44 <piperead+0xc5>
    if(p->nread == p->nwrite)
80103ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80103efc:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f02:	8b 45 08             	mov    0x8(%ebp),%eax
80103f05:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f0b:	39 c2                	cmp    %eax,%edx
80103f0d:	75 02                	jne    80103f11 <piperead+0x92>
      break;
80103f0f:	eb 3b                	jmp    80103f4c <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103f11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f14:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f17:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f23:	8d 48 01             	lea    0x1(%eax),%ecx
80103f26:	8b 55 08             	mov    0x8(%ebp),%edx
80103f29:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103f2f:	25 ff 01 00 00       	and    $0x1ff,%eax
80103f34:	89 c2                	mov    %eax,%edx
80103f36:	8b 45 08             	mov    0x8(%ebp),%eax
80103f39:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80103f3e:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f40:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f47:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f4a:	7c ad                	jl     80103ef9 <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4f:	05 38 02 00 00       	add    $0x238,%eax
80103f54:	89 04 24             	mov    %eax,(%esp)
80103f57:	e8 48 09 00 00       	call   801048a4 <wakeup>
  release(&p->lock);
80103f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5f:	89 04 24             	mov    %eax,(%esp)
80103f62:	e8 96 0b 00 00       	call   80104afd <release>
  return i;
80103f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103f6a:	83 c4 24             	add    $0x24,%esp
80103f6d:	5b                   	pop    %ebx
80103f6e:	5d                   	pop    %ebp
80103f6f:	c3                   	ret    

80103f70 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103f70:	55                   	push   %ebp
80103f71:	89 e5                	mov    %esp,%ebp
80103f73:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103f76:	9c                   	pushf  
80103f77:	58                   	pop    %eax
80103f78:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103f7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103f7e:	c9                   	leave  
80103f7f:	c3                   	ret    

80103f80 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80103f80:	55                   	push   %ebp
80103f81:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103f83:	fb                   	sti    
}
80103f84:	5d                   	pop    %ebp
80103f85:	c3                   	ret    

80103f86 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103f86:	55                   	push   %ebp
80103f87:	89 e5                	mov    %esp,%ebp
80103f89:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80103f8c:	c7 44 24 04 59 83 10 	movl   $0x80108359,0x4(%esp)
80103f93:	80 
80103f94:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80103f9b:	e8 da 0a 00 00       	call   80104a7a <initlock>
}
80103fa0:	c9                   	leave  
80103fa1:	c3                   	ret    

80103fa2 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103fa2:	55                   	push   %ebp
80103fa3:	89 e5                	mov    %esp,%ebp
80103fa5:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  acquire(&ptable.lock);
80103fa8:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80103faf:	e8 e7 0a 00 00       	call   80104a9b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103fb4:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
80103fbb:	eb 53                	jmp    80104010 <allocproc+0x6e>
    if(p->state == UNUSED)
80103fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc0:	8b 40 0c             	mov    0xc(%eax),%eax
80103fc3:	85 c0                	test   %eax,%eax
80103fc5:	75 42                	jne    80104009 <allocproc+0x67>
      goto found;
80103fc7:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80103fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fcb:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103fd2:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80103fd7:	8d 50 01             	lea    0x1(%eax),%edx
80103fda:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
80103fe0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fe3:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80103fe6:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80103fed:	e8 0b 0b 00 00       	call   80104afd <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ff2:	e8 d7 ea ff ff       	call   80102ace <kalloc>
80103ff7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ffa:	89 42 08             	mov    %eax,0x8(%edx)
80103ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104000:	8b 40 08             	mov    0x8(%eax),%eax
80104003:	85 c0                	test   %eax,%eax
80104005:	75 3c                	jne    80104043 <allocproc+0xa1>
80104007:	eb 26                	jmp    8010402f <allocproc+0x8d>
allocproc(void)
{
  struct proc *p;
  char *sp;
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104009:	81 45 f4 f4 00 00 00 	addl   $0xf4,-0xc(%ebp)
80104010:	81 7d f4 54 3c 11 80 	cmpl   $0x80113c54,-0xc(%ebp)
80104017:	72 a4                	jb     80103fbd <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104019:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104020:	e8 d8 0a 00 00       	call   80104afd <release>
  return 0;
80104025:	b8 00 00 00 00       	mov    $0x0,%eax
8010402a:	e9 97 00 00 00       	jmp    801040c6 <allocproc+0x124>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
8010402f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104032:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104039:	b8 00 00 00 00       	mov    $0x0,%eax
8010403e:	e9 83 00 00 00       	jmp    801040c6 <allocproc+0x124>
  }
  sp = p->kstack + KSTACKSIZE;
80104043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104046:	8b 40 08             	mov    0x8(%eax),%eax
80104049:	05 00 10 00 00       	add    $0x1000,%eax
8010404e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104051:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104058:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010405b:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010405e:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104062:	ba 34 61 10 80       	mov    $0x80106134,%edx
80104067:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010406a:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010406c:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104073:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104076:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010407f:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104086:	00 
80104087:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010408e:	00 
8010408f:	89 04 24             	mov    %eax,(%esp)
80104092:	e8 58 0c 00 00       	call   80104cef <memset>
  p->context->eip = (uint)forkret;
80104097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010409d:	ba 9c 47 10 80       	mov    $0x8010479c,%edx
801040a2:	89 50 10             	mov    %edx,0x10(%eax)

  // Reset array that tracks system call count.
  memset(p->sccount, 0, sizeof p->sccount);
801040a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a8:	83 c0 7c             	add    $0x7c,%eax
801040ab:	c7 44 24 08 78 00 00 	movl   $0x78,0x8(%esp)
801040b2:	00 
801040b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801040ba:	00 
801040bb:	89 04 24             	mov    %eax,(%esp)
801040be:	e8 2c 0c 00 00       	call   80104cef <memset>

  return p;
801040c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801040c6:	c9                   	leave  
801040c7:	c3                   	ret    

801040c8 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801040c8:	55                   	push   %ebp
801040c9:	89 e5                	mov    %esp,%ebp
801040cb:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801040ce:	e8 cf fe ff ff       	call   80103fa2 <allocproc>
801040d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801040d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d9:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
801040de:	e8 45 37 00 00       	call   80107828 <setupkvm>
801040e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040e6:	89 42 04             	mov    %eax,0x4(%edx)
801040e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ec:	8b 40 04             	mov    0x4(%eax),%eax
801040ef:	85 c0                	test   %eax,%eax
801040f1:	75 0c                	jne    801040ff <userinit+0x37>
    panic("userinit: out of memory?");
801040f3:	c7 04 24 60 83 10 80 	movl   $0x80108360,(%esp)
801040fa:	e8 3b c4 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801040ff:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104107:	8b 40 04             	mov    0x4(%eax),%eax
8010410a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010410e:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
80104115:	80 
80104116:	89 04 24             	mov    %eax,(%esp)
80104119:	e8 62 39 00 00       	call   80107a80 <inituvm>
  p->sz = PGSIZE;
8010411e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104121:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412a:	8b 40 18             	mov    0x18(%eax),%eax
8010412d:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104134:	00 
80104135:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010413c:	00 
8010413d:	89 04 24             	mov    %eax,(%esp)
80104140:	e8 aa 0b 00 00       	call   80104cef <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104148:	8b 40 18             	mov    0x18(%eax),%eax
8010414b:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104154:	8b 40 18             	mov    0x18(%eax),%eax
80104157:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010415d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104160:	8b 40 18             	mov    0x18(%eax),%eax
80104163:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104166:	8b 52 18             	mov    0x18(%edx),%edx
80104169:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010416d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104171:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104174:	8b 40 18             	mov    0x18(%eax),%eax
80104177:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010417a:	8b 52 18             	mov    0x18(%edx),%edx
8010417d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104181:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104188:	8b 40 18             	mov    0x18(%eax),%eax
8010418b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104195:	8b 40 18             	mov    0x18(%eax),%eax
80104198:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010419f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a2:	8b 40 18             	mov    0x18(%eax),%eax
801041a5:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801041ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041af:	83 c0 6c             	add    $0x6c,%eax
801041b2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801041b9:	00 
801041ba:	c7 44 24 04 79 83 10 	movl   $0x80108379,0x4(%esp)
801041c1:	80 
801041c2:	89 04 24             	mov    %eax,(%esp)
801041c5:	e8 45 0d 00 00       	call   80104f0f <safestrcpy>
  p->cwd = namei("/");
801041ca:	c7 04 24 82 83 10 80 	movl   $0x80108382,(%esp)
801041d1:	e8 1c e2 ff ff       	call   801023f2 <namei>
801041d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041d9:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801041dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041df:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801041e6:	c9                   	leave  
801041e7:	c3                   	ret    

801041e8 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801041e8:	55                   	push   %ebp
801041e9:	89 e5                	mov    %esp,%ebp
801041eb:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801041ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041f4:	8b 00                	mov    (%eax),%eax
801041f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801041f9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801041fd:	7e 34                	jle    80104233 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801041ff:	8b 55 08             	mov    0x8(%ebp),%edx
80104202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104205:	01 c2                	add    %eax,%edx
80104207:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010420d:	8b 40 04             	mov    0x4(%eax),%eax
80104210:	89 54 24 08          	mov    %edx,0x8(%esp)
80104214:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104217:	89 54 24 04          	mov    %edx,0x4(%esp)
8010421b:	89 04 24             	mov    %eax,(%esp)
8010421e:	e8 d3 39 00 00       	call   80107bf6 <allocuvm>
80104223:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104226:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010422a:	75 41                	jne    8010426d <growproc+0x85>
      return -1;
8010422c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104231:	eb 58                	jmp    8010428b <growproc+0xa3>
  } else if(n < 0){
80104233:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104237:	79 34                	jns    8010426d <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104239:	8b 55 08             	mov    0x8(%ebp),%edx
8010423c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423f:	01 c2                	add    %eax,%edx
80104241:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104247:	8b 40 04             	mov    0x4(%eax),%eax
8010424a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010424e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104251:	89 54 24 04          	mov    %edx,0x4(%esp)
80104255:	89 04 24             	mov    %eax,(%esp)
80104258:	e8 73 3a 00 00       	call   80107cd0 <deallocuvm>
8010425d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104260:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104264:	75 07                	jne    8010426d <growproc+0x85>
      return -1;
80104266:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010426b:	eb 1e                	jmp    8010428b <growproc+0xa3>
  }
  proc->sz = sz;
8010426d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104273:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104276:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104278:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010427e:	89 04 24             	mov    %eax,(%esp)
80104281:	e8 93 36 00 00       	call   80107919 <switchuvm>
  return 0;
80104286:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010428b:	c9                   	leave  
8010428c:	c3                   	ret    

8010428d <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010428d:	55                   	push   %ebp
8010428e:	89 e5                	mov    %esp,%ebp
80104290:	57                   	push   %edi
80104291:	56                   	push   %esi
80104292:	53                   	push   %ebx
80104293:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104296:	e8 07 fd ff ff       	call   80103fa2 <allocproc>
8010429b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010429e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801042a2:	75 0a                	jne    801042ae <fork+0x21>
    return -1;
801042a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042a9:	e9 3a 01 00 00       	jmp    801043e8 <fork+0x15b>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801042ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042b4:	8b 10                	mov    (%eax),%edx
801042b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042bc:	8b 40 04             	mov    0x4(%eax),%eax
801042bf:	89 54 24 04          	mov    %edx,0x4(%esp)
801042c3:	89 04 24             	mov    %eax,(%esp)
801042c6:	e8 a1 3b 00 00       	call   80107e6c <copyuvm>
801042cb:	8b 55 e0             	mov    -0x20(%ebp),%edx
801042ce:	89 42 04             	mov    %eax,0x4(%edx)
801042d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042d4:	8b 40 04             	mov    0x4(%eax),%eax
801042d7:	85 c0                	test   %eax,%eax
801042d9:	75 2c                	jne    80104307 <fork+0x7a>
    kfree(np->kstack);
801042db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042de:	8b 40 08             	mov    0x8(%eax),%eax
801042e1:	89 04 24             	mov    %eax,(%esp)
801042e4:	e8 4c e7 ff ff       	call   80102a35 <kfree>
    np->kstack = 0;
801042e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801042f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042f6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801042fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104302:	e9 e1 00 00 00       	jmp    801043e8 <fork+0x15b>
  }
  np->sz = proc->sz;
80104307:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010430d:	8b 10                	mov    (%eax),%edx
8010430f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104312:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104314:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010431b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010431e:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104321:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104324:	8b 50 18             	mov    0x18(%eax),%edx
80104327:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010432d:	8b 40 18             	mov    0x18(%eax),%eax
80104330:	89 c3                	mov    %eax,%ebx
80104332:	b8 13 00 00 00       	mov    $0x13,%eax
80104337:	89 d7                	mov    %edx,%edi
80104339:	89 de                	mov    %ebx,%esi
8010433b:	89 c1                	mov    %eax,%ecx
8010433d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010433f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104342:	8b 40 18             	mov    0x18(%eax),%eax
80104345:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010434c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104353:	eb 3d                	jmp    80104392 <fork+0x105>
    if(proc->ofile[i])
80104355:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010435b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010435e:	83 c2 08             	add    $0x8,%edx
80104361:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104365:	85 c0                	test   %eax,%eax
80104367:	74 25                	je     8010438e <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104369:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010436f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104372:	83 c2 08             	add    $0x8,%edx
80104375:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104379:	89 04 24             	mov    %eax,(%esp)
8010437c:	e8 f1 cb ff ff       	call   80100f72 <filedup>
80104381:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104384:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104387:	83 c1 08             	add    $0x8,%ecx
8010438a:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010438e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104392:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104396:	7e bd                	jle    80104355 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104398:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010439e:	8b 40 68             	mov    0x68(%eax),%eax
801043a1:	89 04 24             	mov    %eax,(%esp)
801043a4:	e8 6c d4 ff ff       	call   80101815 <idup>
801043a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801043ac:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
801043af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043b2:	8b 40 10             	mov    0x10(%eax),%eax
801043b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
801043b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043bb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
801043c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043c8:	8d 50 6c             	lea    0x6c(%eax),%edx
801043cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043ce:	83 c0 6c             	add    $0x6c,%eax
801043d1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801043d8:	00 
801043d9:	89 54 24 04          	mov    %edx,0x4(%esp)
801043dd:	89 04 24             	mov    %eax,(%esp)
801043e0:	e8 2a 0b 00 00       	call   80104f0f <safestrcpy>
  return pid;
801043e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801043e8:	83 c4 2c             	add    $0x2c,%esp
801043eb:	5b                   	pop    %ebx
801043ec:	5e                   	pop    %esi
801043ed:	5f                   	pop    %edi
801043ee:	5d                   	pop    %ebp
801043ef:	c3                   	ret    

801043f0 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801043f0:	55                   	push   %ebp
801043f1:	89 e5                	mov    %esp,%ebp
801043f3:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801043f6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801043fd:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104402:	39 c2                	cmp    %eax,%edx
80104404:	75 0c                	jne    80104412 <exit+0x22>
    panic("init exiting");
80104406:	c7 04 24 84 83 10 80 	movl   $0x80108384,(%esp)
8010440d:	e8 28 c1 ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104412:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104419:	eb 44                	jmp    8010445f <exit+0x6f>
    if(proc->ofile[fd]){
8010441b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104421:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104424:	83 c2 08             	add    $0x8,%edx
80104427:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010442b:	85 c0                	test   %eax,%eax
8010442d:	74 2c                	je     8010445b <exit+0x6b>
      fileclose(proc->ofile[fd]);
8010442f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104435:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104438:	83 c2 08             	add    $0x8,%edx
8010443b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010443f:	89 04 24             	mov    %eax,(%esp)
80104442:	e8 73 cb ff ff       	call   80100fba <fileclose>
      proc->ofile[fd] = 0;
80104447:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010444d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104450:	83 c2 08             	add    $0x8,%edx
80104453:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010445a:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010445b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010445f:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104463:	7e b6                	jle    8010441b <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104465:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010446b:	8b 40 68             	mov    0x68(%eax),%eax
8010446e:	89 04 24             	mov    %eax,(%esp)
80104471:	e8 84 d5 ff ff       	call   801019fa <iput>
  proc->cwd = 0;
80104476:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010447c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104483:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010448a:	e8 0c 06 00 00       	call   80104a9b <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010448f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104495:	8b 40 14             	mov    0x14(%eax),%eax
80104498:	89 04 24             	mov    %eax,(%esp)
8010449b:	e8 c3 03 00 00       	call   80104863 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044a0:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
801044a7:	eb 3b                	jmp    801044e4 <exit+0xf4>
    if(p->parent == proc){
801044a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ac:	8b 50 14             	mov    0x14(%eax),%edx
801044af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044b5:	39 c2                	cmp    %eax,%edx
801044b7:	75 24                	jne    801044dd <exit+0xed>
      p->parent = initproc;
801044b9:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801044bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c2:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801044c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c8:	8b 40 0c             	mov    0xc(%eax),%eax
801044cb:	83 f8 05             	cmp    $0x5,%eax
801044ce:	75 0d                	jne    801044dd <exit+0xed>
        wakeup1(initproc);
801044d0:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801044d5:	89 04 24             	mov    %eax,(%esp)
801044d8:	e8 86 03 00 00       	call   80104863 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044dd:	81 45 f4 f4 00 00 00 	addl   $0xf4,-0xc(%ebp)
801044e4:	81 7d f4 54 3c 11 80 	cmpl   $0x80113c54,-0xc(%ebp)
801044eb:	72 bc                	jb     801044a9 <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801044ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044f3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801044fa:	e8 b9 01 00 00       	call   801046b8 <sched>
  panic("zombie exit");
801044ff:	c7 04 24 91 83 10 80 	movl   $0x80108391,(%esp)
80104506:	e8 2f c0 ff ff       	call   8010053a <panic>

8010450b <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010450b:	55                   	push   %ebp
8010450c:	89 e5                	mov    %esp,%ebp
8010450e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104511:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104518:	e8 7e 05 00 00       	call   80104a9b <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010451d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104524:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
8010452b:	e9 9d 00 00 00       	jmp    801045cd <wait+0xc2>
      if(p->parent != proc)
80104530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104533:	8b 50 14             	mov    0x14(%eax),%edx
80104536:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010453c:	39 c2                	cmp    %eax,%edx
8010453e:	74 05                	je     80104545 <wait+0x3a>
        continue;
80104540:	e9 81 00 00 00       	jmp    801045c6 <wait+0xbb>
      havekids = 1;
80104545:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010454c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454f:	8b 40 0c             	mov    0xc(%eax),%eax
80104552:	83 f8 05             	cmp    $0x5,%eax
80104555:	75 6f                	jne    801045c6 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455a:	8b 40 10             	mov    0x10(%eax),%eax
8010455d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104563:	8b 40 08             	mov    0x8(%eax),%eax
80104566:	89 04 24             	mov    %eax,(%esp)
80104569:	e8 c7 e4 ff ff       	call   80102a35 <kfree>
        p->kstack = 0;
8010456e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104571:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457b:	8b 40 04             	mov    0x4(%eax),%eax
8010457e:	89 04 24             	mov    %eax,(%esp)
80104581:	e8 06 38 00 00       	call   80107d8c <freevm>
        p->state = UNUSED;
80104586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104589:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104593:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010459a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801045a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a7:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801045ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ae:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801045b5:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801045bc:	e8 3c 05 00 00       	call   80104afd <release>
        return pid;
801045c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045c4:	eb 55                	jmp    8010461b <wait+0x110>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045c6:	81 45 f4 f4 00 00 00 	addl   $0xf4,-0xc(%ebp)
801045cd:	81 7d f4 54 3c 11 80 	cmpl   $0x80113c54,-0xc(%ebp)
801045d4:	0f 82 56 ff ff ff    	jb     80104530 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801045da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801045de:	74 0d                	je     801045ed <wait+0xe2>
801045e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045e6:	8b 40 24             	mov    0x24(%eax),%eax
801045e9:	85 c0                	test   %eax,%eax
801045eb:	74 13                	je     80104600 <wait+0xf5>
      release(&ptable.lock);
801045ed:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801045f4:	e8 04 05 00 00       	call   80104afd <release>
      return -1;
801045f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045fe:	eb 1b                	jmp    8010461b <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104600:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104606:	c7 44 24 04 20 ff 10 	movl   $0x8010ff20,0x4(%esp)
8010460d:	80 
8010460e:	89 04 24             	mov    %eax,(%esp)
80104611:	e8 b2 01 00 00       	call   801047c8 <sleep>
  }
80104616:	e9 02 ff ff ff       	jmp    8010451d <wait+0x12>
}
8010461b:	c9                   	leave  
8010461c:	c3                   	ret    

8010461d <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010461d:	55                   	push   %ebp
8010461e:	89 e5                	mov    %esp,%ebp
80104620:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104623:	e8 58 f9 ff ff       	call   80103f80 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104628:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010462f:	e8 67 04 00 00       	call   80104a9b <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104634:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
8010463b:	eb 61                	jmp    8010469e <scheduler+0x81>
      if(p->state != RUNNABLE)
8010463d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104640:	8b 40 0c             	mov    0xc(%eax),%eax
80104643:	83 f8 03             	cmp    $0x3,%eax
80104646:	74 02                	je     8010464a <scheduler+0x2d>
        continue;
80104648:	eb 4d                	jmp    80104697 <scheduler+0x7a>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
8010464a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464d:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104656:	89 04 24             	mov    %eax,(%esp)
80104659:	e8 bb 32 00 00       	call   80107919 <switchuvm>
      p->state = RUNNING;
8010465e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104661:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104668:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010466e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104671:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104678:	83 c2 04             	add    $0x4,%edx
8010467b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010467f:	89 14 24             	mov    %edx,(%esp)
80104682:	e8 f9 08 00 00       	call   80104f80 <swtch>
      switchkvm();
80104687:	e8 70 32 00 00       	call   801078fc <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010468c:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104693:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104697:	81 45 f4 f4 00 00 00 	addl   $0xf4,-0xc(%ebp)
8010469e:	81 7d f4 54 3c 11 80 	cmpl   $0x80113c54,-0xc(%ebp)
801046a5:	72 96                	jb     8010463d <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
801046a7:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801046ae:	e8 4a 04 00 00       	call   80104afd <release>

  }
801046b3:	e9 6b ff ff ff       	jmp    80104623 <scheduler+0x6>

801046b8 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801046b8:	55                   	push   %ebp
801046b9:	89 e5                	mov    %esp,%ebp
801046bb:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
801046be:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801046c5:	e8 fb 04 00 00       	call   80104bc5 <holding>
801046ca:	85 c0                	test   %eax,%eax
801046cc:	75 0c                	jne    801046da <sched+0x22>
    panic("sched ptable.lock");
801046ce:	c7 04 24 9d 83 10 80 	movl   $0x8010839d,(%esp)
801046d5:	e8 60 be ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
801046da:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801046e0:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801046e6:	83 f8 01             	cmp    $0x1,%eax
801046e9:	74 0c                	je     801046f7 <sched+0x3f>
    panic("sched locks");
801046eb:	c7 04 24 af 83 10 80 	movl   $0x801083af,(%esp)
801046f2:	e8 43 be ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
801046f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fd:	8b 40 0c             	mov    0xc(%eax),%eax
80104700:	83 f8 04             	cmp    $0x4,%eax
80104703:	75 0c                	jne    80104711 <sched+0x59>
    panic("sched running");
80104705:	c7 04 24 bb 83 10 80 	movl   $0x801083bb,(%esp)
8010470c:	e8 29 be ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104711:	e8 5a f8 ff ff       	call   80103f70 <readeflags>
80104716:	25 00 02 00 00       	and    $0x200,%eax
8010471b:	85 c0                	test   %eax,%eax
8010471d:	74 0c                	je     8010472b <sched+0x73>
    panic("sched interruptible");
8010471f:	c7 04 24 c9 83 10 80 	movl   $0x801083c9,(%esp)
80104726:	e8 0f be ff ff       	call   8010053a <panic>
  intena = cpu->intena;
8010472b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104731:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104737:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010473a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104740:	8b 40 04             	mov    0x4(%eax),%eax
80104743:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010474a:	83 c2 1c             	add    $0x1c,%edx
8010474d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104751:	89 14 24             	mov    %edx,(%esp)
80104754:	e8 27 08 00 00       	call   80104f80 <swtch>
  cpu->intena = intena;
80104759:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010475f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104762:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104768:	c9                   	leave  
80104769:	c3                   	ret    

8010476a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010476a:	55                   	push   %ebp
8010476b:	89 e5                	mov    %esp,%ebp
8010476d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104770:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104777:	e8 1f 03 00 00       	call   80104a9b <acquire>
  proc->state = RUNNABLE;
8010477c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104782:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104789:	e8 2a ff ff ff       	call   801046b8 <sched>
  release(&ptable.lock);
8010478e:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104795:	e8 63 03 00 00       	call   80104afd <release>
}
8010479a:	c9                   	leave  
8010479b:	c3                   	ret    

8010479c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010479c:	55                   	push   %ebp
8010479d:	89 e5                	mov    %esp,%ebp
8010479f:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801047a2:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801047a9:	e8 4f 03 00 00       	call   80104afd <release>

  if (first) {
801047ae:	a1 08 b0 10 80       	mov    0x8010b008,%eax
801047b3:	85 c0                	test   %eax,%eax
801047b5:	74 0f                	je     801047c6 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801047b7:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
801047be:	00 00 00 
    initlog();
801047c1:	e8 fd e7 ff ff       	call   80102fc3 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801047c6:	c9                   	leave  
801047c7:	c3                   	ret    

801047c8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801047c8:	55                   	push   %ebp
801047c9:	89 e5                	mov    %esp,%ebp
801047cb:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
801047ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047d4:	85 c0                	test   %eax,%eax
801047d6:	75 0c                	jne    801047e4 <sleep+0x1c>
    panic("sleep");
801047d8:	c7 04 24 dd 83 10 80 	movl   $0x801083dd,(%esp)
801047df:	e8 56 bd ff ff       	call   8010053a <panic>

  if(lk == 0)
801047e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801047e8:	75 0c                	jne    801047f6 <sleep+0x2e>
    panic("sleep without lk");
801047ea:	c7 04 24 e3 83 10 80 	movl   $0x801083e3,(%esp)
801047f1:	e8 44 bd ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801047f6:	81 7d 0c 20 ff 10 80 	cmpl   $0x8010ff20,0xc(%ebp)
801047fd:	74 17                	je     80104816 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
801047ff:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104806:	e8 90 02 00 00       	call   80104a9b <acquire>
    release(lk);
8010480b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010480e:	89 04 24             	mov    %eax,(%esp)
80104811:	e8 e7 02 00 00       	call   80104afd <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104816:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010481c:	8b 55 08             	mov    0x8(%ebp),%edx
8010481f:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104822:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104828:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010482f:	e8 84 fe ff ff       	call   801046b8 <sched>

  // Tidy up.
  proc->chan = 0;
80104834:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483a:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104841:	81 7d 0c 20 ff 10 80 	cmpl   $0x8010ff20,0xc(%ebp)
80104848:	74 17                	je     80104861 <sleep+0x99>
    release(&ptable.lock);
8010484a:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104851:	e8 a7 02 00 00       	call   80104afd <release>
    acquire(lk);
80104856:	8b 45 0c             	mov    0xc(%ebp),%eax
80104859:	89 04 24             	mov    %eax,(%esp)
8010485c:	e8 3a 02 00 00       	call   80104a9b <acquire>
  }
}
80104861:	c9                   	leave  
80104862:	c3                   	ret    

80104863 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104863:	55                   	push   %ebp
80104864:	89 e5                	mov    %esp,%ebp
80104866:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104869:	c7 45 fc 54 ff 10 80 	movl   $0x8010ff54,-0x4(%ebp)
80104870:	eb 27                	jmp    80104899 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104872:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104875:	8b 40 0c             	mov    0xc(%eax),%eax
80104878:	83 f8 02             	cmp    $0x2,%eax
8010487b:	75 15                	jne    80104892 <wakeup1+0x2f>
8010487d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104880:	8b 40 20             	mov    0x20(%eax),%eax
80104883:	3b 45 08             	cmp    0x8(%ebp),%eax
80104886:	75 0a                	jne    80104892 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104888:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010488b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104892:	81 45 fc f4 00 00 00 	addl   $0xf4,-0x4(%ebp)
80104899:	81 7d fc 54 3c 11 80 	cmpl   $0x80113c54,-0x4(%ebp)
801048a0:	72 d0                	jb     80104872 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
801048a2:	c9                   	leave  
801048a3:	c3                   	ret    

801048a4 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801048a4:	55                   	push   %ebp
801048a5:	89 e5                	mov    %esp,%ebp
801048a7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
801048aa:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801048b1:	e8 e5 01 00 00       	call   80104a9b <acquire>
  wakeup1(chan);
801048b6:	8b 45 08             	mov    0x8(%ebp),%eax
801048b9:	89 04 24             	mov    %eax,(%esp)
801048bc:	e8 a2 ff ff ff       	call   80104863 <wakeup1>
  release(&ptable.lock);
801048c1:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801048c8:	e8 30 02 00 00       	call   80104afd <release>
}
801048cd:	c9                   	leave  
801048ce:	c3                   	ret    

801048cf <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801048cf:	55                   	push   %ebp
801048d0:	89 e5                	mov    %esp,%ebp
801048d2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
801048d5:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801048dc:	e8 ba 01 00 00       	call   80104a9b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048e1:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
801048e8:	eb 44                	jmp    8010492e <kill+0x5f>
    if(p->pid == pid){
801048ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ed:	8b 40 10             	mov    0x10(%eax),%eax
801048f0:	3b 45 08             	cmp    0x8(%ebp),%eax
801048f3:	75 32                	jne    80104927 <kill+0x58>
      p->killed = 1;
801048f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f8:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801048ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104902:	8b 40 0c             	mov    0xc(%eax),%eax
80104905:	83 f8 02             	cmp    $0x2,%eax
80104908:	75 0a                	jne    80104914 <kill+0x45>
        p->state = RUNNABLE;
8010490a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104914:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010491b:	e8 dd 01 00 00       	call   80104afd <release>
      return 0;
80104920:	b8 00 00 00 00       	mov    $0x0,%eax
80104925:	eb 21                	jmp    80104948 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104927:	81 45 f4 f4 00 00 00 	addl   $0xf4,-0xc(%ebp)
8010492e:	81 7d f4 54 3c 11 80 	cmpl   $0x80113c54,-0xc(%ebp)
80104935:	72 b3                	jb     801048ea <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104937:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010493e:	e8 ba 01 00 00       	call   80104afd <release>
  return -1;
80104943:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104948:	c9                   	leave  
80104949:	c3                   	ret    

8010494a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010494a:	55                   	push   %ebp
8010494b:	89 e5                	mov    %esp,%ebp
8010494d:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104950:	c7 45 f0 54 ff 10 80 	movl   $0x8010ff54,-0x10(%ebp)
80104957:	e9 d9 00 00 00       	jmp    80104a35 <procdump+0xeb>
    if(p->state == UNUSED)
8010495c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010495f:	8b 40 0c             	mov    0xc(%eax),%eax
80104962:	85 c0                	test   %eax,%eax
80104964:	75 05                	jne    8010496b <procdump+0x21>
      continue;
80104966:	e9 c3 00 00 00       	jmp    80104a2e <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010496b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010496e:	8b 40 0c             	mov    0xc(%eax),%eax
80104971:	83 f8 05             	cmp    $0x5,%eax
80104974:	77 23                	ja     80104999 <procdump+0x4f>
80104976:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104979:	8b 40 0c             	mov    0xc(%eax),%eax
8010497c:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104983:	85 c0                	test   %eax,%eax
80104985:	74 12                	je     80104999 <procdump+0x4f>
      state = states[p->state];
80104987:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010498a:	8b 40 0c             	mov    0xc(%eax),%eax
8010498d:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104994:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104997:	eb 07                	jmp    801049a0 <procdump+0x56>
    else
      state = "???";
80104999:	c7 45 ec f4 83 10 80 	movl   $0x801083f4,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801049a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049a3:	8d 50 6c             	lea    0x6c(%eax),%edx
801049a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049a9:	8b 40 10             	mov    0x10(%eax),%eax
801049ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
801049b0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801049b3:	89 54 24 08          	mov    %edx,0x8(%esp)
801049b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801049bb:	c7 04 24 f8 83 10 80 	movl   $0x801083f8,(%esp)
801049c2:	e8 d9 b9 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
801049c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049ca:	8b 40 0c             	mov    0xc(%eax),%eax
801049cd:	83 f8 02             	cmp    $0x2,%eax
801049d0:	75 50                	jne    80104a22 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801049d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049d5:	8b 40 1c             	mov    0x1c(%eax),%eax
801049d8:	8b 40 0c             	mov    0xc(%eax),%eax
801049db:	83 c0 08             	add    $0x8,%eax
801049de:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801049e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801049e5:	89 04 24             	mov    %eax,(%esp)
801049e8:	e8 5f 01 00 00       	call   80104b4c <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801049ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801049f4:	eb 1b                	jmp    80104a11 <procdump+0xc7>
        cprintf(" %p", pc[i]);
801049f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801049fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a01:	c7 04 24 01 84 10 80 	movl   $0x80108401,(%esp)
80104a08:	e8 93 b9 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104a0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a11:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104a15:	7f 0b                	jg     80104a22 <procdump+0xd8>
80104a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a1e:	85 c0                	test   %eax,%eax
80104a20:	75 d4                	jne    801049f6 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104a22:	c7 04 24 05 84 10 80 	movl   $0x80108405,(%esp)
80104a29:	e8 72 b9 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a2e:	81 45 f0 f4 00 00 00 	addl   $0xf4,-0x10(%ebp)
80104a35:	81 7d f0 54 3c 11 80 	cmpl   $0x80113c54,-0x10(%ebp)
80104a3c:	0f 82 1a ff ff ff    	jb     8010495c <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104a42:	c9                   	leave  
80104a43:	c3                   	ret    

80104a44 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104a44:	55                   	push   %ebp
80104a45:	89 e5                	mov    %esp,%ebp
80104a47:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104a4a:	9c                   	pushf  
80104a4b:	58                   	pop    %eax
80104a4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104a4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a52:	c9                   	leave  
80104a53:	c3                   	ret    

80104a54 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104a54:	55                   	push   %ebp
80104a55:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104a57:	fa                   	cli    
}
80104a58:	5d                   	pop    %ebp
80104a59:	c3                   	ret    

80104a5a <sti>:

static inline void
sti(void)
{
80104a5a:	55                   	push   %ebp
80104a5b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104a5d:	fb                   	sti    
}
80104a5e:	5d                   	pop    %ebp
80104a5f:	c3                   	ret    

80104a60 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104a60:	55                   	push   %ebp
80104a61:	89 e5                	mov    %esp,%ebp
80104a63:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104a66:	8b 55 08             	mov    0x8(%ebp),%edx
80104a69:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a6f:	f0 87 02             	lock xchg %eax,(%edx)
80104a72:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104a75:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a78:	c9                   	leave  
80104a79:	c3                   	ret    

80104a7a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104a7a:	55                   	push   %ebp
80104a7b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a80:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a83:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104a86:	8b 45 08             	mov    0x8(%ebp),%eax
80104a89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a92:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104a99:	5d                   	pop    %ebp
80104a9a:	c3                   	ret    

80104a9b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104a9b:	55                   	push   %ebp
80104a9c:	89 e5                	mov    %esp,%ebp
80104a9e:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104aa1:	e8 49 01 00 00       	call   80104bef <pushcli>
  if(holding(lk))
80104aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa9:	89 04 24             	mov    %eax,(%esp)
80104aac:	e8 14 01 00 00       	call   80104bc5 <holding>
80104ab1:	85 c0                	test   %eax,%eax
80104ab3:	74 0c                	je     80104ac1 <acquire+0x26>
    panic("acquire");
80104ab5:	c7 04 24 31 84 10 80 	movl   $0x80108431,(%esp)
80104abc:	e8 79 ba ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104ac1:	90                   	nop
80104ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104acc:	00 
80104acd:	89 04 24             	mov    %eax,(%esp)
80104ad0:	e8 8b ff ff ff       	call   80104a60 <xchg>
80104ad5:	85 c0                	test   %eax,%eax
80104ad7:	75 e9                	jne    80104ac2 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80104adc:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104ae3:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae9:	83 c0 0c             	add    $0xc,%eax
80104aec:	89 44 24 04          	mov    %eax,0x4(%esp)
80104af0:	8d 45 08             	lea    0x8(%ebp),%eax
80104af3:	89 04 24             	mov    %eax,(%esp)
80104af6:	e8 51 00 00 00       	call   80104b4c <getcallerpcs>
}
80104afb:	c9                   	leave  
80104afc:	c3                   	ret    

80104afd <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104afd:	55                   	push   %ebp
80104afe:	89 e5                	mov    %esp,%ebp
80104b00:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104b03:	8b 45 08             	mov    0x8(%ebp),%eax
80104b06:	89 04 24             	mov    %eax,(%esp)
80104b09:	e8 b7 00 00 00       	call   80104bc5 <holding>
80104b0e:	85 c0                	test   %eax,%eax
80104b10:	75 0c                	jne    80104b1e <release+0x21>
    panic("release");
80104b12:	c7 04 24 39 84 10 80 	movl   $0x80108439,(%esp)
80104b19:	e8 1c ba ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80104b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b21:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104b28:	8b 45 08             	mov    0x8(%ebp),%eax
80104b2b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104b32:	8b 45 08             	mov    0x8(%ebp),%eax
80104b35:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104b3c:	00 
80104b3d:	89 04 24             	mov    %eax,(%esp)
80104b40:	e8 1b ff ff ff       	call   80104a60 <xchg>

  popcli();
80104b45:	e8 e9 00 00 00       	call   80104c33 <popcli>
}
80104b4a:	c9                   	leave  
80104b4b:	c3                   	ret    

80104b4c <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104b4c:	55                   	push   %ebp
80104b4d:	89 e5                	mov    %esp,%ebp
80104b4f:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104b52:	8b 45 08             	mov    0x8(%ebp),%eax
80104b55:	83 e8 08             	sub    $0x8,%eax
80104b58:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104b5b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104b62:	eb 38                	jmp    80104b9c <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104b64:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104b68:	74 38                	je     80104ba2 <getcallerpcs+0x56>
80104b6a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104b71:	76 2f                	jbe    80104ba2 <getcallerpcs+0x56>
80104b73:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104b77:	74 29                	je     80104ba2 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104b79:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b7c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104b83:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b86:	01 c2                	add    %eax,%edx
80104b88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b8b:	8b 40 04             	mov    0x4(%eax),%eax
80104b8e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104b90:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b93:	8b 00                	mov    (%eax),%eax
80104b95:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104b98:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104b9c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104ba0:	7e c2                	jle    80104b64 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104ba2:	eb 19                	jmp    80104bbd <getcallerpcs+0x71>
    pcs[i] = 0;
80104ba4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ba7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104bae:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bb1:	01 d0                	add    %edx,%eax
80104bb3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104bb9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104bbd:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104bc1:	7e e1                	jle    80104ba4 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80104bc3:	c9                   	leave  
80104bc4:	c3                   	ret    

80104bc5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104bc5:	55                   	push   %ebp
80104bc6:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80104bcb:	8b 00                	mov    (%eax),%eax
80104bcd:	85 c0                	test   %eax,%eax
80104bcf:	74 17                	je     80104be8 <holding+0x23>
80104bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd4:	8b 50 08             	mov    0x8(%eax),%edx
80104bd7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104bdd:	39 c2                	cmp    %eax,%edx
80104bdf:	75 07                	jne    80104be8 <holding+0x23>
80104be1:	b8 01 00 00 00       	mov    $0x1,%eax
80104be6:	eb 05                	jmp    80104bed <holding+0x28>
80104be8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bed:	5d                   	pop    %ebp
80104bee:	c3                   	ret    

80104bef <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104bef:	55                   	push   %ebp
80104bf0:	89 e5                	mov    %esp,%ebp
80104bf2:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104bf5:	e8 4a fe ff ff       	call   80104a44 <readeflags>
80104bfa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104bfd:	e8 52 fe ff ff       	call   80104a54 <cli>
  if(cpu->ncli++ == 0)
80104c02:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c09:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80104c0f:	8d 48 01             	lea    0x1(%eax),%ecx
80104c12:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80104c18:	85 c0                	test   %eax,%eax
80104c1a:	75 15                	jne    80104c31 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80104c1c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c22:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c25:	81 e2 00 02 00 00    	and    $0x200,%edx
80104c2b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104c31:	c9                   	leave  
80104c32:	c3                   	ret    

80104c33 <popcli>:

void
popcli(void)
{
80104c33:	55                   	push   %ebp
80104c34:	89 e5                	mov    %esp,%ebp
80104c36:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80104c39:	e8 06 fe ff ff       	call   80104a44 <readeflags>
80104c3e:	25 00 02 00 00       	and    $0x200,%eax
80104c43:	85 c0                	test   %eax,%eax
80104c45:	74 0c                	je     80104c53 <popcli+0x20>
    panic("popcli - interruptible");
80104c47:	c7 04 24 41 84 10 80 	movl   $0x80108441,(%esp)
80104c4e:	e8 e7 b8 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80104c53:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c59:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104c5f:	83 ea 01             	sub    $0x1,%edx
80104c62:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104c68:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c6e:	85 c0                	test   %eax,%eax
80104c70:	79 0c                	jns    80104c7e <popcli+0x4b>
    panic("popcli");
80104c72:	c7 04 24 58 84 10 80 	movl   $0x80108458,(%esp)
80104c79:	e8 bc b8 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
80104c7e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c84:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c8a:	85 c0                	test   %eax,%eax
80104c8c:	75 15                	jne    80104ca3 <popcli+0x70>
80104c8e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c94:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104c9a:	85 c0                	test   %eax,%eax
80104c9c:	74 05                	je     80104ca3 <popcli+0x70>
    sti();
80104c9e:	e8 b7 fd ff ff       	call   80104a5a <sti>
}
80104ca3:	c9                   	leave  
80104ca4:	c3                   	ret    

80104ca5 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80104ca5:	55                   	push   %ebp
80104ca6:	89 e5                	mov    %esp,%ebp
80104ca8:	57                   	push   %edi
80104ca9:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104caa:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104cad:	8b 55 10             	mov    0x10(%ebp),%edx
80104cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cb3:	89 cb                	mov    %ecx,%ebx
80104cb5:	89 df                	mov    %ebx,%edi
80104cb7:	89 d1                	mov    %edx,%ecx
80104cb9:	fc                   	cld    
80104cba:	f3 aa                	rep stos %al,%es:(%edi)
80104cbc:	89 ca                	mov    %ecx,%edx
80104cbe:	89 fb                	mov    %edi,%ebx
80104cc0:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104cc3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104cc6:	5b                   	pop    %ebx
80104cc7:	5f                   	pop    %edi
80104cc8:	5d                   	pop    %ebp
80104cc9:	c3                   	ret    

80104cca <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80104cca:	55                   	push   %ebp
80104ccb:	89 e5                	mov    %esp,%ebp
80104ccd:	57                   	push   %edi
80104cce:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104ccf:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104cd2:	8b 55 10             	mov    0x10(%ebp),%edx
80104cd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cd8:	89 cb                	mov    %ecx,%ebx
80104cda:	89 df                	mov    %ebx,%edi
80104cdc:	89 d1                	mov    %edx,%ecx
80104cde:	fc                   	cld    
80104cdf:	f3 ab                	rep stos %eax,%es:(%edi)
80104ce1:	89 ca                	mov    %ecx,%edx
80104ce3:	89 fb                	mov    %edi,%ebx
80104ce5:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104ce8:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104ceb:	5b                   	pop    %ebx
80104cec:	5f                   	pop    %edi
80104ced:	5d                   	pop    %ebp
80104cee:	c3                   	ret    

80104cef <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104cef:	55                   	push   %ebp
80104cf0:	89 e5                	mov    %esp,%ebp
80104cf2:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80104cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf8:	83 e0 03             	and    $0x3,%eax
80104cfb:	85 c0                	test   %eax,%eax
80104cfd:	75 49                	jne    80104d48 <memset+0x59>
80104cff:	8b 45 10             	mov    0x10(%ebp),%eax
80104d02:	83 e0 03             	and    $0x3,%eax
80104d05:	85 c0                	test   %eax,%eax
80104d07:	75 3f                	jne    80104d48 <memset+0x59>
    c &= 0xFF;
80104d09:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104d10:	8b 45 10             	mov    0x10(%ebp),%eax
80104d13:	c1 e8 02             	shr    $0x2,%eax
80104d16:	89 c2                	mov    %eax,%edx
80104d18:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d1b:	c1 e0 18             	shl    $0x18,%eax
80104d1e:	89 c1                	mov    %eax,%ecx
80104d20:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d23:	c1 e0 10             	shl    $0x10,%eax
80104d26:	09 c1                	or     %eax,%ecx
80104d28:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d2b:	c1 e0 08             	shl    $0x8,%eax
80104d2e:	09 c8                	or     %ecx,%eax
80104d30:	0b 45 0c             	or     0xc(%ebp),%eax
80104d33:	89 54 24 08          	mov    %edx,0x8(%esp)
80104d37:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d3e:	89 04 24             	mov    %eax,(%esp)
80104d41:	e8 84 ff ff ff       	call   80104cca <stosl>
80104d46:	eb 19                	jmp    80104d61 <memset+0x72>
  } else
    stosb(dst, c, n);
80104d48:	8b 45 10             	mov    0x10(%ebp),%eax
80104d4b:	89 44 24 08          	mov    %eax,0x8(%esp)
80104d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d52:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d56:	8b 45 08             	mov    0x8(%ebp),%eax
80104d59:	89 04 24             	mov    %eax,(%esp)
80104d5c:	e8 44 ff ff ff       	call   80104ca5 <stosb>
  return dst;
80104d61:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104d64:	c9                   	leave  
80104d65:	c3                   	ret    

80104d66 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104d66:	55                   	push   %ebp
80104d67:	89 e5                	mov    %esp,%ebp
80104d69:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80104d6c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104d72:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d75:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104d78:	eb 30                	jmp    80104daa <memcmp+0x44>
    if(*s1 != *s2)
80104d7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d7d:	0f b6 10             	movzbl (%eax),%edx
80104d80:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d83:	0f b6 00             	movzbl (%eax),%eax
80104d86:	38 c2                	cmp    %al,%dl
80104d88:	74 18                	je     80104da2 <memcmp+0x3c>
      return *s1 - *s2;
80104d8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d8d:	0f b6 00             	movzbl (%eax),%eax
80104d90:	0f b6 d0             	movzbl %al,%edx
80104d93:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d96:	0f b6 00             	movzbl (%eax),%eax
80104d99:	0f b6 c0             	movzbl %al,%eax
80104d9c:	29 c2                	sub    %eax,%edx
80104d9e:	89 d0                	mov    %edx,%eax
80104da0:	eb 1a                	jmp    80104dbc <memcmp+0x56>
    s1++, s2++;
80104da2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104da6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104daa:	8b 45 10             	mov    0x10(%ebp),%eax
80104dad:	8d 50 ff             	lea    -0x1(%eax),%edx
80104db0:	89 55 10             	mov    %edx,0x10(%ebp)
80104db3:	85 c0                	test   %eax,%eax
80104db5:	75 c3                	jne    80104d7a <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80104db7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104dbc:	c9                   	leave  
80104dbd:	c3                   	ret    

80104dbe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104dbe:	55                   	push   %ebp
80104dbf:	89 e5                	mov    %esp,%ebp
80104dc1:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dc7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104dca:	8b 45 08             	mov    0x8(%ebp),%eax
80104dcd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104dd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dd3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104dd6:	73 3d                	jae    80104e15 <memmove+0x57>
80104dd8:	8b 45 10             	mov    0x10(%ebp),%eax
80104ddb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104dde:	01 d0                	add    %edx,%eax
80104de0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104de3:	76 30                	jbe    80104e15 <memmove+0x57>
    s += n;
80104de5:	8b 45 10             	mov    0x10(%ebp),%eax
80104de8:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104deb:	8b 45 10             	mov    0x10(%ebp),%eax
80104dee:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104df1:	eb 13                	jmp    80104e06 <memmove+0x48>
      *--d = *--s;
80104df3:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104df7:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104dfb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dfe:	0f b6 10             	movzbl (%eax),%edx
80104e01:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e04:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80104e06:	8b 45 10             	mov    0x10(%ebp),%eax
80104e09:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e0c:	89 55 10             	mov    %edx,0x10(%ebp)
80104e0f:	85 c0                	test   %eax,%eax
80104e11:	75 e0                	jne    80104df3 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104e13:	eb 26                	jmp    80104e3b <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80104e15:	eb 17                	jmp    80104e2e <memmove+0x70>
      *d++ = *s++;
80104e17:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e1a:	8d 50 01             	lea    0x1(%eax),%edx
80104e1d:	89 55 f8             	mov    %edx,-0x8(%ebp)
80104e20:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e23:	8d 4a 01             	lea    0x1(%edx),%ecx
80104e26:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80104e29:	0f b6 12             	movzbl (%edx),%edx
80104e2c:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80104e2e:	8b 45 10             	mov    0x10(%ebp),%eax
80104e31:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e34:	89 55 10             	mov    %edx,0x10(%ebp)
80104e37:	85 c0                	test   %eax,%eax
80104e39:	75 dc                	jne    80104e17 <memmove+0x59>
      *d++ = *s++;

  return dst;
80104e3b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e3e:	c9                   	leave  
80104e3f:	c3                   	ret    

80104e40 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104e40:	55                   	push   %ebp
80104e41:	89 e5                	mov    %esp,%ebp
80104e43:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80104e46:	8b 45 10             	mov    0x10(%ebp),%eax
80104e49:	89 44 24 08          	mov    %eax,0x8(%esp)
80104e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e50:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e54:	8b 45 08             	mov    0x8(%ebp),%eax
80104e57:	89 04 24             	mov    %eax,(%esp)
80104e5a:	e8 5f ff ff ff       	call   80104dbe <memmove>
}
80104e5f:	c9                   	leave  
80104e60:	c3                   	ret    

80104e61 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104e61:	55                   	push   %ebp
80104e62:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104e64:	eb 0c                	jmp    80104e72 <strncmp+0x11>
    n--, p++, q++;
80104e66:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104e6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104e6e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80104e72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e76:	74 1a                	je     80104e92 <strncmp+0x31>
80104e78:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7b:	0f b6 00             	movzbl (%eax),%eax
80104e7e:	84 c0                	test   %al,%al
80104e80:	74 10                	je     80104e92 <strncmp+0x31>
80104e82:	8b 45 08             	mov    0x8(%ebp),%eax
80104e85:	0f b6 10             	movzbl (%eax),%edx
80104e88:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e8b:	0f b6 00             	movzbl (%eax),%eax
80104e8e:	38 c2                	cmp    %al,%dl
80104e90:	74 d4                	je     80104e66 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80104e92:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e96:	75 07                	jne    80104e9f <strncmp+0x3e>
    return 0;
80104e98:	b8 00 00 00 00       	mov    $0x0,%eax
80104e9d:	eb 16                	jmp    80104eb5 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea2:	0f b6 00             	movzbl (%eax),%eax
80104ea5:	0f b6 d0             	movzbl %al,%edx
80104ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eab:	0f b6 00             	movzbl (%eax),%eax
80104eae:	0f b6 c0             	movzbl %al,%eax
80104eb1:	29 c2                	sub    %eax,%edx
80104eb3:	89 d0                	mov    %edx,%eax
}
80104eb5:	5d                   	pop    %ebp
80104eb6:	c3                   	ret    

80104eb7 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104eb7:	55                   	push   %ebp
80104eb8:	89 e5                	mov    %esp,%ebp
80104eba:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80104ebd:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104ec3:	90                   	nop
80104ec4:	8b 45 10             	mov    0x10(%ebp),%eax
80104ec7:	8d 50 ff             	lea    -0x1(%eax),%edx
80104eca:	89 55 10             	mov    %edx,0x10(%ebp)
80104ecd:	85 c0                	test   %eax,%eax
80104ecf:	7e 1e                	jle    80104eef <strncpy+0x38>
80104ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed4:	8d 50 01             	lea    0x1(%eax),%edx
80104ed7:	89 55 08             	mov    %edx,0x8(%ebp)
80104eda:	8b 55 0c             	mov    0xc(%ebp),%edx
80104edd:	8d 4a 01             	lea    0x1(%edx),%ecx
80104ee0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80104ee3:	0f b6 12             	movzbl (%edx),%edx
80104ee6:	88 10                	mov    %dl,(%eax)
80104ee8:	0f b6 00             	movzbl (%eax),%eax
80104eeb:	84 c0                	test   %al,%al
80104eed:	75 d5                	jne    80104ec4 <strncpy+0xd>
    ;
  while(n-- > 0)
80104eef:	eb 0c                	jmp    80104efd <strncpy+0x46>
    *s++ = 0;
80104ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef4:	8d 50 01             	lea    0x1(%eax),%edx
80104ef7:	89 55 08             	mov    %edx,0x8(%ebp)
80104efa:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80104efd:	8b 45 10             	mov    0x10(%ebp),%eax
80104f00:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f03:	89 55 10             	mov    %edx,0x10(%ebp)
80104f06:	85 c0                	test   %eax,%eax
80104f08:	7f e7                	jg     80104ef1 <strncpy+0x3a>
    *s++ = 0;
  return os;
80104f0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f0d:	c9                   	leave  
80104f0e:	c3                   	ret    

80104f0f <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104f0f:	55                   	push   %ebp
80104f10:	89 e5                	mov    %esp,%ebp
80104f12:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80104f15:	8b 45 08             	mov    0x8(%ebp),%eax
80104f18:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104f1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f1f:	7f 05                	jg     80104f26 <safestrcpy+0x17>
    return os;
80104f21:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f24:	eb 31                	jmp    80104f57 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80104f26:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f2e:	7e 1e                	jle    80104f4e <safestrcpy+0x3f>
80104f30:	8b 45 08             	mov    0x8(%ebp),%eax
80104f33:	8d 50 01             	lea    0x1(%eax),%edx
80104f36:	89 55 08             	mov    %edx,0x8(%ebp)
80104f39:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f3c:	8d 4a 01             	lea    0x1(%edx),%ecx
80104f3f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80104f42:	0f b6 12             	movzbl (%edx),%edx
80104f45:	88 10                	mov    %dl,(%eax)
80104f47:	0f b6 00             	movzbl (%eax),%eax
80104f4a:	84 c0                	test   %al,%al
80104f4c:	75 d8                	jne    80104f26 <safestrcpy+0x17>
    ;
  *s = 0;
80104f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f51:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104f54:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f57:	c9                   	leave  
80104f58:	c3                   	ret    

80104f59 <strlen>:

int
strlen(const char *s)
{
80104f59:	55                   	push   %ebp
80104f5a:	89 e5                	mov    %esp,%ebp
80104f5c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104f5f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104f66:	eb 04                	jmp    80104f6c <strlen+0x13>
80104f68:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104f6c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f72:	01 d0                	add    %edx,%eax
80104f74:	0f b6 00             	movzbl (%eax),%eax
80104f77:	84 c0                	test   %al,%al
80104f79:	75 ed                	jne    80104f68 <strlen+0xf>
    ;
  return n;
80104f7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f7e:	c9                   	leave  
80104f7f:	c3                   	ret    

80104f80 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104f80:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104f84:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104f88:	55                   	push   %ebp
  pushl %ebx
80104f89:	53                   	push   %ebx
  pushl %esi
80104f8a:	56                   	push   %esi
  pushl %edi
80104f8b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104f8c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104f8e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104f90:	5f                   	pop    %edi
  popl %esi
80104f91:	5e                   	pop    %esi
  popl %ebx
80104f92:	5b                   	pop    %ebx
  popl %ebp
80104f93:	5d                   	pop    %ebp
  ret
80104f94:	c3                   	ret    

80104f95 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104f95:	55                   	push   %ebp
80104f96:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80104f98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f9e:	8b 00                	mov    (%eax),%eax
80104fa0:	3b 45 08             	cmp    0x8(%ebp),%eax
80104fa3:	76 12                	jbe    80104fb7 <fetchint+0x22>
80104fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa8:	8d 50 04             	lea    0x4(%eax),%edx
80104fab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fb1:	8b 00                	mov    (%eax),%eax
80104fb3:	39 c2                	cmp    %eax,%edx
80104fb5:	76 07                	jbe    80104fbe <fetchint+0x29>
    return -1;
80104fb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fbc:	eb 0f                	jmp    80104fcd <fetchint+0x38>
  *ip = *(int*)(addr);
80104fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc1:	8b 10                	mov    (%eax),%edx
80104fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fc6:	89 10                	mov    %edx,(%eax)
  return 0;
80104fc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fcd:	5d                   	pop    %ebp
80104fce:	c3                   	ret    

80104fcf <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104fcf:	55                   	push   %ebp
80104fd0:	89 e5                	mov    %esp,%ebp
80104fd2:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80104fd5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fdb:	8b 00                	mov    (%eax),%eax
80104fdd:	3b 45 08             	cmp    0x8(%ebp),%eax
80104fe0:	77 07                	ja     80104fe9 <fetchstr+0x1a>
    return -1;
80104fe2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fe7:	eb 46                	jmp    8010502f <fetchstr+0x60>
  *pp = (char*)addr;
80104fe9:	8b 55 08             	mov    0x8(%ebp),%edx
80104fec:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fef:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80104ff1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ff7:	8b 00                	mov    (%eax),%eax
80104ff9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80104ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fff:	8b 00                	mov    (%eax),%eax
80105001:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105004:	eb 1c                	jmp    80105022 <fetchstr+0x53>
    if(*s == 0)
80105006:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105009:	0f b6 00             	movzbl (%eax),%eax
8010500c:	84 c0                	test   %al,%al
8010500e:	75 0e                	jne    8010501e <fetchstr+0x4f>
      return s - *pp;
80105010:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105013:	8b 45 0c             	mov    0xc(%ebp),%eax
80105016:	8b 00                	mov    (%eax),%eax
80105018:	29 c2                	sub    %eax,%edx
8010501a:	89 d0                	mov    %edx,%eax
8010501c:	eb 11                	jmp    8010502f <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010501e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105022:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105025:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105028:	72 dc                	jb     80105006 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010502a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010502f:	c9                   	leave  
80105030:	c3                   	ret    

80105031 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105031:	55                   	push   %ebp
80105032:	89 e5                	mov    %esp,%ebp
80105034:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105037:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010503d:	8b 40 18             	mov    0x18(%eax),%eax
80105040:	8b 50 44             	mov    0x44(%eax),%edx
80105043:	8b 45 08             	mov    0x8(%ebp),%eax
80105046:	c1 e0 02             	shl    $0x2,%eax
80105049:	01 d0                	add    %edx,%eax
8010504b:	8d 50 04             	lea    0x4(%eax),%edx
8010504e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105051:	89 44 24 04          	mov    %eax,0x4(%esp)
80105055:	89 14 24             	mov    %edx,(%esp)
80105058:	e8 38 ff ff ff       	call   80104f95 <fetchint>
}
8010505d:	c9                   	leave  
8010505e:	c3                   	ret    

8010505f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010505f:	55                   	push   %ebp
80105060:	89 e5                	mov    %esp,%ebp
80105062:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105065:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105068:	89 44 24 04          	mov    %eax,0x4(%esp)
8010506c:	8b 45 08             	mov    0x8(%ebp),%eax
8010506f:	89 04 24             	mov    %eax,(%esp)
80105072:	e8 ba ff ff ff       	call   80105031 <argint>
80105077:	85 c0                	test   %eax,%eax
80105079:	79 07                	jns    80105082 <argptr+0x23>
    return -1;
8010507b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105080:	eb 3d                	jmp    801050bf <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105082:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105085:	89 c2                	mov    %eax,%edx
80105087:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010508d:	8b 00                	mov    (%eax),%eax
8010508f:	39 c2                	cmp    %eax,%edx
80105091:	73 16                	jae    801050a9 <argptr+0x4a>
80105093:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105096:	89 c2                	mov    %eax,%edx
80105098:	8b 45 10             	mov    0x10(%ebp),%eax
8010509b:	01 c2                	add    %eax,%edx
8010509d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050a3:	8b 00                	mov    (%eax),%eax
801050a5:	39 c2                	cmp    %eax,%edx
801050a7:	76 07                	jbe    801050b0 <argptr+0x51>
    return -1;
801050a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ae:	eb 0f                	jmp    801050bf <argptr+0x60>
  *pp = (char*)i;
801050b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050b3:	89 c2                	mov    %eax,%edx
801050b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801050b8:	89 10                	mov    %edx,(%eax)
  return 0;
801050ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050bf:	c9                   	leave  
801050c0:	c3                   	ret    

801050c1 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801050c1:	55                   	push   %ebp
801050c2:	89 e5                	mov    %esp,%ebp
801050c4:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801050c7:	8d 45 fc             	lea    -0x4(%ebp),%eax
801050ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801050ce:	8b 45 08             	mov    0x8(%ebp),%eax
801050d1:	89 04 24             	mov    %eax,(%esp)
801050d4:	e8 58 ff ff ff       	call   80105031 <argint>
801050d9:	85 c0                	test   %eax,%eax
801050db:	79 07                	jns    801050e4 <argstr+0x23>
    return -1;
801050dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e2:	eb 12                	jmp    801050f6 <argstr+0x35>
  return fetchstr(addr, pp);
801050e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050e7:	8b 55 0c             	mov    0xc(%ebp),%edx
801050ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801050ee:	89 04 24             	mov    %eax,(%esp)
801050f1:	e8 d9 fe ff ff       	call   80104fcf <fetchstr>
}
801050f6:	c9                   	leave  
801050f7:	c3                   	ret    

801050f8 <syscall>:
[SYS_getcount] sys_getcount,
};

void
syscall(void)
{
801050f8:	55                   	push   %ebp
801050f9:	89 e5                	mov    %esp,%ebp
801050fb:	53                   	push   %ebx
801050fc:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801050ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105105:	8b 40 18             	mov    0x18(%eax),%eax
80105108:	8b 40 1c             	mov    0x1c(%eax),%eax
8010510b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010510e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105112:	7e 5a                	jle    8010516e <syscall+0x76>
80105114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105117:	83 f8 16             	cmp    $0x16,%eax
8010511a:	77 52                	ja     8010516e <syscall+0x76>
8010511c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511f:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105126:	85 c0                	test   %eax,%eax
80105128:	74 44                	je     8010516e <syscall+0x76>
    
    // Increment system call counter of current process 
    // for the specified syscall/eax.
    proc->sccount[num-1] = proc->sccount[num-1] + 1;
8010512a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105130:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105133:	8d 5a ff             	lea    -0x1(%edx),%ebx
80105136:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010513d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105140:	83 e9 01             	sub    $0x1,%ecx
80105143:	83 c1 1c             	add    $0x1c,%ecx
80105146:	8b 54 8a 0c          	mov    0xc(%edx,%ecx,4),%edx
8010514a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010514d:	8d 53 1c             	lea    0x1c(%ebx),%edx
80105150:	89 4c 90 0c          	mov    %ecx,0xc(%eax,%edx,4)
    proc->tf->eax = syscalls[num]();
80105154:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010515a:	8b 58 18             	mov    0x18(%eax),%ebx
8010515d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105160:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105167:	ff d0                	call   *%eax
80105169:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010516c:	eb 3d                	jmp    801051ab <syscall+0xb3>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010516e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105174:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105177:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    // Increment system call counter of current process 
    // for the specified syscall/eax.
    proc->sccount[num-1] = proc->sccount[num-1] + 1;
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010517d:	8b 40 10             	mov    0x10(%eax),%eax
80105180:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105183:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105187:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010518b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010518f:	c7 04 24 5f 84 10 80 	movl   $0x8010845f,(%esp)
80105196:	e8 05 b2 ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010519b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051a1:	8b 40 18             	mov    0x18(%eax),%eax
801051a4:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801051ab:	83 c4 24             	add    $0x24,%esp
801051ae:	5b                   	pop    %ebx
801051af:	5d                   	pop    %ebp
801051b0:	c3                   	ret    

801051b1 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801051b1:	55                   	push   %ebp
801051b2:	89 e5                	mov    %esp,%ebp
801051b4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801051b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801051be:	8b 45 08             	mov    0x8(%ebp),%eax
801051c1:	89 04 24             	mov    %eax,(%esp)
801051c4:	e8 68 fe ff ff       	call   80105031 <argint>
801051c9:	85 c0                	test   %eax,%eax
801051cb:	79 07                	jns    801051d4 <argfd+0x23>
    return -1;
801051cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051d2:	eb 50                	jmp    80105224 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801051d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051d7:	85 c0                	test   %eax,%eax
801051d9:	78 21                	js     801051fc <argfd+0x4b>
801051db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051de:	83 f8 0f             	cmp    $0xf,%eax
801051e1:	7f 19                	jg     801051fc <argfd+0x4b>
801051e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051ec:	83 c2 08             	add    $0x8,%edx
801051ef:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801051f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051fa:	75 07                	jne    80105203 <argfd+0x52>
    return -1;
801051fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105201:	eb 21                	jmp    80105224 <argfd+0x73>
  if(pfd)
80105203:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105207:	74 08                	je     80105211 <argfd+0x60>
    *pfd = fd;
80105209:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010520c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010520f:	89 10                	mov    %edx,(%eax)
  if(pf)
80105211:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105215:	74 08                	je     8010521f <argfd+0x6e>
    *pf = f;
80105217:	8b 45 10             	mov    0x10(%ebp),%eax
8010521a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010521d:	89 10                	mov    %edx,(%eax)
  return 0;
8010521f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105224:	c9                   	leave  
80105225:	c3                   	ret    

80105226 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105226:	55                   	push   %ebp
80105227:	89 e5                	mov    %esp,%ebp
80105229:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010522c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105233:	eb 30                	jmp    80105265 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105235:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010523b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010523e:	83 c2 08             	add    $0x8,%edx
80105241:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105245:	85 c0                	test   %eax,%eax
80105247:	75 18                	jne    80105261 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105249:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010524f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105252:	8d 4a 08             	lea    0x8(%edx),%ecx
80105255:	8b 55 08             	mov    0x8(%ebp),%edx
80105258:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010525c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010525f:	eb 0f                	jmp    80105270 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105261:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105265:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105269:	7e ca                	jle    80105235 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010526b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105270:	c9                   	leave  
80105271:	c3                   	ret    

80105272 <sys_dup>:

int
sys_dup(void)
{
80105272:	55                   	push   %ebp
80105273:	89 e5                	mov    %esp,%ebp
80105275:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105278:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010527b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010527f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105286:	00 
80105287:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010528e:	e8 1e ff ff ff       	call   801051b1 <argfd>
80105293:	85 c0                	test   %eax,%eax
80105295:	79 07                	jns    8010529e <sys_dup+0x2c>
    return -1;
80105297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010529c:	eb 29                	jmp    801052c7 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010529e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052a1:	89 04 24             	mov    %eax,(%esp)
801052a4:	e8 7d ff ff ff       	call   80105226 <fdalloc>
801052a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052b0:	79 07                	jns    801052b9 <sys_dup+0x47>
    return -1;
801052b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b7:	eb 0e                	jmp    801052c7 <sys_dup+0x55>
  filedup(f);
801052b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052bc:	89 04 24             	mov    %eax,(%esp)
801052bf:	e8 ae bc ff ff       	call   80100f72 <filedup>
  return fd;
801052c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801052c7:	c9                   	leave  
801052c8:	c3                   	ret    

801052c9 <sys_read>:

int
sys_read(void)
{
801052c9:	55                   	push   %ebp
801052ca:	89 e5                	mov    %esp,%ebp
801052cc:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801052cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052d2:	89 44 24 08          	mov    %eax,0x8(%esp)
801052d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801052dd:	00 
801052de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801052e5:	e8 c7 fe ff ff       	call   801051b1 <argfd>
801052ea:	85 c0                	test   %eax,%eax
801052ec:	78 35                	js     80105323 <sys_read+0x5a>
801052ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801052f5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801052fc:	e8 30 fd ff ff       	call   80105031 <argint>
80105301:	85 c0                	test   %eax,%eax
80105303:	78 1e                	js     80105323 <sys_read+0x5a>
80105305:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105308:	89 44 24 08          	mov    %eax,0x8(%esp)
8010530c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010530f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105313:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010531a:	e8 40 fd ff ff       	call   8010505f <argptr>
8010531f:	85 c0                	test   %eax,%eax
80105321:	79 07                	jns    8010532a <sys_read+0x61>
    return -1;
80105323:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105328:	eb 19                	jmp    80105343 <sys_read+0x7a>
  return fileread(f, p, n);
8010532a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010532d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105333:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105337:	89 54 24 04          	mov    %edx,0x4(%esp)
8010533b:	89 04 24             	mov    %eax,(%esp)
8010533e:	e8 9c bd ff ff       	call   801010df <fileread>
}
80105343:	c9                   	leave  
80105344:	c3                   	ret    

80105345 <sys_write>:

int
sys_write(void)
{
80105345:	55                   	push   %ebp
80105346:	89 e5                	mov    %esp,%ebp
80105348:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010534b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010534e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105352:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105359:	00 
8010535a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105361:	e8 4b fe ff ff       	call   801051b1 <argfd>
80105366:	85 c0                	test   %eax,%eax
80105368:	78 35                	js     8010539f <sys_write+0x5a>
8010536a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010536d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105371:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105378:	e8 b4 fc ff ff       	call   80105031 <argint>
8010537d:	85 c0                	test   %eax,%eax
8010537f:	78 1e                	js     8010539f <sys_write+0x5a>
80105381:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105384:	89 44 24 08          	mov    %eax,0x8(%esp)
80105388:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010538b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010538f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105396:	e8 c4 fc ff ff       	call   8010505f <argptr>
8010539b:	85 c0                	test   %eax,%eax
8010539d:	79 07                	jns    801053a6 <sys_write+0x61>
    return -1;
8010539f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a4:	eb 19                	jmp    801053bf <sys_write+0x7a>
  return filewrite(f, p, n);
801053a6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801053b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801053b7:	89 04 24             	mov    %eax,(%esp)
801053ba:	e8 dc bd ff ff       	call   8010119b <filewrite>
}
801053bf:	c9                   	leave  
801053c0:	c3                   	ret    

801053c1 <sys_close>:

int
sys_close(void)
{
801053c1:	55                   	push   %ebp
801053c2:	89 e5                	mov    %esp,%ebp
801053c4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801053c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053ca:	89 44 24 08          	mov    %eax,0x8(%esp)
801053ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801053d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801053dc:	e8 d0 fd ff ff       	call   801051b1 <argfd>
801053e1:	85 c0                	test   %eax,%eax
801053e3:	79 07                	jns    801053ec <sys_close+0x2b>
    return -1;
801053e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ea:	eb 24                	jmp    80105410 <sys_close+0x4f>
  proc->ofile[fd] = 0;
801053ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053f5:	83 c2 08             	add    $0x8,%edx
801053f8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801053ff:	00 
  fileclose(f);
80105400:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105403:	89 04 24             	mov    %eax,(%esp)
80105406:	e8 af bb ff ff       	call   80100fba <fileclose>
  return 0;
8010540b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105410:	c9                   	leave  
80105411:	c3                   	ret    

80105412 <sys_fstat>:

int
sys_fstat(void)
{
80105412:	55                   	push   %ebp
80105413:	89 e5                	mov    %esp,%ebp
80105415:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105418:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010541b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010541f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105426:	00 
80105427:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010542e:	e8 7e fd ff ff       	call   801051b1 <argfd>
80105433:	85 c0                	test   %eax,%eax
80105435:	78 1f                	js     80105456 <sys_fstat+0x44>
80105437:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010543e:	00 
8010543f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105442:	89 44 24 04          	mov    %eax,0x4(%esp)
80105446:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010544d:	e8 0d fc ff ff       	call   8010505f <argptr>
80105452:	85 c0                	test   %eax,%eax
80105454:	79 07                	jns    8010545d <sys_fstat+0x4b>
    return -1;
80105456:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010545b:	eb 12                	jmp    8010546f <sys_fstat+0x5d>
  return filestat(f, st);
8010545d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105463:	89 54 24 04          	mov    %edx,0x4(%esp)
80105467:	89 04 24             	mov    %eax,(%esp)
8010546a:	e8 21 bc ff ff       	call   80101090 <filestat>
}
8010546f:	c9                   	leave  
80105470:	c3                   	ret    

80105471 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105471:	55                   	push   %ebp
80105472:	89 e5                	mov    %esp,%ebp
80105474:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105477:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010547a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010547e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105485:	e8 37 fc ff ff       	call   801050c1 <argstr>
8010548a:	85 c0                	test   %eax,%eax
8010548c:	78 17                	js     801054a5 <sys_link+0x34>
8010548e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105491:	89 44 24 04          	mov    %eax,0x4(%esp)
80105495:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010549c:	e8 20 fc ff ff       	call   801050c1 <argstr>
801054a1:	85 c0                	test   %eax,%eax
801054a3:	79 0a                	jns    801054af <sys_link+0x3e>
    return -1;
801054a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054aa:	e9 3d 01 00 00       	jmp    801055ec <sys_link+0x17b>
  if((ip = namei(old)) == 0)
801054af:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054b2:	89 04 24             	mov    %eax,(%esp)
801054b5:	e8 38 cf ff ff       	call   801023f2 <namei>
801054ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054c1:	75 0a                	jne    801054cd <sys_link+0x5c>
    return -1;
801054c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054c8:	e9 1f 01 00 00       	jmp    801055ec <sys_link+0x17b>

  begin_trans();
801054cd:	e8 ff dc ff ff       	call   801031d1 <begin_trans>

  ilock(ip);
801054d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d5:	89 04 24             	mov    %eax,(%esp)
801054d8:	e8 6a c3 ff ff       	call   80101847 <ilock>
  if(ip->type == T_DIR){
801054dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054e0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801054e4:	66 83 f8 01          	cmp    $0x1,%ax
801054e8:	75 1a                	jne    80105504 <sys_link+0x93>
    iunlockput(ip);
801054ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ed:	89 04 24             	mov    %eax,(%esp)
801054f0:	e8 d6 c5 ff ff       	call   80101acb <iunlockput>
    commit_trans();
801054f5:	e8 20 dd ff ff       	call   8010321a <commit_trans>
    return -1;
801054fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ff:	e9 e8 00 00 00       	jmp    801055ec <sys_link+0x17b>
  }

  ip->nlink++;
80105504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105507:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010550b:	8d 50 01             	lea    0x1(%eax),%edx
8010550e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105511:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105518:	89 04 24             	mov    %eax,(%esp)
8010551b:	e8 6b c1 ff ff       	call   8010168b <iupdate>
  iunlock(ip);
80105520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105523:	89 04 24             	mov    %eax,(%esp)
80105526:	e8 6a c4 ff ff       	call   80101995 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010552b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010552e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105531:	89 54 24 04          	mov    %edx,0x4(%esp)
80105535:	89 04 24             	mov    %eax,(%esp)
80105538:	e8 d7 ce ff ff       	call   80102414 <nameiparent>
8010553d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105540:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105544:	75 02                	jne    80105548 <sys_link+0xd7>
    goto bad;
80105546:	eb 68                	jmp    801055b0 <sys_link+0x13f>
  ilock(dp);
80105548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010554b:	89 04 24             	mov    %eax,(%esp)
8010554e:	e8 f4 c2 ff ff       	call   80101847 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105553:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105556:	8b 10                	mov    (%eax),%edx
80105558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010555b:	8b 00                	mov    (%eax),%eax
8010555d:	39 c2                	cmp    %eax,%edx
8010555f:	75 20                	jne    80105581 <sys_link+0x110>
80105561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105564:	8b 40 04             	mov    0x4(%eax),%eax
80105567:	89 44 24 08          	mov    %eax,0x8(%esp)
8010556b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010556e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105572:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105575:	89 04 24             	mov    %eax,(%esp)
80105578:	e8 b5 cb ff ff       	call   80102132 <dirlink>
8010557d:	85 c0                	test   %eax,%eax
8010557f:	79 0d                	jns    8010558e <sys_link+0x11d>
    iunlockput(dp);
80105581:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105584:	89 04 24             	mov    %eax,(%esp)
80105587:	e8 3f c5 ff ff       	call   80101acb <iunlockput>
    goto bad;
8010558c:	eb 22                	jmp    801055b0 <sys_link+0x13f>
  }
  iunlockput(dp);
8010558e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105591:	89 04 24             	mov    %eax,(%esp)
80105594:	e8 32 c5 ff ff       	call   80101acb <iunlockput>
  iput(ip);
80105599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559c:	89 04 24             	mov    %eax,(%esp)
8010559f:	e8 56 c4 ff ff       	call   801019fa <iput>

  commit_trans();
801055a4:	e8 71 dc ff ff       	call   8010321a <commit_trans>

  return 0;
801055a9:	b8 00 00 00 00       	mov    $0x0,%eax
801055ae:	eb 3c                	jmp    801055ec <sys_link+0x17b>

bad:
  ilock(ip);
801055b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b3:	89 04 24             	mov    %eax,(%esp)
801055b6:	e8 8c c2 ff ff       	call   80101847 <ilock>
  ip->nlink--;
801055bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055be:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801055c2:	8d 50 ff             	lea    -0x1(%eax),%edx
801055c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c8:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801055cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055cf:	89 04 24             	mov    %eax,(%esp)
801055d2:	e8 b4 c0 ff ff       	call   8010168b <iupdate>
  iunlockput(ip);
801055d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055da:	89 04 24             	mov    %eax,(%esp)
801055dd:	e8 e9 c4 ff ff       	call   80101acb <iunlockput>
  commit_trans();
801055e2:	e8 33 dc ff ff       	call   8010321a <commit_trans>
  return -1;
801055e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055ec:	c9                   	leave  
801055ed:	c3                   	ret    

801055ee <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801055ee:	55                   	push   %ebp
801055ef:	89 e5                	mov    %esp,%ebp
801055f1:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801055f4:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801055fb:	eb 4b                	jmp    80105648 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801055fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105600:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105607:	00 
80105608:	89 44 24 08          	mov    %eax,0x8(%esp)
8010560c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010560f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105613:	8b 45 08             	mov    0x8(%ebp),%eax
80105616:	89 04 24             	mov    %eax,(%esp)
80105619:	e8 36 c7 ff ff       	call   80101d54 <readi>
8010561e:	83 f8 10             	cmp    $0x10,%eax
80105621:	74 0c                	je     8010562f <isdirempty+0x41>
      panic("isdirempty: readi");
80105623:	c7 04 24 7b 84 10 80 	movl   $0x8010847b,(%esp)
8010562a:	e8 0b af ff ff       	call   8010053a <panic>
    if(de.inum != 0)
8010562f:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105633:	66 85 c0             	test   %ax,%ax
80105636:	74 07                	je     8010563f <isdirempty+0x51>
      return 0;
80105638:	b8 00 00 00 00       	mov    $0x0,%eax
8010563d:	eb 1b                	jmp    8010565a <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010563f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105642:	83 c0 10             	add    $0x10,%eax
80105645:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105648:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010564b:	8b 45 08             	mov    0x8(%ebp),%eax
8010564e:	8b 40 18             	mov    0x18(%eax),%eax
80105651:	39 c2                	cmp    %eax,%edx
80105653:	72 a8                	jb     801055fd <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105655:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010565a:	c9                   	leave  
8010565b:	c3                   	ret    

8010565c <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010565c:	55                   	push   %ebp
8010565d:	89 e5                	mov    %esp,%ebp
8010565f:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105662:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105665:	89 44 24 04          	mov    %eax,0x4(%esp)
80105669:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105670:	e8 4c fa ff ff       	call   801050c1 <argstr>
80105675:	85 c0                	test   %eax,%eax
80105677:	79 0a                	jns    80105683 <sys_unlink+0x27>
    return -1;
80105679:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010567e:	e9 aa 01 00 00       	jmp    8010582d <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105683:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105686:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105689:	89 54 24 04          	mov    %edx,0x4(%esp)
8010568d:	89 04 24             	mov    %eax,(%esp)
80105690:	e8 7f cd ff ff       	call   80102414 <nameiparent>
80105695:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105698:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010569c:	75 0a                	jne    801056a8 <sys_unlink+0x4c>
    return -1;
8010569e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056a3:	e9 85 01 00 00       	jmp    8010582d <sys_unlink+0x1d1>

  begin_trans();
801056a8:	e8 24 db ff ff       	call   801031d1 <begin_trans>

  ilock(dp);
801056ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b0:	89 04 24             	mov    %eax,(%esp)
801056b3:	e8 8f c1 ff ff       	call   80101847 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801056b8:	c7 44 24 04 8d 84 10 	movl   $0x8010848d,0x4(%esp)
801056bf:	80 
801056c0:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056c3:	89 04 24             	mov    %eax,(%esp)
801056c6:	e8 7c c9 ff ff       	call   80102047 <namecmp>
801056cb:	85 c0                	test   %eax,%eax
801056cd:	0f 84 45 01 00 00    	je     80105818 <sys_unlink+0x1bc>
801056d3:	c7 44 24 04 8f 84 10 	movl   $0x8010848f,0x4(%esp)
801056da:	80 
801056db:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056de:	89 04 24             	mov    %eax,(%esp)
801056e1:	e8 61 c9 ff ff       	call   80102047 <namecmp>
801056e6:	85 c0                	test   %eax,%eax
801056e8:	0f 84 2a 01 00 00    	je     80105818 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801056ee:	8d 45 c8             	lea    -0x38(%ebp),%eax
801056f1:	89 44 24 08          	mov    %eax,0x8(%esp)
801056f5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801056fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ff:	89 04 24             	mov    %eax,(%esp)
80105702:	e8 62 c9 ff ff       	call   80102069 <dirlookup>
80105707:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010570a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010570e:	75 05                	jne    80105715 <sys_unlink+0xb9>
    goto bad;
80105710:	e9 03 01 00 00       	jmp    80105818 <sys_unlink+0x1bc>
  ilock(ip);
80105715:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105718:	89 04 24             	mov    %eax,(%esp)
8010571b:	e8 27 c1 ff ff       	call   80101847 <ilock>

  if(ip->nlink < 1)
80105720:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105723:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105727:	66 85 c0             	test   %ax,%ax
8010572a:	7f 0c                	jg     80105738 <sys_unlink+0xdc>
    panic("unlink: nlink < 1");
8010572c:	c7 04 24 92 84 10 80 	movl   $0x80108492,(%esp)
80105733:	e8 02 ae ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010573b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010573f:	66 83 f8 01          	cmp    $0x1,%ax
80105743:	75 1f                	jne    80105764 <sys_unlink+0x108>
80105745:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105748:	89 04 24             	mov    %eax,(%esp)
8010574b:	e8 9e fe ff ff       	call   801055ee <isdirempty>
80105750:	85 c0                	test   %eax,%eax
80105752:	75 10                	jne    80105764 <sys_unlink+0x108>
    iunlockput(ip);
80105754:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105757:	89 04 24             	mov    %eax,(%esp)
8010575a:	e8 6c c3 ff ff       	call   80101acb <iunlockput>
    goto bad;
8010575f:	e9 b4 00 00 00       	jmp    80105818 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105764:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010576b:	00 
8010576c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105773:	00 
80105774:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105777:	89 04 24             	mov    %eax,(%esp)
8010577a:	e8 70 f5 ff ff       	call   80104cef <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010577f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105782:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105789:	00 
8010578a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010578e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105791:	89 44 24 04          	mov    %eax,0x4(%esp)
80105795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105798:	89 04 24             	mov    %eax,(%esp)
8010579b:	e8 18 c7 ff ff       	call   80101eb8 <writei>
801057a0:	83 f8 10             	cmp    $0x10,%eax
801057a3:	74 0c                	je     801057b1 <sys_unlink+0x155>
    panic("unlink: writei");
801057a5:	c7 04 24 a4 84 10 80 	movl   $0x801084a4,(%esp)
801057ac:	e8 89 ad ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
801057b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801057b8:	66 83 f8 01          	cmp    $0x1,%ax
801057bc:	75 1c                	jne    801057da <sys_unlink+0x17e>
    dp->nlink--;
801057be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801057c5:	8d 50 ff             	lea    -0x1(%eax),%edx
801057c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057cb:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801057cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d2:	89 04 24             	mov    %eax,(%esp)
801057d5:	e8 b1 be ff ff       	call   8010168b <iupdate>
  }
  iunlockput(dp);
801057da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057dd:	89 04 24             	mov    %eax,(%esp)
801057e0:	e8 e6 c2 ff ff       	call   80101acb <iunlockput>

  ip->nlink--;
801057e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801057ec:	8d 50 ff             	lea    -0x1(%eax),%edx
801057ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f2:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801057f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f9:	89 04 24             	mov    %eax,(%esp)
801057fc:	e8 8a be ff ff       	call   8010168b <iupdate>
  iunlockput(ip);
80105801:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105804:	89 04 24             	mov    %eax,(%esp)
80105807:	e8 bf c2 ff ff       	call   80101acb <iunlockput>

  commit_trans();
8010580c:	e8 09 da ff ff       	call   8010321a <commit_trans>

  return 0;
80105811:	b8 00 00 00 00       	mov    $0x0,%eax
80105816:	eb 15                	jmp    8010582d <sys_unlink+0x1d1>

bad:
  iunlockput(dp);
80105818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010581b:	89 04 24             	mov    %eax,(%esp)
8010581e:	e8 a8 c2 ff ff       	call   80101acb <iunlockput>
  commit_trans();
80105823:	e8 f2 d9 ff ff       	call   8010321a <commit_trans>
  return -1;
80105828:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010582d:	c9                   	leave  
8010582e:	c3                   	ret    

8010582f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010582f:	55                   	push   %ebp
80105830:	89 e5                	mov    %esp,%ebp
80105832:	83 ec 48             	sub    $0x48,%esp
80105835:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105838:	8b 55 10             	mov    0x10(%ebp),%edx
8010583b:	8b 45 14             	mov    0x14(%ebp),%eax
8010583e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105842:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105846:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010584a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010584d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105851:	8b 45 08             	mov    0x8(%ebp),%eax
80105854:	89 04 24             	mov    %eax,(%esp)
80105857:	e8 b8 cb ff ff       	call   80102414 <nameiparent>
8010585c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010585f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105863:	75 0a                	jne    8010586f <create+0x40>
    return 0;
80105865:	b8 00 00 00 00       	mov    $0x0,%eax
8010586a:	e9 7e 01 00 00       	jmp    801059ed <create+0x1be>
  ilock(dp);
8010586f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105872:	89 04 24             	mov    %eax,(%esp)
80105875:	e8 cd bf ff ff       	call   80101847 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010587a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010587d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105881:	8d 45 de             	lea    -0x22(%ebp),%eax
80105884:	89 44 24 04          	mov    %eax,0x4(%esp)
80105888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588b:	89 04 24             	mov    %eax,(%esp)
8010588e:	e8 d6 c7 ff ff       	call   80102069 <dirlookup>
80105893:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105896:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010589a:	74 47                	je     801058e3 <create+0xb4>
    iunlockput(dp);
8010589c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010589f:	89 04 24             	mov    %eax,(%esp)
801058a2:	e8 24 c2 ff ff       	call   80101acb <iunlockput>
    ilock(ip);
801058a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058aa:	89 04 24             	mov    %eax,(%esp)
801058ad:	e8 95 bf ff ff       	call   80101847 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801058b2:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801058b7:	75 15                	jne    801058ce <create+0x9f>
801058b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058bc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801058c0:	66 83 f8 02          	cmp    $0x2,%ax
801058c4:	75 08                	jne    801058ce <create+0x9f>
      return ip;
801058c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c9:	e9 1f 01 00 00       	jmp    801059ed <create+0x1be>
    iunlockput(ip);
801058ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d1:	89 04 24             	mov    %eax,(%esp)
801058d4:	e8 f2 c1 ff ff       	call   80101acb <iunlockput>
    return 0;
801058d9:	b8 00 00 00 00       	mov    $0x0,%eax
801058de:	e9 0a 01 00 00       	jmp    801059ed <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801058e3:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801058e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ea:	8b 00                	mov    (%eax),%eax
801058ec:	89 54 24 04          	mov    %edx,0x4(%esp)
801058f0:	89 04 24             	mov    %eax,(%esp)
801058f3:	e8 b4 bc ff ff       	call   801015ac <ialloc>
801058f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058ff:	75 0c                	jne    8010590d <create+0xde>
    panic("create: ialloc");
80105901:	c7 04 24 b3 84 10 80 	movl   $0x801084b3,(%esp)
80105908:	e8 2d ac ff ff       	call   8010053a <panic>

  ilock(ip);
8010590d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105910:	89 04 24             	mov    %eax,(%esp)
80105913:	e8 2f bf ff ff       	call   80101847 <ilock>
  ip->major = major;
80105918:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010591b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010591f:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105923:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105926:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010592a:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
8010592e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105931:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105937:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593a:	89 04 24             	mov    %eax,(%esp)
8010593d:	e8 49 bd ff ff       	call   8010168b <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105942:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105947:	75 6a                	jne    801059b3 <create+0x184>
    dp->nlink++;  // for ".."
80105949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105950:	8d 50 01             	lea    0x1(%eax),%edx
80105953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105956:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010595a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010595d:	89 04 24             	mov    %eax,(%esp)
80105960:	e8 26 bd ff ff       	call   8010168b <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105965:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105968:	8b 40 04             	mov    0x4(%eax),%eax
8010596b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010596f:	c7 44 24 04 8d 84 10 	movl   $0x8010848d,0x4(%esp)
80105976:	80 
80105977:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597a:	89 04 24             	mov    %eax,(%esp)
8010597d:	e8 b0 c7 ff ff       	call   80102132 <dirlink>
80105982:	85 c0                	test   %eax,%eax
80105984:	78 21                	js     801059a7 <create+0x178>
80105986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105989:	8b 40 04             	mov    0x4(%eax),%eax
8010598c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105990:	c7 44 24 04 8f 84 10 	movl   $0x8010848f,0x4(%esp)
80105997:	80 
80105998:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010599b:	89 04 24             	mov    %eax,(%esp)
8010599e:	e8 8f c7 ff ff       	call   80102132 <dirlink>
801059a3:	85 c0                	test   %eax,%eax
801059a5:	79 0c                	jns    801059b3 <create+0x184>
      panic("create dots");
801059a7:	c7 04 24 c2 84 10 80 	movl   $0x801084c2,(%esp)
801059ae:	e8 87 ab ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801059b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b6:	8b 40 04             	mov    0x4(%eax),%eax
801059b9:	89 44 24 08          	mov    %eax,0x8(%esp)
801059bd:	8d 45 de             	lea    -0x22(%ebp),%eax
801059c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801059c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c7:	89 04 24             	mov    %eax,(%esp)
801059ca:	e8 63 c7 ff ff       	call   80102132 <dirlink>
801059cf:	85 c0                	test   %eax,%eax
801059d1:	79 0c                	jns    801059df <create+0x1b0>
    panic("create: dirlink");
801059d3:	c7 04 24 ce 84 10 80 	movl   $0x801084ce,(%esp)
801059da:	e8 5b ab ff ff       	call   8010053a <panic>

  iunlockput(dp);
801059df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e2:	89 04 24             	mov    %eax,(%esp)
801059e5:	e8 e1 c0 ff ff       	call   80101acb <iunlockput>

  return ip;
801059ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801059ed:	c9                   	leave  
801059ee:	c3                   	ret    

801059ef <sys_open>:

int
sys_open(void)
{
801059ef:	55                   	push   %ebp
801059f0:	89 e5                	mov    %esp,%ebp
801059f2:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801059f5:	8d 45 e8             	lea    -0x18(%ebp),%eax
801059f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801059fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a03:	e8 b9 f6 ff ff       	call   801050c1 <argstr>
80105a08:	85 c0                	test   %eax,%eax
80105a0a:	78 17                	js     80105a23 <sys_open+0x34>
80105a0c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a1a:	e8 12 f6 ff ff       	call   80105031 <argint>
80105a1f:	85 c0                	test   %eax,%eax
80105a21:	79 0a                	jns    80105a2d <sys_open+0x3e>
    return -1;
80105a23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a28:	e9 48 01 00 00       	jmp    80105b75 <sys_open+0x186>
  if(omode & O_CREATE){
80105a2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a30:	25 00 02 00 00       	and    $0x200,%eax
80105a35:	85 c0                	test   %eax,%eax
80105a37:	74 40                	je     80105a79 <sys_open+0x8a>
    begin_trans();
80105a39:	e8 93 d7 ff ff       	call   801031d1 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80105a3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a41:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105a48:	00 
80105a49:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105a50:	00 
80105a51:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105a58:	00 
80105a59:	89 04 24             	mov    %eax,(%esp)
80105a5c:	e8 ce fd ff ff       	call   8010582f <create>
80105a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105a64:	e8 b1 d7 ff ff       	call   8010321a <commit_trans>
    if(ip == 0)
80105a69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a6d:	75 5c                	jne    80105acb <sys_open+0xdc>
      return -1;
80105a6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a74:	e9 fc 00 00 00       	jmp    80105b75 <sys_open+0x186>
  } else {
    if((ip = namei(path)) == 0)
80105a79:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a7c:	89 04 24             	mov    %eax,(%esp)
80105a7f:	e8 6e c9 ff ff       	call   801023f2 <namei>
80105a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a8b:	75 0a                	jne    80105a97 <sys_open+0xa8>
      return -1;
80105a8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a92:	e9 de 00 00 00       	jmp    80105b75 <sys_open+0x186>
    ilock(ip);
80105a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9a:	89 04 24             	mov    %eax,(%esp)
80105a9d:	e8 a5 bd ff ff       	call   80101847 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105aa9:	66 83 f8 01          	cmp    $0x1,%ax
80105aad:	75 1c                	jne    80105acb <sys_open+0xdc>
80105aaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ab2:	85 c0                	test   %eax,%eax
80105ab4:	74 15                	je     80105acb <sys_open+0xdc>
      iunlockput(ip);
80105ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab9:	89 04 24             	mov    %eax,(%esp)
80105abc:	e8 0a c0 ff ff       	call   80101acb <iunlockput>
      return -1;
80105ac1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac6:	e9 aa 00 00 00       	jmp    80105b75 <sys_open+0x186>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105acb:	e8 42 b4 ff ff       	call   80100f12 <filealloc>
80105ad0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ad3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ad7:	74 14                	je     80105aed <sys_open+0xfe>
80105ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105adc:	89 04 24             	mov    %eax,(%esp)
80105adf:	e8 42 f7 ff ff       	call   80105226 <fdalloc>
80105ae4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105ae7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105aeb:	79 23                	jns    80105b10 <sys_open+0x121>
    if(f)
80105aed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105af1:	74 0b                	je     80105afe <sys_open+0x10f>
      fileclose(f);
80105af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af6:	89 04 24             	mov    %eax,(%esp)
80105af9:	e8 bc b4 ff ff       	call   80100fba <fileclose>
    iunlockput(ip);
80105afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b01:	89 04 24             	mov    %eax,(%esp)
80105b04:	e8 c2 bf ff ff       	call   80101acb <iunlockput>
    return -1;
80105b09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0e:	eb 65                	jmp    80105b75 <sys_open+0x186>
  }
  iunlock(ip);
80105b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b13:	89 04 24             	mov    %eax,(%esp)
80105b16:	e8 7a be ff ff       	call   80101995 <iunlock>

  f->type = FD_INODE;
80105b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b1e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b2a:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b30:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105b37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b3a:	83 e0 01             	and    $0x1,%eax
80105b3d:	85 c0                	test   %eax,%eax
80105b3f:	0f 94 c0             	sete   %al
80105b42:	89 c2                	mov    %eax,%edx
80105b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b47:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105b4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b4d:	83 e0 01             	and    $0x1,%eax
80105b50:	85 c0                	test   %eax,%eax
80105b52:	75 0a                	jne    80105b5e <sys_open+0x16f>
80105b54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b57:	83 e0 02             	and    $0x2,%eax
80105b5a:	85 c0                	test   %eax,%eax
80105b5c:	74 07                	je     80105b65 <sys_open+0x176>
80105b5e:	b8 01 00 00 00       	mov    $0x1,%eax
80105b63:	eb 05                	jmp    80105b6a <sys_open+0x17b>
80105b65:	b8 00 00 00 00       	mov    $0x0,%eax
80105b6a:	89 c2                	mov    %eax,%edx
80105b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6f:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105b72:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105b75:	c9                   	leave  
80105b76:	c3                   	ret    

80105b77 <sys_mkdir>:

int
sys_mkdir(void)
{
80105b77:	55                   	push   %ebp
80105b78:	89 e5                	mov    %esp,%ebp
80105b7a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80105b7d:	e8 4f d6 ff ff       	call   801031d1 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105b82:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b85:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b90:	e8 2c f5 ff ff       	call   801050c1 <argstr>
80105b95:	85 c0                	test   %eax,%eax
80105b97:	78 2c                	js     80105bc5 <sys_mkdir+0x4e>
80105b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105ba3:	00 
80105ba4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105bab:	00 
80105bac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105bb3:	00 
80105bb4:	89 04 24             	mov    %eax,(%esp)
80105bb7:	e8 73 fc ff ff       	call   8010582f <create>
80105bbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bbf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bc3:	75 0c                	jne    80105bd1 <sys_mkdir+0x5a>
    commit_trans();
80105bc5:	e8 50 d6 ff ff       	call   8010321a <commit_trans>
    return -1;
80105bca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bcf:	eb 15                	jmp    80105be6 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd4:	89 04 24             	mov    %eax,(%esp)
80105bd7:	e8 ef be ff ff       	call   80101acb <iunlockput>
  commit_trans();
80105bdc:	e8 39 d6 ff ff       	call   8010321a <commit_trans>
  return 0;
80105be1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105be6:	c9                   	leave  
80105be7:	c3                   	ret    

80105be8 <sys_mknod>:

int
sys_mknod(void)
{
80105be8:	55                   	push   %ebp
80105be9:	89 e5                	mov    %esp,%ebp
80105beb:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80105bee:	e8 de d5 ff ff       	call   801031d1 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80105bf3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bfa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c01:	e8 bb f4 ff ff       	call   801050c1 <argstr>
80105c06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c0d:	78 5e                	js     80105c6d <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80105c0f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c12:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c1d:	e8 0f f4 ff ff       	call   80105031 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80105c22:	85 c0                	test   %eax,%eax
80105c24:	78 47                	js     80105c6d <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105c26:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c29:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c2d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105c34:	e8 f8 f3 ff ff       	call   80105031 <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105c39:	85 c0                	test   %eax,%eax
80105c3b:	78 30                	js     80105c6d <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105c3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c40:	0f bf c8             	movswl %ax,%ecx
80105c43:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c46:	0f bf d0             	movswl %ax,%edx
80105c49:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105c4c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105c50:	89 54 24 08          	mov    %edx,0x8(%esp)
80105c54:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105c5b:	00 
80105c5c:	89 04 24             	mov    %eax,(%esp)
80105c5f:	e8 cb fb ff ff       	call   8010582f <create>
80105c64:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c67:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c6b:	75 0c                	jne    80105c79 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80105c6d:	e8 a8 d5 ff ff       	call   8010321a <commit_trans>
    return -1;
80105c72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c77:	eb 15                	jmp    80105c8e <sys_mknod+0xa6>
  }
  iunlockput(ip);
80105c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7c:	89 04 24             	mov    %eax,(%esp)
80105c7f:	e8 47 be ff ff       	call   80101acb <iunlockput>
  commit_trans();
80105c84:	e8 91 d5 ff ff       	call   8010321a <commit_trans>
  return 0;
80105c89:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c8e:	c9                   	leave  
80105c8f:	c3                   	ret    

80105c90 <sys_chdir>:

int
sys_chdir(void)
{
80105c90:	55                   	push   %ebp
80105c91:	89 e5                	mov    %esp,%ebp
80105c93:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80105c96:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c99:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ca4:	e8 18 f4 ff ff       	call   801050c1 <argstr>
80105ca9:	85 c0                	test   %eax,%eax
80105cab:	78 14                	js     80105cc1 <sys_chdir+0x31>
80105cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb0:	89 04 24             	mov    %eax,(%esp)
80105cb3:	e8 3a c7 ff ff       	call   801023f2 <namei>
80105cb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cbf:	75 07                	jne    80105cc8 <sys_chdir+0x38>
    return -1;
80105cc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc6:	eb 57                	jmp    80105d1f <sys_chdir+0x8f>
  ilock(ip);
80105cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ccb:	89 04 24             	mov    %eax,(%esp)
80105cce:	e8 74 bb ff ff       	call   80101847 <ilock>
  if(ip->type != T_DIR){
80105cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105cda:	66 83 f8 01          	cmp    $0x1,%ax
80105cde:	74 12                	je     80105cf2 <sys_chdir+0x62>
    iunlockput(ip);
80105ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce3:	89 04 24             	mov    %eax,(%esp)
80105ce6:	e8 e0 bd ff ff       	call   80101acb <iunlockput>
    return -1;
80105ceb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf0:	eb 2d                	jmp    80105d1f <sys_chdir+0x8f>
  }
  iunlock(ip);
80105cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf5:	89 04 24             	mov    %eax,(%esp)
80105cf8:	e8 98 bc ff ff       	call   80101995 <iunlock>
  iput(proc->cwd);
80105cfd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d03:	8b 40 68             	mov    0x68(%eax),%eax
80105d06:	89 04 24             	mov    %eax,(%esp)
80105d09:	e8 ec bc ff ff       	call   801019fa <iput>
  proc->cwd = ip;
80105d0e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d14:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d17:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105d1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d1f:	c9                   	leave  
80105d20:	c3                   	ret    

80105d21 <sys_exec>:

int
sys_exec(void)
{
80105d21:	55                   	push   %ebp
80105d22:	89 e5                	mov    %esp,%ebp
80105d24:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105d2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d38:	e8 84 f3 ff ff       	call   801050c1 <argstr>
80105d3d:	85 c0                	test   %eax,%eax
80105d3f:	78 1a                	js     80105d5b <sys_exec+0x3a>
80105d41:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105d47:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d52:	e8 da f2 ff ff       	call   80105031 <argint>
80105d57:	85 c0                	test   %eax,%eax
80105d59:	79 0a                	jns    80105d65 <sys_exec+0x44>
    return -1;
80105d5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d60:	e9 c8 00 00 00       	jmp    80105e2d <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
80105d65:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80105d6c:	00 
80105d6d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d74:	00 
80105d75:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105d7b:	89 04 24             	mov    %eax,(%esp)
80105d7e:	e8 6c ef ff ff       	call   80104cef <memset>
  for(i=0;; i++){
80105d83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d8d:	83 f8 1f             	cmp    $0x1f,%eax
80105d90:	76 0a                	jbe    80105d9c <sys_exec+0x7b>
      return -1;
80105d92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d97:	e9 91 00 00 00       	jmp    80105e2d <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9f:	c1 e0 02             	shl    $0x2,%eax
80105da2:	89 c2                	mov    %eax,%edx
80105da4:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105daa:	01 c2                	add    %eax,%edx
80105dac:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105db2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105db6:	89 14 24             	mov    %edx,(%esp)
80105db9:	e8 d7 f1 ff ff       	call   80104f95 <fetchint>
80105dbe:	85 c0                	test   %eax,%eax
80105dc0:	79 07                	jns    80105dc9 <sys_exec+0xa8>
      return -1;
80105dc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc7:	eb 64                	jmp    80105e2d <sys_exec+0x10c>
    if(uarg == 0){
80105dc9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105dcf:	85 c0                	test   %eax,%eax
80105dd1:	75 26                	jne    80105df9 <sys_exec+0xd8>
      argv[i] = 0;
80105dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd6:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105ddd:	00 00 00 00 
      break;
80105de1:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de5:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105deb:	89 54 24 04          	mov    %edx,0x4(%esp)
80105def:	89 04 24             	mov    %eax,(%esp)
80105df2:	e8 f8 ac ff ff       	call   80100aef <exec>
80105df7:	eb 34                	jmp    80105e2d <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105df9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105dff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e02:	c1 e2 02             	shl    $0x2,%edx
80105e05:	01 c2                	add    %eax,%edx
80105e07:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e0d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e11:	89 04 24             	mov    %eax,(%esp)
80105e14:	e8 b6 f1 ff ff       	call   80104fcf <fetchstr>
80105e19:	85 c0                	test   %eax,%eax
80105e1b:	79 07                	jns    80105e24 <sys_exec+0x103>
      return -1;
80105e1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e22:	eb 09                	jmp    80105e2d <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80105e24:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80105e28:	e9 5d ff ff ff       	jmp    80105d8a <sys_exec+0x69>
  return exec(path, argv);
}
80105e2d:	c9                   	leave  
80105e2e:	c3                   	ret    

80105e2f <sys_pipe>:

int
sys_pipe(void)
{
80105e2f:	55                   	push   %ebp
80105e30:	89 e5                	mov    %esp,%ebp
80105e32:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105e35:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80105e3c:	00 
80105e3d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e40:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e4b:	e8 0f f2 ff ff       	call   8010505f <argptr>
80105e50:	85 c0                	test   %eax,%eax
80105e52:	79 0a                	jns    80105e5e <sys_pipe+0x2f>
    return -1;
80105e54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e59:	e9 9b 00 00 00       	jmp    80105ef9 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80105e5e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e61:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e65:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e68:	89 04 24             	mov    %eax,(%esp)
80105e6b:	e8 4b dd ff ff       	call   80103bbb <pipealloc>
80105e70:	85 c0                	test   %eax,%eax
80105e72:	79 07                	jns    80105e7b <sys_pipe+0x4c>
    return -1;
80105e74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e79:	eb 7e                	jmp    80105ef9 <sys_pipe+0xca>
  fd0 = -1;
80105e7b:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105e82:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e85:	89 04 24             	mov    %eax,(%esp)
80105e88:	e8 99 f3 ff ff       	call   80105226 <fdalloc>
80105e8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e94:	78 14                	js     80105eaa <sys_pipe+0x7b>
80105e96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e99:	89 04 24             	mov    %eax,(%esp)
80105e9c:	e8 85 f3 ff ff       	call   80105226 <fdalloc>
80105ea1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ea4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ea8:	79 37                	jns    80105ee1 <sys_pipe+0xb2>
    if(fd0 >= 0)
80105eaa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eae:	78 14                	js     80105ec4 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80105eb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105eb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105eb9:	83 c2 08             	add    $0x8,%edx
80105ebc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105ec3:	00 
    fileclose(rf);
80105ec4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ec7:	89 04 24             	mov    %eax,(%esp)
80105eca:	e8 eb b0 ff ff       	call   80100fba <fileclose>
    fileclose(wf);
80105ecf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ed2:	89 04 24             	mov    %eax,(%esp)
80105ed5:	e8 e0 b0 ff ff       	call   80100fba <fileclose>
    return -1;
80105eda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105edf:	eb 18                	jmp    80105ef9 <sys_pipe+0xca>
  }
  fd[0] = fd0;
80105ee1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ee4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ee7:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105ee9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105eec:	8d 50 04             	lea    0x4(%eax),%edx
80105eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef2:	89 02                	mov    %eax,(%edx)
  return 0;
80105ef4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ef9:	c9                   	leave  
80105efa:	c3                   	ret    

80105efb <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105efb:	55                   	push   %ebp
80105efc:	89 e5                	mov    %esp,%ebp
80105efe:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105f01:	e8 87 e3 ff ff       	call   8010428d <fork>
}
80105f06:	c9                   	leave  
80105f07:	c3                   	ret    

80105f08 <sys_exit>:

int
sys_exit(void)
{
80105f08:	55                   	push   %ebp
80105f09:	89 e5                	mov    %esp,%ebp
80105f0b:	83 ec 08             	sub    $0x8,%esp
  exit();
80105f0e:	e8 dd e4 ff ff       	call   801043f0 <exit>
  return 0;  // not reached
80105f13:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f18:	c9                   	leave  
80105f19:	c3                   	ret    

80105f1a <sys_wait>:

int
sys_wait(void)
{
80105f1a:	55                   	push   %ebp
80105f1b:	89 e5                	mov    %esp,%ebp
80105f1d:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105f20:	e8 e6 e5 ff ff       	call   8010450b <wait>
}
80105f25:	c9                   	leave  
80105f26:	c3                   	ret    

80105f27 <sys_kill>:

int
sys_kill(void)
{
80105f27:	55                   	push   %ebp
80105f28:	89 e5                	mov    %esp,%ebp
80105f2a:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105f2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f30:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f3b:	e8 f1 f0 ff ff       	call   80105031 <argint>
80105f40:	85 c0                	test   %eax,%eax
80105f42:	79 07                	jns    80105f4b <sys_kill+0x24>
    return -1;
80105f44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f49:	eb 0b                	jmp    80105f56 <sys_kill+0x2f>
  return kill(pid);
80105f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4e:	89 04 24             	mov    %eax,(%esp)
80105f51:	e8 79 e9 ff ff       	call   801048cf <kill>
}
80105f56:	c9                   	leave  
80105f57:	c3                   	ret    

80105f58 <sys_getpid>:

int
sys_getpid(void)
{
80105f58:	55                   	push   %ebp
80105f59:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80105f5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f61:	8b 40 10             	mov    0x10(%eax),%eax
}
80105f64:	5d                   	pop    %ebp
80105f65:	c3                   	ret    

80105f66 <sys_sbrk>:

int
sys_sbrk(void)
{
80105f66:	55                   	push   %ebp
80105f67:	89 e5                	mov    %esp,%ebp
80105f69:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105f6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f7a:	e8 b2 f0 ff ff       	call   80105031 <argint>
80105f7f:	85 c0                	test   %eax,%eax
80105f81:	79 07                	jns    80105f8a <sys_sbrk+0x24>
    return -1;
80105f83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f88:	eb 24                	jmp    80105fae <sys_sbrk+0x48>
  addr = proc->sz;
80105f8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f90:	8b 00                	mov    (%eax),%eax
80105f92:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f98:	89 04 24             	mov    %eax,(%esp)
80105f9b:	e8 48 e2 ff ff       	call   801041e8 <growproc>
80105fa0:	85 c0                	test   %eax,%eax
80105fa2:	79 07                	jns    80105fab <sys_sbrk+0x45>
    return -1;
80105fa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa9:	eb 03                	jmp    80105fae <sys_sbrk+0x48>
  return addr;
80105fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105fae:	c9                   	leave  
80105faf:	c3                   	ret    

80105fb0 <sys_sleep>:

int
sys_sleep(void)
{
80105fb0:	55                   	push   %ebp
80105fb1:	89 e5                	mov    %esp,%ebp
80105fb3:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80105fb6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fc4:	e8 68 f0 ff ff       	call   80105031 <argint>
80105fc9:	85 c0                	test   %eax,%eax
80105fcb:	79 07                	jns    80105fd4 <sys_sleep+0x24>
    return -1;
80105fcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd2:	eb 6c                	jmp    80106040 <sys_sleep+0x90>
  acquire(&tickslock);
80105fd4:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80105fdb:	e8 bb ea ff ff       	call   80104a9b <acquire>
  ticks0 = ticks;
80105fe0:	a1 a0 44 11 80       	mov    0x801144a0,%eax
80105fe5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105fe8:	eb 34                	jmp    8010601e <sys_sleep+0x6e>
    if(proc->killed){
80105fea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ff0:	8b 40 24             	mov    0x24(%eax),%eax
80105ff3:	85 c0                	test   %eax,%eax
80105ff5:	74 13                	je     8010600a <sys_sleep+0x5a>
      release(&tickslock);
80105ff7:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80105ffe:	e8 fa ea ff ff       	call   80104afd <release>
      return -1;
80106003:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106008:	eb 36                	jmp    80106040 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010600a:	c7 44 24 04 60 3c 11 	movl   $0x80113c60,0x4(%esp)
80106011:	80 
80106012:	c7 04 24 a0 44 11 80 	movl   $0x801144a0,(%esp)
80106019:	e8 aa e7 ff ff       	call   801047c8 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010601e:	a1 a0 44 11 80       	mov    0x801144a0,%eax
80106023:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106026:	89 c2                	mov    %eax,%edx
80106028:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010602b:	39 c2                	cmp    %eax,%edx
8010602d:	72 bb                	jb     80105fea <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010602f:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80106036:	e8 c2 ea ff ff       	call   80104afd <release>
  return 0;
8010603b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106040:	c9                   	leave  
80106041:	c3                   	ret    

80106042 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106042:	55                   	push   %ebp
80106043:	89 e5                	mov    %esp,%ebp
80106045:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106048:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
8010604f:	e8 47 ea ff ff       	call   80104a9b <acquire>
  xticks = ticks;
80106054:	a1 a0 44 11 80       	mov    0x801144a0,%eax
80106059:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010605c:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80106063:	e8 95 ea ff ff       	call   80104afd <release>
  return xticks;
80106068:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010606b:	c9                   	leave  
8010606c:	c3                   	ret    

8010606d <sys_getcount>:

// return how many times the specified syscall has occurred
// since process start.
int
sys_getcount(void)
{
8010606d:	55                   	push   %ebp
8010606e:	89 e5                	mov    %esp,%ebp
80106070:	83 ec 28             	sub    $0x28,%esp
  int scid;

  if(argint(0, &scid) < 0)
80106073:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106076:	89 44 24 04          	mov    %eax,0x4(%esp)
8010607a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106081:	e8 ab ef ff ff       	call   80105031 <argint>
80106086:	85 c0                	test   %eax,%eax
80106088:	79 07                	jns    80106091 <sys_getcount+0x24>
    return -1;
8010608a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010608f:	eb 13                	jmp    801060a4 <sys_getcount+0x37>
  return proc->sccount[scid-1];
80106091:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106097:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010609a:	83 ea 01             	sub    $0x1,%edx
8010609d:	83 c2 1c             	add    $0x1c,%edx
801060a0:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
}
801060a4:	c9                   	leave  
801060a5:	c3                   	ret    

801060a6 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801060a6:	55                   	push   %ebp
801060a7:	89 e5                	mov    %esp,%ebp
801060a9:	83 ec 08             	sub    $0x8,%esp
801060ac:	8b 55 08             	mov    0x8(%ebp),%edx
801060af:	8b 45 0c             	mov    0xc(%ebp),%eax
801060b2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801060b6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801060b9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801060bd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801060c1:	ee                   	out    %al,(%dx)
}
801060c2:	c9                   	leave  
801060c3:	c3                   	ret    

801060c4 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801060c4:	55                   	push   %ebp
801060c5:	89 e5                	mov    %esp,%ebp
801060c7:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801060ca:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801060d1:	00 
801060d2:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801060d9:	e8 c8 ff ff ff       	call   801060a6 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801060de:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801060e5:	00 
801060e6:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801060ed:	e8 b4 ff ff ff       	call   801060a6 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801060f2:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801060f9:	00 
801060fa:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106101:	e8 a0 ff ff ff       	call   801060a6 <outb>
  picenable(IRQ_TIMER);
80106106:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010610d:	e8 3c d9 ff ff       	call   80103a4e <picenable>
}
80106112:	c9                   	leave  
80106113:	c3                   	ret    

80106114 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106114:	1e                   	push   %ds
  pushl %es
80106115:	06                   	push   %es
  pushl %fs
80106116:	0f a0                	push   %fs
  pushl %gs
80106118:	0f a8                	push   %gs
  pushal
8010611a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010611b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010611f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106121:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106123:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106127:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106129:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010612b:	54                   	push   %esp
  call trap
8010612c:	e8 d8 01 00 00       	call   80106309 <trap>
  addl $4, %esp
80106131:	83 c4 04             	add    $0x4,%esp

80106134 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106134:	61                   	popa   
  popl %gs
80106135:	0f a9                	pop    %gs
  popl %fs
80106137:	0f a1                	pop    %fs
  popl %es
80106139:	07                   	pop    %es
  popl %ds
8010613a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010613b:	83 c4 08             	add    $0x8,%esp
  iret
8010613e:	cf                   	iret   

8010613f <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010613f:	55                   	push   %ebp
80106140:	89 e5                	mov    %esp,%ebp
80106142:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106145:	8b 45 0c             	mov    0xc(%ebp),%eax
80106148:	83 e8 01             	sub    $0x1,%eax
8010614b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010614f:	8b 45 08             	mov    0x8(%ebp),%eax
80106152:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106156:	8b 45 08             	mov    0x8(%ebp),%eax
80106159:	c1 e8 10             	shr    $0x10,%eax
8010615c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106160:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106163:	0f 01 18             	lidtl  (%eax)
}
80106166:	c9                   	leave  
80106167:	c3                   	ret    

80106168 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106168:	55                   	push   %ebp
80106169:	89 e5                	mov    %esp,%ebp
8010616b:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010616e:	0f 20 d0             	mov    %cr2,%eax
80106171:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106174:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106177:	c9                   	leave  
80106178:	c3                   	ret    

80106179 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106179:	55                   	push   %ebp
8010617a:	89 e5                	mov    %esp,%ebp
8010617c:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010617f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106186:	e9 c3 00 00 00       	jmp    8010624e <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010618b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010618e:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
80106195:	89 c2                	mov    %eax,%edx
80106197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010619a:	66 89 14 c5 a0 3c 11 	mov    %dx,-0x7feec360(,%eax,8)
801061a1:	80 
801061a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a5:	66 c7 04 c5 a2 3c 11 	movw   $0x8,-0x7feec35e(,%eax,8)
801061ac:	80 08 00 
801061af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b2:	0f b6 14 c5 a4 3c 11 	movzbl -0x7feec35c(,%eax,8),%edx
801061b9:	80 
801061ba:	83 e2 e0             	and    $0xffffffe0,%edx
801061bd:	88 14 c5 a4 3c 11 80 	mov    %dl,-0x7feec35c(,%eax,8)
801061c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c7:	0f b6 14 c5 a4 3c 11 	movzbl -0x7feec35c(,%eax,8),%edx
801061ce:	80 
801061cf:	83 e2 1f             	and    $0x1f,%edx
801061d2:	88 14 c5 a4 3c 11 80 	mov    %dl,-0x7feec35c(,%eax,8)
801061d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061dc:	0f b6 14 c5 a5 3c 11 	movzbl -0x7feec35b(,%eax,8),%edx
801061e3:	80 
801061e4:	83 e2 f0             	and    $0xfffffff0,%edx
801061e7:	83 ca 0e             	or     $0xe,%edx
801061ea:	88 14 c5 a5 3c 11 80 	mov    %dl,-0x7feec35b(,%eax,8)
801061f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f4:	0f b6 14 c5 a5 3c 11 	movzbl -0x7feec35b(,%eax,8),%edx
801061fb:	80 
801061fc:	83 e2 ef             	and    $0xffffffef,%edx
801061ff:	88 14 c5 a5 3c 11 80 	mov    %dl,-0x7feec35b(,%eax,8)
80106206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106209:	0f b6 14 c5 a5 3c 11 	movzbl -0x7feec35b(,%eax,8),%edx
80106210:	80 
80106211:	83 e2 9f             	and    $0xffffff9f,%edx
80106214:	88 14 c5 a5 3c 11 80 	mov    %dl,-0x7feec35b(,%eax,8)
8010621b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621e:	0f b6 14 c5 a5 3c 11 	movzbl -0x7feec35b(,%eax,8),%edx
80106225:	80 
80106226:	83 ca 80             	or     $0xffffff80,%edx
80106229:	88 14 c5 a5 3c 11 80 	mov    %dl,-0x7feec35b(,%eax,8)
80106230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106233:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
8010623a:	c1 e8 10             	shr    $0x10,%eax
8010623d:	89 c2                	mov    %eax,%edx
8010623f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106242:	66 89 14 c5 a6 3c 11 	mov    %dx,-0x7feec35a(,%eax,8)
80106249:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010624a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010624e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106255:	0f 8e 30 ff ff ff    	jle    8010618b <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010625b:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
80106260:	66 a3 a0 3e 11 80    	mov    %ax,0x80113ea0
80106266:	66 c7 05 a2 3e 11 80 	movw   $0x8,0x80113ea2
8010626d:	08 00 
8010626f:	0f b6 05 a4 3e 11 80 	movzbl 0x80113ea4,%eax
80106276:	83 e0 e0             	and    $0xffffffe0,%eax
80106279:	a2 a4 3e 11 80       	mov    %al,0x80113ea4
8010627e:	0f b6 05 a4 3e 11 80 	movzbl 0x80113ea4,%eax
80106285:	83 e0 1f             	and    $0x1f,%eax
80106288:	a2 a4 3e 11 80       	mov    %al,0x80113ea4
8010628d:	0f b6 05 a5 3e 11 80 	movzbl 0x80113ea5,%eax
80106294:	83 c8 0f             	or     $0xf,%eax
80106297:	a2 a5 3e 11 80       	mov    %al,0x80113ea5
8010629c:	0f b6 05 a5 3e 11 80 	movzbl 0x80113ea5,%eax
801062a3:	83 e0 ef             	and    $0xffffffef,%eax
801062a6:	a2 a5 3e 11 80       	mov    %al,0x80113ea5
801062ab:	0f b6 05 a5 3e 11 80 	movzbl 0x80113ea5,%eax
801062b2:	83 c8 60             	or     $0x60,%eax
801062b5:	a2 a5 3e 11 80       	mov    %al,0x80113ea5
801062ba:	0f b6 05 a5 3e 11 80 	movzbl 0x80113ea5,%eax
801062c1:	83 c8 80             	or     $0xffffff80,%eax
801062c4:	a2 a5 3e 11 80       	mov    %al,0x80113ea5
801062c9:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
801062ce:	c1 e8 10             	shr    $0x10,%eax
801062d1:	66 a3 a6 3e 11 80    	mov    %ax,0x80113ea6
  
  initlock(&tickslock, "time");
801062d7:	c7 44 24 04 e0 84 10 	movl   $0x801084e0,0x4(%esp)
801062de:	80 
801062df:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
801062e6:	e8 8f e7 ff ff       	call   80104a7a <initlock>
}
801062eb:	c9                   	leave  
801062ec:	c3                   	ret    

801062ed <idtinit>:

void
idtinit(void)
{
801062ed:	55                   	push   %ebp
801062ee:	89 e5                	mov    %esp,%ebp
801062f0:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801062f3:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801062fa:	00 
801062fb:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80106302:	e8 38 fe ff ff       	call   8010613f <lidt>
}
80106307:	c9                   	leave  
80106308:	c3                   	ret    

80106309 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106309:	55                   	push   %ebp
8010630a:	89 e5                	mov    %esp,%ebp
8010630c:	57                   	push   %edi
8010630d:	56                   	push   %esi
8010630e:	53                   	push   %ebx
8010630f:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106312:	8b 45 08             	mov    0x8(%ebp),%eax
80106315:	8b 40 30             	mov    0x30(%eax),%eax
80106318:	83 f8 40             	cmp    $0x40,%eax
8010631b:	75 3f                	jne    8010635c <trap+0x53>
    if(proc->killed)
8010631d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106323:	8b 40 24             	mov    0x24(%eax),%eax
80106326:	85 c0                	test   %eax,%eax
80106328:	74 05                	je     8010632f <trap+0x26>
      exit();
8010632a:	e8 c1 e0 ff ff       	call   801043f0 <exit>
    proc->tf = tf;
8010632f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106335:	8b 55 08             	mov    0x8(%ebp),%edx
80106338:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010633b:	e8 b8 ed ff ff       	call   801050f8 <syscall>
    if(proc->killed)
80106340:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106346:	8b 40 24             	mov    0x24(%eax),%eax
80106349:	85 c0                	test   %eax,%eax
8010634b:	74 0a                	je     80106357 <trap+0x4e>
      exit();
8010634d:	e8 9e e0 ff ff       	call   801043f0 <exit>
    return;
80106352:	e9 2d 02 00 00       	jmp    80106584 <trap+0x27b>
80106357:	e9 28 02 00 00       	jmp    80106584 <trap+0x27b>
  }

  switch(tf->trapno){
8010635c:	8b 45 08             	mov    0x8(%ebp),%eax
8010635f:	8b 40 30             	mov    0x30(%eax),%eax
80106362:	83 e8 20             	sub    $0x20,%eax
80106365:	83 f8 1f             	cmp    $0x1f,%eax
80106368:	0f 87 bc 00 00 00    	ja     8010642a <trap+0x121>
8010636e:	8b 04 85 88 85 10 80 	mov    -0x7fef7a78(,%eax,4),%eax
80106375:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106377:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010637d:	0f b6 00             	movzbl (%eax),%eax
80106380:	84 c0                	test   %al,%al
80106382:	75 31                	jne    801063b5 <trap+0xac>
      acquire(&tickslock);
80106384:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
8010638b:	e8 0b e7 ff ff       	call   80104a9b <acquire>
      ticks++;
80106390:	a1 a0 44 11 80       	mov    0x801144a0,%eax
80106395:	83 c0 01             	add    $0x1,%eax
80106398:	a3 a0 44 11 80       	mov    %eax,0x801144a0
      wakeup(&ticks);
8010639d:	c7 04 24 a0 44 11 80 	movl   $0x801144a0,(%esp)
801063a4:	e8 fb e4 ff ff       	call   801048a4 <wakeup>
      release(&tickslock);
801063a9:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
801063b0:	e8 48 e7 ff ff       	call   80104afd <release>
    }
    lapiceoi();
801063b5:	e8 e5 ca ff ff       	call   80102e9f <lapiceoi>
    break;
801063ba:	e9 41 01 00 00       	jmp    80106500 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801063bf:	e8 06 c3 ff ff       	call   801026ca <ideintr>
    lapiceoi();
801063c4:	e8 d6 ca ff ff       	call   80102e9f <lapiceoi>
    break;
801063c9:	e9 32 01 00 00       	jmp    80106500 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801063ce:	e8 b8 c8 ff ff       	call   80102c8b <kbdintr>
    lapiceoi();
801063d3:	e8 c7 ca ff ff       	call   80102e9f <lapiceoi>
    break;
801063d8:	e9 23 01 00 00       	jmp    80106500 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801063dd:	e8 97 03 00 00       	call   80106779 <uartintr>
    lapiceoi();
801063e2:	e8 b8 ca ff ff       	call   80102e9f <lapiceoi>
    break;
801063e7:	e9 14 01 00 00       	jmp    80106500 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801063ec:	8b 45 08             	mov    0x8(%ebp),%eax
801063ef:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801063f2:	8b 45 08             	mov    0x8(%ebp),%eax
801063f5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801063f9:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801063fc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106402:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106405:	0f b6 c0             	movzbl %al,%eax
80106408:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010640c:	89 54 24 08          	mov    %edx,0x8(%esp)
80106410:	89 44 24 04          	mov    %eax,0x4(%esp)
80106414:	c7 04 24 e8 84 10 80 	movl   $0x801084e8,(%esp)
8010641b:	e8 80 9f ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106420:	e8 7a ca ff ff       	call   80102e9f <lapiceoi>
    break;
80106425:	e9 d6 00 00 00       	jmp    80106500 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010642a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106430:	85 c0                	test   %eax,%eax
80106432:	74 11                	je     80106445 <trap+0x13c>
80106434:	8b 45 08             	mov    0x8(%ebp),%eax
80106437:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010643b:	0f b7 c0             	movzwl %ax,%eax
8010643e:	83 e0 03             	and    $0x3,%eax
80106441:	85 c0                	test   %eax,%eax
80106443:	75 46                	jne    8010648b <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106445:	e8 1e fd ff ff       	call   80106168 <rcr2>
8010644a:	8b 55 08             	mov    0x8(%ebp),%edx
8010644d:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106450:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106457:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010645a:	0f b6 ca             	movzbl %dl,%ecx
8010645d:	8b 55 08             	mov    0x8(%ebp),%edx
80106460:	8b 52 30             	mov    0x30(%edx),%edx
80106463:	89 44 24 10          	mov    %eax,0x10(%esp)
80106467:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
8010646b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010646f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106473:	c7 04 24 0c 85 10 80 	movl   $0x8010850c,(%esp)
8010647a:	e8 21 9f ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010647f:	c7 04 24 3e 85 10 80 	movl   $0x8010853e,(%esp)
80106486:	e8 af a0 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010648b:	e8 d8 fc ff ff       	call   80106168 <rcr2>
80106490:	89 c2                	mov    %eax,%edx
80106492:	8b 45 08             	mov    0x8(%ebp),%eax
80106495:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106498:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010649e:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801064a1:	0f b6 f0             	movzbl %al,%esi
801064a4:	8b 45 08             	mov    0x8(%ebp),%eax
801064a7:	8b 58 34             	mov    0x34(%eax),%ebx
801064aa:	8b 45 08             	mov    0x8(%ebp),%eax
801064ad:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801064b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064b6:	83 c0 6c             	add    $0x6c,%eax
801064b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801064bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801064c2:	8b 40 10             	mov    0x10(%eax),%eax
801064c5:	89 54 24 1c          	mov    %edx,0x1c(%esp)
801064c9:	89 7c 24 18          	mov    %edi,0x18(%esp)
801064cd:	89 74 24 14          	mov    %esi,0x14(%esp)
801064d1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801064d5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801064d9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
801064dc:	89 74 24 08          	mov    %esi,0x8(%esp)
801064e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801064e4:	c7 04 24 44 85 10 80 	movl   $0x80108544,(%esp)
801064eb:	e8 b0 9e ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801064f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064f6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801064fd:	eb 01                	jmp    80106500 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801064ff:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106500:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106506:	85 c0                	test   %eax,%eax
80106508:	74 24                	je     8010652e <trap+0x225>
8010650a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106510:	8b 40 24             	mov    0x24(%eax),%eax
80106513:	85 c0                	test   %eax,%eax
80106515:	74 17                	je     8010652e <trap+0x225>
80106517:	8b 45 08             	mov    0x8(%ebp),%eax
8010651a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010651e:	0f b7 c0             	movzwl %ax,%eax
80106521:	83 e0 03             	and    $0x3,%eax
80106524:	83 f8 03             	cmp    $0x3,%eax
80106527:	75 05                	jne    8010652e <trap+0x225>
    exit();
80106529:	e8 c2 de ff ff       	call   801043f0 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
8010652e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106534:	85 c0                	test   %eax,%eax
80106536:	74 1e                	je     80106556 <trap+0x24d>
80106538:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010653e:	8b 40 0c             	mov    0xc(%eax),%eax
80106541:	83 f8 04             	cmp    $0x4,%eax
80106544:	75 10                	jne    80106556 <trap+0x24d>
80106546:	8b 45 08             	mov    0x8(%ebp),%eax
80106549:	8b 40 30             	mov    0x30(%eax),%eax
8010654c:	83 f8 20             	cmp    $0x20,%eax
8010654f:	75 05                	jne    80106556 <trap+0x24d>
    yield();
80106551:	e8 14 e2 ff ff       	call   8010476a <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106556:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010655c:	85 c0                	test   %eax,%eax
8010655e:	74 24                	je     80106584 <trap+0x27b>
80106560:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106566:	8b 40 24             	mov    0x24(%eax),%eax
80106569:	85 c0                	test   %eax,%eax
8010656b:	74 17                	je     80106584 <trap+0x27b>
8010656d:	8b 45 08             	mov    0x8(%ebp),%eax
80106570:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106574:	0f b7 c0             	movzwl %ax,%eax
80106577:	83 e0 03             	and    $0x3,%eax
8010657a:	83 f8 03             	cmp    $0x3,%eax
8010657d:	75 05                	jne    80106584 <trap+0x27b>
    exit();
8010657f:	e8 6c de ff ff       	call   801043f0 <exit>
}
80106584:	83 c4 3c             	add    $0x3c,%esp
80106587:	5b                   	pop    %ebx
80106588:	5e                   	pop    %esi
80106589:	5f                   	pop    %edi
8010658a:	5d                   	pop    %ebp
8010658b:	c3                   	ret    

8010658c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010658c:	55                   	push   %ebp
8010658d:	89 e5                	mov    %esp,%ebp
8010658f:	83 ec 14             	sub    $0x14,%esp
80106592:	8b 45 08             	mov    0x8(%ebp),%eax
80106595:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106599:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010659d:	89 c2                	mov    %eax,%edx
8010659f:	ec                   	in     (%dx),%al
801065a0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801065a3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801065a7:	c9                   	leave  
801065a8:	c3                   	ret    

801065a9 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801065a9:	55                   	push   %ebp
801065aa:	89 e5                	mov    %esp,%ebp
801065ac:	83 ec 08             	sub    $0x8,%esp
801065af:	8b 55 08             	mov    0x8(%ebp),%edx
801065b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801065b5:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801065b9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801065bc:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801065c0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801065c4:	ee                   	out    %al,(%dx)
}
801065c5:	c9                   	leave  
801065c6:	c3                   	ret    

801065c7 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801065c7:	55                   	push   %ebp
801065c8:	89 e5                	mov    %esp,%ebp
801065ca:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801065cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801065d4:	00 
801065d5:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801065dc:	e8 c8 ff ff ff       	call   801065a9 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801065e1:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801065e8:	00 
801065e9:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801065f0:	e8 b4 ff ff ff       	call   801065a9 <outb>
  outb(COM1+0, 115200/9600);
801065f5:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801065fc:	00 
801065fd:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106604:	e8 a0 ff ff ff       	call   801065a9 <outb>
  outb(COM1+1, 0);
80106609:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106610:	00 
80106611:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106618:	e8 8c ff ff ff       	call   801065a9 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010661d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106624:	00 
80106625:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010662c:	e8 78 ff ff ff       	call   801065a9 <outb>
  outb(COM1+4, 0);
80106631:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106638:	00 
80106639:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106640:	e8 64 ff ff ff       	call   801065a9 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106645:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010664c:	00 
8010664d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106654:	e8 50 ff ff ff       	call   801065a9 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106659:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106660:	e8 27 ff ff ff       	call   8010658c <inb>
80106665:	3c ff                	cmp    $0xff,%al
80106667:	75 02                	jne    8010666b <uartinit+0xa4>
    return;
80106669:	eb 6a                	jmp    801066d5 <uartinit+0x10e>
  uart = 1;
8010666b:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106672:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106675:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010667c:	e8 0b ff ff ff       	call   8010658c <inb>
  inb(COM1+0);
80106681:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106688:	e8 ff fe ff ff       	call   8010658c <inb>
  picenable(IRQ_COM1);
8010668d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106694:	e8 b5 d3 ff ff       	call   80103a4e <picenable>
  ioapicenable(IRQ_COM1, 0);
80106699:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801066a0:	00 
801066a1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801066a8:	e8 9c c2 ff ff       	call   80102949 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801066ad:	c7 45 f4 08 86 10 80 	movl   $0x80108608,-0xc(%ebp)
801066b4:	eb 15                	jmp    801066cb <uartinit+0x104>
    uartputc(*p);
801066b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b9:	0f b6 00             	movzbl (%eax),%eax
801066bc:	0f be c0             	movsbl %al,%eax
801066bf:	89 04 24             	mov    %eax,(%esp)
801066c2:	e8 10 00 00 00       	call   801066d7 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801066c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801066cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ce:	0f b6 00             	movzbl (%eax),%eax
801066d1:	84 c0                	test   %al,%al
801066d3:	75 e1                	jne    801066b6 <uartinit+0xef>
    uartputc(*p);
}
801066d5:	c9                   	leave  
801066d6:	c3                   	ret    

801066d7 <uartputc>:

void
uartputc(int c)
{
801066d7:	55                   	push   %ebp
801066d8:	89 e5                	mov    %esp,%ebp
801066da:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801066dd:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
801066e2:	85 c0                	test   %eax,%eax
801066e4:	75 02                	jne    801066e8 <uartputc+0x11>
    return;
801066e6:	eb 4b                	jmp    80106733 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801066e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801066ef:	eb 10                	jmp    80106701 <uartputc+0x2a>
    microdelay(10);
801066f1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801066f8:	e8 c7 c7 ff ff       	call   80102ec4 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801066fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106701:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106705:	7f 16                	jg     8010671d <uartputc+0x46>
80106707:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010670e:	e8 79 fe ff ff       	call   8010658c <inb>
80106713:	0f b6 c0             	movzbl %al,%eax
80106716:	83 e0 20             	and    $0x20,%eax
80106719:	85 c0                	test   %eax,%eax
8010671b:	74 d4                	je     801066f1 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
8010671d:	8b 45 08             	mov    0x8(%ebp),%eax
80106720:	0f b6 c0             	movzbl %al,%eax
80106723:	89 44 24 04          	mov    %eax,0x4(%esp)
80106727:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010672e:	e8 76 fe ff ff       	call   801065a9 <outb>
}
80106733:	c9                   	leave  
80106734:	c3                   	ret    

80106735 <uartgetc>:

static int
uartgetc(void)
{
80106735:	55                   	push   %ebp
80106736:	89 e5                	mov    %esp,%ebp
80106738:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010673b:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106740:	85 c0                	test   %eax,%eax
80106742:	75 07                	jne    8010674b <uartgetc+0x16>
    return -1;
80106744:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106749:	eb 2c                	jmp    80106777 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010674b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106752:	e8 35 fe ff ff       	call   8010658c <inb>
80106757:	0f b6 c0             	movzbl %al,%eax
8010675a:	83 e0 01             	and    $0x1,%eax
8010675d:	85 c0                	test   %eax,%eax
8010675f:	75 07                	jne    80106768 <uartgetc+0x33>
    return -1;
80106761:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106766:	eb 0f                	jmp    80106777 <uartgetc+0x42>
  return inb(COM1+0);
80106768:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010676f:	e8 18 fe ff ff       	call   8010658c <inb>
80106774:	0f b6 c0             	movzbl %al,%eax
}
80106777:	c9                   	leave  
80106778:	c3                   	ret    

80106779 <uartintr>:

void
uartintr(void)
{
80106779:	55                   	push   %ebp
8010677a:	89 e5                	mov    %esp,%ebp
8010677c:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
8010677f:	c7 04 24 35 67 10 80 	movl   $0x80106735,(%esp)
80106786:	e8 22 a0 ff ff       	call   801007ad <consoleintr>
}
8010678b:	c9                   	leave  
8010678c:	c3                   	ret    

8010678d <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010678d:	6a 00                	push   $0x0
  pushl $0
8010678f:	6a 00                	push   $0x0
  jmp alltraps
80106791:	e9 7e f9 ff ff       	jmp    80106114 <alltraps>

80106796 <vector1>:
.globl vector1
vector1:
  pushl $0
80106796:	6a 00                	push   $0x0
  pushl $1
80106798:	6a 01                	push   $0x1
  jmp alltraps
8010679a:	e9 75 f9 ff ff       	jmp    80106114 <alltraps>

8010679f <vector2>:
.globl vector2
vector2:
  pushl $0
8010679f:	6a 00                	push   $0x0
  pushl $2
801067a1:	6a 02                	push   $0x2
  jmp alltraps
801067a3:	e9 6c f9 ff ff       	jmp    80106114 <alltraps>

801067a8 <vector3>:
.globl vector3
vector3:
  pushl $0
801067a8:	6a 00                	push   $0x0
  pushl $3
801067aa:	6a 03                	push   $0x3
  jmp alltraps
801067ac:	e9 63 f9 ff ff       	jmp    80106114 <alltraps>

801067b1 <vector4>:
.globl vector4
vector4:
  pushl $0
801067b1:	6a 00                	push   $0x0
  pushl $4
801067b3:	6a 04                	push   $0x4
  jmp alltraps
801067b5:	e9 5a f9 ff ff       	jmp    80106114 <alltraps>

801067ba <vector5>:
.globl vector5
vector5:
  pushl $0
801067ba:	6a 00                	push   $0x0
  pushl $5
801067bc:	6a 05                	push   $0x5
  jmp alltraps
801067be:	e9 51 f9 ff ff       	jmp    80106114 <alltraps>

801067c3 <vector6>:
.globl vector6
vector6:
  pushl $0
801067c3:	6a 00                	push   $0x0
  pushl $6
801067c5:	6a 06                	push   $0x6
  jmp alltraps
801067c7:	e9 48 f9 ff ff       	jmp    80106114 <alltraps>

801067cc <vector7>:
.globl vector7
vector7:
  pushl $0
801067cc:	6a 00                	push   $0x0
  pushl $7
801067ce:	6a 07                	push   $0x7
  jmp alltraps
801067d0:	e9 3f f9 ff ff       	jmp    80106114 <alltraps>

801067d5 <vector8>:
.globl vector8
vector8:
  pushl $8
801067d5:	6a 08                	push   $0x8
  jmp alltraps
801067d7:	e9 38 f9 ff ff       	jmp    80106114 <alltraps>

801067dc <vector9>:
.globl vector9
vector9:
  pushl $0
801067dc:	6a 00                	push   $0x0
  pushl $9
801067de:	6a 09                	push   $0x9
  jmp alltraps
801067e0:	e9 2f f9 ff ff       	jmp    80106114 <alltraps>

801067e5 <vector10>:
.globl vector10
vector10:
  pushl $10
801067e5:	6a 0a                	push   $0xa
  jmp alltraps
801067e7:	e9 28 f9 ff ff       	jmp    80106114 <alltraps>

801067ec <vector11>:
.globl vector11
vector11:
  pushl $11
801067ec:	6a 0b                	push   $0xb
  jmp alltraps
801067ee:	e9 21 f9 ff ff       	jmp    80106114 <alltraps>

801067f3 <vector12>:
.globl vector12
vector12:
  pushl $12
801067f3:	6a 0c                	push   $0xc
  jmp alltraps
801067f5:	e9 1a f9 ff ff       	jmp    80106114 <alltraps>

801067fa <vector13>:
.globl vector13
vector13:
  pushl $13
801067fa:	6a 0d                	push   $0xd
  jmp alltraps
801067fc:	e9 13 f9 ff ff       	jmp    80106114 <alltraps>

80106801 <vector14>:
.globl vector14
vector14:
  pushl $14
80106801:	6a 0e                	push   $0xe
  jmp alltraps
80106803:	e9 0c f9 ff ff       	jmp    80106114 <alltraps>

80106808 <vector15>:
.globl vector15
vector15:
  pushl $0
80106808:	6a 00                	push   $0x0
  pushl $15
8010680a:	6a 0f                	push   $0xf
  jmp alltraps
8010680c:	e9 03 f9 ff ff       	jmp    80106114 <alltraps>

80106811 <vector16>:
.globl vector16
vector16:
  pushl $0
80106811:	6a 00                	push   $0x0
  pushl $16
80106813:	6a 10                	push   $0x10
  jmp alltraps
80106815:	e9 fa f8 ff ff       	jmp    80106114 <alltraps>

8010681a <vector17>:
.globl vector17
vector17:
  pushl $17
8010681a:	6a 11                	push   $0x11
  jmp alltraps
8010681c:	e9 f3 f8 ff ff       	jmp    80106114 <alltraps>

80106821 <vector18>:
.globl vector18
vector18:
  pushl $0
80106821:	6a 00                	push   $0x0
  pushl $18
80106823:	6a 12                	push   $0x12
  jmp alltraps
80106825:	e9 ea f8 ff ff       	jmp    80106114 <alltraps>

8010682a <vector19>:
.globl vector19
vector19:
  pushl $0
8010682a:	6a 00                	push   $0x0
  pushl $19
8010682c:	6a 13                	push   $0x13
  jmp alltraps
8010682e:	e9 e1 f8 ff ff       	jmp    80106114 <alltraps>

80106833 <vector20>:
.globl vector20
vector20:
  pushl $0
80106833:	6a 00                	push   $0x0
  pushl $20
80106835:	6a 14                	push   $0x14
  jmp alltraps
80106837:	e9 d8 f8 ff ff       	jmp    80106114 <alltraps>

8010683c <vector21>:
.globl vector21
vector21:
  pushl $0
8010683c:	6a 00                	push   $0x0
  pushl $21
8010683e:	6a 15                	push   $0x15
  jmp alltraps
80106840:	e9 cf f8 ff ff       	jmp    80106114 <alltraps>

80106845 <vector22>:
.globl vector22
vector22:
  pushl $0
80106845:	6a 00                	push   $0x0
  pushl $22
80106847:	6a 16                	push   $0x16
  jmp alltraps
80106849:	e9 c6 f8 ff ff       	jmp    80106114 <alltraps>

8010684e <vector23>:
.globl vector23
vector23:
  pushl $0
8010684e:	6a 00                	push   $0x0
  pushl $23
80106850:	6a 17                	push   $0x17
  jmp alltraps
80106852:	e9 bd f8 ff ff       	jmp    80106114 <alltraps>

80106857 <vector24>:
.globl vector24
vector24:
  pushl $0
80106857:	6a 00                	push   $0x0
  pushl $24
80106859:	6a 18                	push   $0x18
  jmp alltraps
8010685b:	e9 b4 f8 ff ff       	jmp    80106114 <alltraps>

80106860 <vector25>:
.globl vector25
vector25:
  pushl $0
80106860:	6a 00                	push   $0x0
  pushl $25
80106862:	6a 19                	push   $0x19
  jmp alltraps
80106864:	e9 ab f8 ff ff       	jmp    80106114 <alltraps>

80106869 <vector26>:
.globl vector26
vector26:
  pushl $0
80106869:	6a 00                	push   $0x0
  pushl $26
8010686b:	6a 1a                	push   $0x1a
  jmp alltraps
8010686d:	e9 a2 f8 ff ff       	jmp    80106114 <alltraps>

80106872 <vector27>:
.globl vector27
vector27:
  pushl $0
80106872:	6a 00                	push   $0x0
  pushl $27
80106874:	6a 1b                	push   $0x1b
  jmp alltraps
80106876:	e9 99 f8 ff ff       	jmp    80106114 <alltraps>

8010687b <vector28>:
.globl vector28
vector28:
  pushl $0
8010687b:	6a 00                	push   $0x0
  pushl $28
8010687d:	6a 1c                	push   $0x1c
  jmp alltraps
8010687f:	e9 90 f8 ff ff       	jmp    80106114 <alltraps>

80106884 <vector29>:
.globl vector29
vector29:
  pushl $0
80106884:	6a 00                	push   $0x0
  pushl $29
80106886:	6a 1d                	push   $0x1d
  jmp alltraps
80106888:	e9 87 f8 ff ff       	jmp    80106114 <alltraps>

8010688d <vector30>:
.globl vector30
vector30:
  pushl $0
8010688d:	6a 00                	push   $0x0
  pushl $30
8010688f:	6a 1e                	push   $0x1e
  jmp alltraps
80106891:	e9 7e f8 ff ff       	jmp    80106114 <alltraps>

80106896 <vector31>:
.globl vector31
vector31:
  pushl $0
80106896:	6a 00                	push   $0x0
  pushl $31
80106898:	6a 1f                	push   $0x1f
  jmp alltraps
8010689a:	e9 75 f8 ff ff       	jmp    80106114 <alltraps>

8010689f <vector32>:
.globl vector32
vector32:
  pushl $0
8010689f:	6a 00                	push   $0x0
  pushl $32
801068a1:	6a 20                	push   $0x20
  jmp alltraps
801068a3:	e9 6c f8 ff ff       	jmp    80106114 <alltraps>

801068a8 <vector33>:
.globl vector33
vector33:
  pushl $0
801068a8:	6a 00                	push   $0x0
  pushl $33
801068aa:	6a 21                	push   $0x21
  jmp alltraps
801068ac:	e9 63 f8 ff ff       	jmp    80106114 <alltraps>

801068b1 <vector34>:
.globl vector34
vector34:
  pushl $0
801068b1:	6a 00                	push   $0x0
  pushl $34
801068b3:	6a 22                	push   $0x22
  jmp alltraps
801068b5:	e9 5a f8 ff ff       	jmp    80106114 <alltraps>

801068ba <vector35>:
.globl vector35
vector35:
  pushl $0
801068ba:	6a 00                	push   $0x0
  pushl $35
801068bc:	6a 23                	push   $0x23
  jmp alltraps
801068be:	e9 51 f8 ff ff       	jmp    80106114 <alltraps>

801068c3 <vector36>:
.globl vector36
vector36:
  pushl $0
801068c3:	6a 00                	push   $0x0
  pushl $36
801068c5:	6a 24                	push   $0x24
  jmp alltraps
801068c7:	e9 48 f8 ff ff       	jmp    80106114 <alltraps>

801068cc <vector37>:
.globl vector37
vector37:
  pushl $0
801068cc:	6a 00                	push   $0x0
  pushl $37
801068ce:	6a 25                	push   $0x25
  jmp alltraps
801068d0:	e9 3f f8 ff ff       	jmp    80106114 <alltraps>

801068d5 <vector38>:
.globl vector38
vector38:
  pushl $0
801068d5:	6a 00                	push   $0x0
  pushl $38
801068d7:	6a 26                	push   $0x26
  jmp alltraps
801068d9:	e9 36 f8 ff ff       	jmp    80106114 <alltraps>

801068de <vector39>:
.globl vector39
vector39:
  pushl $0
801068de:	6a 00                	push   $0x0
  pushl $39
801068e0:	6a 27                	push   $0x27
  jmp alltraps
801068e2:	e9 2d f8 ff ff       	jmp    80106114 <alltraps>

801068e7 <vector40>:
.globl vector40
vector40:
  pushl $0
801068e7:	6a 00                	push   $0x0
  pushl $40
801068e9:	6a 28                	push   $0x28
  jmp alltraps
801068eb:	e9 24 f8 ff ff       	jmp    80106114 <alltraps>

801068f0 <vector41>:
.globl vector41
vector41:
  pushl $0
801068f0:	6a 00                	push   $0x0
  pushl $41
801068f2:	6a 29                	push   $0x29
  jmp alltraps
801068f4:	e9 1b f8 ff ff       	jmp    80106114 <alltraps>

801068f9 <vector42>:
.globl vector42
vector42:
  pushl $0
801068f9:	6a 00                	push   $0x0
  pushl $42
801068fb:	6a 2a                	push   $0x2a
  jmp alltraps
801068fd:	e9 12 f8 ff ff       	jmp    80106114 <alltraps>

80106902 <vector43>:
.globl vector43
vector43:
  pushl $0
80106902:	6a 00                	push   $0x0
  pushl $43
80106904:	6a 2b                	push   $0x2b
  jmp alltraps
80106906:	e9 09 f8 ff ff       	jmp    80106114 <alltraps>

8010690b <vector44>:
.globl vector44
vector44:
  pushl $0
8010690b:	6a 00                	push   $0x0
  pushl $44
8010690d:	6a 2c                	push   $0x2c
  jmp alltraps
8010690f:	e9 00 f8 ff ff       	jmp    80106114 <alltraps>

80106914 <vector45>:
.globl vector45
vector45:
  pushl $0
80106914:	6a 00                	push   $0x0
  pushl $45
80106916:	6a 2d                	push   $0x2d
  jmp alltraps
80106918:	e9 f7 f7 ff ff       	jmp    80106114 <alltraps>

8010691d <vector46>:
.globl vector46
vector46:
  pushl $0
8010691d:	6a 00                	push   $0x0
  pushl $46
8010691f:	6a 2e                	push   $0x2e
  jmp alltraps
80106921:	e9 ee f7 ff ff       	jmp    80106114 <alltraps>

80106926 <vector47>:
.globl vector47
vector47:
  pushl $0
80106926:	6a 00                	push   $0x0
  pushl $47
80106928:	6a 2f                	push   $0x2f
  jmp alltraps
8010692a:	e9 e5 f7 ff ff       	jmp    80106114 <alltraps>

8010692f <vector48>:
.globl vector48
vector48:
  pushl $0
8010692f:	6a 00                	push   $0x0
  pushl $48
80106931:	6a 30                	push   $0x30
  jmp alltraps
80106933:	e9 dc f7 ff ff       	jmp    80106114 <alltraps>

80106938 <vector49>:
.globl vector49
vector49:
  pushl $0
80106938:	6a 00                	push   $0x0
  pushl $49
8010693a:	6a 31                	push   $0x31
  jmp alltraps
8010693c:	e9 d3 f7 ff ff       	jmp    80106114 <alltraps>

80106941 <vector50>:
.globl vector50
vector50:
  pushl $0
80106941:	6a 00                	push   $0x0
  pushl $50
80106943:	6a 32                	push   $0x32
  jmp alltraps
80106945:	e9 ca f7 ff ff       	jmp    80106114 <alltraps>

8010694a <vector51>:
.globl vector51
vector51:
  pushl $0
8010694a:	6a 00                	push   $0x0
  pushl $51
8010694c:	6a 33                	push   $0x33
  jmp alltraps
8010694e:	e9 c1 f7 ff ff       	jmp    80106114 <alltraps>

80106953 <vector52>:
.globl vector52
vector52:
  pushl $0
80106953:	6a 00                	push   $0x0
  pushl $52
80106955:	6a 34                	push   $0x34
  jmp alltraps
80106957:	e9 b8 f7 ff ff       	jmp    80106114 <alltraps>

8010695c <vector53>:
.globl vector53
vector53:
  pushl $0
8010695c:	6a 00                	push   $0x0
  pushl $53
8010695e:	6a 35                	push   $0x35
  jmp alltraps
80106960:	e9 af f7 ff ff       	jmp    80106114 <alltraps>

80106965 <vector54>:
.globl vector54
vector54:
  pushl $0
80106965:	6a 00                	push   $0x0
  pushl $54
80106967:	6a 36                	push   $0x36
  jmp alltraps
80106969:	e9 a6 f7 ff ff       	jmp    80106114 <alltraps>

8010696e <vector55>:
.globl vector55
vector55:
  pushl $0
8010696e:	6a 00                	push   $0x0
  pushl $55
80106970:	6a 37                	push   $0x37
  jmp alltraps
80106972:	e9 9d f7 ff ff       	jmp    80106114 <alltraps>

80106977 <vector56>:
.globl vector56
vector56:
  pushl $0
80106977:	6a 00                	push   $0x0
  pushl $56
80106979:	6a 38                	push   $0x38
  jmp alltraps
8010697b:	e9 94 f7 ff ff       	jmp    80106114 <alltraps>

80106980 <vector57>:
.globl vector57
vector57:
  pushl $0
80106980:	6a 00                	push   $0x0
  pushl $57
80106982:	6a 39                	push   $0x39
  jmp alltraps
80106984:	e9 8b f7 ff ff       	jmp    80106114 <alltraps>

80106989 <vector58>:
.globl vector58
vector58:
  pushl $0
80106989:	6a 00                	push   $0x0
  pushl $58
8010698b:	6a 3a                	push   $0x3a
  jmp alltraps
8010698d:	e9 82 f7 ff ff       	jmp    80106114 <alltraps>

80106992 <vector59>:
.globl vector59
vector59:
  pushl $0
80106992:	6a 00                	push   $0x0
  pushl $59
80106994:	6a 3b                	push   $0x3b
  jmp alltraps
80106996:	e9 79 f7 ff ff       	jmp    80106114 <alltraps>

8010699b <vector60>:
.globl vector60
vector60:
  pushl $0
8010699b:	6a 00                	push   $0x0
  pushl $60
8010699d:	6a 3c                	push   $0x3c
  jmp alltraps
8010699f:	e9 70 f7 ff ff       	jmp    80106114 <alltraps>

801069a4 <vector61>:
.globl vector61
vector61:
  pushl $0
801069a4:	6a 00                	push   $0x0
  pushl $61
801069a6:	6a 3d                	push   $0x3d
  jmp alltraps
801069a8:	e9 67 f7 ff ff       	jmp    80106114 <alltraps>

801069ad <vector62>:
.globl vector62
vector62:
  pushl $0
801069ad:	6a 00                	push   $0x0
  pushl $62
801069af:	6a 3e                	push   $0x3e
  jmp alltraps
801069b1:	e9 5e f7 ff ff       	jmp    80106114 <alltraps>

801069b6 <vector63>:
.globl vector63
vector63:
  pushl $0
801069b6:	6a 00                	push   $0x0
  pushl $63
801069b8:	6a 3f                	push   $0x3f
  jmp alltraps
801069ba:	e9 55 f7 ff ff       	jmp    80106114 <alltraps>

801069bf <vector64>:
.globl vector64
vector64:
  pushl $0
801069bf:	6a 00                	push   $0x0
  pushl $64
801069c1:	6a 40                	push   $0x40
  jmp alltraps
801069c3:	e9 4c f7 ff ff       	jmp    80106114 <alltraps>

801069c8 <vector65>:
.globl vector65
vector65:
  pushl $0
801069c8:	6a 00                	push   $0x0
  pushl $65
801069ca:	6a 41                	push   $0x41
  jmp alltraps
801069cc:	e9 43 f7 ff ff       	jmp    80106114 <alltraps>

801069d1 <vector66>:
.globl vector66
vector66:
  pushl $0
801069d1:	6a 00                	push   $0x0
  pushl $66
801069d3:	6a 42                	push   $0x42
  jmp alltraps
801069d5:	e9 3a f7 ff ff       	jmp    80106114 <alltraps>

801069da <vector67>:
.globl vector67
vector67:
  pushl $0
801069da:	6a 00                	push   $0x0
  pushl $67
801069dc:	6a 43                	push   $0x43
  jmp alltraps
801069de:	e9 31 f7 ff ff       	jmp    80106114 <alltraps>

801069e3 <vector68>:
.globl vector68
vector68:
  pushl $0
801069e3:	6a 00                	push   $0x0
  pushl $68
801069e5:	6a 44                	push   $0x44
  jmp alltraps
801069e7:	e9 28 f7 ff ff       	jmp    80106114 <alltraps>

801069ec <vector69>:
.globl vector69
vector69:
  pushl $0
801069ec:	6a 00                	push   $0x0
  pushl $69
801069ee:	6a 45                	push   $0x45
  jmp alltraps
801069f0:	e9 1f f7 ff ff       	jmp    80106114 <alltraps>

801069f5 <vector70>:
.globl vector70
vector70:
  pushl $0
801069f5:	6a 00                	push   $0x0
  pushl $70
801069f7:	6a 46                	push   $0x46
  jmp alltraps
801069f9:	e9 16 f7 ff ff       	jmp    80106114 <alltraps>

801069fe <vector71>:
.globl vector71
vector71:
  pushl $0
801069fe:	6a 00                	push   $0x0
  pushl $71
80106a00:	6a 47                	push   $0x47
  jmp alltraps
80106a02:	e9 0d f7 ff ff       	jmp    80106114 <alltraps>

80106a07 <vector72>:
.globl vector72
vector72:
  pushl $0
80106a07:	6a 00                	push   $0x0
  pushl $72
80106a09:	6a 48                	push   $0x48
  jmp alltraps
80106a0b:	e9 04 f7 ff ff       	jmp    80106114 <alltraps>

80106a10 <vector73>:
.globl vector73
vector73:
  pushl $0
80106a10:	6a 00                	push   $0x0
  pushl $73
80106a12:	6a 49                	push   $0x49
  jmp alltraps
80106a14:	e9 fb f6 ff ff       	jmp    80106114 <alltraps>

80106a19 <vector74>:
.globl vector74
vector74:
  pushl $0
80106a19:	6a 00                	push   $0x0
  pushl $74
80106a1b:	6a 4a                	push   $0x4a
  jmp alltraps
80106a1d:	e9 f2 f6 ff ff       	jmp    80106114 <alltraps>

80106a22 <vector75>:
.globl vector75
vector75:
  pushl $0
80106a22:	6a 00                	push   $0x0
  pushl $75
80106a24:	6a 4b                	push   $0x4b
  jmp alltraps
80106a26:	e9 e9 f6 ff ff       	jmp    80106114 <alltraps>

80106a2b <vector76>:
.globl vector76
vector76:
  pushl $0
80106a2b:	6a 00                	push   $0x0
  pushl $76
80106a2d:	6a 4c                	push   $0x4c
  jmp alltraps
80106a2f:	e9 e0 f6 ff ff       	jmp    80106114 <alltraps>

80106a34 <vector77>:
.globl vector77
vector77:
  pushl $0
80106a34:	6a 00                	push   $0x0
  pushl $77
80106a36:	6a 4d                	push   $0x4d
  jmp alltraps
80106a38:	e9 d7 f6 ff ff       	jmp    80106114 <alltraps>

80106a3d <vector78>:
.globl vector78
vector78:
  pushl $0
80106a3d:	6a 00                	push   $0x0
  pushl $78
80106a3f:	6a 4e                	push   $0x4e
  jmp alltraps
80106a41:	e9 ce f6 ff ff       	jmp    80106114 <alltraps>

80106a46 <vector79>:
.globl vector79
vector79:
  pushl $0
80106a46:	6a 00                	push   $0x0
  pushl $79
80106a48:	6a 4f                	push   $0x4f
  jmp alltraps
80106a4a:	e9 c5 f6 ff ff       	jmp    80106114 <alltraps>

80106a4f <vector80>:
.globl vector80
vector80:
  pushl $0
80106a4f:	6a 00                	push   $0x0
  pushl $80
80106a51:	6a 50                	push   $0x50
  jmp alltraps
80106a53:	e9 bc f6 ff ff       	jmp    80106114 <alltraps>

80106a58 <vector81>:
.globl vector81
vector81:
  pushl $0
80106a58:	6a 00                	push   $0x0
  pushl $81
80106a5a:	6a 51                	push   $0x51
  jmp alltraps
80106a5c:	e9 b3 f6 ff ff       	jmp    80106114 <alltraps>

80106a61 <vector82>:
.globl vector82
vector82:
  pushl $0
80106a61:	6a 00                	push   $0x0
  pushl $82
80106a63:	6a 52                	push   $0x52
  jmp alltraps
80106a65:	e9 aa f6 ff ff       	jmp    80106114 <alltraps>

80106a6a <vector83>:
.globl vector83
vector83:
  pushl $0
80106a6a:	6a 00                	push   $0x0
  pushl $83
80106a6c:	6a 53                	push   $0x53
  jmp alltraps
80106a6e:	e9 a1 f6 ff ff       	jmp    80106114 <alltraps>

80106a73 <vector84>:
.globl vector84
vector84:
  pushl $0
80106a73:	6a 00                	push   $0x0
  pushl $84
80106a75:	6a 54                	push   $0x54
  jmp alltraps
80106a77:	e9 98 f6 ff ff       	jmp    80106114 <alltraps>

80106a7c <vector85>:
.globl vector85
vector85:
  pushl $0
80106a7c:	6a 00                	push   $0x0
  pushl $85
80106a7e:	6a 55                	push   $0x55
  jmp alltraps
80106a80:	e9 8f f6 ff ff       	jmp    80106114 <alltraps>

80106a85 <vector86>:
.globl vector86
vector86:
  pushl $0
80106a85:	6a 00                	push   $0x0
  pushl $86
80106a87:	6a 56                	push   $0x56
  jmp alltraps
80106a89:	e9 86 f6 ff ff       	jmp    80106114 <alltraps>

80106a8e <vector87>:
.globl vector87
vector87:
  pushl $0
80106a8e:	6a 00                	push   $0x0
  pushl $87
80106a90:	6a 57                	push   $0x57
  jmp alltraps
80106a92:	e9 7d f6 ff ff       	jmp    80106114 <alltraps>

80106a97 <vector88>:
.globl vector88
vector88:
  pushl $0
80106a97:	6a 00                	push   $0x0
  pushl $88
80106a99:	6a 58                	push   $0x58
  jmp alltraps
80106a9b:	e9 74 f6 ff ff       	jmp    80106114 <alltraps>

80106aa0 <vector89>:
.globl vector89
vector89:
  pushl $0
80106aa0:	6a 00                	push   $0x0
  pushl $89
80106aa2:	6a 59                	push   $0x59
  jmp alltraps
80106aa4:	e9 6b f6 ff ff       	jmp    80106114 <alltraps>

80106aa9 <vector90>:
.globl vector90
vector90:
  pushl $0
80106aa9:	6a 00                	push   $0x0
  pushl $90
80106aab:	6a 5a                	push   $0x5a
  jmp alltraps
80106aad:	e9 62 f6 ff ff       	jmp    80106114 <alltraps>

80106ab2 <vector91>:
.globl vector91
vector91:
  pushl $0
80106ab2:	6a 00                	push   $0x0
  pushl $91
80106ab4:	6a 5b                	push   $0x5b
  jmp alltraps
80106ab6:	e9 59 f6 ff ff       	jmp    80106114 <alltraps>

80106abb <vector92>:
.globl vector92
vector92:
  pushl $0
80106abb:	6a 00                	push   $0x0
  pushl $92
80106abd:	6a 5c                	push   $0x5c
  jmp alltraps
80106abf:	e9 50 f6 ff ff       	jmp    80106114 <alltraps>

80106ac4 <vector93>:
.globl vector93
vector93:
  pushl $0
80106ac4:	6a 00                	push   $0x0
  pushl $93
80106ac6:	6a 5d                	push   $0x5d
  jmp alltraps
80106ac8:	e9 47 f6 ff ff       	jmp    80106114 <alltraps>

80106acd <vector94>:
.globl vector94
vector94:
  pushl $0
80106acd:	6a 00                	push   $0x0
  pushl $94
80106acf:	6a 5e                	push   $0x5e
  jmp alltraps
80106ad1:	e9 3e f6 ff ff       	jmp    80106114 <alltraps>

80106ad6 <vector95>:
.globl vector95
vector95:
  pushl $0
80106ad6:	6a 00                	push   $0x0
  pushl $95
80106ad8:	6a 5f                	push   $0x5f
  jmp alltraps
80106ada:	e9 35 f6 ff ff       	jmp    80106114 <alltraps>

80106adf <vector96>:
.globl vector96
vector96:
  pushl $0
80106adf:	6a 00                	push   $0x0
  pushl $96
80106ae1:	6a 60                	push   $0x60
  jmp alltraps
80106ae3:	e9 2c f6 ff ff       	jmp    80106114 <alltraps>

80106ae8 <vector97>:
.globl vector97
vector97:
  pushl $0
80106ae8:	6a 00                	push   $0x0
  pushl $97
80106aea:	6a 61                	push   $0x61
  jmp alltraps
80106aec:	e9 23 f6 ff ff       	jmp    80106114 <alltraps>

80106af1 <vector98>:
.globl vector98
vector98:
  pushl $0
80106af1:	6a 00                	push   $0x0
  pushl $98
80106af3:	6a 62                	push   $0x62
  jmp alltraps
80106af5:	e9 1a f6 ff ff       	jmp    80106114 <alltraps>

80106afa <vector99>:
.globl vector99
vector99:
  pushl $0
80106afa:	6a 00                	push   $0x0
  pushl $99
80106afc:	6a 63                	push   $0x63
  jmp alltraps
80106afe:	e9 11 f6 ff ff       	jmp    80106114 <alltraps>

80106b03 <vector100>:
.globl vector100
vector100:
  pushl $0
80106b03:	6a 00                	push   $0x0
  pushl $100
80106b05:	6a 64                	push   $0x64
  jmp alltraps
80106b07:	e9 08 f6 ff ff       	jmp    80106114 <alltraps>

80106b0c <vector101>:
.globl vector101
vector101:
  pushl $0
80106b0c:	6a 00                	push   $0x0
  pushl $101
80106b0e:	6a 65                	push   $0x65
  jmp alltraps
80106b10:	e9 ff f5 ff ff       	jmp    80106114 <alltraps>

80106b15 <vector102>:
.globl vector102
vector102:
  pushl $0
80106b15:	6a 00                	push   $0x0
  pushl $102
80106b17:	6a 66                	push   $0x66
  jmp alltraps
80106b19:	e9 f6 f5 ff ff       	jmp    80106114 <alltraps>

80106b1e <vector103>:
.globl vector103
vector103:
  pushl $0
80106b1e:	6a 00                	push   $0x0
  pushl $103
80106b20:	6a 67                	push   $0x67
  jmp alltraps
80106b22:	e9 ed f5 ff ff       	jmp    80106114 <alltraps>

80106b27 <vector104>:
.globl vector104
vector104:
  pushl $0
80106b27:	6a 00                	push   $0x0
  pushl $104
80106b29:	6a 68                	push   $0x68
  jmp alltraps
80106b2b:	e9 e4 f5 ff ff       	jmp    80106114 <alltraps>

80106b30 <vector105>:
.globl vector105
vector105:
  pushl $0
80106b30:	6a 00                	push   $0x0
  pushl $105
80106b32:	6a 69                	push   $0x69
  jmp alltraps
80106b34:	e9 db f5 ff ff       	jmp    80106114 <alltraps>

80106b39 <vector106>:
.globl vector106
vector106:
  pushl $0
80106b39:	6a 00                	push   $0x0
  pushl $106
80106b3b:	6a 6a                	push   $0x6a
  jmp alltraps
80106b3d:	e9 d2 f5 ff ff       	jmp    80106114 <alltraps>

80106b42 <vector107>:
.globl vector107
vector107:
  pushl $0
80106b42:	6a 00                	push   $0x0
  pushl $107
80106b44:	6a 6b                	push   $0x6b
  jmp alltraps
80106b46:	e9 c9 f5 ff ff       	jmp    80106114 <alltraps>

80106b4b <vector108>:
.globl vector108
vector108:
  pushl $0
80106b4b:	6a 00                	push   $0x0
  pushl $108
80106b4d:	6a 6c                	push   $0x6c
  jmp alltraps
80106b4f:	e9 c0 f5 ff ff       	jmp    80106114 <alltraps>

80106b54 <vector109>:
.globl vector109
vector109:
  pushl $0
80106b54:	6a 00                	push   $0x0
  pushl $109
80106b56:	6a 6d                	push   $0x6d
  jmp alltraps
80106b58:	e9 b7 f5 ff ff       	jmp    80106114 <alltraps>

80106b5d <vector110>:
.globl vector110
vector110:
  pushl $0
80106b5d:	6a 00                	push   $0x0
  pushl $110
80106b5f:	6a 6e                	push   $0x6e
  jmp alltraps
80106b61:	e9 ae f5 ff ff       	jmp    80106114 <alltraps>

80106b66 <vector111>:
.globl vector111
vector111:
  pushl $0
80106b66:	6a 00                	push   $0x0
  pushl $111
80106b68:	6a 6f                	push   $0x6f
  jmp alltraps
80106b6a:	e9 a5 f5 ff ff       	jmp    80106114 <alltraps>

80106b6f <vector112>:
.globl vector112
vector112:
  pushl $0
80106b6f:	6a 00                	push   $0x0
  pushl $112
80106b71:	6a 70                	push   $0x70
  jmp alltraps
80106b73:	e9 9c f5 ff ff       	jmp    80106114 <alltraps>

80106b78 <vector113>:
.globl vector113
vector113:
  pushl $0
80106b78:	6a 00                	push   $0x0
  pushl $113
80106b7a:	6a 71                	push   $0x71
  jmp alltraps
80106b7c:	e9 93 f5 ff ff       	jmp    80106114 <alltraps>

80106b81 <vector114>:
.globl vector114
vector114:
  pushl $0
80106b81:	6a 00                	push   $0x0
  pushl $114
80106b83:	6a 72                	push   $0x72
  jmp alltraps
80106b85:	e9 8a f5 ff ff       	jmp    80106114 <alltraps>

80106b8a <vector115>:
.globl vector115
vector115:
  pushl $0
80106b8a:	6a 00                	push   $0x0
  pushl $115
80106b8c:	6a 73                	push   $0x73
  jmp alltraps
80106b8e:	e9 81 f5 ff ff       	jmp    80106114 <alltraps>

80106b93 <vector116>:
.globl vector116
vector116:
  pushl $0
80106b93:	6a 00                	push   $0x0
  pushl $116
80106b95:	6a 74                	push   $0x74
  jmp alltraps
80106b97:	e9 78 f5 ff ff       	jmp    80106114 <alltraps>

80106b9c <vector117>:
.globl vector117
vector117:
  pushl $0
80106b9c:	6a 00                	push   $0x0
  pushl $117
80106b9e:	6a 75                	push   $0x75
  jmp alltraps
80106ba0:	e9 6f f5 ff ff       	jmp    80106114 <alltraps>

80106ba5 <vector118>:
.globl vector118
vector118:
  pushl $0
80106ba5:	6a 00                	push   $0x0
  pushl $118
80106ba7:	6a 76                	push   $0x76
  jmp alltraps
80106ba9:	e9 66 f5 ff ff       	jmp    80106114 <alltraps>

80106bae <vector119>:
.globl vector119
vector119:
  pushl $0
80106bae:	6a 00                	push   $0x0
  pushl $119
80106bb0:	6a 77                	push   $0x77
  jmp alltraps
80106bb2:	e9 5d f5 ff ff       	jmp    80106114 <alltraps>

80106bb7 <vector120>:
.globl vector120
vector120:
  pushl $0
80106bb7:	6a 00                	push   $0x0
  pushl $120
80106bb9:	6a 78                	push   $0x78
  jmp alltraps
80106bbb:	e9 54 f5 ff ff       	jmp    80106114 <alltraps>

80106bc0 <vector121>:
.globl vector121
vector121:
  pushl $0
80106bc0:	6a 00                	push   $0x0
  pushl $121
80106bc2:	6a 79                	push   $0x79
  jmp alltraps
80106bc4:	e9 4b f5 ff ff       	jmp    80106114 <alltraps>

80106bc9 <vector122>:
.globl vector122
vector122:
  pushl $0
80106bc9:	6a 00                	push   $0x0
  pushl $122
80106bcb:	6a 7a                	push   $0x7a
  jmp alltraps
80106bcd:	e9 42 f5 ff ff       	jmp    80106114 <alltraps>

80106bd2 <vector123>:
.globl vector123
vector123:
  pushl $0
80106bd2:	6a 00                	push   $0x0
  pushl $123
80106bd4:	6a 7b                	push   $0x7b
  jmp alltraps
80106bd6:	e9 39 f5 ff ff       	jmp    80106114 <alltraps>

80106bdb <vector124>:
.globl vector124
vector124:
  pushl $0
80106bdb:	6a 00                	push   $0x0
  pushl $124
80106bdd:	6a 7c                	push   $0x7c
  jmp alltraps
80106bdf:	e9 30 f5 ff ff       	jmp    80106114 <alltraps>

80106be4 <vector125>:
.globl vector125
vector125:
  pushl $0
80106be4:	6a 00                	push   $0x0
  pushl $125
80106be6:	6a 7d                	push   $0x7d
  jmp alltraps
80106be8:	e9 27 f5 ff ff       	jmp    80106114 <alltraps>

80106bed <vector126>:
.globl vector126
vector126:
  pushl $0
80106bed:	6a 00                	push   $0x0
  pushl $126
80106bef:	6a 7e                	push   $0x7e
  jmp alltraps
80106bf1:	e9 1e f5 ff ff       	jmp    80106114 <alltraps>

80106bf6 <vector127>:
.globl vector127
vector127:
  pushl $0
80106bf6:	6a 00                	push   $0x0
  pushl $127
80106bf8:	6a 7f                	push   $0x7f
  jmp alltraps
80106bfa:	e9 15 f5 ff ff       	jmp    80106114 <alltraps>

80106bff <vector128>:
.globl vector128
vector128:
  pushl $0
80106bff:	6a 00                	push   $0x0
  pushl $128
80106c01:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106c06:	e9 09 f5 ff ff       	jmp    80106114 <alltraps>

80106c0b <vector129>:
.globl vector129
vector129:
  pushl $0
80106c0b:	6a 00                	push   $0x0
  pushl $129
80106c0d:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106c12:	e9 fd f4 ff ff       	jmp    80106114 <alltraps>

80106c17 <vector130>:
.globl vector130
vector130:
  pushl $0
80106c17:	6a 00                	push   $0x0
  pushl $130
80106c19:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106c1e:	e9 f1 f4 ff ff       	jmp    80106114 <alltraps>

80106c23 <vector131>:
.globl vector131
vector131:
  pushl $0
80106c23:	6a 00                	push   $0x0
  pushl $131
80106c25:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106c2a:	e9 e5 f4 ff ff       	jmp    80106114 <alltraps>

80106c2f <vector132>:
.globl vector132
vector132:
  pushl $0
80106c2f:	6a 00                	push   $0x0
  pushl $132
80106c31:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106c36:	e9 d9 f4 ff ff       	jmp    80106114 <alltraps>

80106c3b <vector133>:
.globl vector133
vector133:
  pushl $0
80106c3b:	6a 00                	push   $0x0
  pushl $133
80106c3d:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106c42:	e9 cd f4 ff ff       	jmp    80106114 <alltraps>

80106c47 <vector134>:
.globl vector134
vector134:
  pushl $0
80106c47:	6a 00                	push   $0x0
  pushl $134
80106c49:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106c4e:	e9 c1 f4 ff ff       	jmp    80106114 <alltraps>

80106c53 <vector135>:
.globl vector135
vector135:
  pushl $0
80106c53:	6a 00                	push   $0x0
  pushl $135
80106c55:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106c5a:	e9 b5 f4 ff ff       	jmp    80106114 <alltraps>

80106c5f <vector136>:
.globl vector136
vector136:
  pushl $0
80106c5f:	6a 00                	push   $0x0
  pushl $136
80106c61:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106c66:	e9 a9 f4 ff ff       	jmp    80106114 <alltraps>

80106c6b <vector137>:
.globl vector137
vector137:
  pushl $0
80106c6b:	6a 00                	push   $0x0
  pushl $137
80106c6d:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106c72:	e9 9d f4 ff ff       	jmp    80106114 <alltraps>

80106c77 <vector138>:
.globl vector138
vector138:
  pushl $0
80106c77:	6a 00                	push   $0x0
  pushl $138
80106c79:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106c7e:	e9 91 f4 ff ff       	jmp    80106114 <alltraps>

80106c83 <vector139>:
.globl vector139
vector139:
  pushl $0
80106c83:	6a 00                	push   $0x0
  pushl $139
80106c85:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106c8a:	e9 85 f4 ff ff       	jmp    80106114 <alltraps>

80106c8f <vector140>:
.globl vector140
vector140:
  pushl $0
80106c8f:	6a 00                	push   $0x0
  pushl $140
80106c91:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106c96:	e9 79 f4 ff ff       	jmp    80106114 <alltraps>

80106c9b <vector141>:
.globl vector141
vector141:
  pushl $0
80106c9b:	6a 00                	push   $0x0
  pushl $141
80106c9d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106ca2:	e9 6d f4 ff ff       	jmp    80106114 <alltraps>

80106ca7 <vector142>:
.globl vector142
vector142:
  pushl $0
80106ca7:	6a 00                	push   $0x0
  pushl $142
80106ca9:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106cae:	e9 61 f4 ff ff       	jmp    80106114 <alltraps>

80106cb3 <vector143>:
.globl vector143
vector143:
  pushl $0
80106cb3:	6a 00                	push   $0x0
  pushl $143
80106cb5:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106cba:	e9 55 f4 ff ff       	jmp    80106114 <alltraps>

80106cbf <vector144>:
.globl vector144
vector144:
  pushl $0
80106cbf:	6a 00                	push   $0x0
  pushl $144
80106cc1:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106cc6:	e9 49 f4 ff ff       	jmp    80106114 <alltraps>

80106ccb <vector145>:
.globl vector145
vector145:
  pushl $0
80106ccb:	6a 00                	push   $0x0
  pushl $145
80106ccd:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106cd2:	e9 3d f4 ff ff       	jmp    80106114 <alltraps>

80106cd7 <vector146>:
.globl vector146
vector146:
  pushl $0
80106cd7:	6a 00                	push   $0x0
  pushl $146
80106cd9:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106cde:	e9 31 f4 ff ff       	jmp    80106114 <alltraps>

80106ce3 <vector147>:
.globl vector147
vector147:
  pushl $0
80106ce3:	6a 00                	push   $0x0
  pushl $147
80106ce5:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106cea:	e9 25 f4 ff ff       	jmp    80106114 <alltraps>

80106cef <vector148>:
.globl vector148
vector148:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $148
80106cf1:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106cf6:	e9 19 f4 ff ff       	jmp    80106114 <alltraps>

80106cfb <vector149>:
.globl vector149
vector149:
  pushl $0
80106cfb:	6a 00                	push   $0x0
  pushl $149
80106cfd:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106d02:	e9 0d f4 ff ff       	jmp    80106114 <alltraps>

80106d07 <vector150>:
.globl vector150
vector150:
  pushl $0
80106d07:	6a 00                	push   $0x0
  pushl $150
80106d09:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106d0e:	e9 01 f4 ff ff       	jmp    80106114 <alltraps>

80106d13 <vector151>:
.globl vector151
vector151:
  pushl $0
80106d13:	6a 00                	push   $0x0
  pushl $151
80106d15:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106d1a:	e9 f5 f3 ff ff       	jmp    80106114 <alltraps>

80106d1f <vector152>:
.globl vector152
vector152:
  pushl $0
80106d1f:	6a 00                	push   $0x0
  pushl $152
80106d21:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106d26:	e9 e9 f3 ff ff       	jmp    80106114 <alltraps>

80106d2b <vector153>:
.globl vector153
vector153:
  pushl $0
80106d2b:	6a 00                	push   $0x0
  pushl $153
80106d2d:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106d32:	e9 dd f3 ff ff       	jmp    80106114 <alltraps>

80106d37 <vector154>:
.globl vector154
vector154:
  pushl $0
80106d37:	6a 00                	push   $0x0
  pushl $154
80106d39:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106d3e:	e9 d1 f3 ff ff       	jmp    80106114 <alltraps>

80106d43 <vector155>:
.globl vector155
vector155:
  pushl $0
80106d43:	6a 00                	push   $0x0
  pushl $155
80106d45:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106d4a:	e9 c5 f3 ff ff       	jmp    80106114 <alltraps>

80106d4f <vector156>:
.globl vector156
vector156:
  pushl $0
80106d4f:	6a 00                	push   $0x0
  pushl $156
80106d51:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106d56:	e9 b9 f3 ff ff       	jmp    80106114 <alltraps>

80106d5b <vector157>:
.globl vector157
vector157:
  pushl $0
80106d5b:	6a 00                	push   $0x0
  pushl $157
80106d5d:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106d62:	e9 ad f3 ff ff       	jmp    80106114 <alltraps>

80106d67 <vector158>:
.globl vector158
vector158:
  pushl $0
80106d67:	6a 00                	push   $0x0
  pushl $158
80106d69:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106d6e:	e9 a1 f3 ff ff       	jmp    80106114 <alltraps>

80106d73 <vector159>:
.globl vector159
vector159:
  pushl $0
80106d73:	6a 00                	push   $0x0
  pushl $159
80106d75:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106d7a:	e9 95 f3 ff ff       	jmp    80106114 <alltraps>

80106d7f <vector160>:
.globl vector160
vector160:
  pushl $0
80106d7f:	6a 00                	push   $0x0
  pushl $160
80106d81:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106d86:	e9 89 f3 ff ff       	jmp    80106114 <alltraps>

80106d8b <vector161>:
.globl vector161
vector161:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $161
80106d8d:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106d92:	e9 7d f3 ff ff       	jmp    80106114 <alltraps>

80106d97 <vector162>:
.globl vector162
vector162:
  pushl $0
80106d97:	6a 00                	push   $0x0
  pushl $162
80106d99:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106d9e:	e9 71 f3 ff ff       	jmp    80106114 <alltraps>

80106da3 <vector163>:
.globl vector163
vector163:
  pushl $0
80106da3:	6a 00                	push   $0x0
  pushl $163
80106da5:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106daa:	e9 65 f3 ff ff       	jmp    80106114 <alltraps>

80106daf <vector164>:
.globl vector164
vector164:
  pushl $0
80106daf:	6a 00                	push   $0x0
  pushl $164
80106db1:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106db6:	e9 59 f3 ff ff       	jmp    80106114 <alltraps>

80106dbb <vector165>:
.globl vector165
vector165:
  pushl $0
80106dbb:	6a 00                	push   $0x0
  pushl $165
80106dbd:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106dc2:	e9 4d f3 ff ff       	jmp    80106114 <alltraps>

80106dc7 <vector166>:
.globl vector166
vector166:
  pushl $0
80106dc7:	6a 00                	push   $0x0
  pushl $166
80106dc9:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106dce:	e9 41 f3 ff ff       	jmp    80106114 <alltraps>

80106dd3 <vector167>:
.globl vector167
vector167:
  pushl $0
80106dd3:	6a 00                	push   $0x0
  pushl $167
80106dd5:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106dda:	e9 35 f3 ff ff       	jmp    80106114 <alltraps>

80106ddf <vector168>:
.globl vector168
vector168:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $168
80106de1:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106de6:	e9 29 f3 ff ff       	jmp    80106114 <alltraps>

80106deb <vector169>:
.globl vector169
vector169:
  pushl $0
80106deb:	6a 00                	push   $0x0
  pushl $169
80106ded:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106df2:	e9 1d f3 ff ff       	jmp    80106114 <alltraps>

80106df7 <vector170>:
.globl vector170
vector170:
  pushl $0
80106df7:	6a 00                	push   $0x0
  pushl $170
80106df9:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106dfe:	e9 11 f3 ff ff       	jmp    80106114 <alltraps>

80106e03 <vector171>:
.globl vector171
vector171:
  pushl $0
80106e03:	6a 00                	push   $0x0
  pushl $171
80106e05:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106e0a:	e9 05 f3 ff ff       	jmp    80106114 <alltraps>

80106e0f <vector172>:
.globl vector172
vector172:
  pushl $0
80106e0f:	6a 00                	push   $0x0
  pushl $172
80106e11:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106e16:	e9 f9 f2 ff ff       	jmp    80106114 <alltraps>

80106e1b <vector173>:
.globl vector173
vector173:
  pushl $0
80106e1b:	6a 00                	push   $0x0
  pushl $173
80106e1d:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106e22:	e9 ed f2 ff ff       	jmp    80106114 <alltraps>

80106e27 <vector174>:
.globl vector174
vector174:
  pushl $0
80106e27:	6a 00                	push   $0x0
  pushl $174
80106e29:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106e2e:	e9 e1 f2 ff ff       	jmp    80106114 <alltraps>

80106e33 <vector175>:
.globl vector175
vector175:
  pushl $0
80106e33:	6a 00                	push   $0x0
  pushl $175
80106e35:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106e3a:	e9 d5 f2 ff ff       	jmp    80106114 <alltraps>

80106e3f <vector176>:
.globl vector176
vector176:
  pushl $0
80106e3f:	6a 00                	push   $0x0
  pushl $176
80106e41:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106e46:	e9 c9 f2 ff ff       	jmp    80106114 <alltraps>

80106e4b <vector177>:
.globl vector177
vector177:
  pushl $0
80106e4b:	6a 00                	push   $0x0
  pushl $177
80106e4d:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106e52:	e9 bd f2 ff ff       	jmp    80106114 <alltraps>

80106e57 <vector178>:
.globl vector178
vector178:
  pushl $0
80106e57:	6a 00                	push   $0x0
  pushl $178
80106e59:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106e5e:	e9 b1 f2 ff ff       	jmp    80106114 <alltraps>

80106e63 <vector179>:
.globl vector179
vector179:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $179
80106e65:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106e6a:	e9 a5 f2 ff ff       	jmp    80106114 <alltraps>

80106e6f <vector180>:
.globl vector180
vector180:
  pushl $0
80106e6f:	6a 00                	push   $0x0
  pushl $180
80106e71:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106e76:	e9 99 f2 ff ff       	jmp    80106114 <alltraps>

80106e7b <vector181>:
.globl vector181
vector181:
  pushl $0
80106e7b:	6a 00                	push   $0x0
  pushl $181
80106e7d:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106e82:	e9 8d f2 ff ff       	jmp    80106114 <alltraps>

80106e87 <vector182>:
.globl vector182
vector182:
  pushl $0
80106e87:	6a 00                	push   $0x0
  pushl $182
80106e89:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106e8e:	e9 81 f2 ff ff       	jmp    80106114 <alltraps>

80106e93 <vector183>:
.globl vector183
vector183:
  pushl $0
80106e93:	6a 00                	push   $0x0
  pushl $183
80106e95:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106e9a:	e9 75 f2 ff ff       	jmp    80106114 <alltraps>

80106e9f <vector184>:
.globl vector184
vector184:
  pushl $0
80106e9f:	6a 00                	push   $0x0
  pushl $184
80106ea1:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106ea6:	e9 69 f2 ff ff       	jmp    80106114 <alltraps>

80106eab <vector185>:
.globl vector185
vector185:
  pushl $0
80106eab:	6a 00                	push   $0x0
  pushl $185
80106ead:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106eb2:	e9 5d f2 ff ff       	jmp    80106114 <alltraps>

80106eb7 <vector186>:
.globl vector186
vector186:
  pushl $0
80106eb7:	6a 00                	push   $0x0
  pushl $186
80106eb9:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106ebe:	e9 51 f2 ff ff       	jmp    80106114 <alltraps>

80106ec3 <vector187>:
.globl vector187
vector187:
  pushl $0
80106ec3:	6a 00                	push   $0x0
  pushl $187
80106ec5:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106eca:	e9 45 f2 ff ff       	jmp    80106114 <alltraps>

80106ecf <vector188>:
.globl vector188
vector188:
  pushl $0
80106ecf:	6a 00                	push   $0x0
  pushl $188
80106ed1:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106ed6:	e9 39 f2 ff ff       	jmp    80106114 <alltraps>

80106edb <vector189>:
.globl vector189
vector189:
  pushl $0
80106edb:	6a 00                	push   $0x0
  pushl $189
80106edd:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106ee2:	e9 2d f2 ff ff       	jmp    80106114 <alltraps>

80106ee7 <vector190>:
.globl vector190
vector190:
  pushl $0
80106ee7:	6a 00                	push   $0x0
  pushl $190
80106ee9:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106eee:	e9 21 f2 ff ff       	jmp    80106114 <alltraps>

80106ef3 <vector191>:
.globl vector191
vector191:
  pushl $0
80106ef3:	6a 00                	push   $0x0
  pushl $191
80106ef5:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106efa:	e9 15 f2 ff ff       	jmp    80106114 <alltraps>

80106eff <vector192>:
.globl vector192
vector192:
  pushl $0
80106eff:	6a 00                	push   $0x0
  pushl $192
80106f01:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106f06:	e9 09 f2 ff ff       	jmp    80106114 <alltraps>

80106f0b <vector193>:
.globl vector193
vector193:
  pushl $0
80106f0b:	6a 00                	push   $0x0
  pushl $193
80106f0d:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106f12:	e9 fd f1 ff ff       	jmp    80106114 <alltraps>

80106f17 <vector194>:
.globl vector194
vector194:
  pushl $0
80106f17:	6a 00                	push   $0x0
  pushl $194
80106f19:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106f1e:	e9 f1 f1 ff ff       	jmp    80106114 <alltraps>

80106f23 <vector195>:
.globl vector195
vector195:
  pushl $0
80106f23:	6a 00                	push   $0x0
  pushl $195
80106f25:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106f2a:	e9 e5 f1 ff ff       	jmp    80106114 <alltraps>

80106f2f <vector196>:
.globl vector196
vector196:
  pushl $0
80106f2f:	6a 00                	push   $0x0
  pushl $196
80106f31:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106f36:	e9 d9 f1 ff ff       	jmp    80106114 <alltraps>

80106f3b <vector197>:
.globl vector197
vector197:
  pushl $0
80106f3b:	6a 00                	push   $0x0
  pushl $197
80106f3d:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106f42:	e9 cd f1 ff ff       	jmp    80106114 <alltraps>

80106f47 <vector198>:
.globl vector198
vector198:
  pushl $0
80106f47:	6a 00                	push   $0x0
  pushl $198
80106f49:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106f4e:	e9 c1 f1 ff ff       	jmp    80106114 <alltraps>

80106f53 <vector199>:
.globl vector199
vector199:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $199
80106f55:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106f5a:	e9 b5 f1 ff ff       	jmp    80106114 <alltraps>

80106f5f <vector200>:
.globl vector200
vector200:
  pushl $0
80106f5f:	6a 00                	push   $0x0
  pushl $200
80106f61:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106f66:	e9 a9 f1 ff ff       	jmp    80106114 <alltraps>

80106f6b <vector201>:
.globl vector201
vector201:
  pushl $0
80106f6b:	6a 00                	push   $0x0
  pushl $201
80106f6d:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106f72:	e9 9d f1 ff ff       	jmp    80106114 <alltraps>

80106f77 <vector202>:
.globl vector202
vector202:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $202
80106f79:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106f7e:	e9 91 f1 ff ff       	jmp    80106114 <alltraps>

80106f83 <vector203>:
.globl vector203
vector203:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $203
80106f85:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106f8a:	e9 85 f1 ff ff       	jmp    80106114 <alltraps>

80106f8f <vector204>:
.globl vector204
vector204:
  pushl $0
80106f8f:	6a 00                	push   $0x0
  pushl $204
80106f91:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106f96:	e9 79 f1 ff ff       	jmp    80106114 <alltraps>

80106f9b <vector205>:
.globl vector205
vector205:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $205
80106f9d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106fa2:	e9 6d f1 ff ff       	jmp    80106114 <alltraps>

80106fa7 <vector206>:
.globl vector206
vector206:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $206
80106fa9:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106fae:	e9 61 f1 ff ff       	jmp    80106114 <alltraps>

80106fb3 <vector207>:
.globl vector207
vector207:
  pushl $0
80106fb3:	6a 00                	push   $0x0
  pushl $207
80106fb5:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106fba:	e9 55 f1 ff ff       	jmp    80106114 <alltraps>

80106fbf <vector208>:
.globl vector208
vector208:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $208
80106fc1:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106fc6:	e9 49 f1 ff ff       	jmp    80106114 <alltraps>

80106fcb <vector209>:
.globl vector209
vector209:
  pushl $0
80106fcb:	6a 00                	push   $0x0
  pushl $209
80106fcd:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106fd2:	e9 3d f1 ff ff       	jmp    80106114 <alltraps>

80106fd7 <vector210>:
.globl vector210
vector210:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $210
80106fd9:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106fde:	e9 31 f1 ff ff       	jmp    80106114 <alltraps>

80106fe3 <vector211>:
.globl vector211
vector211:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $211
80106fe5:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106fea:	e9 25 f1 ff ff       	jmp    80106114 <alltraps>

80106fef <vector212>:
.globl vector212
vector212:
  pushl $0
80106fef:	6a 00                	push   $0x0
  pushl $212
80106ff1:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106ff6:	e9 19 f1 ff ff       	jmp    80106114 <alltraps>

80106ffb <vector213>:
.globl vector213
vector213:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $213
80106ffd:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107002:	e9 0d f1 ff ff       	jmp    80106114 <alltraps>

80107007 <vector214>:
.globl vector214
vector214:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $214
80107009:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010700e:	e9 01 f1 ff ff       	jmp    80106114 <alltraps>

80107013 <vector215>:
.globl vector215
vector215:
  pushl $0
80107013:	6a 00                	push   $0x0
  pushl $215
80107015:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010701a:	e9 f5 f0 ff ff       	jmp    80106114 <alltraps>

8010701f <vector216>:
.globl vector216
vector216:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $216
80107021:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107026:	e9 e9 f0 ff ff       	jmp    80106114 <alltraps>

8010702b <vector217>:
.globl vector217
vector217:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $217
8010702d:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107032:	e9 dd f0 ff ff       	jmp    80106114 <alltraps>

80107037 <vector218>:
.globl vector218
vector218:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $218
80107039:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010703e:	e9 d1 f0 ff ff       	jmp    80106114 <alltraps>

80107043 <vector219>:
.globl vector219
vector219:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $219
80107045:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010704a:	e9 c5 f0 ff ff       	jmp    80106114 <alltraps>

8010704f <vector220>:
.globl vector220
vector220:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $220
80107051:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107056:	e9 b9 f0 ff ff       	jmp    80106114 <alltraps>

8010705b <vector221>:
.globl vector221
vector221:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $221
8010705d:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107062:	e9 ad f0 ff ff       	jmp    80106114 <alltraps>

80107067 <vector222>:
.globl vector222
vector222:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $222
80107069:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010706e:	e9 a1 f0 ff ff       	jmp    80106114 <alltraps>

80107073 <vector223>:
.globl vector223
vector223:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $223
80107075:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010707a:	e9 95 f0 ff ff       	jmp    80106114 <alltraps>

8010707f <vector224>:
.globl vector224
vector224:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $224
80107081:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107086:	e9 89 f0 ff ff       	jmp    80106114 <alltraps>

8010708b <vector225>:
.globl vector225
vector225:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $225
8010708d:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107092:	e9 7d f0 ff ff       	jmp    80106114 <alltraps>

80107097 <vector226>:
.globl vector226
vector226:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $226
80107099:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010709e:	e9 71 f0 ff ff       	jmp    80106114 <alltraps>

801070a3 <vector227>:
.globl vector227
vector227:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $227
801070a5:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801070aa:	e9 65 f0 ff ff       	jmp    80106114 <alltraps>

801070af <vector228>:
.globl vector228
vector228:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $228
801070b1:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801070b6:	e9 59 f0 ff ff       	jmp    80106114 <alltraps>

801070bb <vector229>:
.globl vector229
vector229:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $229
801070bd:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801070c2:	e9 4d f0 ff ff       	jmp    80106114 <alltraps>

801070c7 <vector230>:
.globl vector230
vector230:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $230
801070c9:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801070ce:	e9 41 f0 ff ff       	jmp    80106114 <alltraps>

801070d3 <vector231>:
.globl vector231
vector231:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $231
801070d5:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801070da:	e9 35 f0 ff ff       	jmp    80106114 <alltraps>

801070df <vector232>:
.globl vector232
vector232:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $232
801070e1:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801070e6:	e9 29 f0 ff ff       	jmp    80106114 <alltraps>

801070eb <vector233>:
.globl vector233
vector233:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $233
801070ed:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801070f2:	e9 1d f0 ff ff       	jmp    80106114 <alltraps>

801070f7 <vector234>:
.globl vector234
vector234:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $234
801070f9:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801070fe:	e9 11 f0 ff ff       	jmp    80106114 <alltraps>

80107103 <vector235>:
.globl vector235
vector235:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $235
80107105:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010710a:	e9 05 f0 ff ff       	jmp    80106114 <alltraps>

8010710f <vector236>:
.globl vector236
vector236:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $236
80107111:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107116:	e9 f9 ef ff ff       	jmp    80106114 <alltraps>

8010711b <vector237>:
.globl vector237
vector237:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $237
8010711d:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107122:	e9 ed ef ff ff       	jmp    80106114 <alltraps>

80107127 <vector238>:
.globl vector238
vector238:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $238
80107129:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010712e:	e9 e1 ef ff ff       	jmp    80106114 <alltraps>

80107133 <vector239>:
.globl vector239
vector239:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $239
80107135:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010713a:	e9 d5 ef ff ff       	jmp    80106114 <alltraps>

8010713f <vector240>:
.globl vector240
vector240:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $240
80107141:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107146:	e9 c9 ef ff ff       	jmp    80106114 <alltraps>

8010714b <vector241>:
.globl vector241
vector241:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $241
8010714d:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107152:	e9 bd ef ff ff       	jmp    80106114 <alltraps>

80107157 <vector242>:
.globl vector242
vector242:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $242
80107159:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010715e:	e9 b1 ef ff ff       	jmp    80106114 <alltraps>

80107163 <vector243>:
.globl vector243
vector243:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $243
80107165:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010716a:	e9 a5 ef ff ff       	jmp    80106114 <alltraps>

8010716f <vector244>:
.globl vector244
vector244:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $244
80107171:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107176:	e9 99 ef ff ff       	jmp    80106114 <alltraps>

8010717b <vector245>:
.globl vector245
vector245:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $245
8010717d:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107182:	e9 8d ef ff ff       	jmp    80106114 <alltraps>

80107187 <vector246>:
.globl vector246
vector246:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $246
80107189:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010718e:	e9 81 ef ff ff       	jmp    80106114 <alltraps>

80107193 <vector247>:
.globl vector247
vector247:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $247
80107195:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010719a:	e9 75 ef ff ff       	jmp    80106114 <alltraps>

8010719f <vector248>:
.globl vector248
vector248:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $248
801071a1:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801071a6:	e9 69 ef ff ff       	jmp    80106114 <alltraps>

801071ab <vector249>:
.globl vector249
vector249:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $249
801071ad:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801071b2:	e9 5d ef ff ff       	jmp    80106114 <alltraps>

801071b7 <vector250>:
.globl vector250
vector250:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $250
801071b9:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801071be:	e9 51 ef ff ff       	jmp    80106114 <alltraps>

801071c3 <vector251>:
.globl vector251
vector251:
  pushl $0
801071c3:	6a 00                	push   $0x0
  pushl $251
801071c5:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801071ca:	e9 45 ef ff ff       	jmp    80106114 <alltraps>

801071cf <vector252>:
.globl vector252
vector252:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $252
801071d1:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801071d6:	e9 39 ef ff ff       	jmp    80106114 <alltraps>

801071db <vector253>:
.globl vector253
vector253:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $253
801071dd:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801071e2:	e9 2d ef ff ff       	jmp    80106114 <alltraps>

801071e7 <vector254>:
.globl vector254
vector254:
  pushl $0
801071e7:	6a 00                	push   $0x0
  pushl $254
801071e9:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801071ee:	e9 21 ef ff ff       	jmp    80106114 <alltraps>

801071f3 <vector255>:
.globl vector255
vector255:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $255
801071f5:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801071fa:	e9 15 ef ff ff       	jmp    80106114 <alltraps>

801071ff <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801071ff:	55                   	push   %ebp
80107200:	89 e5                	mov    %esp,%ebp
80107202:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107205:	8b 45 0c             	mov    0xc(%ebp),%eax
80107208:	83 e8 01             	sub    $0x1,%eax
8010720b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010720f:	8b 45 08             	mov    0x8(%ebp),%eax
80107212:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107216:	8b 45 08             	mov    0x8(%ebp),%eax
80107219:	c1 e8 10             	shr    $0x10,%eax
8010721c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107220:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107223:	0f 01 10             	lgdtl  (%eax)
}
80107226:	c9                   	leave  
80107227:	c3                   	ret    

80107228 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107228:	55                   	push   %ebp
80107229:	89 e5                	mov    %esp,%ebp
8010722b:	83 ec 04             	sub    $0x4,%esp
8010722e:	8b 45 08             	mov    0x8(%ebp),%eax
80107231:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107235:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107239:	0f 00 d8             	ltr    %ax
}
8010723c:	c9                   	leave  
8010723d:	c3                   	ret    

8010723e <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010723e:	55                   	push   %ebp
8010723f:	89 e5                	mov    %esp,%ebp
80107241:	83 ec 04             	sub    $0x4,%esp
80107244:	8b 45 08             	mov    0x8(%ebp),%eax
80107247:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010724b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010724f:	8e e8                	mov    %eax,%gs
}
80107251:	c9                   	leave  
80107252:	c3                   	ret    

80107253 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107253:	55                   	push   %ebp
80107254:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107256:	8b 45 08             	mov    0x8(%ebp),%eax
80107259:	0f 22 d8             	mov    %eax,%cr3
}
8010725c:	5d                   	pop    %ebp
8010725d:	c3                   	ret    

8010725e <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010725e:	55                   	push   %ebp
8010725f:	89 e5                	mov    %esp,%ebp
80107261:	8b 45 08             	mov    0x8(%ebp),%eax
80107264:	05 00 00 00 80       	add    $0x80000000,%eax
80107269:	5d                   	pop    %ebp
8010726a:	c3                   	ret    

8010726b <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010726b:	55                   	push   %ebp
8010726c:	89 e5                	mov    %esp,%ebp
8010726e:	8b 45 08             	mov    0x8(%ebp),%eax
80107271:	05 00 00 00 80       	add    $0x80000000,%eax
80107276:	5d                   	pop    %ebp
80107277:	c3                   	ret    

80107278 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107278:	55                   	push   %ebp
80107279:	89 e5                	mov    %esp,%ebp
8010727b:	53                   	push   %ebx
8010727c:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010727f:	e8 c3 bb ff ff       	call   80102e47 <cpunum>
80107284:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010728a:	05 20 f9 10 80       	add    $0x8010f920,%eax
8010728f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107295:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010729b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801072a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a7:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801072ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ae:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801072b2:	83 e2 f0             	and    $0xfffffff0,%edx
801072b5:	83 ca 0a             	or     $0xa,%edx
801072b8:	88 50 7d             	mov    %dl,0x7d(%eax)
801072bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072be:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801072c2:	83 ca 10             	or     $0x10,%edx
801072c5:	88 50 7d             	mov    %dl,0x7d(%eax)
801072c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072cb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801072cf:	83 e2 9f             	and    $0xffffff9f,%edx
801072d2:	88 50 7d             	mov    %dl,0x7d(%eax)
801072d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801072dc:	83 ca 80             	or     $0xffffff80,%edx
801072df:	88 50 7d             	mov    %dl,0x7d(%eax)
801072e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801072e9:	83 ca 0f             	or     $0xf,%edx
801072ec:	88 50 7e             	mov    %dl,0x7e(%eax)
801072ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801072f6:	83 e2 ef             	and    $0xffffffef,%edx
801072f9:	88 50 7e             	mov    %dl,0x7e(%eax)
801072fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ff:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107303:	83 e2 df             	and    $0xffffffdf,%edx
80107306:	88 50 7e             	mov    %dl,0x7e(%eax)
80107309:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010730c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107310:	83 ca 40             	or     $0x40,%edx
80107313:	88 50 7e             	mov    %dl,0x7e(%eax)
80107316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107319:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010731d:	83 ca 80             	or     $0xffffff80,%edx
80107320:	88 50 7e             	mov    %dl,0x7e(%eax)
80107323:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107326:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010732a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010732d:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107334:	ff ff 
80107336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107339:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107340:	00 00 
80107342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107345:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010734c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107356:	83 e2 f0             	and    $0xfffffff0,%edx
80107359:	83 ca 02             	or     $0x2,%edx
8010735c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107365:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010736c:	83 ca 10             	or     $0x10,%edx
8010736f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107378:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010737f:	83 e2 9f             	and    $0xffffff9f,%edx
80107382:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107392:	83 ca 80             	or     $0xffffff80,%edx
80107395:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010739b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801073a5:	83 ca 0f             	or     $0xf,%edx
801073a8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801073ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801073b8:	83 e2 ef             	and    $0xffffffef,%edx
801073bb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801073c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801073cb:	83 e2 df             	and    $0xffffffdf,%edx
801073ce:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801073d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801073de:	83 ca 40             	or     $0x40,%edx
801073e1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801073e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ea:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801073f1:	83 ca 80             	or     $0xffffff80,%edx
801073f4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801073fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073fd:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107404:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107407:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010740e:	ff ff 
80107410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107413:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010741a:	00 00 
8010741c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741f:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107429:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107430:	83 e2 f0             	and    $0xfffffff0,%edx
80107433:	83 ca 0a             	or     $0xa,%edx
80107436:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010743c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107446:	83 ca 10             	or     $0x10,%edx
80107449:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010744f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107452:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107459:	83 ca 60             	or     $0x60,%edx
8010745c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107465:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010746c:	83 ca 80             	or     $0xffffff80,%edx
8010746f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107478:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010747f:	83 ca 0f             	or     $0xf,%edx
80107482:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107492:	83 e2 ef             	and    $0xffffffef,%edx
80107495:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010749b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074a5:	83 e2 df             	and    $0xffffffdf,%edx
801074a8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074b8:	83 ca 40             	or     $0x40,%edx
801074bb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074cb:	83 ca 80             	or     $0xffffff80,%edx
801074ce:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d7:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801074de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e1:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801074e8:	ff ff 
801074ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ed:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801074f4:	00 00 
801074f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f9:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107503:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010750a:	83 e2 f0             	and    $0xfffffff0,%edx
8010750d:	83 ca 02             	or     $0x2,%edx
80107510:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107519:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107520:	83 ca 10             	or     $0x10,%edx
80107523:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107533:	83 ca 60             	or     $0x60,%edx
80107536:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010753c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107546:	83 ca 80             	or     $0xffffff80,%edx
80107549:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010754f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107552:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107559:	83 ca 0f             	or     $0xf,%edx
8010755c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107565:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010756c:	83 e2 ef             	and    $0xffffffef,%edx
8010756f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107578:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010757f:	83 e2 df             	and    $0xffffffdf,%edx
80107582:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107592:	83 ca 40             	or     $0x40,%edx
80107595:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010759b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801075a5:	83 ca 80             	or     $0xffffff80,%edx
801075a8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801075ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b1:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801075b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075bb:	05 b4 00 00 00       	add    $0xb4,%eax
801075c0:	89 c3                	mov    %eax,%ebx
801075c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c5:	05 b4 00 00 00       	add    $0xb4,%eax
801075ca:	c1 e8 10             	shr    $0x10,%eax
801075cd:	89 c1                	mov    %eax,%ecx
801075cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d2:	05 b4 00 00 00       	add    $0xb4,%eax
801075d7:	c1 e8 18             	shr    $0x18,%eax
801075da:	89 c2                	mov    %eax,%edx
801075dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075df:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801075e6:	00 00 
801075e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075eb:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801075f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f5:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
801075fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075fe:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107605:	83 e1 f0             	and    $0xfffffff0,%ecx
80107608:	83 c9 02             	or     $0x2,%ecx
8010760b:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107614:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010761b:	83 c9 10             	or     $0x10,%ecx
8010761e:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107627:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010762e:	83 e1 9f             	and    $0xffffff9f,%ecx
80107631:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763a:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107641:	83 c9 80             	or     $0xffffff80,%ecx
80107644:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010764a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764d:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107654:	83 e1 f0             	and    $0xfffffff0,%ecx
80107657:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010765d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107660:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107667:	83 e1 ef             	and    $0xffffffef,%ecx
8010766a:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107673:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010767a:	83 e1 df             	and    $0xffffffdf,%ecx
8010767d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107686:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010768d:	83 c9 40             	or     $0x40,%ecx
80107690:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107699:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801076a0:	83 c9 80             	or     $0xffffff80,%ecx
801076a3:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801076a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ac:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801076b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b5:	83 c0 70             	add    $0x70,%eax
801076b8:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
801076bf:	00 
801076c0:	89 04 24             	mov    %eax,(%esp)
801076c3:	e8 37 fb ff ff       	call   801071ff <lgdt>
  loadgs(SEG_KCPU << 3);
801076c8:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
801076cf:	e8 6a fb ff ff       	call   8010723e <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
801076d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d7:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801076dd:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801076e4:	00 00 00 00 
}
801076e8:	83 c4 24             	add    $0x24,%esp
801076eb:	5b                   	pop    %ebx
801076ec:	5d                   	pop    %ebp
801076ed:	c3                   	ret    

801076ee <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801076ee:	55                   	push   %ebp
801076ef:	89 e5                	mov    %esp,%ebp
801076f1:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801076f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801076f7:	c1 e8 16             	shr    $0x16,%eax
801076fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107701:	8b 45 08             	mov    0x8(%ebp),%eax
80107704:	01 d0                	add    %edx,%eax
80107706:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107709:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010770c:	8b 00                	mov    (%eax),%eax
8010770e:	83 e0 01             	and    $0x1,%eax
80107711:	85 c0                	test   %eax,%eax
80107713:	74 17                	je     8010772c <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107715:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107718:	8b 00                	mov    (%eax),%eax
8010771a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010771f:	89 04 24             	mov    %eax,(%esp)
80107722:	e8 44 fb ff ff       	call   8010726b <p2v>
80107727:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010772a:	eb 4b                	jmp    80107777 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010772c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107730:	74 0e                	je     80107740 <walkpgdir+0x52>
80107732:	e8 97 b3 ff ff       	call   80102ace <kalloc>
80107737:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010773a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010773e:	75 07                	jne    80107747 <walkpgdir+0x59>
      return 0;
80107740:	b8 00 00 00 00       	mov    $0x0,%eax
80107745:	eb 47                	jmp    8010778e <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107747:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010774e:	00 
8010774f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107756:	00 
80107757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775a:	89 04 24             	mov    %eax,(%esp)
8010775d:	e8 8d d5 ff ff       	call   80104cef <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107765:	89 04 24             	mov    %eax,(%esp)
80107768:	e8 f1 fa ff ff       	call   8010725e <v2p>
8010776d:	83 c8 07             	or     $0x7,%eax
80107770:	89 c2                	mov    %eax,%edx
80107772:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107775:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107777:	8b 45 0c             	mov    0xc(%ebp),%eax
8010777a:	c1 e8 0c             	shr    $0xc,%eax
8010777d:	25 ff 03 00 00       	and    $0x3ff,%eax
80107782:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778c:	01 d0                	add    %edx,%eax
}
8010778e:	c9                   	leave  
8010778f:	c3                   	ret    

80107790 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107790:	55                   	push   %ebp
80107791:	89 e5                	mov    %esp,%ebp
80107793:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107796:	8b 45 0c             	mov    0xc(%ebp),%eax
80107799:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010779e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801077a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801077a4:	8b 45 10             	mov    0x10(%ebp),%eax
801077a7:	01 d0                	add    %edx,%eax
801077a9:	83 e8 01             	sub    $0x1,%eax
801077ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801077b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801077bb:	00 
801077bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801077c3:	8b 45 08             	mov    0x8(%ebp),%eax
801077c6:	89 04 24             	mov    %eax,(%esp)
801077c9:	e8 20 ff ff ff       	call   801076ee <walkpgdir>
801077ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
801077d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801077d5:	75 07                	jne    801077de <mappages+0x4e>
      return -1;
801077d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077dc:	eb 48                	jmp    80107826 <mappages+0x96>
    if(*pte & PTE_P)
801077de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077e1:	8b 00                	mov    (%eax),%eax
801077e3:	83 e0 01             	and    $0x1,%eax
801077e6:	85 c0                	test   %eax,%eax
801077e8:	74 0c                	je     801077f6 <mappages+0x66>
      panic("remap");
801077ea:	c7 04 24 10 86 10 80 	movl   $0x80108610,(%esp)
801077f1:	e8 44 8d ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
801077f6:	8b 45 18             	mov    0x18(%ebp),%eax
801077f9:	0b 45 14             	or     0x14(%ebp),%eax
801077fc:	83 c8 01             	or     $0x1,%eax
801077ff:	89 c2                	mov    %eax,%edx
80107801:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107804:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107809:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010780c:	75 08                	jne    80107816 <mappages+0x86>
      break;
8010780e:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010780f:	b8 00 00 00 00       	mov    $0x0,%eax
80107814:	eb 10                	jmp    80107826 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107816:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010781d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107824:	eb 8e                	jmp    801077b4 <mappages+0x24>
  return 0;
}
80107826:	c9                   	leave  
80107827:	c3                   	ret    

80107828 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107828:	55                   	push   %ebp
80107829:	89 e5                	mov    %esp,%ebp
8010782b:	53                   	push   %ebx
8010782c:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010782f:	e8 9a b2 ff ff       	call   80102ace <kalloc>
80107834:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107837:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010783b:	75 0a                	jne    80107847 <setupkvm+0x1f>
    return 0;
8010783d:	b8 00 00 00 00       	mov    $0x0,%eax
80107842:	e9 98 00 00 00       	jmp    801078df <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107847:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010784e:	00 
8010784f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107856:	00 
80107857:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010785a:	89 04 24             	mov    %eax,(%esp)
8010785d:	e8 8d d4 ff ff       	call   80104cef <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107862:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107869:	e8 fd f9 ff ff       	call   8010726b <p2v>
8010786e:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107873:	76 0c                	jbe    80107881 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107875:	c7 04 24 16 86 10 80 	movl   $0x80108616,(%esp)
8010787c:	e8 b9 8c ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107881:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107888:	eb 49                	jmp    801078d3 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010788a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788d:	8b 48 0c             	mov    0xc(%eax),%ecx
80107890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107893:	8b 50 04             	mov    0x4(%eax),%edx
80107896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107899:	8b 58 08             	mov    0x8(%eax),%ebx
8010789c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789f:	8b 40 04             	mov    0x4(%eax),%eax
801078a2:	29 c3                	sub    %eax,%ebx
801078a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a7:	8b 00                	mov    (%eax),%eax
801078a9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801078ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
801078b1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801078b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801078b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078bc:	89 04 24             	mov    %eax,(%esp)
801078bf:	e8 cc fe ff ff       	call   80107790 <mappages>
801078c4:	85 c0                	test   %eax,%eax
801078c6:	79 07                	jns    801078cf <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801078c8:	b8 00 00 00 00       	mov    $0x0,%eax
801078cd:	eb 10                	jmp    801078df <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078cf:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801078d3:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
801078da:	72 ae                	jb     8010788a <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801078dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801078df:	83 c4 34             	add    $0x34,%esp
801078e2:	5b                   	pop    %ebx
801078e3:	5d                   	pop    %ebp
801078e4:	c3                   	ret    

801078e5 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801078e5:	55                   	push   %ebp
801078e6:	89 e5                	mov    %esp,%ebp
801078e8:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801078eb:	e8 38 ff ff ff       	call   80107828 <setupkvm>
801078f0:	a3 f8 44 11 80       	mov    %eax,0x801144f8
  switchkvm();
801078f5:	e8 02 00 00 00       	call   801078fc <switchkvm>
}
801078fa:	c9                   	leave  
801078fb:	c3                   	ret    

801078fc <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801078fc:	55                   	push   %ebp
801078fd:	89 e5                	mov    %esp,%ebp
801078ff:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107902:	a1 f8 44 11 80       	mov    0x801144f8,%eax
80107907:	89 04 24             	mov    %eax,(%esp)
8010790a:	e8 4f f9 ff ff       	call   8010725e <v2p>
8010790f:	89 04 24             	mov    %eax,(%esp)
80107912:	e8 3c f9 ff ff       	call   80107253 <lcr3>
}
80107917:	c9                   	leave  
80107918:	c3                   	ret    

80107919 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107919:	55                   	push   %ebp
8010791a:	89 e5                	mov    %esp,%ebp
8010791c:	53                   	push   %ebx
8010791d:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107920:	e8 ca d2 ff ff       	call   80104bef <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107925:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010792b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107932:	83 c2 08             	add    $0x8,%edx
80107935:	89 d3                	mov    %edx,%ebx
80107937:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010793e:	83 c2 08             	add    $0x8,%edx
80107941:	c1 ea 10             	shr    $0x10,%edx
80107944:	89 d1                	mov    %edx,%ecx
80107946:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010794d:	83 c2 08             	add    $0x8,%edx
80107950:	c1 ea 18             	shr    $0x18,%edx
80107953:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010795a:	67 00 
8010795c:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107963:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107969:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107970:	83 e1 f0             	and    $0xfffffff0,%ecx
80107973:	83 c9 09             	or     $0x9,%ecx
80107976:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010797c:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107983:	83 c9 10             	or     $0x10,%ecx
80107986:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010798c:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107993:	83 e1 9f             	and    $0xffffff9f,%ecx
80107996:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010799c:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801079a3:	83 c9 80             	or     $0xffffff80,%ecx
801079a6:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801079ac:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801079b3:	83 e1 f0             	and    $0xfffffff0,%ecx
801079b6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801079bc:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801079c3:	83 e1 ef             	and    $0xffffffef,%ecx
801079c6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801079cc:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801079d3:	83 e1 df             	and    $0xffffffdf,%ecx
801079d6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801079dc:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801079e3:	83 c9 40             	or     $0x40,%ecx
801079e6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801079ec:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801079f3:	83 e1 7f             	and    $0x7f,%ecx
801079f6:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801079fc:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107a02:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a08:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107a0f:	83 e2 ef             	and    $0xffffffef,%edx
80107a12:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107a18:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a1e:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107a24:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a2a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107a31:	8b 52 08             	mov    0x8(%edx),%edx
80107a34:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107a3a:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107a3d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107a44:	e8 df f7 ff ff       	call   80107228 <ltr>
  if(p->pgdir == 0)
80107a49:	8b 45 08             	mov    0x8(%ebp),%eax
80107a4c:	8b 40 04             	mov    0x4(%eax),%eax
80107a4f:	85 c0                	test   %eax,%eax
80107a51:	75 0c                	jne    80107a5f <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107a53:	c7 04 24 27 86 10 80 	movl   $0x80108627,(%esp)
80107a5a:	e8 db 8a ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80107a62:	8b 40 04             	mov    0x4(%eax),%eax
80107a65:	89 04 24             	mov    %eax,(%esp)
80107a68:	e8 f1 f7 ff ff       	call   8010725e <v2p>
80107a6d:	89 04 24             	mov    %eax,(%esp)
80107a70:	e8 de f7 ff ff       	call   80107253 <lcr3>
  popcli();
80107a75:	e8 b9 d1 ff ff       	call   80104c33 <popcli>
}
80107a7a:	83 c4 14             	add    $0x14,%esp
80107a7d:	5b                   	pop    %ebx
80107a7e:	5d                   	pop    %ebp
80107a7f:	c3                   	ret    

80107a80 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107a80:	55                   	push   %ebp
80107a81:	89 e5                	mov    %esp,%ebp
80107a83:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107a86:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107a8d:	76 0c                	jbe    80107a9b <inituvm+0x1b>
    panic("inituvm: more than a page");
80107a8f:	c7 04 24 3b 86 10 80 	movl   $0x8010863b,(%esp)
80107a96:	e8 9f 8a ff ff       	call   8010053a <panic>
  mem = kalloc();
80107a9b:	e8 2e b0 ff ff       	call   80102ace <kalloc>
80107aa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107aa3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107aaa:	00 
80107aab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ab2:	00 
80107ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab6:	89 04 24             	mov    %eax,(%esp)
80107ab9:	e8 31 d2 ff ff       	call   80104cef <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac1:	89 04 24             	mov    %eax,(%esp)
80107ac4:	e8 95 f7 ff ff       	call   8010725e <v2p>
80107ac9:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107ad0:	00 
80107ad1:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107ad5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107adc:	00 
80107add:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ae4:	00 
80107ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80107ae8:	89 04 24             	mov    %eax,(%esp)
80107aeb:	e8 a0 fc ff ff       	call   80107790 <mappages>
  memmove(mem, init, sz);
80107af0:	8b 45 10             	mov    0x10(%ebp),%eax
80107af3:	89 44 24 08          	mov    %eax,0x8(%esp)
80107af7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107afa:	89 44 24 04          	mov    %eax,0x4(%esp)
80107afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b01:	89 04 24             	mov    %eax,(%esp)
80107b04:	e8 b5 d2 ff ff       	call   80104dbe <memmove>
}
80107b09:	c9                   	leave  
80107b0a:	c3                   	ret    

80107b0b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107b0b:	55                   	push   %ebp
80107b0c:	89 e5                	mov    %esp,%ebp
80107b0e:	53                   	push   %ebx
80107b0f:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107b12:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b15:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b1a:	85 c0                	test   %eax,%eax
80107b1c:	74 0c                	je     80107b2a <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107b1e:	c7 04 24 58 86 10 80 	movl   $0x80108658,(%esp)
80107b25:	e8 10 8a ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107b2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b31:	e9 a9 00 00 00       	jmp    80107bdf <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b39:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b3c:	01 d0                	add    %edx,%eax
80107b3e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107b45:	00 
80107b46:	89 44 24 04          	mov    %eax,0x4(%esp)
80107b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80107b4d:	89 04 24             	mov    %eax,(%esp)
80107b50:	e8 99 fb ff ff       	call   801076ee <walkpgdir>
80107b55:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b58:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b5c:	75 0c                	jne    80107b6a <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80107b5e:	c7 04 24 7b 86 10 80 	movl   $0x8010867b,(%esp)
80107b65:	e8 d0 89 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80107b6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b6d:	8b 00                	mov    (%eax),%eax
80107b6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b74:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7a:	8b 55 18             	mov    0x18(%ebp),%edx
80107b7d:	29 c2                	sub    %eax,%edx
80107b7f:	89 d0                	mov    %edx,%eax
80107b81:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107b86:	77 0f                	ja     80107b97 <loaduvm+0x8c>
      n = sz - i;
80107b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8b:	8b 55 18             	mov    0x18(%ebp),%edx
80107b8e:	29 c2                	sub    %eax,%edx
80107b90:	89 d0                	mov    %edx,%eax
80107b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b95:	eb 07                	jmp    80107b9e <loaduvm+0x93>
    else
      n = PGSIZE;
80107b97:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba1:	8b 55 14             	mov    0x14(%ebp),%edx
80107ba4:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107ba7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107baa:	89 04 24             	mov    %eax,(%esp)
80107bad:	e8 b9 f6 ff ff       	call   8010726b <p2v>
80107bb2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107bb5:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107bb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107bbd:	89 44 24 04          	mov    %eax,0x4(%esp)
80107bc1:	8b 45 10             	mov    0x10(%ebp),%eax
80107bc4:	89 04 24             	mov    %eax,(%esp)
80107bc7:	e8 88 a1 ff ff       	call   80101d54 <readi>
80107bcc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107bcf:	74 07                	je     80107bd8 <loaduvm+0xcd>
      return -1;
80107bd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bd6:	eb 18                	jmp    80107bf0 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107bd8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be2:	3b 45 18             	cmp    0x18(%ebp),%eax
80107be5:	0f 82 4b ff ff ff    	jb     80107b36 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107beb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107bf0:	83 c4 24             	add    $0x24,%esp
80107bf3:	5b                   	pop    %ebx
80107bf4:	5d                   	pop    %ebp
80107bf5:	c3                   	ret    

80107bf6 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107bf6:	55                   	push   %ebp
80107bf7:	89 e5                	mov    %esp,%ebp
80107bf9:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107bfc:	8b 45 10             	mov    0x10(%ebp),%eax
80107bff:	85 c0                	test   %eax,%eax
80107c01:	79 0a                	jns    80107c0d <allocuvm+0x17>
    return 0;
80107c03:	b8 00 00 00 00       	mov    $0x0,%eax
80107c08:	e9 c1 00 00 00       	jmp    80107cce <allocuvm+0xd8>
  if(newsz < oldsz)
80107c0d:	8b 45 10             	mov    0x10(%ebp),%eax
80107c10:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c13:	73 08                	jae    80107c1d <allocuvm+0x27>
    return oldsz;
80107c15:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c18:	e9 b1 00 00 00       	jmp    80107cce <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80107c1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c20:	05 ff 0f 00 00       	add    $0xfff,%eax
80107c25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107c2d:	e9 8d 00 00 00       	jmp    80107cbf <allocuvm+0xc9>
    mem = kalloc();
80107c32:	e8 97 ae ff ff       	call   80102ace <kalloc>
80107c37:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107c3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c3e:	75 2c                	jne    80107c6c <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80107c40:	c7 04 24 99 86 10 80 	movl   $0x80108699,(%esp)
80107c47:	e8 54 87 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107c4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c4f:	89 44 24 08          	mov    %eax,0x8(%esp)
80107c53:	8b 45 10             	mov    0x10(%ebp),%eax
80107c56:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80107c5d:	89 04 24             	mov    %eax,(%esp)
80107c60:	e8 6b 00 00 00       	call   80107cd0 <deallocuvm>
      return 0;
80107c65:	b8 00 00 00 00       	mov    $0x0,%eax
80107c6a:	eb 62                	jmp    80107cce <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80107c6c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c73:	00 
80107c74:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c7b:	00 
80107c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c7f:	89 04 24             	mov    %eax,(%esp)
80107c82:	e8 68 d0 ff ff       	call   80104cef <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c8a:	89 04 24             	mov    %eax,(%esp)
80107c8d:	e8 cc f5 ff ff       	call   8010725e <v2p>
80107c92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c95:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107c9c:	00 
80107c9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107ca1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ca8:	00 
80107ca9:	89 54 24 04          	mov    %edx,0x4(%esp)
80107cad:	8b 45 08             	mov    0x8(%ebp),%eax
80107cb0:	89 04 24             	mov    %eax,(%esp)
80107cb3:	e8 d8 fa ff ff       	call   80107790 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80107cb8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc2:	3b 45 10             	cmp    0x10(%ebp),%eax
80107cc5:	0f 82 67 ff ff ff    	jb     80107c32 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80107ccb:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107cce:	c9                   	leave  
80107ccf:	c3                   	ret    

80107cd0 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107cd0:	55                   	push   %ebp
80107cd1:	89 e5                	mov    %esp,%ebp
80107cd3:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107cd6:	8b 45 10             	mov    0x10(%ebp),%eax
80107cd9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107cdc:	72 08                	jb     80107ce6 <deallocuvm+0x16>
    return oldsz;
80107cde:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ce1:	e9 a4 00 00 00       	jmp    80107d8a <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80107ce6:	8b 45 10             	mov    0x10(%ebp),%eax
80107ce9:	05 ff 0f 00 00       	add    $0xfff,%eax
80107cee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107cf6:	e9 80 00 00 00       	jmp    80107d7b <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107d05:	00 
80107d06:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80107d0d:	89 04 24             	mov    %eax,(%esp)
80107d10:	e8 d9 f9 ff ff       	call   801076ee <walkpgdir>
80107d15:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107d18:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d1c:	75 09                	jne    80107d27 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80107d1e:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80107d25:	eb 4d                	jmp    80107d74 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80107d27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d2a:	8b 00                	mov    (%eax),%eax
80107d2c:	83 e0 01             	and    $0x1,%eax
80107d2f:	85 c0                	test   %eax,%eax
80107d31:	74 41                	je     80107d74 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80107d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d36:	8b 00                	mov    (%eax),%eax
80107d38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107d40:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d44:	75 0c                	jne    80107d52 <deallocuvm+0x82>
        panic("kfree");
80107d46:	c7 04 24 b1 86 10 80 	movl   $0x801086b1,(%esp)
80107d4d:	e8 e8 87 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80107d52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d55:	89 04 24             	mov    %eax,(%esp)
80107d58:	e8 0e f5 ff ff       	call   8010726b <p2v>
80107d5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107d60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d63:	89 04 24             	mov    %eax,(%esp)
80107d66:	e8 ca ac ff ff       	call   80102a35 <kfree>
      *pte = 0;
80107d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d6e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80107d74:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d81:	0f 82 74 ff ff ff    	jb     80107cfb <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80107d87:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d8a:	c9                   	leave  
80107d8b:	c3                   	ret    

80107d8c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107d8c:	55                   	push   %ebp
80107d8d:	89 e5                	mov    %esp,%ebp
80107d8f:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80107d92:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107d96:	75 0c                	jne    80107da4 <freevm+0x18>
    panic("freevm: no pgdir");
80107d98:	c7 04 24 b7 86 10 80 	movl   $0x801086b7,(%esp)
80107d9f:	e8 96 87 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107da4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107dab:	00 
80107dac:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80107db3:	80 
80107db4:	8b 45 08             	mov    0x8(%ebp),%eax
80107db7:	89 04 24             	mov    %eax,(%esp)
80107dba:	e8 11 ff ff ff       	call   80107cd0 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80107dbf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107dc6:	eb 48                	jmp    80107e10 <freevm+0x84>
    if(pgdir[i] & PTE_P){
80107dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80107dd5:	01 d0                	add    %edx,%eax
80107dd7:	8b 00                	mov    (%eax),%eax
80107dd9:	83 e0 01             	and    $0x1,%eax
80107ddc:	85 c0                	test   %eax,%eax
80107dde:	74 2c                	je     80107e0c <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80107de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dea:	8b 45 08             	mov    0x8(%ebp),%eax
80107ded:	01 d0                	add    %edx,%eax
80107def:	8b 00                	mov    (%eax),%eax
80107df1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107df6:	89 04 24             	mov    %eax,(%esp)
80107df9:	e8 6d f4 ff ff       	call   8010726b <p2v>
80107dfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e04:	89 04 24             	mov    %eax,(%esp)
80107e07:	e8 29 ac ff ff       	call   80102a35 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107e0c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e10:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107e17:	76 af                	jbe    80107dc8 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80107e19:	8b 45 08             	mov    0x8(%ebp),%eax
80107e1c:	89 04 24             	mov    %eax,(%esp)
80107e1f:	e8 11 ac ff ff       	call   80102a35 <kfree>
}
80107e24:	c9                   	leave  
80107e25:	c3                   	ret    

80107e26 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107e26:	55                   	push   %ebp
80107e27:	89 e5                	mov    %esp,%ebp
80107e29:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e2c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107e33:	00 
80107e34:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e37:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e3b:	8b 45 08             	mov    0x8(%ebp),%eax
80107e3e:	89 04 24             	mov    %eax,(%esp)
80107e41:	e8 a8 f8 ff ff       	call   801076ee <walkpgdir>
80107e46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107e49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e4d:	75 0c                	jne    80107e5b <clearpteu+0x35>
    panic("clearpteu");
80107e4f:	c7 04 24 c8 86 10 80 	movl   $0x801086c8,(%esp)
80107e56:	e8 df 86 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
80107e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5e:	8b 00                	mov    (%eax),%eax
80107e60:	83 e0 fb             	and    $0xfffffffb,%eax
80107e63:	89 c2                	mov    %eax,%edx
80107e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e68:	89 10                	mov    %edx,(%eax)
}
80107e6a:	c9                   	leave  
80107e6b:	c3                   	ret    

80107e6c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107e6c:	55                   	push   %ebp
80107e6d:	89 e5                	mov    %esp,%ebp
80107e6f:	53                   	push   %ebx
80107e70:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107e73:	e8 b0 f9 ff ff       	call   80107828 <setupkvm>
80107e78:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e7f:	75 0a                	jne    80107e8b <copyuvm+0x1f>
    return 0;
80107e81:	b8 00 00 00 00       	mov    $0x0,%eax
80107e86:	e9 fd 00 00 00       	jmp    80107f88 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80107e8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e92:	e9 d0 00 00 00       	jmp    80107f67 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107ea1:	00 
80107ea2:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80107ea9:	89 04 24             	mov    %eax,(%esp)
80107eac:	e8 3d f8 ff ff       	call   801076ee <walkpgdir>
80107eb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107eb4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107eb8:	75 0c                	jne    80107ec6 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80107eba:	c7 04 24 d2 86 10 80 	movl   $0x801086d2,(%esp)
80107ec1:	e8 74 86 ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
80107ec6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ec9:	8b 00                	mov    (%eax),%eax
80107ecb:	83 e0 01             	and    $0x1,%eax
80107ece:	85 c0                	test   %eax,%eax
80107ed0:	75 0c                	jne    80107ede <copyuvm+0x72>
      panic("copyuvm: page not present");
80107ed2:	c7 04 24 ec 86 10 80 	movl   $0x801086ec,(%esp)
80107ed9:	e8 5c 86 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80107ede:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ee1:	8b 00                	mov    (%eax),%eax
80107ee3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ee8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107eeb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eee:	8b 00                	mov    (%eax),%eax
80107ef0:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ef5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107ef8:	e8 d1 ab ff ff       	call   80102ace <kalloc>
80107efd:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107f00:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107f04:	75 02                	jne    80107f08 <copyuvm+0x9c>
      goto bad;
80107f06:	eb 70                	jmp    80107f78 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80107f08:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f0b:	89 04 24             	mov    %eax,(%esp)
80107f0e:	e8 58 f3 ff ff       	call   8010726b <p2v>
80107f13:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f1a:	00 
80107f1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f22:	89 04 24             	mov    %eax,(%esp)
80107f25:	e8 94 ce ff ff       	call   80104dbe <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80107f2a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80107f2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f30:	89 04 24             	mov    %eax,(%esp)
80107f33:	e8 26 f3 ff ff       	call   8010725e <v2p>
80107f38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f3b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80107f3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107f43:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f4a:	00 
80107f4b:	89 54 24 04          	mov    %edx,0x4(%esp)
80107f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f52:	89 04 24             	mov    %eax,(%esp)
80107f55:	e8 36 f8 ff ff       	call   80107790 <mappages>
80107f5a:	85 c0                	test   %eax,%eax
80107f5c:	79 02                	jns    80107f60 <copyuvm+0xf4>
      goto bad;
80107f5e:	eb 18                	jmp    80107f78 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80107f60:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f6d:	0f 82 24 ff ff ff    	jb     80107e97 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80107f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f76:	eb 10                	jmp    80107f88 <copyuvm+0x11c>

bad:
  freevm(d);
80107f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f7b:	89 04 24             	mov    %eax,(%esp)
80107f7e:	e8 09 fe ff ff       	call   80107d8c <freevm>
  return 0;
80107f83:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f88:	83 c4 44             	add    $0x44,%esp
80107f8b:	5b                   	pop    %ebx
80107f8c:	5d                   	pop    %ebp
80107f8d:	c3                   	ret    

80107f8e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107f8e:	55                   	push   %ebp
80107f8f:	89 e5                	mov    %esp,%ebp
80107f91:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f94:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f9b:	00 
80107f9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80107fa6:	89 04 24             	mov    %eax,(%esp)
80107fa9:	e8 40 f7 ff ff       	call   801076ee <walkpgdir>
80107fae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb4:	8b 00                	mov    (%eax),%eax
80107fb6:	83 e0 01             	and    $0x1,%eax
80107fb9:	85 c0                	test   %eax,%eax
80107fbb:	75 07                	jne    80107fc4 <uva2ka+0x36>
    return 0;
80107fbd:	b8 00 00 00 00       	mov    $0x0,%eax
80107fc2:	eb 25                	jmp    80107fe9 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80107fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc7:	8b 00                	mov    (%eax),%eax
80107fc9:	83 e0 04             	and    $0x4,%eax
80107fcc:	85 c0                	test   %eax,%eax
80107fce:	75 07                	jne    80107fd7 <uva2ka+0x49>
    return 0;
80107fd0:	b8 00 00 00 00       	mov    $0x0,%eax
80107fd5:	eb 12                	jmp    80107fe9 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80107fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fda:	8b 00                	mov    (%eax),%eax
80107fdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fe1:	89 04 24             	mov    %eax,(%esp)
80107fe4:	e8 82 f2 ff ff       	call   8010726b <p2v>
}
80107fe9:	c9                   	leave  
80107fea:	c3                   	ret    

80107feb <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107feb:	55                   	push   %ebp
80107fec:	89 e5                	mov    %esp,%ebp
80107fee:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107ff1:	8b 45 10             	mov    0x10(%ebp),%eax
80107ff4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107ff7:	e9 87 00 00 00       	jmp    80108083 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80107ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108004:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108007:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010800a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010800e:	8b 45 08             	mov    0x8(%ebp),%eax
80108011:	89 04 24             	mov    %eax,(%esp)
80108014:	e8 75 ff ff ff       	call   80107f8e <uva2ka>
80108019:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010801c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108020:	75 07                	jne    80108029 <copyout+0x3e>
      return -1;
80108022:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108027:	eb 69                	jmp    80108092 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108029:	8b 45 0c             	mov    0xc(%ebp),%eax
8010802c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010802f:	29 c2                	sub    %eax,%edx
80108031:	89 d0                	mov    %edx,%eax
80108033:	05 00 10 00 00       	add    $0x1000,%eax
80108038:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010803b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010803e:	3b 45 14             	cmp    0x14(%ebp),%eax
80108041:	76 06                	jbe    80108049 <copyout+0x5e>
      n = len;
80108043:	8b 45 14             	mov    0x14(%ebp),%eax
80108046:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108049:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010804c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010804f:	29 c2                	sub    %eax,%edx
80108051:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108054:	01 c2                	add    %eax,%edx
80108056:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108059:	89 44 24 08          	mov    %eax,0x8(%esp)
8010805d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108060:	89 44 24 04          	mov    %eax,0x4(%esp)
80108064:	89 14 24             	mov    %edx,(%esp)
80108067:	e8 52 cd ff ff       	call   80104dbe <memmove>
    len -= n;
8010806c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010806f:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108075:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108078:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010807b:	05 00 10 00 00       	add    $0x1000,%eax
80108080:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108083:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108087:	0f 85 6f ff ff ff    	jne    80107ffc <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010808d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108092:	c9                   	leave  
80108093:	c3                   	ret    
