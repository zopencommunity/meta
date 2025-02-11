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
| [make](https://github.com/zopencommunity/makeport)|Green|100.0%|[STABLE_make_2925](https://github.com/zopencommunity/makeport/releases/download/STABLE_makeport_2925/make-4.4.1.20250130_121444.zos.pax.Z)|A build automation tool|
| [meson](https://github.com/zopencommunity/mesonport)|Red|33.3%|[STABLE_meson_3029](https://github.com/zopencommunity/mesonport/releases/download/STABLE_mesonport_3029/meson-heads.1.6.0.20250131_092909.zos.pax.Z)|A build system|
</div>

<div class="table-category" data-category="compression">

## Compression <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [bzip2](https://github.com/zopencommunity/bzip2port)|Green|100.0%|[STABLE_bzip2_2959](https://github.com/zopencommunity/bzip2port/releases/download/STABLE_bzip2port_2959/bzip2-1.0.8.20250130_232500.zos.pax.Z)|A compression utility|
| [zip](https://github.com/zopencommunity/zipport)|Green|100.0%|[STABLE_zip_3079](https://github.com/zopencommunity/zipport/releases/download/STABLE_zipport_3079/zip-master.20250205_143804.zos.pax.Z)|Tool for zipping files|
| [unzip](https://github.com/zopencommunity/unzipport)|Green|100.0%|[STABLE_unzip_3080](https://github.com/zopencommunity/unzipport/releases/download/STABLE_unzipport_3080/unzip-master.20250205_143814.zos.pax.Z)|Tool for unzipping compressed files|
</div>

<div class="table-category" data-category="core">

## Core <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [screen](https://github.com/zopencommunity/screenport)|Skipped|N/A|[STABLE_screen_2906](https://github.com/zopencommunity/screenport/releases/download/STABLE_screenport_2906/screen-4.9.1.20250129_190227.zos.pax.Z)|A full-screen terminal multiplexer|
| [gin](https://github.com/zopencommunity/ginport)|Skipped|N/A|[STABLE_gin_2594](https://github.com/zopencommunity/ginport/releases/download/STABLE_ginport_2594/gin-heads.v1.9.1.20241002_044048.zos.pax.Z)|A web framework for Go|
| [maven](https://github.com/zopencommunity/mavenport)|Skipped|N/A|[STABLE_maven_3018](https://github.com/zopencommunity/mavenport/releases/download/STABLE_mavenport_3018/apache-maven-3.9.9-bin.20250131_084140.zos.pax.Z)|A build automation tool|
| [util-linux](https://github.com/zopencommunity/util-linuxport)|Green|100.0%|[STABLE_util-linux_3042](https://github.com/zopencommunity/util-linuxport/releases/download/STABLE_util-linuxport_3042/util-linux-heads.v2.39.3.20250131_101532.zos.pax.Z)|A collection of system utilities|
| [gmp](https://github.com/zopencommunity/gmpport)|Green|100.0%|[STABLE_gmp_3025](https://github.com/zopencommunity/gmpport/releases/download/STABLE_gmpport_3025/gmp-6.3.0.20250131_065607.zos.pax.Z)|A library for arbitrary precision arithmetic|
| [frp](https://github.com/zopencommunity/frpport)|Green|100.0%|[STABLE_frp_2859](https://github.com/zopencommunity/frpport/releases/download/STABLE_frpport_2859/frp-heads.v0.54.0.20250124_120527.zos.pax.Z)|A reverse proxy|
| [libdio](https://github.com/zopencommunity/libdioport)|Green|100.0%|[DEV_libdio_3036](https://github.com/zopencommunity/libdioport/releases/download/DEV_libdioport_3036/libdio-main.20250131_101636.zos.pax.Z)|A dataset I/O library|
| [sudo](https://github.com/zopencommunity/sudoport)|Blue|87.8%|[STABLE_sudo_2913](https://github.com/zopencommunity/sudoport/releases/download/STABLE_sudoport_2913/sudo-1.9.15p5.20250129_191208.zos.pax.Z)|A program for running commands with superuser privileges|
| [sed](https://github.com/zopencommunity/sedport)|Blue|84.7%|[STABLE_sed_2981](https://github.com/zopencommunity/sedport/releases/download/STABLE_sedport_2981/sed-4.9.20250131_041436.zos.pax.Z)|A stream editor for manipulating text files|
| [netpbm](https://github.com/zopencommunity/netpbmport)|Red|31.2%|[STABLE_netpbm_3051](https://github.com/zopencommunity/netpbmport/releases/download/STABLE_netpbmport_3051/netpbm-trunk.20250131_102551.zos.pax.Z)|A toolkit for manipulating images|
</div>

<div class="table-category" data-category="database">

## Database <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [grafana](https://github.com/zopencommunity/grafanaport)|Skipped|N/A|[STABLE_grafana_2268](https://github.com/zopencommunity/grafanaport/releases/download/STABLE_grafanaport_2268/grafana-heads.v11.1.3.20240731_150543.zos.pax.Z)|An open-source observability and data visualization platform|
| [s5cmd](https://github.com/zopencommunity/s5cmdport)|Skipped|N/A|[STABLE_s5cmd_2587](https://github.com/zopencommunity/s5cmdport/releases/download/STABLE_s5cmdport_2587/s5cmd-heads.v2.2.2.20241002_042219.zos.pax.Z)|A parallel S3 and local filesystem execution tool|
| [sqlite](https://github.com/zopencommunity/sqliteport)|Green|100.0%|[STABLE_sqlite_2990](https://github.com/zopencommunity/sqliteport/releases/download/STABLE_sqliteport_2990/sqlite-autoconf-3480000.20250131_045743.zos.pax.Z)|A lightweight embedded SQL database engine|
| [prometheus](https://github.com/zopencommunity/prometheusport)|Green|100.0%|[STABLE_prometheus_2271](https://github.com/zopencommunity/prometheusport/releases/download/STABLE_prometheusport_2271/prometheus-heads.v2.45.5.20240710_113009.zos.pax.Z)|A monitoring system|
</div>

<div class="table-category" data-category="development">

## Development <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [vim](https://github.com/zopencommunity/vimport)|Skipped|N/A|[STABLE_vim_3052](https://github.com/zopencommunity/vimport/releases/download/STABLE_vimport_3052/vim-heads.v9.1.1016.20250131_113109.zos.pax.Z)|A TUI editor|
| [expect](https://github.com/zopencommunity/expectport)|Skipped|N/A|[STABLE_expect_2988](https://github.com/zopencommunity/expectport/releases/download/STABLE_expectport_2988/expect-5.45.4.20250131_044542.zos.pax.Z)|A tool for automating interactions with text-based programs|
| [depot_tools](https://github.com/zopencommunity/depot_toolsport)|Skipped|N/A|[DEV_depot_tools_2832](https://github.com/zopencommunity/depot_toolsport/releases/download/DEV_depot_toolsport_2832/depot_tools-main.20250121_195105.zos.pax.Z)|Tools for working with Chromium development|
| [githubcli](https://github.com/zopencommunity/githubcliport)|Skipped|N/A|[DEV_githubcli_3074](https://github.com/zopencommunity/githubcliport/releases/download/DEV_githubcliport_3074/githubcli-DEV.20250205_031236.zos.pax.Z)|A command-line tool for GitHub|
| [buildkite](https://github.com/zopencommunity/buildkiteport)|Skipped|N/A|[STABLE_buildkite_2774](https://github.com/zopencommunity/buildkiteport/releases/download/STABLE_buildkiteport_2774/buildkite-DEV.20241206_015934.zos.pax.Z)|Buildkite is a platform for running fast, secure, and scalable continuous integration pipelines on your own infrastructure|
| [gitlab-runner](https://github.com/zopencommunity/gitlab-runnerport)|Skipped|N/A|[STABLE_gitlab-runner_2597](https://github.com/zopencommunity/gitlab-runnerport/releases/download/STABLE_gitlab-runnerport_2597/gitlab-runner.20241002_044313.zos.pax.Z)|A GitLab Runner|
| [ant](https://github.com/zopencommunity/antport)|Skipped|N/A|[STABLE_ant_3011](https://github.com/zopencommunity/antport/releases/download/STABLE_antport_3011/ant-DEV.20250131_063159.zos.pax.Z)|A build automation tool|
| [gitlabcli](https://github.com/zopencommunity/gitlabcliport)|Skipped|N/A|[STABLE_gitlabcli_3065](https://github.com/zopencommunity/gitlabcliport/releases/download/STABLE_gitlabcliport_3065/gitlabcli-DEV.20250205_031511.zos.pax.Z)|A command-line tool for GitLab|
| [fq](https://github.com/zopencommunity/fqport)|Skipped|N/A|[STABLE_fq_3012](https://github.com/zopencommunity/fqport/releases/download/STABLE_fqport_3012/fq-master.20250131_063249.zos.pax.Z)|A tool for working with binary formats|
| [murex](https://github.com/zopencommunity/murexport)|Skipped|N/A|[STABLE_murex_2265](https://github.com/zopencommunity/murexport/releases/download/STABLE_murexport_2265/murex-DEV.20240515_162657.zos.pax.Z)|A text editor|
| [cjson](https://github.com/zopencommunity/cjsonport)|Skipped|N/A|[STABLE_cjson_3050](https://github.com/zopencommunity/cjsonport/releases/download/STABLE_cjsonport_3050/cjson-heads.v1.7.18.20250131_112202.zos.pax.Z)|A C JSON library|
| [make](https://github.com/zopencommunity/makeport)|Green|100.0%|[STABLE_make_2925](https://github.com/zopencommunity/makeport/releases/download/STABLE_makeport_2925/make-4.4.1.20250130_121444.zos.pax.Z)|A build automation tool|
| [pkgconfig](https://github.com/zopencommunity/pkgconfigport)|Green|100.0%|[STABLE_pkgconfig_2994](https://github.com/zopencommunity/pkgconfigport/releases/download/STABLE_pkgconfigport_2994/pkgconfig-DEV.20250131_042705.zos.pax.Z)|A system for managing library dependencies|
| [gperf](https://github.com/zopencommunity/gperfport)|Green|100.0%|[STABLE_gperf_2965](https://github.com/zopencommunity/gperfport/releases/download/STABLE_gperfport_2965/gperf-3.1.20250131_010012.zos.pax.Z)|A perfect hash function generator|
| [flex](https://github.com/zopencommunity/flexport)|Green|100.0%|[STABLE_flex_2969](https://github.com/zopencommunity/flexport/releases/download/STABLE_flexport_2969/flex-2.6.4.20250131_012201.zos.pax.Z)|A text-based file editor|
| [cscope](https://github.com/zopencommunity/cscopeport)|Green|100.0%|[STABLE_cscope_2966](https://github.com/zopencommunity/cscopeport/releases/download/STABLE_cscopeport_2966/cscope-15.9.20250131_010812.zos.pax.Z)|A source code analyzer|
| [comp_go](https://github.com/zopencommunity/comp_goport)|Green|100.0%|[STABLE_comp_go_2668](https://github.com/zopencommunity/comp_goport/releases/download/STABLE_comp_goport_2668/comp_go-DEV.20241028_222012.zos.pax.Z)|A code completion tool for Go|
| [comp_clang](https://github.com/zopencommunity/comp_clangport)|Green|100.0%|[STABLE_comp_clang_2659](https://github.com/zopencommunity/comp_clangport/releases/download/STABLE_comp_clangport_2659/comp_clang-DEV.20241028_215503.zos.pax.Z)|A code completion tool for Clang compiler|
| [comp_xlclang](https://github.com/zopencommunity/comp_xlclangport)|Green|100.0%|[STABLE_comp_xlclang_2660](https://github.com/zopencommunity/comp_xlclangport/releases/download/STABLE_comp_xlclangport_2660/comp_xlclang-DEV.20241028_215548.zos.pax.Z)|A code completion tool for XL C/C++ compiler|
| [direnv](https://github.com/zopencommunity/direnvport)|Green|100.0%|[STABLE_direnv_2968](https://github.com/zopencommunity/direnvport/releases/download/STABLE_direnvport_2968/direnv-heads.v2.34.0.20250131_011713.zos.pax.Z)||
| [bump](https://github.com/zopencommunity/bumpport)|Green|100.0%|[STABLE_bump_3001](https://github.com/zopencommunity/bumpport/releases/download/STABLE_bumpport_3001/bump-master.20250131_060329.zos.pax.Z)|A version control and update tool|
| [gn](https://github.com/zopencommunity/gnport)|Green|100.0%|[DEV_gn_2827](https://github.com/zopencommunity/gnport/releases/download/DEV_gnport_2827/gn-main.20250117_125041.zos.pax.Z)|A build tool|
| [libevent](https://github.com/zopencommunity/libeventport)|Green|100.0%|[STABLE_libevent_2183](https://github.com/zopencommunity/libeventport/releases/download/STABLE_libeventport_2183/libevent-2.1.12-stable.20240307_140629.zos.pax.Z)|An event notification library|
| [tmux](https://github.com/zopencommunity/tmuxport)|Green|100.0%|[STABLE_tmux_2410](https://github.com/zopencommunity/tmuxport/releases/download/STABLE_tmuxport_2410/tmux-heads.3.3a.20240825_024243.zos.pax.Z)|A terminal multiplexer|
| [zlib-ng](https://github.com/zopencommunity/zlib-ngport)|Green|100.0%|[DEV_zlib-ng_2087](https://github.com/zopencommunity/zlib-ngport/releases/download/DEV_zlib-ngport_2087/zlib-ng-develop.20240205_031127.zos.pax.Z)|A compression library|
| [popt](https://github.com/zopencommunity/poptport)|Green|100.0%|[STABLE_popt_3022](https://github.com/zopencommunity/poptport/releases/download/STABLE_poptport_3022/popt-master.20250131_090110.zos.pax.Z)|A command-line argument parser|
| [libgpgme](https://github.com/zopencommunity/libgpgmeport)|Green|100.0%|[STABLE_libgpgme_2181](https://github.com/zopencommunity/libgpgmeport/releases/download/STABLE_libgpgmeport_2181/gpgme-1.23.2.20240307_085012.zos.pax.Z)|A library for accessing cryptographic functions|
| [lpeg](https://github.com/zopencommunity/lpegport)|Green|100.0%|[STABLE_lpeg_3028](https://github.com/zopencommunity/lpegport/releases/download/STABLE_lpegport_3028/lpeg-1.1.0.20250131_100049.zos.pax.Z)|A pattern-matching library for Lua|
| [luv](https://github.com/zopencommunity/luvport)|Green|100.0%|[STABLE_luv_3040](https://github.com/zopencommunity/luvport/releases/download/STABLE_luvport_3040/luv-master.20250131_103130.zos.pax.Z)|Lua bindings for libuv|
| [check_clang](https://github.com/zopencommunity/check_clangport)|Green|100.0%|[STABLE_check_clang_3033](https://github.com/zopencommunity/check_clangport/releases/download/STABLE_check_clangport_3033/comp_clang-DEV.20250131_100747.zos.pax.Z)|A script to check for the existence of Clang|
| [check_xlclang](https://github.com/zopencommunity/check_xlclangport)|Green|100.0%|[STABLE_check_xlclang_3046](https://github.com/zopencommunity/check_xlclangport/releases/download/STABLE_check_xlclangport_3046/check_xlclang-DEV.20250131_112008.zos.pax.Z)|A script to check for the existence of XL C/C++ compiler|
| [check_go](https://github.com/zopencommunity/check_goport)|Green|100.0%|[STABLE_check_go_3048](https://github.com/zopencommunity/check_goport/releases/download/STABLE_check_goport_3048/check_go-DEV.20250131_112325.zos.pax.Z)|A script to check for the existence of Go|
| [cronie](https://github.com/zopencommunity/cronieport)|Green|100.0%|[DEV_cronie_3087](https://github.com/zopencommunity/cronieport/releases/download/DEV_cronieport_3087/cronie-master.20250206_213640.zos.pax.Z)|A cron daemon|
| [libdio](https://github.com/zopencommunity/libdioport)|Green|100.0%|[DEV_libdio_3036](https://github.com/zopencommunity/libdioport/releases/download/DEV_libdioport_3036/libdio-main.20250131_101636.zos.pax.Z)|A dataset I/O library|
| [bash-completion](https://github.com/zopencommunity/bash-completionport)|Green|100.0%|[STABLE_bash-completion_3043](https://github.com/zopencommunity/bash-completionport/releases/download/STABLE_bash-completionport_3043/bashcompletion-DEV.20250131_110235.zos.pax.Z)||
| [dos2unix](https://github.com/zopencommunity/dos2unixport)|Blue|99.1%|[STABLE_dos2unix_3031](https://github.com/zopencommunity/dos2unixport/releases/download/STABLE_dos2unixport_3031/dos2unix-7.5.2.20250131_100352.zos.pax.Z)|A tool for converting DOS/Windows text files to Unix format|
| [git](https://github.com/zopencommunity/gitport)|Blue|96.7%|[STABLE_git_3023](https://github.com/zopencommunity/gitport/releases/download/STABLE_gitport_3023/git-heads.v2.48.1.20250131_080517.zos.pax.Z)|The Git version control system|
| [re2c](https://github.com/zopencommunity/re2cport)|Blue|83.3%|[STABLE_re2c_3070](https://github.com/zopencommunity/re2cport/releases/download/STABLE_re2cport_3070/re2c-4.0.2.20250205_032000.zos.pax.Z)|A lexer generator for creating lexers|
| [conan](https://github.com/zopencommunity/conanport)|Yellow|54.0%|[STABLE_conan_3047](https://github.com/zopencommunity/conanport/releases/download/STABLE_conanport_3047/conan-heads.2.9.1.20250131_110229.zos.pax.Z)|C/C++ Package Manager tool|
| [byacc](https://github.com/zopencommunity/byaccport)|Red|45.6%|[STABLE_byacc_2982](https://github.com/zopencommunity/byaccport/releases/download/STABLE_byaccport_2982/byacc-20240109.20250131_042653.zos.pax.Z)|A parser generator compatible with Yacc|
| [meson](https://github.com/zopencommunity/mesonport)|Red|33.3%|[STABLE_meson_3029](https://github.com/zopencommunity/mesonport/releases/download/STABLE_mesonport_3029/meson-heads.1.6.0.20250131_092909.zos.pax.Z)|A build system|
</div>

<div class="table-category" data-category="devops">

## Devops <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [terraform](https://github.com/zopencommunity/terraformport)|Skipped|N/A|[STABLE_terraform_2834](https://github.com/zopencommunity/terraformport/releases/download/STABLE_terraformport_2834/terraform-heads.v1.7.4.20250122_183012.zos.pax.Z)|An infrastructure as code tool|
| [lazygit](https://github.com/zopencommunity/lazygitport)|Skipped|N/A|[STABLE_lazygit_2148](https://github.com/zopencommunity/lazygitport/releases/download/STABLE_lazygitport_2148/lazygit-master.20240221_041017.zos.pax.Z)|A Git client|
| [godsect](https://github.com/zopencommunity/godsectport)|Skipped|N/A|[STABLE_godsect_2874](https://github.com/zopencommunity/godsectport/releases/download/STABLE_godsectport_2874/godsect-main.20250129_141744.zos.pax.Z)|A code security scanner|
| [grafana](https://github.com/zopencommunity/grafanaport)|Skipped|N/A|[STABLE_grafana_2268](https://github.com/zopencommunity/grafanaport/releases/download/STABLE_grafanaport_2268/grafana-heads.v11.1.3.20240731_150543.zos.pax.Z)|An open-source observability and data visualization platform|
| [prometheus](https://github.com/zopencommunity/prometheusport)|Green|100.0%|[STABLE_prometheus_2271](https://github.com/zopencommunity/prometheusport/releases/download/STABLE_prometheusport_2271/prometheus-heads.v2.45.5.20240710_113009.zos.pax.Z)|A monitoring system|
| [logrotate](https://github.com/zopencommunity/logrotateport)|Green|100.0%|[STABLE_logrotate_3086](https://github.com/zopencommunity/logrotateport/releases/download/STABLE_logrotateport_3086/logrotate-main.20250206_160826.zos.pax.Z)|A log rotation tool|
| [parse-gotest](https://github.com/zopencommunity/parse-gotestport)|Green|100.0%|[STABLE_parse-gotest_2364](https://github.com/zopencommunity/parse-gotestport/releases/download/STABLE_parse-gotestport_2364/parse-gotest-heads.v0.1.1.20240721_042053.zos.pax.Z)|A Go test parser|
| [git-lfs](https://github.com/zopencommunity/git-lfsport)|Blue|94.1%|[STABLE_git-lfs_2858](https://github.com/zopencommunity/git-lfsport/releases/download/STABLE_git-lfsport_2858/git-lfs.20250124_120556.zos.pax.Z)|A Git extension for versioning large files|
| [conan](https://github.com/zopencommunity/conanport)|Yellow|54.0%|[STABLE_conan_3047](https://github.com/zopencommunity/conanport/releases/download/STABLE_conanport_3047/conan-heads.2.9.1.20250131_110229.zos.pax.Z)|C/C++ Package Manager tool|
</div>

<div class="table-category" data-category="documentation">

## Documentation <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [xmlto](https://github.com/zopencommunity/xmltoport)|Green|100.0%|[STABLE_xmlto_3007](https://github.com/zopencommunity/xmltoport/releases/download/STABLE_xmltoport_3007/xmlto-0.0.28.20250131_062354.zos.pax.Z)|A tool for converting XML documents to other formats|
| [shdoc](https://github.com/zopencommunity/shdocport)|Green|100.0%|[DEV_shdoc_2900](https://github.com/zopencommunity/shdocport/releases/download/DEV_shdocport_2900/shdoc-1.2.20250129_185016.zos.pax.Z)|A documentation generator for shell scripts|
| [doxygen](https://github.com/zopencommunity/doxygenport)|Blue|98.1%|[STABLE_doxygen_3090](https://github.com/zopencommunity/doxygenport/releases/download/STABLE_doxygenport_3090/doxygen-heads.Release_1_13_2.20250209_171213.zos.pax.Z)|A documentation generator|
| [groff](https://github.com/zopencommunity/groffport)|Blue|97.0%|[STABLE_groff_2996](https://github.com/zopencommunity/groffport/releases/download/STABLE_groffport_2996/groff-1.23.0.20250131_051659.zos.pax.Z)|A text formatting system|
</div>

<div class="table-category" data-category="editor">

## Editor <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [vim](https://github.com/zopencommunity/vimport)|Skipped|N/A|[STABLE_vim_3052](https://github.com/zopencommunity/vimport/releases/download/STABLE_vimport_3052/vim-heads.v9.1.1016.20250131_113109.zos.pax.Z)|A TUI editor|
| [nano](https://github.com/zopencommunity/nanoport)|Skipped|N/A|[STABLE_nano_2918](https://github.com/zopencommunity/nanoport/releases/download/STABLE_nanoport_2918/nano-8.1.20250130_115829.zos.pax.Z)|A simple text editor for console environments|
| [emacs](https://github.com/zopencommunity/emacsport)|Skipped|N/A|[STABLE_emacs_2999](https://github.com/zopencommunity/emacsport/releases/download/STABLE_emacsport_2999/emacs-29.4.20250131_050216.zos.pax.Z)|A text editor|
| [lazygit](https://github.com/zopencommunity/lazygitport)|Skipped|N/A|[STABLE_lazygit_2148](https://github.com/zopencommunity/lazygitport/releases/download/STABLE_lazygitport_2148/lazygit-master.20240221_041017.zos.pax.Z)|A Git client|
| [ctags](https://github.com/zopencommunity/ctagsport)|Green|100.0%|[STABLE_ctags_3013](https://github.com/zopencommunity/ctagsport/releases/download/STABLE_ctagsport_3013/ctags-heads.v6.1.0.20250131_062242.zos.pax.Z)|A code indexing tool|
| [neovim](https://github.com/zopencommunity/neovimport)|Green|100.0%|[STABLE_neovim_3083](https://github.com/zopencommunity/neovimport/releases/download/STABLE_neovimport_3083/neovim-heads.v0.10.4.20250206_134238.zos.pax.Z)|A text editor|
| [hexcurse](https://github.com/zopencommunity/hexcurseport)|Green|100.0%|[STABLE_hexcurse_3092](https://github.com/zopencommunity/hexcurseport/releases/download/STABLE_hexcurseport_3092/hexcurse-ng-heads.v1.70.0.20250210_000458.zos.pax.Z)|Hexcurse is a ncurses-based console hexeditor written in C|
| [dos2unix](https://github.com/zopencommunity/dos2unixport)|Blue|99.1%|[STABLE_dos2unix_3031](https://github.com/zopencommunity/dos2unixport/releases/download/STABLE_dos2unixport_3031/dos2unix-7.5.2.20250131_100352.zos.pax.Z)|A tool for converting DOS/Windows text files to Unix format|
| [git-lfs](https://github.com/zopencommunity/git-lfsport)|Blue|94.1%|[STABLE_git-lfs_2858](https://github.com/zopencommunity/git-lfsport/releases/download/STABLE_git-lfsport_2858/git-lfs.20250124_120556.zos.pax.Z)|A Git extension for versioning large files|
</div>

<div class="table-category" data-category="graphics">

## Graphics <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [fx](https://github.com/zopencommunity/fxport)|Skipped|N/A|[STABLE_fx_2577](https://github.com/zopencommunity/fxport/releases/download/STABLE_fxport_2577/fx-heads.34.0.0.20241002_034900.zos.pax.Z)|A functional programming language|
| [prometheus](https://github.com/zopencommunity/prometheusport)|Green|100.0%|[STABLE_prometheus_2271](https://github.com/zopencommunity/prometheusport/releases/download/STABLE_prometheusport_2271/prometheus-heads.v2.45.5.20240710_113009.zos.pax.Z)|A monitoring system|
| [dialog](https://github.com/zopencommunity/dialogport)|Green|100.0%|[STABLE_dialog_3045](https://github.com/zopencommunity/dialogport/releases/download/STABLE_dialogport_3045/dialog-1.3-20240619.20250131_111048.zos.pax.Z)|A library for creating dialog boxes|
</div>

<div class="table-category" data-category="language">

## Language <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [tcl](https://github.com/zopencommunity/tclport)|Skipped|N/A|[STABLE_tcl_2992](https://github.com/zopencommunity/tclport/releases/download/STABLE_tclport_2992/tcl-core8.6.13-src.20250131_051127.zos.pax.Z)|The Tcl scripting language|
| [groovy](https://github.com/zopencommunity/groovyport)|Skipped|N/A|[STABLE_groovy_2053](https://github.com/zopencommunity/groovyport/releases/download/STABLE_groovyport_2053/groovy-DEV.20240129_101738.zos.pax.Z)|A scripting language for the Java platform|
| [lua](https://github.com/zopencommunity/luaport)|Green|100.0%|[STABLE_lua_3084](https://github.com/zopencommunity/luaport/releases/download/STABLE_luaport_3084/lua-5.4.7.20250206_153403.zos.pax.Z)|A lightweight, embeddable scripting language|
| [python](https://github.com/zopencommunity/pythonport)|Green|100.0%|[STABLE_python_2764](https://github.com/zopencommunity/pythonport/releases/download/STABLE_pythonport_2764/python-DEV.20241205_215241.zos.pax.Z)|A port of the Python programming language|
| [java](https://github.com/zopencommunity/javaport)|Green|100.0%|[STABLE_java_2643](https://github.com/zopencommunity/javaport/releases/download/STABLE_javaport_2643/java-DEV.20241028_211549.zos.pax.Z)|The IBM implementation of the Java programming language|
| [my_basic](https://github.com/zopencommunity/my_basicport)|Green|100.0%|[DEV_my_basic_3030](https://github.com/zopencommunity/my_basicport/releases/download/DEV_my_basicport_3030/my_basic-master.20250131_100320.zos.pax.Z)|A BASIC interpreter|
| [check_python](https://github.com/zopencommunity/check_pythonport)|Green|100.0%|[STABLE_check_python_3088](https://github.com/zopencommunity/check_pythonport/releases/download/STABLE_check_pythonport_3088/check_python-DEV.20250206_214926.zos.pax.Z)|A script to check for the existence of Python|
| [check_java](https://github.com/zopencommunity/check_javaport)|Green|100.0%|[STABLE_check_java_3044](https://github.com/zopencommunity/check_javaport/releases/download/STABLE_check_javaport_3044/check_java-DEV.20250131_110841.zos.pax.Z)|A script to check for the existence of Java|
</div>

<div class="table-category" data-category="library">

## Library <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [zusage](https://github.com/zopencommunity/zusageport)|Skipped|N/A|[DEV_zusage_3093](https://github.com/zopencommunity/zusageport/releases/download/DEV_zusageport_3093/zusage-DEV.20250210_164009.zos.pax.Z)|Usage analytics library|
| [expat](https://github.com/zopencommunity/expatport)|Green|100.0%|[STABLE_expat_2953](https://github.com/zopencommunity/expatport/releases/download/STABLE_expatport_2953/expat-2.5.0.20250130_225430.zos.pax.Z)|A library for parsing XML content|
| [zoslib](https://github.com/zopencommunity/zoslibport)|Green|100.0%|[STABLE_zoslib_3085](https://github.com/zopencommunity/zoslibport/releases/download/STABLE_zoslibport_3085/zoslib-zopen2.20250206_160708.zos.pax.Z)|A library used by z/OS Open Tools|
| [libgdbm](https://github.com/zopencommunity/libgdbmport)|Green|100.0%|[STABLE_libgdbm_3066](https://github.com/zopencommunity/libgdbmport/releases/download/STABLE_libgdbmport_3066/gdbm-1.24.20250205_031526.zos.pax.Z)|A library for managing database functions|
| [libpipeline](https://github.com/zopencommunity/libpipelineport)|Green|100.0%|[STABLE_libpipeline_2957](https://github.com/zopencommunity/libpipelineport/releases/download/STABLE_libpipelineport_2957/libpipeline-1.5.7.20250130_223928.zos.pax.Z)|A library for managing pipelines of processes|
| [gnulib](https://github.com/zopencommunity/gnulibport)|Green|100.0%|[STABLE_gnulib_2993](https://github.com/zopencommunity/gnulibport/releases/download/STABLE_gnulibport_2993/gnulib-master.20250131_051808.zos.pax.Z)|A library containing common functions used in GNU software|
| [sqlite](https://github.com/zopencommunity/sqliteport)|Green|100.0%|[STABLE_sqlite_2990](https://github.com/zopencommunity/sqliteport/releases/download/STABLE_sqliteport_2990/sqlite-autoconf-3480000.20250131_045743.zos.pax.Z)|A lightweight embedded SQL database engine|
| [libiconv](https://github.com/zopencommunity/libiconvport)|Green|100.0%|[STABLE_libiconv_2846](https://github.com/zopencommunity/libiconvport/releases/download/STABLE_libiconvport_2846/libiconv-1.17.20250123_222430.zos.pax.Z)|A library for character set conversion|
| [libxslt](https://github.com/zopencommunity/libxsltport)|Green|100.0%|[STABLE_libxslt_3067](https://github.com/zopencommunity/libxsltport/releases/download/STABLE_libxsltport_3067/libxslt-1.1.42.20250204_221638.zos.pax.Z)|A library for processing XSLT stylesheets|
| [libgpgerror](https://github.com/zopencommunity/libgpgerrorport)|Green|100.0%|[STABLE_libgpgerror_2987](https://github.com/zopencommunity/libgpgerrorport/releases/download/STABLE_libgpgerrorport_2987/libgpgerror-DEV.20250131_045012.zos.pax.Z)|A library for handling errors|
| [libgcrypt](https://github.com/zopencommunity/libgcryptport)|Green|100.0%|[STABLE_libgcrypt_2974](https://github.com/zopencommunity/libgcryptport/releases/download/STABLE_libgcryptport_2974/libgcrypt-1.11.0.20250131_033856.zos.pax.Z)|A general-purpose cryptographic library|
| [libassuan](https://github.com/zopencommunity/libassuanport)|Green|100.0%|[STABLE_libassuan_2949](https://github.com/zopencommunity/libassuanport/releases/download/STABLE_libassuanport_2949/libassuan-3.0.1.20250130_211612.zos.pax.Z)|A library for the Assuan protocol, used for IPC between GnuPG components|
| [libksba](https://github.com/zopencommunity/libksbaport)|Green|100.0%|[STABLE_libksba_2937](https://github.com/zopencommunity/libksbaport/releases/download/STABLE_libksbaport_2937/libksba-1.6.7.20250130_130855.zos.pax.Z)|A library for working with X.509 certificates and other cryptographic objects|
| [librdkafka](https://github.com/zopencommunity/librdkafkaport)|Green|100.0%|[STABLE_librdkafka_2997](https://github.com/zopencommunity/librdkafkaport/releases/download/STABLE_librdkafkaport_2997/librdkafka-HEAD.20250131_055226.zos.pax.Z)|A high-performance C/C++ library for Apache Kafka|
| [oniguruma](https://github.com/zopencommunity/onigurumaport)|Green|100.0%|[STABLE_oniguruma_3060](https://github.com/zopencommunity/onigurumaport/releases/download/STABLE_onigurumaport_3060/oniguruma-heads.v6.9.10.20250203_150139.zos.pax.Z)|A regular expression library|
| [libbsd](https://github.com/zopencommunity/libbsdport)|Green|100.0%|[STABLE_libbsd_2665](https://github.com/zopencommunity/libbsdport/releases/download/STABLE_libbsdport_2665/libbsd-main.20241028_215810.zos.pax.Z)|A library providing common BSD functions|
| [jansson](https://github.com/zopencommunity/janssonport)|Green|100.0%|[STABLE_jansson_2998](https://github.com/zopencommunity/janssonport/releases/download/STABLE_janssonport_2998/jansson-master.20250131_054849.zos.pax.Z)|A C library for encoding, decoding, and manipulating JSON data|
| [protobuf](https://github.com/zopencommunity/protobufport)|Green|100.0%|[STABLE_protobuf_3061](https://github.com/zopencommunity/protobufport/releases/download/STABLE_protobufport_3061/protobuf-heads.v29.3.20250203_154441.zos.pax.Z)|A protocol buffer compiler|
| [avro-c-lib](https://github.com/zopencommunity/avro-c-libport)|Green|100.0%|[STABLE_avro-c-lib_3003](https://github.com/zopencommunity/avro-c-libport/releases/download/STABLE_avro-c-libport_3003/avro-c-packaging-master.20250131_060659.zos.pax.Z)|A data serialization framework|
| [zedc_ascii](https://github.com/zopencommunity/zedc_asciiport)|Green|100.0%|[DEV_zedc_ascii_3078](https://github.com/zopencommunity/zedc_asciiport/releases/download/DEV_zedc_asciiport_3078/zedc_ascii-DEV.20250205_142114.zos.pax.Z)|Modified version of zlib for HW optimization|
| [libxml2](https://github.com/zopencommunity/libxml2port)|Blue|100.0%|[STABLE_libxml2_3010](https://github.com/zopencommunity/libxml2port/releases/download/STABLE_libxml2port_3010/libxml2-2.9.12.20250131_055913.zos.pax.Z)|A library for parsing XML content|
| [libuv](https://github.com/zopencommunity/libuvport)|Blue|94.4%|[STABLE_libuv_3037](https://github.com/zopencommunity/libuvport/releases/download/STABLE_libuvport_3037/libuv-heads.v1.48.0.20250131_083955.zos.pax.Z)|An asynchronous I/O library|
| [libpcre](https://github.com/zopencommunity/libpcreport)|Blue|80.0%|[STABLE_libpcre_2845](https://github.com/zopencommunity/libpcreport/releases/download/STABLE_libpcreport_2845/pcre-8.45.20250123_222319.zos.pax.Z)|A regular expression library|
| [libpcre2](https://github.com/zopencommunity/libpcre2port)|Yellow|66.7%|[STABLE_libpcre2_2972](https://github.com/zopencommunity/libpcre2port/releases/download/STABLE_libpcre2port_2972/pcre2-10.42.20250131_031755.zos.pax.Z)|A regular expression library|
</div>

<div class="table-category" data-category="networking">

## Networking <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [nats](https://github.com/zopencommunity/natsport)|Skipped|N/A|[STABLE_NATS_3027](https://github.com/zopencommunity/natsport/releases/download/STABLE_NATSport_3027/nats-DEV.20250131_095445.zos.pax.Z)|A cloud-native messaging system|
| [githubcli](https://github.com/zopencommunity/githubcliport)|Skipped|N/A|[DEV_githubcli_3074](https://github.com/zopencommunity/githubcliport/releases/download/DEV_githubcliport_3074/githubcli-DEV.20250205_031236.zos.pax.Z)|A command-line tool for GitHub|
| [caddy](https://github.com/zopencommunity/caddyport)|Skipped|N/A|[STABLE_caddy_2215](https://github.com/zopencommunity/caddyport/releases/download/STABLE_caddyport_2215/caddy-DEV.20240409_161941.zos.pax.Z)|A web server|
| [nghttp2](https://github.com/zopencommunity/nghttp2port)|Green|100.0%|[STABLE_nghttp2_3063](https://github.com/zopencommunity/nghttp2port/releases/download/STABLE_nghttp2port_3063/nghttp2-1.64.0.20250205_031626.zos.pax.Z)|An HTTP/2 implementation|
| [wget](https://github.com/zopencommunity/wgetport)|Red|20.3%|[STABLE_wget_3076](https://github.com/zopencommunity/wgetport/releases/download/STABLE_wgetport_3076/wget-1.25.0.20250205_033712.zos.pax.Z)|A utility for retrieving files from the web|
</div>

<div class="table-category" data-category="security">

## Security <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [sshpass](https://github.com/zopencommunity/sshpassport)|Skipped|N/A|[STABLE_sshpass_2893](https://github.com/zopencommunity/sshpassport/releases/download/STABLE_sshpassport_2893/sshpass-1.10.20250129_183120.zos.pax.Z)|A secure shell client|
| [osv-scanner](https://github.com/zopencommunity/osv-scannerport)|Skipped|N/A|[STABLE_osv-scanner_2133](https://github.com/zopencommunity/osv-scannerport/releases/download/STABLE_osv-scannerport_2133/osv-scanner-heads.v1.6.2.20240214_174547.zos.pax.Z)|Vulnerability scanner written in Go which uses the data provided by https://osv.dev|
| [cppcheck](https://github.com/zopencommunity/cppcheckport)|Skipped|N/A|[STABLE_cppcheck_3015](https://github.com/zopencommunity/cppcheckport/releases/download/STABLE_cppcheckport_3015/cppcheck-heads.2.14.2.20250131_074438.zos.pax.Z)|A static analysis tool for C/C++ code|
| [npth](https://github.com/zopencommunity/npthport)|Green|100.0%|[STABLE_npth_2799](https://github.com/zopencommunity/npthport/releases/download/STABLE_npthport_2799/npth-1.8.20250107_210046.zos.pax.Z)|A portable threading library|
| [libgpgerror](https://github.com/zopencommunity/libgpgerrorport)|Green|100.0%|[STABLE_libgpgerror_2987](https://github.com/zopencommunity/libgpgerrorport/releases/download/STABLE_libgpgerrorport_2987/libgpgerror-DEV.20250131_045012.zos.pax.Z)|A library for handling errors|
| [libgcrypt](https://github.com/zopencommunity/libgcryptport)|Green|100.0%|[STABLE_libgcrypt_2974](https://github.com/zopencommunity/libgcryptport/releases/download/STABLE_libgcryptport_2974/libgcrypt-1.11.0.20250131_033856.zos.pax.Z)|A general-purpose cryptographic library|
| [libassuan](https://github.com/zopencommunity/libassuanport)|Green|100.0%|[STABLE_libassuan_2949](https://github.com/zopencommunity/libassuanport/releases/download/STABLE_libassuanport_2949/libassuan-3.0.1.20250130_211612.zos.pax.Z)|A library for the Assuan protocol, used for IPC between GnuPG components|
| [libksba](https://github.com/zopencommunity/libksbaport)|Green|100.0%|[STABLE_libksba_2937](https://github.com/zopencommunity/libksbaport/releases/download/STABLE_libksbaport_2937/libksba-1.6.7.20250130_130855.zos.pax.Z)|A library for working with X.509 certificates and other cryptographic objects|
| [openssh](https://github.com/zopencommunity/opensshport)|Green|100.0%|[STABLE_openssh_2748](https://github.com/zopencommunity/opensshport/releases/download/STABLE_opensshport_2748/openssh-9.9p1.20241120_165536.zos.pax.Z)|A suite of secure networking utilities|
| [pinentry](https://github.com/zopencommunity/pinentryport)|Green|100.0%|[STABLE_pinentry_2979](https://github.com/zopencommunity/pinentryport/releases/download/STABLE_pinentryport_2979/pinentry-1.3.1.20250131_041514.zos.pax.Z)|A secure passphrase entry utility|
| [ntbtls](https://github.com/zopencommunity/ntbtlsport)|Green|100.0%|[STABLE_ntbtls_3002](https://github.com/zopencommunity/ntbtlsport/releases/download/STABLE_ntbtlsport_3002/ntbtls-0.3.2.20250131_060937.zos.pax.Z)|A lightweight TLS 1.2 implementation|
| [libmd](https://github.com/zopencommunity/libmdport)|Green|100.0%|[STABLE_libmd_3000](https://github.com/zopencommunity/libmdport/releases/download/STABLE_libmdport_3000/libmd-1.1.0.20250131_060012.zos.pax.Z)|A library for computing message digests|
| [libsasl2](https://github.com/zopencommunity/libsasl2port)|Green|100.0%|[STABLE_libsasl2_2311](https://github.com/zopencommunity/libsasl2port/releases/download/STABLE_libsasl2port_2311/cyrus-sasl-master.20240624_052635.zos.pax.Z)|A SASL library|
| [gpg](https://github.com/zopencommunity/gpgport)|Blue|93.2%|[STABLE_gpg_2977](https://github.com/zopencommunity/gpgport/releases/download/STABLE_gpgport_2977/gnupg-2.5.3.20250131_033744.zos.pax.Z)|A free software implementation of the GNU Privacy Guard|
</div>

<div class="table-category" data-category="shell">

## Shell <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [powerlinego](https://github.com/zopencommunity/powerlinegoport)|Skipped|N/A|[STABLE_powerlinego_2978](https://github.com/zopencommunity/powerlinegoport/releases/download/STABLE_powerlinegoport_2978/powerlinego-DEV.20250131_041610.zos.pax.Z)|A low-latency prompt for your shell|
| [bash-completion](https://github.com/zopencommunity/bash-completionport)|Green|100.0%|[STABLE_bash-completion_3043](https://github.com/zopencommunity/bash-completionport/releases/download/STABLE_bash-completionport_3043/bashcompletion-DEV.20250131_110235.zos.pax.Z)||
| [bash](https://github.com/zopencommunity/bashport)|Blue|80.5%|[STABLE_bash_2848](https://github.com/zopencommunity/bashport/releases/download/STABLE_bashport_2848/bash-5.2.37.20250123_235235.zos.pax.Z)|The Bourne Again shell|
</div>

<div class="table-category" data-category="source_control">

## Source_Control <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [gitlab-runner](https://github.com/zopencommunity/gitlab-runnerport)|Skipped|N/A|[STABLE_gitlab-runner_2597](https://github.com/zopencommunity/gitlab-runnerport/releases/download/STABLE_gitlab-runnerport_2597/gitlab-runner.20241002_044313.zos.pax.Z)|A GitLab Runner|
| [git-extras](https://github.com/zopencommunity/git-extrasport)|Skipped|N/A|[STABLE_git-extras_3041](https://github.com/zopencommunity/git-extrasport/releases/download/STABLE_git-extrasport_3041/gitextras-DEV.20250131_105732.zos.pax.Z)||
| [tig](https://github.com/zopencommunity/tigport)|Green|100.0%|[STABLE_tig_3005](https://github.com/zopencommunity/tigport/releases/download/STABLE_tigport_3005/tig-2.5.9.20250131_061802.zos.pax.Z)|A text-mode interface for Git|
| [git](https://github.com/zopencommunity/gitport)|Blue|96.7%|[STABLE_git_3023](https://github.com/zopencommunity/gitport/releases/download/STABLE_gitport_3023/git-heads.v2.48.1.20250131_080517.zos.pax.Z)|The Git version control system|
</div>

<div class="table-category" data-category="uncategorized">

## Uncategorized <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [llamacpp](https://github.com/zopencommunity/llamacppport)|Skipped|N/A|[STABLE_llamacpp_2013](https://github.com/zopencommunity/llamacppport/releases/download/STABLE_llamacppport_2013/llamacpp-master.20240124_170742.zos.pax.Z)|A C++ library for writing high-performance network applications|
| [ncurses](https://github.com/zopencommunity/ncursesport)|Green|100.0%|[STABLE_ncurses_2956](https://github.com/zopencommunity/ncursesport/releases/download/STABLE_ncursesport_2956/ncurses-6.5.20250130_230916.zos.pax.Z)|Library for ncurses, a terminal screen handling library|
| [gzip](https://github.com/zopencommunity/gzipport)|Green|100.0%|[STABLE_gzip_3082](https://github.com/zopencommunity/gzipport/releases/download/STABLE_gzipport_3082/gzip-1.13.20250205_093947.zos.pax.Z)|Library for handling gzip compressed files|
| [zlib](https://github.com/zopencommunity/zlibport)|Green|100.0%|[STABLE_zlib_3071](https://github.com/zopencommunity/zlibport/releases/download/STABLE_zlibport_3071/zlib-heads.v1.3.1.20250205_034023.zos.pax.Z)|A data compression library|
| [less](https://github.com/zopencommunity/lessport)|Green|100.0%|[STABLE_less_2954](https://github.com/zopencommunity/lessport/releases/download/STABLE_lessport_2954/less-heads.v668.20250130_225718.zos.pax.Z)|A text pager|
| [help2man](https://github.com/zopencommunity/help2manport)|Green|100.0%|[STABLE_help2man_2875](https://github.com/zopencommunity/help2manport/releases/download/STABLE_help2manport_2875/help2man-1.49.3.20250129_141844.zos.pax.Z)|A tool for converting manual pages to other formats|
| [xxhash](https://github.com/zopencommunity/xxhashport)|Green|100.0%|[STABLE_xxhash_1993](https://github.com/zopencommunity/xxhashport/releases/download/STABLE_xxhashport_1993/xxHash-0.8.2.20240123_100914.zos.pax.Z)|A fast hash function library|
| [zstd](https://github.com/zopencommunity/zstdport)|Green|100.0%|[STABLE_zstd_2041](https://github.com/zopencommunity/zstdport/releases/download/STABLE_zstdport_2041/zstd-1.5.5.20240126_215521.zos.pax.Z)|A compression algorithm|
| [lz4](https://github.com/zopencommunity/lz4port)|Green|100.0%|[STABLE_lz4_1936](https://github.com/zopencommunity/lz4port/releases/download/STABLE_lz4port_1936/lz4-1.9.4.20240104_082651.zos.pax.Z)|A compression algorithm|
| [jq](https://github.com/zopencommunity/jqport)|Green|100.0%|[STABLE_jq_3058](https://github.com/zopencommunity/jqport/releases/download/STABLE_jqport_3058/jq-1.7.1.20250202_085803.zos.pax.Z)|A port of the JQ command-line JSON processor|
| [php](https://github.com/zopencommunity/phpport)|Green|100.0%|[STABLE_php_1996](https://github.com/zopencommunity/phpport/releases/download/STABLE_phpport_1996/php-8.2.13.20240123_152440.zos.pax.Z)|A programming language|
| [lynx](https://github.com/zopencommunity/lynxport)|Green|100.0%|[STABLE_lynx_2016](https://github.com/zopencommunity/lynxport/releases/download/STABLE_lynxport_2016/lynx-2.8.9.20240124_173303.zos.pax.Z)|A text-based web browser|
| [duckdb](https://github.com/zopencommunity/duckdbport)|Green|100.0%|[STABLE_duckdb_1986](https://github.com/zopencommunity/duckdbport/releases/download/STABLE_duckdbport_1986/duckdb-main.20240122_143549.zos.pax.Z)|An in-process SQL OLAP database management system|
| [luarocks](https://github.com/zopencommunity/luarocksport)|Green|100.0%|[STABLE_luarocks_2014](https://github.com/zopencommunity/luarocksport/releases/download/STABLE_luarocksport_2014/luarocks-heads.v3.9.2.20240124_121244.zos.pax.Z)|A package manager for Lua|
| [libserdes](https://github.com/zopencommunity/libserdesport)|Green|100.0%|[STABLE_libserdes_2932](https://github.com/zopencommunity/libserdesport/releases/download/STABLE_libserdesport_2932/libserdes-master.20250130_125514.zos.pax.Z)|A serialization/deserialization library|
| [curl](https://github.com/zopencommunity/curlport)|Blue|99.8%|[STABLE_curl_2964](https://github.com/zopencommunity/curlport/releases/download/STABLE_curlport_2964/curl-8.11.1.20250130_210044.zos.pax.Z)|Networking tool|
| [bison](https://github.com/zopencommunity/bisonport)|Blue|99.7%|[STABLE_bison_2448](https://github.com/zopencommunity/bisonport/releases/download/STABLE_bisonport_2448/bison-3.8.2.20240922_015100.zos.pax.Z)|repository for bison port to z/os|
| [perl](https://github.com/zopencommunity/perlport)|Blue|98.9%|[STABLE_perl_2840](https://github.com/zopencommunity/perlport/releases/download/STABLE_perlport_2840/perl5-heads.v5.41.7.20250123_102326.zos.pax.Z)|Perl programming language|
| [m4](https://github.com/zopencommunity/m4port)|Blue|98.3%|[STABLE_m4_1941](https://github.com/zopencommunity/m4port/releases/download/STABLE_m4port_1941/m4-1.4.19.20240104_082339.zos.pax.Z)|A macro processor|
| [ninja](https://github.com/zopencommunity/ninjaport)|Blue|98.2%|[STABLE_ninja_2924](https://github.com/zopencommunity/ninjaport/releases/download/STABLE_ninjaport_2924/ninja-heads.v1.12.1.20250130_123403.zos.pax.Z)|Build automation tool used with GNU Autotools|
| [autoconf](https://github.com/zopencommunity/autoconfport)|Blue|98.0%|[STABLE_autoconf_1736](https://github.com/zopencommunity/autoconfport/releases/download/STABLE_autoconfport_1736/autoconf-2.71.20231114_002453.zos.pax.Z)|A configuration management tool|
| [openssl](https://github.com/zopencommunity/opensslport)|Blue|95.7%|[STABLE_openssl_2838](https://github.com/zopencommunity/opensslport/releases/download/STABLE_opensslport_2838/openssl-3.4.0.20250123_021310.zos.pax.Z)|A cryptographic library|
| [gettext](https://github.com/zopencommunity/gettextport)|Blue|87.4%|[STABLE_gettext_2450](https://github.com/zopencommunity/gettextport/releases/download/STABLE_gettextport_2450/gettext-0.21.20240922_014617.zos.pax.Z)|A library for internationalization and localization|
| [libtool](https://github.com/zopencommunity/libtoolport)|Blue|87.0%|[STABLE_libtool_2923](https://github.com/zopencommunity/libtoolport/releases/download/STABLE_libtoolport_2923/libtool-2.4.20250130_120629.zos.pax.Z)|Library for managing program library dependencies|
| [boost](https://github.com/zopencommunity/boostport)|Blue|85.1%|[DEV_boost_2378](https://github.com/zopencommunity/boostport/releases/download/DEV_boostport_2378/boost-master.20240730_055731.zos.pax.Z)|A collection of C++ libraries|
| [cmake](https://github.com/zopencommunity/cmakeport)|Blue|82.3%|[STABLE_cmake_2914](https://github.com/zopencommunity/cmakeport/releases/download/STABLE_cmakeport_2914/cmake-DEV.20250129_182555.zos.pax.Z)|A cross-platform build system|
| [coreutils](https://github.com/zopencommunity/coreutilsport)|Blue|79.8%|[STABLE_coreutils_3016](https://github.com/zopencommunity/coreutilsport/releases/download/STABLE_coreutilsport_3016/coreutils-9.5.20250131_021847.zos.pax.Z)|A collection of basic Unix utilities|
| [xz](https://github.com/zopencommunity/xzport)|Blue|77.8%|[STABLE_xz_3075](https://github.com/zopencommunity/xzport/releases/download/STABLE_xzport_3075/xz-5.6.4.20250205_033706.zos.pax.Z)|A compression utility|
| [automake](https://github.com/zopencommunity/automakeport)|Yellow|71.4%|[STABLE_automake_3055](https://github.com/zopencommunity/automakeport/releases/download/STABLE_automakeport_3055/automake-1.17.20250131_112933.zos.pax.Z)|Tool for managing dependencies in software projects using GNU Autotools|
| [texinfo](https://github.com/zopencommunity/texinfoport)|Red|35.3%|[STABLE_texinfo_1764](https://github.com/zopencommunity/texinfoport/releases/download/STABLE_texinfoport_1764/texinfo-6.8.20231115_132117.zos.pax.Z)|A documentation generator|
| [libssh2](https://github.com/zopencommunity/libssh2port)|Red|7.1%|[STABLE_libssh2_1930](https://github.com/zopencommunity/libssh2port/releases/download/STABLE_libssh2port_1930/libssh2-1.11.0.20240103_144102.zos.pax.Z)|A library for SSH2 protocol|
</div>

<div class="table-category" data-category="utilities">

## Utilities <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [ncdu](https://github.com/zopencommunity/ncduport)|Skipped|N/A|[STABLE_ncdu_2976](https://github.com/zopencommunity/ncduport/releases/download/STABLE_ncduport_2976/ncdu-1.20.20250131_041215.zos.pax.Z)|A disk usage analyzer with an ncurses interface|
| [zigi](https://github.com/zopencommunity/zigiport)|Skipped|N/A|[STABLE_zigi_2984](https://github.com/zopencommunity/zigiport/releases/download/STABLE_zigiport_2984/zigi-master.20250131_043222.zos.pax.Z)|A git interface for ispf|
| [yq](https://github.com/zopencommunity/yqport)|Skipped|N/A|[STABLE_yq_3072](https://github.com/zopencommunity/yqport/releases/download/STABLE_yqport_3072/yq-master.20250205_033653.zos.pax.Z)|A command-line JSON processor|
| [gum](https://github.com/zopencommunity/gumport)|Skipped|N/A|[STABLE_gum_3062](https://github.com/zopencommunity/gumport/releases/download/STABLE_gumport_3062/gum-heads.v0.15.2.20250205_031308.zos.pax.Z)|A tool for creating simple command-line interfaces|
| [thesilversearcher](https://github.com/zopencommunity/thesilversearcherport)|Skipped|N/A|[STABLE_thesilversearcher_2836](https://github.com/zopencommunity/thesilversearcherport/releases/download/STABLE_thesilversearcherport_2836/the_silver_searcher-2.2.0.20250123_020711.zos.pax.Z)|A code searching tool|
| [moreutils](https://github.com/zopencommunity/moreutilsport)|Skipped|N/A|[STABLE_moreutils_3017](https://github.com/zopencommunity/moreutilsport/releases/download/STABLE_moreutilsport_3017/moreutils-0.67.20250131_083827.zos.pax.Z)|A collection of text processing utilities|
| [tree](https://github.com/zopencommunity/treeport)|Skipped|N/A|[STABLE_tree_2942](https://github.com/zopencommunity/treeport/releases/download/STABLE_treeport_2942/tree-heads.2.2.1.20250130_143113.zos.pax.Z)|A directory tree listing tool|
| [prompters](https://github.com/zopencommunity/promptersport)|Skipped|N/A|[STABLE_prompters_3020](https://github.com/zopencommunity/promptersport/releases/download/STABLE_promptersport_3020/prompters-main.20250131_084954.zos.pax.Z)|Prompter library for creating interactive command line interfaces|
| [lazygit](https://github.com/zopencommunity/lazygitport)|Skipped|N/A|[STABLE_lazygit_2148](https://github.com/zopencommunity/lazygitport/releases/download/STABLE_lazygitport_2148/lazygit-master.20240221_041017.zos.pax.Z)|A Git client|
| [ttype](https://github.com/zopencommunity/ttypeport)|Skipped|N/A|[STABLE_ttype_2771](https://github.com/zopencommunity/ttypeport/releases/download/STABLE_ttypeport_2771/ttype-heads.v0.4.0.20241205_210055.zos.pax.Z)|A terminal type identifier|
| [godsect](https://github.com/zopencommunity/godsectport)|Skipped|N/A|[STABLE_godsect_2874](https://github.com/zopencommunity/godsectport/releases/download/STABLE_godsectport_2874/godsect-main.20250129_141744.zos.pax.Z)|A code security scanner|
| [zotsample](https://github.com/zopencommunity/zotsampleport)|Green|100.0%|[STABLE_zotsample_2944](https://github.com/zopencommunity/zotsampleport/releases/download/STABLE_zotsampleport_2944/zotsample-1.3.20250130_211252.zos.pax.Z)|z/OS Open Tools Sample Port for education|
| [man-db](https://github.com/zopencommunity/man-dbport)|Green|100.0%|[STABLE_man-db_2945](https://github.com/zopencommunity/man-dbport/releases/download/STABLE_man-dbport_2945/man-db-2.12.1.20250130_210217.zos.pax.Z)|Tool for generating manual pages for Unix programs|
| [hello](https://github.com/zopencommunity/helloport)|Green|100.0%|[STABLE_hello_2971](https://github.com/zopencommunity/helloport/releases/download/STABLE_helloport_2971/hello-2.12.1.20250131_030044.zos.pax.Z)|A simple "hello world" program demonstrating the use of autotools and gettext|
| [meta](https://github.com/zopencommunity/metaport)|Green|100.0%|[STABLE_meta_2849](https://github.com/zopencommunity/metaport/releases/download/STABLE_metaport_2849/meta-main.20250124_023351.zos.pax.Z)|zopen package manager|
| [which](https://github.com/zopencommunity/whichport)|Green|100.0%|[STABLE_which_2789](https://github.com/zopencommunity/whichport/releases/download/STABLE_whichport_2789/which-2.21.20241219_210736.zos.pax.Z)|A command to find commands|
| [tig](https://github.com/zopencommunity/tigport)|Green|100.0%|[STABLE_tig_3005](https://github.com/zopencommunity/tigport/releases/download/STABLE_tigport_3005/tig-2.5.9.20250131_061802.zos.pax.Z)|A text-mode interface for Git|
| [c3270](https://github.com/zopencommunity/c3270port)|Green|100.0%|[STABLE_c3270_3014](https://github.com/zopencommunity/c3270port/releases/download/STABLE_c3270port_3014/c3270-DEV.20250131_063757.zos.pax.Z)|A 3270 terminal emulator|
| [wharf](https://github.com/zopencommunity/wharfport)|Green|100.0%|[STABLE_wharf_3056](https://github.com/zopencommunity/wharfport/releases/download/STABLE_wharfport_3056/wharf-main.20250131_125625.zos.pax.Z)|A build configuration for Wharf|
| [zos-code-page-tools](https://github.com/zopencommunity/zos-code-page-toolsport)|Green|100.0%|[DEV_zos-code-page-tools_3008](https://github.com/zopencommunity/zos-code-page-toolsport/releases/download/DEV_zos-code-page-toolsport_3008/zoscodepagetools-DEV.20250131_062724.zos.pax.Z)|Tools for working with z/OS code pages|
| [zospstree](https://github.com/zopencommunity/zospstreeport)|Green|100.0%|[STABLE_zospstree_2851](https://github.com/zopencommunity/zospstreeport/releases/download/STABLE_zospstreeport_2851/zostree-DEV.20250124_030729.zos.pax.Z)|A tool for viewing the structure of z/OS file systems|
| [zosnc](https://github.com/zopencommunity/zosncport)|Green|100.0%|[STABLE_zosnc_3019](https://github.com/zopencommunity/zosncport/releases/download/STABLE_zosncport_3019/zosnc-DEV.20250131_084420.zos.pax.Z)|A tool for managing network connections|
| [stow](https://github.com/zopencommunity/stowport)|Green|100.0%|[STABLE_stow_3034](https://github.com/zopencommunity/stowport/releases/download/STABLE_stowport_3034/stow-2.4.0.20250131_101113.zos.pax.Z)|A symlink manager|
| [parse-gotest](https://github.com/zopencommunity/parse-gotestport)|Green|100.0%|[STABLE_parse-gotest_2364](https://github.com/zopencommunity/parse-gotestport/releases/download/STABLE_parse-gotestport_2364/parse-gotest-heads.v0.1.1.20240721_042053.zos.pax.Z)|A Go test parser|
| [spdlog](https://github.com/zopencommunity/spdlogport)|Green|100.0%|[STABLE_spdlog_3053](https://github.com/zopencommunity/spdlogport/releases/download/STABLE_spdlogport_3053/spdlog-heads.v1.15.0.20250131_120004.zos.pax.Z)||
| [rsync](https://github.com/zopencommunity/rsyncport)|Blue|94.3%|[STABLE_rsync_2844](https://github.com/zopencommunity/rsyncport/releases/download/STABLE_rsyncport_2844/rsync-3.4.1.20250123_215715.zos.pax.Z)|A file synchronization utility|
| [patch](https://github.com/zopencommunity/patchport)|Blue|94.1%|[STABLE_patch_2963](https://github.com/zopencommunity/patchport/releases/download/STABLE_patchport_2963/patch-2.7.20250131_001657.zos.pax.Z)|Tool for patching files|
| [git-lfs](https://github.com/zopencommunity/git-lfsport)|Blue|94.1%|[STABLE_git-lfs_2858](https://github.com/zopencommunity/git-lfsport/releases/download/STABLE_git-lfsport_2858/git-lfs.20250124_120556.zos.pax.Z)|A Git extension for versioning large files|
| [gawk](https://github.com/zopencommunity/gawkport)|Blue|93.1%|[STABLE_gawk_3064](https://github.com/zopencommunity/gawkport/releases/download/STABLE_gawkport_3064/gawk-5.3.1.20250205_031214.zos.pax.Z)|The GNU implementation of the awk text processing language|
| [diffutils](https://github.com/zopencommunity/diffutilsport)|Blue|92.8%|[STABLE_diffutils_2986](https://github.com/zopencommunity/diffutilsport/releases/download/STABLE_diffutilsport_2986/diffutils-3.10.20250131_042952.zos.pax.Z)|File and directory comparison utilities|
| [tar](https://github.com/zopencommunity/tarport)|Blue|92.4%|[STABLE_tar_2939](https://github.com/zopencommunity/tarport/releases/download/STABLE_tarport_2939/tar-1.35.20250130_121504.zos.pax.Z)|GNU implementation of the tar archiving tool|
| [grep](https://github.com/zopencommunity/grepport)|Blue|92.1%|[STABLE_grep_2975](https://github.com/zopencommunity/grepport/releases/download/STABLE_grepport_2975/grep-3.11.20250131_025008.zos.pax.Z)|Text processing utilities|
| [findutils](https://github.com/zopencommunity/findutilsport)|Blue|91.9%|[STABLE_findutils_2690](https://github.com/zopencommunity/findutilsport/releases/download/STABLE_findutilsport_2690/findutils-4.9.0.20241028_234333.zos.pax.Z)|Utilities for finding files|
| [sed](https://github.com/zopencommunity/sedport)|Blue|84.7%|[STABLE_sed_2981](https://github.com/zopencommunity/sedport/releases/download/STABLE_sedport_2981/sed-4.9.20250131_041436.zos.pax.Z)|A stream editor for manipulating text files|
| [getopt](https://github.com/zopencommunity/getoptport)|Yellow|52.2%|[STABLE_getopt_2970](https://github.com/zopencommunity/getoptport/releases/download/STABLE_getoptport_2970/getopt-1.1.6.20250131_021411.zos.pax.Z)|A command-line option parser|
</div>

<div class="table-category" data-category="webframework">

## Webframework <!-- {docsify-ignore} -->

| Package | Status | Test Success Rate | Latest Release | Description |
|---|---|---|---|---|
| [hugo](https://github.com/zopencommunity/hugoport)|Skipped|N/A|[STABLE_hugo_3068](https://github.com/zopencommunity/hugoport/releases/download/STABLE_hugoport_3068/hugo-heads.v0.143.0.20250205_031418.zos.pax.Z)|A static site generator|
</div>


Last updated:  2025-02-10T11:56:01.598463
