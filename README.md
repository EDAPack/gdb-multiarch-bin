# GDB Multi-Architecture Binaries

Pre-built GDB binaries with support for multiple target architectures.

## Features

- **All Architectures**: Built with `--enable-targets=all` to support every architecture GDB can debug
- **Key Architectures Include**:
  - x86/x86_64 (Intel/AMD)
  - RISC-V (32-bit and 64-bit)
  - Xtensa (Tensilica LX6/LX7 - ESP32 support)
  - ARM/AArch64
  - PowerPC, MIPS, SPARC, and many more
- **Linux Only**: x86_64 and ARM64 builds for multiple Linux distributions
- **Wide Compatibility**: Built on manylinux2014, manylinux_2_28, and manylinux_2_34

## Available Builds

Each release includes 5 binary packages:
- `gdb-multiarch-manylinux2014_x86_64-*.tar.gz` - Oldest, most compatible (CentOS 7+)
- `gdb-multiarch-manylinux_2_28_x86_64-*.tar.gz` - Modern x86_64 systems
- `gdb-multiarch-manylinux_2_34_x86_64-*.tar.gz` - Latest x86_64 systems
- `gdb-multiarch-manylinux_2_28_aarch64-*.tar.gz` - Modern ARM64 systems
- `gdb-multiarch-manylinux_2_34_aarch64-*.tar.gz` - Latest ARM64 systems

## Installation

```bash
# Download the appropriate build for your system
wget https://github.com/EDAPack/gdb-multiarch-bin/releases/download/vX.X.X/gdb-multiarch-*.tar.gz

# Extract
tar xzf gdb-multiarch-*.tar.gz

# Use directly or install to system
./gdb/bin/gdb --version

# Or copy to system location
sudo cp -r gdb /opt/gdb-multiarch
sudo ln -s /opt/gdb-multiarch/bin/gdb /usr/local/bin/gdb-multiarch
```

## Usage

```bash
# Debug x86_64 binary
gdb ./my-x86-program

# Debug RISC-V binary
gdb --architecture=riscv:rv32 ./my-riscv-program

# Debug Xtensa/ESP32 binary
gdb --architecture=xtensa ./my-esp32-program

# Remote debugging
gdb -ex "target remote localhost:3333" ./firmware.elf
```

## Build Configuration

- GDB Version: 17.1 (auto-updated from GNU FTP)
- Python: Disabled (reduces dependencies)
- TUI: Disabled (ncurses compatibility)
- Simulator: Disabled (focus on debugging, not simulation)
- Expat: Enabled (XML support)
- LZMA: Enabled (compression support)

## Automated Builds

- **CI Workflow**: Automatically builds on every push and weekly schedule
- **Release Workflow**: Manual workflow to build specific GDB versions
- **Monitoring**: Use `gh run watch` to monitor builds in progress

## Development

To modify the build:

1. Edit `.github/workflows/ci.yml` or `scripts/build.sh`
2. Push changes to trigger build
3. Monitor with: `gh run list` and `gh run watch <run-id>`

## License

GDB is licensed under the GNU GPL v3+. These are unmodified binaries built from official GNU sources.

## Links

- [Official GDB Documentation](https://sourceware.org/gdb/documentation/)
- [GDB Source](https://www.gnu.org/software/gdb/)
- [Latest Release](https://github.com/EDAPack/gdb-multiarch-bin/releases/latest)
