#!/bin/bash

REPO_TOP="$(git rev-parse --show-toplevel)"
eval_dir="${REPO_TOP}/riker"
input_dir="${eval_dir}/input/scripts/autoconf"
scripts_dir="${eval_dir}/scripts/autoconf"

BENCHMARK_SHELL=${BENCHMARK_SHELL:-bash}
BENCHMARK_SCRIPT="$(realpath "$scripts_dir/build.sh")"
export BENCHMARK_SCRIPT
(cd "$input_dir/dev" && $BENCHMARK_SHELL "$scripts_dir/build.sh")


