#ifndef ZOPEN_BOOT_URI
  #include <stdlib.h>
  #define ZOPEN_TOOLS_URL "https://github.com/ZOSOpenTools"
  #define ZOPEN_REPO_URI_PREFIX "repos/ZOSOpenTools"
  #define ZOPEN_REPO_URI_SUFFIX "releases/tags/boot"
  #define ZOPEN_BOOT_URI_PREFIX "ZOSOpenTools"
  #define ZOPEN_BOOT_URI_SUFFIX "releases/download/boot"
  #define ZOPEN_BOOT_URI_TYPE "zos.pax.Z"

  /*
   * Make sure 'meta' is first - we should make all packages independent, but they are not quite yet
   * We may want to trim down the list of tools a bit. In particular vim and ncurses are not _required_
   * but they sure are nice.
   */
  #define ZOPEN_BOOT_PKG { "meta", "curl", "make", "git", "less", "perl", "jq", "bash", "diffutils", "findutils", "coreutils", "tar", "gzip", "xz", "bzip2", "vim", "ncurses", "sed", "grep", "gawk", NULL }
#endif
