# HWSW Project: Benchmark Optimization, Analysis, and Hardware Acceleration

This repository contains the deliverables for the Hardware/Software Co-Design project.
We selected two benchmarks from the pyperformance suite: **nbody** and **pyflate**.

## Repository Structure

- `script_nbody.sh` / `script_pyflate.sh`: Bash scripts to run the baseline benchmarks using `pyperformance`, profile them with `perf`, and generate flame graphs on the provided Linux VM.
- `optimized_nbody.py` / `optimized_pyflate.py`: The optimized Python scripts targeting the bottlenecks identified during the profiling stage.
- `nbody_accelerator.v` / `pyflate_accelerator.v`: The hardware acceleration logic (Verilog) proposed to offload the bottlenecks to custom hardware.
- `report_nbody.txt` / `report_pyflate.txt`: Comprehensive reports detailing the initial analysis, optimization strategies, and the hardware acceleration proposals (including block diagrams, interfaces, and trade-offs).
- `prompt.txt`: Documentation of the prompts used to interact with the AI assistant during this project.

## How to Run on the Course VM (naranja10)

Because this project requires the Linux `perf` tool and KVM acceleration, you must run the bash scripts inside the Technion VM.

### 1. Connect and Start the VM
Open your terminal and SSH into the gateway, then the compute node:
```bash
ssh <your_username>@tangerine.cslcs.technion.ac.il
ssh naranja10
```

If you haven't already, copy the VM image:
```bash
cp /scratch/ece882-001/jammy-server-cloudimg-amd64-disk-kvm.img ~/project_image.img
```

Launch the QEMU VM:
```bash
qemu-system-x86_64 \
  -machine accel=kvm,type=q35 \
  -cpu host \
  -m 2G \
  -nographic \
  -drive if=virtio,format=qcow2,file=~/project_image.img \
  -net user,hostfwd=tcp::2222-:22 -net nic
```

### 2. Connect to the running VM
Open a **new** terminal window on your machine and run:
```bash
ssh -J <your_username>@tangerine.cslcs.technion.ac.il,<your_username>@naranja10 -p 2222 ubuntu@localhost
```

### 3. Run the Scripts
Copy the repository files into the VM (using `scp` or `git clone`).
Then, execute the bash scripts:
```bash
chmod +x script_nbody.sh script_pyflate.sh
./script_nbody.sh
./script_pyflate.sh
```

These scripts will install pyperformance, run the baseline, generate the flame graphs, and output the optimized performance comparisons.

## Verification
Review the generated `report_nbody_baseline.txt` against `report_nbody_optimized_profile.txt` to verify the execution time improvements (>7%). The exact same process applies to `pyflate`.
