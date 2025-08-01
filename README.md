# FIR Filter Optimization

## Overview

This project implements a **Finite Impulse Response (FIR) filter** designed for FPGA deployment, featuring serial input/output and UART connectivity for seamless hardware-in-the-loop testing from a PC environment. The design includes robust data conversion wrappers for serial- to-parallel and parallel-to-serial interfacing, a high-performance FIR core utilizing arithmetic optimizations, and UART communication modules for PC-FPGA data exchange. The solution is built for real-time digital signal processing and supports hardware/software co-simulation with Python visualization.


  Table of Contents

- [System Architecture](#system-architecture)
- [Design Process](#design-process)
- [Algorithm Description](#algorithm-description)
- [Module Descriptions](#module-descriptions)
    - [FIR Core](#fir-core)
    - [Serial Input/Output Wrappers](#serial-inputoutput-wrappers)
    - [UART Receiver/Transmitter](#uart-receivertransmitter)
- [Simulation & Validation](#simulation--validation)
- [Usage Instructions](#usage-instructions)
    - [FPGA Side](#fpga-side)
    - [PC/Python Side](#pcpython-side)
- [Performance & Testing](#performance--testing)
- [References](#references)

## System Architecture

The system can be divided into the following blocks:

- **Serial Data Acquisition:** Serial input is converted to parallel for FIR filtering.
- **FIR Filtering Core:** Applies a fixed 7-tap FIR optimized filter to the input stream in real-time using shift, add, and select (CSR) arithmetic for resource efficiency.
- **Serial Data Output:** The filtered result is parallel-to-serial converted for UART transmission.
- **UART Interface:** Connects the FPGA system to a PC for signal input/output, allowing for testing with synthesized signals (e.g., noisy sine waves).

## Design Process

1. **Requirements Definition:**
   - Real-time signal filtering via FPGA
   - Direct PC connectivity for signal transfer and analysis
   - Optimization for low resource usage

2. **Algorithm Selection:**
   - FIR filtering chosen for its linear phase and stability
   - Coefficients set for desired frequency response (see schematic/simulation)
   - Serial data interfacing to simplify hardware-PC connection

3. **Architecture Development:**
   - Wrap core FIR with serial/parallel converters
   - Integrate UART modules for robust, platform-independent data exchange

4. **Simulation and Iteration:**
   - Simulate with testbenches and input patterns
   - Use Vivado/ModelSim/ISim or built-in simulation tools
   - ![Simulation](https://github.com/Mukesh0035/FIR-Filter-Optimization/blob/main/Fir_Filter%20simulation.png)
   - Timing, correctness, edge cases verified

5. **Schematic and Synthesis:**
   - Hardware schematic exported
   - ![Schematic](https://github.com/Mukesh0035/FIR-Filter-Optimization/blob/main/schematic.png)
   - RTL and post-synthesis verification

6. **PC Software Integration:**
   - Python scripts for generating noisy test signals, driving UART, and visualizing filtered vs. original signals

## Algorithm Description

The **FIR filter** is implemented as a 7-tap, linear-phase filter. Input samples are convolved with fixed coefficients defined by hardware-efficient arithmetic (CSR units replacing multipliers).

**Key features:**

- **Linear phase:** Symmetrical coefficient arrangement for zero group delay.
- **Optimized arithmetic:** Calculations use only shift and add/subtract operations for each tap.
- **Real-time operation:** Register pipeline ensures new input every clock cycle.

**Filter Equation:**

$$
y[n] = b_0 x[n] + b_1 x[n-1] + ... + b_6 x[n-6]
$$

where b_i are the filter coefficients implemented efficiently via CSR (shift-add) logic.

## Module Descriptions

### FIR Core

Implements the filter as a seven-stage shift register, with each tap multiplied by a specific coefficient using the CSR approach:

- **csr_unit modules:** Replace hardware multipliers with efficient shift-add logic based on the coefficient pattern
- Summed outputs of each CSR unit yield the final filter output

### Serial Input/Output Wrappers

- **Input Wrapper:** Converts an incoming serial bitstream into parallel 8-bit samples for FIR processing, buffering appropriately.
- **Output Wrapper:** Serializes parallel 16-bit FIR outputs for transmission, managing data-valid and busy handshakes to ensure proper framing.

### UART Receiver/Transmitter

- **Baud Rate:** Typically set at 115,200 baud but is customizable
- **Protocol:** 8N1 (8 data bits, no parity, 1 stop bit)
- **Integration:** Tightly linked with input/output wrappers to ensure byte-level framing

## Simulation & Validation

Simulation is performed using targeted input sequences (e.g., noisy sine). The provided simulation output ([Fir_Filter simulation.png](https://github.com/Mukesh0035/FIR-Filter-Optimization/blob/main/Fir_Filter%20simulation.png)) shows the filter's attenuation of noise versus the original and cleaned signals.

The schematic ([schematic.png](https://github.com/Mukesh0035/FIR-Filter-Optimization/blob/main/schematic.png)) visualizes the module interconnections and signal pathways.

## Usage Instructions

### FPGA Side

1. **Add all provided modules** (`fir_filter_top`, wrappers, UART RX/TX, CSR units) to your FPGA project.
2. **Set the correct clock and UART parameters** to match your board and PC setup.
3. **Connect the UART Rx/Tx pins** of your FPGA to a USB-UART bridge (FTDI, CP2102).
4. **Program your FPGA** with the synthesized bitstream.

### PC/Python Side

1. **Install dependencies:**  
   ```bash
   pip install numpy matplotlib scipy pyserial
   ```
2. **Run provided Python script:**  
   - Generates noisy sine or custom signals
   - Sends each sample over UART as 2 bytes (16-bit signed)
   - Receives filtered outputs
   - Plots and analyzes the results:
     - Original signal
     - Filtered (clean) output
     - Statistical metrics (SNR improvement, RMSE)
3. **Example workflow:**
   - Connect to the correct COM port
   - Select signal type (sine, square, impulse, etc.)
   - Observe real-time plots and export results as needed

## Performance & Testing

- **Resource Usage:** Optimized for minimal FPGA LUTs and Flip-Flops (no multipliers used)
- **Throughput:** Real-time processing, constrained only by UART speed for I/O
- **Latency:** Register pipeline + FIR group delay. Typically a few clock cycles.
- **Signal Quality:** Test with various noise levels and signal frequencies; SNR is improved as shown in simulation.







