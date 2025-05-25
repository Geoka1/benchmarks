#!/usr/bin/env python3
"""
Summarize shell workloads:
  * number of distinct shell‑syntax constructs  (#Cons)
  * number of unique external commands invoked (#Cmd)

Outputs two CSV files by default:
  • ``constructs_commands_summary.csv``            – per *benchmark*
  • ``constructs_commands_summary_scripts.csv``    – per *script* **plus** one
    extra row per benchmark that aggregates its scripts (rows have ``script = 'none'``)

CLI options
-----------
```
  -o, --output FILE           Override benchmark‑level CSV path
  -s, --scripts-output FILE   Override script‑level CSV path
  --stdout                    Also print both tables to terminal
```

Example
~~~~~~~
::

    $ python constructs_commands_summary.py --stdout \
        -o bench_metrics.csv -s script_metrics.csv
"""
from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd
import viz.syntax as stx

###############################################################################
# Helper functions                                                             #
###############################################################################

def _count_unique_cmds(nodes: pd.Series) -> int:
    """Return the number of distinct ``command(" nodes in *nodes*."""
    return len({n for n in nodes if "command(" in n})


def _count_constructs(nodes: pd.Series) -> int:
    """Return the number of distinct shell‑syntax node kinds in *nodes*."""
    return len(set(nodes))

###############################################################################
# Metric builders                                                              #
###############################################################################

def _build_benchmark_metrics() -> pd.DataFrame:
    """Compute #Cons / #Cmd per benchmark."""
    _, syntax_bench = stx.read_data(True)   # constructs (filtered)
    _, all_cmds     = stx.read_data(False)  # commands   (full)

    syntax_bench["#Cons"] = syntax_bench["nodes"].apply(_count_constructs)
    all_cmds["#Cmd"]      = all_cmds["nodes"].apply(_count_unique_cmds)

    return (
        syntax_bench[["benchmark", "#Cons"]]
        .merge(all_cmds[["benchmark", "#Cmd"]], on="benchmark")
        .sort_values("benchmark", kind="stable")
    )


def _build_script_metrics() -> pd.DataFrame:
    """Compute #Cons / #Cmd per individual script, **plus** an aggregate row per
    benchmark placed on top of its scripts (``script == 'none'``)."""

    syntax_script, _   = stx.read_data(True)   # constructs
    all_cmds_script, _ = stx.read_data(False)  # commands

    # Per‑script metrics ------------------------------------------------------
    syntax_script["#Cons"]   = syntax_script["nodes"].apply(_count_constructs)
    all_cmds_script["#Cmd"] = all_cmds_script["nodes"].apply(_count_unique_cmds)

    per_script = (
        syntax_script[["script", "benchmark", "#Cons"]]
        .merge(all_cmds_script[["script", "#Cmd"]], on="script")
    )

    # Aggregate per benchmark -------------------------------------------------
    summary = (
        per_script.groupby("benchmark", sort=False)[["#Cons", "#Cmd"]]
        .sum()
        .reset_index()
    )
    summary["script"] = "none"
    summary["__order"] = 0  # ensure summary rows come first
    per_script["__order"] = 1

    combined: pd.DataFrame = pd.concat([summary, per_script], ignore_index=True)
    combined = (
        combined.sort_values(["benchmark", "__order", "script"], kind="stable")
        .drop(columns="__order")
    )

    # Re‑order columns
    return combined[["benchmark", "script", "#Cons", "#Cmd"]]

###############################################################################
# CLI / entry‑point                                                            #
###############################################################################

def _parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Compute #Cons/#Cmd metrics (benchmark & script) and export to CSV"
    )
    p.add_argument(
        "-o", "--output", default="constructs_commands_summary.csv",
        help="Benchmark‑level CSV path (default: %(default)s)")
    p.add_argument(
        "-s", "--scripts-output", default="constructs_commands_summary_scripts.csv",
        help="Script‑level CSV path (default: %(default)s)")
    p.add_argument(
        "--stdout", action="store_true",
        help="Also print the tables to standard output")
    return p.parse_args()


def main() -> None:
    args = _parse_args()

    bench_df  = _build_benchmark_metrics()
    script_df = _build_script_metrics()

    # Write CSVs --------------------------------------------------------------
    bench_df.to_csv(Path(args.output), index=False)
    script_df.to_csv(Path(args.scripts_output), index=False)

    # Optional stdout ---------------------------------------------------------
    if args.stdout:
        print(f"\nBenchmark‑level metrics ({len(bench_df)} rows):")
        print(bench_df.to_string(index=False))
        print(f"\nScript‑level metrics ({len(script_df)} rows):")
        print(script_df.to_string(index=False))
    else:
        print(f"Wrote {len(bench_df)} benchmark rows to {args.output}")
        print(f"Wrote {len(script_df)} script rows to {args.scripts_output}")


if __name__ == "__main__":
    main()
