# CN-03 SPI Counter — Multi-level Hardware/Software Implementation

Final assignment for the Embedded Systems (21501) course (MSc in Computer Engineering).
Design and implementation of a custom SPI peripheral device (**CN-03**) across three levels of abstraction: RTL hardware, bare-metal software, and FPGA synthesis.

---

## CN-03 Device Specification

CN-03 is an 8-bit unsigned counter controlled over SPI (with active-low chip select).
On each transaction the master sends an 8-bit command and simultaneously receives the current counter value:

| MSB of command | Effect |
|---|---|
| `1` | Increment counter |
| `0` | Set counter to lower 7 bits (zero-extended) |

---

## Project Structure

```
assignment_finale/
├── SystemVerilog/          # RTL module + testbench (Icarus Verilog)
│   ├── src/
│   │   ├── cn_03.sv        # CN-03 counter with SPI slave interface
│   │   └── spi_slave.sv    # Bit-serial SPI slave shift register
│   └── test/
│       ├── cn_03_tb.sv     # Testbench (reset, increment, set 0x50)
│       └── expected_output.txt
├── Synthesis/              # FPGA synthesis targeting Tang Nano 9K
│   ├── Makefile            # Docker-based Yosys + nextpnr workflow
│   ├── tangnano9k.cst      # Pin constraints
│   └── cn_03.sv / spi_slave.sv
├── C/                      # Bare-metal Raspberry Pi 3B+ driver
│   ├── src/
│   │   ├── kernel.c        # Main control loop
│   │   ├── spi_bb.c        # Bit-banging SPI master (100 kHz)
│   │   ├── peripherals.c   # Memory-mapped GPIO abstraction
│   │   └── delay.c         # Microsecond delay via system timer
│   ├── include/            # Headers and pin/address definitions
│   └── Makefile
└── Microarchitecture/      # ARM32 single-cycle processor simulation
    ├── *.sv                # Processor + peripherals (GPIO, SysTick, SPI)
    ├── memfile.s           # ARM assembly driver for CN-03
    └── test.sh             # Build & simulate script
```

---

## Components

### 1. SystemVerilog — RTL Module

Implements the CN-03 device as a synchronous SystemVerilog module:

- **`cn_03.sv`** — 8-bit counter logic with SPI command decoding
- **`spi_slave.sv`** — Bit-serial shift register (MSB-first, clocked on negedge SCK)
- **`cn_03_tb.sv`** — Testbench covering reset, increment, and value-set scenarios

**Simulate with Icarus Verilog:**
```bash
cd SystemVerilog
iverilog -g2012 -o sim test/cn_03_tb.sv src/cn_03.sv src/spi_slave.sv
vvp sim
```

---

### 2. FPGA Synthesis — Tang Nano 9K

The CN-03 module is synthesized for the **Tang Nano 9K** FPGA (Gowin GW1NR-LV9QN88PC6/I5) using a fully Dockerized toolchain (Yosys → nextpnr-gowin → gowin_pack).

**Requirements:** Docker

```bash
cd Synthesis

# Run simulation
make test

# Full synthesis → .fs bitstream
make

# Flash to board (requires openFPGALoader)
make flash
```

---

### 3. Bare-Metal C Driver — Raspberry Pi 3B+

A bare-metal driver for Raspberry Pi 3B+ that controls CN-03 via **bit-banging SPI**:

| GPIO Pin | SPI Signal |
|---|---|
| GPIO 8  | CS (active low) |
| GPIO 11 | CLK (100 kHz) |
| GPIO 10 | MOSI |
| GPIO 9  | MISO |

**Control sequence (repeated in an infinite loop):**
1. Reset counter (send `0x00`)
2. Increment 100 times (send `0x80`)
3. Set to maximum `0x7F`, then increment once

The driver uses direct memory-mapped access to GPIO (`0x3F200000`) and system timer (`0x3F003000`) registers.
A simulation mode (`-DSIMULAZIONE`) allows running on host hardware for testing.

```bash
cd C

# Build (simulation mode)
make

# Run simulation
./bin/cn03
```

---

### 4. ARM Microarchitecture Simulation

The simulation extends the single-cycle ARM32 processor from Harris & Harris, *Digital Design and Computer Architecture* (2nd ed.) with custom peripherals and instruction set extensions to run the CN-03 assembly driver end-to-end.

**Extensions to the base HH processor:**

| Component | Extension |
|---|---|
| `alu.sv` | Widened `ALUControl` from 2 to 3 bits; added MOV and BIC (bit-clear) operations |
| `decoder.sv` | Added BL (branch-and-link) instruction support; added opcodes for MOV, BIC, CMP |
| `datapath.sv` | Added BranchLink path (writes PC+4 to R14); added Rs read port for barrel shifter |
| `regfile.sv` | Added third read port `rd_s` to support register-specified shift amounts |
| `controller.sv` | Updated control signals for 3-bit `ALUControl` |
| `arm.sv` | Updated port widths for 3-bit `ALUControl` |
| `imem.sv` | Expanded instruction memory from 64 to 256 words |
| `top.sv` | Replaced single dmem with full peripheral bus: GPIO, system timer, SPI slave (CN-03) |
| `tb.sv` | Dual-clock testbench (10 MHz CPU / 1 MHz timer); file-based output capture |

**Original modules added on top of HH:**
- **`bus_decoder.sv`** — peripheral address decoding (GPIO `0x3F200000`, SysTick `0x3F003000`, RAM default)
- **`gpio_peripheral.sv`** — Raspberry Pi GPIO register model (GPFSEL, GPSET, GPCLR, GPLEV)
- **`systimer_peripheral.sv`** — 64-bit 1 MHz system timer with compare registers
- **`cn_03.sv`** / **`spi_slave.sv`** — the CN-03 counter device wired as SPI slave
- **`srcb_shifter.sv`** — barrel shifter for ALU operand B (LSL, LSR, ASR, ROR; immediate or register amount)
- **`pio.sv`** — parallel I/O glue logic
- **`memfile.s`** — complete ARM32 assembly driver for CN-03 (bit-bang SPI, GPIO, delay via SysTick)

**Build & simulate:**
```bash
cd Microarchitecture

# Assemble and generate memfile.dat
arm-none-eabi-as memfile.s -o memfile.o
arm-none-eabi-objcopy memfile.o -O binary memfile.bin
hexdump -e '1/4 "%02x" "\n"' memfile.bin > memfile.dat

# Simulate
iverilog -g2012 *.sv && vvp a.out
```

Or use the provided script:
```bash
cd Microarchitecture && bash test.sh
```

**Requirements:** `arm-none-eabi-as`, `arm-none-eabi-objcopy`, `iverilog`

---

## Tech Stack

| Layer | Tools |
|---|---|
| RTL simulation | Icarus Verilog |
| FPGA synthesis | Yosys, nextpnr-gowin, gowin_pack (via Docker) |
| FPGA target | Tang Nano 9K (Gowin GW1NR) |
| Bare-metal C | GCC, memory-mapped I/O |
| ARM assembly | arm-none-eabi-as |
| Processor simulation | Icarus Verilog |
