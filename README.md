# pes_asic_class
Repo for the lab assignments for VLSI Physical Design for ASICs Special topic, August 2023.

Course Instructor - [Kunal Ghosh](https://github.com/kunalg123/)

Link to course notes: https://github.com/skudlur/VLSI-PD

## System Information

- Laptop - Lenovo ThinkPad T470
- Operating System - Fedora 36
- WM - i3wm
- FS - btrfs
- OS Bit length - 64-bit
- RAM - 8GB
- Memory - 512GB

## Installed tools for the course:

1. RISC-V GCC GNU Toolchain - Compiler collection to compile languages like C, C++ to RISC-V assembly. I have built the compiler from [source](https://github.com/riscv-collab/riscv-gnu-toolchain). The shell script also builds it from source because the one that is specified in the course is only for Ubuntu and other Debian systems. I have compiled both 64 and 32-bit compilers (multilib) as well as Linux compilers to experiment further but this is not necessary, just 64-bit should suffice (The shell installer will only install 64-bit compilers).

2. RISC-V ISA Simulator (SPIKE) - Again built it from [source](https://github.com/riscv-software-src/riscv-isa-sim). This simulator is used to run RISC-V executables that cannot be run on our host machines. (yet ;))

3. RISC-V Proxy Kernel (pk) - Built it from the [source](https://github.com/riscv-software-src/riscv-pk). This hosts statically-linked RISC-V ELF binaries. This allows the system calls from the RISC-V binaries to be translated to host target specific syscalls to execute them as intended.

## Installation guide for Fedora users

```bash
git clone https://github.com/skudlur/pes_asic_class.git
cd pes_asic_class
chmod +x run_fedora.sh
./run_fedora.sh
```

# Lab assignments

## Day - 1 Lab assignments - Introduction to RISC-V ISA and GNU Compiler Toolchain

### RISC-V

Reduced Instruction Set Computer - Five is an open instruction set architecture that is simple and extensively customizable to use to build a processor. It was developed by people at UC Berkeley to teach people how to build a processor. It now has the potential to be the go-to architecture for almost any use-case.

### Different extensions of RISC-V

- `I` -> Integer Extension (consists of instructions like `ADD`, `LW`, `SB` etc.). This extension is considered as the base ISA (minimum extension)
- `M` -> Multiplication and division Extension (`MUL`, `DIV` etc.)
- `C` -> Compressed Extension
- `A` -> Atomic Extension
- `F` -> Single Precision Floating point Extension
- `D` -> Double Precision Floating point Extension
- `V` -> Vector Extension
- `G` -> General collection of Extensions (IMACF)
  
All the code can be found in the respective day directories.

### Using GCC and RISC-V GCC to compile a C-program

- The first program for this lab is the program that calculates sum of N numbers.
- The following code is done to get x86 assembly for the C program.

```bash
gcc sum-1ton.c -o x86
./x86
```

- The above commands will run on an x86 system and print out an output.

![x86](https://github.com/skudlur/pes_asic_class/blob/main/day-1/assets/x86_sum1ton.png "x86")

- To get RISC-V assembly, we use the RISC-V GCC compiler to compile the program.

```bash
riscv64-unknown-elf-gcc sum-1ton.c -o rv
./rv
```

- The above command to execute the compiled binary will not run as it ran previously (for GCC). This is because the assembly produced is only for RISC-V processors.

![GCC](https://github.com/skudlur/pes_asic_class/blob/main/day-1/assets/gcc.png "GCC")

- We can use spike to invoke the executable.

```bash
spike $(which pk) rv
```

![RV](https://github.com/skudlur/pes_asic_class/blob/main/day-1/assets/rv_sum1ton.png "rv")

### Using RISC-V GCC to get disassembly

- Run the following commands to run get the disassembly

```bash
riscv64-unknown-elf-gcc -O1 -mabi=lp64 -march-rv64id -o rv sum-1ton.c
riscv64-unknown-elf-objdump -d rv | less
```
![rv-gcc](https://github.com/skudlur/pes_asic_class/blob/main/day-1/assets/gcc-march.png)
![rv-objd](https://github.com/skudlur/pes_asic_class/blob/main/day-1/assets/gcc-objdump.png)
![rv-disasm](https://github.com/skudlur/pes_asic_class/blob/main/day-1/assets/disasm.png)

- `-O<number>` -> Optimization levels for the compiler. Ranges from 0 (lowest optimization) to 3 (highest optimization).
- `-mabi` -> Denotes the Application Binary Interface (ABI) to be used for the compilation of the program.
- `-march` -> Denotes the extensions and machine instruction length to be generated.
- `-o` -> Denotes custom name for the object file.

- This will give the disassembled code from the C program (sum-1ton.c). To put the disassembly in a file, run the following command

```bash
riscv64-unknown-elf-objdump -d rv >> out.txt
```

![rv-out](https://github.com/skudlur/pes_asic_class/blob/main/day-1/assets/disasm_txt.png)

- The disassembly will be stored in `out.txt`.

### Running Spike to debug the disassembly

- Run the following commands to run spike in debug mode

```bash
spike $(which pk) rv
spike -d $(which pk) rv
```

![spike](https://github.com/skudlur/pes_asic_class/blob/main/day-1/assets/spike-debug.png)

- This will enable interactive debug mode in spike, you can access the register values, jump PC values and get next assembly in the instruction memory/pipeline.

- To check execution log, run the following command

```bash
spike -l --log=exec.txt $(which pk) rv
```

![spike-exec](https://github.com/skudlur/pes_asic_class/blob/main/day-1/assets/spike-exec.png)

- This will print the execution log in the `exec.txt` file.

## Day - 2 Lab assignments - Introduction to ABI and Basic Verification Flow 

### RISC-V Instructions:

RISC-V instructions can be categorized into different categories based on their functionality. Here are some common types of RISC-V instructions:

- **R-Type Instructions:** These are used for arithmetic and logic operations between two source registers, storing the result in a destination register. Common R-type instructions include:
  - `add`: Addition
  - `sub`: Subtraction
  - `and`: Bitwise AND
  - `or`: Bitwise OR
  - `xor`: Bitwise XOR
  - `slt`: Set Less Than (signed)
  - `sltu`: Set Less Than (unsigned)

- **I-Type Instructions:** These are used for arithmetic and logic operations that involve an immediate value (constant) and a source register. Common I-type instructions include:
  - `addi`: Add Immediate
  - `andi`: Bitwise AND with Immediate
  - `ori`: Bitwise OR with Immediate
  - `xori`: Bitwise XOR with Immediate
  - `lw`: Load Word (load data from memory)
  - `sw`: Store Word (store data to memory)
  - `beq`: Branch if Equal
  - `bne`: Branch if Not Equal

- **S-Type Instructions:** These are similar to I-type instructions but are used for storing values from a source register into memory. Common S-type instructions include:
  - `sb`: Store Byte
  - `sh`: Store Halfword
  - `sw`: Store Word

- **U-Type Instructions:** These are used for setting large immediate values into registers or for jumping to an absolute address. Common U-type instructions include:
  - `lui`: Load Upper Immediate (set the upper bits of a register)
  - `auipc`: Add Upper Immediate to PC (used for address calculations)

- J-Type Instructions: These are used for jumping or branching to different program locations. Common J-type instructions include:
  - `jal`: Jump and Link (used for function calls)
  - `jalr`: Jump and Link Register (used for function calls)

- **F-Type and D-Type Instructions (Floating-Point):** These instructions are used for floating-point arithmetic and include various operations like addition, multiplication, and comparison. These instructions typically have an 'F' or 'D' prefix to indicate single-precision or double-precision floating-point operations.
  - `fadd.s`: Single-precision floating-point addition
  - `fmul.d`: Double-precision floating-point multiplication
  - `fcmp.s`: Single-precision floating-point comparison

- **RV64 and RV32 Variants:** RISC-V can be configured in different bit-widths, with RV64 being a 64-bit architecture and RV32 being a 32-bit architecture. Instructions for these variants have slightly different encoding to accommodate the different data widths.

![instr](https://devopedia.org/images/article/110/3808.1535301636.png)

RISC-V instructions have a common structure with several fields that serve different purposes. The specific fields may vary depending on the type of instruction (R-type, I-type, S-type, U-type, etc.), but here are the typical fields you'll find in a RISC-V instruction:

- **Opcode (OP):** The opcode field specifies the operation to be performed by the instruction. It indicates what type of instruction it is (e.g., arithmetic, load, store, branch) and what specific operation within that type is being carried out.

- **Destination Register (rd):** This field specifies the destination register where the result of the instruction should be stored. In R-type instructions, this is often the first source register. In I-type and S-type instructions, this is sometimes used to specify the target register.

- **Source Register(s) (rs1, rs2):** These fields specify the source registers for the operation. For R-type instructions, rs1 and rs2 are typically the two source registers. In I-type and S-type instructions, rs1 is the source register, and immediate values may be used in place of rs2.

- **Immediate (imm):** The immediate field contains a constant value that is used as an operand in I-type and S-type instructions. This value can be an immediate constant, an offset, or an immediate value for arithmetic or logical operations.

- **Function Code (funct3, funct7):** In R-type and some I-type instructions, these fields further specify the operation. funct3 typically selects a particular function within an opcode category, and funct7 may provide additional information or further differentiate the instruction.

- **Extension-specific Fields:** Depending on the RISC-V extension being used (e.g., F for floating-point, M for integer multiplication/division), there may be additional fields to accommodate the specific requirements of that extension. These fields are not part of the base RISC-V instruction format.

### Register Naming in RISC-V according to ABI

![abi-reg](https://web.eecs.utk.edu/~smarz1/courses/ece356/notes/risc/imgs/regfile.png)

### Simulate a C program using ABI function call (using registers) and execute

![dodo](https://github.com/skudlur/pes_asic_class/blob/main/day-1/assets/Screenshot%20from%202023-08-21%2022-57-34.png)
![dodo1](https://github.com/skudlur/pes_asic_class/blob/main/day-1/assets/Screenshot%20from%202023-08-21%2022-56-54.png)

# RTL design using Verilog with SKY130 Technology

### Day - 1: Introducton to Verilog RTL Design and Synthesis

```bash
sudo dnf install gtkwave iverilog yosys
```

- Yosys can be installed using dnf itself.

#### Yosys check post installation
![yosys](https://github.com/skudlur/pes_asic_class/blob/main/assets/yosys.png "yosys")

- **Yosys**: Yosys is an open-source synthesis tool that converts RTL (Register Transfer Level) descriptions written in HDL (Hardware Description Language) into optimized gate-level netlists for digital circuit designs. -Inputs to yosys : liberty file(.lib) and design file(HDL) -Output : synthesized netlist mapped with the provided technology library

- **iverilog**: Icarus verilog is an open-source Verilog simulation and synthesis tool that allows designers to verify their digital designs using simulation and generate netlists for synthesis. -Inputs to iverilog : testbench and design files -output : VCD (Value change dump) file that stores data related to simulation

- **GTKWave**: GTKWave is an open-source waveform viewer that provides graphical visualization of simulation results produced by digital design simulation tools, aiding in the debugging and analysis of digital circuits. -Inputs : VCD FIle -output : Simulation waveform

#### Files

- The liberty file required for synthesis is `sky130_fd_sc_hd__tt_025C_1v80.lib` present under `rtl` Folder
- The design Files can be found under `verilog_files` directory inside `rtl`.

#### Synthesis and Simulation

```bash
cd /path/to/file/location
iverilog mux.v mux_tb.v -o mux.out
./mux.out
gtkwave mux_tb.vcd
```

#### Waveforms
![gtkwave](https://github.com/skudlur/pes_asic_class/blob/main/assets/wfm.png "gtkwave")

### Synthesis (Interactive flow)

- Open yosys where the verilog files are present using the command - `yosys`
- Specify the technology library to be used - `read_liberty -lib <PATH_TO_.lib_FILE_LOCATION>/sky130_fd_sc_hd__tt_025C_1v80.lib`
- Specify all the verilog files to be synthesized - `read_verilog mux.v`
- Since some designs have submodules, it is necessary to mention the topmodule name (mux in my case) - `synth -top mux`
- Generate synthesized netlist (ABC links the expression declared in design file with cells present in library) - `abc -liberty <Path_to_.lib_File>/sky130_fd_sc_hd__tt_025C_1v80.lib`
- To view the graphical representation of sytnthesized netlist - `show`
- Write the generated netlist into a verilog file - `write_verilog mux_mapped.v` or `write_verilog -noattr mux_mapped.v`
    - noattr helps in compressing the mapped netlist by removing unwanted information

#### yosys stats
![yosys_stats](https://github.com/skudlur/pes_asic_class/blob/main/assets/ystats.png "yosys stats")

#### abc stats
![abc_stats](https://github.com/skudlur/pes_asic_class/blob/main/assets/abcstats.png "abc stats")

#### Netlist
![netlist_stats](https://github.com/skudlur/pes_asic_class/blob/main/assets/netlist.png "netlist")

### Day - 2: Timing libs, Efficient flop coding styles

## Liberate file explained 

lib file name : [sky130_fd_sc_hd__tt_025C_1v80.lib](https://github.com/yagnavivek/PES_ASIC_CLASS/blob/main/RTL_Verilog/sky130_fd_sc_hd__tt_025C_1v80.lib) 
- ```tt``` - Typical PMOS typical NMOS (Regular working speed)
- ```025C``` - Temperature
- ```1v80``` - supply voltage
The above 3 parameters shortly known as PVT(Process Voltage Temperature) define how and at what conditions the fabricated silicon works
- ```sky130``` - 130nm Technology node
- ```fd``` - Foundry design
- ```sc``` - standard cell
- ```hd``` - high density - This specifies that this library supports using these standard cells at a high density resulting in samller chip area

- The library file consists of all the details of the cell ie., leakage power, area, timing etc. for all input combinations
- The library file consists of some same cell with different loads that facilitate the synthesis process.

![and201](https://github.com/yagnavivek/PES_ASIC_CLASS/assets/93475824/36923763-9654-4ad0-9230-8d038f1a7332)

-From the figure, it is clear that we have different flavours of same cells whose values are different.

### Hierarchical Synthesis V/s Flat Synthesis

In Hierarchical synthesis, The hierarchy is maintained ie., submodules will be displayed as submodule block itself.They wont be represented by the logic present inside them but when flattened, the submodule data will not be visible. Only the top module will be visible.

#### Steps for hierarchical synthesis, flat synthesis and submodule level synthesis

```
read_liberty -lib <PATH_TO_.lib_FILE>/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog multiple_modules.v
synth -top multiple_modules  <!-- We can use synth -top <submodule_name> to synthesize the design at submodule level
abc -liberty <PATH_TO_.lib_FILE>/sky130_fd_sc_hd__tt_025C_1v80.lib
write_verilog -noattr multiple_modules_mapped_hier.v
show multiple_modules
flatten
write_verilog -noattr multiple_modules_mapped_flat.v
show multiple_modules
```
### Hierarchical Synthesis output [Multiple_modules.v](https://github.com/yagnavivek/PES_ASIC_CLASS/blob/main/RTL_Verilog/verilog_files/multiple_modules.v)

![multi_mod_hier](https://github.com/yagnavivek/PES_ASIC_CLASS/assets/93475824/47305ca1-3f4a-448b-b648-2745b9662de7)

### Flattened Synthesis netlist

![multi_mod_flat](https://github.com/yagnavivek/PES_ASIC_CLASS/assets/93475824/7e1409b5-7514-4cbe-b3a3-38fe7c48b4af)

### Submodule Synthesis netlist (submodule2 in this case)

![submod2](https://github.com/yagnavivek/PES_ASIC_CLASS/assets/93475824/38a1776b-6920-4f4e-85a5-7a9ff363e818)

#### Note : 
- While synthesizing OR gate, AND gate, most of the times the tool uses NAND Gates to obtain the functionality as in NAND gates,The NMOS are connected in series and provide better signal transfer.
- Submodule level synthesis helps reduce synthesis time when in a massive design, the same submodule has been called many times and also we can synthesize all submodules and stitch them to obtain top level.But here the optimisation also takes place at submodule level ,not at top level.3

### Flops

Due to propogation delays of gates, The combinational block may output some glitches which might be negligible but when "n" number of combinational blocks are connected, theglich becomes large and no more remains a glitch but as a false state. So to avoid the addition effect of glitches we will have flops at the end of each combinational blocks as the flop stores the final value and the glitch is eliminated before passing it to next block.

Steps to synthesize flops
```
read_liberty -lib <PATH_TO_.lib_FILE>/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog flop.v
synth -top flop
dfflibmap -liberty <PATH_TO_.lib_FILE>/sky130_fd_sc_hd__tt_025C_1v80.lib
abc -liberty <PATH_TO_.lib_FILE>/sky130_fd_sc_hd__tt_025C_1v80.lib
write_verilog -noattr flop_mapped.v
show 
```
To view the waveform
```
iverilog flop.v flop_tb.v -o flop.out
./flop.out
gtkwave flop_tb.vcd
```

## D-flip-flop with an asynchronous reset [asyncres.v](https://github.com/yagnavivek/PES_ASIC_CLASS/blob/main/RTL_Verilog/verilog_files/asyncres.v) [asyncres_tb.v](https://github.com/yagnavivek/PES_ASIC_CLASS/blob/main/RTL_Verilog/verilog_files/asyncres_tb.v)

![asyncres_stats](https://github.com/yagnavivek/PES_ASIC_CLASS/assets/93475824/cef13e93-fc85-47d6-bf81-b1e110d4412c)

Since we see a D Flip FLop getting inferred, We use the above mentioned dfflibmap command to map the flops accurately
View the output waveforms

![asyncres_netlist](https://github.com/yagnavivek/PES_ASIC_CLASS/assets/93475824/e3075c6c-714b-42a6-ad99-bde2a7ed3023)

To Check the functionality, We refer to this waveform

![asyncres_wvf](https://github.com/yagnavivek/PES_ASIC_CLASS/assets/93475824/0788dc0a-95af-43c5-906d-a8961c6887e0)


## D-flip-flop with an asynchronous set [asyncset.v](https://github.com/yagnavivek/PES_ASIC_CLASS/blob/main/RTL_Verilog/verilog_files/asyncset.v) [asyncset_tb.v](https://github.com/yagnavivek/PES_ASIC_CLASS/blob/main/RTL_Verilog/verilog_files/asyncset_tb.v)

![asyncset_netlist](https://github.com/yagnavivek/PES_ASIC_CLASS/assets/93475824/f448f979-d3d7-4f6a-878c-681a7d4db8c0)

![asyncset_wvf](https://github.com/yagnavivek/PES_ASIC_CLASS/assets/93475824/04126806-59a3-4506-8877-c4901e45c592)

## D-flip-flop with both synchronous and asynchronous reset [sync_async_res.v](https://github.com/yagnavivek/PES_ASIC_CLASS/blob/main/RTL_Verilog/verilog_files/sync_async_res.v) [sync_async_res_tb.v](https://github.com/yagnavivek/PES_ASIC_CLASS/blob/main/RTL_Verilog/verilog_files/sync_async_res_tb.v)

![sync_async_res_netlist](https://github.com/yagnavivek/PES_ASIC_CLASS/assets/93475824/d0368959-6e54-4cd6-a015-683c6e9158f0)

![sync_async_res_wvf](https://github.com/yagnavivek/PES_ASIC_CLASS/assets/93475824/5ab8057d-43b6-4d00-9385-46c1ba6279f2)

## Most common issues with RISC-V toolchain on Fedora

1. pk not found error
    - Instead of running `spike pk <executable>` try running `spike $(which pk) <executable>`
2. Just `sudo dnf install iverilog`
3. RISC-V GNU toolchain takes a long time to build
    - It takes a while to build it, so let the system take its time and make sure it is charged.
4. If you face any issues like 'not found' just make sure you have included the GCC, pk and spike dirs in PATH in your `~/.bashrc` or `~/.zshrc`.
   
![zshrc](https://github.com/skudlur/pes_asic_class/blob/main/assets/zshrc.png "zshrc")
 
