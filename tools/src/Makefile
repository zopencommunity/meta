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

zopen-setup: main.o download.o createdirs.o createdb.o createpem.o
	$(LD) $(LDFLAGS) -o$@ $^ 
