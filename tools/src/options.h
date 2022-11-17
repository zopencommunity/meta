#ifndef __ZOPEN_OPTIONS
  #define __ZOPEN_OPTIONS 1

  #ifdef MAIN
     int verbose=1; /* create an options structure if this gets more complex */
  #else
     extern int verbose;
  #endif

  #define STDTRC stdout
#endif
