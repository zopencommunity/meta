# Changelog
## December 2024
### ✨ Features
- Enhance zopen generate to create default main branch and add new contribution link ([#927](https://github.com/zopencommunity/meta/pull/927))
- Add a prompt, plus improve messaging to inform the user about the zopen overriding behaviour on conflicting tools ([#926](https://github.com/zopencommunity/meta/pull/926))

### 🔧 Maintenance
- Update usage.zopen.community urls ([728d8ef](https://github.com/zopencommunity/meta/commit/728d8efa4d9716ded35dc4674ebc8a437d89ee3d))

## November 2024
### ♻️ Refactoring
- Several Website changes (adds categories, refactors scripts, and more) ([#898](https://github.com/zopencommunity/meta/pull/898))

### ✨ Features
- Add recommended tools based on roles and update the TOC ([4629a54](https://github.com/zopencommunity/meta/commit/4629a54027f613e2057ea722d8981c3709e4ce54))
- Add recommended tools based on roles and update the TOC ([a785890](https://github.com/zopencommunity/meta/commit/a78589035bb6e666085ad1e81afe6b85a930d4b0))

### 🐛 Bug Fixes
- Add issue template and workflow to create port repos in zopencommunity org ([#910](https://github.com/zopencommunity/meta/pull/910))
- Resolve issue with size calculation ([#915](https://github.com/zopencommunity/meta/pull/915))
- fix typo in getbinaries.py ([fbd9af5](https://github.com/zopencommunity/meta/commit/fbd9af5de61b57e8e664b2712ff58445c6fed8c3))

### 📚 Documentation
- Update Porting.md - new port contribution request form ([#924](https://github.com/zopencommunity/meta/pull/924))
- Update CONTRIBUTING.md ([#921](https://github.com/zopencommunity/meta/pull/921))
- Added vim-airline and vim-airline-themes info in the doc ([#913](https://github.com/zopencommunity/meta/pull/913))
- Update _sidebar.md with usage and pipeline info ([e6664a9](https://github.com/zopencommunity/meta/commit/e6664a95dd468f954f6cbbe1b391c25e5d0ebce3))
- Update Analytics.md ([f0ae77e](https://github.com/zopencommunity/meta/commit/f0ae77ef09afdf8c24c1d1d2dde1ceb6e4f89738))
- Remove redundant `port` in Latest.md generation ([#907](https://github.com/zopencommunity/meta/pull/907))
- Use docsify-toc instead of docsify-plugin-toc css ([df0860c](https://github.com/zopencommunity/meta/commit/df0860cc708a39c39270c8e3a731d61fcb374122))
- Update Table of contents in docs ([dc40c51](https://github.com/zopencommunity/meta/commit/dc40c515339971dc60ed42603b7cbf671bba8f69))
- Update recommended.md ([37f48b0](https://github.com/zopencommunity/meta/commit/37f48b0fcc68b2f367512857219e62fe024f2c46))
- Update recommended.md ([b01e4e0](https://github.com/zopencommunity/meta/commit/b01e4e0f93a87476467b57b2fae191edb9d6eecf))
- Update recommended.md ([7d080ba](https://github.com/zopencommunity/meta/commit/7d080ba7e5a294a32abdaf5fde658b6504d3eb31))
- Update README.md ([2b9516e](https://github.com/zopencommunity/meta/commit/2b9516e4829105c969831ee32afab83cf10485e3))
- Update README.md ([b9d40db](https://github.com/zopencommunity/meta/commit/b9d40db29fd11ec159bf4ea31c49c8fdb3f1327e))
- Update README.md ([dda04b1](https://github.com/zopencommunity/meta/commit/dda04b1ba45547374783ddd6986957a2b2e18c27))

### 🔄 CI/CD
- Add scripts to monitor/restart if down, all of the cicd systems ([#923](https://github.com/zopencommunity/meta/pull/923))
- Update the cicd / usage urls to the new domain names ([#916](https://github.com/zopencommunity/meta/pull/916))

### 🔍 Other Changes
- Mark initialization files as IBM-1047 ([#888](https://github.com/zopencommunity/meta/pull/888))
- Start gpg-agent for verification of signatures ([#908](https://github.com/zopencommunity/meta/pull/908))
- Change commit user name ([#863](https://github.com/zopencommunity/meta/pull/863))
- Invalid option -m passed to df during installs ([#909](https://github.com/zopencommunity/meta/pull/909))

### 🔧 Maintenance
- Reinstante the correct update to link to new repo ([#920](https://github.com/zopencommunity/meta/pull/920))
- Update getting z/OS access link ([5f3bc7d](https://github.com/zopencommunity/meta/commit/5f3bc7d3d95db76e0c1cee9fba8d0af4bf5b1339))
- Update website ([09e9152](https://github.com/zopencommunity/meta/commit/09e91520352194d66585eeecaa4b809200f355f0))

## October 2024
### ✨ Features
- Add category to zopen list output ([#892](https://github.com/zopencommunity/meta/pull/892))
- Update CODEOWNERS (add sachintu47) ([#895](https://github.com/zopencommunity/meta/pull/895))
- Add categories to release json ([aa5c333](https://github.com/zopencommunity/meta/commit/aa5c333e02a221e58549d499cde12b7a62736186))
- Add Git Tag Info ([#882](https://github.com/zopencommunity/meta/pull/882))
- Add --force option to avoid locks in zopen-init installs ([971b034](https://github.com/zopencommunity/meta/commit/971b03457347bac7960f2e1a081b62d71a5681ee))
- Add demo resources by topic ([#874](https://github.com/zopencommunity/meta/pull/874))
- Add support for system prereq checks ([#844](https://github.com/zopencommunity/meta/pull/844))
- Adds support for --override-zos-tools in manpages ([#870](https://github.com/zopencommunity/meta/pull/870))

### 🐛 Bug Fixes
- Add error checking in zopen-build setup.sh and only replace hardcoded paths in text files (not binary files) ([#887](https://github.com/zopencommunity/meta/pull/887))
- Fix generateJsonConfiguration issue in zopen-init ([#896](https://github.com/zopencommunity/meta/pull/896))
- Improve error messages when out of space ([#881](https://github.com/zopencommunity/meta/pull/881))
- Fix zopen meta refresh issue ([064ef0f](https://github.com/zopencommunity/meta/commit/064ef0f5c38fb902acd31da02932e6e8a04aafd1))
- Update zopen-init (fix for --refresh to update bootstrap tools) ([15887fd](https://github.com/zopencommunity/meta/commit/15887fda71c4a6861b229252a72b216d8d524a12))
- Add --bypass-prereq-checks to zopen-init and fix zopen-init issues ([#879](https://github.com/zopencommunity/meta/pull/879))
- syntax issue fix ([#877](https://github.com/zopencommunity/meta/pull/877))
- Fix on_nightly.sh ([dd17ffb](https://github.com/zopencommunity/meta/commit/dd17ffb3c141f811dd2cef91a006df1b3156cbd3))
- Do not print an error until we activate gpg in the build process ([9b9316e](https://github.com/zopencommunity/meta/commit/9b9316eb24d54235069412bc2e074d27b970ef12))
- Add issue templates and automatic labeling ([#861](https://github.com/zopencommunity/meta/pull/861))

### 📚 Documentation
- Update QuickStart Guide. Make sidebar pages collapsed by default ([#880](https://github.com/zopencommunity/meta/pull/880))
- Update logo in docs ([2574eb9](https://github.com/zopencommunity/meta/commit/2574eb9989ea3696fad3ab9895fc6221f3268faa))

### 🔄 CI/CD
- Allow specification of specific patch directory ([#890](https://github.com/zopencommunity/meta/pull/890))

### 🔍 Other Changes
- Avoid gpg temporary files colliding ([#891](https://github.com/zopencommunity/meta/pull/891))
- zopen init changes ([#876](https://github.com/zopencommunity/meta/pull/876))
- GPG - sign & verify pax files ([#852](https://github.com/zopencommunity/meta/pull/852))

### 🔧 Maintenance
- Update zopen-init ([#899](https://github.com/zopencommunity/meta/pull/899))
- Update tool_categories.txt ([6ed7da8](https://github.com/zopencommunity/meta/commit/6ed7da8d94590ef9c095bbfef09fdc4b95e57c21))
- Update tool_categories.txt ([8b3848b](https://github.com/zopencommunity/meta/commit/8b3848ba1c8658457c6c7b7c828295bb36de0e32))
- Update build.groovy ([#883](https://github.com/zopencommunity/meta/pull/883))
- Update create_cve_json.py ([#856](https://github.com/zopencommunity/meta/pull/856))

## September 2024
### ✨ Features
- add `skip` option to ZOPEN_COMP ([#858](https://github.com/zopencommunity/meta/pull/858))
- Adding PR template ([#841](https://github.com/zopencommunity/meta/pull/841))

### 🔍 Other Changes
- Rename z/OS Open Tools to zopen community (to be merged on Sept. 20) ([#862](https://github.com/zopencommunity/meta/pull/862))

## August 2024
### ✨ Features
- Add zopen build --instrument option to enable code instrumentation ([#851](https://github.com/zopencommunity/meta/pull/851))

### 🐛 Bug Fixes
- Re-org zopen-init code to avoid jq errors ([#850](https://github.com/zopencommunity/meta/pull/850))

## July 2024
### ✨ Features
- Added a flag to handle generation of ZOSLIB Hooks ([#839](https://github.com/zopencommunity/meta/pull/839))
- Add options to zopen-audit for dealing with vulnerable packages ([#832](https://github.com/zopencommunity/meta/pull/832))
- Adding best practices section ([#836](https://github.com/zopencommunity/meta/pull/836))

### 🐛 Bug Fixes
- Fix reg with is_collecting_stats ([8d281ac](https://github.com/zopencommunity/meta/commit/8d281ac644d6edda4d106f1000d31d8b442a5748))
- Update QuickStart.md to address issue 720 ([#723](https://github.com/zopencommunity/meta/pull/723))
- Zopen config bug fixes and key name policing ([#795](https://github.com/zopencommunity/meta/pull/795))

### 💄 Style
- Switch to new CVE json format ([#833](https://github.com/zopencommunity/meta/pull/833))

### 🔍 Other Changes
- Enable file system setting for how /bin tools are overriden via zopen-init ([#828](https://github.com/zopencommunity/meta/pull/828))
- Manual lists of CVEs to include and exclude ([#817](https://github.com/zopencommunity/meta/pull/817))

### 🔧 Maintenance
- Update instructions regarding new altbin dir ([#819](https://github.com/zopencommunity/meta/pull/819))

## June 2024
### ✨ Features
- Add alternate path for tools that conflict with /bin tools + mechanism to add them to your PATH ([#766](https://github.com/zopencommunity/meta/pull/766))
- Add quick install similar to brew ([#811](https://github.com/zopencommunity/meta/pull/811))
- Add view for newly released tools ([#741](https://github.com/zopencommunity/meta/pull/741))
- Add zopen audit command to check installed packages for vulnerabilities ([#770](https://github.com/zopencommunity/meta/pull/770))

### 🐛 Bug Fixes
- Fix typos ([#813](https://github.com/zopencommunity/meta/pull/813))

### 📚 Documentation
- Update blogs.md ([#786](https://github.com/zopencommunity/meta/pull/786))
- Seperate docupdate.sh into two scripts, on_nightly and on_release ([#783](https://github.com/zopencommunity/meta/pull/783))
- Add links to releases and latest releases on vulnerabilities docs page ([#781](https://github.com/zopencommunity/meta/pull/781))
- Add page on docs for list of package vulnerabilities ([#774](https://github.com/zopencommunity/meta/pull/774))
- Consolidation of install docs ([#769](https://github.com/zopencommunity/meta/pull/769))

### 🔍 Other Changes
- Generate XML file for vulnerabilities RSS feed ([#794](https://github.com/zopencommunity/meta/pull/794))
- Ensure true/false consistency for knv ([#787](https://github.com/zopencommunity/meta/pull/787))
- Remove bashisms from zopen-audit script ([#784](https://github.com/zopencommunity/meta/pull/784))
- Remove command trace & repush variable ([#782](https://github.com/zopencommunity/meta/pull/782))
- Export environment key-value pairs ([#780](https://github.com/zopencommunity/meta/pull/780))
- Zopen config helper capabilities ([#779](https://github.com/zopencommunity/meta/pull/779))
- Enable SSL for requests in create_cve_json script ([#773](https://github.com/zopencommunity/meta/pull/773))

## May 2024
### ✨ Features
- Add copyright and notices footer ([#759](https://github.com/zopencommunity/meta/pull/759))

### 🐛 Bug Fixes
- fix for comments and what is expected ([#764](https://github.com/zopencommunity/meta/pull/764))
- Fix for zopen-build when zoslib_env is empty ([#763](https://github.com/zopencommunity/meta/pull/763))

### 📚 Documentation
- Update GitOnZOS.md ([#768](https://github.com/zopencommunity/meta/pull/768))

### 🔍 Other Changes
- Script to generate json file of vulnerabilities in packages ([#765](https://github.com/zopencommunity/meta/pull/765))
- Remove escaped quotes in config ([#762](https://github.com/zopencommunity/meta/pull/762))

## April 2024
### 💄 Style
- Add iden information to executables ([#750](https://github.com/zopencommunity/meta/pull/750))

### 🔍 Other Changes
- Only generate zoslib hooks if CC is set ([#754](https://github.com/zopencommunity/meta/pull/754))

## March 2024
### ✨ Features
- Added some info about curl ([#730](https://github.com/zopencommunity/meta/pull/730))

### 📚 Documentation
- doc: the command zopen search is not valid ([#747](https://github.com/zopencommunity/meta/pull/747))
- Simplify the meta README ([#744](https://github.com/zopencommunity/meta/pull/744))
- Update GpgOnZOS.md ([#731](https://github.com/zopencommunity/meta/pull/731))
- Update VimOnZOS.md ([#739](https://github.com/zopencommunity/meta/pull/739))
- Update VimOnZOS.md to remove old package manager workflow ([#724](https://github.com/zopencommunity/meta/pull/724))
- Update FAQ.md with statement on support ([#721](https://github.com/zopencommunity/meta/pull/721))

### 🔄 CI/CD
- Add a blurb about github actions and rename Pipeline to Testing ([#568](https://github.com/zopencommunity/meta/pull/568))

### 🔍 Other Changes
- Set GIT UTF8 CCSID to 819 for zopen builds ([#736](https://github.com/zopencommunity/meta/pull/736))
- Embed usage statistics in Analytics page ([#725](https://github.com/zopencommunity/meta/pull/725))
- workshop manual ([#668](https://github.com/zopencommunity/meta/pull/668))

### 🔧 Maintenance
- Update version to 0.8.2 ([#716](https://github.com/zopencommunity/meta/pull/716))

## February 2024
### ✨ Features
- Add General Outline for Porting Go Packages ([#712](https://github.com/zopencommunity/meta/pull/712))
- Update CODEOWNERS (Add v1gnesh) ([#706](https://github.com/zopencommunity/meta/pull/706))
- Download metadata.json during zopen install + support for installation caveats ([#693](https://github.com/zopencommunity/meta/pull/693))
- Add port's commit hash to metadata.json ([#685](https://github.com/zopencommunity/meta/pull/685))

### 🐛 Bug Fixes
- Analytics: enable support by default + some fixes ([#711](https://github.com/zopencommunity/meta/pull/711))
- Fix zopen install --select ([#710](https://github.com/zopencommunity/meta/pull/710))
- Modified error description ([#705](https://github.com/zopencommunity/meta/pull/705))
- Add error message for invalid options in zopen ([#699](https://github.com/zopencommunity/meta/pull/699))
- Fix metadata.json bug ([eedc581](https://github.com/zopencommunity/meta/commit/eedc5813c9bdd16d8b2bbc786fb10f074fc4f1ee))
- Fix caveats code ([d8a5736](https://github.com/zopencommunity/meta/commit/d8a573628923cd5deedeba81dfc4d29bffd75b11))
- Address issues in usage statistics feature ([#690](https://github.com/zopencommunity/meta/pull/690))
- Fix zopen install --all and guard display on zopen-config ([#677](https://github.com/zopencommunity/meta/pull/677))

### 📚 Documentation
- Remove duplication from QuickStart guide ([#708](https://github.com/zopencommunity/meta/pull/708))
- Update QuickStart.md ([0732ac7](https://github.com/zopencommunity/meta/commit/0732ac73af485baccdf3d8a3bdbdb39c364560c4))
- Update README.md ([30b1baf](https://github.com/zopencommunity/meta/commit/30b1baf2b59243b2130312c063eb2a8562a9d33b))
- Update README.md ([b4efd53](https://github.com/zopencommunity/meta/commit/b4efd53227336f2620e10885a2247b1c176a19a0))
- Reorder doc updates ([b16ed57](https://github.com/zopencommunity/meta/commit/b16ed57ec86ecf4a2e9fe7e489ba8bc4727a34be))
- Reorder doc updates ([c5a775a](https://github.com/zopencommunity/meta/commit/c5a775a2ced5a127e0d014c7cad5590a6bf37bef))

### 🔍 Other Changes
- Create a CODEOWNERS file as part of zopen generate ([#678](https://github.com/zopencommunity/meta/pull/678))

### 🔧 Maintenance
- Update zopen-generate ([#709](https://github.com/zopencommunity/meta/pull/709))

## January 2024
### ✨ Features
- Update ivt script to add java check ([#672](https://github.com/zopencommunity/meta/pull/672))
- Add IVT script to verify system meets all prereqs ([#655](https://github.com/zopencommunity/meta/pull/655))
- Add +x permissions ([6ee0f54](https://github.com/zopencommunity/meta/commit/6ee0f54bb3e72d27a3a821716801a33a9c33d002))

### 🐛 Bug Fixes
- fix zopen-promote help so that it can be properly converted to man pages ([#666](https://github.com/zopencommunity/meta/pull/666))
- Fix date to timestamp conversion ([#649](https://github.com/zopencommunity/meta/pull/649))
- Fix README.md ([986430a](https://github.com/zopencommunity/meta/commit/986430ac7191d4158f4e3463218f4ee228d3725b))
- Fix zopen-generate copy command + add stubs for bump in buildenv ([#648](https://github.com/zopencommunity/meta/pull/648))
- fix erroneous ] in docupdate.sh ([#650](https://github.com/zopencommunity/meta/pull/650))

### 📚 Documentation
- Add details about Clang and Go compiler in porting pre-req doc ([#653](https://github.com/zopencommunity/meta/pull/653))
- Correct the reference .md generation again ([#651](https://github.com/zopencommunity/meta/pull/651))
- Reference docs styling (#645) ([d3a87d6](https://github.com/zopencommunity/meta/commit/d3a87d6c8765abdec22a6be66d9b611c17c356ff))
- Commit jenkins doc update cicd script ([0c4d18a](https://github.com/zopencommunity/meta/commit/0c4d18ac829dfd51435847e067032c3a62d21b7b))

### 🔍 Other Changes
- Preserve steplib under ZOPEN_OLD_STEPLIB for compilers ([#659](https://github.com/zopencommunity/meta/pull/659))
- Server-side backend/Web UI for usage statistics ([#656](https://github.com/zopencommunity/meta/pull/656))
- Revert "Server-side backend/Web UI for usage statistics" ([3d5c2b4](https://github.com/zopencommunity/meta/commit/3d5c2b466ef4cadc7ca9ebfbaa42a3b4b09db11d))
- Server-side backend/Web UI for usage statistics ([3c67e61](https://github.com/zopencommunity/meta/commit/3c67e611984096ae815de99e26d589046599c122))

### 🔧 Maintenance
- Update release cache script to leverage release metadata.json ([#646](https://github.com/zopencommunity/meta/pull/646))
- Update tool_categories.txt ([#647](https://github.com/zopencommunity/meta/pull/647))

## December 2023
### ♻️ Refactoring
- Cleanup `zopen-install --help` output (#640) ([e06f992](https://github.com/zopencommunity/meta/commit/e06f992dc09edd911cc296576eda379799f14aa5))

### ✨ Features
- Add copyright text (#642) ([a22f4c6](https://github.com/zopencommunity/meta/commit/a22f4c60cfdcb81f16aed9395e6518c5523b6b5d))
- Implement some granular logic to --cache ([#627](https://github.com/zopencommunity/meta/pull/627))
- Add 'zip' as a supported extension ([#632](https://github.com/zopencommunity/meta/pull/632))

### 🐛 Bug Fixes
- Trivial typo in Migration.md ([#644](https://github.com/zopencommunity/meta/pull/644))
- Fix markdown warnings, formatting,  spelling, and grammar ([#639](https://github.com/zopencommunity/meta/pull/639))
- Message fixes ([#637](https://github.com/zopencommunity/meta/pull/637))
- Fix test issue ([d309463](https://github.com/zopencommunity/meta/commit/d309463de670d2006b9fa54bc07aa806412855da))
- added fix for findutilsport ([#575](https://github.com/zopencommunity/meta/pull/575))

### 📚 Documentation
- Docs: add a section for feedback ([#612](https://github.com/zopencommunity/meta/pull/612))

### 🔍 Other Changes
- Ensure z/OS standard sed is used in common.sh ([#638](https://github.com/zopencommunity/meta/pull/638))
- metadata.json sizes should be in bytes, not 512-byte units ([#635](https://github.com/zopencommunity/meta/pull/635))
- Improve package version changing ([#634](https://github.com/zopencommunity/meta/pull/634))
- zopen-remove ([e1d32a0](https://github.com/zopencommunity/meta/commit/e1d32a0f23ec961a892bebf51e5ba95e998a7fd0))
- Analytics - Collecting usage statistics for zopen ([#607](https://github.com/zopencommunity/meta/pull/607))

### 🔧 Maintenance
- Update help text (#641) ([884d3e7](https://github.com/zopencommunity/meta/commit/884d3e741ac666d507e1a6bce76aeeada055ebd2))
- Metaport43 zopen upgrade failure ([#626](https://github.com/zopencommunity/meta/pull/626))
- Update version to 0.8.1 ([#609](https://github.com/zopencommunity/meta/pull/609))

## November 2023
### ♻️ Refactoring
- Message cleanup ([#594](https://github.com/zopencommunity/meta/pull/594))
- clean up help for manpages ([#557](https://github.com/zopencommunity/meta/pull/557))

### ✨ Features
- Add zopen_pre_terminate hook ([#602](https://github.com/zopencommunity/meta/pull/602))
- Re-init changes + add refresh option to refresh config file ([#595](https://github.com/zopencommunity/meta/pull/595))
- Add in check for _BPXK_AUTOCVT and set if not set (fail if set to OFF) ([#597](https://github.com/zopencommunity/meta/pull/597))
- zopen-build: Add an option to avoid installing runtime deps ([#587](https://github.com/zopencommunity/meta/pull/587))
- Check if tty is available when getting columns + add other ways to obtain columns ([#560](https://github.com/zopencommunity/meta/pull/560))
- Convert properties.json to metadata.json and add more fields ([#460](https://github.com/zopencommunity/meta/pull/460))

### 🐛 Bug Fixes
- Query bug ([#590](https://github.com/zopencommunity/meta/pull/590))
- add comments on code and fix compute of end of file line number ([#588](https://github.com/zopencommunity/meta/pull/588))
- Fix could not locate curl directory error if you have multiple curl installations ([#581](https://github.com/zopencommunity/meta/pull/581))
- Fix query logic in zopen-install ([#579](https://github.com/zopencommunity/meta/pull/579))
- fix zopen-clean traversal ([#573](https://github.com/zopencommunity/meta/pull/573))
- Fix metadata.json creation for BARE type projects ([#570](https://github.com/zopencommunity/meta/pull/570))
- Fix OCI artifact generation ([#505](https://github.com/zopencommunity/meta/pull/505))
- fix: Use printf instead of echo in license generation ([#503](https://github.com/zopencommunity/meta/pull/503))
- Fix curl error in zopen-build ([#553](https://github.com/zopencommunity/meta/pull/553))

### 📚 Documentation
- Update Migration.md - Rocket Tools ([#583](https://github.com/zopencommunity/meta/pull/583))
- Updating Docs to reference white background color command ([#577](https://github.com/zopencommunity/meta/pull/577))
- Clean up zopen-xxx services and associated docs ([#559](https://github.com/zopencommunity/meta/pull/559))
- Update _sidebar.md with link to zopen reference page ([#556](https://github.com/zopencommunity/meta/pull/556))

### 🔍 Other Changes
- Improve the 'git reset' message when working with patches ([#600](https://github.com/zopencommunity/meta/pull/600))
- Redirect trap command stderr ([#591](https://github.com/zopencommunity/meta/pull/591))
- Use alternate url for zopen_releases.json ([#582](https://github.com/zopencommunity/meta/pull/582))
- Provide the total size up front when installing all tools (zopen install --all) ([#564](https://github.com/zopencommunity/meta/pull/564))
- Move darkbackground logic ([#572](https://github.com/zopencommunity/meta/pull/572))
- Use active symlink for LICENSE ([#574](https://github.com/zopencommunity/meta/pull/574))
- Improve man and html page rendering ([#549](https://github.com/zopencommunity/meta/pull/549))
- Tag and encode .env as IBM-1047 ([#548](https://github.com/zopencommunity/meta/pull/548))

### 🔧 Maintenance
- Use ETag vs Last modified to check if zopen_releases.json is updated ([#601](https://github.com/zopencommunity/meta/pull/601))
- Update ansible to reflect new zopen ([#551](https://github.com/zopencommunity/meta/pull/551))
- Update common.sh to allow for a "light mode" ([#543](https://github.com/zopencommunity/meta/pull/543))

### 🧪 Testing
- Add bump and build_and_test yml files to data dir (used by zopen generate) ([#550](https://github.com/zopencommunity/meta/pull/550))

## October 2023
### ♻️ Refactoring
- Rework cleanup logic ([#542](https://github.com/zopencommunity/meta/pull/542))
- clean up options and put into sections ([#509](https://github.com/zopencommunity/meta/pull/509))
- Add in logic to only run cleanup ([#494](https://github.com/zopencommunity/meta/pull/494))

### ⚡️ Performance
- Simplify zopen-config for better performance ([#507](https://github.com/zopencommunity/meta/pull/507))

### ✨ Features
- Add a table to report download count for each project, sorted by projects with the highest downloads ([#546](https://github.com/zopencommunity/meta/pull/546))
- Add references in zopen to other commands ([#536](https://github.com/zopencommunity/meta/pull/536))
- Add a zopen pre-configure hook, needed by nginx ([#506](https://github.com/zopencommunity/meta/pull/506))
- Add '}' to variable encapsulation ([#490](https://github.com/zopencommunity/meta/pull/490))
- Add Haritha as a codeowner ([#481](https://github.com/zopencommunity/meta/pull/481))

### 🐛 Bug Fixes
- zopen-remove debug issue ([#545](https://github.com/zopencommunity/meta/pull/545))
- Fix issue with zoslib_env_hook prepend action when PROJECT_ROOT specified more than once ([#537](https://github.com/zopencommunity/meta/pull/537))
- Remove stty echo as its not longer needed and causes issues with perl ([#535](https://github.com/zopencommunity/meta/pull/535))
- Fix license check ([#529](https://github.com/zopencommunity/meta/pull/529))
- Fix zopen clean -c ([#527](https://github.com/zopencommunity/meta/pull/527))
- Update curl to the latest with the cve fix ([#526](https://github.com/zopencommunity/meta/pull/526))
- Fix zoslib env hook so that it only avoids implicitly setting envars for tool it is building ([#517](https://github.com/zopencommunity/meta/pull/517))
- Correct shell scripts issues, format shell scripts ([#486](https://github.com/zopencommunity/meta/pull/486))
- Fix bar chart and pie chart in progress page ([#483](https://github.com/zopencommunity/meta/pull/483))
- Fix for publish.groovy ([#478](https://github.com/zopencommunity/meta/pull/478))
- More fixes to replaceHardcodedPath logic, add sed as a dep ([#477](https://github.com/zopencommunity/meta/pull/477))
- Fix zopen-split-patch - fails with file argument ([#476](https://github.com/zopencommunity/meta/pull/476))
- Fix matching of runtime dependencies in release cache ([#474](https://github.com/zopencommunity/meta/pull/474))

### 📚 Documentation
- Update developing.md ([#504](https://github.com/zopencommunity/meta/pull/504))
- Update README for 'using' info ([#496](https://github.com/zopencommunity/meta/pull/496))

### 🔄 CI/CD
- Improved Explicit Upgrade Message ([#539](https://github.com/zopencommunity/meta/pull/539))
- Add reuseable github action workflow for testing ports ([#484](https://github.com/zopencommunity/meta/pull/484))
- Add zoslib as an implicit dep ([#524](https://github.com/zopencommunity/meta/pull/524))
- Do not add curl path to PATH when updating dependencies ([#532](https://github.com/zopencommunity/meta/pull/532))

### 🔍 Other Changes
- set non-zero rc when help2man fails to generate file ([#530](https://github.com/zopencommunity/meta/pull/530))
- Increment release to 0.8.0 ([#525](https://github.com/zopencommunity/meta/pull/525))
- Improve message as per #380 ([#518](https://github.com/zopencommunity/meta/pull/518))
- help2man wants executable name, not full-path ([#520](https://github.com/zopencommunity/meta/pull/520))
- force zopen_get_version to be required ([#512](https://github.com/zopencommunity/meta/pull/512))
- Check if JSON cache is accessible ([#514](https://github.com/zopencommunity/meta/pull/514))
- 500 urgent zopen clean u pkg too aggressive ([#502](https://github.com/zopencommunity/meta/pull/502))
- provide --version for all and call zopen-version directly ([#488](https://github.com/zopencommunity/meta/pull/488))
- 448 redux ([#475](https://github.com/zopencommunity/meta/pull/475))

### 🔧 Maintenance
- Updates for quickstart ([#510](https://github.com/zopencommunity/meta/pull/510))
- Re-enable update-cacert ([#523](https://github.com/zopencommunity/meta/pull/523))
- FAQ updates ([#480](https://github.com/zopencommunity/meta/pull/480))

### 🧪 Testing
- remove partially implemented verbs - add back in when tested ([#519](https://github.com/zopencommunity/meta/pull/519))
- Add logic to handle test harness ([#497](https://github.com/zopencommunity/meta/pull/497))

## September 2023
### ♻️ Refactoring
- clean up options processing ([#461](https://github.com/zopencommunity/meta/pull/461))

### ⚡️ Performance
- restrict tools that perform an update to writable zopen tool chains ([#464](https://github.com/zopencommunity/meta/pull/464))
- Optimize .env and .zopen-config processing ([#390](https://github.com/zopencommunity/meta/pull/390))

### ✨ Features
- Add checks to publish.groovy script ([#467](https://github.com/zopencommunity/meta/pull/467))
- Add a blurb on upgrading meta ([#439](https://github.com/zopencommunity/meta/pull/439))
- add version and have zopen know about itself to eliminate need for .env ([#434](https://github.com/zopencommunity/meta/pull/434))
- Add GH Actions action.yml ([#412](https://github.com/zopencommunity/meta/pull/412))
- Add back properties.json to install dir ([1828375](https://github.com/zopencommunity/meta/commit/18283757b0f330518bdba9abb70672e9b60f939e))
- Add initial workshop details ([5bf7f0d](https://github.com/zopencommunity/meta/commit/5bf7f0daea91be2696cdbb32feaf06f37333bdcb))
- Add option to zopen-init to answer yes ([#404](https://github.com/zopencommunity/meta/pull/404))
- Add publish.groovy ([e4acd1e](https://github.com/zopencommunity/meta/commit/e4acd1e81713f5b135425e41901e144a2416abca))
- Add a suggestion if zopen-config is not loaded ([#385](https://github.com/zopencommunity/meta/pull/385))
- Address zopen build's install location ([#383](https://github.com/zopencommunity/meta/pull/383))

### 🐛 Bug Fixes
- Fix replaceHardcodedPath regexp ([#470](https://github.com/zopencommunity/meta/pull/470))
- fix regression - let options through ([d911aad](https://github.com/zopencommunity/meta/commit/d911aadbfa7eb8670b672dc76c5a7c63f564b3c7))
- Code restructuring and bug fix for umask ([#459](https://github.com/zopencommunity/meta/pull/459))
- Fix release cache so that it skips repos not ending with port ([#452](https://github.com/zopencommunity/meta/pull/452))
- Fix success stories link ([#451](https://github.com/zopencommunity/meta/pull/451))
- fix releaseMetadata variable to be consistent ([#441](https://github.com/zopencommunity/meta/pull/441))
- Fix libpath and manpath to reflect symlink paths ([#432](https://github.com/zopencommunity/meta/pull/432))
- Always add a -suffix to ZOPEN_NAME ([#430](https://github.com/zopencommunity/meta/pull/430))
- Add envar to print debug info for zoslib env hook ([#425](https://github.com/zopencommunity/meta/pull/425))
- Fix zopen install --all ([#422](https://github.com/zopencommunity/meta/pull/422))
- zopen build install changes + fix for replacing hardcoded paths in package contents ([#415](https://github.com/zopencommunity/meta/pull/415))
- Fix properties.json ([1ae572f](https://github.com/zopencommunity/meta/commit/1ae572fd109c45d2555aefe46bf1ac8a4b48e5f2))
- Fix publish_oci.sh ([9bfc1d6](https://github.com/zopencommunity/meta/commit/9bfc1d6863780368a070382ad46c45aee27f7ac3))
- Update zopen generate to reflect new cicd structure + other fixes ([#410](https://github.com/zopencommunity/meta/pull/410))
- Fix zopen list --upgradeable + zopen-config fix ([#403](https://github.com/zopencommunity/meta/pull/403))
- Fix gif ([2e54f17](https://github.com/zopencommunity/meta/commit/2e54f17cea6793ce09eed8606e22d2abc16ab7c3))
- Fix gif ([76ceacc](https://github.com/zopencommunity/meta/commit/76ceaccec01ea5637dfb16f4d7e6e4c2c3888362))
- Fix gif ([c869961](https://github.com/zopencommunity/meta/commit/c869961c068d1cbd99763c91b3df4bdf582f6c3a))
- Fix publish  cicd ([2f84985](https://github.com/zopencommunity/meta/commit/2f84985485433583c7548cb978abc51b4e6acdea))
- Fix publish  cicd ([ba1d919](https://github.com/zopencommunity/meta/commit/ba1d919be2fa50627d1d8b031286f3a319c8e3d6))
- Fix zopen-update-cacert ([533a267](https://github.com/zopencommunity/meta/commit/533a2675b5740f12ef272e403f4f09cdcd1ad21e))
- Fix zopen-build issues related to new project parent dir ([06a51f6](https://github.com/zopencommunity/meta/commit/06a51f6a4fbb62dbff36e2fda61a40110e2f4de8))

### 📚 Documentation
- Update QuickStart.md ([#450](https://github.com/zopencommunity/meta/pull/450))
- Update docs for new zopen tooling ([#409](https://github.com/zopencommunity/meta/pull/409))
- Update docs ([1193b6c](https://github.com/zopencommunity/meta/commit/1193b6c408e47bd1fe359f9219db584189be3ba0))
- Update docs ([0ba0c02](https://github.com/zopencommunity/meta/commit/0ba0c02baa0eeb34f58f3d06e4d0757311293c2a))
- Update README.md ([12dd840](https://github.com/zopencommunity/meta/commit/12dd84036f3338206c617545f9be2002ce8d620e))
- Update QuickStart.md ([f27f021](https://github.com/zopencommunity/meta/commit/f27f0214920292b336849ffb81448f7744368e0c))

### 🔄 CI/CD
- CI: Add a label for the node to build on ([#456](https://github.com/zopencommunity/meta/pull/456))
- Updates to CI build step to upgrade meta, clean cache ([#455](https://github.com/zopencommunity/meta/pull/455))
- Update publish_oci.sh ([ccd779e](https://github.com/zopencommunity/meta/commit/ccd779eee0c89d8049534fc294df35657f0d0488))

### 🔍 Other Changes
- Increase delay after github release is created ([#466](https://github.com/zopencommunity/meta/pull/466))
- take another crack - move the version file ([#454](https://github.com/zopencommunity/meta/pull/454))
- rename version file from .version to zopen-version ([#453](https://github.com/zopencommunity/meta/pull/453))
- Use the ID zosopentoolsmain for user_name in the action ([#437](https://github.com/zopencommunity/meta/pull/437))
- some internal use tools for migration to new 'zopen build' framework ([#442](https://github.com/zopencommunity/meta/pull/442))
- remove pinning "real meta" note ([#449](https://github.com/zopencommunity/meta/pull/449))
- Enable 'zopen' tools to be processed by help2man and create a script to generate man pages for zopen tools ([#447](https://github.com/zopencommunity/meta/pull/447))
- change .version file and use it for printing out version ([#440](https://github.com/zopencommunity/meta/pull/440))
- minor change in message of zopen-init ([5614eb9](https://github.com/zopencommunity/meta/commit/5614eb90a05bf4aa7b7d34ad8e177126562cb0e6))
- 426 zopen clean  a groff didnt do what i expected ([#428](https://github.com/zopencommunity/meta/pull/428))
- Embed getting started vidoe ([d99b8b0](https://github.com/zopencommunity/meta/commit/d99b8b05309f7b29c2ce80d826b71eb6370f7ac6))
- preserve LIBPATH ([#423](https://github.com/zopencommunity/meta/pull/423))
- Replace all occurances of PROJECT_ROOT in zoslib env hook ([#424](https://github.com/zopencommunity/meta/pull/424))
- Use  <rootfs>usr/local/  as  base rather than ([#411](https://github.com/zopencommunity/meta/pull/411))
- Pass thru custom curl parameters ([#407](https://github.com/zopencommunity/meta/pull/407))
- Change the install location so as not to conflict with the default zopen install location. ([#399](https://github.com/zopencommunity/meta/pull/399))
- Remove dot from zopen-config, so it's not hidden ([#384](https://github.com/zopencommunity/meta/pull/384))
- Echo the pax location ([1074e15](https://github.com/zopencommunity/meta/commit/1074e15fd39755bbc112b44e2abce7a84da7c29b))
- Merge Russell's zopen fork into main ([#376](https://github.com/zopencommunity/meta/pull/376))

### 🔧 Maintenance
- Update publish.groovy ([4feca6a](https://github.com/zopencommunity/meta/commit/4feca6a83f0c4350b94f3e4c8eefb47bb311e2f2))
- Update zopen_releases.json ([735fd19](https://github.com/zopencommunity/meta/commit/735fd19ec8b78d09378dd073c096771ac65c7534))
- Update action.yml ([#429](https://github.com/zopencommunity/meta/pull/429))
- Update build.groovy ([0ef3dad](https://github.com/zopencommunity/meta/commit/0ef3dad78dd317b82bf2a84a8fdcde0c4adec00e))

## August 2023
### ✨ Features
- Add Mike Fulton's script to split an consolidated git patch into individual patches for each file ([#368](https://github.com/zopencommunity/meta/pull/368))
- Add zopen_pre_patch and support for cloning with submodules ([#363](https://github.com/zopencommunity/meta/pull/363))

### 🐛 Bug Fixes
- Fix json cache to report the correct tests statistics ([#369](https://github.com/zopencommunity/meta/pull/369))
- Fix encoding of properties.json and add install_test.sh support ([5e1dcd4](https://github.com/zopencommunity/meta/commit/5e1dcd46ba4b0d0d0ca1d241cab7a10c55e62522))
- Fixed build_line check ([dd8e950](https://github.com/zopencommunity/meta/commit/dd8e9500890d513f66761c74ade91496b533621a))
- Fix styling in SuccessStories page ([5fdb345](https://github.com/zopencommunity/meta/commit/5fdb34534de076d1c4717ed1217fbd36a5f772b4))

### 📚 Documentation
- Update GitOnZOS.md ([#373](https://github.com/zopencommunity/meta/pull/373))
- docs page octocat link does not work ([#372](https://github.com/zopencommunity/meta/pull/372))
- Update README.md ([#365](https://github.com/zopencommunity/meta/pull/365))

### 🔄 CI/CD
- Add logic to publish builds as OCI artifacts into the github container registry ([#364](https://github.com/zopencommunity/meta/pull/364))

### 🔍 Other Changes
- Correct permissions ([e6b9907](https://github.com/zopencommunity/meta/commit/e6b99074f75bd5d3779faf2362686d2fca02bef4))
- Set default BUILD_LINE to Stable ([9936c27](https://github.com/zopencommunity/meta/commit/9936c27b13e9df84432733ea0b4d7a9896345bf7))
- Success stories page ([#362](https://github.com/zopencommunity/meta/pull/362))

## July 2023
### ✨ Features
- Support for stable and dev line builds ([#353](https://github.com/zopencommunity/meta/pull/353))
- Add a tool to cache all z/OS Open Tools releases ([#354](https://github.com/zopencommunity/meta/pull/354))

### 🐛 Bug Fixes
- Add download url and fix removal of port suffix in JSON cache ([#356](https://github.com/zopencommunity/meta/pull/356))

### 🔄 CI/CD
- Add support for dev and stable builds in Jenkins ([#360](https://github.com/zopencommunity/meta/pull/360))

## June 2023
### ✨ Features
- Add an option for force apply the patches, useful when moving up to new versions ([#314](https://github.com/zopencommunity/meta/pull/314))
- Add external blogs ([#347](https://github.com/zopencommunity/meta/pull/347))
- Add more attempts when update-cacert fails as it sometimes times out on certain systems ([#338](https://github.com/zopencommunity/meta/pull/338))
- added function to sort the bootpkg array ([#310](https://github.com/zopencommunity/meta/pull/310))

### 🐛 Bug Fixes
- Fix zopen build errors ([#342](https://github.com/zopencommunity/meta/pull/342))
- Fix external blog link ([3d9e23b](https://github.com/zopencommunity/meta/commit/3d9e23b935cb10c9001563b5b18430e2d057aa79))
- Fix for tgz when applying patches ([9084d0f](https://github.com/zopencommunity/meta/commit/9084d0f80b8d3c378e84249d2f9dd66f9e52065e))

### 📚 Documentation
- Update _sidebar.md ([#331](https://github.com/zopencommunity/meta/pull/331))

### 🔄 CI/CD
- simple utility to compute build dependencies - tarball only ([#316](https://github.com/zopencommunity/meta/pull/316))
- Refactor and offload most compiler logic to dependencies ([#282](https://github.com/zopencommunity/meta/pull/282))

### 🔍 Other Changes
- Install zopen into the usual path rather than the current directory ([#348](https://github.com/zopencommunity/meta/pull/348))
- Do not create a .depenvs if top level project is not installed ([#346](https://github.com/zopencommunity/meta/pull/346))
- importenv enhancements ([#336](https://github.com/zopencommunity/meta/pull/336))
- Modify zopen-build to generate the .depsenv rather than zopen-install ([#334](https://github.com/zopencommunity/meta/pull/334))
- GPG article ([#317](https://github.com/zopencommunity/meta/pull/317))
- simple tool to print out brew and z/os tool versions ([#315](https://github.com/zopencommunity/meta/pull/315))

## May 2023
### ✨ Features
- Add additional common solutions ([#313](https://github.com/zopencommunity/meta/pull/313))
- Add a ZOPEN_CHECK_MINIMAL and *_FOR_BUILD envars ([#294](https://github.com/zopencommunity/meta/pull/294))

### 🐛 Bug Fixes
- Fix github query past 100 results, per page ([#302](https://github.com/zopencommunity/meta/pull/302))
- Update stable tools and fix token bug in create_stable_releases.sh ([#291](https://github.com/zopencommunity/meta/pull/291))
- Fix spelling ([#283](https://github.com/zopencommunity/meta/pull/283))

### 📚 Documentation
- Readme cleanup ([#305](https://github.com/zopencommunity/meta/pull/305))
- docs: added hint for environment variable ([#289](https://github.com/zopencommunity/meta/pull/289))

### 🔄 CI/CD
- zopen-generate: add polling in cicd.groovy ([#309](https://github.com/zopencommunity/meta/pull/309))
- Modify jenkins ip to new instance ([#303](https://github.com/zopencommunity/meta/pull/303))
- CICD: Install python modules if not present in publish job ([#292](https://github.com/zopencommunity/meta/pull/292))

### 🔍 Other Changes
- removed outdated comment ([#300](https://github.com/zopencommunity/meta/pull/300))
- Initial ansible playbook for setting up a z/OS vpc instance ([#209](https://github.com/zopencommunity/meta/pull/209))
- Allow an option to override default zopen type ([#299](https://github.com/zopencommunity/meta/pull/299))
- Create stable releases rather than boot releases ([#284](https://github.com/zopencommunity/meta/pull/284))

## April 2023
### ♻️ Refactoring
- Cleanup on a fresh build should remove configure/bootstrap success files ([#270](https://github.com/zopencommunity/meta/pull/270))
- Clean up syntax help message ([#269](https://github.com/zopencommunity/meta/pull/269))

### ✨ Features
- Add ZOPEN_TYPE=BARE for cases where the binaries already exist ([#277](https://github.com/zopencommunity/meta/pull/277))
- Add instructions on how to set bash as your default shell ([#272](https://github.com/zopencommunity/meta/pull/272))
- Improve OMVS support ([#264](https://github.com/zopencommunity/meta/pull/264))

### 🐛 Bug Fixes
- Fix broken zopen-setup by adding a cert for objects.githubusercontent.com ([#275](https://github.com/zopencommunity/meta/pull/275))
- Various fixes/changes to boottool.sh ([#213](https://github.com/zopencommunity/meta/pull/213))
- -Werror causes issues in the headers since they have warnings ([#260](https://github.com/zopencommunity/meta/pull/260))

### 🔍 Other Changes
- resolved conflict , raised new PR same as PR #242 under meta ([#261](https://github.com/zopencommunity/meta/pull/261))

## March 2023
### ♻️ Refactoring
- Retain Python path in PATH environment variable after cleanup ([#228](https://github.com/zopencommunity/meta/pull/228))
- clean up zopen build 'zopen_init' function ([#219](https://github.com/zopencommunity/meta/pull/219))

### ✨ Features
- Add slack message color for successful builds ([#255](https://github.com/zopencommunity/meta/pull/255))
- Add curl to the path when we run zopen install ([#225](https://github.com/zopencommunity/meta/pull/225))
- Progress page: add Projects with most patches + allow ports to skip publishing if no pax found ([#207](https://github.com/zopencommunity/meta/pull/207))

### 🐛 Bug Fixes
- Fix typo in description link ([ca94d5b](https://github.com/zopencommunity/meta/commit/ca94d5b6671041423983eaee0d3edfa0e2528a8b))
- Fix progress table for # of patches to consider all .patch files ([#222](https://github.com/zopencommunity/meta/pull/222))
- Fix zopen build -u breaking with initEnvironment changes by adding zopen path and curl path ([218033b](https://github.com/zopencommunity/meta/commit/218033bb973b8618b36933dc4b9475f1a1af2379))
- Use tar -axf now that its issues are resolved ([#211](https://github.com/zopencommunity/meta/pull/211))
- Ignore utime Invalid argument tar error ([#210](https://github.com/zopencommunity/meta/pull/210))

### 📚 Documentation
- add new guide on terminal config for non-US characters ([#259](https://github.com/zopencommunity/meta/pull/259))

### 🔄 CI/CD
- Add CICD params to force build with clang, no promotion boolean, and release level ([#247](https://github.com/zopencommunity/meta/pull/247))
- Handle read-only files when replacing hardcoded install paths ([#234](https://github.com/zopencommunity/meta/pull/234))
- Override global .gitattributes by specifying UTF-8 working tree encoding ([#227](https://github.com/zopencommunity/meta/pull/227))

### 🔍 Other Changes
- Change installing to checking in header ([#251](https://github.com/zopencommunity/meta/pull/251))
- Generate zoslib env hook ([#236](https://github.com/zopencommunity/meta/pull/236))
- Ignore .vscode directory ([#246](https://github.com/zopencommunity/meta/pull/246))
- Have 'git' generate a MANPATH entry ([#239](https://github.com/zopencommunity/meta/pull/239))
- Move _TAG_REDIR_* envars before functions ([#229](https://github.com/zopencommunity/meta/pull/229))
- changed the token reading var name ([#221](https://github.com/zopencommunity/meta/pull/221))
- Use default PATH/MANPATH/LIBPATH/etc before zopen build for consistent results ([#204](https://github.com/zopencommunity/meta/pull/204))
- change links from short link to original long form ([#217](https://github.com/zopencommunity/meta/pull/217))

### 🔧 Maintenance
- Update boot list to include sed, grep and gawk. Also print out the boot list on help ([#223](https://github.com/zopencommunity/meta/pull/223))

### 🧪 Testing
- Add expected total tests to zopen_check_results ([#254](https://github.com/zopencommunity/meta/pull/254))

## February 2023
### ♻️ Refactoring
- Step 1 of deps parsing of optional operator and version, and cleanup of envars ([#151](https://github.com/zopencommunity/meta/pull/151))

### ✨ Features
- Script to add branch protection to repos ([#200](https://github.com/zopencommunity/meta/pull/200))
- Script to automatically add teams to all repos ([#197](https://github.com/zopencommunity/meta/pull/197))
- Revert "add build timestamp" ([5c5debd](https://github.com/zopencommunity/meta/commit/5c5debd194ff61a01c8ae13ae0417cc590914789))
- add build timestamp ([440d7b5](https://github.com/zopencommunity/meta/commit/440d7b5042153548caee5e3364720a5dee4ed14e))
- Add support for $HOME/zopen as target location and running without _BPX_AUTOCVT set ([#150](https://github.com/zopencommunity/meta/pull/150))

### 🐛 Bug Fixes
- fix: use main as name for primary branch on git init ([#206](https://github.com/zopencommunity/meta/pull/206))
- work around bug in tar setting time for files ([#201](https://github.com/zopencommunity/meta/pull/201))
- Fix original dir var name when the port name has a - ([#198](https://github.com/zopencommunity/meta/pull/198))
- fix test.status ([88d534d](https://github.com/zopencommunity/meta/commit/88d534d6097c1b6c46893c398552f6bb900302bf))
- Fix FAQ links ([e7e3792](https://github.com/zopencommunity/meta/commit/e7e37923fad8e6dd425331dddeeb304417e5c42b))
- Fix status link ([e329f25](https://github.com/zopencommunity/meta/commit/e329f2513a9aad5b67176d972c6b98bafcb0a177))
- Fix quickstart ([4e10f51](https://github.com/zopencommunity/meta/commit/4e10f514649d2256fa0c5ff4d24137744dcae1a3))
- Add pre-install hook + fix unset ([#176](https://github.com/zopencommunity/meta/pull/176))
- Fix FAQ links ([#166](https://github.com/zopencommunity/meta/pull/166))
- Add gonumber + add error checking in update-cacert ([#163](https://github.com/zopencommunity/meta/pull/163))
- fix another typo ([#158](https://github.com/zopencommunity/meta/pull/158))
- update prefix on install ([#157](https://github.com/zopencommunity/meta/pull/157))
- Fix upgrade dependency call in zopen-build - prevents unnecessary re-install ([#156](https://github.com/zopencommunity/meta/pull/156))
- Add install option, also fix zopen download so that it sets up ports ([#153](https://github.com/zopencommunity/meta/pull/153))

### 📚 Documentation
- Create CODE_OF_CONDUCT.md ([#191](https://github.com/zopencommunity/meta/pull/191))
- Front-page gif + docsify theme updates ([#192](https://github.com/zopencommunity/meta/pull/192))
- rework the docs to provide more of a 'task focus' ([#179](https://github.com/zopencommunity/meta/pull/179))

### 🔄 CI/CD
- cicd changes ([2da24ff](https://github.com/zopencommunity/meta/commit/2da24ff14a84dfe8f012025ed02c541e083a487b))
- Use default install location in cicd ([#188](https://github.com/zopencommunity/meta/pull/188))
- .env sourcing of dependencies + download-only option ([#170](https://github.com/zopencommunity/meta/pull/170))
- Add support for installing runtime dependencies ([#160](https://github.com/zopencommunity/meta/pull/160))

### 🔍 Other Changes
- Change one liner install command to work for /bin/sh as well as bash ([#199](https://github.com/zopencommunity/meta/pull/199))
- Shorten the demo ([#193](https://github.com/zopencommunity/meta/pull/193))
- allow installs to be moveable ([#189](https://github.com/zopencommunity/meta/pull/189))
- Redirect output from cd - and popd to /dev/null ([#185](https://github.com/zopencommunity/meta/pull/185))
- Remove build timestamp in resulting directory for new and existing pax.Z packages ([#182](https://github.com/zopencommunity/meta/pull/182))
- use pushd/popd when in bash ([#181](https://github.com/zopencommunity/meta/pull/181))
- Various zopen-build Improvements ([#169](https://github.com/zopencommunity/meta/pull/169))
- Do not replace hardcoded paths in binaries ([#165](https://github.com/zopencommunity/meta/pull/165))
- Use /bin/iconv which converts EBCDIC ([#154](https://github.com/zopencommunity/meta/pull/154))

### 🔧 Maintenance
- Update publish.groovy for new directory name ([#187](https://github.com/zopencommunity/meta/pull/187))
- Improve zopen update cacert ([#155](https://github.com/zopencommunity/meta/pull/155))

### 🧪 Testing
- Place test.status in a known location ([a505fa1](https://github.com/zopencommunity/meta/commit/a505fa1f27f9942fec3c39276db2dc678fa27bc7))

## January 2023
### ✨ Features
- Delete existing install directory before extracting + Address binary files in .gitattributes + Use default UTF-8 encoding ([#147](https://github.com/zopencommunity/meta/pull/147))
- Add monitor_vpc.sh script ([#141](https://github.com/zopencommunity/meta/pull/141))
- Add checks for safer setup ([#137](https://github.com/zopencommunity/meta/pull/137))
- Add new 'common solution' for S_TYPExxx macros ([#133](https://github.com/zopencommunity/meta/pull/133))
- Add install-or-upgrade option to zopen download to eliminate having to re-download packages every build ([#132](https://github.com/zopencommunity/meta/pull/132))
- provide cacert support for metaport, git, curl ([#128](https://github.com/zopencommunity/meta/pull/128))
- Add initial FAQ ([#109](https://github.com/zopencommunity/meta/pull/109))
- Add .gitattributes ([9527784](https://github.com/zopencommunity/meta/commit/95277843cbba45742c8bb3b4fba6cdeca9352881))
- addressed changes related to boottool - Enhanced the tool to retain t… ([#104](https://github.com/zopencommunity/meta/pull/104))
- Add pre-req project links and license info ([#102](https://github.com/zopencommunity/meta/pull/102))

### 🐛 Bug Fixes
- Fix pager so it uses cat on xlclang + pass along LDLIBS as libs for zstd ([#148](https://github.com/zopencommunity/meta/pull/148))
- fix: update zopen-setup help to match current behaviour ([#138](https://github.com/zopencommunity/meta/pull/138))
- change order of tools to be set up from .bootenv and fixed UX issues ([#131](https://github.com/zopencommunity/meta/pull/131))
- Support OAUTH and provide better error messages for zopen-setup ([#129](https://github.com/zopencommunity/meta/pull/129))
- fix merge conflict ([dcd18ed](https://github.com/zopencommunity/meta/commit/dcd18ed3280600d9aec5468e5c72ca4dcb52e699))
- Fix setup.sh script ([#126](https://github.com/zopencommunity/meta/pull/126))
- fixed issue of - https://github.com/ZOSOpenTools/utils/issues/136 ([#137](https://github.com/zopencommunity/meta/pull/137))
- Fix merge conflicts ([64a951b](https://github.com/zopencommunity/meta/commit/64a951bfc5148942492696cb5284e2e717d910cf))
- Fix permissions for bin/lib/zopen-build ([#133](https://github.com/zopencommunity/meta/pull/133))

### 📚 Documentation
- Various documentation updates ([#124](https://github.com/zopencommunity/meta/pull/124))

### 🔄 CI/CD
- Add git as an implicit dep since we use it to initialize the tar source dir as a git repo ([#149](https://github.com/zopencommunity/meta/pull/149))
- Add the actual dependent projects in the table "Projects with the most dependencies" ([#106](https://github.com/zopencommunity/meta/pull/106))

### 🔍 Other Changes
- Move setup.sh to end of .env so that you can use envars in setup.sh ([#144](https://github.com/zopencommunity/meta/pull/144))
- Increase buffer size used for GitHub token. ([#139](https://github.com/zopencommunity/meta/pull/139))
- Migrate source to OpenXL ([#140](https://github.com/zopencommunity/meta/pull/140))
- Use /bin/echo to intrepret backslash escapes. Modern echo requires -e option ([#136](https://github.com/zopencommunity/meta/pull/136))
- Move to open source tar in zopen build code ([#135](https://github.com/zopencommunity/meta/pull/135))
- Merge pull request #127 from ZOSOpenTools/change_zopen_download ([794575c](https://github.com/zopencommunity/meta/commit/794575cbdc46e352b1c6d0fd3bd149f199b66a0e))
- No need to clone meta since we're already in it ([3b8cc66](https://github.com/zopencommunity/meta/commit/3b8cc66b094d23873e43d6fc7b814221aedf08fa))
- Avoid processing files in .env if there are no hardcoded paths + separate setup from environment variables ([#135](https://github.com/zopencommunity/meta/pull/135))
- Don't let the ZOPEN_CHECK process become an orphaned process upon early exit ([#134](https://github.com/zopencommunity/meta/pull/134))

### 🔧 Maintenance
- Update all references to utils and change them to meta ([9c19fef](https://github.com/zopencommunity/meta/commit/9c19fefec154fd0ce4471445abbf5daea1b7a5ec))

## December 2022
### ✨ Features
- Add generate pax option ([#101](https://github.com/zopencommunity/meta/pull/101))
- Add symlink support + optionally generate pax.Z file ([#129](https://github.com/zopencommunity/meta/pull/129))
- Support Github oauth token for downloads ([#98](https://github.com/zopencommunity/meta/pull/98))
- Add vim on z/OS article ([#94](https://github.com/zopencommunity/meta/pull/94))
- add option to only checkout the source ([#124](https://github.com/zopencommunity/meta/pull/124))
- add clang support ([#123](https://github.com/zopencommunity/meta/pull/123))

### 🐛 Bug Fixes
- fix for requirement to retain retain previous boot releases while creating new boot release ([#99](https://github.com/zopencommunity/meta/pull/99))
- Enable compiler informational messages, and fix the results ([#97](https://github.com/zopencommunity/meta/pull/97))
- Better error message when destination is read-only ([#95](https://github.com/zopencommunity/meta/pull/95))

### 🔍 Other Changes
- Commit iD retaining for the boot-release created ([#91](https://github.com/zopencommunity/meta/pull/91))
- Improve legibility of status bar chart ([#100](https://github.com/zopencommunity/meta/pull/100))
- Remove colons from headings ([#90](https://github.com/zopencommunity/meta/pull/90))
- Adjust directory permissions ([#96](https://github.com/zopencommunity/meta/pull/96))

### 🔧 Maintenance
- Create .zopen-config file with zopen-init, and also update zopen-build/download to depend on it ([#131](https://github.com/zopencommunity/meta/pull/131))

## November 2022
### ✨ Features
- add LDLIBS (used by openssl) + add .gitignore in zopen-generate ([#104](https://github.com/zopencommunity/meta/pull/104))
- Support for tags in zopen download, update only if newer releases are found + more ([#97](https://github.com/zopencommunity/meta/pull/97))

### 🐛 Bug Fixes
- Fix small typo on Getting Started page ([#88](https://github.com/zopencommunity/meta/pull/88))
- force rebuild option (-f) + override log dir with ZOPEN_LOG_DIR + fix -DCPPFLAGS in configure opts ([#102](https://github.com/zopencommunity/meta/pull/102))
- fix: correctly test for help flag ([#99](https://github.com/zopencommunity/meta/pull/99))

### 💄 Style
- Update getbinaries.py to get dependent project information ([9f3c7f8](https://github.com/zopencommunity/meta/commit/9f3c7f8d1a9e16d5d23987b87dd642eefba3e4dc))

### 📚 Documentation
- Add initial docs on zoslib ([#83](https://github.com/zopencommunity/meta/pull/83))
- Update docs for common problems ASCII open and FSUM msg ([#82](https://github.com/zopencommunity/meta/pull/82))
- Update Pre-req.md ([#72](https://github.com/zopencommunity/meta/pull/72))

### 🔄 CI/CD
- Update cicd tool to report more status ([e69b95d](https://github.com/zopencommunity/meta/commit/e69b95da5cd2315896b0407dd23e9f0455638aee))
- Update cicd/build.groovy to always update ([1b4cd9e](https://github.com/zopencommunity/meta/commit/1b4cd9e9d2ed03c2138c895140d525bef172c3e0))

### 🔍 Other Changes
- initial commit of boot tool ([#81](https://github.com/zopencommunity/meta/pull/81))
- Getting started ([#70](https://github.com/zopencommunity/meta/pull/70))
- mention rocket curl for consumers ([#69](https://github.com/zopencommunity/meta/pull/69))

### 🔧 Maintenance
- update from origin ([#1](https://github.com/zopencommunity/meta/pull/1))

### 🧪 Testing
- get latest releases instead of the first one ([ec8968f](https://github.com/zopencommunity/meta/commit/ec8968f01b1ea127477042348f28782249d44fb1))

## October 2022
### ✨ Features
- Add a ZOPEN_MAKE_MINIMAL + NSIG=42 - needed for ncurses/bash, respectively ([#96](https://github.com/zopencommunity/meta/pull/96))
- Add codeowners file for default PR reviewers ([#92](https://github.com/zopencommunity/meta/pull/92))
- zopen-generate: check for port in name + add .gitattributes ([8da7e53](https://github.com/zopencommunity/meta/commit/8da7e536bc33c298c9da5946431ff4eb97c3f591))
- Add -qenum=int as a default compiler option ([#79](https://github.com/zopencommunity/meta/pull/79))
- added clarification around the C/C++ build compiler ([#53](https://github.com/zopencommunity/meta/pull/53))

### 🐛 Bug Fixes
- Add CEE3728S to list of common issues ([#55](https://github.com/zopencommunity/meta/pull/55))
- fix `git add` on tarball files that contain a space ([#87](https://github.com/zopencommunity/meta/pull/87))
- Print check results output when it contains errors ([#86](https://github.com/zopencommunity/meta/pull/86))
- zopen-generate fixes (check for port in name + create .gitattributes file) ([#84](https://github.com/zopencommunity/meta/pull/84))
- Added fix for issue https://github.com/ZOSOpenTools/utils/issues/81 ([#82](https://github.com/zopencommunity/meta/pull/82))
- Add contributing.md file + fix tagging in zopen generate ([#78](https://github.com/zopencommunity/meta/pull/78))
- Added fix for issue https://github.com/ZOSOpenTools/utils/issues/56 ([#69](https://github.com/zopencommunity/meta/pull/69))
- fix chtag in git ([#72](https://github.com/zopencommunity/meta/pull/72))

### 📚 Documentation
- Add pre-req documentation + sidebar changes + progress page ([#58](https://github.com/zopencommunity/meta/pull/58))

### 🔄 CI/CD
- Adds support for specifying LIBS (needed to link with ZOSLIB) ([#76](https://github.com/zopencommunity/meta/pull/76))

### 🔍 Other Changes
- tolerate spaces in zopen_check_results output ([#75](https://github.com/zopencommunity/meta/pull/75))
- More granular percentage + check for numbers in zopen_check_results o… ([#74](https://github.com/zopencommunity/meta/pull/74))

### 🧪 Testing
- capture stderr from tests which could hold info on test statistics ([#83](https://github.com/zopencommunity/meta/pull/83))

## September 2022
### ✨ Features
- Add more details about zopen generate/hooks ([#59](https://github.com/zopencommunity/meta/pull/59))
- add example for open() and tagging ([#41](https://github.com/zopencommunity/meta/pull/41))
- added a note about creating patches from directories in .gitignore ([#38](https://github.com/zopencommunity/meta/pull/38))
- Adds default .env (with ability to append entries) ([#52](https://github.com/zopencommunity/meta/pull/52))

### 🐛 Bug Fixes
- Preserve attributes on unpax + don't rename .git + fix chtag errors for empty patch directory + --buildtype option + add details for zopen_check_results ([#66](https://github.com/zopencommunity/meta/pull/66))
- fix pipeline ([8c1d956](https://github.com/zopencommunity/meta/commit/8c1d956e85ffca97970df4e36ea115438d7db3d9))
- Quick fix for test status typo ([2daf410](https://github.com/zopencommunity/meta/commit/2daf410afa2e6704edb1c71da698c61f9e2427f8))
- Fix return codes getting reset after piping to tee ([#60](https://github.com/zopencommunity/meta/pull/60))
- Fix hardcoded paths by replacing them with ZOPEN_INSTALL_ROOT and then replace to the installed path in the .env ([#54](https://github.com/zopencommunity/meta/pull/54))

### 📚 Documentation
- Update Porting.md ([#42](https://github.com/zopencommunity/meta/pull/42))

### 🔍 Other Changes
- expand on FSUM problem ([#43](https://github.com/zopencommunity/meta/pull/43))
- Display command output when verbose is active ([#58](https://github.com/zopencommunity/meta/pull/58))
- preserve file permissions when modifying files in install dir ([#55](https://github.com/zopencommunity/meta/pull/55))

### 🧪 Testing
- Always run tests and set TMPDIR ([#51](https://github.com/zopencommunity/meta/pull/51))
- Test infrastructure changes + zopen generate updates + envar updates ([#63](https://github.com/zopencommunity/meta/pull/63))
- filter install/test.status ([0888074](https://github.com/zopencommunity/meta/commit/0888074380cfab9ebcbcffaab107bf42ab83a071))
- Allow for optional running of tests and propogate test.status file ([#45](https://github.com/zopencommunity/meta/pull/45))
- Allow ZOPEN_ROOT to be referenced in buildenv + Use variables for test return codes ([#62](https://github.com/zopencommunity/meta/pull/62))

## August 2022
### ✨ Features
- add check that 'git' and 'xlclang' are 'new enough' ([#39](https://github.com/zopencommunity/meta/pull/39))

### 🐛 Bug Fixes
- Build/Publish OCI images + misc fixes ([#38](https://github.com/zopencommunity/meta/pull/38))
- Move accessory scripts to lib dir + fix for garbled characters in runAndLog ([#47](https://github.com/zopencommunity/meta/pull/47))
- Fix description to source .env in current directory ([#20](https://github.com/zopencommunity/meta/pull/20))
- Change PORT_INSTALL_DIR to ZOPEN_INSTALL_DIR + Update Latest.md + Fix attributes for png files ([#18](https://github.com/zopencommunity/meta/pull/18))
- Fix build.groovy to run zopen build ([#14](https://github.com/zopencommunity/meta/pull/14))

### 📚 Documentation
- docs: Update Porting.md ([#34](https://github.com/zopencommunity/meta/pull/34))
- Update README.md to document zopen download ([#48](https://github.com/zopencommunity/meta/pull/48))
- Update documentation ([#25](https://github.com/zopencommunity/meta/pull/25))

### 🔄 CI/CD
- add back in option to let us specify a sub-directory to build out of ([#46](https://github.com/zopencommunity/meta/pull/46))

### 🔍 Other Changes
- resolve commands before startShell ([#45](https://github.com/zopencommunity/meta/pull/45))
- Primecache ([#43](https://github.com/zopencommunity/meta/pull/43))
- Tag untracked files as well (new files created from patches) ([#41](https://github.com/zopencommunity/meta/pull/41))

### 🔧 Maintenance
- updates from Nate Myers suggestions ([#28](https://github.com/zopencommunity/meta/pull/28))

## July 2022
### ✨ Features
- Define env in common.inc + add C11 as default + continue downloading after bad extract ([#37](https://github.com/zopencommunity/meta/pull/37))
- add configure-minimal option so that ZLIB will be ok with configure ([#36](https://github.com/zopencommunity/meta/pull/36))
- Add skipcheck option + show help when no params are passed to zopen ([#33](https://github.com/zopencommunity/meta/pull/33))

### 📚 Documentation
- Update documentation with zopen details ([#15](https://github.com/zopencommunity/meta/pull/15))
- Update readme with zopen build changes ([#32](https://github.com/zopencommunity/meta/pull/32))
- Added a tool (cloneall) and added doc on 'order to build' ([#12](https://github.com/zopencommunity/meta/pull/12))

### 🔄 CI/CD
- Add more details regarding CI/CD ([#16](https://github.com/zopencommunity/meta/pull/16))
- zopen convention changes to script files + -e option to specify custom buildenv + -d option to specify deps search paths ([#27](https://github.com/zopencommunity/meta/pull/27))

### 🔍 Other Changes
- Skip step if the command is not found ([#35](https://github.com/zopencommunity/meta/pull/35))
- Checkexe ([#34](https://github.com/zopencommunity/meta/pull/34))
- remove check that BOOTSTRAP and CONFIGURE are executable because need… ([#28](https://github.com/zopencommunity/meta/pull/28))

## June 2022
### ✨ Features
- Add info on creating a repo under zosopentools ([#10](https://github.com/zopencommunity/meta/pull/10))

### 🐛 Bug Fixes
- Add support for PORT_EXTRA_CPPFLAGS PORT_EXTRA_CONFIGURE_OPTS + fix t… ([#17](https://github.com/zopencommunity/meta/pull/17))
- Fix make check + log ([#16](https://github.com/zopencommunity/meta/pull/16))
- Add ability to set num of jobs for make + extra error checks ([#10](https://github.com/zopencommunity/meta/pull/10))

### 📚 Documentation
- Add a link to the documentation ([#9](https://github.com/zopencommunity/meta/pull/9))
- Add initial pipeline documentation + add generate binaries page ([#8](https://github.com/zopencommunity/meta/pull/8))
- improve doc ([da71f81](https://github.com/zopencommunity/meta/commit/da71f81b1be6acff9fc9ccd9397cfedfbfb4469a))

### 🔄 CI/CD
- Add initial cicd jenkins scripts to meta ([#11](https://github.com/zopencommunity/meta/pull/11))
- Customize installation for Jenkins ([#11](https://github.com/zopencommunity/meta/pull/11))

### 🔍 Other Changes
- Merge pull request #26 from ZOSOpenTools/jshimoda-dev ([ad3c5c2](https://github.com/zopencommunity/meta/commit/ad3c5c2be9be931391e9f57f4522312f5721a4fa))
- Openssl enablement ([#21](https://github.com/zopencommunity/meta/pull/21))
- WIP: download script for github releases ([#24](https://github.com/zopencommunity/meta/pull/24))
- Some enhancements to build.sh ([#18](https://github.com/zopencommunity/meta/pull/18))
- Help ([#12](https://github.com/zopencommunity/meta/pull/12))
- moved build.sh details into build.sh ([5421784](https://github.com/zopencommunity/meta/commit/54217847641516356f61c59bd9e037559f263aca))
- A few general enhancements to build.sh ([#7](https://github.com/zopencommunity/meta/pull/7))

### 🔧 Maintenance
- merge igors updates ([7bbe6da](https://github.com/zopencommunity/meta/commit/7bbe6da9d9a966533410933189d692374c34573e))

## May 2022
### ✨ Features
- added portcrtenv.sh for git ([#6](https://github.com/zopencommunity/meta/pull/6))
- add in git attributes for easy z/os extraction ([f3e04e1](https://github.com/zopencommunity/meta/commit/f3e04e11c4e108355c9cad5aed60c709040163c1))

### 💄 Style
- Adds colour coding of output, verbose output, and formats build.sh ([#8](https://github.com/zopencommunity/meta/pull/8))

### 📚 Documentation
- Update CommonSolutions.md ([5e12c4b](https://github.com/zopencommunity/meta/commit/5e12c4be2986b2365465638eca2a28f28e208c17))
- Update CommonSolutions.md ([42930c2](https://github.com/zopencommunity/meta/commit/42930c2e8222ee82f5abe3dddd024c62896e15be))
- Additions to Porting.md ([#6](https://github.com/zopencommunity/meta/pull/6))
- added base docs for porting ([2980498](https://github.com/zopencommunity/meta/commit/2980498d621a6340ce41565562648c1715e98ff3))

### 🔍 Other Changes
- Igor review 2 ([#4](https://github.com/zopencommunity/meta/pull/4))
- Igor review 2 ([#3](https://github.com/zopencommunity/meta/pull/3))
- Initial framework for github pages ([#5](https://github.com/zopencommunity/meta/pull/5))
- merge ([e6dfd8d](https://github.com/zopencommunity/meta/commit/e6dfd8d58ce242e6d7ec883667d90f3c359effbd))
- Starter code for general purpose build.sh for ports ([#2](https://github.com/zopencommunity/meta/pull/2))

## November 2021
### 📚 Documentation
- Update README.md ([6aa1a69](https://github.com/zopencommunity/meta/commit/6aa1a6953a8f706c7f1a5bd18e484242cdb3e0a9))

### 🔍 Other Changes
- Initial commit ([47ef9db](https://github.com/zopencommunity/meta/commit/47ef9db03436b70e8ea391f988ebc1b2513daf0c))

