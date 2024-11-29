# zopen community ports

Note: to download the latest packages, use the [zopen package manager](/Guides/QuickStart)

<div>
  <label for="category-filter">Filter by Category: </label>
  <select id="category-filter" onchange="filterTable()">
    <option value="All">All</option>
    <option value="build_system">build_system</option>
    <option value="compression">compression</option>
    <option value="core">core</option>
    <option value="database">database</option>
    <option value="development">development</option>
    <option value="devops">devops</option>
    <option value="documentation">documentation</option>
    <option value="editor">editor</option>
    <option value="graphics">graphics</option>
    <option value="language">language</option>
    <option value="library">library</option>
    <option value="networking">networking</option>
    <option value="security">security</option>
    <option value="shell">shell</option>
    <option value="source_control">source_control</option>
    <option value="uncategorized">uncategorized</option>
    <option value="utilities">utilities</option>
    <option value="webframework">webframework</option>
  </select>
</div>

<div class="table-category" data-category="build_system">

## Build_System <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [make](https://github.com/zopencommunity/makeport)|Blue|99.9%|[STABLE_make_2702](https://github.com/zopencommunity/makeport/releases/download/STABLE_makeport_2702/make-4.4.1.20241029_012339.zos.pax.Z)|A build automation tool|
| [meson](https://github.com/zopencommunity/mesonport)|Red|33.3%|[STABLE_meson_2720](https://github.com/zopencommunity/mesonport/releases/download/STABLE_mesonport_2720/meson-heads.1.6.0.20241101_195530.zos.pax.Z)|A build system|
</div>

<div class="table-category" data-category="compression">

## Compression <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [bzip2](https://github.com/zopencommunity/bzip2port)|Green|100.0%|[STABLE_bzip2_2640](https://github.com/zopencommunity/bzip2port/releases/download/STABLE_bzip2port_2640/bzip2-1.0.8.20241028_123455.zos.pax.Z)|A compression utility|
| [zip](https://github.com/zopencommunity/zipport)|Green|100.0%|[STABLE_zip_2682](https://github.com/zopencommunity/zipport/releases/download/STABLE_zipport_2682/zip-master.20241028_232906.zos.pax.Z)|Tool for zipping files|
| [unzip](https://github.com/zopencommunity/unzipport)|Green|100.0%|[STABLE_unzip_2692](https://github.com/zopencommunity/unzipport/releases/download/STABLE_unzipport_2692/unzip-master.20241029_001426.zos.pax.Z)|Tool for unzipping compressed files|
</div>

<div class="table-category" data-category="core">

## Core <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [screen](https://github.com/zopencommunity/screenport)|Skipped|N/A|[STABLE_screen_2678](https://github.com/zopencommunity/screenport/releases/download/STABLE_screenport_2678/screen-4.9.1.20241028_224806.zos.pax.Z)|A full-screen terminal multiplexer|
| [gin](https://github.com/zopencommunity/ginport)|Skipped|N/A|[STABLE_gin_2594](https://github.com/zopencommunity/ginport/releases/download/STABLE_ginport_2594/gin-heads.v1.9.1.20241002_044048.zos.pax.Z)|A web framework for Go|
| [maven](https://github.com/zopencommunity/mavenport)|Skipped|N/A|[STABLE_maven_2176](https://github.com/zopencommunity/mavenport/releases/download/STABLE_mavenport_2176/apache-maven-3.9.6-bin.20240304_083533.zos.pax.Z)|A build automation tool|
| [util-linux](https://github.com/zopencommunity/util-linuxport)|Green|100.0%|[STABLE_util-linux_1955](https://github.com/zopencommunity/util-linuxport/releases/download/STABLE_util-linuxport_1955/util-linux-heads.v2.39.3.20240109_230256.zos.pax.Z)|A collection of system utilities|
| [gmp](https://github.com/zopencommunity/gmpport)|Green|100.0%|[STABLE_gmp_2574](https://github.com/zopencommunity/gmpport/releases/download/STABLE_gmpport_2574/gmp-6.3.0.20241002_032507.zos.pax.Z)|A library for arbitrary precision arithmetic|
| [frp](https://github.com/zopencommunity/frpport)|Green|100.0%|[STABLE_frp_2164](https://github.com/zopencommunity/frpport/releases/download/STABLE_frpport_2164/frp-heads.v0.54.0.20240225_234231.zos.pax.Z)|A reverse proxy|
| [libdio](https://github.com/zopencommunity/libdioport)|Green|100.0%|[DEV_libdio_2726](https://github.com/zopencommunity/libdioport/releases/download/DEV_libdioport_2726/libdio-main.20241105_062712.zos.pax.Z)|A dataset I/O library|
| [sudo](https://github.com/zopencommunity/sudoport)|Blue|87.8%|[STABLE_sudo_2687](https://github.com/zopencommunity/sudoport/releases/download/STABLE_sudoport_2687/sudo-1.9.15p5.20241028_222413.zos.pax.Z)|A program for running commands with superuser privileges|
| [sed](https://github.com/zopencommunity/sedport)|Blue|84.7%|[STABLE_sed_2696](https://github.com/zopencommunity/sedport/releases/download/STABLE_sedport_2696/sed-4.9.20241028_234039.zos.pax.Z)|A stream editor for manipulating text files|
| [netpbm](https://github.com/zopencommunity/netpbmport)|Red|28.2%|[STABLE_netpbm_2055](https://github.com/zopencommunity/netpbmport/releases/download/STABLE_netpbmport_2055/netpbm-trunk.20240129_101332.zos.pax.Z)|A toolkit for manipulating images|
</div>

<div class="table-category" data-category="database">

## Database <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [grafana](https://github.com/zopencommunity/grafanaport)|Skipped|N/A|[STABLE_grafana_2268](https://github.com/zopencommunity/grafanaport/releases/download/STABLE_grafanaport_2268/grafana-heads.v11.1.3.20240731_150543.zos.pax.Z)|An open-source observability and data visualization platform|
| [s5cmd](https://github.com/zopencommunity/s5cmdport)|Skipped|N/A|[STABLE_s5cmd_2587](https://github.com/zopencommunity/s5cmdport/releases/download/STABLE_s5cmdport_2587/s5cmd-heads.v2.2.2.20241002_042219.zos.pax.Z)|A parallel S3 and local filesystem execution tool|
| [sqlite](https://github.com/zopencommunity/sqliteport)|Green|100.0%|[STABLE_sqlite_2676](https://github.com/zopencommunity/sqliteport/releases/download/STABLE_sqliteport_2676/sqlite-autoconf-3450100.20241028_222913.zos.pax.Z)|A lightweight embedded SQL database engine|
| [prometheus](https://github.com/zopencommunity/prometheusport)|Green|100.0%|[STABLE_prometheus_2271](https://github.com/zopencommunity/prometheusport/releases/download/STABLE_prometheusport_2271/prometheus-heads.v2.45.5.20240710_113009.zos.pax.Z)|A monitoring system|
</div>

<div class="table-category" data-category="development">

## Development <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [vim](https://github.com/zopencommunity/vimport)|Skipped|N/A|[STABLE_vim_2736](https://github.com/zopencommunity/vimport/releases/download/STABLE_vimport_2736/vim-heads.v9.1.0869.20241118_041149.zos.pax.Z)|Utility for managing virtual file systems|
| [expect](https://github.com/zopencommunity/expectport)|Skipped|N/A|[STABLE_expect_2673](https://github.com/zopencommunity/expectport/releases/download/STABLE_expectport_2673/expect-5.45.4.20241028_223259.zos.pax.Z)|A tool for automating interactions with text-based programs|
| [buildkite](https://github.com/zopencommunity/buildkiteport)|Skipped|N/A|[STABLE_buildkite_2546](https://github.com/zopencommunity/buildkiteport/releases/download/STABLE_buildkiteport_2546/buildkite-DEV.20241002_013949.zos.pax.Z)|Buildkite is a platform for running fast, secure, and scalable continuous integration pipelines on your own infrastructure|
| [gitlab-runner](https://github.com/zopencommunity/gitlab-runnerport)|Skipped|N/A|[STABLE_gitlab-runner_2597](https://github.com/zopencommunity/gitlab-runnerport/releases/download/STABLE_gitlab-runnerport_2597/gitlab-runner.20241002_044313.zos.pax.Z)|A GitLab Runner|
| [ant](https://github.com/zopencommunity/antport)|Skipped|N/A|[STABLE_ant_2592](https://github.com/zopencommunity/antport/releases/download/STABLE_antport_2592/ant-DEV.20241002_043504.zos.pax.Z)|A build automation tool|
| [fq](https://github.com/zopencommunity/fqport)|Skipped|N/A|[STABLE_fq_2588](https://github.com/zopencommunity/fqport/releases/download/STABLE_fqport_2588/fq-master.20241002_042059.zos.pax.Z)|A tool for working with binary formats|
| [murex](https://github.com/zopencommunity/murexport)|Skipped|N/A|[STABLE_murex_2265](https://github.com/zopencommunity/murexport/releases/download/STABLE_murexport_2265/murex-DEV.20240515_162657.zos.pax.Z)|A text editor|
| [cjson](https://github.com/zopencommunity/cjsonport)|Skipped|N/A|[STABLE_cjson_2572](https://github.com/zopencommunity/cjsonport/releases/download/STABLE_cjsonport_2572/cjson-heads.v1.7.18.20241002_030456.zos.pax.Z)|A C JSON library|
| [pkgconfig](https://github.com/zopencommunity/pkgconfigport)|Green|100.0%|[STABLE_pkgconfig_2704](https://github.com/zopencommunity/pkgconfigport/releases/download/STABLE_pkgconfigport_2704/pkgconfig-DEV.20241029_013507.zos.pax.Z)|A system for managing library dependencies|
| [gperf](https://github.com/zopencommunity/gperfport)|Green|100.0%|[STABLE_gperf_2693](https://github.com/zopencommunity/gperfport/releases/download/STABLE_gperfport_2693/gperf-3.1.20241029_001259.zos.pax.Z)|A perfect hash function generator|
| [flex](https://github.com/zopencommunity/flexport)|Green|100.0%|[STABLE_flex_2685](https://github.com/zopencommunity/flexport/releases/download/STABLE_flexport_2685/flex-2.6.4.20241028_233607.zos.pax.Z)|A text-based file editor|
| [comp_go](https://github.com/zopencommunity/comp_goport)|Green|100.0%|[STABLE_comp_go_2668](https://github.com/zopencommunity/comp_goport/releases/download/STABLE_comp_goport_2668/comp_go-DEV.20241028_222012.zos.pax.Z)|A code completion tool for Go|
| [comp_clang](https://github.com/zopencommunity/comp_clangport)|Green|100.0%|[STABLE_comp_clang_2659](https://github.com/zopencommunity/comp_clangport/releases/download/STABLE_comp_clangport_2659/comp_clang-DEV.20241028_215503.zos.pax.Z)|A code completion tool for Clang compiler|
| [comp_xlclang](https://github.com/zopencommunity/comp_xlclangport)|Green|100.0%|[STABLE_comp_xlclang_2660](https://github.com/zopencommunity/comp_xlclangport/releases/download/STABLE_comp_xlclangport_2660/comp_xlclang-DEV.20241028_215548.zos.pax.Z)|A code completion tool for XL C/C++ compiler|
| [gn](https://github.com/zopencommunity/gnport)|Green|100.0%|[DEV_gn_2555](https://github.com/zopencommunity/gnport/releases/download/DEV_gnport_2555/gn-main.20241002_020256.zos.pax.Z)|A build tool|
| [libevent](https://github.com/zopencommunity/libeventport)|Green|100.0%|[STABLE_libevent_2183](https://github.com/zopencommunity/libeventport/releases/download/STABLE_libeventport_2183/libevent-2.1.12-stable.20240307_140629.zos.pax.Z)|An event notification library|
| [tmux](https://github.com/zopencommunity/tmuxport)|Green|100.0%|[STABLE_tmux_2410](https://github.com/zopencommunity/tmuxport/releases/download/STABLE_tmuxport_2410/tmux-heads.3.3a.20240825_024243.zos.pax.Z)|A terminal multiplexer|
| [zlib-ng](https://github.com/zopencommunity/zlib-ngport)|Green|100.0%|[DEV_zlib-ng_2087](https://github.com/zopencommunity/zlib-ngport/releases/download/DEV_zlib-ngport_2087/zlib-ng-develop.20240205_031127.zos.pax.Z)|A compression library|
| [popt](https://github.com/zopencommunity/poptport)|Green|100.0%|[STABLE_popt_2584](https://github.com/zopencommunity/poptport/releases/download/STABLE_poptport_2584/popt-master.20241002_041357.zos.pax.Z)|A command-line argument parser|
| [libgpgme](https://github.com/zopencommunity/libgpgmeport)|Green|100.0%|[STABLE_libgpgme_2181](https://github.com/zopencommunity/libgpgmeport/releases/download/STABLE_libgpgmeport_2181/gpgme-1.23.2.20240307_085012.zos.pax.Z)|A library for accessing cryptographic functions|
| [lpeg](https://github.com/zopencommunity/lpegport)|Green|100.0%|[STABLE_lpeg_2595](https://github.com/zopencommunity/lpegport/releases/download/STABLE_lpegport_2595/lpeg-1.1.0.20241002_045211.zos.pax.Z)|A pattern-matching library for Lua|
| [luv](https://github.com/zopencommunity/luvport)|Green|100.0%|[STABLE_luv_2596](https://github.com/zopencommunity/luvport/releases/download/STABLE_luvport_2596/luv-master.20241002_045447.zos.pax.Z)|Lua bindings for libuv|
| [cronie](https://github.com/zopencommunity/cronieport)|Green|100.0%|[DEV_cronie_2445](https://github.com/zopencommunity/cronieport/releases/download/DEV_cronieport_2445/cronie-master.20240922_053018.zos.pax.Z)|A cron daemon|
| [libdio](https://github.com/zopencommunity/libdioport)|Green|100.0%|[DEV_libdio_2726](https://github.com/zopencommunity/libdioport/releases/download/DEV_libdioport_2726/libdio-main.20241105_062712.zos.pax.Z)|A dataset I/O library|
| [make](https://github.com/zopencommunity/makeport)|Blue|99.9%|[STABLE_make_2702](https://github.com/zopencommunity/makeport/releases/download/STABLE_makeport_2702/make-4.4.1.20241029_012339.zos.pax.Z)|A build automation tool|
| [dos2unix](https://github.com/zopencommunity/dos2unixport)|Blue|99.1%|[STABLE_dos2unix_2543](https://github.com/zopencommunity/dos2unixport/releases/download/STABLE_dos2unixport_2543/dos2unix-7.5.2.20241002_013955.zos.pax.Z)|A tool for converting DOS/Windows text files to Unix format|
| [git](https://github.com/zopencommunity/gitport)|Blue|96.7%|[STABLE_git_2730](https://github.com/zopencommunity/gitport/releases/download/STABLE_gitport_2730/git-heads.v2.47.0.20241114_225356.zos.pax.Z)|The Git version control system|
| [re2c](https://github.com/zopencommunity/re2cport)|Blue|80.0%|[STABLE_re2c_2686](https://github.com/zopencommunity/re2cport/releases/download/STABLE_re2cport_2686/re2c-3.1.20241028_225705.zos.pax.Z)|A lexer generator for creating lexers|
| [conan](https://github.com/zopencommunity/conanport)|Yellow|54.0%|[STABLE_conan_2723](https://github.com/zopencommunity/conanport/releases/download/STABLE_conanport_2723/conan-heads.2.9.1.20241104_151950.zos.pax.Z)|C/C++ Package Manager tool|
| [byacc](https://github.com/zopencommunity/byaccport)|Red|45.6%|[STABLE_byacc_2661](https://github.com/zopencommunity/byaccport/releases/download/STABLE_byaccport_2661/byacc-20240109.20241028_215525.zos.pax.Z)|A parser generator compatible with Yacc|
| [meson](https://github.com/zopencommunity/mesonport)|Red|33.3%|[STABLE_meson_2720](https://github.com/zopencommunity/mesonport/releases/download/STABLE_mesonport_2720/meson-heads.1.6.0.20241101_195530.zos.pax.Z)|A build system|
</div>

<div class="table-category" data-category="devops">

## Devops <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [terraform](https://github.com/zopencommunity/terraformport)|Skipped|N/A|[STABLE_terraform_2165](https://github.com/zopencommunity/terraformport/releases/download/STABLE_terraformport_2165/terraform-heads.v1.7.4.20240226_124341.zos.pax.Z)|An infrastructure as code tool|
| [lazygit](https://github.com/zopencommunity/lazygitport)|Skipped|N/A|[STABLE_lazygit_2148](https://github.com/zopencommunity/lazygitport/releases/download/STABLE_lazygitport_2148/lazygit-master.20240221_041017.zos.pax.Z)|A Git client|
| [godsect](https://github.com/zopencommunity/godsectport)|Skipped|N/A|[STABLE_godsect_2444](https://github.com/zopencommunity/godsectport/releases/download/STABLE_godsectport_2444/godsect-main.20240922_052634.zos.pax.Z)|A code security scanner|
| [grafana](https://github.com/zopencommunity/grafanaport)|Skipped|N/A|[STABLE_grafana_2268](https://github.com/zopencommunity/grafanaport/releases/download/STABLE_grafanaport_2268/grafana-heads.v11.1.3.20240731_150543.zos.pax.Z)|An open-source observability and data visualization platform|
| [prometheus](https://github.com/zopencommunity/prometheusport)|Green|100.0%|[STABLE_prometheus_2271](https://github.com/zopencommunity/prometheusport/releases/download/STABLE_prometheusport_2271/prometheus-heads.v2.45.5.20240710_113009.zos.pax.Z)|A monitoring system|
| [logrotate](https://github.com/zopencommunity/logrotateport)|Green|100.0%|[STABLE_logrotate_2174](https://github.com/zopencommunity/logrotateport/releases/download/STABLE_logrotateport_2174/logrotate-main.20240229_195903.zos.pax.Z)|A log rotation tool|
| [parse-gotest](https://github.com/zopencommunity/parse-gotestport)|Green|100.0%|[STABLE_parse-gotest_2364](https://github.com/zopencommunity/parse-gotestport/releases/download/STABLE_parse-gotestport_2364/parse-gotest-heads.v0.1.1.20240721_042053.zos.pax.Z)|A Go test parser|
| [git-lfs](https://github.com/zopencommunity/git-lfsport)|Blue|95.2%|[STABLE_git-lfs_2150](https://github.com/zopencommunity/git-lfsport/releases/download/STABLE_git-lfsport_2150/git-lfs.20240221_133034.zos.pax.Z)|A Git extension for versioning large files|
| [conan](https://github.com/zopencommunity/conanport)|Yellow|54.0%|[STABLE_conan_2723](https://github.com/zopencommunity/conanport/releases/download/STABLE_conanport_2723/conan-heads.2.9.1.20241104_151950.zos.pax.Z)|C/C++ Package Manager tool|
</div>

<div class="table-category" data-category="documentation">

## Documentation <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [xmlto](https://github.com/zopencommunity/xmltoport)|Green|100.0%|[STABLE_xmlto_2666](https://github.com/zopencommunity/xmltoport/releases/download/STABLE_xmltoport_2666/xmlto-0.0.28.20241028_221534.zos.pax.Z)|A tool for converting XML documents to other formats|
| [shdoc](https://github.com/zopencommunity/shdocport)|Green|100.0%|[DEV_shdoc_2657](https://github.com/zopencommunity/shdocport/releases/download/DEV_shdocport_2657/shdoc-1.2.20241028_214954.zos.pax.Z)|A documentation generator for shell scripts|
| [groff](https://github.com/zopencommunity/groffport)|Blue|97.0%|[STABLE_groff_2677](https://github.com/zopencommunity/groffport/releases/download/STABLE_groffport_2677/groff-1.23.0.20241028_224408.zos.pax.Z)|A text formatting system|
</div>

<div class="table-category" data-category="editor">

## Editor <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [vim](https://github.com/zopencommunity/vimport)|Skipped|N/A|[STABLE_vim_2736](https://github.com/zopencommunity/vimport/releases/download/STABLE_vimport_2736/vim-heads.v9.1.0869.20241118_041149.zos.pax.Z)|Utility for managing virtual file systems|
| [nano](https://github.com/zopencommunity/nanoport)|Skipped|N/A|[STABLE_nano_2684](https://github.com/zopencommunity/nanoport/releases/download/STABLE_nanoport_2684/nano-8.1.20241028_230851.zos.pax.Z)|A simple text editor for console environments|
| [lazygit](https://github.com/zopencommunity/lazygitport)|Skipped|N/A|[STABLE_lazygit_2148](https://github.com/zopencommunity/lazygitport/releases/download/STABLE_lazygitport_2148/lazygit-master.20240221_041017.zos.pax.Z)|A Git client|
| [ctags](https://github.com/zopencommunity/ctagsport)|Green|100.0%|[STABLE_ctags_2545](https://github.com/zopencommunity/ctagsport/releases/download/STABLE_ctagsport_2545/ctags-heads.v6.1.0.20241002_014030.zos.pax.Z)|A code indexing tool|
| [dos2unix](https://github.com/zopencommunity/dos2unixport)|Blue|99.1%|[STABLE_dos2unix_2543](https://github.com/zopencommunity/dos2unixport/releases/download/STABLE_dos2unixport_2543/dos2unix-7.5.2.20241002_013955.zos.pax.Z)|A tool for converting DOS/Windows text files to Unix format|
| [git-lfs](https://github.com/zopencommunity/git-lfsport)|Blue|95.2%|[STABLE_git-lfs_2150](https://github.com/zopencommunity/git-lfsport/releases/download/STABLE_git-lfsport_2150/git-lfs.20240221_133034.zos.pax.Z)|A Git extension for versioning large files|
</div>

<div class="table-category" data-category="graphics">

## Graphics <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [fx](https://github.com/zopencommunity/fxport)|Skipped|N/A|[STABLE_fx_2577](https://github.com/zopencommunity/fxport/releases/download/STABLE_fxport_2577/fx-heads.34.0.0.20241002_034900.zos.pax.Z)|A functional programming language|
| [prometheus](https://github.com/zopencommunity/prometheusport)|Green|100.0%|[STABLE_prometheus_2271](https://github.com/zopencommunity/prometheusport/releases/download/STABLE_prometheusport_2271/prometheus-heads.v2.45.5.20240710_113009.zos.pax.Z)|A monitoring system|
| [dialog](https://github.com/zopencommunity/dialogport)|Green|100.0%|[STABLE_dialog_2578](https://github.com/zopencommunity/dialogport/releases/download/STABLE_dialogport_2578/dialog-1.3-20240619.20241002_034717.zos.pax.Z)|A library for creating dialog boxes|
</div>

<div class="table-category" data-category="language">

## Language <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [tcl](https://github.com/zopencommunity/tclport)|Skipped|N/A|[STABLE_tcl_2707](https://github.com/zopencommunity/tclport/releases/download/STABLE_tclport_2707/tcl-core8.6.13-src.20241029_025017.zos.pax.Z)|The Tcl scripting language|
| [groovy](https://github.com/zopencommunity/groovyport)|Skipped|N/A|[STABLE_groovy_2053](https://github.com/zopencommunity/groovyport/releases/download/STABLE_groovyport_2053/groovy-DEV.20240129_101738.zos.pax.Z)|A scripting language for the Java platform|
| [lua](https://github.com/zopencommunity/luaport)|Green|100.0%|[STABLE_lua_2671](https://github.com/zopencommunity/luaport/releases/download/STABLE_luaport_2671/lua-5.1.5.20241028_222633.zos.pax.Z)|A lightweight, embeddable scripting language|
| [python](https://github.com/zopencommunity/pythonport)|Green|100.0%|[STABLE_python_2663](https://github.com/zopencommunity/pythonport/releases/download/STABLE_pythonport_2663/python-DEV.20241028_220331.zos.pax.Z)|A port of the Python programming language|
| [java](https://github.com/zopencommunity/javaport)|Green|100.0%|[STABLE_java_2643](https://github.com/zopencommunity/javaport/releases/download/STABLE_javaport_2643/java-DEV.20241028_211549.zos.pax.Z)|The IBM implementation of the Java programming language|
| [my_basic](https://github.com/zopencommunity/my_basicport)|Green|100.0%|[DEV_my_basic_1889](https://github.com/zopencommunity/my_basicport/releases/download/DEV_my_basicport_1889/my_basic-master.20231205_131203.zos.pax.Z)|A BASIC interpreter|
</div>

<div class="table-category" data-category="library">

## Library <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [expat](https://github.com/zopencommunity/expatport)|Green|100.0%|[STABLE_expat_2698](https://github.com/zopencommunity/expatport/releases/download/STABLE_expatport_2698/expat-2.5.0.20241029_002907.zos.pax.Z)|A library for parsing XML content|
| [zoslib](https://github.com/zopencommunity/zoslibport)|Green|100.0%|[STABLE_zoslib_2727](https://github.com/zopencommunity/zoslibport/releases/download/STABLE_zoslibport_2727/zoslib-zopen2.20241113_035526.zos.pax.Z)|A library used by z/OS Open Tools|
| [libgdbm](https://github.com/zopencommunity/libgdbmport)|Green|100.0%|[STABLE_libgdbm_2691](https://github.com/zopencommunity/libgdbmport/releases/download/STABLE_libgdbmport_2691/gdbm-1.23.20241028_235609.zos.pax.Z)|A library for managing database functions|
| [libpipeline](https://github.com/zopencommunity/libpipelineport)|Green|100.0%|[STABLE_libpipeline_2675](https://github.com/zopencommunity/libpipelineport/releases/download/STABLE_libpipelineport_2675/libpipeline-1.5.7.20241028_223656.zos.pax.Z)|A library for managing pipelines of processes|
| [gnulib](https://github.com/zopencommunity/gnulibport)|Green|100.0%|[STABLE_gnulib_2679](https://github.com/zopencommunity/gnulibport/releases/download/STABLE_gnulibport_2679/gnulib-master.20241028_225223.zos.pax.Z)|A library containing common functions used in GNU software|
| [sqlite](https://github.com/zopencommunity/sqliteport)|Green|100.0%|[STABLE_sqlite_2676](https://github.com/zopencommunity/sqliteport/releases/download/STABLE_sqliteport_2676/sqlite-autoconf-3450100.20241028_222913.zos.pax.Z)|A lightweight embedded SQL database engine|
| [libxslt](https://github.com/zopencommunity/libxsltport)|Green|100.0%|[STABLE_libxslt_2667](https://github.com/zopencommunity/libxsltport/releases/download/STABLE_libxsltport_2667/libxslt-1.1.39.20241028_221648.zos.pax.Z)|A library for processing XSLT stylesheets|
| [libgpgerror](https://github.com/zopencommunity/libgpgerrorport)|Green|100.0%|[STABLE_libgpgerror_2753](https://github.com/zopencommunity/libgpgerrorport/releases/download/STABLE_libgpgerrorport_2753/libgpgerror-DEV.20241128_041303.zos.pax.Z)|A library for handling errors|
| [libgcrypt](https://github.com/zopencommunity/libgcryptport)|Green|100.0%|[STABLE_libgcrypt_2741](https://github.com/zopencommunity/libgcryptport/releases/download/STABLE_libgcryptport_2741/libgcrypt-1.10.3.20241119_061304.zos.pax.Z)|A general-purpose cryptographic library|
| [libksba](https://github.com/zopencommunity/libksbaport)|Green|100.0%|[STABLE_libksba_2648](https://github.com/zopencommunity/libksbaport/releases/download/STABLE_libksbaport_2648/libksba-1.6.5.20241028_211725.zos.pax.Z)|A library for working with X.509 certificates and other cryptographic objects|
| [librdkafka](https://github.com/zopencommunity/librdkafkaport)|Green|100.0%|[STABLE_librdkafka_2729](https://github.com/zopencommunity/librdkafkaport/releases/download/STABLE_librdkafkaport_2729/librdkafka-HEAD.20241114_123916.zos.pax.Z)|A high-performance C/C++ library for Apache Kafka|
| [oniguruma](https://github.com/zopencommunity/onigurumaport)|Green|100.0%|[STABLE_oniguruma_2655](https://github.com/zopencommunity/onigurumaport/releases/download/STABLE_onigurumaport_2655/oniguruma-heads.v6.9.9.20241028_214629.zos.pax.Z)|A regular expression library|
| [libbsd](https://github.com/zopencommunity/libbsdport)|Green|100.0%|[STABLE_libbsd_2665](https://github.com/zopencommunity/libbsdport/releases/download/STABLE_libbsdport_2665/libbsd-main.20241028_215810.zos.pax.Z)|A library providing common BSD functions|
| [jansson](https://github.com/zopencommunity/janssonport)|Green|100.0%|[STABLE_jansson_2652](https://github.com/zopencommunity/janssonport/releases/download/STABLE_janssonport_2652/jansson-master.20241028_213752.zos.pax.Z)|A C library for encoding, decoding, and manipulating JSON data|
| [avro-c-lib](https://github.com/zopencommunity/avro-c-libport)|Green|100.0%|[STABLE_avro-c-lib_2651](https://github.com/zopencommunity/avro-c-libport/releases/download/STABLE_avro-c-libport_2651/avro-c-packaging-master.20241028_213518.zos.pax.Z)|A data serialization framework|
| [libxml2](https://github.com/zopencommunity/libxml2port)|Blue|99.9%|[STABLE_libxml2_2683](https://github.com/zopencommunity/libxml2port/releases/download/STABLE_libxml2port_2683/libxml2-2.9.12.20241028_233023.zos.pax.Z)|A library for parsing XML content|
| [libpcre2](https://github.com/zopencommunity/libpcre2port)|Yellow|66.7%|[STABLE_libpcre2_2672](https://github.com/zopencommunity/libpcre2port/releases/download/STABLE_libpcre2port_2672/pcre2-10.42.20241028_222746.zos.pax.Z)|A regular expression library|
</div>

<div class="table-category" data-category="networking">

## Networking <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [nats](https://github.com/zopencommunity/natsport)|Skipped|N/A|[STABLE_NATS_2576](https://github.com/zopencommunity/natsport/releases/download/STABLE_NATSport_2576/nats-DEV.20241002_034528.zos.pax.Z)|A cloud-native messaging system|
| [caddy](https://github.com/zopencommunity/caddyport)|Skipped|N/A|[STABLE_caddy_2215](https://github.com/zopencommunity/caddyport/releases/download/STABLE_caddyport_2215/caddy-DEV.20240409_161941.zos.pax.Z)|A web server|
| [nghttp2](https://github.com/zopencommunity/nghttp2port)|Green|100.0%|[STABLE_nghttp2_2599](https://github.com/zopencommunity/nghttp2port/releases/download/STABLE_nghttp2port_2599/nghttp2-1.59.0.20241002_043824.zos.pax.Z)|An HTTP/2 implementation|
</div>

<div class="table-category" data-category="security">

## Security <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [sshpass](https://github.com/zopencommunity/sshpassport)|Skipped|N/A|[STABLE_sshpass_2641](https://github.com/zopencommunity/sshpassport/releases/download/STABLE_sshpassport_2641/sshpass-1.10.20241028_083610.zos.pax.Z)|A secure shell client|
| [osv-scanner](https://github.com/zopencommunity/osv-scannerport)|Skipped|N/A|[STABLE_osv-scanner_2133](https://github.com/zopencommunity/osv-scannerport/releases/download/STABLE_osv-scannerport_2133/osv-scanner-heads.v1.6.2.20240214_174547.zos.pax.Z)|Vulnerability scanner written in Go which uses the data provided by https://osv.dev|
| [cppcheck](https://github.com/zopencommunity/cppcheckport)|Skipped|N/A|[STABLE_cppcheck_2309](https://github.com/zopencommunity/cppcheckport/releases/download/STABLE_cppcheckport_2309/cppcheck-heads.2.14.2.20240619_013350.zos.pax.Z)|A static analysis tool for C/C++ code|
| [npth](https://github.com/zopencommunity/npthport)|Green|100.0%|[STABLE_npth_2754](https://github.com/zopencommunity/npthport/releases/download/STABLE_npthport_2754/npth-1.8.20241128_113430.zos.pax.Z)|A portable threading library|
| [libgpgerror](https://github.com/zopencommunity/libgpgerrorport)|Green|100.0%|[STABLE_libgpgerror_2753](https://github.com/zopencommunity/libgpgerrorport/releases/download/STABLE_libgpgerrorport_2753/libgpgerror-DEV.20241128_041303.zos.pax.Z)|A library for handling errors|
| [libgcrypt](https://github.com/zopencommunity/libgcryptport)|Green|100.0%|[STABLE_libgcrypt_2741](https://github.com/zopencommunity/libgcryptport/releases/download/STABLE_libgcryptport_2741/libgcrypt-1.10.3.20241119_061304.zos.pax.Z)|A general-purpose cryptographic library|
| [libksba](https://github.com/zopencommunity/libksbaport)|Green|100.0%|[STABLE_libksba_2648](https://github.com/zopencommunity/libksbaport/releases/download/STABLE_libksbaport_2648/libksba-1.6.5.20241028_211725.zos.pax.Z)|A library for working with X.509 certificates and other cryptographic objects|
| [openssh](https://github.com/zopencommunity/opensshport)|Green|100.0%|[STABLE_openssh_2748](https://github.com/zopencommunity/opensshport/releases/download/STABLE_opensshport_2748/openssh-9.9p1.20241120_165536.zos.pax.Z)|A suite of secure networking utilities|
| [pinentry](https://github.com/zopencommunity/pinentryport)|Green|100.0%|[STABLE_pinentry_2734](https://github.com/zopencommunity/pinentryport/releases/download/STABLE_pinentryport_2734/pinentry-1.3.1.20241115_142052.zos.pax.Z)|A secure passphrase entry utility|
| [ntbtls](https://github.com/zopencommunity/ntbtlsport)|Green|100.0%|[STABLE_ntbtls_2650](https://github.com/zopencommunity/ntbtlsport/releases/download/STABLE_ntbtlsport_2650/ntbtls-0.3.2.20241028_211903.zos.pax.Z)|A lightweight TLS 1.2 implementation|
| [libmd](https://github.com/zopencommunity/libmdport)|Green|100.0%|[STABLE_libmd_2658](https://github.com/zopencommunity/libmdport/releases/download/STABLE_libmdport_2658/libmd-1.1.0.20241028_213749.zos.pax.Z)|A library for computing message digests|
| [libsasl2](https://github.com/zopencommunity/libsasl2port)|Green|100.0%|[STABLE_libsasl2_2311](https://github.com/zopencommunity/libsasl2port/releases/download/STABLE_libsasl2port_2311/cyrus-sasl-master.20240624_052635.zos.pax.Z)|A SASL library|
</div>

<div class="table-category" data-category="shell">

## Shell <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [powerlinego](https://github.com/zopencommunity/powerlinegoport)|Skipped|N/A|[STABLE_powerlinego_2751](https://github.com/zopencommunity/powerlinegoport/releases/download/STABLE_powerlinegoport_2751/powerlinego-DEV.20241127_031544.zos.pax.Z)|A low-latency prompt for your shell|
</div>

<div class="table-category" data-category="source_control">

## Source_Control <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [gitlab-runner](https://github.com/zopencommunity/gitlab-runnerport)|Skipped|N/A|[STABLE_gitlab-runner_2597](https://github.com/zopencommunity/gitlab-runnerport/releases/download/STABLE_gitlab-runnerport_2597/gitlab-runner.20241002_044313.zos.pax.Z)|A GitLab Runner|
| [tig](https://github.com/zopencommunity/tigport)|Green|100.0%|[STABLE_tig_2656](https://github.com/zopencommunity/tigport/releases/download/STABLE_tigport_2656/tig-2.5.9.20241028_214944.zos.pax.Z)|A text-mode interface for Git|
| [git](https://github.com/zopencommunity/gitport)|Blue|96.7%|[STABLE_git_2730](https://github.com/zopencommunity/gitport/releases/download/STABLE_gitport_2730/git-heads.v2.47.0.20241114_225356.zos.pax.Z)|The Git version control system|
</div>

<div class="table-category" data-category="uncategorized">

## Uncategorized <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [ncdu](https://github.com/zopencommunity/ncduport)|Skipped|N/A|[STABLE_ncdu_2401](https://github.com/zopencommunity/ncduport/releases/download/STABLE_ncduport_2401/ncdu-1.20.20240820_162607.zos.pax.Z)|A disk usage analyzer with an ncurses interface|
| [emacs](https://github.com/zopencommunity/emacsport)|Skipped|N/A|[STABLE_emacs_2505](https://github.com/zopencommunity/emacsport/releases/download/STABLE_emacsport_2505/emacs-29.4.20241001_222229.zos.pax.Z)|A text editor|
| [yq](https://github.com/zopencommunity/yqport)|Skipped|N/A|[STABLE_yq_2531](https://github.com/zopencommunity/yqport/releases/download/STABLE_yqport_2531/yq-master.20241002_010453.zos.pax.Z)|A command-line JSON processor|
| [gum](https://github.com/zopencommunity/gumport)|Skipped|N/A|[STABLE_gum_2581](https://github.com/zopencommunity/gumport/releases/download/STABLE_gumport_2581/gum-heads.v0.13.0.20241002_035627.zos.pax.Z)|A tool for creating simple command-line interfaces|
| [thesilversearcher](https://github.com/zopencommunity/thesilversearcherport)|Skipped|N/A|[STABLE_thesilversearcher_2575](https://github.com/zopencommunity/thesilversearcherport/releases/download/STABLE_thesilversearcherport_2575/the_silver_searcher-2.2.0.20241002_034103.zos.pax.Z)|A code searching tool|
| [llamacpp](https://github.com/zopencommunity/llamacppport)|Skipped|N/A|[STABLE_llamacpp_2013](https://github.com/zopencommunity/llamacppport/releases/download/STABLE_llamacppport_2013/llamacpp-master.20240124_170742.zos.pax.Z)|A C++ library for writing high-performance network applications|
| [githubcli](https://github.com/zopencommunity/githubcliport)|Skipped|N/A|[DEV_githubcli_2573](https://github.com/zopencommunity/githubcliport/releases/download/DEV_githubcliport_2573/githubcli-DEV.20241002_030701.zos.pax.Z)|A command-line tool for GitHub|
| [gitlabcli](https://github.com/zopencommunity/gitlabcliport)|Skipped|N/A|[STABLE_gitlabcli_2590](https://github.com/zopencommunity/gitlabcliport/releases/download/STABLE_gitlabcliport_2590/gitlabcli-DEV.20241002_042636.zos.pax.Z)|A command-line tool for GitLab|
| [less](https://github.com/zopencommunity/lessport)|Green|100.0%|[STABLE_less_2642](https://github.com/zopencommunity/lessport/releases/download/STABLE_lessport_2642/less-heads.v667.20241028_123530.zos.pax.Z)|A text pager|
| [ncurses](https://github.com/zopencommunity/ncursesport)|Green|100.0%|[STABLE_ncurses_2721](https://github.com/zopencommunity/ncursesport/releases/download/STABLE_ncursesport_2721/ncurses-6.5.20241101_200007.zos.pax.Z)|Library for ncurses, a terminal screen handling library|
| [zlib](https://github.com/zopencommunity/zlibport)|Green|100.0%|[DEV_zlib_2706](https://github.com/zopencommunity/zlibport/releases/download/DEV_zlibport_2706/zlib-develop.20241029_024916.zos.pax.Z)|A data compression library|
| [help2man](https://github.com/zopencommunity/help2manport)|Green|100.0%|[STABLE_help2man_2476](https://github.com/zopencommunity/help2manport/releases/download/STABLE_help2manport_2476/help2man-1.49.3.20240924_041914.zos.pax.Z)|A tool for converting manual pages to other formats|
| [xxhash](https://github.com/zopencommunity/xxhashport)|Green|100.0%|[STABLE_xxhash_1993](https://github.com/zopencommunity/xxhashport/releases/download/STABLE_xxhashport_1993/xxHash-0.8.2.20240123_100914.zos.pax.Z)|A fast hash function library|
| [zstd](https://github.com/zopencommunity/zstdport)|Green|100.0%|[STABLE_zstd_2041](https://github.com/zopencommunity/zstdport/releases/download/STABLE_zstdport_2041/zstd-1.5.5.20240126_215521.zos.pax.Z)|A compression algorithm|
| [lz4](https://github.com/zopencommunity/lz4port)|Green|100.0%|[STABLE_lz4_1936](https://github.com/zopencommunity/lz4port/releases/download/STABLE_lz4port_1936/lz4-1.9.4.20240104_082651.zos.pax.Z)|A compression algorithm|
| [php](https://github.com/zopencommunity/phpport)|Green|100.0%|[STABLE_php_1996](https://github.com/zopencommunity/phpport/releases/download/STABLE_phpport_1996/php-8.2.13.20240123_152440.zos.pax.Z)|A programming language|
| [cscope](https://github.com/zopencommunity/cscopeport)|Green|100.0%|[STABLE_cscope_2506](https://github.com/zopencommunity/cscopeport/releases/download/STABLE_cscopeport_2506/cscope-15.9.20241001_232134.zos.pax.Z)|A source code analyzer|
| [libiconv](https://github.com/zopencommunity/libiconvport)|Green|100.0%|[DEV_libiconv_2409](https://github.com/zopencommunity/libiconvport/releases/download/DEV_libiconvport_2409/libiconv-master.20240824_140157.zos.pax.Z)|A library for character set conversion|
| [lynx](https://github.com/zopencommunity/lynxport)|Green|100.0%|[STABLE_lynx_2016](https://github.com/zopencommunity/lynxport/releases/download/STABLE_lynxport_2016/lynx-2.8.9.20240124_173303.zos.pax.Z)|A text-based web browser|
| [which](https://github.com/zopencommunity/whichport)|Green|100.0%|[STABLE_which_2564](https://github.com/zopencommunity/whichport/releases/download/STABLE_whichport_2564/which-2.21.20241002_024933.zos.pax.Z)|A command to find commands|
| [neovim](https://github.com/zopencommunity/neovimport)|Green|100.0%|[STABLE_neovim_2198](https://github.com/zopencommunity/neovimport/releases/download/STABLE_neovimport_2198/neovim-master.20240312_215757.zos.pax.Z)|A text editor|
| [libassuan](https://github.com/zopencommunity/libassuanport)|Green|100.0%|[STABLE_libassuan_2618](https://github.com/zopencommunity/libassuanport/releases/download/STABLE_libassuanport_2618/libassuan-2.5.6.20241014_074316.zos.pax.Z)|A library for the Assuan protocol, used for IPC between GnuPG components|
| [direnv](https://github.com/zopencommunity/direnvport)|Green|100.0%|[STABLE_direnv_2498](https://github.com/zopencommunity/direnvport/releases/download/STABLE_direnvport_2498/direnv-heads.v2.34.0.20241001_215342.zos.pax.Z)||
| [duckdb](https://github.com/zopencommunity/duckdbport)|Green|100.0%|[STABLE_duckdb_1986](https://github.com/zopencommunity/duckdbport/releases/download/STABLE_duckdbport_1986/duckdb-main.20240122_143549.zos.pax.Z)|An in-process SQL OLAP database management system|
| [bump](https://github.com/zopencommunity/bumpport)|Green|100.0%|[STABLE_bump_2540](https://github.com/zopencommunity/bumpport/releases/download/STABLE_bumpport_2540/bump-master.20241002_013007.zos.pax.Z)|A version control and update tool|
| [wharf](https://github.com/zopencommunity/wharfport)|Green|100.0%|[STABLE_wharf_2586](https://github.com/zopencommunity/wharfport/releases/download/STABLE_wharfport_2586/wharf-main.20241002_041452.zos.pax.Z)|A build configuration for Wharf|
| [luarocks](https://github.com/zopencommunity/luarocksport)|Green|100.0%|[STABLE_luarocks_2014](https://github.com/zopencommunity/luarocksport/releases/download/STABLE_luarocksport_2014/luarocks-heads.v3.9.2.20240124_121244.zos.pax.Z)|A package manager for Lua|
| [protobuf](https://github.com/zopencommunity/protobufport)|Green|100.0%|[STABLE_protobuf_2029](https://github.com/zopencommunity/protobufport/releases/download/STABLE_protobufport_2029/protobuf-main.20240124_133955.zos.pax.Z)|A protocol buffer compiler|
| [libserdes](https://github.com/zopencommunity/libserdesport)|Green|100.0%|[STABLE_libserdes_2733](https://github.com/zopencommunity/libserdesport/releases/download/STABLE_libserdesport_2733/libserdes-master.20241115_140625.zos.pax.Z)|A serialization/deserialization library|
| [depot_tools](https://github.com/zopencommunity/depot_toolsport)|Green|100.0%|[DEV_depot_tools_2549](https://github.com/zopencommunity/depot_toolsport/releases/download/DEV_depot_toolsport_2549/depot_tools-main.20241002_020104.zos.pax.Z)|Tools for working with Chromium development|
| [zospstree](https://github.com/zopencommunity/zospstreeport)|Green|100.0%|[STABLE_zospstree_2567](https://github.com/zopencommunity/zospstreeport/releases/download/STABLE_zospstreeport_2567/zostree-DEV.20241002_025437.zos.pax.Z)|A tool for viewing the structure of z/OS file systems|
| [zosnc](https://github.com/zopencommunity/zosncport)|Green|100.0%|[STABLE_zosnc_2589](https://github.com/zopencommunity/zosncport/releases/download/STABLE_zosncport_2589/zosnc-DEV.20241002_043005.zos.pax.Z)|A tool for managing network connections|
| [curl](https://github.com/zopencommunity/curlport)|Blue|99.9%|[STABLE_curl_2731](https://github.com/zopencommunity/curlport/releases/download/STABLE_curlport_2731/curl-8.11.0.20241115_052024.zos.pax.Z)|Networking tool|
| [bison](https://github.com/zopencommunity/bisonport)|Blue|99.7%|[STABLE_bison_2448](https://github.com/zopencommunity/bisonport/releases/download/STABLE_bisonport_2448/bison-3.8.2.20240922_015100.zos.pax.Z)|repository for bison port to z/os|
| [perl](https://github.com/zopencommunity/perlport)|Blue|98.8%|[STABLE_perl_2740](https://github.com/zopencommunity/perlport/releases/download/STABLE_perlport_2740/perl5-heads.v5.41.5.20241118_172302.zos.pax.Z)|Perl programming language|
| [m4](https://github.com/zopencommunity/m4port)|Blue|98.3%|[STABLE_m4_1941](https://github.com/zopencommunity/m4port/releases/download/STABLE_m4port_1941/m4-1.4.19.20240104_082339.zos.pax.Z)|A macro processor|
| [ninja](https://github.com/zopencommunity/ninjaport)|Blue|98.2%|[STABLE_ninja_2713](https://github.com/zopencommunity/ninjaport/releases/download/STABLE_ninjaport_2713/ninja-heads.v1.12.1.20241029_041229.zos.pax.Z)|Build automation tool used with GNU Autotools|
| [autoconf](https://github.com/zopencommunity/autoconfport)|Blue|98.0%|[STABLE_autoconf_1736](https://github.com/zopencommunity/autoconfport/releases/download/STABLE_autoconfport_1736/autoconf-2.71.20231114_002453.zos.pax.Z)|A configuration management tool|
| [rsync](https://github.com/zopencommunity/rsyncport)|Blue|97.7%|[STABLE_rsync_2052](https://github.com/zopencommunity/rsyncport/releases/download/STABLE_rsyncport_2052/rsync-master.20240129_094849.zos.pax.Z)|A file synchronization utility|
| [gpg](https://github.com/zopencommunity/gpgport)|Blue|97.3%|[STABLE_gpg_2510](https://github.com/zopencommunity/gpgport/releases/download/STABLE_gpgport_2510/gnupg-2.4.4.20241001_233258.zos.pax.Z)|A free software implementation of the GNU Privacy Guard|
| [openssl](https://github.com/zopencommunity/opensslport)|Blue|95.5%|[STABLE_openssl_2719](https://github.com/zopencommunity/opensslport/releases/download/STABLE_opensslport_2719/openssl-3.3.2.20241101_004716.zos.pax.Z)|A cryptographic library|
| [doxygen](https://github.com/zopencommunity/doxygenport)|Blue|95.2%|[STABLE_doxygen_2189](https://github.com/zopencommunity/doxygenport/releases/download/STABLE_doxygenport_2189/doxygen-master.20240311_135723.zos.pax.Z)|A documentation generator|
| [libuv](https://github.com/zopencommunity/libuvport)|Blue|94.0%|[STABLE_libuv_2601](https://github.com/zopencommunity/libuvport/releases/download/STABLE_libuvport_2601/libuv-heads.v1.48.0.20241002_035849.zos.pax.Z)|An asynchronous I/O library|
| [gettext](https://github.com/zopencommunity/gettextport)|Blue|87.4%|[STABLE_gettext_2450](https://github.com/zopencommunity/gettextport/releases/download/STABLE_gettextport_2450/gettext-0.21.20240922_014617.zos.pax.Z)|A library for internationalization and localization|
| [boost](https://github.com/zopencommunity/boostport)|Blue|85.1%|[DEV_boost_2378](https://github.com/zopencommunity/boostport/releases/download/DEV_boostport_2378/boost-master.20240730_055731.zos.pax.Z)|A collection of C++ libraries|
| [cmake](https://github.com/zopencommunity/cmakeport)|Blue|83.8%|[STABLE_cmake_2068](https://github.com/zopencommunity/cmakeport/releases/download/STABLE_cmakeport_2068/CMake-heads.v3.27.8.20240129_142242.zos.pax.Z)|A cross-platform build system|
| [libtool](https://github.com/zopencommunity/libtoolport)|Blue|81.6%|[STABLE_libtool_2708](https://github.com/zopencommunity/libtoolport/releases/download/STABLE_libtoolport_2708/libtool-2.4.20241029_025421.zos.pax.Z)|Library for managing program library dependencies|
| [bash](https://github.com/zopencommunity/bashport)|Blue|80.5%|[STABLE_bash_2485](https://github.com/zopencommunity/bashport/releases/download/STABLE_bashport_2485/bash-5.2.32.20240930_190728.zos.pax.Z)|The Bourne Again shell|
| [libpcre](https://github.com/zopencommunity/libpcreport)|Blue|80.0%|[STABLE_libpcre_1938](https://github.com/zopencommunity/libpcreport/releases/download/STABLE_libpcreport_1938/pcre-8.45.20240104_134313.zos.pax.Z)|A regular expression library|
| [coreutils](https://github.com/zopencommunity/coreutilsport)|Blue|79.8%|[STABLE_coreutils_2629](https://github.com/zopencommunity/coreutilsport/releases/download/STABLE_coreutilsport_2629/coreutils-9.5.20241018_140747.zos.pax.Z)|A collection of basic Unix utilities|
| [xz](https://github.com/zopencommunity/xzport)|Blue|77.8%|[STABLE_xz_2609](https://github.com/zopencommunity/xzport/releases/download/STABLE_xzport_2609/xz-5.4.5.20241009_201602.zos.pax.Z)|A compression utility|
| [gzip](https://github.com/zopencommunity/gzipport)|Blue|77.8%|[STABLE_gzip_2711](https://github.com/zopencommunity/gzipport/releases/download/STABLE_gzipport_2711/gzip-1.13.20241029_035908.zos.pax.Z)|Library for handling gzip compressed files|
| [automake](https://github.com/zopencommunity/automakeport)|Yellow|71.4%|[STABLE_automake_2714](https://github.com/zopencommunity/automakeport/releases/download/STABLE_automakeport_2714/automake-1.17.20241029_040611.zos.pax.Z)|Tool for managing dependencies in software projects using GNU Autotools|
| [getopt](https://github.com/zopencommunity/getoptport)|Yellow|52.2%|[STABLE_getopt_1927](https://github.com/zopencommunity/getoptport/releases/download/STABLE_getoptport_1927/getopt-1.1.6.20240103_131650.zos.pax.Z)|A command-line option parser|
| [texinfo](https://github.com/zopencommunity/texinfoport)|Red|35.3%|[STABLE_texinfo_1764](https://github.com/zopencommunity/texinfoport/releases/download/STABLE_texinfoport_1764/texinfo-6.8.20231115_132117.zos.pax.Z)|A documentation generator|
| [wget](https://github.com/zopencommunity/wgetport)|Red|18.8%|[STABLE_wget_2157](https://github.com/zopencommunity/wgetport/releases/download/STABLE_wgetport_2157/wget-1.21.4.20240224_042400.zos.pax.Z)|A utility for retrieving files from the web|
| [libssh2](https://github.com/zopencommunity/libssh2port)|Red|7.1%|[STABLE_libssh2_1930](https://github.com/zopencommunity/libssh2port/releases/download/STABLE_libssh2port_1930/libssh2-1.11.0.20240103_144102.zos.pax.Z)|A library for SSH2 protocol|
</div>

<div class="table-category" data-category="utilities">

## Utilities <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [zigi](https://github.com/zopencommunity/zigiport)|Skipped|N/A|[STABLE_zigi_2747](https://github.com/zopencommunity/zigiport/releases/download/STABLE_zigiport_2747/zigi-master.20241120_170602.zos.pax.Z)|A git interface for ispf|
| [moreutils](https://github.com/zopencommunity/moreutilsport)|Skipped|N/A|[STABLE_moreutils_2647](https://github.com/zopencommunity/moreutilsport/releases/download/STABLE_moreutilsport_2647/moreutils-0.67.20241028_212123.zos.pax.Z)|A collection of text processing utilities|
| [tree](https://github.com/zopencommunity/treeport)|Skipped|N/A|[STABLE_tree_2752](https://github.com/zopencommunity/treeport/releases/download/STABLE_treeport_2752/tree-heads.2.1.1.20241127_223132.zos.pax.Z)|A directory tree listing tool|
| [prompters](https://github.com/zopencommunity/promptersport)|Skipped|N/A|[STABLE_prompters_2717](https://github.com/zopencommunity/promptersport/releases/download/STABLE_promptersport_2717/prompters-main.20241029_144150.zos.pax.Z)|Prompter library for creating interactive command line interfaces|
| [lazygit](https://github.com/zopencommunity/lazygitport)|Skipped|N/A|[STABLE_lazygit_2148](https://github.com/zopencommunity/lazygitport/releases/download/STABLE_lazygitport_2148/lazygit-master.20240221_041017.zos.pax.Z)|A Git client|
| [ttype](https://github.com/zopencommunity/ttypeport)|Skipped|N/A|[STABLE_ttype_2185](https://github.com/zopencommunity/ttypeport/releases/download/STABLE_ttypeport_2185/ttype-heads.v0.4.0.20240308_094006.zos.pax.Z)|A terminal type identifier|
| [godsect](https://github.com/zopencommunity/godsectport)|Skipped|N/A|[STABLE_godsect_2444](https://github.com/zopencommunity/godsectport/releases/download/STABLE_godsectport_2444/godsect-main.20240922_052634.zos.pax.Z)|A code security scanner|
| [zotsample](https://github.com/zopencommunity/zotsampleport)|Green|100.0%|[STABLE_zotsample_2744](https://github.com/zopencommunity/zotsampleport/releases/download/STABLE_zotsampleport_2744/zotsample-1.3.20241120_025724.zos.pax.Z)|z/OS Open Tools Sample Port for education|
| [man-db](https://github.com/zopencommunity/man-dbport)|Green|100.0%|[STABLE_man-db_2712](https://github.com/zopencommunity/man-dbport/releases/download/STABLE_man-dbport_2712/man-db-2.12.1.20241029_015025.zos.pax.Z)|Tool for generating manual pages for Unix programs|
| [hello](https://github.com/zopencommunity/helloport)|Green|100.0%|[STABLE_hello_2670](https://github.com/zopencommunity/helloport/releases/download/STABLE_helloport_2670/hello-2.12.1.20241028_222324.zos.pax.Z)|A simple "hello world" program demonstrating the use of autotools and gettext|
| [meta](https://github.com/zopencommunity/metaport)|Green|100.0%|[STABLE_meta_2750](https://github.com/zopencommunity/metaport/releases/download/STABLE_metaport_2750/meta-main.20241122_160415.zos.pax.Z)|zopen package manager|
| [tig](https://github.com/zopencommunity/tigport)|Green|100.0%|[STABLE_tig_2656](https://github.com/zopencommunity/tigport/releases/download/STABLE_tigport_2656/tig-2.5.9.20241028_214944.zos.pax.Z)|A text-mode interface for Git|
| [c3270](https://github.com/zopencommunity/c3270port)|Green|100.0%|[STABLE_c3270_2669](https://github.com/zopencommunity/c3270port/releases/download/STABLE_c3270port_2669/c3270-DEV.20241028_220605.zos.pax.Z)|A 3270 terminal emulator|
| [zos-code-page-tools](https://github.com/zopencommunity/zos-code-page-toolsport)|Green|100.0%|[DEV_zos-code-page-tools_2645](https://github.com/zopencommunity/zos-code-page-toolsport/releases/download/DEV_zos-code-page-toolsport_2645/zoscodepagetools-DEV.20241028_211943.zos.pax.Z)|Tools for working with z/OS code pages|
| [stow](https://github.com/zopencommunity/stowport)|Green|100.0%|[STABLE_stow_2598](https://github.com/zopencommunity/stowport/releases/download/STABLE_stowport_2598/stow-2.4.0.20241002_045825.zos.pax.Z)|A symlink manager|
| [parse-gotest](https://github.com/zopencommunity/parse-gotestport)|Green|100.0%|[STABLE_parse-gotest_2364](https://github.com/zopencommunity/parse-gotestport/releases/download/STABLE_parse-gotestport_2364/parse-gotest-heads.v0.1.1.20240721_042053.zos.pax.Z)|A Go test parser|
| [git-lfs](https://github.com/zopencommunity/git-lfsport)|Blue|95.2%|[STABLE_git-lfs_2150](https://github.com/zopencommunity/git-lfsport/releases/download/STABLE_git-lfsport_2150/git-lfs.20240221_133034.zos.pax.Z)|A Git extension for versioning large files|
| [patch](https://github.com/zopencommunity/patchport)|Blue|94.1%|[STABLE_patch_2680](https://github.com/zopencommunity/patchport/releases/download/STABLE_patchport_2680/patch-2.7.20241028_223747.zos.pax.Z)|Tool for patching files|
| [gawk](https://github.com/zopencommunity/gawkport)|Blue|92.9%|[STABLE_gawk_2689](https://github.com/zopencommunity/gawkport/releases/download/STABLE_gawkport_2689/gawk-5.3.0.20241028_234615.zos.pax.Z)|The GNU implementation of the awk text processing language|
| [diffutils](https://github.com/zopencommunity/diffutilsport)|Blue|92.8%|[STABLE_diffutils_2699](https://github.com/zopencommunity/diffutilsport/releases/download/STABLE_diffutilsport_2699/diffutils-3.10.20241029_000813.zos.pax.Z)|File and directory comparison utilities|
| [tar](https://github.com/zopencommunity/tarport)|Blue|92.4%|[STABLE_tar_2703](https://github.com/zopencommunity/tarport/releases/download/STABLE_tarport_2703/tar-1.35.20241029_004316.zos.pax.Z)|GNU implementation of the tar archiving tool|
| [grep](https://github.com/zopencommunity/grepport)|Blue|92.1%|[STABLE_grep_2701](https://github.com/zopencommunity/grepport/releases/download/STABLE_grepport_2701/grep-3.11.20241029_001448.zos.pax.Z)|Text processing utilities|
| [findutils](https://github.com/zopencommunity/findutilsport)|Blue|91.9%|[STABLE_findutils_2690](https://github.com/zopencommunity/findutilsport/releases/download/STABLE_findutilsport_2690/findutils-4.9.0.20241028_234333.zos.pax.Z)|Utilities for finding files|
| [sed](https://github.com/zopencommunity/sedport)|Blue|84.7%|[STABLE_sed_2696](https://github.com/zopencommunity/sedport/releases/download/STABLE_sedport_2696/sed-4.9.20241028_234039.zos.pax.Z)|A stream editor for manipulating text files|
| [jq](https://github.com/zopencommunity/jqport)|Yellow|71.4%|[STABLE_jq_2694](https://github.com/zopencommunity/jqport/releases/download/STABLE_jqport_2694/jq-1.6.20241029_001827.zos.pax.Z)|A port of the JQ command-line JSON processor|
</div>

<div class="table-category" data-category="webframework">

## Webframework <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [hugo](https://github.com/zopencommunity/hugoport)|Skipped|N/A|[STABLE_hugo_2583](https://github.com/zopencommunity/hugoport/releases/download/STABLE_hugoport_2583/hugo-heads.v0.129.0.20241002_035927.zos.pax.Z)|A static site generator|
</div>


Last updated:  2024-11-28T06:56:43.377858
