#ifndef ZOPEN_PATH_MAX
  #define ZOPEN_PATH_MAX 1023
  #include <stdio.h>
  int genfilename(const char* extension, char* buffer, size_t bufflen);
  int genfilenameinsubdir(const char* dir, const char* subdir, const char* filename, char* buffer, size_t bufflen);
#endif
