#!/bin/bash
BENCHMARK_SHELL=${BENCHMARK_SHELL:-bash}
REPO_TOP=$(git rev-parse --show-toplevel)
eval_dir="${REPO_TOP}/vps-audit"
scripts_dir="${eval_dir}/scripts"
main_script="${scripts_dir}/vps-audit.sh"
mkdir -p "${eval_dir}/outputs"
echo "Starting VPS audit..."
${BENCHMARK_SHELL} "${main_script}"
echo $?
