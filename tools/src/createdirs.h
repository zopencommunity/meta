#ifndef __ZOPEN_CREATEDIR__
  #define __ZOPEN_CREATEDIR__ 1
  enum {
    ZOPEN_CREATEDIR_OK=0,
    ZOPEN_CREATEDIR_DIR_TOO_LONG,
    ZOPEN_CREATEDIR_CREATE_FAILED,
    ZOPEN_CREATEDIR_DIR_EXISTS,
    ZOPEN_CREATEDIR_ROOT_NOT_EXIST,
  };

  #define ZOPEN_PROD "prod"
  #define ZOPEN_BOOT "boot"
  #define ZOPEN_DEV  "dev"
  #define ZOPEN_HOME  "$HOME"
  #define ZOPEN_HOME_NAME  "zopen"
  #define ZOPEN_DIR_DELIMITER "/"

  int createdirs(const char* root);
#endif
