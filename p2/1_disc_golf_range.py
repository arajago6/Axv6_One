from threading import Thread, Semaphore
from time import sleep
import sys
import random
rng = random.Random()
rng.seed(100)	

def frolfer_routine(FId):
    global StashSize
    global DiscOnField
    global DiscPrBucket

    while True:
        sleep(rng.random()*10)     
        mutex.acquire()
        print ('Frolfer %d is calling for bucket' % FId)
     
        if StashSize < DiscPrBucket:
            cart_block_sem.release()
            frolf_barr_sem.acquire()
        StashSize -= DiscPrBucket
        print ('Frolfer %d got %d discs; Stash = %d' % (FId,DiscPrBucket,StashSize))
        mutex.release()
        
        
        disk_iter_sem.acquire()
        disk_iter_sem.release()
        for i in range(DiscPrBucket):
            sleep(rng.random())
            DiscOnField += 1
            print ('Frolfer %d threw disc %d' % (FId,i))
        
def cart_routine():
    global DiscPrBucket
    global StashSize
    global DiscOnField
    while True:
        cart_block_sem.acquire()
        disk_iter_sem.acquire()
        
        sleep(rng.random())
        print ('###############################################################')
        print ('StashSize = %d; Cart entering field' % StashSize)
        StashSize += DiscOnField
        print ('Cart done, gathered %d DiscPrBucket; StashSize = %d' % (DiscOnField,StashSize))
        print ('###############################################################')
        DiscOnField = 0
        frolf_barr_sem.release()
        disk_iter_sem.release()



mutex, disk_iter_sem = Semaphore(1), Semaphore(1)
frolf_barr_sem, cart_block_sem = Semaphore(0), Semaphore(0)
DiscOnField = 0
arg_list = []
FCount, StashSize, DiscPrBucket = 0, 0, 0

for arg in sys.argv:
    arg_list.append(arg)

if len(arg_list) == 4:

    FCount = int(arg_list[1])
    StashSize = int(arg_list[2])
    DiscPrBucket = int(arg_list[3])

    print ("Running disc thrower simulation: %d frolfers, stash size of %d and %d discs per bucket " % (FCount,StashSize,DiscPrBucket))
    fthrds = [Thread(target=frolfer_routine, args=[i]) for i in range(FCount)]
    for t in fthrds: t.start()

    crtthrd = Thread(target=cart_routine)
    crtthrd.start()

else:
    print ("EXITED with ERROR: Incorrect argument count. Only 2 arguments are allowed.\nUsage:python filename frolfer_count stash_size discs_per_bucket")