# pes_asic_class
Repo for the lab assignments for VLSI Physical Design for ASICs Special topic, August 2023.

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

1. RISC-V GCC GNU Toolchain - Compiler collection to compile languages like C, C++ to RISC-V assembly. I have built the compiler from ![source](https://github.com/riscv-collab/riscv-gnu-toolchain). The shell script also builds it from source because the one that is specified in the course is only for Ubuntu and other Debian systems. I have compiled both 64 and 32-bit compilers (multilib) as well as Linux compilers to experiment further but this is not necessary, just 64-bit should suffice (The shell installer will only install 64-bit compilers).

2. RISC-V ISA Simulator (SPIKE) - Again built it from ![source](https://github.com/riscv-software-src/riscv-isa-sim). This simulator is used to run RISC-V executables that cannot be run on our host machines. (yet ;))

3. RISC-V Proxy Kernel (pk) - Built it from the ![source](https://github.com/riscv-software-src/riscv-pk). This hosts statically-linked RISC-V ELF binaries. This allows the system calls from the RISC-V binaries to be translated to host target specific syscalls to execute them as intended.

## Installation guide for Fedora users

```bash
git clone https://github.com/skudlur/pes_asic_class.git
cd pes_asic_class
chmod +x run_fedora.sh
./run_fedora.sh
```

# Lab assignments

## Day - 1 Lab assignments.

- All the code can be found in the respective day directories.

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

## Day - 2 Lab assignments

To be updated.

## Most common issues with RISC-V toolchain on Fedora

1. pk not found error
    - Instead of running `spike pk <executable>` try running `spike $(which pk) <executable>`
2. Just `sudo dnf install iverilog`
3. RISC-V GNU toolchain takes a long time to build
    - It takes a while to build it, so let the system take its time and make sure it is charged.
4. If you face any issues like 'not found' just make sure you have included the GCC, pk and spike dirs in PATH in your `~/.bashrc` or `~/.zshrc`.
   
![zshrc](https://github.com/skudlur/pes_asic_class/blob/main/assets/zshrc.png "zshrc")
 
