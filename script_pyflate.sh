#!/bin/bash
# HWSW Project: Benchmark Execution Script for pyflate
# This script is intended to be run on the naranja10 VM

echo "Setting up environment for pyflate benchmark..."
# Install pyperformance and linux-tools for perf
sudo apt-get update
sudo apt-get install -y linux-tools-common linux-tools-generic linux-tools-$(uname -r) git
python3-dbg -m pip install pyperformance

echo "Running pyflate benchmark with perf..."
perf record -F 999 -e cpu-clock -g -- python3-dbg -m pyperformance run --bench pyflate -o pyflate_baseline.json

echo "Generating perf report..."
perf report --stdio > report_pyflate_baseline.txt

echo "Generating flame graph for pyflate..."
if [ ! -d "FlameGraph" ]; then
    git clone https://github.com/brendangregg/FlameGraph
fi
perf script > out.pyflate.perf
./FlameGraph/stackcollapse-perf.pl out.pyflate.perf > out.pyflate.folded
./FlameGraph/flamegraph.pl out.pyflate.folded > pyflate_flamegraph.svg
echo "Flame graph saved as pyflate_flamegraph.svg"

echo "Comparing optimized version..."
python3-dbg optimized_pyflate.py -o pyflate_optimized.json
python3-dbg -m pyperf compare_to pyflate_baseline.json pyflate_optimized.json > report_pyflate_comparison.txt

echo "Optimization execution complete. View report_pyflate_comparison.txt for the exact speedup!"
