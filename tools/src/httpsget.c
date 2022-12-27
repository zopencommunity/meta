#define _POSIX_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

#include "createdb.h"
#include "httpsget.h"
#include "zopenio.h"
#include "download.h"

int httpsget(const char* host, const char* uri, const char* pem, const char* output) {
  char* keydb;
  char* reqdb;
  char* stashfile;
  size_t keydblen = ZOPEN_PATH_MAX+1;
  size_t reqdblen = ZOPEN_PATH_MAX+1;
  size_t stashfilelen = ZOPEN_PATH_MAX+1;
  int rc;
  int fd;

  if ((fd = open(pem, O_RDONLY)) > 0) {
    close(fd);
  } else {
    fprintf(stderr, "Unable to open PEM file %s for read\n", pem);
    return 4;
  }
  if ((fd = open(output, O_CREAT|O_WRONLY|O_TRUNC, S_IRWXU)) > 0) {
    close(fd);
  } else {
    fprintf(stderr, "Unable to open output file %s for write\n", output);
    return 4;
  }


  keydb = malloc(ZOPEN_PATH_MAX+1);
  reqdb = malloc(ZOPEN_PATH_MAX+1);
  stashfile = malloc(ZOPEN_PATH_MAX+1);
  if (!keydb || !reqdb || !stashfile) {
    fprintf(stderr, "Unable to acquire storage for httpsget\n");
    return 4;
  }

  if (rc = createdb(pem, &keydb, keydblen, &reqdb, reqdblen, &stashfile, stashfilelen)) {
    fprintf(stderr, "error creating temporary key db %s\n", keydb);
    return rc;
  }

  if (rc = download(host, uri, output, keydb, stashfile)) {
    fprintf(stderr, "error downloading  https://%s%s to %s: %d\n", host, uri, output, rc);
    return rc;
  }

  if (rc = removedb(keydb, reqdb, stashfile)) {
    fprintf(stderr, "error removing temporary key db file %s\n", keydb);
    return rc;
  }

  return 0;
}
