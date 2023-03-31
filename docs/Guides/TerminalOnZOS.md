# Setting up your terminal

If you need to display characters that are not defined in the lower 7 bits of the general ASCII
encoding, you might have problems if you choose the wrong terminal character encoding.
Character encodings are a complex issue, so I will restrict this to the basics of ISO8859-1 and
UTF-8 encodings and setting up your terminal emulator correctly.

I noticed when I tried to issue:
```
man --locale=fr vim
```

the output did not look right. After much experimentation, I discovered it was because
my terminal was set up to display UTF-8 characters, but in this case, my French man pages needed 
my terminal to be set up to display ISO8859-1 characters!

The solution was to change my settings for my terminal to be ISO8859-1.
How you do this will vary by terminal emulator. In my case, I use `iTerm2` on a Mac, and I did:
```
Right-click terminal
Choose Edit Session
Select Terminal
Change Character Encoding to Western (ASCII)
```

Here is a forum entry that discusses this in more detail with specifics for Linux:
[character encodings supported by more cat and less](https://unix.stackexchange.com/questions/78776/characters-encodings-supported-by-more-cat-and-less). 
