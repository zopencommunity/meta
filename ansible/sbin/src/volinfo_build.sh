#!/bin/sh
#
# Build the C code for volinfo
#
#set -x
MY_DIR=$(cd `dirname $0`; echo $PWD)
c89 -O2 -Wc,list\(${MY_DIR}\) -o ${MY_DIR}/../volinfo ${MY_DIR}/volinfo.c
