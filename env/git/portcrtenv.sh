#!/bin/sh
install_dir="$1"

cat <<zz >"${install_dir}/.env"
if ! [ -f ./.env ]; then
        echo "Need to source from the .env directory" >&2
        return 0
fi
mydir="${PWD}"
export PATH="${mydir}/bin:$PATH"
export GIT_EXEC_PATH=${mydir}/ported/libexec/git-core
export GIT_ROOT=${mydir}
export GIT_SHELL=/bin/bash
export GIT_TEMPLATE_DIR=${mydir}/share/git-core/templates
export GIT_PAGER=cat git diff
export GIT_MAN_PATH=${mydir}/ported/man
zz
exit 0
