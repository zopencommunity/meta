#include <stdio.h>
#include "download.h"
int main() {
  const char* host = "github.com";
  const char* uri = "ZOSOpenTools/curlport/releases/download/curlport_boot/curl-7.83.1.20220808_165842.zos.pax.Z";
  const char* file = "/tmp/curl.pax.Z";
  return download(host, uri, file);
}
