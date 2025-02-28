#!/bin/bash

ORIGINAL_REPO="/benchmarks"

# mkdir /benchmarks/temp if it doesn't exist
mkdir -p /benchmarks/temp

cd /benchmarks/temp
git clone https://github.com/Geoka1/benchmarks.git
git switch feb
cd benchmarks

MODIFIED_SUITE_BASE="/benchmarks/temp/benchmarks"

MODIFIED_SUITE="$MODIFIED_SUITE_BASE"

while getopts ":s:" opt; do
  case $opt in
    s) MODIFIED_SUITE="$MODIFIED_SUITE_BASE/infrastructure/systems/$OPTARG";;
    \?) echo "Usage: $0 [-s SYSTEM]"; exit 1;;
  esac
done

sync_benchmarks() {
    local src="$1"
    local dest="$2"

    for benchmark in "$src"/*; do
        if [ -d "$benchmark" ]; then
            benchmark_name=$(basename "$benchmark")

            if [[ "$benchmark_name" == "infrastructure" || "$benchmark_name" == "temp" ]]; then
                echo "Skipping $benchmark_name directory"
                continue
            fi

            dest_benchmark="$dest/$benchmark_name"
            mkdir -p "$dest_benchmark"

            rsync -av --exclude 'input' "$benchmark/" "$dest_benchmark/"
            echo "Synced $benchmark_name to $dest_benchmark"
        fi
    done
}

sync_benchmarks "$MODIFIED_SUITE" "$ORIGINAL_REPO"
