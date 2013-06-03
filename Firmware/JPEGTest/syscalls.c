#include <stdio.h>
#include <errno.h>
#include <sys/stat.h>

#include "malloc.h"
#include "fileio.h"

#include "small_printf.h"


#define SYS_ftruncate 3000
#define SYS_isatty 3001

/* Set to 1 if we are running on hardware. The config instruction is 
 * always emulated on the simulator. The emulation code pokes this 
 * variable to 1.
 */
extern int _hardware;

/* _cpu_config==0 => Abel
 * _cpu_config==1 => Zeta
 * _cpu_config==2 => Phi
 */
extern int _cpu_config;

extern int main(int argc, char **argv);

static char *args[]={"dummy.exe"};

// FIXME - bring these in.
extern void _init(void);
void _initIO(void);

extern char _end; // Defined by the linker script
char *heap_ptr;

void __attribute__ ((weak)) _premain()  
{
	int t;
//	_initIO();
	printf("_end is %d, RAMTOP is %d\n",&_end,RAMTOP);
	malloc_add(&_end,(char *)RAMTOP-&_end);	// Add the entire RAM to the free memory pool
	_init();
	t=main(1, args);
	exit(t);
	for (;;);
}

// Re-implement sbrk, since the libgloss version doesn't know about our memory map.
char *_sbrk(int nbytes)
{
	// Since we add the entire memory in _premain() we can skip this.
	printf("Custom sbrk asking for %d bytes\n",nbytes);
	return(0);

	char *base;

	if (!heap_ptr)
		heap_ptr = (char *)&_end;
	base = heap_ptr;

	heap_ptr += nbytes;

	if ((int)heap_ptr>RAMTOP)
		return (char *)-1;

	return base;
}

/* NOTE!!!! compiled with -fomit-frame-pointer to make sure that 'status' has the
 * correct value when breakpointing at _exit
 */
void __attribute__ ((weak)) _exit (int status)  
{
	/* end of the universe, cause memory fault */
	__asm("breakpoint");
	for (;;);
}

void __attribute__ ((weak)) _zpu_interrupt(void)  
{
	/* not implemented in libgloss */
	__asm("breakpoint");
	for (;;);
}


int __attribute__ ((weak))
_DEFUN (write, (fd, buf, nbytes),
       int fd _AND
       char *buf _AND
       int nbytes)  
{
	// FIXME write to UART
	return (nbytes);
}


/*
 * read  -- read bytes from the serial port. Ignore fd, since
 *          we only have stdin.
 */
int __attribute__ ((weak))
_DEFUN (read, (fd, buf, nbytes),
       int fd _AND
       char *buf _AND
       int nbytes)  
{
	// FIXME - read from UART if present
}



/*
 * open -- open a file descriptor. We don't have a filesystem, so
 *         we return an error.
 */
int __attribute__ ((weak)) open(const char *buf,
       int flags,
       int mode,
       ...)  
{
	errno = EIO;
	return (-1);
}



/*
 * close -- We don't need to do anything, but pretend we did.
 */
int __attribute__ ((weak))
_DEFUN (close ,(fd),
       int fd)  
{
	return (0);
}




int __attribute__ ((weak))
ftruncate (int file, off_t length)  
{
	return -1;
}


/*
 * unlink -- since we have no file system, 
 *           we just return an error.
 */
int __attribute__ ((weak))
_DEFUN (unlink, (path),
        char * path)  
{
	errno = EIO;
	return (-1);
}


/*
 * lseek --  Since a serial port is non-seekable, we return an error.
 */
off_t __attribute__ ((weak))
_DEFUN (lseek, (fd,  offset, whence),
       int fd _AND
       off_t offset _AND
       int whence)  
{
	errno = ESPIPE;
	return ((off_t)-1);
}

/* we convert from bigendian to smallendian*/
static long conv(char *a, int len) 
{
	long t=0;
	int i;
	for (i=0; i<len; i++)
	{
		t|=(((int)a[i])&0xff)<<((len-1-i)*8);
	}
	return t;
}

static void convert(struct fio_stat *gdb_stat, struct stat *buf)
{
	memset(buf, 0, sizeof(*buf));
	buf->st_dev=conv(gdb_stat->fst_dev, sizeof(gdb_stat->fst_dev));
	buf->st_ino=conv(gdb_stat->fst_ino, sizeof(gdb_stat->fst_ino));
	buf->st_mode=conv(gdb_stat->fst_mode, sizeof(gdb_stat->fst_mode));
	buf->st_nlink=conv(gdb_stat->fst_nlink, sizeof(gdb_stat->fst_nlink));
	buf->st_uid=conv(gdb_stat->fst_uid, sizeof(gdb_stat->fst_uid));
	buf->st_gid=conv(gdb_stat->fst_gid, sizeof(gdb_stat->fst_gid));
	buf->st_rdev=conv(gdb_stat->fst_rdev, sizeof(gdb_stat->fst_rdev));
	buf->st_size=conv(gdb_stat->fst_size, sizeof(gdb_stat->fst_size));
}

int __attribute__ ((weak))
_DEFUN (fstat, (fd, buf),
       int fd _AND
       struct stat *buf)  
{
/*
 * fstat -- Since we have no file system, we just return an error.
 */
	buf->st_mode = S_IFCHR;	/* Always pretend to be a tty */
	buf->st_blksize = 0;

	return (0);
}


int __attribute__ ((weak))
_DEFUN (stat, (path, buf),
       const char *path _AND
       struct stat *buf)  
{
	errno = EIO;
	return (-1);
}



int __attribute__ ((weak))
_DEFUN (isatty, (fd),
       int fd)  
{
	/*
	 * isatty -- returns 1 if connected to a terminal device,
	 *           returns 0 if not. Since we're hooked up to a
	 *           serial port, we'll say yes _AND return a 1.
	 */
	return (1);
}

