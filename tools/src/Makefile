#
# Simple compile and link of zopen-setup program
#
CC=xlc
CFLAGS=-c -qdll -qrent -qlongname -Wl,DYNAM=DLL

all: headers zopen-setup
clean:
	rm -f *.o zopen-setup

hwthic.h:
	cp "//'sys1.sieahdrv.h(hwthic)'" hwthic.h

headers: hwthic.h

#download.o: download.c
#	xlc -c -qdll -qrent -qlongname -Wl,DYNAM=DLL $^

#main.o: main.c
#	xlc -c -qdll -qrent -qlongname -Wl,DYNAM=DLL $^

zopen-setup: main.o download.o createdirs.o
	$(LD) $(LDFLAGS) -o$@ $^ 
