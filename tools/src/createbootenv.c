#include "createbootenv.h"
#include "zopenio.h"
#define _POSIX_SOURCE
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

int createbootenv(const char* root, const char* subdir, const char* bootenv, const char* bootpkg[]) {
  char absbootenv[ZOPEN_PATH_MAX+1];
  char header[]  = "/*\n * Set up the boot environment for z/OS Open Source Community tools development\n */\n\nfor p in \'";   
  char trailer[] = "\'; do\n  cd \"${p}\"\n  . ./.env\ndone";
  int fd;
  int rc;
  int i;

  if ((rc = snprintf(absbootenv, ZOPEN_PATH_MAX, "%s/%s/%s", root, subdir, bootenv)) > ZOPEN_PATH_MAX) {
    fprintf(stderr, "Error building bootenv name\n");
    return rc;
  }

  if (!(fd = open(absbootenv, O_CREAT|O_WRONLY, S_IRWXU))) {
    fprintf(stderr, "Unable to create %s\n", absbootenv);
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
