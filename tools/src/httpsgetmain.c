#include <stdio.h>
#include "download.h"
#include "createpem.h"
#include "createdb.h"
#include "github_pem_ca.h"
#include "httpsget.h"

int main(int argc, char* argv[]) {
  const char* host;
  const char* uri;
  const char* pem;
  const char* out;
  int rc;

  if (argc < 5) {
    fprintf(stderr, "Syntax:\n"
                    "%s <host> <uri> <pem> <out>\n"
                    "  <host> : the host name, e.g. www.ibm.com or 23.6.251.247\n"
                    "  <uri>  : the uri, e.g. /index.html\n"
                    "  <pem>  : the PEM CA cert for the corresponding host, e.g. /u/user/www-ibm-com.pem\n"
                    "  <out>  : the location to write the file (in binary) to, e.g. /u/user/out.bin\n", argv[0]);
    return(4);
  }
  host = argv[1];
  uri = argv[2];
  pem = argv[3];
  out = argv[4]; 

  if (rc = httpsget(host, uri, pem, out)) {
    fprintf(stderr, "error downloading https://%s%s with PEM file %s to %s\n", host, uri, pem, out);
    return rc;
  }
  return 0;
}
