#ifndef ZOPEN_BOOT_URI
  #include <stdlib.h>
  #define ZOPEN_TOOLS_URL "https://github.com/zopencommunity"
  #define ZOPEN_REPO_URI_PREFIX "repos/zopencommunity"
  #define ZOPEN_REPO_URI_SUFFIX "releases/tags/stable"
  #define ZOPEN_BOOT_URI_PREFIX "zopencommunity"
  #define ZOPEN_BOOT_URI_SUFFIX "releases/download/stable"
  #define ZOPEN_BOOT_URI_TYPE "zos.pax.Z"

  /*
   * We may want to trim down the list of tools a bit. In particular vim and ncurses are not _required_
   * but they sure are nice.
   */
  #define ZOPEN_BOOT_PKG { "meta", "curl", "make", "git", "less", "perl", \
                           "jq",  "bash", "diffutils", "findutils", "coreutils", \
                           "tar", "gzip", "xz", "bzip2", "vim", "ncurses", "sed", \
                           "grep", "gawk", "man-db", "groff", "libiconv", NULL }
#endif
