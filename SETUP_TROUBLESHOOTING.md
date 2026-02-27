# Anura OS Linux Setup & Build Troubleshooting Guide

## Overview

This guide covers setting up Anura OS on various Linux distributions and troubleshooting common build issues.

## Supported Linux Distributions

The setup script supports all major Linux distributions:

- **Debian/Ubuntu** (apt)
- **Fedora/RHEL/CentOS** (dnf/yum)
- **Arch Linux** (pacman)
- **openSUSE** (zypper)
- **Alpine Linux** (apk)
- **And other systemd-based distributions**

## Quick Start

### For Debian/Ubuntu/similar:
```bash
sudo ./anura-full-setup.sh
```

### For Fedora/RHEL:
```bash
sudo ./anura-full-setup.sh
```

### For Arch Linux:
```bash
sudo ./anura-full-setup.sh
```

The script automatically detects your distribution and uses the appropriate package manager.

## Common Build Issues & Solutions

### Issue 1: Rust Transmute Warnings

**Symptoms:**
```
warning: unnecessary transmute
    --> src/rust/cpu/instructions_0f.rs:2456:24
```

**Important Note:**
These warnings are safe to suppress. They occur because the v86 codebase uses `std::mem::transmute()` for type reinterpretation between arrays of different sizes. The Rust compiler suggests safer alternatives like `from_ne_bytes()`, but these don't work for arrays larger than 8 bytes or of different element types.

**Solutions:**

**Option A: Suppress Warnings (Recommended)**
The build patches script automatically adds warning suppression:
```bash
./anura-build-patches.sh
make all
```

**Option B: Accept Warnings During Build**
These warnings don't prevent compilation - the build will complete even with warnings displayed:
```bash
make all 2>&1 | tee build.log
```

**Option C: Investigate Further**
If transmute warnings cause compilation errors (not just warnings), see Issue #2 below.

### Issue 1b: Rust Transmute Type Mismatch Errors

**Symptoms:**
```
error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4194:43
     |
4194 | write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                    ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
```

**Root Cause:**
Automated patching tried to replace transmute with type conversion (like `from_ne_bytes()`), but resulted arrays have different types (`[u16; 4]`, `[i16; 4]`, `[i8; 8]`, etc.) where automatic conversion doesn't work.

**Solution:**
Use the proper build patches which suppress warnings instead of trying to "fix" the transmute:
```bash
./anura-build-patches.sh
make all
```

This will add `#![allow(unsafe_code)]` to suppress transmute warnings while keeping the original (safe) working code.

### Issue 2: WASM Linker Error - "global-base cannot be less than stack size"

**Symptoms:**
```
rust-lld: error: --global-base cannot be less than stack size when --stack-first is used
```

**Root Cause:**
The v86 WASM build has `--global-base=4096` but `--stack-first` with `--stack-size=1048576`, which are incompatible.

**Solutions:**

**Option A: Use Build Patches (Recommended)**
```bash
./anura-build-patches.sh
make all
```

**Option B: Manual Environment Fix**
```bash
export RUSTFLAGS="-C link-args=-z -C link-args=stack-size=1048576"
make all
```

