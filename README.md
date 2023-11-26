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

#### Mapped file when used "-noattr" switch
![image](https://github.com/skudlur/pes_asic_class/assets/38615795/a9b593f1-de49-4beb-8221-20a50ede41e5)

#### Mapped file when the above switch not used
![image](https://github.com/skudlur/pes_asic_class/assets/38615795/5e54c48b-c0e3-4707-9c51-4f70fb08e9b4)

## Day 2 - Timing libs, Efficient flop coding styles

lib file name : ![sky130_fd_sc_hd__tt_025C_1v80.lib](https://github.com/skudlur/pes_asic_class/blob/main/rtl/sky130_fd_sc_hd__tt_025C_1v80.lib)
- ```tt``` - Typical PMOS typical NMOS (Regular working speed)
- ```025C``` - Temperature
- ```1v80``` - supply voltage
The above 3 parameters shortly known as PVT(Process Voltage Temperat ure) define how and at what conditions the fabricated silicon works
- ```sky130``` - 130nm Technology node
- ```fd``` - Foundry design
- ```sc``` - standard cell
- ```hd``` - high density - This specifies that this library supports using these standard cells at a high density resulting in samller chip area

- The library file consists of all the details of the cell ie., leakage power, area, timing etc. for all input combinations
- The library file consists of some same cell with different loads that facilitate the synthesis process.

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/f38e99b8-b38a-495e-a0bd-ee46d4b8934b)

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
### Hierarchical Synthesis output Multiple_modules.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/52da35f9-3b1a-49c2-8391-ece91bff544d)

### Flattened Synthesis netlist

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/a060ad50-559f-4f4c-ad89-01422fb94f56)

### Submodule Synthesis netlist (submodule2 in this case)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/2a7ee90e-e7b7-4e95-a6e8-5f3ea679e11d)

#### Note : 
- While synthesizing OR gate, AND gate, most of the times the tool uses NAND Gates to obtain the functionality as in NAND gates,The NMOS are connected in series and provide better signal transfer.
- Submodule level synthesis helps reduce synthesis time when in a massive design, the same submodule has been called many times and also we can synthesize all submodules and stitch them to obtain top level.But here the optimisation also takes place at submodule level, not at top level.

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

## D-flip-flop with an asynchronous reset asyncres.v asyncres_tb.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/a6f095cc-4451-4bf4-8638-aaa7d1453450)

Since we see a D Flip Flop getting inferred, We use the above mentioned dfflibmap command to map the flops accurately
View the output waveforms

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/28894575-2fe9-4e33-9c9c-70db043f03bf)

To check the functionality, We refer to this waveform

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/0a241e07-c40a-4c4e-b136-f62d2cf6d502)

## D-flip-flop with an asynchronous set asyncset.v asyncres_tb.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/3cd9dd22-65a5-4fa7-a4be-16104512a61d)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/c9b7d723-0974-4ffe-b3bb-69c049543ba7)

## D-flip-flop with both synchronous and asynchronous reset sync_async_res.v sync_async_res_tb.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/11aef5c8-4346-4531-a72c-f504bc38e324)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/5c0222ce-26d0-4b21-b7d9-7f52356f20f1)

## [mul2.v](https://github.com/yagnavivek/PES_ASIC_CLASS/blob/main/RTL_Verilog/verilog_files/mul2.v) 

