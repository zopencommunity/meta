#ifndef ZOPEN_BOOT_URI
  #include <stdlib.h>
  #define ZOPEN_REPO_URI_PREFIX "ZOSOpenTools" 
  #define ZOPEN_REPO_URI_SUFFIX "releases/tag/boot"
  #define ZOPEN_BOOT_URI_PREFIX "ZOSOpenTools"
  #define ZOPEN_BOOT_URI_SUFFIX "releases/download/boot"
  #define ZOPEN_BOOT_URI_TYPE "zos.pax.Z"
  #define ZOPEN_BOOT_PKG { "gzip", "tar", "curl", "make", "utils", "git", NULL }
#endif