**Option C: Modify v86 Build (if patches don't work)**
Edit `v86/tools/rust-lld-wrapper` and adjust the linker options to not use `--stack-first` when `--global-base` is too small.

### Issue 3: Git Submodule Not Initialized

**Symptoms:**
```
v86 directory is empty
Build fails immediately
```

**Solution:**
The setup script handles this automatically, but if needed, initialize manually:
```bash
git submodule update --init --recursive
```

### Issue 4: Package Manager Not Found

**Symptoms:**
```
Could not detect package manager
```

**Solution:**
Install packages manually for your distribution before running the setup script:

**Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install -y build-essential curl git python3 python3-dev libssl-dev
```

**Fedora/RHEL:**
```bash
sudo dnf install -y @development-tools curl git python3 python3-devel openssl-devel
```

**Arch:**
```bash
sudo pacman -S base-devel curl git python3
```

### Issue 5: Rust Toolchain Not Found

**Symptoms:**
```
rustup: command not found
```

**Solution:**
The setup script installs Rust automatically. If you're getting this error, ensure Rust is in your PATH:

```bash
source $HOME/.cargo/env
```

Or add this to your `~/.bashrc` or `~/.zshrc`:
```bash
export PATH="$HOME/.cargo/bin:$PATH"
```

### Issue 6: Node.js/npm Version Issues

**Symptoms:**
```
npm version too old
node version incompatible
```

**Solution:**
The setup script installs Node.js 20 from NodeSource. You can also manually update:

**Debian/Ubuntu:**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt-get install -y nodejs
```

**Fedora/RHEL:**
```bash
sudo dnf install -y nodejs npm
```

## Manual Steps if Automated Setup Fails

```bash
# 1. Update system
sudo apt update && sudo apt upgrade -y  # or your package manager

# 2. Install dependencies
sudo apt install -y build-essential curl wget git pkg-config python3 python3-dev libssl-dev zlib1g-dev uuid-runtime gcc-multilib

# 3. Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs

# 4. Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
source $HOME/.cargo/env
rustup target add wasm32-unknown-unknown i686-unknown-linux-gnu

# 5. Install npm dependencies
npm install

# 6. Update git submodules
git submodule update --init --recursive

# 7. Apply build patches
./anura-build-patches.sh

# 8. Build
make all

# 9. Build server
cd server && npm install && cd ..

# 10. Create systemd service (optional)
sudo ./anura-full-setup.sh  # Run this for the service setup part
```

## Systemd Service Setup

After successful build, create a systemd service for 24/7 operation:

```bash
# Interactive setup
sudo ./anura-full-setup.sh

# Manual setup:
sudo tee /etc/systemd/system/anura-os.service > /dev/null << EOF
[Unit]
Description=Anura OS Server
After=network.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$(pwd)/server
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable anura-os
sudo systemctl start anura-os

# View status
sudo systemctl status anura-os
```

## Using the Error Logs

The setup script creates two log files to help with troubleshooting:

### Build Log: `setup-build.log`

Contains full output from all build commands:
```bash
# View build log in real-time (if running)
tail -f setup-build.log

# View specific errors in build log
grep -i error setup-build.log

# View last 50 lines
tail -50 setup-build.log
```

### Error Summary: `setup-errors.txt`

Contains captured errors and their context:
```bash
# View error summary
cat setup-errors.txt

# View formatted output
less setup-errors.txt
```

### Finding Your Specific Error

1. **Look at error summary first:**
   ```bash
   cat setup-errors.txt
   ```

2. **Search for error in build log:**
   ```bash
   grep -A 5 -B 5 "error\[" setup-build.log
   ```

3. **Check for specific warnings:**
   ```bash
   grep "warning\|error" setup-build.log | head -20
   ```

## Common Issues and Log Patterns

### If you see transmute type mismatches:

```bash
# Check if patches were applied
grep "allow(unsafe_code)" v86/src/rust/cpu/instructions_0f.rs

# If not found, apply patches:
./anura-build-patches.sh

# Then retry build:
make clean
make all
```

### Checking specific file for issues:

```bash
# Count compilation errors
grep "^error\[" setup-build.log | wc -l

# See all error types
grep "^error\[" setup-build.log | cut -d: -f1 | sort | uniq -c

# Get detailed error info
grep -A 10 "^error\[E0308\]" setup-build.log | head -30
```

## Checking Build Status

```bash
# View build logs
make clean
make all 2>&1 | tee setup-build.log

# Check if server was built
ls -la v86/build/v86.wasm
ls -la public/dist/ 2>/dev/null || echo "Frontend not built yet"

# Test the server
cd server
npm start
```

## Environment Variables

Optional configuration for the setup:

```bash
# Use specific Node version
NODE_VERSION=20

# Use specific Rust profile
RUST_PROFILE=minimal

# Custom build flags
RUSTFLAGS="-C opt-level=3"

# Skip certain steps
SKIP_FRONTEND_BUILD=1
SKIP_SERVER_BUILD=1
```

## Getting Help

If you're still having issues:

1. Check the build logs: `cat build.log`
2. Check systemd journal: `journalctl -u anura-os -n 50`
3. Verify all dependencies are installed: `make clean && make all`
4. Check GitHub issues: https://github.com/MercuryWorkshop/anuraOS
5. Open a detailed issue with your OS, distribution version, and full error output

## Platform-Specific Notes

### VPS Deployment (Debian)

For deploying on a VPS:

```bash
# Ensure you have enough disk space (10GB+ recommended)
df -h

# Run setup with nohup to persist after SSH disconnect
sudo nohup bash -c './anura-full-setup.sh 2>&1 | tee /tmp/anura-setup.log' &

# Monitor progress
tail -f /tmp/anura-setup.log
```

### Minimal/Alpine Linux

Alpine's musl libc may cause issues. Use build patches:

```bash
./anura-build-patches.sh
make all
```

### Docker/Container

The setup script works in containers but may need privileged mode:

```dockerfile
FROM debian:bookworm
RUN apt-get update && apt-get install -y curl sudo
COPY . /app
WORKDIR /app
RUN chmod +x anura-full-setup.sh && ./anura-full-setup.sh
```

---

**Last Updated:** February 2026  
**Tested On:** Debian 12, Ubuntu 22.04, Fedora 39, Arch Linux, Alpine 3.19
