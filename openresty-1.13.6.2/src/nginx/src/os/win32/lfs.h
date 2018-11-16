/*
** LuaFileSystem
** Copyright Kepler Project 2003 - 2016 (http://keplerproject.github.io/luafilesystem)
*/
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <sys/stat.h>

#ifdef _WIN32
#include <direct.h>
#ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN 1
#endif
#include <windows.h>
#include <io.h>
#include <sys/locking.h>
#ifdef __BORLANDC__
#include <utime.h>
#else
#include <sys/utime.h>
#endif
#include <fcntl.h>
/* MAX_PATH seems to be 260. Seems kind of small. Is there a better one? */
#define LFS_MAXPATHLEN MAX_PATH
#else
#include <unistd.h>
#include <dirent.h>
#include <fcntl.h>
#include <sys/types.h>
#include <utime.h>
#include <sys/param.h> /* for MAXPATHLEN */
#define LFS_MAXPATHLEN MAXPATHLEN
#endif

/* Define 'chdir' for systems that do not implement it */
#ifdef NO_CHDIR
  #define chdir(p)	(-1)
  #define chdir_error	"Function 'chdir' not provided by system"
#else
  #define chdir_error	strerror(errno)
#endif

#ifdef _WIN32
  #define chdir(p) (_chdir(p))
  #define getcwd(d, s) (_getcwd(d, s))
  #define rmdir(p) (_rmdir(p))
  #define LFS_EXPORT __declspec (dllexport)
  #ifndef fileno
    #define fileno(f) (_fileno(f))
  #endif

#endif

typedef struct lfs_dir_lock {
#ifdef _WIN32
	HANDLE fd;
#else
	char *ln;
#endif
} lfs_dir_lock;

typedef struct lfs_dir_data {
	int  closed;

#ifdef _WIN32
	intptr_t hFile;
	char pattern[MAX_PATH + 1];
	struct _finddata_t c_file;
#else
	DIR *dir;
	struct dirent *entry;
#endif
} lfs_dir_data;


#ifdef __cplusplus
extern "C" {
#endif

int change_dir(const char *path);
int get_dir(char **ppath);

lfs_dir_lock * lfs_lock_dir(const char *path);
void lfs_unlock_dir(lfs_dir_lock *lock);

int lock_file_win(const char *sFileName, void **ppOutHandle);
int unlock_file_win(void *pHandle);

int file_lock(FILE *fh, const char *mode, const long start, long len);
int file_unlock(FILE *fh, const long start, long len);

int make_link(const char *oldpath, const char *newpath, int symbolic);
int make_dir(const char *path);
int remove_dir(const char *path);

const char * dir_iter(lfs_dir_data *d);
void dir_iter_close(lfs_dir_data *d);
lfs_dir_data * dir_iter_factory(const char *path);

#ifdef __cplusplus
}
#endif
