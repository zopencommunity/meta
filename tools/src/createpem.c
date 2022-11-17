#include <stdio.h>
#include "createpem.h"

int createpem(const char* pemdata, const char* pemfile) {
  FILE* fpem;
  int rc;

  remove(pemfile);

  if (! (fpem = fopen(pemfile, "w"))) {
    fprintf(stderr, "Unable to create temporary file %s name for PEM file\n", pemfile);
    return 4;
  }
  if (fputs(pemdata, fpem) == EOF) {
    fprintf(stderr, "Error write PEM contents \n%s\n to temporary file %s\n", pemdata, pemfile);
    return 4;
  }
  if (fclose(fpem)) {
    fprintf(stderr, "Error closing temporary PEM file %s\n", pemfile);
    return 4;
  }
  return 0;
}
