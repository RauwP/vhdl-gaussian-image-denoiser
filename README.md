# Gaussian Noise Reduction on 256×256 24‑bit Images

This repository implements a VHDL‑based image denoising pipeline designed to remove Gaussian noise (with noise level ≤ 5%) from 256 × 256 images at 24 bits per pixel (8 bits per color channel). The design includes the core denoising algorithm, format‐conversion utilities, test vectors, and demonstration examples using the classic “Lena” and “Pétruha” images.

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Block Diagram & State Machine](#block-diagram--state-machine)
4. [Repository Structure](#repository-structure)
5. [Prerequisites](#prerequisites)
6. [Usage](#usage)

   * [1. Converting Images to MIF/RAW](#1-converting-images-to-mifraw)
   * [2. Synthesizing & Simulating the VHDL Core](#2-synthesizing--simulating-the-vhdl-core)
   * [3. Converting Back to Viewable Format](#3-converting-back-to-viewable-format)
7. [Examples](#examples)
8. [Resource Utilization](#resource-utilization)
9. [License](#license)

---

## Overview

The goal of this project is to demonstrate a fully hardware‐implemented denoising algorithm capable of cleaning low‐level Gaussian noise from 24‑bit images (256×256 resolution). The core is written in VHDL for FPGA deployment, with auxiliary Python scripts for memory‐initialization file (MIF) and raw‐binary conversions.

---

## Features

* **Denoising Algorithm:** Custom VHDL module implementing a median-of-medians filter over 3×3 pixel windows (with edge padding) to remove Gaussian noise up to 5% standard deviation.
* **Format Conversion:** Python utilities to convert between PNG/BMP ↔ RAW ↔ MIF formats:

  * `hextomif.py`
  * `mif_to_raw.py`
  * `raw_to_mif.py`
  * `noiseadder.py` (for testbench stimulus)
* **Testbenches:** VHDL testbenches for both the Processing Unit and Control Unit modules.
* **Demonstrations:** Before/after examples for “Lena” and “Pétruha” images.

---

## Block Diagram & State Machine

### Block Diagram

![Block Diagram](vhdl-gaussian-image-denoiser\images\block_diagram.jpg)

*Figure 1: Top‐level architecture showing the data path through the Control Unit, Processing Unit, and memory interfaces.*

### State Machine Diagram

![State Machine Diagram](vhdl-gaussian-image-denoiser\images\state_machine.jpg)

*Figure 2: Control Unit finite‐state machine describing initialization, data fetch, denoising, and write‐back states.*

---

## Repository Structure

```
├── vhdl-gaussian-image-denoiser/
│   └── images/
│       ├── lena_before.raw
│       ├── lena_noise.raw
│       ├── lena_noiseless.raw
│       ├── petruha_before.raw
│       ├── petruha_noise.raw
│       ├── petruha_noiseless.raw
│       ├── block_diagram.png
│       └── state_machine.png
├── scripts/
│   ├── hextomif.py
│   ├── mif_to_raw.py
│   ├── raw_to_mif.py
│   └── noiseadder.py
├── vhdl/
│   ├── helper_package.vhd
│   ├── ROM.vhd
│   ├── RAM.vhd
│   ├── Processing_Unit.vhd
│   ├── Processing_Unit_tb.vhd
│   ├── Control_Unit.vhd
│   └── Control_Unit_tb.vhd
├── inputs_outputs/
│   ├── lena/
│   │   ├── MEM_noiseless_outputs/
│   │   │   ├── r.mem
│   │   │   ├── g.mem
│   │   │   └── b.mem
│   │   └── MIF_noise_input/
│   │       ├── r.mif
│   │       ├── g.mif
│   │       └── b.mif
│   ├── petruha/
│   │   ├── MEM_noiseless_outputs/
│   │   │   ├── r.mem
│   │   │   ├── g.mem
│   │   │   └── b.mem
│   │   └── MIF_noise_input/
│   │       ├── r.mif
│   │       ├── g.mif
│   │       └── b.mif
└── README.md
```

---

## Prerequisites

* **VHDL Simulator/Synthesizer:** ModelSim, GHDL, or Quartus Prime.
* **Python 3.7+** with packages:

  * `numpy`
  * `Pillow`

---

## Usage

### 1. Converting Images to MIF/RAW

1. Place your 256×256 PNG (24 bpp) in the `examples/` folder.
2. Run the noise‐adder (optional) to inject Gaussian noise:

   ```bash
   python3 scripts/noiseadder.py --input examples/lena.png --sigma 0.05 --output examples/lena_noisy.raw
   ```
3. Convert raw binary to MIF for FPGA memory initialization:

   ```bash
   python3 scripts/raw_to_mif.py --input examples/lena_noisy.raw --output vhdl/lena_noisy.mif
   ```
4. (For simulation) change in Processing_Unit_tb.vhd the generics of the mif_path to the desired string path of the new mif files.
### 2. Synthesizing & Simulating the VHDL Core

1. Launch your simulator (e.g. ModelSim):

   ```tcl
   vsim work.Processing_Unit_tb
   run -all
   ```
2. Inspect waveforms to verify end pulse is raised.
3. Alternatively, synthesize for your target FPGA with Quartus:

   * Create a new project, add all `vhdl/` files.
   * Set top‐level to `Control_Unit`.

### 3. Converting Back to Viewable Format

2. **Convert all three `.mem` dumps to `.mif`** (one command handles R, G and B channels): (dont forget to get them in the same folder as the script, and change their name to outut_{r/g/b}.mem)
   ```bash
   python3 scripts/hextomif.py

This reads r_output.mem, g_output.mem, b_output.mem and produces r_output.mif, g_output.mif, b_output.mif.
3. Merge the three .mif files into a single RAW image:

python3 scripts/mif_to_raw.py

By default this writes out lena_noiseless.raw or petruha_noiseless.raw (adjust filenames or script options as needed).
4. Inspect the resulting RAW file using your preferred raw‐image viewer or convert it to a standard format (e.g., PNG) for display.

---

## Examples

### Lena

| Input (Noisy)                    | Output (Denoised)               |
| -------------------------------- | ------------------------------- |
| ![](vhdl-gaussian-image-denoiser/images/lena_noise.raw) | ![](vhdl-gaussian-image-denoiser/images/lena_noiseless.raw) |

### Pétruha

| Input (Noisy)                       | Output (Denoised)                  |
| ----------------------------------- | ---------------------------------- |
| ![](vhdl-gaussian-image-denoiser/images/petruha_noise.raw) | ![](vhdl-gaussian-image-denoiser/images/petruha_noiseless.raw) |

---

## Resource Utilization

| Resource               | Used    | Available | Utilization (%) |
|------------------------|--------:|----------:|----------------:|
| Logic Elements (ALUTs) | 104,435 | 114,480   | 91%             |
| Registers (Flip-Flops) |  24,858 | 117,053   | 21%             |
| Block RAM (M9K/M10K)   |     342 |     432   | 79%             |
| DSP Blocks             |       0 |     532   | 0%              |
| PLLs                   |       0 |       4   | 0%              |
| I/O Pins               |       4 |     529   | <1%             |


*Values measured on a Cyclone IV E EP4CE115F29C7.*

---
