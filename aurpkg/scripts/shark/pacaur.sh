#!/bin/bash

IN="$1"
OUT="$2"
MAX_PROCS=${MAX_PROCS:-$(nproc)}

mkcd() {
    mkdir -p "$1" || return 1
    cd "$1" || return 1
}

# set link to plaintext PKGBUILDs
URL='https://atlas.cs.brown.edu/data/aurpkg'

run_tests() {
    pkg=$1
    ORIG_DIR=$(pwd)

    mkcd "${OUT}/$pkg" || exit 1

    curl --insecure -o PKGBUILD "$URL/$pkg/PKGBUILD" 2>/dev/null || echo ' '

    gpg --recv-keys $(sed -n "s:^validpgpkeys=('\([0-9A-Fa-fx]\+\)').*$:\1:p" PKGBUILD)

    if [ "$EUID" -eq 0 ]; then
        chown -R user:user "$OUT"
        runuser -u user -p -- makedeb -d >"../$pkg.txt" 2>&1 || true
    else
        makedeb -d >"../$pkg.txt" 2>&1 || true
    fi 
    cd "$ORIG_DIR" || exit 1
}

export -f run_tests

pkg_count=0

while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    pkg_count=$((pkg_count + 1))
    count_copy=$pkg_count
    echo "$pkg"

    (
        run_tests "$pkg" > "${OUT}/${count_copy}.txt" 2>&1
    ) &

    ((current_jobs++))

    if (( current_jobs >= MAX_PROCS )); then
        wait -n
        ((current_jobs--))
    fi
done < "$IN"

wait