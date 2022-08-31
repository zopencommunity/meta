#ifndef ZOPEN_PATH_MAX
  #include <stdlib.h>
  #define ZOPEN_PATH_MAX 1023

  int genfilename(const char* extension, char* buffer, size_t bufflen);
  int genfilenameinsubdir(const char* extension, const char* dir, const char* subdir, const char* prefix, char* buffer, size_t bufflen);
#endif
