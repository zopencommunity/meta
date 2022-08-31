#include <stdio.h>
#include "download.h"
#include "zopenio.h"
#include "createpem.h"
#include "createdb.h"
#include "createdirs.h"
#include "github_pem_ca.h"
#include "zopen_boot_uri.h"
#include "httpsget.h"

int main(int argc, char* argv[]) {
  const char* host = "github.com";
  const char* bootpkg[] = ZOPEN_BOOT_PKG;
  const char* pemdata = GITHUB_PEM_CA;
  const char* root;
  char  output[ZOPEN_PATH_MAX+1];
  char  tmppem[ZOPEN_PATH_MAX+1];
  char  uri[ZOPEN_PATH_MAX+1];
  int   rc;
  int   i;

  if (argc != 2) {
    fprintf(stderr, "Syntax: %s <root>\n"
                    "  <root> is the root directory where:\n"
                    "    a symbolic link from ${HOME}/zopen to <root> will be created\n"
                    "    boot, prod, and dev directories will be created\n"
                    "  The boot subdirectory will have:\n"
                    "    sub-directories created for each of the tools needed for running the zopen utility\n"
                    "  The dev subdirectory will have:\n"
                    "    a 'git clone' of both the utils and meta repositories\n", argv[0]);
    return 4; 
  }
  root = argv[1];
 
  if (!tmppem || genfilename("pem", tmppem, ZOPEN_PATH_MAX)) {
    fprintf(stderr, "error acquiring storage\n");
    return 4;
  }
 
  if (rc = createdirs(root))  {
    fprintf(stderr, "error creating directories: %d\n", rc);
    return rc;
  }

  if (rc = createpem(pemdata, tmppem)) {
    fprintf(stderr, "error creating pem file: %d\n", rc);
    return rc;
  }
#define ZOPEN_BOOT_URI_ROOT "/ZOSOpenTools/curlport/releases/download/boot"
  for (i=0; bootpkg[i]; ++i) {
    if ((rc = snprintf(uri, sizeof(uri), "/%s/%sport/%s/%s.%s", ZOPEN_BOOT_URI_PREFIX, bootpkg[i], ZOPEN_BOOT_URI_SUFFIX, bootpkg[i], ZOPEN_BOOT_URI_TYPE)) > sizeof(uri)) {
      fprintf(stderr, "error building uri for %s/%s.%s", ZOPEN_BOOT_URI_ROOT, bootpkg[i], ZOPEN_BOOT_URI_TYPE);
      return 4;
    }   
    if (!output || genfilenameinsubdir("pax.Z", root, ZOPEN_BOOT, bootpkg[i], output, ZOPEN_PATH_MAX)) {
      fprintf(stderr, "error acquiring storage (2)\n");
      return 4;
    }
    if (rc = httpsget(host, uri, tmppem, output)) {
      fprintf(stderr, "error downloading https://%s%s with PEM file %s to %s\n", host, uri, tmppem, output);
      return rc;
    }
  }
  
  if (remove(tmppem)) {
    fprintf(stderr, "error removing temporary pem file: %s\n", tmppem);
    return 4;
  }
  return 0;
}
