#define _ISOC99_SOURCE
#define _XOPEN_SOURCE_EXTENDED 1
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "download.h"
#include "zopenio.h"
#include "createpem.h"
#include "createdb.h"
#include "createdirs.h"
#include "github_pem_ca.h"
#include "zopen_boot_uri.h"
#include "httpsget.h"
#include "httpspkg.h"
#include "syscmd.h"
#include "createbootenv.h"

#define MAIN
#include "options.h"

static const char* lastpos(const char* str, int c) {
  int i;
  for (i=strlen(str); i>=0; --i) {
    if (str[i] == c) {
      return &str[i];
    }
  }
  return NULL;
}

static void syntax(const char* pgm, const char** bootpkg) {
  const char* base;
  if (base = lastpos(pgm, '/')) {
    pgm = &base[1];
  }
  fprintf(stderr, "%s : Install the z/OS Open Source Tools 'starter' environment by downloading from %s\n"
                  "Syntax: %s [-vq] <root>\n"
                  "  <root> is the root directory where:\n"
                  "    a symbolic link from ${HOME}/zopen to <root> will be created\n"
                  "    boot, prod, and dev directories will be created\n"
                  "  The boot subdirectory will have:\n"
                  "    sub-directories created for each of the tools needed for running the zopen utility\n"
                  "Options:\n"
                  " -v : print out verbose messages\n"
                  " -q : only print out errors\n"
                  "Note:\n"
                  " Special consideration is made if <root> is ${HOME}/zopen in which case no link is created\n",
                  pgm, ZOPEN_TOOLS_URL, pgm);

  fprintf(stderr, "Tools to be installed:\n ");
  for (int i=0; bootpkg[i]; ++i) {
    if (bootpkg[i+1])
      fprintf(stderr, "%s, ", bootpkg[i]);
    else
      fprintf(stderr, "%s\n", bootpkg[i]);
  }
  return;
}

#define _CVTSTATE_OFF     0
#define _CVTSTATE_ON      1
#define _CVTSTATE_ALL     4

#define _CVTSTATE_SWAP    2
#define _CVTSTATE_QUERY   3

int __ae_autoconvert_state(int action);

/*
 * This program does the following:
 * - creates the directories for z/OS Open Source Tools from the 'root' directory provided (boot, prod, dev)
 * - creates a temporary PEM file that will be used to connect to the github.com site to download bootstrap tools (e.g. curl)
 * - download each of the packages into the bootstrap directory as pax.Z files
 * - unpax the pax files
 * - generate a .bootenv script that can later be sourced in the 'boot' directory for subsequent setup of the boot environment
 * - create symbolic link from $HOME/zopen to 'root' directory provided
 */

