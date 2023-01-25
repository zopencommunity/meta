#ifndef ZOPEN_PATH_MAX
  #define ZOPEN_PATH_MAX 1023
  #include <stdio.h>
  int gentmpfilename(const char* extension, char* buffer, size_t bufflen);
  int genfilename(const char* dir, const char* filename, char* buffer, size_t bufflen);
  int genfilenameinsubdir(const char* dir, const char* subdir, const char* filename, char* buffer, size_t bufflen);
#endif
