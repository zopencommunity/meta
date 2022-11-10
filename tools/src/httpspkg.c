#include "zopenio.h"
#include "httpspkg.h"
#include "zopen_boot_uri.h"


/*
 This is the URI pattern we want to generate:
 https://api.github.com/repos/ZOSOpenTools/<pkg>/releases/tags/boot
 */

int getfilenamefrompkg(const char* pkg, const char* pkgsfx, const char* tmppem, char* buffer, size_t bufflen) {
  const char* apihost = "api.github.com";
  char temprawpkg[ZOPEN_PATH_MAX+1];
  char temppkg[ZOPEN_PATH_MAX+1];
  char uri[ZOPEN_PATH_MAX+1];
  int rc;

  if (genfilename("raw", temprawpkg, ZOPEN_PATH_MAX)) {
    return 4;
  }
  if (genfilename("pkg", temppkg, ZOPEN_PATH_MAX)) {
    return 4;
  }

  remove(temprawpkg);
  remove(temppkg);

  if ((rc = snprintf(uri, sizeof(uri), "/%s/%s%s/%s", ZOPEN_REPO_URI_PREFIX, pkg, pkgsfx, ZOPEN_REPO_URI_SUFFIX)) > sizeof(uri)) {
    fprintf(stderr, "error building uri for /%s/%s%s/%s", ZOPEN_REPO_URI_PREFIX, pkg, pkgsfx, ZOPEN_REPO_URI_SUFFIX);
    return 4;
  }
  if (rc = httpsget(apihost, uri, tmppem, temprawpkg)) {
    fprintf(stderr, "error downloading https://%s%s with PEM file %s to %s\n", apihost, uri, tmppem, temprawpkg);
    return rc;
  }
  if (getpkgname(temprawpkg, temppkg, buffer, bufflen)) {
    fprintf(stderr, "error extracting package name from %s\n", temprawpkg);
    return 4;
  }

#if VERBOSE
  printf("Package name:%s\n", buffer);
#else
  remove(temprawpkg);
  remove(temppkg);
#endif

  return 0;
}