int main(int argc, char* argv[]) {
  const char* host = "github.com";
  const char* bootpkg[] = ZOPEN_BOOT_PKG;
  const char* pemdata = GITHUB_PEM_CA;
  const char* pemdata2 = GITHUB_OBJECT_PEM_CA;
  char* pkgsfx;
  char  root[ZOPEN_PATH_MAX+1];
  char  filename[ZOPEN_PATH_MAX+1];
  char  output[ZOPEN_PATH_MAX+1];
  char  tmppem[ZOPEN_PATH_MAX+1];
  char  tmppem2[ZOPEN_PATH_MAX+1];
  char  zopenhome[ZOPEN_PATH_MAX+1];
  char  realpathhome[ZOPEN_PATH_MAX+1];
  char  uri[ZOPEN_PATH_MAX+1];
  int   rc;
  int   i;
  int symlink;
  int parmsok=0;
  char* zopen_c_home_var = getenv("HOME");

  __ae_autoconvert_state(_CVTSTATE_ON); 

  if (argc < 2) {
    syntax(argv[0], bootpkg);
    return 4;
  }
  for (i=1; i<argc; ++i) {
    if (!strcmp(argv[i], "-v")) {
      verbose = 1;
    } else if  (!strcmp(argv[i], "-q"))	{
      verbose =	0;
    } else if (argv[i][0] == '-') {
      fprintf(stderr, "Unknown option: %s specified\n", argv[i]);
      syntax(argv[0], bootpkg);
      return 8;
    } else if (i != (argc-1)) {
      fprintf(stderr, "Too many parameters specified\n");
      syntax(argv[0], bootpkg);
      return 8;
    } else {
      parmsok=1;
    }
  }
  if (!parmsok) {
    fprintf(stderr, "Specify a directory to install into\n");
    syntax(argv[0], bootpkg);
    return 8;
  }
  if (!zopen_c_home_var) {
    fprintf(stderr, "Unable to determine $HOME location - this is required to create the symbolic link\n");
    return 8;
  }
  if (!realpath(argv[argc-1], root)) {
    fprintf(stderr, "Directory %s does not exist, or is not writable\n", argv[argc-1]);
    syntax(argv[0], bootpkg);
    return 4;
  }
  if (genfilename(zopen_c_home_var, ZOPEN_HOME_NAME, zopenhome, ZOPEN_PATH_MAX)) {
    return 4;
  }

  if (realpath(zopenhome, realpathhome)) {
    if (strcmp(root, realpathhome)) {
      fprintf(stderr, "File or directory %s exists. Please move this file before running since a symbolic link will be created\n", zopenhome);
      syntax(argv[0], bootpkg);
      return 4;
    } else {
      /* Special case - if zopenhome and realpathhome are the same, recognize this and skip creating a symbolic link */
      symlink=0;
    }
  } else {
    symlink=1;
  }

  if (gentmpfilename("pem", tmppem, ZOPEN_PATH_MAX)) {
    /* gentmpfilename issues specific errors */
    return 4;
  }
  if (gentmpfilename("pem2", tmppem2, ZOPEN_PATH_MAX)) {
    /* gentmpfilename issues specific errors */
    return 4;
  }


  if (verbose) {
    fprintf(STDTRC, "Creating directories under %s\n", root);
  }

  if (rc = createdirs(root))  {
    fprintf(stderr, "error creating directories: %d\n", rc);
    return rc;
  }

  if (rc = createpem(pemdata, tmppem)) {
    fprintf(stderr, "error creating pem file: %d\n", rc);
    return rc;
  }
  if (rc = createpem(pemdata2, tmppem2)) {
    fprintf(stderr, "error creating pem file: %d\n", rc);
    return rc;
  }
  for (i=0; bootpkg[i]; ++i) {
    pkgsfx="port";

    if (verbose) {
      fprintf(STDTRC, "Download %s into %s/%s\n", bootpkg[i], root,  ZOPEN_BOOT);
    }
    if (rc = getfilenamefrompkg(bootpkg[i], pkgsfx, tmppem, tmppem2, filename, ZOPEN_PATH_MAX)) {
      /* If the boot package isn't found (404), keep going */
      if (rc == 404) { continue; }
      return rc;
    }
    if (genfilenameinsubdir(root, ZOPEN_BOOT, filename, output, ZOPEN_PATH_MAX)) {
      return 4;
    }
    if ((rc = snprintf(uri, sizeof(uri), "/%s/%s%s/%s/%s", ZOPEN_BOOT_URI_PREFIX, bootpkg[i], pkgsfx, ZOPEN_BOOT_URI_SUFFIX, filename)) > sizeof(uri)) {
      fprintf(stderr, "error building uri for /%s/%s%s/%s/%s", ZOPEN_BOOT_URI_PREFIX, bootpkg[i], pkgsfx, ZOPEN_BOOT_URI_SUFFIX, filename);
      return 4;
    }
    if (rc = httpsget(host, uri, tmppem, tmppem2, output)) {
      fprintf(stderr, "error %d downloading https://%s%s with PEM files %s,%s to %s\n", rc, host, uri, tmppem, tmppem2, output);
      return rc;
    }
    if (rc = unpaxandlink(root, ZOPEN_BOOT, output, bootpkg[i])) {
      return rc;
    }
  }

  if (verbose) {
    fprintf(STDTRC, "Create %s for source'ing in %s/%s\n", ZOPEN_BOOT_ENV, root, ZOPEN_BOOT);
  }
  if (rc = createbootenv(root, ZOPEN_BOOT, bootpkg)) {
    return rc;
  }

  if (symlink) {
    if (verbose) {
      fprintf(STDTRC, "Create symbolic link from %s to %s\n", zopenhome, root);
    }
    if (createhomelink(zopenhome, root)) {
      fprintf(stderr, "error creating symbolic link from %s to %s\n", zopenhome, root);
      return rc;
    }
  } else {
    if (verbose) {
      fprintf(STDTRC, "No symbolic link from %s to %s required\n", zopenhome, root);
    }
  }


  if (remove(tmppem)) {
    fprintf(stderr, "error removing temporary pem file: %s\n", tmppem);
    return 4;
  }
  if (remove(tmppem2)) {
    fprintf(stderr, "error removing temporary pem file: %s\n", tmppem2);
    return 4;
  }
  return 0;
}
