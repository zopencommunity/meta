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
  const char* uri[] = ZOPEN_BOOT_URI;
  const char* pemdata = GITHUB_PEM_CA;
  const char* root;
  char* output = malloc(ZOPEN_PATH_MAX+1);
  char* tmppem = malloc(ZOPEN_PATH_MAX+1);
  int rc;
  int i;

  if (argc != 2) {
    fprintf(stderr, "Syntax: %s <root>\n"
                    "  where <root> is the root directory where:\n"
                    "    a symbolic link from ${HOME}/zopen  to <root> will be created\n"
                    "    a boot, prod, and dev directory created\n"
                    "  The boot subdirectory will have:\n"
                    "    sub-directories for each of the tools needed for running the zopen utility\n"
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

  for (i=0; uri[i]; ++i) {
    if (!output || genfilename("pax.Z", output, ZOPEN_PATH_MAX)) {
      fprintf(stderr, "error acquiring storage (2)\n");
      return 4;
    }
    if (rc = httpsget(host, uri[i], tmppem, output)) {
      fprintf(stderr, "error downloading https://%s%s with PEM file %s to %s\n", host, uri, tmppem, output);
      return rc;
    }
  }
}
