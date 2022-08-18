#include <stdio.h>
#include "download.h"
#include "createdirs.h"

int main() {
  const char* host = "github.com";
  const char* uri = "/ZOSOpenTools/curlport/releases/download/curlport_boot/curl-7.83.1.20220808_165842.zos.pax.Z";
  const char* file = "/tmp/curl.pax.Z";
  const char* root = "/tmp";
  int rc;

  if (rc = createdirs(root))  {
    fprintf(stderr, "error creating directories: %d\n", rc);
    return rc;
  }
   
  if (0 && (rc = download(host, uri, file))) {
    fprintf(stderr, "error downloading  https://%s%s to %s: %d\n", host, uri, file, rc);
    return rc;
  }
    
}
