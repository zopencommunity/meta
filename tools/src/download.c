/* START OF SPECIFICATIONS *********************************************
 * Beginning of Copyright and License                                  *
 *                                                                     *
 * Copyright 2019 IBM Corp.                                            *
 *                                                                     *
 * Licensed under the Apache License, Version 2.0 (the "License");     *
 * you may not use this file except in compliance with the License.    *
 * You may obtain a copy of the License at                             *
 *                                                                     *
 * http://www.apache.org/licenses/LICENSE-2.0                          *
 *                                                                     *
 * Unless required by applicable law or agreed to in writing,          *
 * software distributed under the License is distributed on an         *
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,        *
 * either express or implied.  See the License for the specific        *
 * language governing permissions and limitations under the License.   *
 *                                                                     *
 * End of Copyright and License                                        *
 */

/*
 * This code is derived from:
 *   https://github.com/IBM/zOS-Client-Web-Enablement-Toolkit/tree/master/Example-Download
 * and has been restricted to just support a download of a binary file from an https URL
 ***********************************************************************
 *                                                                     *
 *    DESCRIPTIVE NAME=  Download to File using the Web                *
 *                       Enablement Toolkit                            *
 *                                                                     *
 *    FUNCTION                                                         *
 *     Use streaming receive on an Http(s) GET request to obtain       *
 *     uri content, and write that content to a designated Hfs/Zfs     *
 *     file, or sequential (PS) dataset with canonical attributes.     *
 *                                                                     *
 *     If designating a File, the user specifies an absolute pathname  *
 *     to a valid location which should have sufficient capacity.      *
 *     If designating a Dataset, the user should pre-allocate the      *
 *     dataset to have sufficient capacity.                            *
 *                                                                     *
 *     In all cases, should the content being downloaded exceed the    *
 *     fs or dataset capacity, the program will fail with messages     *
 *     indicating how much data was, and was not written (to inform    *
 *     the user on how to better-prepare on a repeat attempt).         *
 *                                                                     *
 *                                                                     *
 *    USAGE                                                            *
 *     (required)                                                      *
 *     -f|-F  to specify "from" (the URI which designates the remote   *
 *            content to be downloaded)                                *
 *     -t|-T  to specify "to" (the dataset or file where the           *
 *            downloaded content is to be stored (see NOTE(S) below    *
 *            for expected attributes of datasets).                    *
 *                                                                     *
 *     (optional)                                                      *
 *     -c|-C  to specify "user:password" credential for access         *
 *     -k|-K  to specify a certificate keystore to be used in          *
 *            establishing a secure (https) connection to host         *
 *     -s|-S  to specify a password stashfile associated with the      *
 *            certificate keystore (if appropriate)                    *
 *     -v|-V  to specify that verbose toolkit Trace is desired         *
 *                                                                     *
 *    NOTE(S):                                                         *
 *                                                                     *
 *     Any dataset specified must be Physical Sequential (DSORG=PS),   *
 *     Fixed-Blocked (RECF=FB), with record size (LRECL=) 1024.        *
 *                                                                     *
 *     Currently the toolkit supports a keystore which is either a     *
 *     SAF keyring (in which case any notion of stashfile is n/a),     *
 *     or a keyring created using the SystemSSL gskkyman utility.      *
 *     In this case, an associated stashfile is needed so that         *
 *     SystemSSL may access the keyring contents.  Regardless of       *
 *     format, the given keystore must be made to contain the          *
 *     certificate of the CA (certificate authority) which issued      *
 *     the certificate used by the web server.  Note that a newly-     *
 *     created keystore will typically contain many of the prevalent   *
 *     CA certificates.  If your initial attempts at secure connection *
 *     fail, begin by checking for missing or expired certificate.     *
 *                                                                     *
 * END OF SPECIFICATIONS * * * * * * * * * * * * * * * * * * * * * * **/
#pragma langlvl(extc99)
#define _ALL_SOURCE
#define _LARGE_FILES
#define  _XOPEN_SOURCE_EXTENDED 1
#include <strings.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdbool.h>
#include <sys/stat.h>
#include <sys/uio.h>
#include <sys/types.h>
#include "hwthic.h"          /* toolkit constants */

/***************************
 * constants for args.
 ***************************/
static const char *OPTION_FROM          = "-f";
static const char *OPTION_TO            = "-t";
static const char *OPTION_CRED          = "-c";
static const char *OPTION_KEYRING       = "-k";
static const char *OPTION_STASHFILE     = "-s";
static const char *OPTION_TOOLKIT_TRACE = "-v";

/*******************************************************
 * Constants for file I/O.  Our streaming receive exit
 * will present 1 Meg. of read capacity (120@4096) to
 * the sockets layer on each callback.  Increasing this
 * does not *appear* in practice to increase throughput.
 *******************************************************/
#define NUM_BUFFERS  120        /* IOV_MAX defined in limits.h */
#define BUFFER_SIZE  4096
#define FREAD_OK     0
#define FREAD_EOF    1
#define FREAD_ERROR  2

#define IOTYPE_DATASET 1
#define IOTYPE_FILE    2

#define ABEND_SHORTAGE_B37  2871     /* B37x system abend code */
#define ABEND_SHORTAGE_D37  3383     /* D37x system abend code */

#define MAX_DSNAME_LEN     44         /* by convention */
#define MAX_HOSTNAME_LEN   63         /* reasonable */
#define MAX_URI_LEN        511        /* generous */
#define MAX_PATH_LEN       255        /* reasonable */
#define MAX_USERID_LEN     8          /* pragmatic */
#define MAX_PASSWORD_LEN   8          /* pragmatic */

#define SCHEME_HTTP   1
#define SCHEME_HTTPS  2

#define MEGABYTE  1024*1024
#define EMIT_MSG_INTERVAL 50*MEGABYTE   /* for progress msgs */

#define DS_LRECL 1024              /* TRSMAIN convention */
char *DS_FORMAT = "FB";            /* TRSMAIN convention */
char *DS_TYPE = "blocked";         /* TRSMAIN convention */

/****************************
 * constants for http status
 ****************************/
#define HTTP_RC_OK        200
#define HTTP_RC_CREATED   201
#define HTTP_RC_REDIRECT  302 
#define HTTP_RC_UNAUTHORIZED 401
#define HTTP_RC_FORBIDDEN 403

/********************************
 * variables and constants which
 * define the download
 ********************************/
struct parmStruct {
	bool traceToolkit;
	int  ioType;
	int  connectScheme;
	int  connectPort;                        /* from uri parse */
	char connectHost[1+MAX_HOSTNAME_LEN];    /* from uri parse */
	char requestUri[1+MAX_URI_LEN];          /* from uri parse */
	char fileOrDsname[1+MAX_PATH_LEN];
	char userid[1+MAX_USERID_LEN];
	char password[1+MAX_PASSWORD_LEN];
	char sslKeyring[1+MAX_PATH_LEN];
	char sslStashfile[1+MAX_PATH_LEN];
	bool sslOption;
};

/***********************************************************
 * Data area used by callback(s).
 ***********************************************************/

/*************************************************************
 * The Streaming Receive callback must provide a list which
 * describes one or more data buffers (the "supplylist") into
 * which the toolkit will write the next receivable data.
 * We will use <bufferList> and <bufferListSize> to describe
 * the list.  The Receive callback will record the http
 * Status Code and the <numBytesReceived> once the receive
 * has completed.
 * The received data will be written either to file or to
 * dataset, per the program arguments.  This file or dataset
 * remains open across callbacks via <fp>.  The callback
 * writes data as it consumes its current payload.  In the
 * dataset case, writes are record-based, as determined by
 * the LRECL of the dataset, and we will typically be carrying
 * over a residual fragment from a previous callback, of size
 * <dsRecordBytesUsed>.
 * If the file or dataset lacks capacity to hold the entirety
 * of received data, receive *may* need to complete (suppressing
 * writes), in order to convey <numBytesReceived>, the capacity
 * required for a successful next attempt.  This will depend
 * upon whether or not the (server) endpoint returned an http
 * <Content-Length: NN> response header, which the headers exit
 * would have recorded in <knownContentLength>.
 *************************************************************/
struct  receiveUserData {
	char eyecatcher[8];
	HWTH_STREAM_DATADESC_TYPE *bufferList;
	int  bufferListSize;
	int  httpStatusCode;
	int64_t  numBytesReceived;
	int64_t  numBytesWritten;
	int64_t  lastEmitMsgBytes;
	int64_t  knownContentLength;           /* perhaps */
	FILE  *fp;
	int  ioType;
	/*****************************
	 * For ioType == IOTYPE_FILE
	 *****************************/
	char  filePath[1+MAX_PATH_LEN];
	int   fwriteErrno;
	/*******************************
	 * For ioType == IOTYPE_DATASET
	 *******************************/
	char  datasetName[6+MAX_DSNAME_LEN];    /* enveloped */
	unsigned short  dsWriteAbendCode;
	unsigned short  dsWriteAbendRsn;
	int   dsRecordBytesUsed;    /* for persisting fragments */
	char  dsRecord[DS_LRECL];
};
static struct receiveUserData receiveData;

/*******************************************
 * Define connection and request constants
 *******************************************/
const char *HTTP_SCHEME = "http";
const char *HTTPS_SCHEME = "https";

/***************************************************
 * Functions used to prepare toolkit Handles, and
 * drive the Http protocol thru the toolkit
 ***************************************************/
int  setupConnection( HWTH_HANDLE_TYPE  *connectHandlePtr,
		struct parmStruct *parmsPtr );

int  setupRequest( HWTH_HANDLE_TYPE  *requestHandlePtr,
		struct parmStruct *parmsPtr );

int  setStreamingRecvExit( HWTH_RETURNCODE_TYPE  *rcPtr,
		HWTH_HANDLE_TYPE      *requestHandlePtr,
		HWTHRCVX              *exitPtr,
		void                  *userdataPtr,
		HWTH_DIAGAREA_TYPE    *diagAreaPtr );

int  setResponseHeadersExit( HWTH_RETURNCODE_TYPE *rcPtr,
		HWTH_HANDLE_TYPE     *requestHandlePtr,
		HWTHHDRX             *headersExitPtr,
		void                 *userDataPtr,
		HWTH_DIAGAREA_TYPE   *diagAreaPtr );

void surfaceToolkitDiag( HWTH_RETURNCODE_TYPE  *rcPtr,
		HWTH_DIAGAREA_TYPE    *diagAreaPtr );

/********************************
 * Assorted Utility functions
 ********************************/
 int  getDownloadParms( int argc,
		 char **argv,
		 struct parmStruct *pParms );

void summarize( struct parmStruct *pParms,
		struct receiveUserData *pRecvData,
		HWTH_RETURNCODE_TYPE toolkitRc );

char *getConnectScheme( struct parmStruct *pParms );

int  parseUri( char *value, struct parmStruct *pParms );
int  setFileOrDsname( char *value, struct parmStruct *pParms );
int  setCred( char *value, struct parmStruct *pParms );
int  setUserid( char *value, char *pUserid );
int  setPassword( char *value, char *pPassword );
int  setKeyring( char *value, char *pKeyring );
int  setStashfile( char *value, char *pStashfile );

void usage();
int  fatalError( char *where );

int  initReceive( struct receiveUserData *pRecvData );
void termReceive( struct receiveUserData *pUserData );

int  getBuffersList( HWTH_STREAM_DATADESC_TYPE **listRef,
		int listSize,
		int bufferSize );

void freeBuffersList( HWTH_STREAM_DATADESC_TYPE **listRef,
		int listSize );

void consumeNextResponseData( HWTH_STREAM_DATADESC_TYPE *returnList,
		int listSize,
		struct receiveUserData *pUserData );

void finalizeResponseData( struct receiveUserData *pUserData );

FILE *openSequentialDSForWrite( char *canonicalDsName,
		char *dsRecfm,
		char *dsType,
		int   dsLrecl );

