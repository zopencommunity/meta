#include <stdio.h>
#include "createdb.h"
#include "httpsget.h"

int httpsget(const char* host, const char* uri, const char* pem, const char* output) {
  const char* keydb = "/tmp/zopen-setup.kdb";
  const char* reqdb = "/tmp/zopen-setup.rdb";
  const char* stashfile = "/tmp/zopen-setup.sth";
  int rc;

  removedb(keydb, reqdb, stashfile);

  if (rc = createdb(pem, keydb, reqdb, stashfile)) {
    fprintf(stderr, "error creating temporary key db %s\n", keydb);
    return rc;
  }
   
  if (rc = download(host, uri, output, keydb, stashfile)) {
    fprintf(stderr, "error downloading  https://%s%s to %s: %d\n", host, uri, output, keydb, stashfile, rc);
    return rc;
  }
    
  if (rc = removedb(keydb, reqdb, stashfile)) {
    fprintf(stderr, "error removing temporary key db file %s\n", keydb);
    return rc;
  }

  return 0;
}
