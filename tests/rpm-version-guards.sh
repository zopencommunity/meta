#!/bin/sh
# Isolated guard regressions; no RPM database, signing, network, or project build.
set -eu
repo=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd -P)
umask 077
work=$(mktemp -d "${TMPDIR:-/tmp}/rpm-version-guards.XXXXXXXX")
trap 'rm -rf "$work"' 0
trap 'exit 1' HUP INT TERM
mkdir -p "$work/bin" "$work/include" "$work/tmp" "$work/home" "$work/install"
TMPDIR="$work/tmp" HOME="$work/home" RPM_TEST_MARKER="$work/delegated"
export TMPDIR HOME RPM_TEST_MARKER
PATH="$work/bin:$PATH"
export PATH
log="$work/test.log"
fail() { printf 'FAIL: %s\n' "$*" >&2; [ ! -f "$log" ] || cat "$log" >&2; exit 1; }
# Never retag EBCDIC as ASCII. Inspect raw bytes before tagging private fixtures.
ascii_tag() {
    if [ "$(uname -s)" = 'OS/390' ]; then
        raw=$(_BPXK_AUTOCVT=OFF od -An -tx1 -N1 "$1" | tr -d '[:space:]')
        [ "$raw" = 23 ] || fail "not raw ASCII (expected leading #): $1 ($raw)"
        chtag -t -c ISO8859-1 "$1"
    fi
}
extract() {
    awk -v fn="$1" '
        BEGIN { print "# Extracted from the actual production source" }
        $0 == fn "()" { active=1; found++ }
        active { print }
        active && /^}/ { active=0; done++ }
        END { if (found != 1 || done != 1) exit 1 }
    ' "$2" > "$3" || fail "cannot extract $1"
    ascii_tag "$3"
}
extract normalizeVersion "$repo/include/common.sh" "$work/normalize.sh"
extract normalizeRpmVersion "$repo/include/common.sh" "$work/normalize-rpm.sh"
cat > "$work/include/common.sh" <<'EOF'
# Minimal common stub: normalization below is extracted, not reimplemented.
printInfo() { :; }
printWarning() { :; }
printHeader() { :; }
printError() { printf '%s\n' "$*" >&2; exit 1; }
. "$INCDIR/../normalize.sh"
. "$INCDIR/../normalize-rpm.sh"
case "${RPM_TEST_FAULT:-}" in
    status) normalizeRpmVersion() { return 17; } ;;
    empty) normalizeRpmVersion() { return 0; } ;;
    spaces) normalizeRpmVersion() { printf ' \t\n'; } ;;
esac
EOF
cat > "$work/bin/rpm" <<'EOF'
#!/bin/sh
[ "$#" = 2 ] && [ "$1" = --eval ] && [ "$2" = '%{_target_cpu}' ] || exit 99
printf 's390x\n'
EOF
cat > "$work/bin/pax" <<'EOF'
#!/bin/sh
printf '%s\n' '-rwxr-xr-x 1 test test 1 Jan 1 00:00 php/bin/php'
EOF
cat > "$work/bin/zopen-rpmbuild" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > "$RPM_TEST_MARKER"
EOF
for file in "$work/include/common.sh" "$work/bin/"*; do ascii_tag "$file"; done
chmod +x "$work/bin/"*
cp "$repo/bin/zopen-pax2rpm" "$work/original.sh"
ascii_tag "$work/original.sh"
reset_generator() {
    cp "$work/original.sh" "$work/bin/zopen-pax2rpm"
    ascii_tag "$work/bin/zopen-pax2rpm"
    chmod +x "$work/bin/zopen-pax2rpm"
    rm -f "$work/php.spec" "$RPM_TEST_MARKER" "$log"
}
run_generator() {
    archive=$1; shift
    : > "$work/$archive"
    (cd "$work" && sh "$work/bin/zopen-pax2rpm" "$work/$archive" \
        --summary 'Guard fixture' --build-binary --buildroot "$work/rpmbuild" ${1+"$@"}) > "$log" 2>&1
}
check_spec() {
    awk -v expected="$1" '
        /^%description/ { exit }
        /^Version:/ { n++; if ($0 == "Version:        " expected) good++ }
        END { exit !(n == 1 && good == 1) }
    ' "$work/php.spec" || fail "wrong or duplicate Version tag ($1)"
    grep -q '^Name:           php$' "$work/php.spec" || fail 'wrong filename-derived name'
    [ -f "$RPM_TEST_MARKER" ] || fail 'valid spec did not delegate to stub'
}
. "$work/normalize.sh"
. "$work/normalize-rpm.sh"
for version in 8.2.35 v8.2.35 V8.2.35 8.2.35rc1 8.2.35-rc1 8.2.35.rc1 '8.2.35~rc1'; do
    case "$version" in *rc1) expected='8.2.35~rc1' ;; *) expected=8.2.35 ;; esac
    normalized=$(normalizeRpmVersion "$version") || fail "normalizer failed: $version"
    [ "$normalized" = "$expected" ] || fail "normalization: $version -> $normalized"
    [ "$(normalizeRpmVersion "$normalized")" = "$normalized" ] || fail 'not idempotent'
    reset_generator
    run_generator "php-$version.zos.pax.Z" || fail "filename default: $version"
    check_spec "$expected"
