#include <stdio.h>
#include "download.h"
#include "createpem.h"
#include "createdb.h"
#include "createdirs.h"
#include "github_pem_ca.h"

int main() {
  const char* host = "github.com";
  const char* uri = "/ZOSOpenTools/curlport/releases/download/curlport_boot/curl-7.83.1.20220808_165842.zos.pax.Z";
  const char* pemdata = GITHUB_PEM_CA;
  const char* tmppem = "/tmp/temporary.pem";
  const char* output = "/tmp/curl-fultonm.pax.Z";
  const char* keydb = "/tmp/zopen-setup.kdb";
  const char* reqdb = "/tmp/zopen-setup.rdb";
  const char* stashfile = "/tmp/zopen-setup.sth";
  const char* root = "/tmp";
  int rc;

  if (rc = createdirs(root))  {
    fprintf(stderr, "error creating directories: %d\n", rc);
    return rc;
  }

  removedb(tmppem, keydb, reqdb, stashfile);

  if (rc = createpem(pemdata, tmppem)) {
    fprintf(stderr, "error creating pem file: %d\n", rc);
    return rc;
  }

  if (rc = createdb(tmppem, keydb, reqdb, stashfile)) {
    fprintf(stderr, "error creating temporary key db %s\n", keydb);
    return rc;
  }
   
  if (rc = download(host, uri, output, keydb, stashfile)) {
    fprintf(stderr, "error downloading  https://%s%s to %s: %d\n", host, uri, output, keydb, stashfile, rc);
    return rc;
  }
    
  if (rc = removedb(tmppem, keydb, reqdb, stashfile)) {
    fprintf(stderr, "error removing temporary key db file %s\n", keydb);
    return rc;
  }
}
