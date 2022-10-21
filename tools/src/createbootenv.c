#define _POSIX_SOURCE
#define _OPEN_SYS_FILE_EXT 1

#include "createbootenv.h"
#include "zopenio.h"
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

static int setccsid(int fd, int ccsid) {
  attrib_t attr;
  int rc;

  memset(&attr, 0, sizeof(attr));
  attr.att_filetagchg = 1;
  attr.att_filetag.ft_ccsid = ccsid;
  attr.att_filetag.ft_txtflag = 1;

  rc = __fchattr(fd, &attr, sizeof(attr));
  return rc;
}

int createbootenv(const char* root, const char* subdir, const char* bootpkg[]) {
  char absbootenv[ZOPEN_PATH_MAX+1];
  char header[]  = "#\n"
                   "# Set up the boot environment for z/OS Open Source Community tools development\n"
                   "#/\n\n"
                   "if ! [ -f ./" ZOPEN_BOOT_ENV " ]; then\n"
	           "  echo \"Need to source from the directory containing " ZOPEN_BOOT_ENV " >&2\"\n"
	           "  return 0\n"
                   "fi\n"
                   "bootdir=\"${PWD}\"\n"
                   "for p in ";  
 
  char trailer[] = "; do\n"
                   "  cd \"${p}\"\n  "
                   "  . ./.env\n"
                   "  cd \"${bootdir}\"\n"
                   "done\n";
  int fd;
  int rc;
  int i;
  int ccsid;

#if (__CHARSET_LIB == 1) /* built ASCII */
  ccsid = 819;
#else
  ccsid = 1047;
#endif

  if ((rc = snprintf(absbootenv, ZOPEN_PATH_MAX, "%s/%s/%s", root, subdir, ZOPEN_BOOT_ENV)) > ZOPEN_PATH_MAX) {
    fprintf(stderr, "Error building bootenv name\n");
    return rc;
  }

  /*
   * Do not mark the bootenv file as executable since it should only be source'd
   */
  if (!(fd = open(absbootenv, O_CREAT|O_WRONLY, S_IRUSR | S_IWUSR))) {
    fprintf(stderr, "Unable to create %s\n", absbootenv);
    return 4;
  } 
  if (setccsid(fd, ccsid)) {
    fprintf(stderr, "Unable to tag %s\n", absbootenv);
    return 4;
  } 

  if (write(fd, header, sizeof(header)-1) < sizeof(header)-1) {
    fprintf(stderr, "Unable to write header to %s\n", absbootenv);
    return 4;
  }

  for (i=0; bootpkg[i]; ++i) {
    size_t bootlen = strlen(bootpkg[i]);
    if (write(fd, bootpkg[i], bootlen) < bootlen) { 
      fprintf(stderr, "Unable to write pkg %s to %s\n", bootpkg[i], absbootenv);
      return 4;
    } 
    if (write(fd, " ", 1) < 1) { 
      fprintf(stderr, "Unable to write space to %s\n", absbootenv);
      return 4;
    } 
  }

  if (write(fd, trailer, sizeof(trailer)-1) < sizeof(trailer)-1) {
    fprintf(stderr, "Unable to write trailer to %s\n", absbootenv);
    return 4;
  }
 
  if (close(fd)) {
    fprintf(stderr, "Unable to close %s\n", absbootenv);
    return 4;
  } 
  fprintf(stdout, "Successfully created boot environment file for sourcing: %s\n", absbootenv);
  return 0;
}