done
reset_generator
run_generator php-1.0.zos.pax.Z --pkg-version V8.2.35 || fail 'explicit version override'
check_spec 8.2.35
reset_generator
run_generator php-8.2.35.zos.pax.Z --description 'Version: body text, not a header' || fail 'description confused with header'
check_spec 8.2.35
grep -q '^Version: body text, not a header$' "$work/php.spec" || fail 'description not exercised'
for fault in status empty spaces; do
    for archive in php-8.2.35.zos.pax.Z opaque.pax; do
        reset_generator
        if RPM_TEST_FAULT=$fault run_generator "$archive" --name php --pkg-version 8.2.35; then
            fail "accepted normalizer fault: $fault ($archive)"
        fi
        [ ! -e "$work/php.spec" ] || fail "normalizer fault emitted spec: $fault"
        [ ! -e "$RPM_TEST_MARKER" ] || fail "normalizer fault delegated: $fault"
    done
done
# Mutate only the private generator, exercising its independent post-write guard.
for mutation in blank clobber; do
    reset_generator
    awk -v mutation="$mutation" '
        mutation == "blank" && /^Version:/ { print "Version:"; n++; next }
        { print }
        mutation == "clobber" && /^    analyze_pax_contents "\$source_file"$/ {
            print "    PKG_VERSION=\"\""; n++
        }
        END { if (n != 1) exit 1 }
    ' "$work/original.sh" > "$work/bin/zopen-pax2rpm" || fail "mutation anchor: $mutation"
    ascii_tag "$work/bin/zopen-pax2rpm"
    if run_generator php-8.2.35.zos.pax.Z; then fail "accepted $mutation spec"; fi
    [ -s "$work/php.spec" ] || fail "$mutation spec not retained"
    grep -q '^Version:[[:space:]]*$' "$work/php.spec" || fail "$mutation not exercised"
    [ ! -e "$RPM_TEST_MARKER" ] || fail "$mutation spec delegated"
done
# Source just create_rpm, never execute zopen-build or the logged command.
extract create_rpm "$repo/bin/zopen-build" "$work/create-rpm.sh"
create_fixture() (
    printError() { printf '%s\n' "$*" >&2; exit 1; }
    printHeader() { :; }
    getProjectName() { printf 'php\n'; }
    runAndLog() { printf '%s\n' "$1" > "$RPM_TEST_MARKER"; }
    ZOPEN_INSTALL_DIR="$work/install" ZOPEN_NAME=php ZOPEN_ROOT="$work"
    ZOPEN_RUNTIME_DEPS='meta zlib' MYDIR="$work/bin"
    paxFileName="$work/php-8.2.35.zos.pax.Z" signRPM=false forceUpgradeDeps=false
    . "$work/create-rpm.sh"
    create_rpm
)
for field in .version .buildtimestamp; do
    for invalid in missing empty whitespace; do
        printf '8.2.35\n' > "$work/install/.version"
        printf '20260101_123456\n' > "$work/install/.buildtimestamp"
        case "$invalid" in
            missing) rm -f "$work/install/$field" ;;
            empty) : > "$work/install/$field" ;;
            whitespace) printf ' \t\n\n' > "$work/install/$field" ;;
        esac
        rm -f "$RPM_TEST_MARKER"
        if create_fixture > "$log" 2>&1; then fail "accepted $invalid $field"; fi
        [ ! -e "$RPM_TEST_MARKER" ] || fail "delegated with $invalid $field"
    done
done
printf '8.2.35\n' > "$work/install/.version"
printf '20260101_123456\n' > "$work/install/.buildtimestamp"
create_fixture > "$log" 2>&1 || fail 'valid create_rpm metadata rejected'
command=$(cat "$RPM_TEST_MARKER")
case "$command" in *' --pkg-version "8.2.35" '*) ;; *) fail 'missing explicit --pkg-version' ;; esac
case "$command" in *' --release "20260101.123456" '*) ;; *) fail 'wrong timestamp release' ;; esac
case "$command" in *' --version '*) fail 'ambiguous --version used' ;; esac
printf 'PASS: isolated RPM version guard regressions\n'
