
#define _ISOC99_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "zopenio.h"
#include "zopen_boot_uri.h"

static char* zopentmpdir(void) {
  char* tmpdir;
  int rc;
  if (! ((tmpdir = getenv("TMP")) || (tmpdir = getenv("TMPDIR"))) ) {
    tmpdir = "/tmp";
  }
  return tmpdir;
}

int genfilename(const char* extension, char* buffer, size_t bufflen) {
  pid_t pid = getpid();
  char* tmpdir = zopentmpdir();
  int rc;

  rc = snprintf(buffer, bufflen, "%s/zopen_tmp_%d.%s", tmpdir, pid, extension);

  if (rc > bufflen) {
    fprintf(stderr, "Unable to generate temporary file name for %s (bufflen %d, rc %d)\n", extension, bufflen, rc);
    return 4;
  }
  return 0;
}

int genfilenameinsubdir(const char* dir, const char* subdir, const char* filename, char* buffer, size_t bufflen) {
  int rc;

  rc = snprintf(buffer, bufflen, "%s/%s/%s", dir, subdir, filename);

  if (rc > bufflen) {
    fprintf(stderr, "Unable to generate temporary file name in %s/%s (bufflen %d, rc %d)\n", dir, subdir, bufflen, rc);
    return 4;
  }

#if VERY_VERBOSE
  printf("filename in subdir:%s\n", buffer);
#endif

  return 0;
}

