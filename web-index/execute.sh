#!/usr/bin/env bash

cd "$(dirname "$0")" || exit 1

BENCHMARK_SHELL=${BENCHMARK_SHELL:-bash}
export BENCHMARK_CATEGORY="web-index"

# ensure a local ./tmp directory exists for sorting
mkdir -p ./tmp
export TMPDIR=$PWD/tmp

INPUTS="$PWD/inputs"
OUTPUT_BASE="$PWD/outputs/ngrams"

suffix=""
for arg in "$@"; do
    if [ "$arg" = "--small" ]; then
        suffix="_small"
        break
    elif [ "$arg" = "--min" ]; then
        suffix="_min"
        break
    fi
done
INPUT_FILE="$INPUTS/index$suffix.txt"

export INPUT_FILE

directory_path="inputs/articles$suffix"

if [ ! -d "$directory_path" ]; then
	    echo "Error: Directory does not exist."
      exit 1
fi

mkdir -p "$OUTPUT_BASE"

echo "web-index"
BENCHMARK_SCRIPT="$(realpath "./scripts/ngrams.sh")"
export BENCHMARK_SCRIPT

BENCHMARK_INPUT_FILE="$(realpath "$INPUT_FILE")"
export BENCHMARK_INPUT_FILE

$BENCHMARK_SHELL "./scripts/ngrams.sh" "$OUTPUT_BASE" "$directory_path"
echo $?
