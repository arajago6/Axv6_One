from threading import Thread, Semaphore
from collections import deque
from time import sleep
import itertools
import sys	
import random
rng = random.Random()
rng.seed(100)

mutex_local = Semaphore(1)
floor_sem, runnable_sem = Semaphore(0), Semaphore(0)

FIDKeeper, LIDKeeper = deque(), deque()
LdrCount, FlrCount, DncrCount = 0, 0, 0

class FIFOQCreator:
    def __init__(self):
        self.queue = deque()
        self.mutex = Semaphore(1)
        
    def class_wait(self, thread_local_sem):
        self.mutex.acquire()
        self.queue.append(thread_local_sem)
        self.mutex.release()
        thread_local_sem.acquire()
        
    def class_signal(self):
        self.mutex.acquire()
        sem = self.queue.popleft()		
        self.mutex.release()
        sem.release()

def bandleader_routine():
    for music in itertools.cycle(['waltz', 'tango', 'foxtrot']):
        start_music(music)
        sleep(5)
        end_music(music)

def start_music(music):
    print("** Band leader started playing %s **" %(music))
    floor_sem.release()
    runnable_sem.release()

def end_music(music):
    runnable_sem.acquire()
    floor_sem.acquire()
    sleep(2)
    print("** Band leader stopped playing %s **" %(music))

def enter_floor(DId, DNat):
    global DncrCount
    print("%s %s entering floor." %(DNat, DId))
    mutex_local.acquire()
    DncrCount += 1
    if DncrCount is 1:
        floor_sem.acquire()
    mutex_local.release()

def line_up(DId, DNat):
    global DncrCount
    print("%s %s getting back in line." %(DNat, DId))
    mutex_local.acquire()
    DncrCount -= 1
    if DncrCount is 0:
        floor_sem.release()
    mutex_local.release()

def dance(LdrId, FlrId):
    if (LdrId != -1) and (FlrId != -1):
        print("Leader %s and Follower %s are dancing." %(LdrId, FlrId))

def leader_routine(LdrId):
    global LdrCount, FlrCount, DncrCount

    FlrId, DNat = -1, 'Leader'
    thread_local_sem = Semaphore(0)

    while True: 
        runnable_sem.acquire()
        runnable_sem.release()
        sleep(rng.random()*3)

        mutex_local.acquire()
        if FlrCount > 0:
            FlrCount -= 1
            FlrQueueObj.class_signal()
            FlrId = FIDKeeper.popleft();
            mutex_local.release()
        else:
            LdrCount += 1
            LIDKeeper.append(LdrId)
            mutex_local.release()
            LdrQueueObj.class_wait(thread_local_sem)
        
        enter_floor(LdrId, DNat)
        dance(LdrId, FlrId)
        sleep(2)
        line_up(LdrId, DNat)

        
def follower_routine(FlrId):
    global LdrCount, FlrCount, DncrCount

    LdrId, DNat = -1, 'Follower'
    thread_local_sem = Semaphore(0)

    while True:
        runnable_sem.acquire()
        runnable_sem.release()
        sleep(rng.random()*3)

        mutex_local.acquire()
        if LdrCount > 0:
            LdrCount -= 1
            LdrQueueObj.class_signal()
            LdrId = LIDKeeper.popleft()
            mutex_local.release()
        else:
            FlrCount += 1
            FIDKeeper.append(FlrId)
            mutex_local.release()
            FlrQueueObj.class_wait(thread_local_sem)
        enter_floor(FlrId, DNat)
        dance(LdrId, FlrId) 
        sleep(5)
        line_up(FlrId, DNat)    
    


LdrQueueObj = FIFOQCreator()
FlrQueueObj = FIFOQCreator()
arg_list = []
InLdrCount, InFlrCount = 0, 0

for arg in sys.argv:
    arg_list.append(arg)

if len(arg_list) == 3:

    InLdrCount = int(arg_list[1])
    InFlrCount = int(arg_list[2])

    print ("Running dance mixer simulation: %d leaders and %d followers" % (InLdrCount,InFlrCount))
    lthrds = [Thread(target=leader_routine, args=[i]) for i in range(InLdrCount)]
    for lt in lthrds: lt.start()

    fthrds = [Thread(target=follower_routine, args=[i]) for i in range(InFlrCount)]
    for ft in fthrds: ft.start()

    for music in itertools.cycle(['waltz', 'tango', 'foxtrot']):
        bandleader_routine()

else:
    print ("EXITED with ERROR: Incorrect argument count. Only 2 arguments are allowed.\nUsage:python filename leader_count follower_count")
