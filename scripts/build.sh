#!/bin/sh -x

root=$(pwd)

#********************************************************************
#* Install required packages
#********************************************************************
if test $(uname -s) = "Linux"; then
    yum update -y
    yum install -y wget texinfo bison flex make gcc gcc-c++ git \
        python3 python3-devel expat-devel xz-devel zlib-devel \
        ncurses-devel gmp-devel mpfr-devel libmpc-devel

    if test -z $image; then
        image=linux
    fi
    export PATH=/opt/python/cp312-cp312/bin:$PATH
    
    rls_plat=${image}
fi

#********************************************************************
#* Validate environment variables
#********************************************************************
if test -z $gdb_latest_rls; then
  echo "gdb_latest_rls not set"
  env
  exit 1
fi

#********************************************************************
#* Calculate version information
#********************************************************************
if test -z ${rls_version}; then
    rls_version=${gdb_latest_rls}

    if test "x${BUILD_NUM}" != "x"; then
        rls_version="${rls_version}.${BUILD_NUM}"
    fi
fi

gdb_tag="gdb-${gdb_latest_rls}-release"

echo "Building GDB version: ${gdb_latest_rls}"
echo "GDB tag: ${gdb_tag}"
echo "Release version: ${rls_version}"
echo "Platform: ${rls_plat}"

#********************************************************************
#* Download and extract GDB source
#********************************************************************
cd ${root}
rm -rf gdb-src
mkdir -p gdb-src
cd gdb-src

echo "Downloading GDB source..."
wget -q https://ftp.gnu.org/gnu/gdb/gdb-${gdb_latest_rls}.tar.xz
if test $? -ne 0; then
    echo "Failed to download GDB source"
    exit 1
fi

tar xf gdb-${gdb_latest_rls}.tar.xz
if test $? -ne 0; then
    echo "Failed to extract GDB source"
    exit 1
fi

cd gdb-${gdb_latest_rls}

#********************************************************************
#* Check for Tensilica support
#********************************************************************
echo "Checking for Tensilica (xtensa) support in GDB..."
if test -d "bfd" && grep -r "xtensa" bfd/config.bfd > /dev/null 2>&1; then
    echo "Tensilica/Xtensa support found in GDB source"
    ENABLE_XTENSA="--enable-targets=xtensa-esp32-elf,xtensa-esp32s2-elf,xtensa-esp32s3-elf"
else
    echo "Tensilica/Xtensa support not found, building without it"
    ENABLE_XTENSA=""
fi

#********************************************************************
#* Configure GDB
#********************************************************************
echo "Configuring GDB..."
mkdir -p ${root}/build
cd ${root}/build

# Configure GDB with multi-architecture support
# Enable x86_64, i386, riscv32, riscv64, and xtensa (if available)
${root}/gdb-src/gdb-${gdb_latest_rls}/configure \
    --prefix=${root}/release/gdb \
    --enable-targets=x86_64-linux-gnu,i386-linux-gnu,riscv32-unknown-elf,riscv64-unknown-elf${ENABLE_XTENSA:+,$ENABLE_XTENSA} \
    --disable-werror \
    --with-python=python3 \
    --with-expat \
    --with-lzma \
    --enable-tui \
    --with-system-readline=no \
    --with-gmp \
    --with-mpfr

if test $? -ne 0; then
    echo "Configure failed"
    exit 1
fi

#********************************************************************
#* Build GDB
#********************************************************************
echo "Building GDB..."
make -j$(nproc)
if test $? -ne 0; then
    echo "Build failed"
    exit 1
fi

#********************************************************************
#* Install GDB
#********************************************************************
echo "Installing GDB..."
make install
if test $? -ne 0; then
    echo "Install failed"
    exit 1
fi

#********************************************************************
#* Post-install cleanup
#********************************************************************
cd ${root}/release

# Strip binaries to reduce size
strip gdb/bin/* 2>/dev/null || true

# Remove unnecessary files
rm -rf gdb/share/info
rm -rf gdb/share/man

#********************************************************************
#* Create release tarball
#********************************************************************
echo "Creating release tarball..."
tar czf gdb-multiarch-${rls_plat}-${rls_version}.tar.gz gdb
if test $? -ne 0; then
    echo "Failed to create tarball"
    exit 1
fi

echo "Build complete: gdb-multiarch-${rls_plat}-${rls_version}.tar.gz"

# Print GDB version and supported architectures
echo ""
echo "GDB built successfully:"
${root}/release/gdb/bin/gdb --version | head -n 1
echo ""
echo "Supported architectures:"
${root}/release/gdb/bin/gdb --configuration | grep -i "target" || echo "Configuration not available"
