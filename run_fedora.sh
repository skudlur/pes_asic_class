echo "--------RISC-V toolchain installed--------"
echo "Installing dependencied for Fedora"
sudo dnf install -y autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-develsudo dnf install -y git vim
echo "Creating a directory for installation"
mkdir riscv
cd riscv
echo "Cloning the toolchain repo, this installation will take a while"
git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --enable-multilib
make
export PATH=/opt/riscv/bin:$PATH
echo "RISC-V GCC toolchain successfully installed"
cd ..
sudo dnf install -y dtc
echo "Installed Device Tree Compiler!"
echo "Cloning SPIKE repo"
git clone https://github.com/riscv-software-src/riscv-isa-sim.git
cd riscv-isa-sim
mkdir build
cd build
../configure --prefix=/opt/riscv/bin
make
sudo make install
echo "Installed Spike successfully!"
cd ..
echo "Cloning RISC-V pk repo"
git clone https://github.com/riscv-software-src/riscv-pk.git
cd riscv-pk
mkdir build
cd build
../configure --prefix=/opt/riscv/bin --host=riscv64-unknown-elf
make
sudo make install
export PATH=/opt/riscv/riscv64-unknown-elf/bin:$PATH
echo "Installed pk successfully"
echo "Installing iverilog"
sudo dnf install -y iverilog
echo "Script completed!"