FILE *openFileForWrite( char *filePath );

void writeToSequentialDataset( struct receiveUserData *pUserData,
		char *dataAddr,
		int dataLength );

void writeToFile( struct receiveUserData *pUserData,
		char *dataAddr,
		int dataLength );

int checkHttpStatus( int httpStatusCode );

int setupSSL( HWTH_HANDLE_TYPE  *connectHandlePtr,
		struct parmStruct *parmsPtr );

void trace( char *traceString );
void hxtrace( char *traceString );
void rxtrace( char *traceString );

char *diagRsnString( uint32_t diagRsn );

/****************************************
 * Thin wrappers for toolkit functions
 ****************************************/
 int toolkitInitHandle( HWTH_RETURNCODE_TYPE *rcPtr,
		 HWTH_HANDLETYPE_TYPE  whichType,
		 HWTH_HANDLE_TYPE     *handlePtr,
		 HWTH_DIAGAREA_TYPE   *diagAreaPtr );

int toolkitConnect( HWTH_HANDLE_TYPE  *connectHandlePtr );

void toolkitDisconnect( HWTH_HANDLE_TYPE  *connectHandlePtr );

int toolkitRequest( HWTH_HANDLE_TYPE  *connectHandlePtr,
		HWTH_HANDLE_TYPE  *requestHandlePtr );

void toolkitTerminate( HWTH_HANDLE_TYPE  *handlePtr );

int toolkitSetOption( HWTH_RETURNCODE_TYPE *rcPtr,
		HWTH_HANDLE_TYPE     *handlePtr,
		HWTH_SET_OPTION_TYPE  option,
		void                **optionValueRef,
		uint32_t              optionValueLength,
		HWTH_DIAGAREA_TYPE   *diagAreaPtr );

int  setRequestHeaders( HWTH_RETURNCODE_TYPE *rcPtr,
                        HWTH_HANDLE_TYPE     *requestHandlePtr,
                        HWTH_DIAGAREA_TYPE   *diagAreaPtr );
char  **getRequestHeaders(void);
void  freeRequestHeaders( char **headersList );
int toolkitSlistOperation( HWTH_RETURNCODE_TYPE    *rcPtr,
                           HWTH_HANDLE_TYPE        *handlePtr,
                           HWTH_SLST_FUNCTION_TYPE  whichFunction,
                           HWTH_SLIST_TYPE         *sListPtr,
                           char                   **stringRef,
                           uint32_t                 stringLength,
                           HWTH_DIAGAREA_TYPE      *diagAreaPtr );

#define MAX_TOKEN_PAYLOAD 16536       /* generous */
#define MAX_URI_LEN        511        /* generous */
#define MAX_PATH_LEN       255        /* reasonable */

/**************
 * Callbacks
 **************/
 HWTHRCVX  recvexit;                  /* streaming receive */
 int       httpStatusCode;            /* http status       */
 HWTHHDRX  rhdrexit;                  /* response headers  */

