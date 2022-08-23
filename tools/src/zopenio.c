#include "zopenio.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

static char* zopentmpdir() {
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
