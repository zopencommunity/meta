#ifndef __ZOPEN_CREATEDB__
  #define __ZOPEN_CREATEDB__ 1

  int createdb(const char* tmppem, const char* keydb, const char* reqdb, const char* stashfile);
  int removedb(const char* tmppem, const char* keydb, const char* reqdb, const char* stashfile);
#endif
