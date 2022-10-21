#ifndef __ZOPEN_CREATEBOOTENV__
  #define __ZOPEN_CREATEBOOTENV__ 1

  #define ZOPEN_BOOT_ENV ".bootenv"
  int createbootenv(const char* root, const char* subdir, const char* bootenv, const char* pkg[]);
#endif
