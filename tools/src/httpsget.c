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
  const char* github_oauth_help = "https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/authorizing-oauth-apps";
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
    if (rc == 403) {
      fprintf(stderr, "You have received a 403 Forbidden error from %s%s\n", host, uri);
      fprintf(stderr, "This is likely because you have exceeded your download quota from github.\n");
      fprintf(stderr, "Please see: %s for instructions on how to set up a github OAUTH id.\n", github_oauth_help);
      fprintf(stderr, "Once your OAUTH id is set, export ZOPEN_GITHUB_OAUTH_TOKEN=<your token> and then re-run zopen-setup.\n");
    } else if (rc == 401) {
      fprintf(stderr, "You have received a 401 Unauthorized error from %s%s\n", host, uri);
      fprintf(stderr, "This is likely because you have an expired or invalid github OAUTH id.\n");
      fprintf(stderr, "Please see: %s for instructions on how to set up a new github OAUTH id.\n", github_oauth_help);
      fprintf(stderr, "Once your OAUTH id is reset, export ZOPEN_GITHUB_OAUTH_TOKEN=<your token> and then re-run zopen-setup.\n");
    } else if (rc == 404) {
      fprintf(stderr, "You have received a 404 Not Found error from %s%s\n", host, uri);
      fprintf(stderr, "This is likely because there is no release currently tagged as 'boot' for this package\n");
      fprintf(stderr, "Open an issue at https://github.com/ZOSOpenTools/<pkg>port/issues\n");
    } else {
      fprintf(stderr, "error downloading  https://%s%s to %s: %d\n", host, uri, output, rc);
    }
    return rc;
  }

  if (rc = removedb(keydb, reqdb, stashfile)) {
    fprintf(stderr, "error removing temporary key db file %s\n", keydb);
    return rc;
  }

  return 0;
}