#ifdef HAS_MAIN
 int main( int argc, char **argv ) {
#else
 #include "download.h"
 int download(const char* host, const char* uri, const char* output, const char* keyring, const char* stashfile) {
#endif

	 HWTH_HANDLE_TYPE  connectHandle;
	 HWTH_HANDLE_TYPE  requestHandle;
	 HWTH_RETURNCODE_TYPE  toolkitRc;
#ifdef HAS_MAIN
	 struct parmStruct downloadParms;
#else
	 struct parmStruct downloadParms = { false, IOTYPE_FILE, SCHEME_HTTPS };
#endif
	 char  msgBuf[80];
   int rc;

#ifdef HAS_MAIN
	 if ( getDownloadParms( argc, argv, &downloadParms ) ) {
		 usage();
		 return ( fatalError( "Invalid argument(s)" ) );
	 }
#else
   strncpy(downloadParms.connectHost, host, MAX_HOSTNAME_LEN+1);
   strncpy(downloadParms.requestUri, uri, MAX_URI_LEN+1);
   strncpy(downloadParms.fileOrDsname, output, MAX_PATH_LEN+1);
   strncpy(downloadParms.sslKeyring, keyring, MAX_PATH_LEN+1);
   strncpy(downloadParms.sslStashfile, stashfile, MAX_PATH_LEN+1);
   downloadParms.traceToolkit = false;
   downloadParms.sslOption = true;
#endif

#if VERY_VERBOSE
         printf("HTTPS Download https:%s/%s to %s\n", host, uri, output);
#endif

	 if ( setupConnection( &connectHandle, &downloadParms ) )
		 return ( fatalError( "Setup (connection)" ) );

	 if ( setupRequest( &requestHandle, &downloadParms ) )
		 return ( fatalError( "Setup (request)" ) );

	 if ( toolkitConnect( &connectHandle ) )
		 return ( fatalError( "Connect" ) );

	 toolkitRc = toolkitRequest( &connectHandle, &requestHandle );

	 toolkitTerminate( &requestHandle );
	 toolkitDisconnect( &connectHandle );
	 toolkitTerminate( &connectHandle );

	 summarize( &downloadParms, &receiveData, toolkitRc );

	 rc = checkHttpStatus(httpStatusCode);
   return (rc == HTTP_RC_OK) ? 0 : rc; 
 }  /* end main */


 /*****************************************************
  * Function:  getDownloadParms()
  *
  * Returns: 0 if successful, -1 if not
  *****************************************************/
 int getDownloadParms( int argc,
		 char **argv,
		 struct parmStruct *pParms ) {

	 int i, parmErrors = 0;
	 char *nextOpt, *nextVal;
	 char traceBuf[80];

	 memset( pParms, 0, sizeof(struct parmStruct) );
	 pParms->sslOption = false;
	 pParms->traceToolkit = false;

	 /*****************************************************
	  * Skip the first arg (which will always be program
	  * name), and process each single <opt>, or
	  * <opt> <value> pair...
	  ****************************************************/
	 i = 1;
	 while ( i < argc ) {
		 nextOpt = argv[i];
		 nextVal = argv[i+1];
		 if ( strcasecmp( nextOpt, OPTION_FROM ) == 0 ) {
			 parmErrors += parseUri( nextVal, pParms );
			 i += 2;
		 }
		 else if ( strcasecmp( nextOpt, OPTION_TO ) == 0 ) {
			 parmErrors += setFileOrDsname( nextVal, pParms );
			 i += 2;
		 }
		 else if ( strcasecmp( nextOpt, OPTION_CRED ) == 0 ) {
			 parmErrors += setCred( nextVal, pParms );
			 i += 2;
		 }
		 else if ( strcasecmp( nextOpt, OPTION_KEYRING ) == 0 ) {
			 parmErrors += setKeyring( nextVal, &pParms->sslKeyring[0] );
			 pParms->sslOption = true;
			 i += 2;
		 }
		 else if ( strcasecmp( nextOpt, OPTION_STASHFILE ) == 0 ) {
			 parmErrors += setStashfile( nextVal, &pParms->sslStashfile[0] );
			 i += 2;
		 }
		 else if ( strcasecmp( nextOpt, OPTION_TOOLKIT_TRACE ) == 0 ) {
			 pParms->traceToolkit = true;
			 i += 1;
		 }
		 else {
			 sprintf( traceBuf,
					 "Unrecognized option: %s",
					 nextOpt );
			 trace( traceBuf );
			 parmErrors += -1;
			 i = argc;
		 }
	 } /* endloop thru args */


	 /***********************************************
	  * Check that requiredness conditions are met.
	  **********************************************/
	 if ( pParms->connectScheme == 0 ) {
		 trace( "Parse failure: <Scheme>" );
		 parmErrors += -1;
	 }
	 else {
		 sprintf( traceBuf,
				 "Using connect scheme: %s",
				 getConnectScheme( pParms ) );
		 trace( traceBuf );
	 }

	 if ( strlen(pParms->connectHost) ) {
		 sprintf( traceBuf,
				 "Using host: %s",
				 pParms->connectHost );
		 trace( traceBuf );
	 }
	 else {
		 trace( "Parse failure: <Host>" );
		 parmErrors += -1;
	 }

	 if ( strlen(pParms->requestUri) ) {
		 sprintf( traceBuf,
				 "Using requestUri: %s",
				 pParms->requestUri );
		 trace( traceBuf );
	 }
	 else {
		 trace( "Parse failure: <requestUri>" );
		 parmErrors += -1;
	 }

	 if ( strlen(pParms->fileOrDsname) ) {
		 sprintf( traceBuf,
				 "Using file (or dataset): %s",
				 pParms->fileOrDsname );
		 trace( traceBuf );
	 }
	 else {
		 trace( "Required <file or dataset> not specified" );
		 parmErrors += -1;
	 }

	 if ( pParms->connectPort ) {
		 sprintf( traceBuf,
				 "Using connect port: %d",
				 pParms->connectPort );
		 trace( traceBuf );
	 }

	 /*************************
	  * Surface any optionals
	  *************************/
	 if ( strlen(pParms->userid) ) {
		 sprintf( traceBuf,
				 "Using userid: %s",
				 pParms->userid );
		 trace( traceBuf );
	 }

	 if ( strlen(pParms->password) ) {
		 trace( "Using supplied password" );       /* no blabbermouth */
	 }

	 if ( strlen( pParms->sslKeyring ) ) {
		 sprintf( traceBuf,
				 "Using keyring: %s",
				 pParms->sslKeyring );
		 trace( traceBuf );
	 }

	 if ( strlen( pParms->sslStashfile ) ) {
		 sprintf( traceBuf,
				 "Using stashfile: %s",
				 pParms->sslStashfile );
		 trace( traceBuf );

		 if ( !pParms->sslOption ) {
			 trace( "Missing required keyring." );
			 parmErrors += -1;
		 }
	 }

	 if ( pParms->traceToolkit )
		 trace( "Toolkit Tracing is enabled" );

	 return ( parmErrors );

 }


 /*****************************************************
  * Function:  usage()
  *
  * Surface required invocation details
  *
  *****************************************************/
 void usage() {

	 static char traceBuf[256];

	 trace( "\nUsage: " );
	 sprintf( traceBuf,
			 "\tRequired:\t%s %s %s %s",
			 OPTION_FROM,
			 "<from uri>",
			 OPTION_TO,
			 "<to file or dataset>" );
	 trace( traceBuf );
	 sprintf( traceBuf,
			 "\tOptional:\t%s %s %s %s %s %s %s",
			 OPTION_CRED,
			 "<user:password>",
			 OPTION_KEYRING,
			 "<keyring>",
			 OPTION_STASHFILE,
			 "<stashfile>",
			 OPTION_TOOLKIT_TRACE );
	 trace( traceBuf );

 }


 /*****************************************************
  * Function:  fatalError()
  *
  * Returns: contents of input rc parameter, or -1
  *****************************************************/
 int fatalError( char *where ) {

	 char traceBuf[256];          /* accomodate big where string */

	 sprintf( traceBuf,
			 "\nFATAL ERROR encountered [%s]",
			 where );
	 trace( traceBuf );

	 return -1;
 }


 /*****************************************************
  * Function: setupConnection()
  *
  * Instantiate a connection handle, and set
  * the appropriate options prior to connect.
  *
  * Returns: 0 if successful, -1 if not
  *****************************************************/
 int setupConnection( HWTH_HANDLE_TYPE  *connectHandlePtr,
		 struct parmStruct *parmsPtr ) {

	 HWTH_RETURNCODE_TYPE  rc = HWTH_OK;
	 HWTH_DIAGAREA_TYPE    diagArea;

	 uint32_t   intOption;
	 uint32_t  *intOptionPtr = &intOption;
	 int        connectPort;
	 char       connectUri[128];
	 char       traceBuf[256];
	 char      *stringOptionPtr;
	 char      *schemePtr = getConnectScheme( parmsPtr );

	 memset( &diagArea, 0, sizeof(HWTH_DIAGAREA_TYPE) );

	 /************************************************
	  * Obtain the work area for the connection handle
	  ************************************************/
	 if ( toolkitInitHandle( &rc,
			 HWTH_HANDLETYPE_CONNECTION,
			 connectHandlePtr,
			 &diagArea ) )
		 return -1;

	 /************************************************
	  * Now set all the various attributes for the
	  * server you'll be connection to, this is also
	  * where you'd turn on tracing.
	  ************************************************/
	 if ( parmsPtr->traceToolkit ) {

		 intOption = HWTH_VERBOSE_UNREDACTED;

		 if ( toolkitSetOption( &rc,
				 connectHandlePtr,
				 HWTH_OPT_VERBOSE,
				 (void **)&intOptionPtr,
				 sizeof(intOption),
				 &diagArea ) )
			 return -1;
     }

	 /************************************************************
	  * Form and set the connection URI (Note that the toolkit
	  * handles the PORT independently, and we *may* do that next)
	  ************************************************************/
	 sprintf( connectUri,
			 "%s://%s",
			 schemePtr,
			 parmsPtr->connectHost );
	 stringOptionPtr = connectUri;

	 if ( toolkitSetOption( &rc,
			 connectHandlePtr,
			 HWTH_OPT_URI,
			 (void **)&stringOptionPtr,
			 strlen(connectUri),
			 &diagArea ) )
		 return -1;

	 if (parmsPtr->connectPort) {

		 intOption = parmsPtr->connectPort;

		 if ( toolkitSetOption( &rc,
				 connectHandlePtr,
				 HWTH_OPT_PORT,
				 (void **)&intOptionPtr,
				 sizeof(intOption),
				 &diagArea ) )
			 return -1;
	 }

     intOption = 50;
     if ( toolkitSetOption( &rc,
				 connectHandlePtr,
				 HWTH_OPT_MAX_REDIRECTS,
				 (void **)&intOptionPtr,
				 sizeof(intOption),
				 &diagArea ) )
			 return -1;

   /* allow for cross domain redirects */
	 intOption = HWTH_XDOMAIN_REDIRS_ALLOWED;
     if ( toolkitSetOption( &rc,
				 connectHandlePtr,
				 HWTH_OPT_XDOMAIN_REDIRECTS,
				 (void **)&intOptionPtr,
				 sizeof(intOption),
				 &diagArea ) )
			 return -1;

	 /*************************************************
	  * If the user has provided explicit ssl-related
	  * option(s), set them now.
	  *************************************************/
	 if ( strcmp( schemePtr, HTTPS_SCHEME ) == 0 &&
			 parmsPtr->sslOption)
		 return setupSSL( connectHandlePtr, parmsPtr );

	 return 0;
 }


 /*****************************************************
  * Function: setupRequest()
  *
  * Instantiate a request handle, and set the
  * appropriate options prior to making request.
  *
  * Returns: 0 if successful, -1 if not
  *****************************************************/
 int  setupRequest( HWTH_HANDLE_TYPE  *requestHandlePtr,
		 struct parmStruct *parmsPtr )  {

	 HWTH_RETURNCODE_TYPE  rc = HWTH_OK;
	 HWTH_DIAGAREA_TYPE  diagArea;
	 uint32_t     intOption;
	 uint32_t    *intOptionPtr = &intOption;
	 char        *stringOptionPtr;
	 char        *requestPath = parmsPtr->requestUri;
	 char        *hostUserid = parmsPtr->userid;
	 char        *hostPassword = parmsPtr->password;
	 char        *requestMethod;
	 char         traceBuf[256];

	 memset( &diagArea, 0, sizeof(HWTH_DIAGAREA_TYPE) );

	 /*********************************************
	  * Obtain the work area for the request handle
	  *********************************************/
	 if ( toolkitInitHandle( &rc,
			 HWTH_HANDLETYPE_HTTPREQUEST,
			 requestHandlePtr,
			 &diagArea ) )
		 return -1;

	 /************************************************
	  * Now set all the various attributes for the
	  * resource, that's located on the server,
	  * you're interested in.
	  ************************************************/
	 if ( toolkitSetOption( &rc,
			 requestHandlePtr,
			 HWTH_OPT_URI,
			 (void **)&requestPath,
			 strlen(requestPath),
			 &diagArea ) )
		 return -1;

	 intOption = HWTH_HTTP_REQUEST_GET;
	 if ( toolkitSetOption( &rc,
			 requestHandlePtr,
			 HWTH_OPT_REQUESTMETHOD,
			 (void **)&intOptionPtr,
			 sizeof(intOption),
			 &diagArea ) )
		 return -1;

   /*********************************************
   * Set the request headers.  This involves
   * SList processing, done in called routines.
   *********************************************/
  	if ( setRequestHeaders( &rc,
                          requestHandlePtr,
                         &diagArea) ) {
    	 trace( "Unable to set request header(s)" );
    	 return -1;
     }

	 /************************************************************
	  * If the user specified a credential (anticipating that the
	  * server requires basic client authentication), then set the
	  * authentication type, userid, and password accordingly.
	  ************************************************************/
	 if ( strlen( hostUserid ) ) {
		 intOption = HWTH_HTTPAUTH_BASIC;
		 if ( toolkitSetOption( &rc,
				 requestHandlePtr,
				 HWTH_OPT_HTTPAUTH,
				 (void **)&intOptionPtr,
				 sizeof(intOption),
				 &diagArea ) )
			 return -1;

		 stringOptionPtr = hostUserid;
		 if ( toolkitSetOption( &rc,
				 requestHandlePtr,
				 HWTH_OPT_USERNAME,
				 (void **)&stringOptionPtr,
				 strlen(hostUserid),
				 &diagArea ) )
			 return -1;

		 stringOptionPtr = hostPassword;
		 if ( toolkitSetOption( &rc,
				 requestHandlePtr,
				 HWTH_OPT_PASSWORD,
				 (void **)&stringOptionPtr,
				 strlen(hostPassword),
				 &diagArea ) )
			 return -1;
	 } /* endif credential exists */

	 /***********************************************
	  * Establish the streaming receive callback,
	  * with its own userdata area (which we now
	  * must prepare so that the receive exit
	  * knows what file or dataset to save into).
	  ***********************************************/
	 memset( &receiveData, 0, sizeof(receiveData) );
	 strcpy( receiveData.eyecatcher, "USRDATA" );
	 receiveData.ioType = parmsPtr->ioType;
	 if ( receiveData.ioType == IOTYPE_DATASET )
		 strcpy( receiveData.datasetName,
				 parmsPtr->fileOrDsname );
	 else
		 strcpy( receiveData.filePath,
				 parmsPtr->fileOrDsname );

	 if ( setStreamingRecvExit(  &rc,
			 requestHandlePtr,
			 &recvexit,
			 (void *)&receiveData,
			 &diagArea ) )
		 return -1;

	 /***********************************************
	  * Establish a second callback, this one for
	  * the response headers which precede any body.
	  * We can use the same userdata area we prepared
	  * above without fear of concurrent access
	  * because they inherently serialized (headers
	  * arrive and are processed before body).
	  ***********************************************/
	 if ( setResponseHeadersExit( &rc,
			 requestHandlePtr,
			 &rhdrexit,
			 (void *)&receiveData,
			 &diagArea ) )
		 return -1;

	 return 0;
 }

 /*******************************************************
  * Function:  toolkitInitHandle()
  *
  * Thin wrapper for hwthinit() toolkit service, which
  * should instantiate a handle of the designated type
  * and set the input handlePtr accordingly.
  *
  * Returns: 0 if successful, -1 if not
  *******************************************************/
 int toolkitInitHandle( HWTH_RETURNCODE_TYPE *rcPtr,
		 HWTH_HANDLETYPE_TYPE  whichType,
		 HWTH_HANDLE_TYPE     *handlePtr,
		 HWTH_DIAGAREA_TYPE   *diagAreaPtr ) {

	 hwthinit( rcPtr,
			 whichType,
			 handlePtr,
			 diagAreaPtr );
	 if ( *rcPtr == HWTH_OK )
		 return 0;

	 surfaceToolkitDiag( rcPtr, diagAreaPtr );
	 return -1;
 }

 /****************************************************************
  * Function: toolkitConnect()
  *
  * Thin wrapper for hwthconn() service, which should connect to
  * the endpoint designated by any options previously set for
  * the connection handle.
  *
  * Returns:  0 if successful, -1 if not
  ****************************************************************/
 int toolkitConnect( HWTH_HANDLE_TYPE  *connectHandlePtr ) {

	 HWTH_RETURNCODE_TYPE  rc = HWTH_OK;
	 HWTH_DIAGAREA_TYPE    diagArea;

	 hwthconn( &rc, *connectHandlePtr, &diagArea );
	 if ( rc == HWTH_OK )
		 return 0;

	 surfaceToolkitDiag( &rc, &diagArea );
	 return -1;

 }


 /****************************************************************
  * Function: toolkitDisconnect()
  *
  * Thin wrapper for hwthdisc() service, which should disconnect
  * from the endpoint to which we connected earlier.
  *
  ****************************************************************/
 void toolkitDisconnect( HWTH_HANDLE_TYPE  *connectHandlePtr ) {

	 HWTH_RETURNCODE_TYPE  rc = HWTH_OK;
	 HWTH_DIAGAREA_TYPE    diagArea;

	 hwthdisc( &rc, *connectHandlePtr, &diagArea );
	 if ( rc != HWTH_OK )
		 surfaceToolkitDiag( &rc, &diagArea );

 }


 /************************************************************
  * Function: toolkitRequest()
  *
  * Thin wrapper for hwthrqst() toolkit service, which should
  * execute the http request designated by any options
  * previously set for the request handle.
  *
  * Returns:  toolkit rc
  ************************************************************/
 int toolkitRequest( HWTH_HANDLE_TYPE  *connectHandlePtr,
		 HWTH_HANDLE_TYPE  *requestHandlePtr ) {

	 HWTH_RETURNCODE_TYPE  rc = HWTH_OK;
	 HWTH_DIAGAREA_TYPE    diagArea;

	 hwthrqst( &rc,
			 *connectHandlePtr,
			 *requestHandlePtr,
			 &diagArea );
	 if ( rc != HWTH_OK ) {
		 /* The HWTH_WARNING with reason code 1 is due to a redirect        */
     /* This is not an issue - redirects are normal - no message needed */
		 if (rc == HWTH_WARNING && diagArea.HWTH_reasonCode == 1) {
      rc = HWTH_OK;
		 } else {
       if (rc != HWTH_WARNING) {
		     trace("hwthrqst did not return an acceptable RC");
		     surfaceToolkitDiag( &rc, &diagArea );
       }
		 }
	 }
	 return rc;

 }


 /*************************************************************
  * Function: toolkitTerminate()
  *
  * Thin wrapper for hwthterm() toolkit service, which should
  * cleanup resources associated with the designated handle,
  * and free the handle instance.
  *
  ************************************************/
 void toolkitTerminate( HWTH_HANDLE_TYPE  *handlePtr ) {

	 HWTH_RETURNCODE_TYPE  rc = HWTH_OK;
	 HWTH_DIAGAREA_TYPE  diagArea;

	 hwthterm( &rc,
			 *handlePtr,
			 HWTH_NOFORCE,
			 &diagArea );
	 if ( rc != HWTH_OK )
		 surfaceToolkitDiag( &rc, &diagArea );

 }

/************************************************************
  * Function: toolkitSetOption()
  *
  * Thin wrapper for hwthset() toolkit service, which should
  * set the the designated value for the designated option
  * associated with the intput handle.
  *
  * Returns:  0 if successful, -1 if not
  ************************************************************/
 int toolkitSetOption( HWTH_RETURNCODE_TYPE *rcPtr,
		 HWTH_HANDLE_TYPE     *handlePtr,
		 HWTH_SET_OPTION_TYPE  option,
		 void                **optionValueRef,
		 uint32_t              optionValueLength,
		 HWTH_DIAGAREA_TYPE   *diagAreaPtr ) {

	 hwthset( rcPtr,
			 *handlePtr,
			 option,
			 optionValueRef,
			 optionValueLength,
			 diagAreaPtr );
	 if ( *rcPtr == HWTH_OK )
		 return 0;

	 surfaceToolkitDiag( rcPtr, diagAreaPtr );
	 return -1;

 }

 /************************************************************
  * function:  summarize()
  *
  * Returns: (void)
  ************************************************************/
 void summarize( struct parmStruct *pParms,
		 struct receiveUserData *pRecvData,
		 HWTH_RETURNCODE_TYPE toolkitRc ) {

	 char msgBuf[256];
	 int64_t downloadSize;

	 /***********************************************
	  * We set numBytesReceived only on full receipt
	  * of data.  Still, we allow for the possibility
	  * that a response header could have informed
	  * us of the content length
	  ***********************************************/
	 if ( pRecvData->numBytesReceived )
		 downloadSize = pRecvData->numBytesReceived;
	 else {
		 if ( toolkitRc == HWTH_OK ) {
			 sprintf( msgBuf,
					 "Http response code %d was received",
					 pRecvData->httpStatusCode );
			 trace( msgBuf );
		 }
		 else {
     #if 0
       /* for things like forbidden or redirect, no message needed */
			 sprintf( msgBuf,
					 "Toolkit failure rc %d was received",
					 toolkitRc );
			 trace( msgBuf );
     #endif
		 }
		 downloadSize = pRecvData->knownContentLength;
	 } /* endif lacking (full) response */

	 /******************************************************
	  * If we wrote anything, then we should talk about it
	  ******************************************************/
	 if ( pRecvData->numBytesWritten > 0 ) {
		 /************************************
		  * Announce the successful download
		  ************************************/
		 if ( pRecvData->numBytesWritten == pRecvData->numBytesReceived ) {
     #ifdef VERY_VERBOSE
			 sprintf( msgBuf,
					 "File successfully downloaded to %s (%lld bytes)",
					 pParms->fileOrDsname,
					 pRecvData->numBytesWritten );
			 trace( msgBuf );
     #endif
			 return;
		 }  /* endif successful download */

		 /*****************************************************
		  * If we know the size of the full response, then
		  * we are in a position to talk about capacity issues
		  *****************************************************/
		 if ( downloadSize ) {
			 sprintf( msgBuf,
					 "Only %lld of the %lld byte download could be written",
					 pRecvData->numBytesWritten,
					 downloadSize );
			 trace( msgBuf );

			 if ( pRecvData->ioType == IOTYPE_DATASET ) {
				 if ( pRecvData->dsWriteAbendCode ) {
					 sprintf( msgBuf,
							 "An I/O abend (%X-%X) was detected",
							 pRecvData->dsWriteAbendCode,
							 pRecvData->dsWriteAbendRsn );
					 trace( msgBuf );
				 } /* endif abend recorded */

				 if ( pRecvData->dsWriteAbendCode == ABEND_SHORTAGE_B37 ||
						 pRecvData->dsWriteAbendCode == ABEND_SHORTAGE_D37 )
					 trace( "Try preallocating a dataset with greater capacity" );
			 } /* endif using dataset */
			 else {
				 if ( pRecvData->fwriteErrno ) {
					 sprintf( msgBuf,
							 "Write error occurred (errno=%d)",
							 pRecvData->fwriteErrno );
					 trace( msgBuf );
				 } /* endif errno recorded */

				 if ( pRecvData->fwriteErrno == ENOSPC )
					 trace( "Try using a filesystem with greater capacity" );
			 } /* endif using file */
		 } /* endif full size known */
	 } /* endif write(s) occurred */

 }


 /************************************************************
  * function:  trace()
  *
  * Simple printf() wrapper, with prefixing.
  *
  * Returns: (void)
  ***********************************************************/
 void trace( char *S ) {
	 printf( "%s\n", S );
 }



 /************************************************************
  * function:  rxtrace()
  *
  * Simple printf() wrapper for streaming receive exit.
  *
  * Returns: (void)
  ***********************************************************/
 void rxtrace( char *S ) {
	 printf( "[recvexit] %s\n", S );
 }


 /************************************************************
  * function:  hxtrace()
  *
  * Simple printf() wrapper for response headers exit.
  *
  * Returns: (void)
  ***********************************************************/
 void hxtrace( char *S ) {
	 printf( "[rhdrexit] %s\n", S );
 }



 /******************************************************************
  * Function: setStreamingRecvExit()
  *
  * Sets options for the designated request handle with the
  * address of the streaming receive exit and an optional userdata
  * area for the send exit to use on callback(s) from toolkit.
  *
  * Returns:  0 if successful, -1 if not
  ******************************************************************/
 int  setStreamingRecvExit( HWTH_RETURNCODE_TYPE  *rcPtr,
		 HWTH_HANDLE_TYPE      *requestHandlePtr,
		 HWTHRCVX              *exitPtr,
		 void                  *userdataPtr,
		 HWTH_DIAGAREA_TYPE    *diagAreaPtr ) {

	 int exitOption = (int)*exitPtr;
	 void *exitOptionPtr = (void *)&exitOption;
	 int dataOption = (int)userdataPtr;
	 void *dataOptionPtr = (void *)&dataOption;

	 if ( toolkitSetOption( rcPtr,
			 requestHandlePtr,
			 HWTH_OPT_RESPONSEBODY_USERDATA,
			 &dataOptionPtr,
			 sizeof(dataOption),
			 diagAreaPtr ) ) {
		 trace( "Unable to set userdata" );
		 return -1;
	 }

	 if ( toolkitSetOption( rcPtr,
			 requestHandlePtr,
			 HWTH_OPT_STREAM_RECEIVE_EXIT,
			 &exitOptionPtr,
			 sizeof(exitOption),
			 diagAreaPtr ) ) {
		 trace( "Unable to set streaming receive exit" );
		 return -1;
	 }

	 return 0;
 }


 /*******************************************************
  * Function: getBuffersList()
  *
  * Allocates a set of uniformly-sized data buffers from
  * heap, along with an array of descriptors (in a format
  * the toolkit understands) which describe those buffers.
  * Set the input ref parameter accordingly.
  *
  * Returns: 0 if successful, -1 if not
  *******************************************************/
 int  getBuffersList( HWTH_STREAM_DATADESC_TYPE **buffListRef,
		 int listSize,
		 int bufferSize ) {

	 HWTH_STREAM_DATADESC_TYPE *buffList = NULL;
	 int i, capacity = 0;
	 char msgBuf[80];

	 /************************************************************
	  * Use calloc() to obtain an array of data descriptors from
	  * heap storage.  The calloc() library routine promises that
	  * these are pre-initialized to 0.
	  ************************************************************/
	 buffList = (HWTH_STREAM_DATADESC_TYPE *)calloc( listSize,
			 sizeof(HWTH_STREAM_DATADESC_TYPE) );
	 if ( buffList == NULL ) {
		 sprintf( msgBuf,
				 "Unexpected calloc() failure (%d)",
				 errno );
		 rxtrace( msgBuf );
		 *buffListRef = NULL;
		 return -1;
	 } /* endif unexpected calloc() faliure */

	 /**************************************************************
	  * Do repetitive malloc() calls to obtain corresponding buffers
	  * of uniform size, and set the corresponding data descriptor
	  * (array element) to describe the buffer addr and length.
	  **************************************************************/
	 for ( i = 0; i < listSize; i++ ) {
		 buffList[i].HWTH_dataAddr = (char *)malloc( bufferSize );
		 if ( buffList[i].HWTH_dataAddr == NULL ) {
			 sprintf( msgBuf,
					 "Unexpected Buffer malloc() failure (%d)",
					 errno );
			 rxtrace( msgBuf );
			 buffList[i].HWTH_dataLength = 0;
		 }
		 else {
			 buffList[i].HWTH_dataLength = bufferSize;
			 capacity += bufferSize;
		 } /* endif malloc() ok */
	 } /* endloop thru numBuffers */

	 /*************************************************************
	  * In the unlikely case that we were unable to obtain a
	  * complete list of buffers, free the partial list and fail.
	  *************************************************************/
	 if ( capacity != (listSize*bufferSize) ) {
		 freeBuffersList( &buffList, listSize );
		 return -1;
	 } /* endif incomplete */

	 *buffListRef = buffList;
	 return 0;
 }


 /*******************************************************
  * Function: freeBuffersList()
  *
  * Frees the heap resources from an earlier call to
  * getBuffersList()
  *
  * Returns: (void)
  *******************************************************/
 void freeBuffersList( HWTH_STREAM_DATADESC_TYPE **buffListRef,
		 int listSize ) {

	 HWTH_STREAM_DATADESC_TYPE *buffList = NULL;
	 int i;

	 if ( buffListRef != NULL )
		 buffList = *buffListRef;
	 if ( buffList == NULL | listSize < 0 ) {
		 rxtrace( "freeBuffersList() - unexpected parameter error" );
		 return;
	 }

	 /*******************************
	  * Free each referenced buffer
	  *******************************/
	 for ( i = 0; i < listSize; i++ ) {
		 if ( buffList[i].HWTH_dataAddr != NULL ) {
			 free( buffList[i].HWTH_dataAddr );
			 buffList[i].HWTH_dataAddr = NULL;
			 buffList[i].HWTH_dataLength = 0;
		 }
	 } /* endloop thru List */

	 /*********************************
	  * Free the array struct, itself
	  *********************************/
	 free( buffList );
	 *buffListRef = NULL;
 }


 /******************************************************
  * Function: recvexit()
  *
  * Streaming receive exit which receives a response
  * body, over the course of 1 or more callbacks (as
  * controlled by the state parameter).
  *
  * Returns:  (void)
  *******************************************************/
 void recvexit( HWTH_STREAM_PROGRESS_TYPE *pReceiveProgress,
		 int *pReceiveState,
		 HWTH_STREAM_DATADESC_TYPE **supplyListRef,
		 int *pSupplyListSize,
		 HWTH_STREAM_DATADESC_TYPE *pReturnList,
		 int *pReturnListSize ) {
	 struct receiveUserData *pUserData;
	 HWTH_STATUS_LINE_TYPE *pStatusLine;
	 int i;
	 char msgBuf[80];

	 /*************************************************
	  * Access the user data struct passed by main().
	  *************************************************/
	 pUserData =
			 *((struct receiveUserData **)pReceiveProgress->HWTH_userData);

	 /************************************************************
	  * Let's make sure that we have considered the HTTP status
	  * code for the request, in case that makes us disinterested
	  * in receiving a useless (and potentially large) response
	  * body (which we can avoid by aborting the receive).
	  ***********************************************************/
	 if ( pUserData->httpStatusCode == 0 ) {
		 pStatusLine = pReceiveProgress->HWTH_responseStatusLine;
		 pUserData->httpStatusCode = (int)(pStatusLine->HWTH_statusCode);
     httpStatusCode = pUserData->httpStatusCode; 
		 if (checkHttpStatus( pUserData->httpStatusCode ) != HTTP_RC_OK) {
			 *pReceiveState = HWTH_STREAM_RECEIVE_ABORT;
			 return;
		 } /* endif unacceptable http status code */
	 } /* endif status code not yet checked */

	 /*************************************************************
	  * Seeing totalBytes==0 in the progress descriptor tells us
	  * that this is the first callback.  In this case, there is
	  * there is no received data to consume, because we have not
	  * yet provided any storage buffer(s) to the toolkit.  We
	  * allocate a set of such buffers (whose number and size are
	  * completely of our choosing), as well as an array of
	  * descriptors in the format expected by the toolkit.  This
	  * will be our "supply list", which we anchor via our userdata
	  * area.  We also open the users dataset into which we will
	  * store the data as we receive it.
	  ************************************************************/
	 if ( pReceiveProgress->HWTH_totalBytes == 0 ) {
		 if ( initReceive( pUserData ) ) {
			 rxtrace( "aborting (init failure)" );
			 *pReceiveState = HWTH_STREAM_RECEIVE_ABORT;
			 return;
		 } /* endif init error */
	 } /* endif first callback */
	 else {
		 /*************************************************
		  * Maybe (only periodically) trace our progress
		  ************************************************/
		 if ( pReceiveProgress->HWTH_totalBytes -
				 pUserData->lastEmitMsgBytes >= EMIT_MSG_INTERVAL ) {
			 sprintf( msgBuf,
					 "%lld bytes received",
					 pReceiveProgress->HWTH_totalBytes );
			 rxtrace( msgBuf );
			 pUserData->lastEmitMsgBytes =
					 pReceiveProgress->HWTH_totalBytes;
		 }
	 } /* endif not first */

	 /************************************************
	  * Proceed per the current state, as appropriate
	  ************************************************/
	 switch (*pReceiveState) {
	 case HWTH_STREAM_RECEIVE_CONTINUE:
		 /*************************************************************
		  * In this (the most common) case, we are in the midst of the
		  * receive.  We consume the pieces of data indicated by the
		  * "return list", and re-supply the toolkit with a next buffer
		  * list, to hold the next payload.
		  *************************************************************/
		 consumeNextResponseData( pReturnList,
				 *pReturnListSize,
				 pUserData );
		 *supplyListRef = pUserData->bufferList;
		 *pSupplyListSize = pUserData->bufferListSize;
		 break; /* endif continue state */

	 case HWTH_STREAM_RECEIVE_EOD:
		 /*********************************************************
		  * In this case, the toolkit has indicated end-of-data.
		  * Consume any last data (there need not be any).  We
		  * acknowledge full receipt by changing the state to
		  * "complete".  This will be the final callback for this
		  * receive, so do any necessary cleanup before returning.
		  *********************************************************/
		 consumeNextResponseData( pReturnList,
				 *pReturnListSize,
				 pUserData );
		 finalizeResponseData( pUserData );
		 *pReceiveState = HWTH_STREAM_RECEIVE_COMPLETE;
		 pUserData->numBytesReceived =
				 pReceiveProgress->HWTH_totalBytes;
		 termReceive( pUserData );
		 break; /* endif end of data state */

	 case HWTH_STREAM_RECEIVE_ERROR:
		 /************************************************
		  * In this case the toolkit has encountered a
		  * fatal error (perhaps a dropped connection).
		  * This will be the final callback for this
		  * request, and do any necessary cleanup now
		  * before returning to the toolkit.
		  ************************************************/
		 termReceive( pUserData );
		 break;  /* endif error state */

	 default:
		 /****************************************************
		  * This case should not occur in practice, and is
		  * included here only as a projected best practice.
		  ****************************************************/
		 rxtrace( "state anomaly (setting ABORT state)" );
		 *pReceiveState = HWTH_STREAM_RECEIVE_ABORT;
		 break;  /* endif state anomaly */
	 } /* end switch on state */

 }


 /************************************************************
  * Function: initReceive()
  *
  * Initializes for streaming receive by anchoring the
  * (supply) list of data buffers.  Opens the file or dataset
  * to which the received data will be written.
  *
  * Returns: 0 if successful, -1 if not
  ************************************************************/
 int initReceive( struct receiveUserData *pUserData ) {

	 /***********************************************************
	  * Obtain a supplyList and associated buffers, which we
	  * can (re)use  on each callback to convey a next data
	  * payload.
	  ***********************************************************/
	 if ( getBuffersList( &pUserData->bufferList,
			 NUM_BUFFERS,
			 BUFFER_SIZE ) ) {
		 return -1;
	 } /* endif unable to obtain supplyList buffers */
	 else
		 pUserData->bufferListSize = NUM_BUFFERS;

	 /*********************************************************
	  * Open the designated file or dataset for binary write
	  *********************************************************/
	 if ( pUserData->ioType == IOTYPE_DATASET )
		 pUserData->fp = openSequentialDSForWrite( pUserData->datasetName,
				 DS_FORMAT,
				 DS_TYPE,
				 (int)DS_LRECL );
	 else
		 pUserData->fp = openFileForWrite( pUserData->filePath );

	 if ( pUserData->fp == NULL ) {
		 termReceive( pUserData );
		 return -1;
	 }  /* endif open failure */

	 return 0;
 }


 /*******************************************************
  * Function: termReceive()
  *
  * Undoes the effects of an earlier initReceive() call.
  *
  * Returns: (void)
  *******************************************************/
 void termReceive( struct receiveUserData *pUserData ) {

	 /***************************
	  * Close any open dataset
	  ***************************/
	 if ( pUserData->fp != NULL )
		 fclose( pUserData->fp );

	 /****************************************************
	  * Free any extant supplyList and associated buffers.
	  ****************************************************/
	 freeBuffersList( &pUserData->bufferList,
			 pUserData->bufferListSize );

 }

 /*******************************************************
  * Function: checkHttpStatus()
  *
  * Determines whether or not the designated http status
  * code (returned in the response headers) warrants
  * receipt of the response body.
  *
  * Returns: 0 if acceptable status, httpStatusCode if not
  *******************************************************/
 int  checkHttpStatus( int httpStatusCode ) {
	 int rc = -1;
	 char msgBuf[80];

	 switch ( httpStatusCode ) {
	 case HTTP_RC_CREATED:
	 case HTTP_RC_OK:
	 case HTTP_RC_REDIRECT:
		 rc = HTTP_RC_OK; /* map 'ok' stuff to rc_ok */
		 break;
	 case HTTP_RC_FORBIDDEN:
     rc = HTTP_RC_FORBIDDEN;
     break; /* this is an error - but we will not print a message about it */
	 case HTTP_RC_UNAUTHORIZED:
     rc = HTTP_RC_UNAUTHORIZED;
     break; /* this is an error - but we will not print a message about it */
	 default:
		 sprintf( msgBuf,
				 "Unexpected Http response code %d received",
				 httpStatusCode );
     rc = httpStatusCode;
       
		 rxtrace( msgBuf );
		 break;
	 } /* end switch */

	 return rc;
 }


 /***********************************************************
  * Function: diagRsnString()
  *
  * Of the many possible reason codes which might appear in
  * the diagarea, some are streaming-specific.  If the code
  * is one of these, return a string equivalent (just to
  * make streaming exit debug a bit quicker).
  *
  * Returns: ptr to string as described, or NULL
  ***********************************************************/
 char *diagRsnString( uint32_t diagRsn ) {

	 char *pRsnString = NULL;

	 switch( diagRsn ) {

	 case HWTH_RSN_MALFORMED_CHNK_ENCODE:
		 pRsnString = "HWTH_RSN_MALFORMED_CHNK_ENCODE";
		 break;
	 case HWTH_RSN_STREAM_SEND_EXIT_ABORT:
		 pRsnString = "HWTH_RSN_STREAM_SEND_EXIT_ABORT";
		 break;
	 case HWTH_RSN_STREAM_SEND_EXIT_INVALID:
		 pRsnString = "HWTH_RSN_STREAM_SEND_EXIT_INVALID";
		 break;
	 case HWTH_RSN_STREAM_SEND_EXIT_NODATA:
		 pRsnString = "HWTH_RSN_STREAM_SEND_EXIT_NODATA";
		 break;
	 case HWTH_RSN_STREAM_SEND_EXIT_STATE:
		 pRsnString = "HWTH_RSN_STREAM_SEND_EXIT_STATE";
		 break;
	 case HWTH_RSN_STREAM_RECV_EXIT_ABORT:
		 pRsnString = "HWTH_RSN_STREAM_RECV_EXIT_ABORT";
		 break;
	 case HWTH_RSN_STREAM_RECV_EXIT_INVALID:
		 pRsnString = "HWTH_RSN_STREAM_RECV_EXIT_INVALID";
		 break;
	 case HWTH_RSN_STREAM_RECV_EXIT_NODATA:
		 pRsnString = "HWTH_RSN_STREAM_RECV_EXIT_NODATA";
		 break;
	 case HWTH_RSN_STREAM_RECV_EXIT_STATE:
		 pRsnString = "HWTH_RSN_STREAM_RECV_EXIT_STATE";
		 break;
	 case HWTH_RSN_UNSUPPORTED_XFERENCODING:
		 pRsnString = "HWTH_RSN_UNSUPPORTED_XFERENCODING";
		 break;
	 case HWTH_RSN_UNSUPPORTED_BODY_SIZE:
		 pRsnString = "HWTH_RSN_UNSUPPORTED_BODY_SIZE";
		 break;
	 case HWTH_RSN_UNSUPPORTED_CHUNK_SIZE:
		 pRsnString = "HWTH_RSN_UNSUPPORTED_CHUNK_SIZE";
		 break;
	 case HWTH_RSN_INCOMPLETE_RESPONSE:
		 pRsnString = "HWTH_RSN_INCOMPLETE_RESPONSE";
		 break;
	 default:
		 break;
	 } /* end switch */

	 return pRsnString;
 }


 /***********************************************************
  * Function: surfaceToolkitDiag()
  *
  ***********************************************************/
 void surfaceToolkitDiag( HWTH_RETURNCODE_TYPE *rcPtr,
		 HWTH_DIAGAREA_TYPE *diagAreaPtr ) {

	 char traceBuf[256];       /* accomodate reasonDesc string */
	 int errorCode = (int) *rcPtr;
	 char *pDiagRsnString = NULL;

	 sprintf( traceBuf,
			 "*ERROR* rc: %d ***",
			 errorCode );
	 trace( traceBuf );

	 /****************************************************************
	  * Surface the diagnostics area, if appropriate.  Surface the
	  * reason code in (more usable) string form, if possible.
	  ****************************************************************/
	 pDiagRsnString = diagRsnString( diagAreaPtr->HWTH_reasonCode );
	 if ( pDiagRsnString == NULL )
		 sprintf( traceBuf,
				 "toolkit DIAG: Service[%d], Reason[%d], Desc[%s]",
				 diagAreaPtr->HWTH_service,
				 diagAreaPtr->HWTH_reasonCode,
				 diagAreaPtr->HWTH_reasonDesc );
	 else
		 sprintf( traceBuf,
				 "toolkit DIAG: Service[%d], Reason[%s], Desc[%s]",
				 diagAreaPtr->HWTH_service,
				 pDiagRsnString,
				 diagAreaPtr->HWTH_reasonDesc );

	 trace( traceBuf );
 }


 /**************************************************************
  * Function: openSequentialDSForWrite()
  *
  * Open the named sequential dataset, with the specified
  * attributes.  Note that for an existing dataset, open in
  * "wb" mode resets the file to logical empty, and it is a
  * remarkable fact that no matter what LRECL a given PS dataset
  * may have had, when wiped in this way, a new LRECL can in
  * fact superscede the old (not the case in non-sequential).
  *
  * Note that by "canonicalDsname" we mean the usual quoting
  * and prefixing by which USS recognizes dataset usage:
  * "//'MY.SEQUENTIAL.DATASET'"
  *
  * Return: FILE pointer if successful, NULL if dataset does
  * not exist or does not have the specified attributes.
  *************************************************************/
 FILE *openSequentialDSForWrite( char *canonicalDsName,
		 char *dsRecfm,
		 char *dsType,
		 int   dsLrecl ) {
	 FILE *fp = NULL;
	 char mode[80];
	 fldata_t Fdt;
	 char nameBuf[256];
	 int fldataRc;
	 char msgBuf[256];

	 sprintf( msgBuf,
			 "open sequential ds (%s)",
			 canonicalDsName );
	 trace( msgBuf );

	 /*********************************************************
	  * Check for pre-existing dataset.  If this were a USS
	  * file, one would more happily use access() or stat(),
	  * but it *appears* that we are better-off trying to
	  * open datasets for read.  Note that if fopen() for
	  * read actually fails due to authorization, then the
	  * subsequent fopen() for write almost certainly will,
	  * as well, and we elect to just deal with that...
	  *********************************************************/
	 fp = fopen( canonicalDsName, "r" );     /* open for read */
	 if ( fp == NULL ) {
		 trace( "Dataset does not appear to exist..." );
		 return ( NULL );
	 }
	 else {
		 /********************************************************
		  * Dataset appears to exist, so verify that the dataset
		  * is sequential before closing (prior to reopen).
		  ********************************************************/
		 trace( "Dataset appears to exist..." );
		 fldataRc = fldata( fp, nameBuf, &Fdt );
		 fclose(fp);
		 if ( fldataRc != 0 || Fdt.__dsorgPS != 1 ) {
			 trace( "Unacceptable dataset attribute(s)..." );
			 return( NULL );
		 }

		 sprintf( mode,
				 "wb, recfm=%s, type=%s, lrecl=%d",
				 dsRecfm, dsType, dsLrecl );
	 } /* endif dataset exists */

	 sprintf( msgBuf,
			 "using fopen mode (%s)",
			 mode );
	 trace( msgBuf );

	 /*******************************************
	  * Its vital to surface any failure here.
	  * Note that in the successful case, any
	  * existing dataset is "reset" to empty...
	  *******************************************/
	 fp = fopen( canonicalDsName, mode );
	 if ( fp == NULL ) {
		 sprintf( msgBuf,
				 "fopen() failure: %d (%s)",
				 errno,
				 strerror(errno) );
		 trace( msgBuf );
	 } /* endif fopen() failed */

	 return( fp );
 }


 /**************************************************************
  * Function: openFileForWrite()
  *
  **************************************************************/
 FILE *openFileForWrite( char *filePath ) {

	 FILE *fp = NULL;
	 char msgBuf[16+MAX_PATH_LEN];

	 /*******************************************
	  * Its vital to surface any failure here.
	  * Note that in the successful case, any
	  * existing file is "reset" to empty...
	  *******************************************/
	 fp = fopen( filePath, "wb" );
	 if ( fp == NULL ) {
		 sprintf( msgBuf,
				 "fopen() failure: %d (%s)",
				 errno,
				 strerror(errno) );
		 trace( msgBuf );
	 } /* endif fopen() failed */

	 return( fp );
 }


 /********************************************************************
  * Function: consumeNextResponseData()
  *
  * Process the next pieces of the response body, described by
  * the returnList.  If the dataset appears to still be receptive,
  * we write them to the dataset per its record length, incorporating
  * any residual fragment from a previous callback.  If the dataset
  * appears unreceptive, we simply do nothing with the current data.
  *
  ********************************************************************/
 void consumeNextResponseData( HWTH_STREAM_DATADESC_TYPE *returnList,
		 int listSize,
		 struct receiveUserData *pUserData ) {
	 HWTH_STREAM_DATADESC_TYPE *pDesc;
	 int i;

	 /*****************************************************
	  * Writes are suppressed if the file has been closed
	  * and the file pointer cleared...
	  *****************************************************/
	 if ( pUserData->fp == NULL )
		 return;

	 /**********************************************
	  * Process each of the returnList descriptors.
	  **********************************************/
	 for ( i = 0; i < listSize; i++ ) {
		 pDesc = &returnList[i];
		 if ( pUserData->ioType == IOTYPE_DATASET )
			 writeToSequentialDataset( pUserData,
					 pDesc->HWTH_dataAddr,
					 pDesc->HWTH_dataLength );
		 else
			 writeToFile( pUserData,
					 pDesc->HWTH_dataAddr,
					 pDesc->HWTH_dataLength );
	 } /* endloop over all pieces */

 }


 /*************************************************************
  * Function: finalizeResponseData()
  *
  * It is quite unlikely that the downloaded data has a size
  * which is a perfect multiple of the dataset lrecl.  In all
  * other cases, there is a fragment of unwritten data still
  * held in the record area of the user data, and we write that
  * small fragment to the dataset.  Since a successful write
  * requires us to conform to the lrecl of the dataset, we
  * pad the fragment with trailing 0's to the required length.
  *
  *************************************************************/
 void finalizeResponseData( struct receiveUserData *pUserData ) {

	 int fragmentSize = pUserData->dsRecordBytesUsed;
	 char *P;
	 char msgBuf[80];
	 __amrc_type AMRC;

	 /*****************************************************
	  * Writes are suppressed if the file has been closed
	  * and the file pointer cleared (e.g., file full)...
	  *****************************************************/
	 if ( pUserData->fp == NULL )
		 return;

	 if ( fragmentSize > 0 ) {
		 trace( "finalizing Response Data..." );
		 /**********************************
		  * Clear unused part of record...
		  **********************************/
		 P = &pUserData->dsRecord[fragmentSize];
		 memset( P, 0, DS_LRECL - fragmentSize );

		 /***************************
		  * Write out the record...
		  ***************************/
		 if ( fwrite( pUserData->dsRecord,
				 1,
				 DS_LRECL,
				 pUserData->fp ) < DS_LRECL ) {
			 AMRC = * __amrc;
			 pUserData->dsWriteAbendCode =
					 AMRC.__code.__abend.__syscode;
			 pUserData->dsWriteAbendRsn =
					 AMRC.__code.__abend.__rc;
			 sprintf( msgBuf,
					 "fwrite() failure, errno=%d (%s)",
					 errno,
					 strerror( errno ) );
			 trace( msgBuf );
			 /********************************************
			  * It is pointless to take steps to suppress
			  * subsequent writes since this is the last
			  ********************************************/
			 return;
		 } /* endif write failed */

		 pUserData->dsRecordBytesUsed = 0;           /* merely scrupulous */
		 pUserData->numBytesWritten += fragmentSize; /* crucial */
	 } /* endif fragment */

 }


 /*************************************************************
  * Function: setDataset()
  *
  * Write the input <value> in canonical form "//'<dsname>'"
  * to the location designated by <pDsName>
  *
  * Return: 0 if successful, -1 if not
  *************************************************************/
 int setDataset( char *value, char *pDsName ) {

	 char nameBuf[4+MAX_DSNAME_LEN];    /* possible 4-char envelope */

	 /***************************
	  * Deflect degenerate case
	  ***************************/
	 if ( value == NULL ||
			 strlen( value ) == 0 )
		 return -1;            /* nothing to set */

	 /*********************************************************
	  * We require that the dataset name be fully-qualified,
	  * but are happy to "envelop" it with single quotes and
	  * preceding double-slash, if necessary...
	  ********************************************************/
	 if ( *value == '/' ) {
		 /*******************************************
		  *  The name is already fully-enveloped,
		  *  so take it as-is (space permitting)...
		  *******************************************/
		 if ( strlen( value ) <= 4+MAX_DSNAME_LEN )
			 sprintf( nameBuf, "%s", value );
		 else
			 return -1;       /* unacceptable size */
	 } /* endif already fully-enveloped */
	 else if ( *value == '\'' ) {
		 /***********************************************
		  * The name is already single-quoted, so prefix
		  * it with double-slash (space permitting)...
		  *************************************************/
		 if ( strlen( value ) <= 2+MAX_DSNAME_LEN )
			 sprintf( nameBuf, "//%s", value );
		 else
			 return -1;       /* unacceptable size */
	 } /* endif already single-quoted */
	 else {
		 /**********************************************
		  * Envelope the name fully (space permitting)
		  **********************************************/
		 if ( strlen( value ) <= MAX_DSNAME_LEN )
			 sprintf( nameBuf, "//'%s'", value );
		 else
			 return -1;     /* unacceptable size */
	 } /* endif no envelope */

	 strcpy( pDsName, nameBuf );
	 return 0;
 }


 /*************************************************************
  * Function: setFileOrDsname()
  *
  * Write the input <value> to the appropriate field of the
  * input <parmStruct>, according to whether it appears to
  * designate a dataset, or an HFS/ZFS file.
  *
  * Return: 0 if successful, -1 if not
  *************************************************************/
 int setFileOrDsname( char *value, struct parmStruct *pParms ) {

	 const char  FS_DELIM = '/';
	 const char *DS_DELIM = "//";
	 char *pFileOrDsname = &pParms->fileOrDsname[0];

	 /***************************
	  * Deflect degenerate cases
	  ***************************/
	 if ( value == NULL )
		 return -1;            /* nothing to set */

	 if ( strlen( value ) > MAX_PATH_LEN ||
			 strlen( value ) == 0 )
		 return -1;            /* unacceptable size */

	 /*******************************************
	  * If it appears to be an absolute fs path,
	  * simply copy it.
	  *******************************************/
	 if ( *value == FS_DELIM &&
			 strncmp( value, DS_DELIM, strlen( DS_DELIM ) ) != 0 ) {
		 pParms->ioType = IOTYPE_FILE;
		 strcpy( pFileOrDsname, value );
		 return 0;
	 }

	 /*******************************************
	  * If not an fs path, assume dataset and
	  * write a canonical version of it for
	  * ease of subsequent open.
	  *******************************************/
	 pParms->ioType = IOTYPE_DATASET;
	 return setDataset( value, pFileOrDsname );
 }



 /*************************************************************
  * Function: setStashfile()
  *
  * Write the input <value> to the designated location.
  *
  * Return: 0 if successful, -1 if not
  *************************************************************/
 int setStashfile( char *value, char *pStashfile ) {

	 /****************************
	  * Deflect degenerate cases
	  ****************************/
	 if ( value == NULL )
		 return -1;              /* nothing to set */

	 if ( strlen( value ) > MAX_PATH_LEN ||
			 strlen( value ) == 0 )
		 return -1;          /* unacceptable value length */

	 if ( strlen( pStashfile ) > 0 )
		 return -1;              /* already set */

	 strcpy( pStashfile, value );
	 return 0;
 }


 /*************************************************************
  * Function: setKeyring()
  *
  * Write the input <value> to the designated location.
  *
  * Return: 0 if successful, -1 if not
  *************************************************************/
 int setKeyring( char *value, char *pKeyring ) {

	 /****************************
	  * Deflect degenerate cases
	  ****************************/
	 if ( value == NULL )
		 return -1;              /* nothing to set */

	 if ( strlen( value ) > MAX_PATH_LEN ||
			 strlen( value ) == 0 )
		 return -1;          /* unacceptable value length */

	 if ( strlen( pKeyring ) > 0 )
		 return -1;              /* already set */

	 strcpy( pKeyring, value );
	 return 0;
 }


 /*************************************************************
  * Function: getConnectScheme()
  *
  *************************************************************/
 char *getConnectScheme( struct parmStruct *pParms ) {

	 char *schemePtr = NULL;
	 if ( pParms->connectScheme == SCHEME_HTTP )
		 schemePtr = (char *)HTTP_SCHEME;
	 else if ( pParms->connectScheme == SCHEME_HTTPS )
		 schemePtr = (char *)HTTPS_SCHEME;

	 return schemePtr;
 }


 /*****************************************************
  * Function: setupSSL()
  *
  * Set several connectHandle options needed for
  * secure connect via SSL (or more likely, TLS).
  *
  * Returns: 0 if successful, -1 if not
  *****************************************************/
 int setupSSL( HWTH_HANDLE_TYPE  *connectHandlePtr,
		 struct parmStruct *parmsPtr ) {

	 HWTH_RETURNCODE_TYPE rc = HWTH_OK;
	 HWTH_DIAGAREA_TYPE   diagArea;
	 uint32_t   intOption;
	 uint32_t  *intOptionPtr = &intOption;
	 char      *stringOptionPtr;
	 char       traceBuf[256];

	 /************************************************
	  * Indicate that SSL/TLS should be used
	  ************************************************/
	 intOption = HWTH_SSL_USE;
	 if ( toolkitSetOption( &rc,
			 connectHandlePtr,
			 HWTH_OPT_USE_SSL,
			 (void **)&intOptionPtr,
			 sizeof(intOption),
			 &diagArea ) ) {
		 trace( "Unable to indicate SSL" );
		 return -1;
	 }

	 /**************************************************
	  * Indicate which version(s) of SSL/TLS we prefer.
	  * If you have reason to believe that your web
	  * server does not support this level, then change
	  * HWTH_SSLVERSION_TLSV12 to some alternative level
	  * indicated in <HWTHIC.h>
	  * If you are unsure, you may wish to keep this and
	  * simply add comparable code sections to enable
	  * additional level(s) to increase the likelihood
	  * of acceptance by your web server.
	  **************************************************/
	 /* HWTH_SSLVERSION_DEFAULT is the default */

	 intOption = HWTH_SSLVERSION_TLSV12;
	 if ( toolkitSetOption( &rc,
			 connectHandlePtr,
			 HWTH_OPT_SSLVERSION,
			 (void **)&intOptionPtr,
			 sizeof(intOption),
			 &diagArea ) ) {
		 trace( "Unable to indicate HWTH_SSLVERSION_TLSV12" );
		 return -1;
	 }

	 /*******************************************************
	  * The toolkit currently supports 2 types of keyrings.
	  * Since a gskkyman format keyring is useless to us
	  * without a stashfile, we assume gskkyman format if and
	  * only if a stashfile has been nominated.  Otherwise,
	  * we assume that the keyring is saf format.
	  *******************************************************/
	 if ( strlen( parmsPtr->sslStashfile ) > 0 ) {
		 /*******************************************************
		  * Indicate that our keystore type is a gskkyman type
		  *******************************************************/
		 intOption = HWTH_SSLKEYTYPE_KEYDBFILE;
		 if ( toolkitSetOption( &rc,
				 connectHandlePtr,
				 HWTH_OPT_SSLKEYTYPE,
				 (void **)&intOptionPtr,
				 sizeof(intOption),
				 &diagArea ) ) {
			 trace( "Unable to set (gskkyman) keystore type" );
			 return -1;
		 }

		 /************************************************************
		  * specify a valid path for the HWTH_OPT_SSLKEYSTASHFILE
		  * that points to a gskkyman stash file in the file system.
		  ************************************************************/
		 stringOptionPtr = parmsPtr->sslStashfile;
		 if ( toolkitSetOption( &rc,
				 connectHandlePtr,
				 HWTH_OPT_SSLKEYSTASHFILE,
				 (void **)&stringOptionPtr,
				 strlen(parmsPtr->sslStashfile),
				 &diagArea ) ) {
			 trace( "Unable to set Stashfile" );
			 return -1;
		 }
	 } /* endif gskkyman format (stashfile specified) */
	 else {
		 /*************************************************
		  * Indicate that our keystore type is SAF
		  *************************************************/
		 intOption = HWTH_SSLKEYTYPE_KEYRINGNAME;
		 if ( toolkitSetOption( &rc,
				 connectHandlePtr,
				 HWTH_OPT_SSLKEYTYPE,
				 (void **)&intOptionPtr,
				 sizeof(intOption),
				 &diagArea ) ) {
			 trace( "Unable to set (saf) keystore type" );
			 return -1;
		 }
	 } /* endif saf format */

	 /************************
	  * Specify the keystore
	  ************************/
	 stringOptionPtr = parmsPtr->sslKeyring;
	 if ( toolkitSetOption( &rc,
			 connectHandlePtr,
			 HWTH_OPT_SSLKEY,
			 (void **)&stringOptionPtr,
			 strlen(parmsPtr->sslKeyring),
			 &diagArea ) ) {
		 trace( "Unable to set Keystore" );
		 return -1;
	 }

	 return 0;
 }


 /*****************************************************
  * Function: writeToSequentialDataset()
  *
  * Do record-oriented write(s) to the open dataset
  * associated with the FILE pointer within the input
  * userdata struct.  Maintain the running count of
  * <byteswritten> so long as the file has not be
  * filled to capacity.  If a write attempt fails with
  * an abend code suggesting that the file is at
  * capacity, then close the file to suppress future
  * write attempts for the duration of receive.
  *
  *****************************************************/
 void writeToSequentialDataset( struct receiveUserData *pUserData,
		 char *dataAddr,
		 int dataLength ) {
	 int   readBytesRemaining;
	 char *readCursor;
	 int   writeBytesAvail;
	 char *writeCursor;
	 int copySize;
	 char msgBuf[256];
	 __amrc_type AMRC;

	 /******************************************************
	  * The input area could well span multiple dataset
	  * records.  Use a cursor to advance thru
	  * a given area, combining the appropriate
	  * number of bytes with residual data, to form
	  * a complete dataset record which we write to
	  * the open dataset.
	  **********************************************/
	 readCursor = dataAddr;                       /* area start */
	 readBytesRemaining = dataLength;             /* area size */

	 while ( readBytesRemaining > 0 ) {
		 writeBytesAvail = DS_LRECL - pUserData->dsRecordBytesUsed;
		 writeCursor = &pUserData->dsRecord[0] +
				 pUserData->dsRecordBytesUsed;
		 if ( readBytesRemaining <= writeBytesAvail )
			 copySize = readBytesRemaining;
		 else
			 copySize = writeBytesAvail;
		 memcpy( writeCursor, readCursor, copySize );
		 readBytesRemaining -= copySize;
		 readCursor += copySize;
		 pUserData->dsRecordBytesUsed += copySize;
		 if ( pUserData->dsRecordBytesUsed == DS_LRECL ) {
			 /**********************************************
			  * If not suppressing writes, try to write out
			  * the completed record.  If successful,
			  * set <bytesused> to indicate empty record and
			  * increment <byteswritten> count.  If write
			  * failure (e.g., file full), take steps to
			  * suppress future writes, and trace the error
			  *********************************************/
			 if ( pUserData->fp != NULL ) {
				 if ( fwrite( pUserData->dsRecord,
						 1,
						 DS_LRECL,
						 pUserData->fp ) < DS_LRECL ) {
					 /*************************************
					  * Capture the abend code and reason
					  * from the esoteric I/O struct
					  *************************************/
					 AMRC = * __amrc;
					 pUserData->dsWriteAbendCode =
							 AMRC.__code.__abend.__syscode;
					 pUserData->dsWriteAbendRsn =
							 AMRC.__code.__abend.__rc;
					 sprintf( msgBuf,
							 "fwrite() failure, errno=%d (%s)",
							 errno,
							 strerror( errno ) );
					 trace( msgBuf );

					 fclose( pUserData->fp );
					 pUserData->fp = NULL;
					 return; /* likely dataset full */
				 } /* endif fwrite failed */
			 } /* endif not suppressing writes */

			 pUserData->dsRecordBytesUsed = 0;
			 pUserData->numBytesWritten += DS_LRECL;
		 } /* endif record complete */
	 } /* endwhile current piece not fully consumed */
 }


 /*****************************************************
  * Function: writeToFile()
  *
  * Do byte-oriented write(s) to the open file
  * associated with the FILE pointer within the input
  * userdata struct.  Maintain the running count of
  * <byteswritten> so long as no write has failed.
  * If a write attempt fails (suggesting that the
  * file system containing the file is at capacity),
  * then close the file to suppress future write
  * attempts for the duration of receive.
  *
  *****************************************************/
 void writeToFile( struct receiveUserData *pUserData,
		 char *dataAddr,
		 int dataLength ) {
	 char msgBuf[256];

	 if ( pUserData->fp == NULL )
		 return;

	 /****************************************************
	  * Write out the data.  If write failure (e.g.,
	  * file full), take steps to suppress future writes,
	  * and trace the errno.
	  ****************************************************/
	 if ( fwrite( dataAddr,
			 1,
			 dataLength,
			 pUserData->fp ) < dataLength ) {
		 pUserData->fwriteErrno = errno;
		 sprintf( msgBuf,
				 "fwrite() failure, errno=%d (%s)",
				 errno,
				 strerror( errno ) );
		 trace( msgBuf );

		 fclose( pUserData->fp );
		 pUserData->fp = NULL;
		 return;
	 } /* endif fwrite failed */

	 pUserData->numBytesWritten += dataLength;
 }


 /*****************************************************
  * Function: parseUri()
  *
  * Parse the input uri which must either be of form:
  *   <scheme>://<host>:<port><path>
  * or:
  *   <scheme>://<host><path>
  * If <port> is not specified, then the default port
  * for the given scheme (80 for http, 443 for https)
  * will be understood and used by the toolkit.
  * Record the parsed <scheme>, <host>, <port>, and
  * <path> to the corresponding fields of the input
  * <parmStruct>.
  *
  * Return: 0 if successful, -1 if not
  *****************************************************/
 int  parseUri( char *uri, struct parmStruct *pParms ) {

	 char  uriCopy[1+MAX_URI_LEN];
	 char *cursor, *host, *port, *path;
	 const char *SCHEME_DELIM = "://";
	 const char *PORT_DELIM = ":";

	 /************************************************
	  * Validate the uri and make a mutable copy
	  ************************************************/
	 if ( uri == NULL )
		 return -1;

	 if ( strlen(uri) == 0 ||
			 strlen(uri) > MAX_URI_LEN )
		 return -1;

	 strcpy( uriCopy, uri );
	 cursor = uriCopy;

	 /************************************************
	  * Parse for http(s) scheme, which is required
	  ************************************************/
	 if ( strncasecmp( cursor,
			 HTTPS_SCHEME,
			 strlen(HTTPS_SCHEME) ) == 0 ) {
		 pParms->connectScheme = SCHEME_HTTPS;
		 cursor += strlen(HTTPS_SCHEME);
	 }
	 else if (strncasecmp( cursor,
			 HTTP_SCHEME,
			 strlen(HTTP_SCHEME) ) == 0 ) {
		 pParms->connectScheme = SCHEME_HTTP;
		 cursor += strlen(HTTP_SCHEME);
	 }
	 else
		 return -1;

	 /************************************************
	  * Parse for '://' delimiter, which is required
	  ************************************************/
	 if ( strncasecmp( cursor, SCHEME_DELIM, strlen(SCHEME_DELIM) ) )
		 return -1;

	 cursor += strlen(SCHEME_DELIM);
	 host = cursor;

	 /**********************************************
	  * Search for '/', which should begin the path
	  * portion following <host> or <host:port>
	  **********************************************/
	 path = strchr( cursor, '/' );
	 if ( path == NULL ) {
		 strcpy( pParms->connectHost, host );
		 return -1;
	 }

	 /**********************************************
	  * Copy the path portion, then truncate the
	  * mutable copy to make the next part easier
	  **********************************************/
	 strcpy( pParms->requestUri, path );
	 *path = '\0';

	 /*****************************************************
	  * Search for optional port delimited by ':'.  If not
	  * found, do nothing (let the toolkit supply the
	  * default port per the scheme).
	  *****************************************************/
	 port = strchr( cursor, ':' );
	 if ( port != NULL ) {
		 /**********************************************
		  * If a colon-delimited port was specified,
		  * extract it, and truncate the mutable copy
		  * to make the next part easier.
		  **********************************************/
		 *port = '\0';
		 ++port;
		 pParms->connectPort = atoi( port );
		 if ( pParms->connectPort <= 0 )
			 return -1;
	 }

	 /**********************************************
	  * Maybe having truncated, the host now stands
	  * alone, and we can copy it as-is.
	  **********************************************/
	 strcpy( pParms->connectHost, host );

	 return 0;

 }


 /*****************************************************
  * Function: setUserid()
  *
  * Write the input <value> to the designated location.
  *
  * Return: 0 if successful, -1 if not
  *****************************************************/
 int setUserid( char *value, char *pUserid ) {
	 /****************************
	  * Deflect degenerate cases
	  ****************************/
	 if ( value == NULL )
		 return -1;              /* nothing to set */

	 if ( strlen( value ) > MAX_USERID_LEN ||
			 strlen( value ) == 0 )
		 return -1;          /* unacceptable value length */

	 if ( strlen( pUserid ) > 0 )
		 return -1;              /* already set */

	 strcpy( pUserid, value );
	 return 0;
 }


 /*****************************************************
  * Function: setPassword()
  *
  * Write the input <value> to the designated location.
  *
  * Return: 0 if successful, -1 if not
  *****************************************************/
 int setPassword( char *value, char *pPassword ) {
	 /****************************
	  * Deflect degenerate cases
	  ****************************/
	 if ( value == NULL )
		 return -1;              /* nothing to set */

	 if ( strlen( value ) > MAX_PASSWORD_LEN ||
			 strlen( value ) == 0 )
		 return -1;          /* unacceptable value length */

	 if ( strlen( pPassword ) > 0 )
		 return -1;              /* already set */

	 strcpy( pPassword, value );
	 return 0;
 }


 /******************************************************************
  * Function: setResponseHeadersExit()
  *
  * Sets options for the designated request handle with the
  * address of the response headers exit and an optional userdata
  * area for the send exit to use on callback(s) from toolkit.
  *
  * Returns:  0 if successful, -1 if not
  ******************************************************************/
 int  setResponseHeadersExit( HWTH_RETURNCODE_TYPE *rcPtr,
		 HWTH_HANDLE_TYPE     *requestHandlePtr,
		 HWTHHDRX             *headersExitPtr,
		 void                 *userDataPtr,
		 HWTH_DIAGAREA_TYPE   *diagAreaPtr ) {

	 int exitOption = (int)*headersExitPtr;
	 int *exitOptionPtr = &exitOption;
	 int dataOption = (int)userDataPtr;
	 int *dataOptionPtr = &dataOption;

	 if ( toolkitSetOption( rcPtr,
			 requestHandlePtr,
			 HWTH_OPT_RESPONSEHDR_USERDATA,
			 (void **)&dataOptionPtr,
			 sizeof(dataOption),
			 diagAreaPtr ) )
		 return -1;

	 if ( toolkitSetOption( rcPtr,
			 requestHandlePtr,
			 HWTH_OPT_RESPONSEHDR_EXIT,
			 (void **)&exitOptionPtr,
			 sizeof(exitOption),
			 diagAreaPtr ) )
		 return -1;

	 return 0;
 }


 /******************************************************
  * Function: rhdrexit()
  *
  * Exit which receives control for each response
  * header returned by the (server) endpoint, prior to
  * any possible response body.  As used here, its only
  * real function is to recognize a <Content-Length: NN>
  * header and record its value <NN> in the input userdata
  *
  * Returns: HWTH_RESP_EXIT_RC_OK or
  *          HWTH_RESP_EXIT_RC_ABORT
  *******************************************************/
 uint32_t rhdrexit( HWTH_STATUS_LINE_TYPE  *httpResp,
		 HWTH_RESP_EXIT_FLAGS_TYPE  *exitFlags,
		 char  **headerName,
		 uint32_t  *headerNameLen,
		 char  **headerValue,
		 uint32_t  *headerValueLen,
		 char   **headerUserData,
		 uint32_t   *headerUserDataLen ) {

	 struct receiveUserData  *P, **Pref;
	 int64_t contentLengthValue;
	 char  msgBuf[80];
	 const char *CONTENT_LENGTH_HDR = "Content-Length";

	 /******************************************************
	  * The only response header we currently react to is
	  * Content-Length:  record it in the userdata so that
	  * we can abort any receive which exceeds capacity.
	  ******************************************************/
	 if ( strcasecmp( *headerName, CONTENT_LENGTH_HDR ) == 0 ) {
		 Pref = (struct receiveUserData **)*headerUserData;
		 P = *Pref;
		 contentLengthValue = atoll( *headerValue );
		 P->knownContentLength = contentLengthValue;
		 sprintf( msgBuf,
				 "Content-Length header is: %lld",
				 P->knownContentLength );
	     //hxtrace( msgBuf );
	 } /* endif Content-Length response header */
	 else {
		 /******************************************************
		  * Uncomment the following two lines and the one above
		  * for hxtrace if you'd like to print out the header info
		  * as it's received, this information is alternatively
		  * available when the HWTH_OPT_VERBOSE is turned on via
		  * the -v option
		  ******************************************************/
		 //hxtrace( *headerName );
		 //hxtrace( *headerValue );
	 }

	 return HWTH_RESP_EXIT_RC_OK;
 }


 /*****************************************************
  * Function: setCred()
  *
  * Parse the input <value> which must have form:
  *             userid:password
  * Write the individual components to their
  * corresponding fields in the input <parmStruct>,
  * or indicate invalid <value>
  *
  * Return: 0 if successful, -1 if not
  *****************************************************/
 int  setCred( char *value, struct parmStruct *pParms ) {

	 char credBuf[MAX_USERID_LEN + MAX_PASSWORD_LEN + 2];
	 char *pDelim;

	 if ( strlen(value) == 0 ||
			 strlen(value) > sizeof(credBuf) )
		 return -1;

	 /**************************************
	  * Make a mutable copy, then tokenize
	  **************************************/
	 strcpy( credBuf, value );
	 pDelim = strchr( credBuf, ':' );
	 if ( pDelim == NULL )
		 return -1;
	 *pDelim = '\0';
	 ++pDelim;

	 return ( setUserid( credBuf, &pParms->userid[0] ) +
			 setPassword( pDelim, &pParms->password[0] ) );
 }


 /******************************************************************
 * Function:  setRequestHeaders()
 *
 * Use toolkit SList processing to provide any request header(s)
 * which are appropriate.
 *
 * Returns: 0 if successful, -1 if not
 *****************************************************************/
int setRequestHeaders( HWTH_RETURNCODE_TYPE *rcPtr,
                 HWTH_HANDLE_TYPE     *requestHandlePtr,
                 HWTH_DIAGAREA_TYPE   *diagAreaPtr ) {

  char **headerStringArray = NULL;
  int  i;

  HWTH_SLIST_TYPE SList;
  HWTH_SLIST_TYPE *SListPtr = &SList;
  char  **stringRef;

  /*******************************************************************
   * It might typically be the case that the caller has no request
   * header(s) to supply.  However in this particular sample they
   * will turn out to be required (see the commentary for function
   * getRequestHeaders()), and failure to produce them is fatal.
   *******************************************************************/
  headerStringArray = getRequestHeaders();
  if ( headerStringArray == NULL || headerStringArray[0] == NULL ) {
     trace( "No Request header(s) supplied" );
     return -1;
     }

  stringRef = &headerStringArray[0];
  *SListPtr = NULL;
  if ( toolkitSlistOperation( rcPtr,
                              requestHandlePtr,
                              HWTH_SLST_NEW,
                              SListPtr,
                              stringRef,
                              (uint32_t)strlen(*stringRef),
                              diagAreaPtr ) ) {
      trace( "Slist create failure" );
      return -1;
      } /* endif slist create failure */

  i = 1;
  while ( ( headerStringArray[i] != NULL ) &&
          ( strlen(headerStringArray[i]) > 0 ) ) {
     stringRef = &headerStringArray[i++];
     if ( toolkitSlistOperation( rcPtr,
                                 requestHandlePtr,
                                 HWTH_SLST_APPEND,
                                 SListPtr,
                                 stringRef,
                                 (uint32_t)strlen(*stringRef),
                                 diagAreaPtr ) ) {
         trace( "Slist append failure" );
         return -1;
         } /* endif slist append failed */
      }  /* endloop thru remaining headers */

 if ( toolkitSetOption( rcPtr,
                        requestHandlePtr,
                        HWTH_OPT_HTTPHEADERS,
                        (void **)&SListPtr,
                        sizeof(SList),
                        diagAreaPtr ) ) {
    trace( "Unable to set Request Headers" );
    return -1;
    } /* endif set headers ok */

 freeRequestHeaders( headerStringArray );
 return 0;
} /* end function */


/*******************************************************************
 * Function:  getRequestHeaders()
 *
 * Callers may choose to supply request headers to influence how
 * the request is sent, or how the endpoint processes the sent
 * request body.  If the caller has neither of these considerations
 * then no request headers need be specified at all (the toolkit
 * supplies any headers on the caller's behalf should they omit
 * any strictly required by the protocol).
 *
 * In particular, the toolkit will supply a default of:
 *           <Transfer-Encoding: chunked>
 * with a streamed request body, causing the toolkit to send the
 * body using chunked encoding, which will be fine for most endpoints.
 *
 * However in this *particular* sample, the chosen endpoint happens
 * *NOT* to do well with input data sent using chunked encoding.
 * And so instead we create and supply a <Content-Length: NN> header
 * where NN is the size (in bytes) of the request body being sent by
 * the streaming send exit.  This will still cause the toolkit to
 * stream the request body data, but without chunked encoding.
 *
 * Returns: Address of heap-allocated ptr array
 ****************************************************************/
char **getRequestHeaders(void) {
 char buf[80];
 char **headers = NULL;
 int num_headers = 1;

 char *token = getenv("ZOPEN_GIT_OAUTH_TOKEN");
 if (token != NULL) {
	num_headers++;
 }

/***************************************************
 * Allocate an array of pointers to string, and
 * build a string for each of the headers.  Use a
 * NULL last array element to indicate end of array.
 ***************************************************/
 int idx = 0;
 headers = (char **)calloc(1 + num_headers, sizeof(char *));
 if (headers == NULL) {
	char msgBuf[80];
	snprintf(msgBuf, sizeof msgBuf,
			"Unexpected calloc() failure (%d)", errno);

	rxtrace(msgBuf);
	return NULL;
 }

 snprintf(buf, sizeof buf, "%s:%s", "User-Agent", "toolkit" );
 headers[idx++] = strdup(buf);

 if (token != NULL) {
	snprintf(buf, sizeof buf,"%s:%s %s",
			 "Authorization", "Bearer",token);
	headers[idx++] = strdup(buf);
 }

 /* Terminate the header array */
 headers[idx] = NULL;

return headers;
} /* end function */


/*******************************************************************
 * Function:  freeRequestHeaders()
 *
 * Free the string array produced by an earlier getRequestHeaders()
 *
 * Returns: (void)
 ****************************************************************/
void freeRequestHeaders( char **headersList ) {

 int i = 0;
 if ( headersList == NULL )
  return;

 while ( headersList[i] != NULL ) {
    free( headersList[i] );
    ++i;
    }

 free( headersList );
} /* end function */


/***************************************************************
 * Function: toolkitSlistOperation()
 *
 * Thin wrapper for hwthslst() toolkit service, which should
 * set the the designated value for the designated list option
 * associated with the intput handle.
 *
 * Returns:  0 if successful, -1 if not
 ***************************************************************/
int toolkitSlistOperation( HWTH_RETURNCODE_TYPE    *rcPtr,
                           HWTH_HANDLE_TYPE        *handlePtr,
                           HWTH_SLST_FUNCTION_TYPE  whichFunction,
                           HWTH_SLIST_TYPE         *sListPtr,
                           char                   **stringRef,
                           uint32_t                 stringLength,
                           HWTH_DIAGAREA_TYPE      *diagAreaPtr ) {

  hwthslst( rcPtr,
            *handlePtr,
            whichFunction,
            sListPtr,
            stringRef,
            stringLength,
            diagAreaPtr );
  return ( ( *rcPtr == HWTH_OK ) ? 0: -1 );

 } /* end function */
