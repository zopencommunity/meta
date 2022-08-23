#include "createdb.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int genfilename(const char* extension, char* buffer, size_t bufflen) {
  pid_t pid = getpid();
  char* tmpdir;
  int rc;
  if (! ((tmpdir = getenv("TMP")) || (tmpdir = getenv("TMPDIR"))) ) {
    tmpdir = "/tmp";
  }
  
  rc = snprintf(buffer, bufflen, "%s/zopengskkey_%d.%s", tmpdir, pid, extension);

  if (rc > bufflen) {
    fprintf(stderr, "Unable to generate temporary file name for %s (bufflen %d, rc %d)\n", extension, bufflen, rc);
    return 4;
  }
  return 0;
}

static int genfilenames(char* kdb, size_t kdblen, char* rdb, size_t reqdblen, char* stashfile, size_t stashfilelen) {
  if (genfilename("kdb", kdb, kdblen)) {
    return 4;
  } 
  if (genfilename("rdb", rdb, reqdblen)) {
    return 4;
  } 
  if (genfilename("sth", stashfile, stashfilelen)) {
    return 4;
  } 
  return 0;
}
  
int removedb(const char* keydb, const char* reqdb, const char* stashfile) {
  int rc1 = remove(keydb);
  int rc2 = remove(reqdb);
  int rc3 = remove(stashfile);

  return rc1 | rc2 | rc3;
}
  
int createdb(const char* pem, char** keydb, size_t keydblen, char** reqdb, size_t reqdblen, char** stashfile, size_t stashfilelen) {
  char dbcmdstreambuff[256];
  char dbcmdbuff[256];
  int rc;

  /*
   * Create the database. Unfortunately, gskkyman does not seem to 
   * have a CLI for this, so we need to use the 'interactive' interface and
   * pass in the right parameters. 
   * It is 'ok' that the password is known because the CA cert we are putting
   * into the database is public.
   */
  #define CREATE_DB "1\n"
  #define DB_PASSWORD "zopen-setup"
  #define DB_PASSWORD_NL DB_PASSWORD "\n"
  #define DB_EXPIRE   "1\n"
  #define DB_RECLEN   "5000\n"
  #define FIPS_MODE   "0\n"
  #define RETURN      "\n"
  #define EXIT        "0\n"

  #define OPEN_DB "2\n"
  #define IMPORT_CA "7\n"
  #define CA_LABEL "zopen-ca\n"

  if (genfilenames(*keydb, keydblen, *reqdb, reqdblen, *stashfile, stashfilelen)) {
    return 4;
  } 

  removedb(*keydb, *reqdb, *stashfile);

  if ((rc = snprintf(dbcmdstreambuff, sizeof(dbcmdstreambuff), "%s%s%s%s%s%s%s%s%s%s", CREATE_DB, *keydb, "\n", 
    DB_PASSWORD_NL, DB_PASSWORD_NL, DB_EXPIRE, DB_RECLEN, FIPS_MODE, RETURN, EXIT)) > sizeof(dbcmdstreambuff)) {
    fprintf(stderr, "Internal error: buffer too small\n");
    return 4;
  }

  if ((rc = snprintf(dbcmdbuff, sizeof(dbcmdbuff), "echo \"%s\" | gskkyman >/dev/null 2>&1", dbcmdstreambuff)) > sizeof(dbcmdbuff)) {
    fprintf(stderr, "Internal error: buffer too small\n");
    return 4;
  }
  if (rc = (system(dbcmdbuff) & 0xFF)) {
    fprintf(stderr, "Failure (%d) trying to initialize database %s with <%s>\n", rc, *keydb, dbcmdbuff);
    return 4;
  }

  /*
   * Next, import the PEM file (CA Certificate).
   * I could not figure out how to do this via the command line :(
   */
 
  if ((rc = snprintf(dbcmdstreambuff, sizeof(dbcmdstreambuff), "%s%s%s%s%s%s%s%s%s", OPEN_DB, *keydb, "\n", 
    DB_PASSWORD_NL, IMPORT_CA, pem, "\n", CA_LABEL, RETURN, EXIT)) > sizeof(dbcmdstreambuff)) {
    fprintf(stderr, "Internal error: buffer too small\n");
    return 4;
  }

  if ((rc = snprintf(dbcmdbuff, sizeof(dbcmdbuff), "echo \"%s\" | gskkyman >/dev/null 2>&1", dbcmdstreambuff)) > sizeof(dbcmdbuff)) {
    fprintf(stderr, "Internal error: buffer too small\n");
    return 4;
  }
  if (rc = (system(dbcmdbuff) & 0xFF)) {
    fprintf(stderr, "Failure (%d) trying to import certificate file into database %s with <%s>\n", rc, *keydb, dbcmdbuff);
    return 4;
  }

  /*
   * Now we can use a more natural command line to import the pem file and export the stash file
   * The reqdb file and stashfile will be created in the same directory with the same file name but a 
   * different extension. It is unfortunate this can not be controlled but the genfilenames() above
   * does the right thing and will ensure the kdb, reqdb, stashfile names are all consistent 
   * (same directory, same file name, different extension)
   */

  if ((rc = snprintf(dbcmdbuff, sizeof(dbcmdbuff), "echo \"%s\" | gskkyman -s -k %s >/dev/null 2>&1", DB_PASSWORD, *keydb)) > sizeof(dbcmdbuff)) {
    fprintf(stderr, "Internal error: buffer too small\n");
    return 4;
  }
  if (rc = (system(dbcmdbuff) & 0xFF)) {
    fprintf(stderr, "Failure (%d) trying to extract stash file %s from %s <%s>\n", rc, *stashfile, *keydb, dbcmdbuff);
    return 4;
  }

  if ((rc = snprintf(dbcmdbuff, sizeof(dbcmdbuff), "echo \"%s\" | gskkyman -s -k %s >/dev/null 2>&1", DB_PASSWORD, *keydb)) > sizeof(dbcmdbuff)) {
    fprintf(stderr, "Internal error: buffer too small\n");
    return 4;
  }
  if (rc = (system(dbcmdbuff) & 0xFF)) {
    fprintf(stderr, "Failure (%d) trying to extract stash file %s from %s <%s>\n", rc, stashfile, *keydb, dbcmdbuff);
    return 4;
  }

  return 0;
}
