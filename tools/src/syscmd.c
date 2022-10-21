#include "syscmd.h"
#include <stdio.h>
#include <stdlib.h>

int unpaxandlink(const char* root, const char* subdir, const char* pkg, const char* shortname) { 
  char pax_format[] = "cd %s/%s && /bin/pax -rf %s && rm %s";
  char pax[ZOPEN_CMD_MAX+1];
  char ln_format[] = "/bin/sh -c \"cd %s/%s && /bin/rm -f %s && /bin/ln -s %s* %s\"";
  char ln[ZOPEN_CMD_MAX+1];
  int rc;

  if ((rc = snprintf(pax, sizeof(pax), pax_format, root, subdir, pkg, pkg)) > sizeof(pax)) {
    fprintf(stderr, "error building command for pax of package %s in %s/%s\n", pkg, root, subdir);
    return rc;
  }
  rc = system(pax);
  if (rc == 0) {
    fprintf(stdout, "Successfully performed unpax: %s\n", pax);
  } else {
    fprintf(stderr, "non zero rc of %d from system %s\n", rc, pax);
  }

  if ((rc = snprintf(ln, sizeof(ln), ln_format, root, subdir, shortname, shortname, shortname)) > sizeof(ln)) {
    fprintf(stderr, "error building command for symbolic link of shortname %s in %s/%s\n", shortname, root, subdir);
    return rc;
  }
  rc = system(ln);
  if (rc == 0) {
    fprintf(stdout, "Successfully performed symbolic link: %s\n", ln);
  } else {
    fprintf(stderr, "non zero rc of %d from system %s\n", rc, ln);
  }

  return rc;
}
