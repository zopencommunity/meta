#ifndef ZOPEN_CMD_MAX
  #define ZOPEN_CMD_MAX 1023

  #include <stdio.h>

  int unpaxandlink(const char* root, const char* subdir, const char* pkg, const char* shortname);
  int createhomelink(const char* home, const char* root);
  int getpkgname(const char* temprawpkg, const char* temppkg, char* buffer, size_t bufflen);
#endif
