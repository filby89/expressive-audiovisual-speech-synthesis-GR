#ifndef semaphore_h
#define semaphore_h

#ifdef _WIN32

class Semaphore {
 public: 
    Semaphore() : locked(false) {}
    void lock() {
	while (locked) {
	 //   usleep(usecs);
	 //   printf("\nSemaphore!!");
	}
	locked = true;
    }
    void un_lock() {
	locked = false;
    }
 private:
    bool locked;
    unsigned int usecs;
};

#else

#include <unistd.h>

class Semaphore {
 public: 
    Semaphore() : locked(false), usecs(100) {}
    void lock() {
	while (locked) {
	    usleep(usecs);
	    printf("\nSemaphore!!");
	}
	locked = true;
    }
    void un_lock() {
	locked = false;
    }
 private:
    bool locked;
    unsigned int usecs;
};

#endif


#endif
