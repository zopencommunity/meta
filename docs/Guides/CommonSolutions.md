# Common Issues and their solutions

## C pipe, C open do not tag newly created file descriptors
TBD

## FSUM7327 signal number XX not conventional
See: [FSUM7327](https://tech.mikefulton.ca/FSUM7327) which is relatively cryptic and [kill](https://tech.mikefulton.ca/POSIXSignalNumbers) 
Only _some_ signals have a well-defined number that can be used when specifying an action (such as kill or trap). In particular, signal number 13 (which seems to be SIGPIPE) is _not_ a well-defined signal number.
As such, code that specifies signal 13 gets the cryptic error message above and can be re-coded to use SIGPIPE instead (see signal.h if the signal number in question isn't 13, in which case you will need to see what a Linux signal XX is and then re-code it with a name)
