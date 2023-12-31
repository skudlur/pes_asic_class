# Day - 1 Lab assignments.

## Using GCC and RISC-V GCC to compile a C-program

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

## Using RISC-V GCC to get disassembly

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

## Running Spike to debug the disassembly

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

