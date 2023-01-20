#
# Simple compile and link of zopen-setup program
#
CC=xlc
LD=xlc
INFO = 'info(cmp,cnv,cns,enu,lan,por,pro,ret)'
CFLAGS=-c -qdll -qrent -qlongname -Wl,DYNAM=DLL -Wc,GONUM,${INFO}

all: headers zopen-setup httpsget
clean:
	rm -f *.o zopen-setup

hwthic.h:
	/bin/cp "//'sys1.sieahdrv.h(hwthic)'" hwthic.h

headers: hwthic.h

httpsget: httpsgetmain.o httpsget.o createdb.o createpem.o download.o zopenio.o
	$(LD) $(LDFLAGS) -o$@ $^
    
zopen-setup: zopensetupmain.o download.o createdirs.o createdb.o createpem.o httpsget.o zopenio.o syscmd.o createbootenv.o httpspkg.o
	$(LD) $(LDFLAGS) -o$@ $^ 
