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

## Most common issues with RISC-V toolchain on Fedora

1. pk not found error
    - Instead of running `spike pk <executable>` try running `spike $(which pk) <executable>`
2. Just `sudo dnf install iverilog`
3. RISC-V GNU toolchain takes a long time to build
    - It takes a while to build it, so let the system take its time and make sure it is charged.
4. If you face any issues like 'not found' just make sure you have included the GCC, pk and spike dirs in PATH in your `~/.bashrc` or `~/.zshrc`.
   
![zshrc](https://github.com/skudlur/pes_asic_class/blob/main/assets/zshrc.png "zshrc")
 
