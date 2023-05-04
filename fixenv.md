# FIXENV

This utility is designed to be used to facilitate the remounting, moving, or copying the z/OS Open Tools (zopen) installation files to a new mount point.

This rexx code should be run on your OMVS session after:

1. installing the z/OS Open Tools (zot)                
2. before invoking the zot .bootenv to setup the environment                                         
3. execute this rexx code with a parm of 1             
   - this will capture the current environment         
4. execute the zot .bootenv to update the active environment                                         
5. execute this rexx code with a parm of 2             
   - this will generate                                
     - a file to be added to /etc/profile or user      
       .profile                                        
     - an env file that can be used by zigi            
6. Enjoy the results         

To run fixenv issue the command `./fixenv parm` where `parm` is `1` or `2`. 
If you enter no  parm, or an invalid parm, then the  above instructions will be presented to the user.                         

### Note

This utility is written in REXX and has some comments to help anyone updating the code to understand it.
