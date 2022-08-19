#include <stdio.h>
#include "download.h"
#include "createdirs.h"

int main() {
  const char* host = "github.com";
  const char* uri = "/ZOSOpenTools/curlport/releases/download/curlport_boot/curl-7.83.1.20220808_165842.zos.pax.Z";
  const char* output = "/tmp/curl-fultonm.pax.Z";
  const char* keyring = "/tmp/zopen-setup.kdb";
  const char* stashfile = "/tmp/zopen-setup.sth";
  const char* root = "/tmp";
  int rc;

  if (rc = createdirs(root))  {
    fprintf(stderr, "error creating directories: %d\n", rc);
    return rc;
  }
   
  if (rc = download(host, uri, output, keyring, stashfile)) {
    fprintf(stderr, "error downloading  https://%s%s to %s: %d\n", host, uri, output, keyring, stashfile, rc);
    return rc;
  }
    
}
