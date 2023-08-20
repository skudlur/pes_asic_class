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
