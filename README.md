# HWSW Project: Benchmark Optimization, Analysis, and Hardware Acceleration

This repository contains the deliverables for the Hardware/Software Co-Design project.
We selected two benchmarks from the pyperformance suite: **nbody** and **pyflate**.

## Repository Structure

- `script_nbody.sh` / `script_pyflate.sh`: Bash scripts to run the baseline benchmarks using `pyperformance`, profile them with `perf`, and generate flame graphs. They also benchmark our custom optimized code and automatically generate a scientific performance comparison using `pyperf`.
- `optimized_nbody.py` / `optimized_pyflate.py`: The optimized Python scripts targeting the bottlenecks identified during the profiling stage.
- `nbody_accelerator.v` / `pyflate_accelerator.v`: The hardware acceleration logic (Verilog) proposed to offload the bottlenecks to custom hardware.
- `report_nbody.txt` / `report_pyflate.txt`: Comprehensive reports detailing the initial analysis, optimization strategies, and the hardware acceleration proposals (including block diagrams, interfaces, and trade-offs).
- `prompt.txt`: Documentation of the prompts used to interact with the AI assistant during this project.

## How to Run on the Course Ubuntu VM

Because this project requires the Linux `perf` tool and KVM acceleration, these scripts are designed to be executed inside the provided course Virtual Machine.

### 1. Execute the Scripts
Once you have cloned this repository into the VM, simply execute the bash scripts:
```bash
chmod +x script_nbody.sh script_pyflate.sh
./script_nbody.sh
./script_pyflate.sh
```

These scripts will automatically:
1. Install `pyperformance`.
2. Run the baseline and capture `perf` samples (using software events to bypass KVM restrictions).
3. Generate the flame graphs.
4. Run our optimized Python code and generate the `pyperf compare_to` data to prove the performance improvements.

## Verification
Review the generated `report_nbody_comparison.txt` and `report_pyflate_comparison.txt` files to verify the exact execution time speedup factor.
