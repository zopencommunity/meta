#include "createdb.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int removedb(const char* keydb, const char* reqdb, const char* stashfile) {
  int rc1 = remove(keydb);
  int rc2 = remove(reqdb);
  int rc3 = remove(stashfile);

  return rc1 | rc2 | rc3;
}
  
int createdb(const char* pem, const char* keydb, const char* reqdb, const char* stashfile) {
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
 
  if ((rc = snprintf(dbcmdstreambuff, sizeof(dbcmdstreambuff), "%s%s%s%s%s%s%s%s%s%s", CREATE_DB, keydb, "\n", 
    DB_PASSWORD_NL, DB_PASSWORD_NL, DB_EXPIRE, DB_RECLEN, FIPS_MODE, RETURN, EXIT)) > sizeof(dbcmdstreambuff)) {
    fprintf(stderr, "Internal error: buffer too small\n");
    return 4;
  }

  if ((rc = snprintf(dbcmdbuff, sizeof(dbcmdbuff), "echo \"%s\" | gskkyman >/dev/null 2>&1", dbcmdstreambuff)) > sizeof(dbcmdbuff)) {
    fprintf(stderr, "Internal error: buffer too small\n");
    return 4;
  }
  if (rc = (system(dbcmdbuff) & 0xFF)) {
    fprintf(stderr, "Failure (%d) trying to initialize database %s with <%s>\n", rc, keydb, dbcmdbuff);
    return 4;
  }

  /*
   * Next, import the PEM file (CA Certificate).
   * I could not figure out how to do this via the command line :(
   */
 
  if ((rc = snprintf(dbcmdstreambuff, sizeof(dbcmdstreambuff), "%s%s%s%s%s%s%s%s%s", OPEN_DB, keydb, "\n", 
    DB_PASSWORD_NL, IMPORT_CA, pem, "\n", CA_LABEL, RETURN, EXIT)) > sizeof(dbcmdstreambuff)) {
    fprintf(stderr, "Internal error: buffer too small\n");
    return 4;
  }

  if ((rc = snprintf(dbcmdbuff, sizeof(dbcmdbuff), "echo \"%s\" | gskkyman >/dev/null 2>&1", dbcmdstreambuff)) > sizeof(dbcmdbuff)) {
    fprintf(stderr, "Internal error: buffer too small\n");
    return 4;
  }
  if (rc = (system(dbcmdbuff) & 0xFF)) {
    fprintf(stderr, "Failure (%d) trying to import certificate file into database %s with <%s>\n", rc, keydb, dbcmdbuff);
    return 4;
  }

  /*
   * Now we can use a more natural command line to import the pem file and export the stash file
   */

  if ((rc = snprintf(dbcmdbuff, sizeof(dbcmdbuff), "echo \"%s\" | gskkyman -s -k %s >/dev/null 2>&1", DB_PASSWORD, keydb)) > sizeof(dbcmdbuff)) {
    fprintf(stderr, "Internal error: buffer too small\n");
    return 4;
  }
  if (rc = (system(dbcmdbuff) & 0xFF)) {
    fprintf(stderr, "Failure (%d) trying to extract stash file %s from %s <%s>\n", rc, stashfile, keydb, dbcmdbuff);
    return 4;
  }

  if ((rc = snprintf(dbcmdbuff, sizeof(dbcmdbuff), "echo \"%s\" | gskkyman -s -k %s >/dev/null 2>&1", DB_PASSWORD, keydb)) > sizeof(dbcmdbuff)) {
    fprintf(stderr, "Internal error: buffer too small\n");
    return 4;
  }
  if (rc = (system(dbcmdbuff) & 0xFF)) {
    fprintf(stderr, "Failure (%d) trying to extract stash file %s from %s <%s>\n", rc, stashfile, keydb, dbcmdbuff);
    return 4;
  }

  return 0;
}
