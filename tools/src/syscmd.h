#ifndef ZOPEN_CMD_MAX
  #define ZOPEN_CMD_MAX 1023

  int unpaxandlink(const char* root, const char* subdir, const char* pkg, const char* shortname);
  int createhomelink(const char* home, const char* name, const char* root);
#endif
