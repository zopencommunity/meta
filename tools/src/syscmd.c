#define _ISOC99_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#include "syscmd.h"

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
  #if VERY_VERBOSE
    fprintf(stdout, "Successfully performed unpax: %s\n", pax);
  #endif
  } else {
    fprintf(stderr, "non zero rc of %d from system %s\n", rc, pax);
  }

  if ((rc = snprintf(ln, sizeof(ln), ln_format, root, subdir, shortname, shortname, shortname)) > sizeof(ln)) {
    fprintf(stderr, "error building command for symbolic link of shortname %s in %s/%s\n", shortname, root, subdir);
    return rc;
  }
  rc = system(ln);
  if (rc == 0) {
  #if VERY_VERBOSE
    fprintf(stdout, "Successfully performed symbolic link: %s\n", ln);
  #endif
  } else {
    fprintf(stderr, "non zero rc of %d from system %s\n", rc, ln);
  }

  return rc;
}

int createhomelink(const char* home, const char* name, const char* root) {
  char ln_format[] = "/bin/sh -c \"/bin/rm -rf %s/%s/* && /bin/ln -s %s %s/%s\"";
  char ln[ZOPEN_CMD_MAX+1];
  int rc;
  if ((rc = snprintf(ln, sizeof(ln), ln_format, home, name, root, home, name)) > sizeof(ln)) {
    fprintf(stderr, "error building command for symbolic link to %s from %s/%s\n", root, home, name);
    return rc;
  }
  rc = system(ln);
  if (rc == 0) {
  #if VERY_VERBOSE
    fprintf(stdout, "Successfully performed symbolic link: %s\n", ln);
  #endif
  } else {
    fprintf(stderr, "non zero rc of %d from system %s\n", rc, ln);
  }

  return rc;
}

int getpkgname(const char* temprawpkg, const char* temppkg, char* buffer, size_t bufflen) {
  char getpkg_format[] = "/bin/sh -c \"chtag -t %s && chtag -cISO8859-1 %s && cat %s | awk ' BEGIN { RS=\\\",\\\" } { print }' | grep '\\\"name\\\":' | grep pax.Z | tr '\\\"' ' ' | /bin/awk '{ print \\$3 }' >%s\"";
  char getpkg[ZOPEN_CMD_MAX+1];
  int rc;
  ssize_t len;
  int fd;

  if ((rc = snprintf(getpkg, sizeof(getpkg), getpkg_format, temprawpkg, temprawpkg, temprawpkg, temppkg)) > sizeof(getpkg)) {
    fprintf(stderr, "error building command to get package from %s and write it to %s\n", temprawpkg, temppkg);
    return rc;
  }
  rc = system(getpkg);
  if (rc) {
    fprintf(stderr, "non zero rc of %d from system %s\n", rc, getpkg);
    return rc;
  }

  if (!(fd = open(temppkg, O_RDONLY))) {
    fprintf(stderr, "Unable to open %s for read after system call (check that %s has a 'pax.Z' asset in it)\n", temppkg, temprawpkg);
    return 4;
  }
  if ((len = read(fd, buffer, bufflen)) <= 0) {
    fprintf(stderr, "Unable to read %s after system call (check that %s has a 'pax.Z' asset in it)\n", temppkg, temprawpkg);
    return 4;
  }
  close(fd);
  buffer[len-1] = '\0'; /* remove newline */

  return 0;
}