![mul2_full](https://github.com/yagnavivek/PES_ASIC_CLASS/assets/93475824/d9ac5584-9c21-4308-ad06-d3c83b936871)

When a number is multiplied by 2, it just means that the number is right shifted once. Therefore a bit "0" is appended at the end of the number to be multiplied by 2. Therefore optimisation has been done by appending a ground bit instead of inferring a multiplier.

## mul8.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/2e739e26-bc85-4307-a011-87991b6ae22c)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/5caa0bc9-c503-442e-95a9-6da029838b94)

mul8 is nothing but a(8+1) so append 3 zeroes at end for a and add a .Therefore multiplier is not inferred here and only 3 bits are added.

## Day 3 - Combinational and sequential optimizations

## Logic Optimisation

- Combinational Logic Optimisation
	- Constant Propogation
	- Boolean logic Optimisation
- Sequential Logic Optimisation
	- Sequential constant propogation
	- State optimisation
	- Retiming
	- Sequential logic cloning

#### To perform the combinational logic optimisation, use the command ```opt_clean -purge``` before linking to abc  and synthesize.

## opt_check1.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/6e506377-fc0d-478d-845e-c4311260800a)

## opt_check2.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/6c0b7f39-0589-4104-93e4-1a6c74279463)

## opt_check3.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/7214ec30-9c7a-4860-97ec-32ff34eb710a)

## opt_check4.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/8737cccf-735d-473b-8134-85dace99f490)


## multiple_modules_opt.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/95e29a5a-5ed6-4272-9490-5d48e21d9ebe)

Inorder to optimise a verilog files that has submodules, We have to first flatten it, then optimize ```opt_clean -purge``` and complete the synthesis process

Here we can observe that instead of using ```and``` gate and ```or``` gates, its using ```AOI```

#### sequential logic optimisation

## dff_const1 dff_const1_tb.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/20bb8d7e-4787-4166-b4cc-ddbf199289c3)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/254a1795-1da6-4bd9-abf8-75338ad66842)

## dff_const2 dff_const2_tb.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/fb2acb71-2261-4bd0-990c-ee3363bd76b0)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/d056bebc-a745-4acb-ae01-9992e1ba6630)

## dff_const3 dff_const3_tb.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/90d4e40b-5615-42d2-9a46-5d92132aaadc)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/527faf54-8120-481b-8127-8e780b526ac0)

## dff_const4 dff_const4_tb.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/0a3a0dd2-d167-4ce5-a7d1-55b6693dbd6d)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/7f844303-edca-40f7-880e-a5b7e27bf3a2)

## dff_const5 dff_const5_tb.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/2e527b60-f18b-4994-aa4f-1d2597e79899)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/0861a884-6af4-4eb6-b6a0-56eb9e8ae2b1)

## counter_opt1.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/a73ca3a1-b998-4256-9077-23a4baa17834)

Usually a 3 bit counter requires 3 flops but since the output here is dependent on only the LSB and other 2 bits are unused. Therefore only one flop is being down and as we know that LSB toggles every clock cylce,its just using an inverter to invert the output at every clock cycle.

## counter_opt2.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/a3478c41-9663-4de4-a550-e26d6071de36)

Since the logic is changed such that the output is dependent on all 3 bits, it has inferred 3 flip flops.

## Day 4 - GLS, Synthesis solution mismatch

## Gate Level Simulation(GLS)

- used for post-synthesis verification to ensure functionality and timing requirements
- input : testbench ,synthesized netlist of a deisgn, gate level verilog models (since design now is synthesised one , it has library gate definitions in it.so we have to pass those verilog models too)
- sometimes there is a mismatch in simulation results for post-synthesis netlist that's called synthesis simulation mismatch

### Synthesis Simulation Mismatch

Reasons : 
- **Missing Sensitivity list**
- **Blocking(sequential execution) vs Non Blocking assignments(parallel Execution)**
- **Non standard verilog codeing**

### GLS Lab

```
synthesize conditional_mux and write its netlist
iverilog <Path_to_primitives.v>/primitives.v <path_to_sky130_fd_sc_hd.v>/sky130_fd_sc_hd.v <path_to_synthesized_netlist>/conditional_mux_mapped.v <path_to_original_file>/conditional_mux_tb.v -o conditional_mux_gls.out
./conditional_mux_gls.out
gtkwave conditional_mux_tb.vcd
```

## presynthesis(above) and post-synthesis simulation(below) conditional_mux.v conditional_mux_tb.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/76dd7ded-5adf-4d84-87e6-1f2bc36c8ace)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/240154e0-b4d9-4640-a8c9-a275dad6e0c7)

Since the presynthesis and post-synthesis waveforms are same, it confirms that the synthesized netlist is functionally correct

## presynthesis(above) and post-synthesis(below) bad_mux.v bad_mux_tb.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/6c8b33eb-51b0-4f79-9370-09d064c9acc6)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/76a50841-6be5-4ee3-8ca9-e83608b57b2a)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/a6922a44-b265-4372-bb26-dbfa0693a705)

since the sensitivity list had only select signal, the output changes only when select signal changes irrespective of input 1 and 0. The presynthesis waveform explains the same. But after synthesizing, the waveform can be explained such a way that output is depending on all the input changes. This case is called **Synthesis Simulation Mismatch**

##  presynthesis(above) and post-synthesis(below) Blocking_error.v Blocking_error_tb.v

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/2c48f272-f8b1-4695-816d-9b306016b922)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/292bd90a-614d-4ff8-92d9-4d690df6617e)

![image](https://github.com/skudlur/pes_asic_class/assets/38615795/5a6791a7-f06c-4b6d-bbd5-c54c1f4f5f0b)

when we observe the code, d=x&c and x=a|b so d depends on x but x is evaluated after d.so d uses previous value of x to compute itself.Therefore we can say that if previous value is being used, then it's behaving like a flop and the same can be observed in waveform. But after synthesis, its behoviour is normal as-if value of x has been computed before giving to d. This state can be called as **Synthesis Simulation Mismatch**

## Most common issues with RISC-V toolchain on Fedora

1. pk not found error
    - Instead of running `spike pk <executable>` try running `spike $(which pk) <executable>`
2. Just `sudo dnf install iverilog`
3. RISC-V GNU toolchain takes a long time to build
    - It takes a while to build it, so let the system take its time and make sure it is charged.
4. If you face any issues like 'not found' just make sure you have included the GCC, pk and spike dirs in PATH in your `~/.bashrc` or `~/.zshrc`.
   
![zshrc](https://github.com/skudlur/pes_asic_class/blob/main/assets/zshrc.png "zshrc")
 
