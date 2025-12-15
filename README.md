# Hardware Performance Monitor (HPM) for MicroBlaze MCS

**Author:** Gabriel Yeung  
**Course:** ELC 4312 (Softcore SoCs)  
**Platform:** Nexys 4 DDR (Artix-7 FPGA)  

## Project Overview
This project implements a **Hardware Performance Monitor (HPM)** for the Xilinx MicroBlaze MCS Softcore processor. Unlike software profilers, which introduce execution overhead and skew timing data, this HPM is a non-intrusive hardware peripheral that "snoops" on the system bus.

It allows developers to measure **cycle-accurate execution time** and **bus utilization** for specific code blocks, providing deep insights into architectural bottlenecks (such as the lack of a hardware Floating Point Unit).

## Hardware Architecture: "Bus Snooping"
The core innovation of this project is the **Bus Snooping Architecture**.
* **Standard Control:** The CPU controls the HPM (Start/Stop/Reset) via the standard MMIO bus (Slot 5).
* **Monitoring Path:** The HPM physically taps into the `io_addr_strobe`, `io_read_strobe`, and `io_write_strobe` signals.
* **Result:** The core counts every instruction fetch and memory access in real-time, completely independent of the CPU's execution flow.

*(See `Report/HPM_Block_Diagram.png` for the visual architecture)*

## Repository Structure
```text
HPM_Project/
├── HDL/                     # SystemVerilog Hardware Files
│   ├── hpm_peripheral.sv    # The custom HPM Core logic (Counters & Snoop Logic)
│   ├── mcs_top_vanilla.sv   # Modified Top-Level (Wired for Bus Snooping)
│   ├── mmio_sys_vanilla.sv  # Modified MMIO Subsystem (Routing Slot 5)
│   └── chu_io_map.svh       # Updated Header mapping Slot 5
│
├── Software/                # Vitis C++ Application & Drivers
│   ├── main_hpm.cpp         # Benchmark Application (Arithmetic vs Memory)
│   ├── hpm_driver.h         # C++ Driver Class for the HPM
│   ├── chu_io_map.h         # Updated Address Map
│   └── (Support Files)      # UART and Timer drivers
│
└── Report/                  # Documentation
    ├── Final Project - Gabriel Yeung.pdf    # Full Technical Report
    └── Hardware Performance Monitor Project - Gabriel Yeung.ppptx    # Project Slides
