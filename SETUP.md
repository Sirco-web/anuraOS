# Anura OS Automated Setup Guide

## Quick Start: 30 Seconds

1. **Clone and enter directory:**
   ```bash
   cd /path/to/anuraOS
   ```

2. **Run setup (all distros supported):**
   ```bash
   sudo ./anura-full-setup.sh
   ```

3. **Follow the prompts** - the script will:
   - ✅ Detect your Linux distribution automatically
   - ✅ Install all required dependencies (Rust, Node.js, build tools)
   - ✅ Build Anura OS from source
   - ✅ Setup optional systemd service for 24/7 operation

That's it! The server will be ready to use.

## Supported Operating Systems

| Distribution | Package Manager | Status |
|---|---|---|
| Ubuntu 20.04+ | apt | ✅ Tested |
| Debian 11+ | apt | ✅ Tested |
| Fedora 38+ | dnf | ✅ Supported |
| RHEL/CentOS 8+ | dnf/yum | ✅ Supported |
| Arch Linux | pacman | ✅ Supported |
| openSUSE | zypper | ✅ Supported |
| Alpine Linux | apk | ✅ Supported |

## What Gets Installed

### System Dependencies
- Build tools (gcc, g++, make, ninja)
- Rust toolchain with wasm32 target
- Node.js 20 LTS
- Development libraries (OpenSSL, zlib, readline, etc.)
- Git for version control

### Anura OS Components
- v86 CPU emulator (compiled to WebAssembly)
- Frontend (TypeScript/React)
- Node.js server
- All npm dependencies

### Optional
- Systemd service for automatic startup

## Build Time

- **First build:** 15-30 minutes (depends on CPU/disk speed)
- **Subsequent builds:** 5-10 minutes
- **Total with setup:** 20-45 minutes

## Disk Space

- **Minimum required:** 5GB
- **Recommended:** 10GB+
- **With npm cache:** 15GB

## System Requirements

| Resource | Minimum | Recommended |
|---|---|---|
| CPU | 2 cores | 4+ cores |
| RAM | 2GB | 4GB+ |
| Disk | 5GB | 10GB+ |
| Network | 500MB+ | Fast (gigabit) |

## Features

### ✨ Interactive Setup
- Colored output with progress indicators
- Automatic OS detection
- Comprehensive error messages
- Recovery suggestions

### 🔧 Systemd Integration
- Automatic service creation
- Auto-restart on failure
- Journal logging with `journalctl`
- Enable/disable on system boot

### 📊 Build Patches
- Automatic transmute warning fixes
- WASM linker compatibility patches
- Git submodule initialization
- Cross-distribution support

### 🆘 Troubleshooting
- Detailed error logging
- Built-in solutions for common issues
- Separate `anura-build-patches.sh` for advanced users
- Comprehensive `SETUP_TROUBLESHOOTING.md` guide

## Usage Examples

### Standard Setup
```bash
sudo ./anura-full-setup.sh
```

### With Custom Node Port
```bash
sudo ./anura-full-setup.sh
# When prompted: Enter port 3000 (instead of default 8080)
```

### Systemd Service Management
```bash
# Check status
sudo systemctl status anura-os

# View logs
sudo journalctl -u anura-os -f

# Restart
sudo systemctl restart anura-os

# Stop
sudo systemctl stop anura-os

# Start
sudo systemctl start anura-os
```

### Manual Build (without full setup)
```bash
# If you already have dependencies installed
./anura-build-patches.sh
make all
cd server && npm install && cd ..
```

## Troubleshooting

### Build Fails
1. Check `SETUP_TROUBLESHOOTING.md`
2. Run: `./anura-build-patches.sh`
3. Verify disk space: `df -h`
4. Check internet connection (for downloads)

### Systemd Service Issues
```bash
# View detailed logs
journalctl -u anura-os -n 100

# Restart service
sudo systemctl restart anura-os

# Check if port is in use
sudo lsof -i :8080
```

### Out of Disk Space
```bash
# Check available space
df -h

# Clean Rust cache
cargo clean

# Clean npm cache
npm cache clean --force

# Remove build artifacts
make clean
```

## Advanced Options

### Environment Variables
```bash
# Skip frontend build
SKIP_FRONTEND=1 ./anura-full-setup.sh

# Use specific Node version
NODE_VERSION=18 sudo ./anura-full-setup.sh

# Custom Rust flags
RUSTFLAGS="-C opt-level=3" make all
```

### Manual Patching
```bash
./anura-build-patches.sh           # Apply build patches
./anura-full-setup.sh              # Run full setup
```

### Docker Deployment
```dockerfile
FROM debian:bookworm
WORKDIR /app
COPY . .
RUN chmod +x anura-full-setup.sh && sudo ./anura-full-setup.sh
EXPOSE 8080
CMD ["npm", "start"]
```

## VPS Deployment

For running on a remote VPS with persistent execution:

```bash
# SSH to your VPS, then:
cd /opt/anuraOS
sudo nohup bash -c './anura-full-setup.sh 2>&1 | tee setup.log' &

# Monitor progress
tail -f setup.log

# Check status later
sudo systemctl status anura-os
```

## Next Steps After Setup

1. **Start the server:**
   ```bash
   npm start  # from server directory
   ```

2. **Access Anura OS:**
   - Local: `http://localhost:8080`
   - Remote: `http://your-vps-ip:8080`

3. **Configure firewall (if needed):**
   ```bash
   # For ufw
   sudo ufw allow 8080/tcp
   
   # For firewalld
   sudo firewall-cmd --add-port=8080/tcp --permanent
   sudo firewall-cmd --reload
   ```

4. **Setup reverse proxy (nginx/Apache)** for production use

5. **Configure HTTPS** with Let's Encrypt SSL

## File Reference

- `anura-full-setup.sh` - Main setup script (run with sudo)
- `anura-build-patches.sh` - Build fix script (optional, auto-called)
- `SETUP_TROUBLESHOOTING.md` - Detailed troubleshooting guide
- `Makefile` - Build configuration
- `package.json` - Node.js dependencies

## Getting Help

1. **Check documentation:** `SETUP_TROUBLESHOOTING.md`
2. **Review log files:**
   ```bash
   cat setup.log
   journalctl -u anura-os -n 100
   ```
3. **Check GitHub:** https://github.com/MercuryWorkshop/anuraOS
4. **Manual setup:** See "Manual Steps" in SETUP_TROUBLESHOOTING.md

## License

Anura OS is licensed under the AGPL-3.0 License. See LICENSE file for details.

---

**Version:** 1.0  
**Updated:** February 2026  
**Tested Distributions:** Debian 12, Ubuntu 22.04, Fedora 39, Arch Linux, Alpine 3.19
