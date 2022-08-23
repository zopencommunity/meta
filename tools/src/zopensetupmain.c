#include <stdio.h>
#include "download.h"
#include "createpem.h"
#include "createdb.h"
#include "createdirs.h"
#include "github_pem_ca.h"
#include "httpsget.h"

int main() {
  const char* host = "github.com";
  const char* uri = "/ZOSOpenTools/curlport/releases/download/curlport_boot/curl-7.83.1.20220808_165842.zos.pax.Z";
  const char* pemdata = GITHUB_PEM_CA;
  const char* tmppem = "/tmp/temporary.pem";
  const char* output = "/tmp/curl-fultonm.pax.Z";
  const char* root = "/tmp";
  int rc;

  if (rc = createdirs(root))  {
    fprintf(stderr, "error creating directories: %d\n", rc);
    return rc;
  }

  if (rc = createpem(pemdata, tmppem)) {
    fprintf(stderr, "error creating pem file: %d\n", rc);
    return rc;
  }

  if (rc = httpsget(host, uri, tmppem, output)) {
    fprintf(stderr, "error downloading https://%s%s with PEM file %s to %s\n", host, uri, tmppem, output);
    return rc;
  }
}
