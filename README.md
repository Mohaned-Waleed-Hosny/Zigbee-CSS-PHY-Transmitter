# IEEE 802.15.4a CSS PHY Transmitter (ZigBee Extension)

## Overview
This repository contains the hardware design (Verilog RTL) and reference software models (MATLAB) for an **IEEE 802.15.4a Chirp Spread Spectrum (CSS) Physical Layer Transmitter**. The design supports both **1 Mbps** and **250 kbps** data rates and features fixed-point optimization for FPGA/ASIC implementation.

## Key Features
* **Dual Data Rate Support:** 1 Mbps (3/4 coding rate) and 250 kbps (6/32 coding rate with Bit Interleaver).
* **Golden Reference Model:** MATLAB implementation covering both Floating-Point and Fixed-Point arithmetic with MSE verification.
* **Fully Modular Verilog RTL:** Includes Header/Padding generation, DEMUX, Symbol Mapping, DQPSK Encoding, and CSK Modulation.
* **Verification Pipeline:** Automated co-simulation using MATLAB HDL Verifier and ModelSim.