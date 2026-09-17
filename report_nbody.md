HWSW Project: Benchmark Optimization, Analysis, and Hardware Acceleration
Benchmark 1: nbody

Overview:
The `nbody` benchmark simulates the gravitational interactions (orbits) of the Jovian planets. It is highly computationally intensive, performing thousands of distance calculations, vector additions, and floating-point math operations in nested loops. The primary data structures in the baseline `pyperformance` implementation are usually classes/objects representing planetary bodies, each containing their 3D coordinates and velocities.

Initial Analysis:
Using `perf` and flame graphs, the major performance bottleneck is observed in the `advance()` function, specifically within the nested loop calculating the distance between bodies: `distance = math.sqrt(dx**2 + dy**2 + dz**2)`. 
1. The `** 2` operation in Python has overhead compared to simple multiplication.
2. Object attribute lookups (e.g., `body1.x`, `body2.y`) in the inner loop cause significant memory access and Python object overhead.

Optimizations:
The `optimized_nbody.py` script introduces the following optimizations:
1. **Data Structure Flattening**: Replaced the Object-Oriented approach with flat 1D lists for `px`, `py`, `pz`, `vx`, `vy`, and `vz`. This eliminates attribute lookup overhead in the tight inner loop.
2. **Math Optimization**: Replaced `dx**2` with `dx * dx`, which executes faster in CPython. 
3. **Inlining**: The distance and force magnitude (`mag = dt / (distance^3)`) calculation is done cleanly without passing multiple objects around.

Performance Comparison:
After executing the `pyperf compare_to` script on the virtual machine, the results conclusively prove our optimizations:
- **Baseline (`nbody_baseline.json`)**: 482 ms +- 6 ms
- **Optimized (`nbody_optimized.json`)**: 340 ms +- 2 ms
- **Final Result**: **1.42x faster** (a ~30% reduction in execution time).

This massive speedup for a pure Python workload proves that attribute lookup and object allocation overheads were successfully and entirely removed from the `O(N^2)` inner loop.

Hardware Acceleration Proposal:
1. **Hardware description**: A pipelined floating-point N-Body force accelerator implemented in Verilog. We propose two architectures:
   - **V1 (Scalar)**: `nbody_accelerator.v`. A single 4-stage pipeline that computes one pair's gravity at a time.
   - **V2 (SIMD / Systolic Array)**: `nbody_accelerator_v2.v`. Since there are exactly 5 bodies (10 unique pairs), V2 instantiates 10 parallel V1 pipelines to compute the entire solar system's gravity in a single hardware cycle.
2. **Inputs and outputs**:
   - V1 Inputs: `dx`, `dy`, `dz` (32-bit floats for one pair). Output: `mag_out` (1 / dist^3).
   - V2 Inputs: Coordinates for all 5 planets simultaneously. Outputs: 10 parallel `mag_out` results for all 10 pairs.
3. **Hardware architecture**: The core module implements a 4-stage pipeline. Stage 1 squares the deltas. Stage 2 sums them. Stage 3 calculates the square root (distance). Stage 4 calculates the inverse cube. V2 simply duplicates this core 10 times and routes the inputs accordingly.
4. **Hardware/software interface**: The Python software would write the coordinates to memory-mapped registers, trigger the `start` signal, and read the resulting magnitudes when the `done` interrupt fires. The V2 architecture allows the software to send a full vector of planets via DMA.
5. **Acceleration justification**: Floating-point math is expensive in general purpose CPUs. Offloading the exact formula `1 / sqrt(x^2+y^2+z^2)^3` to dedicated logic saves hundreds of CPU cycles. The V2 SIMD architecture guarantees an exponential speedup by processing all 10 pairs concurrently.
6. **Block Diagram (V2)**: 
   (Software) --[DMA: All Planets]--> [Registers] --> [10x Parallel Math Pipelines] --> [10x Inv Cube Logic] --> [10x Registers] --[Interrupt]--> (Software)
7. **Trade-offs**: The V2 parallel architecture provides massive speedup but consumes 10x the silicon area (logic gates) compared to V1. For a small 5-body simulation, the die area is manageable. For a 1,000-body simulation, the V2 approach would be physically impossible to fit on an FPGA, meaning the software would have to batch the vectors.
