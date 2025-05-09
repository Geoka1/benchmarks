#!/bin/bash
set -e

REPO_TOP=$(git rev-parse --show-toplevel)
eval_dir="${REPO_TOP}/ray-tracing"
INPUT_DIR="${REPO_TOP}/ray-tracing/inputs"
mkdir -p "$INPUT_DIR"

# TODO add inputs
# Simulate input fetch (replace with actual source)
# curl -o "$INPUT_DIR/1.INFO" <URL>
# curl -o "$INPUT_DIR/2.INFO" <URL>
cp $eval_dir/min_inputs/* "$INPUT_DIR"