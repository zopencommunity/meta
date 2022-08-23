#ifndef ZOPEN_PATH_MAX
  #include <stdlib.h>
  #define ZOPEN_PATH_MAX 1023

  int genfilename(const char* extension, char* buffer, size_t bufflen);
#endif
