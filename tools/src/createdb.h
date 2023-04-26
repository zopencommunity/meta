#ifndef __ZOPEN_CREATEDB__
  #define __ZOPEN_CREATEDB__ 1

  #include <stdio.h>

  int createdb(const char* pem, const char* pem2, char** keydb, size_t keydblen, char** reqdb, size_t reqdblen, char** stashfile, size_t stashfilelen);
  int removedb(const char* keydb, const char* reqdb, const char* stashfile);
#endif
