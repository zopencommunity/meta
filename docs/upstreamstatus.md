# Upstream Patch Status Report

*Report generated on: 2025-04-29 06:11:30 EDT.*

## Overall Summary

- **Total Projects Analyzed:** 220
- **Total Current Lines of Code (LOC) in Patches:** 27,866
- **Total Number of Current Patch Files:** 657
- **Average Current Patch LOC per Project:** 126.66
- **Average Current Patch Count per Project:** 2.99

### Historical Trends (All Projects)

![Average Patch LOC Trend](images/upstream/average_patch_loc_trend.png)

![Overall Patch LOC Trend](images/upstream/overall_current_loc_trend.png)

### Repository LoC Distribution

![Repository Distribution by LoC](images/upstream/overall_loc_distribution_pie.png)

## Repository Breakdown (Sorted by Current Patch LOC)

| Repository | Current Patch LOC | Delta Last Month | # Current Patches |
|---|:---|:---|:---|
| [librdkafkaport](#repo-librdkafkaport) | 2,638 | +0 | 54 |
| [bashport](#repo-bashport) | 1,698 | -2,728 | 32 |
| [libuvport](#repo-libuvport) | 1,462 | +0 | 26 |
| [sudoport](#repo-sudoport) | 1,278 | +0 | 30 |
| [coreutilsport](#repo-coreutilsport) | 1,169 | +382 | 18 |
| [cmakeport](#repo-cmakeport) | 1,092 | +0 | 1 |
| [gitport](#repo-gitport) | 974 | -1 | 31 |
| [valgrindport](#repo-valgrindport) | 896 | +0 | 3 |
| [gzipport](#repo-gzipport) | 690 | +21 | 8 |
| [gpgport](#repo-gpgport) | 687 | +0 | 13 |
| [procpsport](#repo-procpsport) | 687 | +42 | 1 |
| [perlport](#repo-perlport) | 683 | +0 | 13 |
| [unzipport](#repo-unzipport) | 549 | +0 | 12 |
| [cronieport](#repo-cronieport) | 510 | +0 | 13 |
| [util-linuxport](#repo-util-linuxport) | 489 | -123 | 12 |
| [screenport](#repo-screenport) | 485 | +0 | 7 |
| [tmuxport](#repo-tmuxport) | 440 | +0 | 13 |
| [treeport](#repo-treeport) | 425 | +0 | 3 |
| [emacsport](#repo-emacsport) | 413 | +0 | 2 |
| [opensshport](#repo-opensshport) | 376 | +0 | 19 |
| [flexport](#repo-flexport) | 351 | +0 | 2 |
| [prometheusport](#repo-prometheusport) | 348 | +0 | 1 |
| [pocoport](#repo-pocoport) | 343 | +0 | 9 |
| [rsyncport](#repo-rsyncport) | 341 | +0 | 6 |
| [vimport](#repo-vimport) | 335 | +0 | 12 |
| [phpport](#repo-phpport) | 320 | +0 | 13 |
| [neovimport](#repo-neovimport) | 312 | +0 | 12 |
| [conanport](#repo-conanport) | 299 | +0 | 8 |
| [zipport](#repo-zipport) | 297 | +0 | 8 |
| [redisport](#repo-redisport) | 263 | +115 | 1 |
| [gitlab-runnerport](#repo-gitlab-runnerport) | 241 | +0 | 10 |
| [zstdport](#repo-zstdport) | 236 | +9 | 4 |
| [llamacppport](#repo-llamacppport) | 236 | +0 | 1 |
| [mesonport](#repo-mesonport) | 229 | +0 | 9 |
| [gettextport](#repo-gettextport) | 206 | +0 | 7 |
| [findutilsport](#repo-findutilsport) | 199 | +0 | 10 |
| [ninjaport](#repo-ninjaport) | 196 | +0 | 8 |
| [diffutilsport](#repo-diffutilsport) | 184 | +0 | 8 |
| [protobufport](#repo-protobufport) | 174 | +0 | 8 |
| [groffport](#repo-groffport) | 165 | +0 | 13 |
| [autoconfport](#repo-autoconfport) | 151 | +0 | 6 |
| [moreutilsport](#repo-moreutilsport) | 151 | +0 | 1 |
| [jqport](#repo-jqport) | 146 | +0 | 8 |
| [libserdesport](#repo-libserdesport) | 142 | +0 | 4 |
| [tclport](#repo-tclport) | 130 | +0 | 5 |
| [libgcryptport](#repo-libgcryptport) | 129 | +0 | 7 |
| [pinentryport](#repo-pinentryport) | 124 | +0 | 5 |
| [libssh2port](#repo-libssh2port) | 122 | +0 | 5 |
| [m4port](#repo-m4port) | 120 | +0 | 5 |
| [thesilversearcherport](#repo-thesilversearcherport) | 118 | +0 | 4 |
| [gas2asmport](#repo-gas2asmport) | 116 | +116 | 4 |
| [grepport](#repo-grepport) | 115 | +0 | 3 |
| [uucpport](#repo-uucpport) | 115 | +115 | 1 |
| [ncursesport](#repo-ncursesport) | 111 | +0 | 2 |
| [hexcurseport](#repo-hexcurseport) | 108 | +0 | 4 |
| [libbsdport](#repo-libbsdport) | 107 | +0 | 4 |
| [victoriametricsport](#repo-victoriametricsport) | 107 | +0 | 3 |
| [zlib-ngport](#repo-zlib-ngport) | 100 | +0 | 3 |
| [pkgconfigport](#repo-pkgconfigport) | 98 | +0 | 1 |
| [doxygenport](#repo-doxygenport) | 97 | +0 | 5 |
| [libiconvport](#repo-libiconvport) | 96 | -100 | 4 |
| [depot_toolsport](#repo-depot-toolsport) | 91 | +0 | 1 |
| [libeventport](#repo-libeventport) | 87 | +0 | 3 |
| [patchport](#repo-patchport) | 86 | +0 | 3 |
| [gawkport](#repo-gawkport) | 81 | +0 | 4 |
| [expectport](#repo-expectport) | 79 | +0 | 4 |
| [librabbitmqport](#repo-librabbitmqport) | 78 | +0 | 2 |
| [libassuanport](#repo-libassuanport) | 77 | +0 | 4 |
| [xmltoport](#repo-xmltoport) | 74 | +0 | 1 |
| [cppcheckport](#repo-cppcheckport) | 72 | +0 | 4 |
| [libtoolport](#repo-libtoolport) | 71 | +0 | 3 |
| [nanoport](#repo-nanoport) | 68 | +0 | 1 |
| [getoptport](#repo-getoptport) | 66 | +0 | 1 |
| [logrotateport](#repo-logrotateport) | 65 | +0 | 1 |
| [lz4port](#repo-lz4port) | 58 | +0 | 4 |
| [libgpgerrorport](#repo-libgpgerrorport) | 53 | +0 | 3 |
| [expatport](#repo-expatport) | 52 | +0 | 2 |
| [terraformport](#repo-terraformport) | 51 | +0 | 2 |
| [libsasl2port](#repo-libsasl2port) | 50 | +0 | 3 |
| [automakeport](#repo-automakeport) | 47 | +0 | 3 |
| [lessport](#repo-lessport) | 47 | +0 | 3 |
| [xxhashport](#repo-xxhashport) | 47 | +0 | 2 |
| [tigport](#repo-tigport) | 47 | +0 | 1 |
| [lazygitport](#repo-lazygitport) | 46 | +0 | 1 |
| [fzfport](#repo-fzfport) | 45 | +0 | 2 |
| [poptport](#repo-poptport) | 35 | +0 | 1 |
| [whichport](#repo-whichport) | 34 | +0 | 1 |
| [sedport](#repo-sedport) | 33 | +0 | 1 |
| [texinfoport](#repo-texinfoport) | 33 | -23 | 2 |
| [ntbtlsport](#repo-ntbtlsport) | 33 | +0 | 1 |
| [sqliteport](#repo-sqliteport) | 32 | +0 | 1 |
| [luvport](#repo-luvport) | 31 | +0 | 1 |
| [libffiport](#repo-libffiport) | 31 | +0 | 2 |
| [lynxport](#repo-lynxport) | 30 | +0 | 1 |
| [netpbmport](#repo-netpbmport) | 29 | +0 | 2 |
| [gmpport](#repo-gmpport) | 29 | +0 | 2 |
| [libgpgmeport](#repo-libgpgmeport) | 29 | +0 | 2 |
| [npthport](#repo-npthport) | 28 | +0 | 2 |
| [libksbaport](#repo-libksbaport) | 28 | +0 | 2 |
| [avro-c-libport](#repo-avro-c-libport) | 28 | +0 | 2 |
| [ctagsport](#repo-ctagsport) | 26 | +0 | 2 |
| [git-extrasport](#repo-git-extrasport) | 26 | +0 | 1 |
| [my_basicport](#repo-my-basicport) | 22 | +0 | 1 |
| [shdocport](#repo-shdocport) | 20 | +0 | 2 |
| [sshpassport](#repo-sshpassport) | 18 | +0 | 1 |
| [git-lfsport](#repo-git-lfsport) | 18 | +0 | 1 |
| [bzip2port](#repo-bzip2port) | 17 | +0 | 1 |
| [cunitport](#repo-cunitport) | 17 | +0 | 2 |
| [makeport](#repo-makeport) | 16 | +0 | 1 |
| [curlport](#repo-curlport) | 15 | +0 | 1 |
| [xzport](#repo-xzport) | 15 | +0 | 1 |
| [opensslport](#repo-opensslport) | 15 | +0 | 1 |
| [libgdbmport](#repo-libgdbmport) | 15 | +0 | 1 |
| [libpipelineport](#repo-libpipelineport) | 15 | +0 | 1 |
| [libpcre2port](#repo-libpcre2port) | 15 | +0 | 1 |
| [libxsltport](#repo-libxsltport) | 15 | +0 | 1 |
| [libpcreport](#repo-libpcreport) | 15 | +0 | 1 |
| [libmdport](#repo-libmdport) | 15 | +0 | 1 |
| [tarport](#repo-tarport) | 14 | +0 | 1 |
| [nghttp2port](#repo-nghttp2port) | 14 | +0 | 1 |
| [bisonport](#repo-bisonport) | 13 | +0 | 1 |
| [ncduport](#repo-ncduport) | 13 | +0 | 1 |
| [luaport](#repo-luaport) | 13 | +0 | 1 |
| [lpegport](#repo-lpegport) | 13 | +0 | 1 |
| [stowport](#repo-stowport) | 13 | +0 | 1 |
| [edport](#repo-edport) | 13 | +13 | 1 |
| [lzipport](#repo-lzipport) | 13 | +13 | 1 |
| [libxml2port](#repo-libxml2port) | 12 | +0 | 1 |
| [zlibport](#repo-zlibport) | 0 | +0 | 0 |
| [help2manport](#repo-help2manport) | 0 | +0 | 0 |
| [zotsampleport](#repo-zotsampleport) | 0 | +0 | 0 |
| [man-dbport](#repo-man-dbport) | 0 | +0 | 0 |
| [shufport](#repo-shufport) | 0 | +0 | 0 |
| [wgetport](#repo-wgetport) | 0 | +0 | 0 |
| [gperfport](#repo-gperfport) | 0 | +0 | 0 |
| [zoslibport](#repo-zoslibport) | 0 | +0 | 0 |
| [re2cport](#repo-re2cport) | 0 | +0 | 0 |
| [cscopeport](#repo-cscopeport) | 0 | +0 | 0 |
| [gnulibport](#repo-gnulibport) | 0 | +0 | 0 |
| [helloport](#repo-helloport) | 0 | +0 | 0 |
| [htopport](#repo-htopport) | 0 | +0 | 0 |
| [metaport](#repo-metaport) | 0 | +0 | 0 |
| [zigiport](#repo-zigiport) | 0 | +0 | 0 |
| [yqport](#repo-yqport) | 0 | +0 | 0 |
| [direnvport](#repo-direnvport) | 0 | +0 | 0 |
| [libgit2port](#repo-libgit2port) | 0 | +0 | 0 |
| [duckdbport](#repo-duckdbport) | 0 | +0 | 0 |
| [powerlinegoport](#repo-powerlinegoport) | 0 | +0 | 0 |
| [byaccport](#repo-byaccport) | 0 | +0 | 0 |
| [bumpport](#repo-bumpport) | 0 | +0 | 0 |
| [c3270port](#repo-c3270port) | 0 | +0 | 0 |
| [gumport](#repo-gumport) | 0 | +0 | 0 |
| [wharfport](#repo-wharfport) | 0 | +0 | 0 |
| [dufport](#repo-dufport) | 0 | +0 | 0 |
| [onigurumaport](#repo-onigurumaport) | 0 | +0 | 0 |
| [multitailport](#repo-multitailport) | 0 | +0 | 0 |
| [janssonport](#repo-janssonport) | 0 | +0 | 0 |
| [luarocksport](#repo-luarocksport) | 0 | +0 | 0 |
| [termenvport](#repo-termenvport) | 0 | +0 | 0 |
| [esbuildport](#repo-esbuildport) | 0 | +0 | 0 |
| [nginxport](#repo-nginxport) | 0 | +0 | 0 |
| [natsport](#repo-natsport) | 0 | +0 | 0 |
| [githubcliport](#repo-githubcliport) | 0 | +0 | 0 |
| [zos-code-page-toolsport](#repo-zos-code-page-toolsport) | 0 | +0 | 0 |
| [gnport](#repo-gnport) | 0 | +0 | 0 |
| [v8port](#repo-v8port) | 0 | +0 | 0 |
| [dos2unixport](#repo-dos2unixport) | 0 | +0 | 0 |
| [zospstreeport](#repo-zospstreeport) | 0 | +0 | 0 |
| [zosncport](#repo-zosncport) | 0 | +0 | 0 |
| [boostport](#repo-boostport) | 0 | +0 | 0 |
| [buildkiteport](#repo-buildkiteport) | 0 | +0 | 0 |
| [antport](#repo-antport) | 0 | +0 | 0 |
| [jrubyport](#repo-jrubyport) | 0 | +0 | 0 |
| [toolsandtoysport](#repo-toolsandtoysport) | 0 | +0 | 0 |
| [groovyport](#repo-groovyport) | 0 | +0 | 0 |
| [kotlinport](#repo-kotlinport) | 0 | +0 | 0 |
| [caddyport](#repo-caddyport) | 0 | +0 | 0 |
| [gitlabcliport](#repo-gitlabcliport) | 0 | +0 | 0 |
| [fqport](#repo-fqport) | 0 | +0 | 0 |
| [promptersport](#repo-promptersport) | 0 | +0 | 0 |
| [osv-scannerport](#repo-osv-scannerport) | 0 | +0 | 0 |
| [ginport](#repo-ginport) | 0 | +0 | 0 |
| [frpport](#repo-frpport) | 0 | +0 | 0 |
| [mavenport](#repo-mavenport) | 0 | +0 | 0 |
| [ttypeport](#repo-ttypeport) | 0 | +0 | 0 |
| [cosignport](#repo-cosignport) | 0 | +0 | 0 |
| [jenkinsport](#repo-jenkinsport) | 0 | +0 | 0 |
| [godsectport](#repo-godsectport) | 0 | +0 | 0 |
| [murexport](#repo-murexport) | 0 | +0 | 0 |
| [grafanaport](#repo-grafanaport) | 0 | +0 | 0 |
| [iperfport](#repo-iperfport) | 0 | N/A | 0 |
| [fxport](#repo-fxport) | 0 | +0 | 0 |
| [s5cmdport](#repo-s5cmdport) | 0 | +0 | 0 |
| [parse-gotestport](#repo-parse-gotestport) | 0 | +0 | 0 |
| [check_clangport](#repo-check-clangport) | 0 | +0 | 0 |
| [check_xlclangport](#repo-check-xlclangport) | 0 | +0 | 0 |
| [check_pythonport](#repo-check-pythonport) | 0 | +0 | 0 |
| [check_javaport](#repo-check-javaport) | 0 | +0 | 0 |
| [check_goport](#repo-check-goport) | 0 | +0 | 0 |
| [nmapport](#repo-nmapport) | 0 | N/A | 0 |
| [hugoport](#repo-hugoport) | 0 | +0 | 0 |
| [dialogport](#repo-dialogport) | 0 | +0 | 0 |
| [joeport](#repo-joeport) | 0 | N/A | 0 |
| [cjsonport](#repo-cjsonport) | 0 | +0 | 0 |
| [libdioport](#repo-libdioport) | 0 | +0 | 0 |
| [git-chglogport](#repo-git-chglogport) | 0 | N/A | 0 |
| [zedc_asciiport](#repo-zedc-asciiport) | 0 | +0 | 0 |
| [bash-completionport](#repo-bash-completionport) | 0 | +0 | 0 |
| [zusageport](#repo-zusageport) | 0 | +0 | 0 |
| [spdlogport](#repo-spdlogport) | 0 | +0 | 0 |
| [creduceport](#repo-creduceport) | 0 | +0 | 0 |
| [gradleport](#repo-gradleport) | 0 | N/A | 0 |
| [luajitport](#repo-luajitport) | 0 | +0 | 0 |
| [cpioport](#repo-cpioport) | 0 | +0 | 0 |
| [bcport](#repo-bcport) | 0 | +0 | 0 |
| [git-sizerport](#repo-git-sizerport) | 0 | +0 | 0 |
| [chezmoiport](#repo-chezmoiport) | 0 | N/A | 0 |
| [jdport](#repo-jdport) | 0 | +0 | 0 |
| [libarchiveport](#repo-libarchiveport) | 0 | +0 | 0 |
| [aprport](#repo-aprport) | 0 | +0 | 0 |

---

# Detailed Repository Reports

<a id="repo-librdkafkaport"></a>
## librdkafkaport

- **Origin Date (First Commit):** 2023-07-27
- **Current Patch LOC:** 2,638
- **Current Patch Count:** 54

### Historical Trends

![LOC Trend for librdkafkaport](images/upstream/librdkafkaport_current_loc_trend.png)
![Count Trend for librdkafkaport](images/upstream/librdkafkaport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.self.patch` | `patches` | 20 |
| `patches/examples/alter_consumer_group_offsets.c.patch` | `patches` | 13 |
| `patches/examples/describe_consumer_groups.c.patch` | `patches` | 13 |
| `patches/examples/incremental_alter_configs.c.patch` | `patches` | 13 |
| `patches/examples/kafkatest_verifiable_client.cpp.patch` | `patches` | 13 |
| `patches/examples/list_consumer_group_offsets.c.patch` | `patches` | 13 |
| `patches/examples/list_consumer_groups.c.patch` | `patches` | 13 |
| `patches/examples/misc.c.patch` | `patches` | 13 |
| `patches/examples/openssl_engine_example.cpp.patch` | `patches` | 13 |
| `patches/examples/rdkafka_complex_consumer_example.c.patch` | `patches` | 14 |
| `patches/examples/rdkafka_complex_consumer_example.cpp.patch` | `patches` | 13 |
| `patches/examples/rdkafka_example.c.patch` | `patches` | 14 |
| `patches/examples/rdkafka_example.cpp.patch` | `patches` | 13 |
| `patches/examples/user_scram.c.patch` | `patches` | 13 |
| `patches/mklove/Makefile.base.patch` | `patches` | 41 |
| `patches/src-cpp/Makefile.patch` | `patches` | 13 |
| `patches/src/rd.h.patch` | `patches` | 40 |
| `patches/src/rdaddr.c.patch` | `patches` | 125 |
| `patches/src/rdcrc32.c.patch` | `patches` | 13 |
| `patches/src/rdcrc32.h.patch` | `patches` | 22 |
| `patches/src/rdendian.h.patch` | `patches` | 14 |
| `patches/src/rdhdrhistogram.c.patch` | `patches` | 25 |
| `patches/src/rdhttp.c.patch` | `patches` | 77 |
| `patches/src/rdkafka.c.patch` | `patches` | 367 |
| `patches/src/rdkafka.h.patch` | `patches` | 16 |
| `patches/src/rdkafka_broker.c.patch` | `patches` | 48 |
| `patches/src/rdkafka_conf.c.patch` | `patches` | 264 |
| `patches/src/rdkafka_conf.h.patch` | `patches` | 28 |
| `patches/src/rdkafka_feature.c.patch` | `patches` | 51 |
| `patches/src/rdkafka_int.h.patch` | `patches` | 62 |
| `patches/src/rdkafka_interceptor.c.patch` | `patches` | 34 |
| `patches/src/rdkafka_offset.c.patch` | `patches` | 58 |
| `patches/src/rdkafka_op.c.patch` | `patches` | 21 |
| `patches/src/rdkafka_partition.c.patch` | `patches` | 34 |
| `patches/src/rdkafka_queue.c.patch` | `patches` | 73 |
| `patches/src/rdkafka_queue.h.patch` | `patches` | 18 |
| `patches/src/rdkafka_request.c.patch` | `patches` | 25 |
| `patches/src/rdkafka_sasl_oauthbearer_oidc.c.patch` | `patches` | 371 |
| `patches/src/rdkafka_ssl.c.patch` | `patches` | 58 |
| `patches/src/rdkafka_transport.c.patch` | `patches` | 137 |
| `patches/src/rdkafka_transport_int.h.patch` | `patches` | 15 |
| `patches/src/rdlist.c.patch` | `patches` | 72 |
| `patches/src/rdports.c.patch` | `patches` | 52 |
| `patches/src/rdposix.h.patch` | `patches` | 49 |
| `patches/src/rdrand.c.patch` | `patches` | 38 |
| `patches/src/snappy_compat.h.patch` | `patches` | 13 |
| `patches/src/tinycthread.c.patch` | `patches` | 66 |
| `patches/src/tinycthread.h.patch` | `patches` | 16 |
| `patches/src/tinycthread_extra.c.patch` | `patches` | 13 |
| `patches/tests/0017-compression.c.patch` | `patches` | 16 |
| `patches/tests/0056-balanced_group_mt.c.patch` | `patches` | 16 |
| `patches/tests/0146-metadata_mock.c.patch` | `patches` | 13 |
| `patches/tests/sockem.c.patch` | `patches` | 17 |
| `patches/tests/sockem_ctrl.h.patch` | `patches` | 16 |

---

<a id="repo-bashport"></a>
## bashport

- **Origin Date (First Commit):** 2022-10-26
- **Current Patch LOC:** 1,698
- **Current Patch Count:** 32

### Historical Trends

![LOC Trend for bashport](images/upstream/bashport_current_loc_trend.png)
![Count Trend for bashport](images/upstream/bashport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `dev-patches/aclocal.patch` | `dev-patches` | 23 |
| `dev-patches/array.tests.patch` | `dev-patches` | 64 |
| `dev-patches/dontupstream/read.tests.patch` | `dev-patches` | 13 |
| `dev-patches/dontupstream/redir10.patch` | `dev-patches` | 13 |
| `dev-patches/dontupstream/run-all_and_diff.patch` | `dev-patches` | 72 |
| `dev-patches/source6.sub.patch` | `dev-patches` | 13 |
| `stable-patches/Makefile.in.patch` | `stable-patches` | 13 |
| `stable-patches/PR1.patch` | `stable-patches` | 53 |
| `stable-patches/PR2.patch` | `stable-patches` | 769 |
| `stable-patches/PR3/builtins.right.patch` | `stable-patches` | 40 |
| `stable-patches/PR3/coproc.tests.patch` | `stable-patches` | 13 |
| `stable-patches/PR3/dstack.right.patch` | `stable-patches` | 10 |
| `stable-patches/PR3/errors.right.patch` | `stable-patches` | 30 |
| `stable-patches/PR3/exec.right.patch` | `stable-patches` | 41 |
| `stable-patches/PR3/exportfunc.right.patch` | `stable-patches` | 18 |
| `stable-patches/PR3/heredoc.right.patch` | `stable-patches` | 13 |
| `stable-patches/PR3/intl.right.patch` | `stable-patches` | 13 |
| `stable-patches/PR3/new-exp.right.patch` | `stable-patches` | 13 |
| `stable-patches/PR3/redir.right.patch` | `stable-patches` | 20 |
| `stable-patches/PR3/redir.tests.patch` | `stable-patches` | 13 |
| `stable-patches/PR3/redir10.sub.patch` | `stable-patches` | 15 |
| `stable-patches/PR3/signames.c.patch` | `stable-patches` | 35 |
| `stable-patches/PR3/smatch.c.patch` | `stable-patches` | 49 |
| `stable-patches/PR3/test1.sub.patch` | `stable-patches` | 13 |
| `stable-patches/PR3/trap.right.patch` | `stable-patches` | 61 |
| `stable-patches/PR3/trap.tests.patch` | `stable-patches` | 13 |
| `stable-patches/PR3/vredir.right.patch` | `stable-patches` | 10 |
| `stable-patches/PR3/vredir.tests.patch` | `stable-patches` | 17 |
| `stable-patches/configure.patch` | `stable-patches` | 53 |
| `stable-patches/findcmd.c.patch` | `stable-patches` | 22 |
| `stable-patches/kill.def.patch` | `stable-patches` | 123 |
| `stable-patches/sig.c.patch` | `stable-patches` | 30 |

---

<a id="repo-libuvport"></a>
## libuvport

- **Origin Date (First Commit):** 2023-09-14
- **Current Patch LOC:** 1,462
- **Current Patch Count:** 26

### Historical Trends

![LOC Trend for libuvport](images/upstream/libuvport_current_loc_trend.png)
![Count Trend for libuvport](images/upstream/libuvport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `stable-patches/CMakeLists.txt.patch` | `stable-patches` | 69 |
| `stable-patches/docs/src/fs.rst.patch` | `stable-patches` | 15 |
| `stable-patches/include/uv.h.patch` | `stable-patches` | 22 |
| `stable-patches/include/uv/errno.h.patch` | `stable-patches` | 17 |
| `stable-patches/include/uv/os390.h.patch` | `stable-patches` | 21 |
| `stable-patches/src/unix/core.c.patch` | `stable-patches` | 109 |
| `stable-patches/src/unix/fs.c.patch` | `stable-patches` | 131 |
| `stable-patches/src/unix/internal.h.patch` | `stable-patches` | 19 |
| `stable-patches/src/unix/linux.c.patch` | `stable-patches` | 28 |
| `stable-patches/src/unix/os390-syscalls.c.patch` | `stable-patches` | 183 |
| `stable-patches/src/unix/os390-syscalls.h.patch` | `stable-patches` | 26 |
| `stable-patches/src/unix/os390.c.patch` | `stable-patches` | 144 |
| `stable-patches/src/unix/process.c.patch` | `stable-patches` | 105 |
| `stable-patches/src/unix/stream.c.patch` | `stable-patches` | 120 |
| `stable-patches/src/unix/tcp.c.patch` | `stable-patches` | 40 |
| `stable-patches/src/unix/thread.c.patch` | `stable-patches` | 25 |
| `stable-patches/src/uv-common.c.patch` | `stable-patches` | 15 |
| `stable-patches/test/run-tests.c.patch` | `stable-patches` | 27 |
| `stable-patches/test/task.h.patch` | `stable-patches` | 24 |
| `stable-patches/test/test-fs-copyfile.c.patch` | `stable-patches` | 31 |
| `stable-patches/test/test-fs.c.patch` | `stable-patches` | 17 |
| `stable-patches/test/test-get-currentexe.c.patch` | `stable-patches` | 159 |
| `stable-patches/test/test-get-passwd.c.patch` | `stable-patches` | 13 |
| `stable-patches/test/test-list.h.patch` | `stable-patches` | 20 |
| `stable-patches/test/test-spawn.c.patch` | `stable-patches` | 59 |
| `stable-patches/test/test-thread-priority.c.patch` | `stable-patches` | 23 |

---

<a id="repo-sudoport"></a>
## sudoport

- **Origin Date (First Commit):** 2023-03-07
- **Current Patch LOC:** 1,278
- **Current Patch Count:** 30

### Historical Trends

![LOC Trend for sudoport](images/upstream/sudoport_current_loc_trend.png)
![Count Trend for sudoport](images/upstream/sudoport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/configure.patch` | `patches` | 15 |
| `patches/PR1/include/sudo_iolog.h.patch` | `patches` | 12 |
| `patches/PR1/lib/eventlog/Makefile.in.patch` | `patches` | 13 |
| `patches/PR1/lib/util/getentropy.c.patch` | `patches` | 42 |
| `patches/PR1/lib/util/mmap_alloc.c.patch` | `patches` | 45 |
| `patches/PR1/lib/util/progname.c.patch` | `patches` | 13 |
| `patches/PR1/lib/util/pw_dup.c.patch` | `patches` | 32 |
| `patches/PR1/lib/util/regress/mktemp/mktemp_test.c.patch` | `patches` | 28 |
| `patches/PR1/lib/util/sig2str.c.patch` | `patches` | 256 |
| `patches/PR1/lib/util/str2sig.c.patch` | `patches` | 15 |
| `patches/PR1/plugins/group_file/getgrent.c.patch` | `patches` | 14 |
| `patches/PR1/plugins/sudoers/auth/passwd.c.patch` | `patches` | 95 |
| `patches/PR1/plugins/sudoers/check_aliases.c.patch` | `patches` | 33 |
| `patches/PR1/plugins/sudoers/cvtsudoers_pwutil.c.patch` | `patches` | 64 |
| `patches/PR1/plugins/sudoers/defaults.c.patch` | `patches` | 34 |
| `patches/PR1/plugins/sudoers/env.c.patch` | `patches` | 18 |
| `patches/PR1/plugins/sudoers/getspwuid.c.patch` | `patches` | 18 |
| `patches/PR1/plugins/sudoers/pwutil.c.patch` | `patches` | 45 |
| `patches/PR1/plugins/sudoers/pwutil_impl.c.patch` | `patches` | 52 |
| `patches/PR1/plugins/sudoers/regress/testsudoers/test9.sh.patch` | `patches` | 20 |
| `patches/PR1/plugins/sudoers/set_perms.c.patch` | `patches` | 180 |
| `patches/PR1/plugins/sudoers/sudoers.c.patch` | `patches` | 17 |
| `patches/PR1/plugins/sudoers/testsudoers.c.patch` | `patches` | 16 |
| `patches/PR1/plugins/sudoers/tsgetgrpw.c.patch` | `patches` | 35 |
| `patches/PR1/scripts/install-sh.patch` | `patches` | 44 |
| `patches/PR1/src/exec.c.patch` | `patches` | 30 |
| `patches/PR1/src/get_pty.c.patch` | `patches` | 26 |
| `patches/PR1/src/net_ifs.c.patch` | `patches` | 15 |
| `patches/PR1/src/preload.c.patch` | `patches` | 14 |
| `patches/PR1/src/sudo.c.patch` | `patches` | 37 |

---

<a id="repo-coreutilsport"></a>
## coreutilsport

- **Origin Date (First Commit):** 2022-04-29
- **Current Patch LOC:** 1,169
- **Current Patch Count:** 18

### Historical Trends

![LOC Trend for coreutilsport](images/upstream/coreutilsport_current_loc_trend.png)
![Count Trend for coreutilsport](images/upstream/coreutilsport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `stable-patches/Makefile.in.patch` | `stable-patches` | 12 |
| `stable-patches/build-aux/test-driver.patch` | `stable-patches` | 13 |
| `stable-patches/lib/fdopendir.c.patch` | `stable-patches` | 14 |
| `stable-patches/lib/fts.c.patch` | `stable-patches` | 17 |
| `stable-patches/lib/getprogname.c.patch` | `stable-patches` | 21 |
| `stable-patches/lib/nproc.c.patch` | `stable-patches` | 15 |
| `stable-patches/lib/posix_memalign.c.patch` | `stable-patches` | 22 |
| `stable-patches/lib/stat-time.h.patch` | `stable-patches` | 13 |
| `stable-patches/src/basenc.c.patch` | `stable-patches` | 15 |
| `stable-patches/src/cat.c.patch` | `stable-patches` | 314 |
| `stable-patches/src/copy.c.patch` | `stable-patches` | 41 |
| `stable-patches/src/cp.c.patch` | `stable-patches` | 61 |
| `stable-patches/src/digest.c.patch` | `stable-patches` | 61 |
| `stable-patches/src/ls.c.patch` | `stable-patches` | 201 |
| `stable-patches/src/od.c.patch` | `stable-patches` | 16 |
| `stable-patches/src/pinky.c.patch` | `stable-patches` | 50 |
| `stable-patches/src/stat.c.patch` | `stable-patches` | 253 |
| `stable-patches/src/timeout.c.patch` | `stable-patches` | 30 |

---

<a id="repo-cmakeport"></a>
## cmakeport

- **Origin Date (First Commit):** 2022-04-21
- **Current Patch LOC:** 1,092
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for cmakeport](images/upstream/cmakeport_current_loc_trend.png)
![Count Trend for cmakeport](images/upstream/cmakeport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 1,092 |

---

<a id="repo-gitport"></a>
## gitport

- **Origin Date (First Commit):** 2022-05-25
- **Current Patch LOC:** 974
- **Current Patch Count:** 31

### Historical Trends

![LOC Trend for gitport](images/upstream/gitport_current_loc_trend.png)
![Count Trend for gitport](images/upstream/gitport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `dev-patches/PR1/newline.patch` | `dev-patches` | 13 |
| `dev-patches/PR1/nogreph.patch` | `dev-patches` | 14 |
| `dev-patches/PR1/releasenamecollision-pack.patch` | `dev-patches` | 22 |
| `dev-patches/PR1/releasenamecollision.patch` | `dev-patches` | 89 |
| `stable-patches/Makefile.patch` | `stable-patches` | 84 |
| `stable-patches/archive.c.patch` | `stable-patches` | 15 |
| `stable-patches/attr.c.patch` | `stable-patches` | 16 |
| `stable-patches/blame.c.patch` | `stable-patches` | 16 |
| `stable-patches/builtin.h.patch` | `stable-patches` | 13 |
| `stable-patches/combine-diff.c.patch` | `stable-patches` | 15 |
| `stable-patches/config.c.patch` | `stable-patches` | 33 |
| `stable-patches/config.mak.uname.patch` | `stable-patches` | 24 |
| `stable-patches/configure.ac.patch` | `stable-patches` | 14 |
| `stable-patches/convert.c.patch` | `stable-patches` | 142 |
| `stable-patches/copy.c.patch` | `stable-patches` | 14 |
| `stable-patches/diff.c.patch` | `stable-patches` | 42 |
| `stable-patches/entry.c.patch` | `stable-patches` | 77 |
| `stable-patches/environment.c.patch` | `stable-patches` | 15 |
| `stable-patches/environment.h.patch` | `stable-patches` | 15 |
| `stable-patches/exec-cmd.c.patch` | `stable-patches` | 15 |
| `stable-patches/generate-perl.sh.patch` | `stable-patches` | 13 |
| `stable-patches/git-compat-util.h.patch` | `stable-patches` | 16 |
| `stable-patches/hash-object.c.patch` | `stable-patches` | 15 |
| `stable-patches/http.c.patch` | `stable-patches` | 23 |
| `stable-patches/lockfile.c.patch` | `stable-patches` | 14 |
| `stable-patches/object-file.c.patch` | `stable-patches` | 106 |
| `stable-patches/quote.c.patch` | `stable-patches` | 22 |
| `stable-patches/read-cache-ll.h.patch` | `stable-patches` | 15 |
| `stable-patches/read-cache.c.patch` | `stable-patches` | 14 |
| `stable-patches/test-lib.sh.patch` | `stable-patches` | 13 |
| `stable-patches/utf8.c.patch` | `stable-patches` | 35 |

---

<a id="repo-valgrindport"></a>
## valgrindport

- **Origin Date (First Commit):** 2024-12-04
- **Current Patch LOC:** 896
- **Current Patch Count:** 3

### Historical Trends

![LOC Trend for valgrindport](images/upstream/valgrindport_current_loc_trend.png)
![Count Trend for valgrindport](images/upstream/valgrindport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.all.am.patch` | `patches` | 13 |
| `patches/guest_s390_defs.h.patch` | `patches` | 16 |
| `patches/guest_s390_helpers.c.patch` | `patches` | 867 |

---

<a id="repo-gzipport"></a>
## gzipport

- **Origin Date (First Commit):** 2022-04-21
- **Current Patch LOC:** 690
- **Current Patch Count:** 8

### Historical Trends

![LOC Trend for gzipport](images/upstream/gzipport_current_loc_trend.png)
![Count Trend for gzipport](images/upstream/gzipport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.in.patch` | `patches` | 70 |
| `patches/gzip.c.patch` | `patches` | 192 |
| `patches/gzip.h.patch` | `patches` | 22 |
| `patches/test-reference.patch` | `patches` | 37 |
| `patches/unzip.c.patch` | `patches` | 24 |
| `patches/zedc.c.patch` | `patches` | 236 |
| `patches/zip.c.patch` | `patches` | 79 |
| `patches/zos.h.patch` | `patches` | 30 |

---

<a id="repo-gpgport"></a>
## gpgport

- **Origin Date (First Commit):** 2023-05-17
- **Current Patch LOC:** 687
- **Current Patch Count:** 13

### Historical Trends

![LOC Trend for gpgport](images/upstream/gpgport_current_loc_trend.png)
![Count Trend for gpgport](images/upstream/gpgport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/call-gpg.c.patch` | `patches` | 54 |
| `patches/call-pinentry.c.patch` | `patches` | 31 |
| `patches/command.c.patch` | `patches` | 13 |
| `patches/configure.ac.patch` | `patches` | 13 |
| `patches/configure.patch` | `patches` | 27 |
| `patches/decrypt.c.patch` | `patches` | 15 |
| `patches/dns.c.patch` | `patches` | 13 |
| `patches/ffi.c.patch` | `patches` | 14 |
| `patches/gpg-agent.c.patch` | `patches` | 107 |
| `patches/homedir.c.patch` | `patches` | 326 |
| `patches/openfile.c.patch` | `patches` | 37 |
| `patches/server.c.patch` | `patches` | 22 |
| `patches/t-exectool.c.patch` | `patches` | 15 |

---

<a id="repo-procpsport"></a>
## procpsport

- **Origin Date (First Commit):** 2024-07-26
- **Current Patch LOC:** 687
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for procpsport](images/upstream/procpsport_current_loc_trend.png)
![Count Trend for procpsport](images/upstream/procpsport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 687 |

---

<a id="repo-perlport"></a>
## perlport

- **Origin Date (First Commit):** 2021-11-12
- **Current Patch LOC:** 683
- **Current Patch Count:** 13

### Historical Trends

![LOC Trend for perlport](images/upstream/perlport_current_loc_trend.png)
![Count Trend for perlport](images/upstream/perlport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/Configure.patch` | `patches` | 32 |
| `patches/PR1/Makefile.SH.patch` | `patches` | 54 |
| `patches/PR1/cpan/IPC-SysV/SysV.xs.patch` | `patches` | 13 |
| `patches/PR1/doio.c.patch` | `patches` | 135 |
| `patches/PR1/ext/ExtUtils-Miniperl/lib/ExtUtils/Miniperl.pm.patch` | `patches` | 20 |
| `patches/PR1/hints/os390.sh.patch` | `patches` | 141 |
| `patches/PR1/installperl.patch` | `patches` | 36 |
| `patches/PR1/iperlsys.h.patch` | `patches` | 28 |
| `patches/PR1/lib/File/Copy.pm.patch` | `patches` | 16 |
| `patches/PR1/makedepend_file.SH.patch` | `patches` | 16 |
| `patches/PR1/os390/os390.c.patch` | `patches` | 62 |
| `patches/PR1/perl.c.patch` | `patches` | 24 |
| `patches/PR1/util.c.patch` | `patches` | 106 |

---

<a id="repo-unzipport"></a>
## unzipport

- **Origin Date (First Commit):** 2022-11-14
- **Current Patch LOC:** 549
- **Current Patch Count:** 12

### Historical Trends

![LOC Trend for unzipport](images/upstream/unzipport_current_loc_trend.png)
![Count Trend for unzipport](images/upstream/unzipport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/ebcdic.h.patch` | `patches` | 48 |
| `patches/extract.c.patch` | `patches` | 23 |
| `patches/fileio.c.patch` | `patches` | 67 |
| `patches/globals.h.patch` | `patches` | 18 |
| `patches/process.c.patch` | `patches` | 13 |
| `patches/riscos.h.patch` | `patches` | 16 |
| `patches/ttyio.c.patch` | `patches` | 29 |
| `patches/unix.c.patch` | `patches` | 197 |
| `patches/unxcfg.h.patch` | `patches` | 72 |
| `patches/unzip.h.patch` | `patches` | 27 |
| `patches/unzpriv.h.patch` | `patches` | 25 |
| `patches/zipinfo.c.patch` | `patches` | 14 |

---

<a id="repo-cronieport"></a>
## cronieport

- **Origin Date (First Commit):** 2024-06-26
- **Current Patch LOC:** 510
- **Current Patch Count:** 13

### Historical Trends

![LOC Trend for cronieport](images/upstream/cronieport_current_loc_trend.png)
![Count Trend for cronieport](images/upstream/cronieport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makemodule.am.patch` | `patches` | 13 |
| `patches/cron-zos-paths.c.patch` | `patches` | 109 |
| `patches/cron-zos-paths.h.patch` | `patches` | 59 |
| `patches/cron.c.patch` | `patches` | 14 |
| `patches/cronnext.c.patch` | `patches` | 37 |
| `patches/crontab.c.patch` | `patches` | 23 |
| `patches/database.c.patch` | `patches` | 23 |
| `patches/entry.c.patch` | `patches` | 25 |
| `patches/genlib.sh.patch` | `patches` | 77 |
| `patches/pathnames.h.patch` | `patches` | 30 |
| `patches/popen.c.patch` | `patches` | 30 |
| `patches/pw_dup.c.patch` | `patches` | 57 |
| `patches/readtab.c.patch` | `patches` | 13 |

---

<a id="repo-util-linuxport"></a>
## util-linuxport

- **Origin Date (First Commit):** 2023-11-22
- **Current Patch LOC:** 489
- **Current Patch Count:** 12

### Historical Trends

![LOC Trend for util-linuxport](images/upstream/util_linuxport_current_loc_trend.png)
![Count Trend for util-linuxport](images/upstream/util_linuxport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/blkdev.patch` | `patches` | 20 |
| `patches/c.h.patch` | `patches` | 37 |
| `patches/c_strtod.c.patch` | `patches` | 15 |
| `patches/configure.ac.patch` | `patches` | 74 |
| `patches/gen_uuid.c.patch` | `patches` | 50 |
| `patches/monotonic.c.patch` | `patches` | 13 |
| `patches/pty-session.patch` | `patches` | 131 |
| `patches/setsid.c.patch` | `patches` | 15 |
| `patches/strutils.c.patch` | `patches` | 12 |
| `patches/term-utils.patch` | `patches` | 65 |
| `patches/ttyutils.patch` | `patches` | 44 |
| `patches/widechar.h.patch` | `patches` | 13 |

---

<a id="repo-screenport"></a>
## screenport

- **Origin Date (First Commit):** 2022-10-31
- **Current Patch LOC:** 485
- **Current Patch Count:** 7

### Historical Trends

![LOC Trend for screenport](images/upstream/screenport_current_loc_trend.png)
![Count Trend for screenport](images/upstream/screenport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 140 |
| `patches/acls.c.patch` | `patches` | 16 |
| `patches/comm.sh.patch` | `patches` | 14 |
| `patches/pty.c.patch` | `patches` | 83 |
| `patches/screen.c.patch` | `patches` | 80 |
| `patches/tty.sh.patch` | `patches` | 40 |
| `patches/utmp.c.patch` | `patches` | 112 |

---

<a id="repo-tmuxport"></a>
## tmuxport

- **Origin Date (First Commit):** 2024-01-15
- **Current Patch LOC:** 440
- **Current Patch Count:** 13

### Historical Trends

![LOC Trend for tmuxport](images/upstream/tmuxport_current_loc_trend.png)
![Count Trend for tmuxport](images/upstream/tmuxport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/client.c.patch` | `patches` | 0 |
| `patches/cmd-pipe-pane.c.patch` | `patches` | 22 |
| `patches/configure.ac.patch` | `patches` | 23 |
| `patches/environ.c.patch` | `patches` | 20 |
| `patches/forkpty-zos.c.patch` | `patches` | 120 |
| `patches/job.c.patch` | `patches` | 26 |
| `patches/osdep-zos.c.patch` | `patches` | 63 |
| `patches/server.c.patch` | `patches` | 17 |
| `patches/spawn.c.patch` | `patches` | 46 |
| `patches/tmux.c.patch` | `patches` | 30 |
| `patches/tmux.h.patch` | `patches` | 31 |
| `patches/tty-keys.c.patch` | `patches` | 22 |
| `patches/tty.c.patch` | `patches` | 20 |

---

<a id="repo-treeport"></a>
## treeport

- **Origin Date (First Commit):** 2023-11-14
- **Current Patch LOC:** 425
- **Current Patch Count:** 3

### Historical Trends

![LOC Trend for treeport](images/upstream/treeport_current_loc_trend.png)
![Count Trend for treeport](images/upstream/treeport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.patch` | `patches` | 49 |
| `patches/manpage.patch` | `patches` | 42 |
| `patches/zossupport.patch` | `patches` | 334 |

---

<a id="repo-emacsport"></a>
## emacsport

- **Origin Date (First Commit):** 2023-03-10
- **Current Patch LOC:** 413
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for emacsport](images/upstream/emacsport_current_loc_trend.png)
![Count Trend for emacsport](images/upstream/emacsport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/beta.patch` | `patches` | 400 |
| `patches/keyboard.c.patch` | `patches` | 13 |

---

<a id="repo-opensshport"></a>
## opensshport

- **Origin Date (First Commit):** 2023-05-15
- **Current Patch LOC:** 376
- **Current Patch Count:** 19

### Historical Trends

![LOC Trend for opensshport](images/upstream/opensshport_current_loc_trend.png)
![Count Trend for opensshport](images/upstream/opensshport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/auth-passwd.c.patch` | `patches` | 16 |
| `patches/auth.c.patch` | `patches` | 17 |
| `patches/configure.patch` | `patches` | 16 |
| `patches/defines.h.patch` | `patches` | 17 |
| `patches/includes.h.patch` | `patches` | 14 |
| `patches/misc.c.patch` | `patches` | 56 |
| `patches/monitor_wrap.c.patch` | `patches` | 14 |
| `patches/openbsd-compat/port-net.c.patch` | `patches` | 14 |
| `patches/openbsd-compat/xcrypt.c.patch` | `patches` | 20 |
| `patches/packet.c.patch` | `patches` | 14 |
| `patches/pathnames.h.patch` | `patches` | 27 |
| `patches/platform.c.patch` | `patches` | 16 |
| `patches/readconf.c.patch` | `patches` | 17 |
| `patches/scp.c.patch` | `patches` | 22 |
| `patches/servconf.c.patch` | `patches` | 16 |
| `patches/sshbuf-io.c.patch` | `patches` | 14 |
| `patches/sshconnect.c.patch` | `patches` | 15 |
| `patches/sshd-session.c.patch` | `patches` | 37 |
| `patches/sshkey.c.patch` | `patches` | 14 |

---

<a id="repo-flexport"></a>
## flexport

- **Origin Date (First Commit):** 2022-11-25
- **Current Patch LOC:** 351
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for flexport](images/upstream/flexport_current_loc_trend.png)
![Count Trend for flexport](images/upstream/flexport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.in.patch` | `patches` | 318 |
| `patches/configure.patch` | `patches` | 33 |

---

<a id="repo-prometheusport"></a>
## prometheusport

- **Origin Date (First Commit):** 2024-05-16
- **Current Patch LOC:** 348
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for prometheusport](images/upstream/prometheusport_current_loc_trend.png)
![Count Trend for prometheusport](images/upstream/prometheusport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/prometheus.patch` | `patches` | 348 |

---

<a id="repo-pocoport"></a>
## pocoport

- **Origin Date (First Commit):** 2023-12-06
- **Current Patch LOC:** 343
- **Current Patch Count:** 9

### Historical Trends

![LOC Trend for pocoport](images/upstream/pocoport_current_loc_trend.png)
![Count Trend for pocoport](images/upstream/pocoport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/DirectoryWatcher.cpp.patch` | `patches` | 60 |
| `patches/Makefile.patch` | `patches` | 31 |
| `patches/Platform.h.patch` | `patches` | 14 |
| `patches/SharedMemory_POSIX.cpp.patch` | `patches` | 64 |
| `patches/Thread_POSIX.cpp.patch` | `patches` | 50 |
| `patches/Thread_POSIX.h.patch` | `patches` | 17 |
| `patches/VarHolder.h.patch` | `patches` | 71 |
| `patches/configure.patch` | `patches` | 13 |
| `patches/global.patch` | `patches` | 23 |

---

<a id="repo-rsyncport"></a>
## rsyncport

- **Origin Date (First Commit):** 2022-07-17
- **Current Patch LOC:** 341
- **Current Patch Count:** 6

### Historical Trends

![LOC Trend for rsyncport](images/upstream/rsyncport_current_loc_trend.png)
![Count Trend for rsyncport](images/upstream/rsyncport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.in.patch` | `patches` | 22 |
| `patches/PR1/addunistd.patch` | `patches` | 12 |
| `patches/PR1/rsync.h.patch` | `patches` | 50 |
| `patches/PR1/touchfix.patch` | `patches` | 11 |
| `patches/PR3/syscall.c.patch` | `patches` | 217 |
| `patches/pipe.c.patch` | `patches` | 29 |

---

<a id="repo-vimport"></a>
## vimport

- **Origin Date (First Commit):** 2022-06-24
- **Current Patch LOC:** 335
- **Current Patch Count:** 12

### Historical Trends

![LOC Trend for vimport](images/upstream/vimport_current_loc_trend.png)
![Count Trend for vimport](images/upstream/vimport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `dev-patches/Makefile.patch` | `dev-patches` | 13 |
| `dev-patches/abendfix.patch` | `dev-patches` | 13 |
| `stable-patches/buffwrite.c.patch` | `stable-patches` | 25 |
| `stable-patches/evalfunc.c.patch` | `stable-patches` | 18 |
| `stable-patches/fileio.c.patch` | `stable-patches` | 14 |
| `stable-patches/os_unix.c.patch` | `stable-patches` | 43 |
| `stable-patches/pty.c.patch` | `stable-patches` | 17 |
| `stable-patches/structs.h.patch` | `stable-patches` | 14 |
| `stable-patches/test_hlsearch.vim.patch` | `stable-patches` | 53 |
| `stable-patches/test_startup.vim.patch` | `stable-patches` | 34 |
| `stable-patches/test_syntax.vim.patch` | `stable-patches` | 79 |
| `stable-patches/vim.h.patch` | `stable-patches` | 12 |

---

<a id="repo-phpport"></a>
## phpport

- **Origin Date (First Commit):** 2022-10-19
- **Current Patch LOC:** 320
- **Current Patch Count:** 13

### Historical Trends

![LOC Trend for phpport](images/upstream/phpport_current_loc_trend.png)
![Count Trend for phpport](images/upstream/phpport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/basic_functions_arginfo.h.patch` | `patches` | 17 |
| `patches/configure.patch` | `patches` | 12 |
| `patches/dns.c.patch` | `patches` | 14 |
| `patches/hrtime.c.patch` | `patches` | 15 |
| `patches/hrtime.h.patch` | `patches` | 26 |
| `patches/microtime.c.patch` | `patches` | 13 |
| `patches/net.c.patch` | `patches` | 15 |
| `patches/network.c.patch` | `patches` | 17 |
| `patches/posix.c.patch` | `patches` | 36 |
| `patches/sljitNativeS390X.c.patch` | `patches` | 34 |
| `patches/zend_alloc.c.patch` | `patches` | 40 |
| `patches/zend_fibers.c.patch` | `patches` | 31 |
| `patches/zend_mmap.h.patch` | `patches` | 50 |

---

<a id="repo-neovimport"></a>
## neovimport

- **Origin Date (First Commit):** 2023-04-21
- **Current Patch LOC:** 312
- **Current Patch Count:** 12

### Historical Trends

![LOC Trend for neovimport](images/upstream/neovimport_current_loc_trend.png)
![Count Trend for neovimport](images/upstream/neovimport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `stable-patches/cmake.deps.cmake.BuildLua.cmake.patch` | `stable-patches` | 39 |
| `stable-patches/cmake.deps.cmake.BuildLuv.cmake.patch` | `stable-patches` | 29 |
| `stable-patches/cmake.deps.cmake.BuildTreesitter.cmake.patch` | `stable-patches` | 12 |
| `stable-patches/cmake.deps.cmake.BuildTreesitterParsers.cmake.patch` | `stable-patches` | 13 |
| `stable-patches/src.nvim.CMakeLists.txt.patch` | `stable-patches` | 42 |
| `stable-patches/src.nvim.buffer_defs.h.patch` | `stable-patches` | 15 |
| `stable-patches/src.nvim.bufwrite.c.patch` | `stable-patches` | 43 |
| `stable-patches/src.nvim.channel.c.patch` | `stable-patches` | 47 |
| `stable-patches/src.nvim.memfile.c.patch` | `stable-patches` | 12 |
| `stable-patches/src.nvim.os.pty_proc_unix.c.patch` | `stable-patches` | 32 |
| `stable-patches/src.nvim.tui.termkey.termkey.c.patch` | `stable-patches` | 15 |
| `stable-patches/src.nvim.undo.c.patch` | `stable-patches` | 13 |

---

<a id="repo-conanport"></a>
## conanport

- **Origin Date (First Commit):** 2024-08-15
- **Current Patch LOC:** 299
- **Current Patch Count:** 8

### Historical Trends

![LOC Trend for conanport](images/upstream/conanport_current_loc_trend.png)
![Count Trend for conanport](images/upstream/conanport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/conan/internal/api/detect/detect_api.py.patch` | `patches` | 31 |
| `patches/conan/internal/default_settings.py.patch` | `patches` | 27 |
| `patches/conan/test/utils/tools.py.patch` | `patches` | 20 |
| `patches/conan/tools/build/cppstd.py.patch` | `patches` | 29 |
| `patches/conan/tools/build/cstd.py.patch` | `patches` | 22 |
| `patches/conan/tools/build/flags.py.patch` | `patches` | 101 |
| `patches/conan/tools/gnu/gnudeps_flags.py.patch` | `patches` | 13 |
| `patches/conan/tools/meson/toolchain.py.patch` | `patches` | 56 |

---

<a id="repo-zipport"></a>
## zipport

- **Origin Date (First Commit):** 2022-10-27
- **Current Patch LOC:** 297
- **Current Patch Count:** 8

### Historical Trends

![LOC Trend for zipport](images/upstream/zipport_current_loc_trend.png)
![Count Trend for zipport](images/upstream/zipport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/fileio.c.patch` | `patches` | 17 |
| `patches/osdep.h.patch` | `patches` | 13 |
| `patches/unix.c.patch` | `patches` | 99 |
| `patches/zip.c.patch` | `patches` | 17 |
| `patches/zip.h.patch` | `patches` | 16 |
| `patches/zipnote.c.patch` | `patches` | 97 |
| `patches/zipup.c.patch` | `patches` | 21 |
| `patches/zipup.h.patch` | `patches` | 17 |

---

<a id="repo-redisport"></a>
## redisport

- **Origin Date (First Commit):** 2025-02-14
- **Current Patch LOC:** 263
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for redisport](images/upstream/redisport_current_loc_trend.png)
![Count Trend for redisport](images/upstream/redisport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/pr.patch` | `patches` | 263 |

---

<a id="repo-gitlab-runnerport"></a>
## gitlab-runnerport

- **Origin Date (First Commit):** 2023-12-13
- **Current Patch LOC:** 241
- **Current Patch Count:** 10

### Historical Trends

![LOC Trend for gitlab-runnerport](images/upstream/gitlab_runnerport_current_loc_trend.png)
![Count Trend for gitlab-runnerport](images/upstream/gitlab_runnerport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/commander_unix.go.patch` | `patches` | 10 |
| `patches/config_unix.go.patch` | `patches` | 22 |
| `patches/dump_unix.go.patch` | `patches` | 22 |
| `patches/job_unix.go.patch` | `patches` | 22 |
| `patches/killer_unix.go.patch` | `patches` | 22 |
| `patches/ops_unix.go.patch` | `patches` | 30 |
| `patches/service_portable.go.patch` | `patches` | 22 |
| `patches/service_zos.go.patch` | `patches` | 59 |
| `patches/wrapper_unix.go.patch` | `patches` | 10 |
| `patches/zip_extra_unix.go.patch` | `patches` | 22 |

---

<a id="repo-zstdport"></a>
## zstdport

- **Origin Date (First Commit):** 2022-07-18
- **Current Patch LOC:** 236
- **Current Patch Count:** 4

### Historical Trends

![LOC Trend for zstdport](images/upstream/zstdport_current_loc_trend.png)
![Count Trend for zstdport](images/upstream/zstdport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.patch` | `patches` | 29 |
| `patches/PR1/addzostomakefile.patch` | `patches` | 44 |
| `patches/PR1/assertfirst.patch` | `patches` | 99 |
| `patches/tests_Makefile.patch` | `patches` | 64 |

---

<a id="repo-llamacppport"></a>
## llamacppport

- **Origin Date (First Commit):** 2023-08-21
- **Current Patch LOC:** 236
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for llamacppport](images/upstream/llamacppport_current_loc_trend.png)
![Count Trend for llamacppport](images/upstream/llamacppport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 236 |

---

<a id="repo-mesonport"></a>
## mesonport

- **Origin Date (First Commit):** 2023-10-20
- **Current Patch LOC:** 229
- **Current Patch Count:** 9

### Historical Trends

![LOC Trend for mesonport](images/upstream/mesonport_current_loc_trend.png)
![Count Trend for mesonport](images/upstream/mesonport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/mesonbuild/backend/backends.py.patch` | `patches` | 13 |
| `patches/mesonbuild/build.py.patch` | `patches` | 30 |
| `patches/mesonbuild/compilers/compilers.py.patch` | `patches` | 13 |
| `patches/mesonbuild/compilers/detect.py.patch` | `patches` | 33 |
| `patches/mesonbuild/envconfig.py.patch` | `patches` | 17 |
| `patches/mesonbuild/environment.py.patch` | `patches` | 58 |
| `patches/mesonbuild/linkers/linkers.py.patch` | `patches` | 29 |
| `patches/mesonbuild/utils/universal.py.patch` | `patches` | 23 |
| `patches/run_tests.py.patch` | `patches` | 13 |

---

<a id="repo-gettextport"></a>
## gettextport

- **Origin Date (First Commit):** 2022-05-20
- **Current Patch LOC:** 206
- **Current Patch Count:** 7

### Historical Trends

![LOC Trend for gettextport](images/upstream/gettextport_current_loc_trend.png)
![Count Trend for gettextport](images/upstream/gettextport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/fetch-name-collision.patch` | `patches` | 31 |
| `patches/PR1/locale-name-collision.patch` | `patches` | 13 |
| `patches/PR1/no-pwd_gecos.patch` | `patches` | 50 |
| `patches/PR1/tagtarball.patch` | `patches` | 13 |
| `patches/PR2/dummy.c.patch` | `patches` | 16 |
| `patches/PR3/test-unsetenv.c.patch` | `patches` | 23 |
| `patches/PR4/configure.patch` | `patches` | 60 |

---

<a id="repo-findutilsport"></a>
## findutilsport

- **Origin Date (First Commit):** 2022-10-25
- **Current Patch LOC:** 199
- **Current Patch Count:** 10

### Historical Trends

![LOC Trend for findutilsport](images/upstream/findutilsport_current_loc_trend.png)
![Count Trend for findutilsport](images/upstream/findutilsport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/filemode.c.patch` | `patches` | 33 |
| `patches/PR2/PR2.patch` | `patches` | 14 |
| `patches/PR3/config.guess.patch` | `patches` | 13 |
| `patches/PR3/configure.patch` | `patches` | 22 |
| `patches/PR3/install-sh.patch` | `patches` | 19 |
| `patches/PR3/test-driver.patch` | `patches` | 19 |
| `patches/PR4/gl_lib_canonicalize.c.patch` | `patches` | 25 |
| `patches/PR4/gnulib-tests_test-unsetenv.c.patch` | `patches` | 24 |
| `patches/PR5/fts.c.patch` | `patches` | 17 |
| `patches/sched_yield_disable.patch` | `patches` | 13 |

---

<a id="repo-ninjaport"></a>
## ninjaport

- **Origin Date (First Commit):** 2022-04-21
- **Current Patch LOC:** 196
- **Current Patch Count:** 8

### Historical Trends

![LOC Trend for ninjaport](images/upstream/ninjaport_current_loc_trend.png)
![Count Trend for ninjaport](images/upstream/ninjaport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/CMakeLists.txt.patch` | `patches` | 13 |
| `patches/PR1/configure.py.patch` | `patches` | 91 |
| `patches/PR1/src/disk_interface.cc.patch` | `patches` | 15 |
| `patches/PR1/src/getopt.c.patch` | `patches` | 13 |
| `patches/PR1/src/getopt.h.patch` | `patches` | 13 |
| `patches/PR1/src/manifest_parser_perftest.cc.patch` | `patches` | 13 |
| `patches/PR1/src/ninja.cc.patch` | `patches` | 13 |
| `patches/PR1/src/util.cc.patch` | `patches` | 25 |

---

<a id="repo-diffutilsport"></a>
## diffutilsport

- **Origin Date (First Commit):** 2022-09-09
- **Current Patch LOC:** 184
- **Current Patch Count:** 8

### Historical Trends

![LOC Trend for diffutilsport](images/upstream/diffutilsport_current_loc_trend.png)
![Count Trend for diffutilsport](images/upstream/diffutilsport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/config.guess.patch` | `patches` | 13 |
| `patches/PR2/c-file-type.c.patch` | `patches` | 22 |
| `patches/PR2/getprogname.c.patch` | `patches` | 13 |
| `patches/PR3/stdlib.in.h.patch` | `patches` | 25 |
| `patches/cmp.c.patch` | `patches` | 18 |
| `patches/depcomp.patch` | `patches` | 30 |
| `patches/help2man.patch` | `patches` | 10 |
| `patches/skip_test.patch` | `patches` | 53 |

---

<a id="repo-protobufport"></a>
## protobufport

- **Origin Date (First Commit):** 2023-08-02
- **Current Patch LOC:** 174
- **Current Patch Count:** 8

### Historical Trends

![LOC Trend for protobufport](images/upstream/protobufport_current_loc_trend.png)
![Count Trend for protobufport](images/upstream/protobufport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/attributes.h.patch` | `patches` | 24 |
| `patches/config.h.patch` | `patches` | 12 |
| `patches/low_level_alloc.cc.patch` | `patches` | 36 |
| `patches/low_level_alloc.h.patch` | `patches` | 13 |
| `patches/per_thread_sem.h.patch` | `patches` | 20 |
| `patches/port_def.inc.patch` | `patches` | 22 |
| `patches/sysinfo.cc.patch` | `patches` | 26 |
| `patches/time_zone_libc.cc.patch` | `patches` | 21 |

---

<a id="repo-groffport"></a>
## groffport

- **Origin Date (First Commit):** 2022-10-20
- **Current Patch LOC:** 165
- **Current Patch Count:** 13

### Historical Trends

![LOC Trend for groffport](images/upstream/groffport_current_loc_trend.png)
![Count Trend for groffport](images/upstream/groffport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `dev-patches/main.cpp.patch` | `dev-patches` | 17 |
| `dev-patches/pre-html.cpp.patch` | `dev-patches` | 24 |
| `dev-patches/test-driver.patch` | `dev-patches` | 0 |
| `stable-patches/assertfix/box.cpp.patch` | `stable-patches` | 12 |
| `stable-patches/assertfix/delim.cpp.patch` | `stable-patches` | 12 |
| `stable-patches/assertfix/dvi.cpp.patch` | `stable-patches` | 13 |
| `stable-patches/assertfix/lbp.cpp.patch` | `stable-patches` | 12 |
| `stable-patches/assertfix/lj4.cpp.patch` | `stable-patches` | 13 |
| `stable-patches/assertfix/pile.cpp.patch` | `stable-patches` | 12 |
| `stable-patches/assertfix/printer.cpp.patch` | `stable-patches` | 13 |
| `stable-patches/assertfix/script.cpp.patch` | `stable-patches` | 12 |
| `stable-patches/getopt.c.patch` | `stable-patches` | 16 |
| `stable-patches/makevarescape.sed.patch` | `stable-patches` | 9 |

---

<a id="repo-autoconfport"></a>
## autoconfport

- **Origin Date (First Commit):** 2021-08-13
- **Current Patch LOC:** 151
- **Current Patch Count:** 6

### Historical Trends

![LOC Trend for autoconfport](images/upstream/autoconfport_current_loc_trend.png)
![Count Trend for autoconfport](images/upstream/autoconfport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/config.guess.patch` | `patches` | 14 |
| `patches/PR1/configure.patch` | `patches` | 22 |
| `patches/PR1/general.m4.patch` | `patches` | 76 |
| `patches/PR1/local.at.patch` | `patches` | 13 |
| `patches/PR1/status.m4.patch` | `patches` | 13 |
| `patches/m4sh.m4.patch` | `patches` | 13 |

---

<a id="repo-moreutilsport"></a>
## moreutilsport

- **Origin Date (First Commit):** 2023-11-02
- **Current Patch LOC:** 151
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for moreutilsport](images/upstream/moreutilsport_current_loc_trend.png)
![Count Trend for moreutilsport](images/upstream/moreutilsport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 151 |

---

<a id="repo-jqport"></a>
## jqport

- **Origin Date (First Commit):** 2022-06-05
- **Current Patch LOC:** 146
- **Current Patch Count:** 8

### Historical Trends

![LOC Trend for jqport](images/upstream/jqport_current_loc_trend.png)
![Count Trend for jqport](images/upstream/jqport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/zOS.patch` | `patches` | 15 |
| `stable-patches/builtin.c.patch` | `stable-patches` | 32 |
| `stable-patches/configure.patch` | `stable-patches` | 15 |
| `stable-patches/jq_test.c.patch` | `stable-patches` | 16 |
| `stable-patches/jv_alloc.c.patch` | `stable-patches` | 18 |
| `stable-patches/mantest.patch` | `stable-patches` | 10 |
| `stable-patches/shtest.patch` | `stable-patches` | 21 |
| `stable-patches/version.patch` | `stable-patches` | 19 |

---

<a id="repo-libserdesport"></a>
## libserdesport

- **Origin Date (First Commit):** 2023-08-29
- **Current Patch LOC:** 142
- **Current Patch Count:** 4

### Historical Trends

![LOC Trend for libserdesport](images/upstream/libserdesport_current_loc_trend.png)
![Count Trend for libserdesport](images/upstream/libserdesport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.self.patch` | `patches` | 13 |
| `patches/src/serdes-common.h.patch` | `patches` | 15 |
| `patches/src/serdes_int.h.patch` | `patches` | 17 |
| `patches/src/tinycthread.c.patch` | `patches` | 97 |

---

<a id="repo-tclport"></a>
## tclport

- **Origin Date (First Commit):** 2022-07-09
- **Current Patch LOC:** 130
- **Current Patch Count:** 5

### Historical Trends

![LOC Trend for tclport](images/upstream/tclport_current_loc_trend.png)
![Count Trend for tclport](images/upstream/tclport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/namecollision.patch` | `patches` | 42 |
| `patches/PR1/neederrno.patch` | `patches` | 12 |
| `patches/PR1/remove_oe_sockets_hardcode.patch` | `patches` | 17 |
| `patches/PR2/tclUnixNotfy.c.patch` | `patches` | 15 |
| `patches/PR2/tclUnixThrd.c.patch` | `patches` | 44 |

---

<a id="repo-libgcryptport"></a>
## libgcryptport

- **Origin Date (First Commit):** 2023-04-21
- **Current Patch LOC:** 129
- **Current Patch Count:** 7

### Historical Trends

![LOC Trend for libgcryptport](images/upstream/libgcryptport_current_loc_trend.png)
![Count Trend for libgcryptport](images/upstream/libgcryptport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.in.patch` | `patches` | 13 |
| `patches/configure.patch` | `patches` | 33 |
| `patches/doc_Makefile.in.patch` | `patches` | 13 |
| `patches/g10lib.h.patch` | `patches` | 17 |
| `patches/longlong.h.patch` | `patches` | 22 |
| `patches/rndgetentropy.c.patch` | `patches` | 17 |
| `patches/secmem.c.patch` | `patches` | 14 |

---

<a id="repo-pinentryport"></a>
## pinentryport

- **Origin Date (First Commit):** 2023-05-18
- **Current Patch LOC:** 124
- **Current Patch Count:** 5

### Historical Trends

![LOC Trend for pinentryport](images/upstream/pinentryport_current_loc_trend.png)
![Count Trend for pinentryport](images/upstream/pinentryport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.ac.patch` | `patches` | 20 |
| `patches/configure.patch` | `patches` | 32 |
| `patches/pinentry-emacs.c.patch` | `patches` | 15 |
| `patches/pinentry.c.patch` | `patches` | 15 |
| `patches/secmem.c.patch` | `patches` | 42 |

---

<a id="repo-libssh2port"></a>
## libssh2port

- **Origin Date (First Commit):** 2023-05-10
- **Current Patch LOC:** 122
- **Current Patch Count:** 5

### Historical Trends

![LOC Trend for libssh2port](images/upstream/libssh2port_current_loc_trend.png)
![Count Trend for libssh2port](images/upstream/libssh2port_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 15 |
| `patches/libssh2_setup.h.patch` | `patches` | 23 |
| `patches/openssh_fixture.c.patch` | `patches` | 57 |
| `patches/scp_write_nonblock.c.patch` | `patches` | 12 |
| `patches/session_fixture.c.patch` | `patches` | 15 |

---

<a id="repo-m4port"></a>
## m4port

- **Origin Date (First Commit):** 2021-08-11
- **Current Patch LOC:** 120
- **Current Patch Count:** 5

### Historical Trends

![LOC Trend for m4port](images/upstream/m4port_current_loc_trend.png)
![Count Trend for m4port](images/upstream/m4port_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `dev-patches/PR4/doc/m4.texi.patch` | `dev-patches` | 17 |
| `dev-patches/PR4/src/format.c.patch` | `dev-patches` | 13 |
| `stable-patches/PR2/builtin.c.patch` | `stable-patches` | 55 |
| `stable-patches/PR2/canonicalize-lgpl.c.patch` | `stable-patches` | 22 |
| `stable-patches/PR2/configure.patch` | `stable-patches` | 13 |

---

<a id="repo-thesilversearcherport"></a>
## thesilversearcherport

- **Origin Date (First Commit):** 2023-07-18
- **Current Patch LOC:** 118
- **Current Patch Count:** 4

### Historical Trends

![LOC Trend for thesilversearcherport](images/upstream/thesilversearcherport_current_loc_trend.png)
![Count Trend for thesilversearcherport](images/upstream/thesilversearcherport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/genlib.sh.patch` | `patches` | 77 |
| `patches/main.c.patch` | `patches` | 14 |
| `patches/options.c.patch` | `patches` | 13 |
| `patches/print.c.patch` | `patches` | 14 |

---

<a id="repo-gas2asmport"></a>
## gas2asmport

- **Origin Date (First Commit):** 2025-04-11
- **Current Patch LOC:** 116
- **Current Patch Count:** 4

### Historical Trends

![LOC Trend for gas2asmport](images/upstream/gas2asmport_current_loc_trend.png)
![Count Trend for gas2asmport](images/upstream/gas2asmport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.mvs.patch` | `patches` | 77 |
| `patches/simple.assemble.patch` | `patches` | 0 |
| `patches/test/check.asmok.patch` | `patches` | 10 |
| `patches/test/deflate2.s.patch` | `patches` | 29 |

---

<a id="repo-grepport"></a>
## grepport

- **Origin Date (First Commit):** 2022-09-09
- **Current Patch LOC:** 115
- **Current Patch Count:** 3

### Historical Trends

![LOC Trend for grepport](images/upstream/grepport_current_loc_trend.png)
![Count Trend for grepport](images/upstream/grepport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/fts.c.patch` | `patches` | 17 |
| `patches/gnulib.patch` | `patches` | 14 |
| `patches/grep.c.patch` | `patches` | 84 |

---

<a id="repo-uucpport"></a>
## uucpport

- **Origin Date (First Commit):** 2025-04-11
- **Current Patch LOC:** 115
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for uucpport](images/upstream/uucpport_current_loc_trend.png)
![Count Trend for uucpport](images/upstream/uucpport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 115 |

---

<a id="repo-ncursesport"></a>
## ncursesport

- **Origin Date (First Commit):** 2022-10-27
- **Current Patch LOC:** 111
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for ncursesport](images/upstream/ncursesport_current_loc_trend.png)
![Count Trend for ncursesport](images/upstream/ncursesport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/TERMINFO.patch` | `patches` | 48 |
| `patches/clear.c.patch` | `patches` | 63 |

---

<a id="repo-hexcurseport"></a>
## hexcurseport

- **Origin Date (First Commit):** 2025-02-09
- **Current Patch LOC:** 108
- **Current Patch Count:** 4

### Historical Trends

![LOC Trend for hexcurseport](images/upstream/hexcurseport_current_loc_trend.png)
![Count Trend for hexcurseport](images/upstream/hexcurseport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/file.c.patch` | `patches` | 47 |
| `patches/hex.h.patch` | `patches` | 12 |
| `patches/hexcurse.c.patch` | `patches` | 22 |
| `patches/screen.c.patch` | `patches` | 27 |

---

<a id="repo-libbsdport"></a>
## libbsdport

- **Origin Date (First Commit):** 2023-07-31
- **Current Patch LOC:** 107
- **Current Patch Count:** 4

### Historical Trends

![LOC Trend for libbsdport](images/upstream/libbsdport_current_loc_trend.png)
![Count Trend for libbsdport](images/upstream/libbsdport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.ac.patch` | `patches` | 57 |
| `patches/src/fgetln.c.patch` | `patches` | 11 |
| `patches/src/flopen.c.patch` | `patches` | 15 |
| `patches/src/readpassphrase.c.patch` | `patches` | 24 |

---

<a id="repo-victoriametricsport"></a>
## victoriametricsport

- **Origin Date (First Commit):** 2024-03-04
- **Current Patch LOC:** 107
- **Current Patch Count:** 3

### Historical Trends

![LOC Trend for victoriametricsport](images/upstream/victoriametricsport_current_loc_trend.png)
![Count Trend for victoriametricsport](images/upstream/victoriametricsport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/lib_filestream.patch` | `patches` | 36 |
| `patches/lib_fs.patch` | `patches` | 34 |
| `patches/lib_memory.patch` | `patches` | 37 |

---

<a id="repo-zlib-ngport"></a>
## zlib-ngport

- **Origin Date (First Commit):** 2024-02-02
- **Current Patch LOC:** 100
- **Current Patch Count:** 3

### Historical Trends

![LOC Trend for zlib-ngport](images/upstream/zlib_ngport_current_loc_trend.png)
![Count Trend for zlib-ngport](images/upstream/zlib_ngport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.in.patch` | `patches` | 56 |
| `patches/zbuild.h.patch` | `patches` | 22 |
| `patches/zutil_p.h.patch` | `patches` | 22 |

---

<a id="repo-pkgconfigport"></a>
## pkgconfigport

- **Origin Date (First Commit):** 2022-06-24
- **Current Patch LOC:** 98
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for pkgconfigport](images/upstream/pkgconfigport_current_loc_trend.png)
![Count Trend for pkgconfigport](images/upstream/pkgconfigport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 98 |

---

<a id="repo-doxygenport"></a>
## doxygenport

- **Origin Date (First Commit):** 2024-02-14
- **Current Patch LOC:** 97
- **Current Patch Count:** 5

### Historical Trends

![LOC Trend for doxygenport](images/upstream/doxygenport_current_loc_trend.png)
![Count Trend for doxygenport](images/upstream/doxygenport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/filesystem.hpp.patch` | `patches` | 32 |
| `patches/latexgen.cpp.patch` | `patches` | 18 |
| `patches/runtests.py.patch` | `patches` | 16 |
| `patches/types.h.patch` | `patches` | 13 |
| `patches/util.cpp.patch` | `patches` | 18 |

---

<a id="repo-libiconvport"></a>
## libiconvport

- **Origin Date (First Commit):** 2023-01-14
- **Current Patch LOC:** 96
- **Current Patch Count:** 4

### Historical Trends

![LOC Trend for libiconvport](images/upstream/libiconvport_current_loc_trend.png)
![Count Trend for libiconvport](images/upstream/libiconvport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `dev-patches/iconv.c.patch` | `dev-patches` | 17 |
| `stable-patches/IBM-1047.TXT.patch` | `stable-patches` | 22 |
| `stable-patches/Makefile.in.patch` | `stable-patches` | 22 |
| `stable-patches/ebcdic1047.h.patch` | `stable-patches` | 35 |

---

<a id="repo-depot-toolsport"></a>
## depot_toolsport

- **Origin Date (First Commit):** 2023-10-10
- **Current Patch LOC:** 91
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for depot_toolsport](images/upstream/depot_toolsport_current_loc_trend.png)
![Count Trend for depot_toolsport](images/upstream/depot_toolsport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/zos.patch` | `patches` | 91 |

---

<a id="repo-libeventport"></a>
## libeventport

- **Origin Date (First Commit):** 2024-01-02
- **Current Patch LOC:** 87
- **Current Patch Count:** 3

### Historical Trends

![LOC Trend for libeventport](images/upstream/libeventport_current_loc_trend.png)
![Count Trend for libeventport](images/upstream/libeventport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 50 |
| `patches/evutil.c.patch` | `patches` | 15 |
| `patches/regress_http.c.patch` | `patches` | 22 |

---

<a id="repo-patchport"></a>
## patchport

- **Origin Date (First Commit):** 2022-10-18
- **Current Patch LOC:** 86
- **Current Patch Count:** 3

### Historical Trends

![LOC Trend for patchport](images/upstream/patchport_current_loc_trend.png)
![Count Trend for patchport](images/upstream/patchport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/pathmax.h.patch` | `patches` | 14 |
| `patches/PR1/string.in.h.patch` | `patches` | 60 |
| `patches/PR1/util.c.patch` | `patches` | 12 |

---

<a id="repo-gawkport"></a>
## gawkport

- **Origin Date (First Commit):** 2022-07-17
- **Current Patch LOC:** 81
- **Current Patch Count:** 4

### Historical Trends

![LOC Trend for gawkport](images/upstream/gawkport_current_loc_trend.png)
![Count Trend for gawkport](images/upstream/gawkport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/ascii-io.patch` | `patches` | 39 |
| `patches/PR1/noprotoscope.patch` | `patches` | 16 |
| `patches/PR1/zosdoesnotmeanebcdic.patch` | `patches` | 13 |
| `patches/PR2/install-sh.patch` | `patches` | 13 |

---

<a id="repo-expectport"></a>
## expectport

- **Origin Date (First Commit):** 2023-03-27
- **Current Patch LOC:** 79
- **Current Patch Count:** 4

### Historical Trends

![LOC Trend for expectport](images/upstream/expectport_current_loc_trend.png)
![Count Trend for expectport](images/upstream/expectport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.in.patch` | `patches` | 14 |
| `patches/configure.patch` | `patches` | 17 |
| `patches/exp_clib.c.patch` | `patches` | 12 |
| `patches/pty_termios.c.patch` | `patches` | 36 |

---

<a id="repo-librabbitmqport"></a>
## librabbitmqport

- **Origin Date (First Commit):** 2025-02-12
- **Current Patch LOC:** 78
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for librabbitmqport](images/upstream/librabbitmqport_current_loc_trend.png)
![Count Trend for librabbitmqport](images/upstream/librabbitmqport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/CMakeLists.txt.patch` | `patches` | 37 |
| `patches/librabbitmq_CMakeLists.txt.patch` | `patches` | 41 |

---

<a id="repo-libassuanport"></a>
## libassuanport

- **Origin Date (First Commit):** 2023-04-26
- **Current Patch LOC:** 77
- **Current Patch Count:** 4

### Historical Trends

![LOC Trend for libassuanport](images/upstream/libassuanport_current_loc_trend.png)
![Count Trend for libassuanport](images/upstream/libassuanport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.in.patch` | `patches` | 13 |
| `patches/assuan-defs.h.patch` | `patches` | 22 |
| `patches/assuan-socket.c.patch` | `patches` | 15 |
| `patches/configure.patch` | `patches` | 27 |

---

<a id="repo-xmltoport"></a>
## xmltoport

- **Origin Date (First Commit):** 2023-02-10
- **Current Patch LOC:** 74
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for xmltoport](images/upstream/xmltoport_current_loc_trend.png)
![Count Trend for xmltoport](images/upstream/xmltoport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 74 |

---

<a id="repo-cppcheckport"></a>
## cppcheckport

- **Origin Date (First Commit):** 2024-04-24
- **Current Patch LOC:** 72
- **Current Patch Count:** 4

### Historical Trends

![LOC Trend for cppcheckport](images/upstream/cppcheckport_current_loc_trend.png)
![Count Trend for cppcheckport](images/upstream/cppcheckport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/compilerDefinitions.cmake.patch` | `patches` | 9 |
| `patches/library.cpp.patch` | `patches` | 12 |
| `patches/path.cpp.patch` | `patches` | 33 |
| `patches/programmemory.cpp.patch` | `patches` | 18 |

---

<a id="repo-libtoolport"></a>
## libtoolport

- **Origin Date (First Commit):** 2022-05-12
- **Current Patch LOC:** 71
- **Current Patch Count:** 3

### Historical Trends

![LOC Trend for libtoolport](images/upstream/libtoolport_current_loc_trend.png)
![Count Trend for libtoolport](images/upstream/libtoolport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 22 |
| `patches/libtool.m4.patch` | `patches` | 15 |
| `patches/ltmain.sh.patch` | `patches` | 34 |

---

<a id="repo-nanoport"></a>
## nanoport

- **Origin Date (First Commit):** 2022-11-14
- **Current Patch LOC:** 68
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for nanoport](images/upstream/nanoport_current_loc_trend.png)
![Count Trend for nanoport](images/upstream/nanoport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/initial_zos.patch` | `patches` | 68 |

---

<a id="repo-getoptport"></a>
## getoptport

- **Origin Date (First Commit):** 2023-02-10
- **Current Patch LOC:** 66
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for getoptport](images/upstream/getoptport_current_loc_trend.png)
![Count Trend for getoptport](images/upstream/getoptport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.patch` | `patches` | 66 |

---

<a id="repo-logrotateport"></a>
## logrotateport

- **Origin Date (First Commit):** 2024-02-29
- **Current Patch LOC:** 65
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for logrotateport](images/upstream/logrotateport_current_loc_trend.png)
![Count Trend for logrotateport](images/upstream/logrotateport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 65 |

---

<a id="repo-lz4port"></a>
## lz4port

- **Origin Date (First Commit):** 2022-07-18
- **Current Patch LOC:** 58
- **Current Patch Count:** 4

### Historical Trends

![LOC Trend for lz4port](images/upstream/lz4port_current_loc_trend.png)
![Count Trend for lz4port](images/upstream/lz4port_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.patch` | `patches` | 19 |
| `patches/PR1/addzostomakefile.patch` | `patches` | 25 |
| `patches/PR2/Makefile.inc.patch` | `patches` | 0 |
| `patches/PR2/tests-Makefile.patch` | `patches` | 14 |

---

<a id="repo-libgpgerrorport"></a>
## libgpgerrorport

- **Origin Date (First Commit):** 2023-04-21
- **Current Patch LOC:** 53
- **Current Patch Count:** 3

### Historical Trends

![LOC Trend for libgpgerrorport](images/upstream/libgpgerrorport_current_loc_trend.png)
![Count Trend for libgpgerrorport](images/upstream/libgpgerrorport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.in.patch` | `patches` | 13 |
| `patches/configure.patch` | `patches` | 15 |
| `patches/spawn-posix.c.patch` | `patches` | 25 |

---

<a id="repo-expatport"></a>
## expatport

- **Origin Date (First Commit):** 2022-07-09
- **Current Patch LOC:** 52
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for expatport](images/upstream/expatport_current_loc_trend.png)
![Count Trend for expatport](images/upstream/expatport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 37 |
| `patches/configure.patch` | `patches` | 15 |

---

<a id="repo-terraformport"></a>
## terraformport

- **Origin Date (First Commit):** 2023-10-25
- **Current Patch LOC:** 51
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for terraformport](images/upstream/terraformport_current_loc_trend.png)
![Count Trend for terraformport](images/upstream/terraformport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/go.mod.patch` | `patches` | 24 |
| `patches/inode.go.patch` | `patches` | 27 |

---

<a id="repo-libsasl2port"></a>
## libsasl2port

- **Origin Date (First Commit):** 2024-06-14
- **Current Patch LOC:** 50
- **Current Patch Count:** 3

### Historical Trends

![LOC Trend for libsasl2port](images/upstream/libsasl2port_current_loc_trend.png)
![Count Trend for libsasl2port](images/upstream/libsasl2port_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.am.patch` | `patches` | 17 |
| `patches/configure.ac.patch` | `patches` | 12 |
| `patches/saslauthd/auth_getpwent.c.patch` | `patches` | 21 |

---

<a id="repo-automakeport"></a>
## automakeport

- **Origin Date (First Commit):** 2021-08-13
- **Current Patch LOC:** 47
- **Current Patch Count:** 3

### Historical Trends

![LOC Trend for automakeport](images/upstream/automakeport_current_loc_trend.png)
![Count Trend for automakeport](images/upstream/automakeport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/automake.in.patch` | `patches` | 13 |
| `patches/PR1/configure.patch` | `patches` | 22 |
| `patches/PR1/distdir.am.patch` | `patches` | 12 |

---

<a id="repo-lessport"></a>
## lessport

- **Origin Date (First Commit):** 2022-04-21
- **Current Patch LOC:** 47
- **Current Patch Count:** 3

### Historical Trends

![LOC Trend for lessport](images/upstream/lessport_current_loc_trend.png)
![Count Trend for lessport](images/upstream/lessport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `stable-patches/charset.c.patch` | `stable-patches` | 17 |
| `stable-patches/edit.c.patch` | `stable-patches` | 17 |
| `stable-patches/os.c.patch` | `stable-patches` | 13 |

---

<a id="repo-xxhashport"></a>
## xxhashport

- **Origin Date (First Commit):** 2022-07-18
- **Current Patch LOC:** 47
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for xxhashport](images/upstream/xxhashport_current_loc_trend.png)
![Count Trend for xxhashport](images/upstream/xxhashport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/linkoptforzos.patch` | `patches` | 34 |
| `patches/tests-Makefile.patch` | `patches` | 13 |

---

<a id="repo-tigport"></a>
## tigport

- **Origin Date (First Commit):** 2023-06-20
- **Current Patch LOC:** 47
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for tigport](images/upstream/tigport_current_loc_trend.png)
![Count Trend for tigport](images/upstream/tigport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 47 |

---

<a id="repo-lazygitport"></a>
## lazygitport

- **Origin Date (First Commit):** 2024-02-15
- **Current Patch LOC:** 46
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for lazygitport](images/upstream/lazygitport_current_loc_trend.png)
![Count Trend for lazygitport](images/upstream/lazygitport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/lazygit.patch` | `patches` | 46 |

---

<a id="repo-fzfport"></a>
## fzfport

- **Origin Date (First Commit):** 2023-03-22
- **Current Patch LOC:** 45
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for fzfport](images/upstream/fzfport_current_loc_trend.png)
![Count Trend for fzfport](images/upstream/fzfport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.patch` | `patches` | 20 |
| `patches/main.go.patch` | `patches` | 25 |

---

<a id="repo-poptport"></a>
## poptport

- **Origin Date (First Commit):** 2024-02-29
- **Current Patch LOC:** 35
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for poptport](images/upstream/poptport_current_loc_trend.png)
![Count Trend for poptport](images/upstream/poptport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 35 |

---

<a id="repo-whichport"></a>
## whichport

- **Origin Date (First Commit):** 2023-03-23
- **Current Patch LOC:** 34
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for whichport](images/upstream/whichport_current_loc_trend.png)
![Count Trend for whichport](images/upstream/whichport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/bash.c.patch` | `patches` | 34 |

---

<a id="repo-sedport"></a>
## sedport

- **Origin Date (First Commit):** 2022-08-31
- **Current Patch LOC:** 33
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for sedport](images/upstream/sedport_current_loc_trend.png)
![Count Trend for sedport](images/upstream/sedport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `stable-patches/execute.c.patch` | `stable-patches` | 33 |

---

<a id="repo-texinfoport"></a>
## texinfoport

- **Origin Date (First Commit):** 2022-09-19
- **Current Patch LOC:** 33
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for texinfoport](images/upstream/texinfoport_current_loc_trend.png)
![Count Trend for texinfoport](images/upstream/texinfoport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Init-test.inc.patch` | `patches` | 13 |
| `patches/Makefile.in.patch` | `patches` | 20 |

---

<a id="repo-ntbtlsport"></a>
## ntbtlsport

- **Origin Date (First Commit):** 2023-06-27
- **Current Patch LOC:** 33
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for ntbtlsport](images/upstream/ntbtlsport_current_loc_trend.png)
![Count Trend for ntbtlsport](images/upstream/ntbtlsport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 33 |

---

<a id="repo-sqliteport"></a>
## sqliteport

- **Origin Date (First Commit):** 2022-12-08
- **Current Patch LOC:** 32
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for sqliteport](images/upstream/sqliteport_current_loc_trend.png)
![Count Trend for sqliteport](images/upstream/sqliteport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 32 |

---

<a id="repo-luvport"></a>
## luvport

- **Origin Date (First Commit):** 2024-03-09
- **Current Patch LOC:** 31
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for luvport](images/upstream/luvport_current_loc_trend.png)
![Count Trend for luvport](images/upstream/luvport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/thread.c.patch` | `patches` | 31 |

---

<a id="repo-libffiport"></a>
## libffiport

- **Origin Date (First Commit):** 2024-06-20
- **Current Patch LOC:** 31
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for libffiport](images/upstream/libffiport_current_loc_trend.png)
![Count Trend for libffiport](images/upstream/libffiport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.host.patch` | `patches` | 16 |
| `patches/configure.patch` | `patches` | 15 |

---

<a id="repo-lynxport"></a>
## lynxport

- **Origin Date (First Commit):** 2023-03-03
- **Current Patch LOC:** 30
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for lynxport](images/upstream/lynxport_current_loc_trend.png)
![Count Trend for lynxport](images/upstream/lynxport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 30 |

---

<a id="repo-netpbmport"></a>
## netpbmport

- **Origin Date (First Commit):** 2023-11-21
- **Current Patch LOC:** 29
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for netpbmport](images/upstream/netpbmport_current_loc_trend.png)
![Count Trend for netpbmport](images/upstream/netpbmport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Execute-Tests.patch` | `patches` | 10 |
| `patches/GNUmakefile.patch` | `patches` | 19 |

---

<a id="repo-gmpport"></a>
## gmpport

- **Origin Date (First Commit):** 2023-11-29
- **Current Patch LOC:** 29
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for gmpport](images/upstream/gmpport_current_loc_trend.png)
![Count Trend for gmpport](images/upstream/gmpport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 15 |
| `patches/inp_str.c.patch` | `patches` | 14 |

---

<a id="repo-libgpgmeport"></a>
## libgpgmeport

- **Origin Date (First Commit):** 2024-03-04
- **Current Patch LOC:** 29
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for libgpgmeport](images/upstream/libgpgmeport_current_loc_trend.png)
![Count Trend for libgpgmeport](images/upstream/libgpgmeport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `stable-patches/ath.h.patch` | `stable-patches` | 14 |
| `stable-patches/libtool.m4.patch` | `stable-patches` | 15 |

---

<a id="repo-npthport"></a>
## npthport

- **Origin Date (First Commit):** 2023-04-20
- **Current Patch LOC:** 28
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for npthport](images/upstream/npthport_current_loc_trend.png)
![Count Trend for npthport](images/upstream/npthport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 15 |
| `patches/npth.c.patch` | `patches` | 13 |

---

<a id="repo-libksbaport"></a>
## libksbaport

- **Origin Date (First Commit):** 2023-04-26
- **Current Patch LOC:** 28
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for libksbaport](images/upstream/libksbaport_current_loc_trend.png)
![Count Trend for libksbaport](images/upstream/libksbaport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.in.patch` | `patches` | 13 |
| `patches/configure.patch` | `patches` | 15 |

---

<a id="repo-avro-c-libport"></a>
## avro-c-libport

- **Origin Date (First Commit):** 2023-08-09
- **Current Patch LOC:** 28
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for avro-c-libport](images/upstream/avro_c_libport_current_loc_trend.png)
![Count Trend for avro-c-libport](images/upstream/avro_c_libport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/avro_private.h.patch` | `patches` | 13 |
| `patches/refcount.h.patch` | `patches` | 15 |

---

<a id="repo-ctagsport"></a>
## ctagsport

- **Origin Date (First Commit):** 2022-11-25
- **Current Patch LOC:** 26
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for ctagsport](images/upstream/ctagsport_current_loc_trend.png)
![Count Trend for ctagsport](images/upstream/ctagsport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.am.patch` | `patches` | 13 |
| `patches/acutest.h.patch` | `patches` | 13 |

---

<a id="repo-git-extrasport"></a>
## git-extrasport

- **Origin Date (First Commit):** 2024-12-05
- **Current Patch LOC:** 26
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for git-extrasport](images/upstream/git_extrasport_current_loc_trend.png)
![Count Trend for git-extrasport](images/upstream/git_extrasport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1.patch` | `patches` | 26 |

---

<a id="repo-my-basicport"></a>
## my_basicport

- **Origin Date (First Commit):** 2023-12-02
- **Current Patch LOC:** 22
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for my_basicport](images/upstream/my_basicport_current_loc_trend.png)
![Count Trend for my_basicport](images/upstream/my_basicport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/my_basic.c.patch` | `patches` | 22 |

---

<a id="repo-shdocport"></a>
## shdocport

- **Origin Date (First Commit):** 2023-10-09
- **Current Patch LOC:** 20
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for shdocport](images/upstream/shdocport_current_loc_trend.png)
![Count Trend for shdocport](images/upstream/shdocport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.patch` | `patches` | 10 |
| `patches/shdoc.patch` | `patches` | 10 |

---

<a id="repo-sshpassport"></a>
## sshpassport

- **Origin Date (First Commit):** 2022-09-09
- **Current Patch LOC:** 18
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for sshpassport](images/upstream/sshpassport_current_loc_trend.png)
![Count Trend for sshpassport](images/upstream/sshpassport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/main.c.patch` | `patches` | 18 |

---

<a id="repo-git-lfsport"></a>
## git-lfsport

- **Origin Date (First Commit):** 2024-02-15
- **Current Patch LOC:** 18
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for git-lfsport](images/upstream/git_lfsport_current_loc_trend.png)
![Count Trend for git-lfsport](images/upstream/git_lfsport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.patch` | `patches` | 18 |

---

<a id="repo-bzip2port"></a>
## bzip2port

- **Origin Date (First Commit):** 2022-08-08
- **Current Patch LOC:** 17
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for bzip2port](images/upstream/bzip2port_current_loc_trend.png)
![Count Trend for bzip2port](images/upstream/bzip2port_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.patch` | `patches` | 17 |

---

<a id="repo-cunitport"></a>
## cunitport

- **Origin Date (First Commit):** 2023-11-30
- **Current Patch LOC:** 17
- **Current Patch Count:** 2

### Historical Trends

![LOC Trend for cunitport](images/upstream/cunitport_current_loc_trend.png)
![Count Trend for cunitport](images/upstream/cunitport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/bootstrap.patch` | `patches` | 17 |
| `patches/configure.patch` | `patches` | 0 |

---

<a id="repo-makeport"></a>
## makeport

- **Origin Date (First Commit):** 2021-12-12
- **Current Patch LOC:** 16
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for makeport](images/upstream/makeport_current_loc_trend.png)
![Count Trend for makeport](images/upstream/makeport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/getopt.c.patch` | `patches` | 16 |

---

<a id="repo-curlport"></a>
## curlport

- **Origin Date (First Commit):** 2022-04-08
- **Current Patch LOC:** 15
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for curlport](images/upstream/curlport_current_loc_trend.png)
![Count Trend for curlport](images/upstream/curlport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `stable-patches/configure.patch` | `stable-patches` | 15 |

---

<a id="repo-xzport"></a>
## xzport

- **Origin Date (First Commit):** 2022-04-21
- **Current Patch LOC:** 15
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for xzport](images/upstream/xzport_current_loc_trend.png)
![Count Trend for xzport](images/upstream/xzport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 15 |

---

<a id="repo-opensslport"></a>
## opensslport

- **Origin Date (First Commit):** 2022-05-24
- **Current Patch LOC:** 15
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for opensslport](images/upstream/opensslport_current_loc_trend.png)
![Count Trend for opensslport](images/upstream/opensslport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `stable-patches/50-os390.conf.patch` | `stable-patches` | 15 |

---

<a id="repo-libgdbmport"></a>
## libgdbmport

- **Origin Date (First Commit):** 2022-10-19
- **Current Patch LOC:** 15
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for libgdbmport](images/upstream/libgdbmport_current_loc_trend.png)
![Count Trend for libgdbmport](images/upstream/libgdbmport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 15 |

---

<a id="repo-libpipelineport"></a>
## libpipelineport

- **Origin Date (First Commit):** 2022-10-19
- **Current Patch LOC:** 15
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for libpipelineport](images/upstream/libpipelineport_current_loc_trend.png)
![Count Trend for libpipelineport](images/upstream/libpipelineport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 15 |

---

<a id="repo-libpcre2port"></a>
## libpcre2port

- **Origin Date (First Commit):** 2023-02-03
- **Current Patch LOC:** 15
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for libpcre2port](images/upstream/libpcre2port_current_loc_trend.png)
![Count Trend for libpcre2port](images/upstream/libpcre2port_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 15 |

---

<a id="repo-libxsltport"></a>
## libxsltport

- **Origin Date (First Commit):** 2023-02-12
- **Current Patch LOC:** 15
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for libxsltport](images/upstream/libxsltport_current_loc_trend.png)
![Count Trend for libxsltport](images/upstream/libxsltport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 15 |

---

<a id="repo-libpcreport"></a>
## libpcreport

- **Origin Date (First Commit):** 2023-02-03
- **Current Patch LOC:** 15
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for libpcreport](images/upstream/libpcreport_current_loc_trend.png)
![Count Trend for libpcreport](images/upstream/libpcreport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 15 |

---

<a id="repo-libmdport"></a>
## libmdport

- **Origin Date (First Commit):** 2023-07-25
- **Current Patch LOC:** 15
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for libmdport](images/upstream/libmdport_current_loc_trend.png)
![Count Trend for libmdport](images/upstream/libmdport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 15 |

---

<a id="repo-tarport"></a>
## tarport

- **Origin Date (First Commit):** 2022-07-08
- **Current Patch LOC:** 14
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for tarport](images/upstream/tarport_current_loc_trend.png)
![Count Trend for tarport](images/upstream/tarport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/gnu/fdopendir.c.patch` | `patches` | 14 |

---

<a id="repo-nghttp2port"></a>
## nghttp2port

- **Origin Date (First Commit):** 2023-11-30
- **Current Patch LOC:** 14
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for nghttp2port](images/upstream/nghttp2port_current_loc_trend.png)
![Count Trend for nghttp2port](images/upstream/nghttp2port_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/configure.patch` | `patches` | 14 |

---

<a id="repo-bisonport"></a>
## bisonport

- **Origin Date (First Commit):** 2022-05-11
- **Current Patch LOC:** 13
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for bisonport](images/upstream/bisonport_current_loc_trend.png)
![Count Trend for bisonport](images/upstream/bisonport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/ylwrap.patch` | `patches` | 13 |

---

<a id="repo-ncduport"></a>
## ncduport

- **Origin Date (First Commit):** 2022-11-05
- **Current Patch LOC:** 13
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for ncduport](images/upstream/ncduport_current_loc_trend.png)
![Count Trend for ncduport](images/upstream/ncduport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/util.c.patch` | `patches` | 13 |

---

<a id="repo-luaport"></a>
## luaport

- **Origin Date (First Commit):** 2022-12-21
- **Current Patch LOC:** 13
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for luaport](images/upstream/luaport_current_loc_trend.png)
![Count Trend for luaport](images/upstream/luaport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.patch` | `patches` | 13 |

---

<a id="repo-lpegport"></a>
## lpegport

- **Origin Date (First Commit):** 2024-03-09
- **Current Patch LOC:** 13
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for lpegport](images/upstream/lpegport_current_loc_trend.png)
![Count Trend for lpegport](images/upstream/lpegport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/makefile.patch` | `patches` | 13 |

---

<a id="repo-stowport"></a>
## stowport

- **Origin Date (First Commit):** 2024-05-31
- **Current Patch LOC:** 13
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for stowport](images/upstream/stowport_current_loc_trend.png)
![Count Trend for stowport](images/upstream/stowport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `stable-patches/stow.in.patch` | `stable-patches` | 13 |

---

<a id="repo-edport"></a>
## edport

- **Origin Date (First Commit):** 2025-04-15
- **Current Patch LOC:** 13
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for edport](images/upstream/edport_current_loc_trend.png)
![Count Trend for edport](images/upstream/edport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.in.patch` | `patches` | 13 |

---

<a id="repo-lzipport"></a>
## lzipport

- **Origin Date (First Commit):** 2025-04-09
- **Current Patch LOC:** 13
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for lzipport](images/upstream/lzipport_current_loc_trend.png)
![Count Trend for lzipport](images/upstream/lzipport_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/Makefile.in.patch` | `patches` | 13 |

---

<a id="repo-libxml2port"></a>
## libxml2port

- **Origin Date (First Commit):** 2023-01-23
- **Current Patch LOC:** 12
- **Current Patch Count:** 1

### Historical Trends

![LOC Trend for libxml2port](images/upstream/libxml2port_current_loc_trend.png)
![Count Trend for libxml2port](images/upstream/libxml2port_current_count_trend.png)

### Current Patch Details

| Patch File (Repo Relative Path) | Source | LOC |
|---|---|:---|
| `patches/PR1/configure.patch` | `patches` | 12 |

---

<a id="repo-zlibport"></a>
## zlibport

- **Origin Date (First Commit):** 2022-04-19
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

![LOC Trend for zlibport](images/upstream/zlibport_current_loc_trend.png)
![Count Trend for zlibport](images/upstream/zlibport_current_count_trend.png)

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-help2manport"></a>
## help2manport

- **Origin Date (First Commit):** 2022-05-16
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-zotsampleport"></a>
## zotsampleport

- **Origin Date (First Commit):** 2022-06-05
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-man-dbport"></a>
## man-dbport

- **Origin Date (First Commit):** 2022-06-23
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

![LOC Trend for man-dbport](images/upstream/man_dbport_current_loc_trend.png)
![Count Trend for man-dbport](images/upstream/man_dbport_current_count_trend.png)

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-shufport"></a>
## shufport

- **Origin Date (First Commit):** 2022-09-09
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-wgetport"></a>
## wgetport

- **Origin Date (First Commit):** 2022-09-19
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

![LOC Trend for wgetport](images/upstream/wgetport_current_loc_trend.png)
![Count Trend for wgetport](images/upstream/wgetport_current_count_trend.png)

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-gperfport"></a>
## gperfport

- **Origin Date (First Commit):** 2022-10-01
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-zoslibport"></a>
## zoslibport

- **Origin Date (First Commit):** 2022-10-06
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-re2cport"></a>
## re2cport

- **Origin Date (First Commit):** 2022-10-20
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-cscopeport"></a>
## cscopeport

- **Origin Date (First Commit):** 2022-11-27
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-gnulibport"></a>
## gnulibport

- **Origin Date (First Commit):** 2022-11-25
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-helloport"></a>
## helloport

- **Origin Date (First Commit):** 2022-11-27
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-htopport"></a>
## htopport

- **Origin Date (First Commit):** 2022-11-28
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

![LOC Trend for htopport](images/upstream/htopport_current_loc_trend.png)
![Count Trend for htopport](images/upstream/htopport_current_count_trend.png)

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-metaport"></a>
## metaport

- **Origin Date (First Commit):** 2023-01-16
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-zigiport"></a>
## zigiport

- **Origin Date (First Commit):** 2023-02-01
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-yqport"></a>
## yqport

- **Origin Date (First Commit):** 2023-04-20
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-direnvport"></a>
## direnvport

- **Origin Date (First Commit):** 2023-05-18
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-libgit2port"></a>
## libgit2port

- **Origin Date (First Commit):** 2023-10-25
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-duckdbport"></a>
## duckdbport

- **Origin Date (First Commit):** 2023-05-31
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

![LOC Trend for duckdbport](images/upstream/duckdbport_current_loc_trend.png)
![Count Trend for duckdbport](images/upstream/duckdbport_current_count_trend.png)

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-powerlinegoport"></a>
## powerlinegoport

- **Origin Date (First Commit):** 2023-05-20
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

![LOC Trend for powerlinegoport](images/upstream/powerlinegoport_current_loc_trend.png)
![Count Trend for powerlinegoport](images/upstream/powerlinegoport_current_count_trend.png)

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-byaccport"></a>
## byaccport

- **Origin Date (First Commit):** 2023-06-02
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-bumpport"></a>
## bumpport

- **Origin Date (First Commit):** 2023-06-11
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-c3270port"></a>
## c3270port

- **Origin Date (First Commit):** 2023-06-20
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

![LOC Trend for c3270port](images/upstream/c3270port_current_loc_trend.png)
![Count Trend for c3270port](images/upstream/c3270port_current_count_trend.png)

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-gumport"></a>
## gumport

- **Origin Date (First Commit):** 2023-07-07
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-wharfport"></a>
## wharfport

- **Origin Date (First Commit):** 2023-07-07
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-dufport"></a>
## dufport

- **Origin Date (First Commit):** 2023-07-14
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-onigurumaport"></a>
## onigurumaport

- **Origin Date (First Commit):** 2023-07-20
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-multitailport"></a>
## multitailport

- **Origin Date (First Commit):** 2023-07-21
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-janssonport"></a>
## janssonport

- **Origin Date (First Commit):** 2023-08-02
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-luarocksport"></a>
## luarocksport

- **Origin Date (First Commit):** 2023-08-02
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-termenvport"></a>
## termenvport

- **Origin Date (First Commit):** 2023-08-08
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-esbuildport"></a>
## esbuildport

- **Origin Date (First Commit):** 2023-10-25
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-nginxport"></a>
## nginxport

- **Origin Date (First Commit):** 2023-10-25
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-natsport"></a>
## natsport

- **Origin Date (First Commit):** 2023-10-25
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-githubcliport"></a>
## githubcliport

- **Origin Date (First Commit):** 2023-10-19
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-zos-code-page-toolsport"></a>
## zos-code-page-toolsport

- **Origin Date (First Commit):** 2023-11-06
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-gnport"></a>
## gnport

- **Origin Date (First Commit):** 2023-11-07
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

![LOC Trend for gnport](images/upstream/gnport_current_loc_trend.png)
![Count Trend for gnport](images/upstream/gnport_current_count_trend.png)

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-v8port"></a>
## v8port

- **Origin Date (First Commit):** 2023-11-22
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-dos2unixport"></a>
## dos2unixport

- **Origin Date (First Commit):** 2023-11-14
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

![LOC Trend for dos2unixport](images/upstream/dos2unixport_current_loc_trend.png)
![Count Trend for dos2unixport](images/upstream/dos2unixport_current_count_trend.png)

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-zospstreeport"></a>
## zospstreeport

- **Origin Date (First Commit):** 2023-11-14
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-zosncport"></a>
## zosncport

- **Origin Date (First Commit):** 2023-11-14
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-boostport"></a>
## boostport

- **Origin Date (First Commit):** 2024-03-14
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

![LOC Trend for boostport](images/upstream/boostport_current_loc_trend.png)
![Count Trend for boostport](images/upstream/boostport_current_count_trend.png)

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-buildkiteport"></a>
## buildkiteport

- **Origin Date (First Commit):** 2023-11-26
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-antport"></a>
## antport

- **Origin Date (First Commit):** 2023-11-29
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-jrubyport"></a>
## jrubyport

- **Origin Date (First Commit):** 2023-12-02
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-toolsandtoysport"></a>
## toolsandtoysport

- **Origin Date (First Commit):** 2023-12-06
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-groovyport"></a>
## groovyport

- **Origin Date (First Commit):** 2023-12-11
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-kotlinport"></a>
## kotlinport

- **Origin Date (First Commit):** 2023-12-16
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-caddyport"></a>
## caddyport

- **Origin Date (First Commit):** 2024-04-01
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-gitlabcliport"></a>
## gitlabcliport

- **Origin Date (First Commit):** 2024-01-10
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-fqport"></a>
## fqport

- **Origin Date (First Commit):** 2024-01-21
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-promptersport"></a>
## promptersport

- **Origin Date (First Commit):** 2024-02-05
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-osv-scannerport"></a>
## osv-scannerport

- **Origin Date (First Commit):** 2024-02-14
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-ginport"></a>
## ginport

- **Origin Date (First Commit):** 2024-02-22
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-frpport"></a>
## frpport

- **Origin Date (First Commit):** 2024-02-23
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-mavenport"></a>
## mavenport

- **Origin Date (First Commit):** 2024-02-26
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-ttypeport"></a>
## ttypeport

- **Origin Date (First Commit):** 2024-03-07
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-cosignport"></a>
## cosignport

- **Origin Date (First Commit):** 2024-03-13
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-jenkinsport"></a>
## jenkinsport

- **Origin Date (First Commit):** 2024-03-25
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-godsectport"></a>
## godsectport

- **Origin Date (First Commit):** 2024-04-08
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-murexport"></a>
## murexport

- **Origin Date (First Commit):** 2024-04-12
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-grafanaport"></a>
## grafanaport

- **Origin Date (First Commit):** 2024-05-09
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-iperfport"></a>
## iperfport

- **Origin Date (First Commit):** Unknown
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-fxport"></a>
## fxport

- **Origin Date (First Commit):** 2024-05-21
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-s5cmdport"></a>
## s5cmdport

- **Origin Date (First Commit):** 2024-05-27
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-parse-gotestport"></a>
## parse-gotestport

- **Origin Date (First Commit):** 2024-06-07
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-check-clangport"></a>
## check_clangport

- **Origin Date (First Commit):** 2023-04-28
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-check-xlclangport"></a>
## check_xlclangport

- **Origin Date (First Commit):** 2023-04-28
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-check-pythonport"></a>
## check_pythonport

- **Origin Date (First Commit):** 2023-04-27
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-check-javaport"></a>
## check_javaport

- **Origin Date (First Commit):** 2023-11-29
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-check-goport"></a>
## check_goport

- **Origin Date (First Commit):** 2023-04-28
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-nmapport"></a>
## nmapport

- **Origin Date (First Commit):** Unknown
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-hugoport"></a>
## hugoport

- **Origin Date (First Commit):** 2024-07-17
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-dialogport"></a>
## dialogport

- **Origin Date (First Commit):** 2024-08-08
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-joeport"></a>
## joeport

- **Origin Date (First Commit):** Unknown
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-cjsonport"></a>
## cjsonport

- **Origin Date (First Commit):** 2024-08-16
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-libdioport"></a>
## libdioport

- **Origin Date (First Commit):** 2024-08-16
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-git-chglogport"></a>
## git-chglogport

- **Origin Date (First Commit):** Unknown
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-zedc-asciiport"></a>
## zedc_asciiport

- **Origin Date (First Commit):** 2024-12-05
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-bash-completionport"></a>
## bash-completionport

- **Origin Date (First Commit):** 2024-12-10
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-zusageport"></a>
## zusageport

- **Origin Date (First Commit):** 2024-12-05
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-spdlogport"></a>
## spdlogport

- **Origin Date (First Commit):** 2025-01-30
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-creduceport"></a>
## creduceport

- **Origin Date (First Commit):** 2025-01-31
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-gradleport"></a>
## gradleport

- **Origin Date (First Commit):** Unknown
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-luajitport"></a>
## luajitport

- **Origin Date (First Commit):** 2025-04-08
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-cpioport"></a>
## cpioport

- **Origin Date (First Commit):** 2025-04-09
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-bcport"></a>
## bcport

- **Origin Date (First Commit):** 2025-04-09
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-git-sizerport"></a>
## git-sizerport

- **Origin Date (First Commit):** 2025-04-09
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-chezmoiport"></a>
## chezmoiport

- **Origin Date (First Commit):** Unknown
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-jdport"></a>
## jdport

- **Origin Date (First Commit):** 2025-04-24
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-libarchiveport"></a>
## libarchiveport

- **Origin Date (First Commit):** 2025-04-29
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

<a id="repo-aprport"></a>
## aprport

- **Origin Date (First Commit):** 2025-04-29
- **Current Patch LOC:** 0
- **Current Patch Count:** 0

### Historical Trends

*(Patch LOC trend graph not generated)*
*(Patch count trend graph not generated)*

### Current Patch Details

*No current patches found in tracked directories (stable-patches, dev-patches, patches).*

---

