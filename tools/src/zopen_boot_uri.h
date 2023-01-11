#ifndef ZOPEN_BOOT_URI
  #include <stdlib.h>
  #define ZOPEN_TOOLS_URL "https://github.com/ZOSOpenTools"
  #define ZOPEN_REPO_URI_PREFIX "repos/ZOSOpenTools"
  #define ZOPEN_REPO_URI_SUFFIX "releases/tags/boot"
  #define ZOPEN_BOOT_URI_PREFIX "ZOSOpenTools"
  #define ZOPEN_BOOT_URI_SUFFIX "releases/download/boot"
  #define ZOPEN_BOOT_URI_TYPE "zos.pax.Z"
  #define ZOPEN_BOOT_PKG { "curl", "gzip", "tar", "make", "git", "meta", NULL }
#endif
