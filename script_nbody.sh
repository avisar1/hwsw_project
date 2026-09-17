#!/bin/bash
# HWSW Project: Benchmark Execution Script for nbody
# This script is intended to be run on the naranja10 VM

echo "Setting up environment for nbody benchmark..."
# Install pyperformance and linux-tools for perf
sudo apt-get update
sudo apt-get install -y linux-tools-common linux-tools-generic linux-tools-$(uname -r) git
python3-dbg -m pip install pyperformance

echo "Running nbody benchmark with perf..."
perf record -F 999 -e cpu-clock -g -- python3-dbg -m pyperformance run --bench nbody -o nbody_baseline.json

echo "Generating perf report..."
perf report --stdio > report_nbody_baseline.txt

echo "Generating flame graph for nbody..."
if [ ! -d "FlameGraph" ]; then
    git clone https://github.com/brendangregg/FlameGraph
fi
perf script > out.nbody.perf
./FlameGraph/stackcollapse-perf.pl out.nbody.perf > out.nbody.folded
./FlameGraph/flamegraph.pl out.nbody.folded > nbody_flamegraph.svg
echo "Flame graph saved as nbody_flamegraph.svg"

echo "Comparing optimized version..."
# To fully test with pyperformance, you'd replace the bm_nbody.py in site-packages.
# For local testing, we use cProfile on the standalone optimized script.
python3-dbg -m cProfile -s tottime optimized_nbody.py > report_nbody_optimized_profile.txt

echo "nbody benchmark script completed successfully!"
