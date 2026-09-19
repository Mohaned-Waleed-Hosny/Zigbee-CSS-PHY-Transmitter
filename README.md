# Zigbee CSS PHY Transmitter

A complete end-to-end implementation of an IEEE 802.15.4 Chirp Spread Spectrum (CSS) PHY Transmitter. This repository provides a full-stack hardware design, covering the mathematical golden reference model in MATLAB, complete Verilog RTL, stage-by-stage testbenches, FPGA implementation flows for both Altera/Intel (Quartus) and Xilinx (Vivado), and a full ASIC digital backend flow (Synthesis to Place & Route).

## Project Overview

This PHY transmitter translates baseband payload data into complex Differential Quadrature Chirp-Shift Keying (DQCSK) waveforms. It supports both standard CSS data rates:

* **1 Mbps**: Uses 4-chip bi-orthogonal codewords and an 8-symbol preamble.


* **250 kbps**: Uses 32-chip bi-orthogonal codewords, a 20-symbol preamble, and includes bit interleaving.



The transmitter handles a maximum payload length of 127 bytes, prepended with a 12-bit PHY Header (PHR).

## Architecture & Data Path

The system is highly pipelined and segmented into modular processing blocks managed by a central top-level wrapper (`css_phy_tx_top.v`). The hardware data path directly mirrors the IEEE 802.15.4 standard:

1. **Controller**: Manages payload RAM reads, framing, and pipeline synchronization.


2. **Zero Padding**: Pads the data stream to align with interleaver/symbol mapper block boundaries (6 bits for 1 Mbps, 24 bits for 250 kbps).


3. **Demux I/Q**: Splits the serial bitstream into parallel In-phase (I) and Quadrature (Q) paths.


4. **Symbol Mapper**: Maps I/Q bits into bi-orthogonal codewords based on the selected data rate.


5. **Bit Interleaver**: Permutes chips across consecutive codewords (active only for the 250 kbps rate).


6. **Form PPDU**: Assembles the Physical Layer Protocol Data Unit by prepending the preamble and Start-of-Frame Delimiter (SFD) to the payload.


7. **QPSK Mapper**: Converts I/Q chip pairs into base QPSK symbols.


8. **DQPSK Encoder**: Differentially encodes symbols using a 4-symbol feedback memory.


9. **CSK Generation**: A sequencer tracks 38-sample subchirps, buffering DQPSK symbols to match the slower Chirp-Shift Keying sample stream.


10. **DQPSK-CSK Multiplier**: Multiplies the differential symbols with the selected base chirp waveforms generated from a registered ROM to produce the final complex TX outputs.



## Repository Structure

```text
Zigbee-CSS-PHY-Transmitter/
├── RTL/                      # Synthesizable Verilog source files
│   └── rom/                  # Text files for codeword ROM initialization
├── Testbenches/              # Module-level and top-level testbenches
├── Scripts/                  # ModelSim simulation DO files
├── TB_Waveforms/             # Captured simulation waveforms (PNG)
├── Matlab/                   # Golden reference model and vector generation
├── Test_Vectors/             # Phase-by-phase test vectors for RTL verification
├── FPGA_Flow_Quartus/        # Intel/Altera implementation project (.qpf, .qsf)
├── FPGA_FLOW_Vivado/         # Xilinx implementation project (.xpr, .xdc)
└── asic-implementation/      # Complete Synopsys digital implementation flow
    ├── std_cells/            # SAED 90nm PDK files (lib, lef, tluplus)
    ├── syn/                  # Logic Synthesis (Design Compiler)
    ├── ndm/                  # NDM library creation
    ├── floorplan/            # IC Compiler II Floorplanning
    ├── placement/            # Standard cell placement
    ├── powerplan/            # Power grid generation
    ├── cts/                  # Clock Tree Synthesis
    ├── routing/              # Signal routing
    └── fm/                   # Formal Verification (Formality)

```

## MATLAB Golden Reference & Verification

The `Matlab/` directory contains a bit-true reference model of the transmitter. The core function, `ChirpSpreadSpectrum_Tx.m`, implements the full modulation chain.

Crucially, this MATLAB model acts as the test vector generator for the RTL. During execution, it dumps stage-by-stage intermediate text files (e.g., `data_after_padding.txt`, `I_mapped_matlab_rate0.txt`, `S_real_matlab_rate0.txt`). These text files are loaded by the Verilog testbenches in `Test_Vectors/` to perform automated, cycle-accurate comparisons between the MATLAB math and the Verilog hardware.

## Implementation Flows

### FPGA Integration

The repository includes fully constrained projects for both major FPGA vendors:

* **Intel/Altera (Quartus):** Located in `FPGA_Flow_Quartus/`. Includes SDC constraints, QSF assignments, and incremental database setups.
* **Xilinx (Vivado):** Located in `FPGA_FLOW_Vivado/`. Uses a Clock Wizard IP (`clk_wiz_0`) and includes physical constraints (`cons.xdc`).

### ASIC Flow

Located in `asic-implementation/`, this project features a heavy-duty backend physical design flow targeting the Synopsys SAED 90nm educational node. It utilizes Tcl scripting for automated execution across the Synopsys toolchain:

* **Design Compiler:** RTL-to-gate logic synthesis (`syn/`).
* **IC Compiler II (ICC2):** Physical design including floorplanning, power grid synthesis, standard cell placement, CTS (Clock Tree Synthesis), and final routing. Includes QoR, utilization, and DRC reports.
* **Formality:** Logical equivalence checking (`fm/`) between RTL and synthesized netlists, as well as pre/post-routing netlists.

## Tools Required

* **Simulation:** Siemens ModelSim or QuestaSim.
* **Reference Modeling:** MathWorks MATLAB.
* **FPGA Synthesis:** Intel Quartus Prime, AMD Xilinx Vivado.
* **ASIC Implementation:** Synopsys Design Compiler, IC Compiler II, Formality.

## Setup & Run Instructions

**1. MATLAB Golden Vector Generation:**

```matlab
cd Matlab
runMe  % Executes simulationParameters.m and generates TX test vectors in Test_Vectors/

```

**2. RTL Simulation (ModelSim):**

```bash
cd Scripts
vsim -do run.do  # Compiles RTL, loads memory files from RTL/rom/, and runs the master testbench

```

**3. FPGA Flow (Vivado):**
Open `FPGA_FLOW_Vivado/project_1.xpr` in Vivado. Run Synthesis, Implementation, and Generate Bitstream. Review timing reports in the Design Runs tab.

**4. ASIC Flow (Synopsys):**
Navigate to the specific stage directories within `asic-implementation/` (e.g., `syn/`, `placement/`). Run the associated Tcl script using the respective tool:

```bash
dc_shell -f script/syn_script.tcl
icc2_shell -f script/floor_script.tcl

```

*Note: The ASIC flow requires the SAED 90nm libraries configured in your environment.*
