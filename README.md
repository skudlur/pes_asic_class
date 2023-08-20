# pes_asic_class
Repo for the lab assignments for ASIC Special topic

# System Information

- Laptop - ThinkPad T470
- Operating System - Fedora 36
- OS Bit length - 64-bit
- RAM - 8GB
- Memory - 512GB

# Most common issues with RISC-V toolchain on Fedora

1. pk not found error
    - Instead of running `spike pk <executable>` try running `spike $(which pk) <executable>`
2. Just `sudo dnf install iverilog`
3. RISC-V GNU toolchain takes a long time to build
    - It takes a while to build it, so let the system take its time and make sure it is charged.
4. If you face any issues like 'not found' just make sure you have included the GCC, pk and spike dirs in PATH in your `~/.bashrc` or `~/.zshrc`.
   
![zshrc](https://github.com/skudlur/pes_asic_class/blob/main/assets/zshrc.png "zshrc")
 
