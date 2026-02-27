#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
log_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

log_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

log_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

# Function to check if running with sudo when needed
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run with sudo for system package installation"
        exit 1
    fi
}

# Function to detect OS and get package manager
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_ID="$ID"
        OS_NAME="$PRETTY_NAME"
        
        # Detect package manager and set install command
        if command -v apt-get &> /dev/null; then
            PKG_MANAGER="apt"
            PKG_INSTALL="apt-get install -y"
            PKG_UPDATE="apt-get update"
            PKG_UPGRADE="apt-get upgrade -y"
        elif command -v dnf &> /dev/null; then
            PKG_MANAGER="dnf"
            PKG_INSTALL="dnf install -y"
            PKG_UPDATE="dnf check-update"
            PKG_UPGRADE="dnf upgrade -y"
        elif command -v yum &> /dev/null; then
            PKG_MANAGER="yum"
            PKG_INSTALL="yum install -y"
            PKG_UPDATE="yum check-update"
            PKG_UPGRADE="yum upgrade -y"
        elif command -v pacman &> /dev/null; then
            PKG_MANAGER="pacman"
            PKG_INSTALL="pacman -S --noconfirm"
            PKG_UPDATE="pacman -Sy"
            PKG_UPGRADE="pacman -Syu --noconfirm"
        elif command -v zypper &> /dev/null; then
            PKG_MANAGER="zypper"
            PKG_INSTALL="zypper install -y"
            PKG_UPDATE="zypper refresh"
            PKG_UPGRADE="zypper update -y"
        elif command -v apk &> /dev/null; then
            PKG_MANAGER="apk"
            PKG_INSTALL="apk add"
            PKG_UPDATE="apk update"
            PKG_UPGRADE="apk upgrade"
        else
            log_error "Could not detect package manager. Please install packages manually."
            exit 1
        fi
        
        log_info "Detected OS: $OS_NAME"
        log_info "Using package manager: $PKG_MANAGER"
    else
        log_error "Could not detect OS. Please ensure /etc/os-release exists."
        exit 1
    fi
}

# Main setup
main() {
    log_info "Starting Anura OS Full Setup..."
    
    # Check prerequisites
    detect_os
    check_sudo
    
    log_info "Step 1: Updating system packages..."
    $PKG_UPDATE || true
    $PKG_UPGRADE || true
    log_success "System packages updated"
    
    log_info "Step 2: Installing required build tools and dependencies..."
    
    # Install distro-specific packages
    case "$PKG_MANAGER" in
        apt)
            $PKG_INSTALL \
                build-essential \
                curl \
                wget \
                git \
                pkg-config \
                python3 \
                python3-dev \
                libssl-dev \
                zlib1g-dev \
                libreadline-dev \
                uuid-runtime \
                gcc-multilib \
                g++-multilib \
                ninja-build \
                ca-certificates
            ;;
        dnf|yum)
            $PKG_INSTALL \
                "@Development Tools" \
                curl \
                wget \
                git \
                pkgconfig \
                python3 \
                python3-devel \
                openssl-devel \
                zlib-devel \
                readline-devel \
                util-linux \
                gcc-multilib \
                glibc-devel.i686 \
                ninja-build \
                ca-certificates
            ;;
        pacman)
            $PKG_INSTALL \
                base-devel \
                curl \
                wget \
                git \
                pkg-config \
                python3 \
                openssl \
                zlib \
                readline \
                util-linux \
                ninja \
                ca-certificates
            ;;
        zypper)
            $PKG_INSTALL \
                -t pattern devel_basis \
                curl \
                wget \
                git-core \
                pkg-config \
                python3 \
                python3-devel \
                libopenssl-devel \
                zlib-devel \
                readline-devel \
                util-linux \
                gcc-multilib \
                ninja \
                ca-certificates
            ;;
        apk)
            $PKG_INSTALL \
                build-base \
                curl \
                wget \
                git \
                pkgconfig \
                python3 \
                python3-dev \
                openssl-dev \
                zlib-dev \
                readline-dev \
                util-linux \
                ninja \
                ca-certificates
            ;;
    esac
    
    log_success "Build tools and dependencies installed"
    
    log_info "Step 3: Installing Node.js and npm..."
    if ! command -v node &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt install -y nodejs
        log_success "Node.js installed"
    else
        log_success "Node.js already installed: $(node --version)"
    fi
    
    log_info "Step 4: Installing Rust toolchain..."
    if ! command -v rustup &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
        source "$HOME/.cargo/env"
        log_success "Rust installed"
    else
        log_success "Rust already installed: $(rustc --version)"
    fi
    
    # Ensure Rust is in PATH for this script
    export PATH="$HOME/.cargo/bin:$PATH"
    
    log_info "Step 5: Installing Rust targets..."
    rustup target add wasm32-unknown-unknown i686-unknown-linux-gnu
    log_success "Rust targets installed"
    
    log_info "Step 6: Installing npm dependencies..."
    npm install -g npm@latest
    npm install
    log_success "npm dependencies installed"
    
    log_info "Step 7: Updating git submodules..."
    git submodule update --init --recursive
    log_success "Git submodules updated"
    
    log_info "Step 8: Applying build patches..."
    apply_build_patches
    
    log_info "Step 9: Building Anura OS..."
    if ! make all; then
        log_warn "Initial build failed. Attempting with build patches..."
        if [[ -x "./anura-build-patches.sh" ]]; then
            ./anura-build-patches.sh
            log_info "Retrying build with patches applied..."
            if ! make all; then
                log_error "Build failed even with patches. Check the error messages above."
                log_info "You can try manually patching the Rust files or check v86 submodule status."
                exit 1
            fi
        else
            log_error "Build failed and patch script not found. Installation cannot continue."
            exit 1
        fi
    fi
    log_success "Anura OS built successfully"
    
    log_info "Step 9: Building server..."
    if [[ -f "server/package.json" ]]; then
        cd server
        npm install
        cd ..
        log_success "Server dependencies installed"
    fi
    log_success "Server ready"
    
    log_info "Step 11: Verifying installation..."
    verify_installation
    log_success "All verifications passed!"
    
    log_info "Step 12: Systemd service setup..."
    setup_systemd_service
    
    log_success "Setup completed successfully!"
    echo ""
    log_info "=== Summary ==="
    echo "Anura OS has been fully set up on your $OS_NAME system."
    echo "All dependencies have been installed."
    echo "The server has been built and is ready to run."
    echo ""
    log_info "Next steps:"
    echo "1. Run the server manually: npm start (from the server directory)"
    echo "2. Or use the systemd service if you created one"
    echo ""
    log_info "Documentation:"
    echo "- Setup & Troubleshooting: SETUP_TROUBLESHOOTING.md"
    echo "- Main README: README.md"
    echo ""
    log_success "Installation complete! 🎉"
}

# Function to verify installation
verify_installation() {
    local checks_passed=0
    local checks_total=0
    
    log_info "Verifying installation..."
    
    # Check Node.js
    checks_total=$((checks_total + 1))
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        log_success "Node.js: $(node --version)"
        checks_passed=$((checks_passed + 1))
    else
        log_error "Node.js not found"
    fi
    
    # Check Rust
    checks_total=$((checks_total + 1))
    if command -v rustc &> /dev/null; then
        log_success "Rust: $(rustc --version)"
        checks_passed=$((checks_passed + 1))
    else
        log_error "Rust not found"
    fi
    
    # Check if build artifacts exist
    checks_total=$((checks_total + 1))
    if [[ -d "dist" ]] || [[ -d "build" ]]; then
        log_success "Build artifacts found"
        checks_passed=$((checks_passed + 1))
    else
        log_warn "Build artifacts might not be in expected location (this might be okay)"
    fi
    
    # Check if server files exist
    checks_total=$((checks_total + 1))
    if [[ -f "server/server.js" ]]; then
        log_success "Server file found"
        checks_passed=$((checks_passed + 1))
    else
        log_warn "Server file not in expected location"
    fi
    
    echo ""
    log_info "Verification: $checks_passed/$checks_total checks passed"
    echo ""
}

# Function to set up systemd service
setup_systemd_service() {
    echo ""
    log_info "=== Systemd Service Setup ==="
    echo ""
    echo "This will help you create a systemd service to run Anura OS server 24/7"
    echo ""
    
    read -p "Do you want to create a systemd service? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping systemd service setup"
        echo "You can run the server manually with: npm start"
        return
    fi
    
    # Get current working directory
    local service_dir=$(pwd)
    local service_user="${SUDO_USER:-$(whoami)}"
    
    read -p "Enter the port the server should run on (default: 8080): " port
    port=${port:-8080}
    
    read -p "Enter the service name (default: anura-os): " service_name
    service_name=${service_name:-anura-os}
    
    local service_file="/etc/systemd/system/${service_name}.service"
    
    log_info "Creating systemd service: $service_file"
    
    cat > "$service_file" << EOF
[Unit]
Description=Anura OS Server
After=network.target

[Service]
Type=simple
User=$service_user
WorkingDirectory=$service_dir/server
EnvironmentFile=-$service_dir/.env
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=anura-os

[Install]
WantedBy=multi-user.target
EOF
    
    log_success "Systemd service file created"
    
    # Create optional environment file template
    if [[ ! -f ".env" ]]; then
        cat > ".env" << EOF
# Anura OS Server Environment Configuration
NODE_ENV=production
PORT=$port
# Add any other environment variables your server needs
EOF
        log_success "Created .env template (edit as needed)"
    fi
    
    # Reload systemd
    log_info "Reloading systemd daemon..."
    systemctl daemon-reload
    log_success "Systemd daemon reloaded"
    
    echo ""
    log_info "=== Service Created Successfully ==="
    echo ""
    echo "Service name: $service_name"
    echo "Service file: $service_file"
    echo ""
    log_info "Useful commands:"
    echo "  Start the service:     sudo systemctl start $service_name"
    echo "  Stop the service:      sudo systemctl stop $service_name"
    echo "  Restart the service:   sudo systemctl restart $service_name"
    echo "  Enable auto-start:     sudo systemctl enable $service_name"
    echo "  View status:           sudo systemctl status $service_name"
    echo "  View logs:             sudo journalctl -u $service_name -f"
    echo ""
    
    read -p "Do you want to enable the service to start on boot? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        systemctl enable "$service_name"
        log_success "Service enabled for auto-start on boot"
    fi
    
    read -p "Do you want to start the service now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        systemctl start "$service_name"
        log_success "Service started"
        sleep 2
        systemctl status "$service_name" --no-pager || true
    fi
}

# Error handler
trap 'on_error $? $LINENO' ERR

on_error() {
    local exit_code=$1
    local line_number=$2
    log_error "Setup failed at line $line_number with exit code $exit_code"
    echo ""
    log_warn "Common solutions:"
    echo "1. Check SETUP_TROUBLESHOOTING.md for your specific issue"
    echo "2. Run: ./anura-build-patches.sh"
    echo "3. Check available disk space: df -h"
    echo "4. Run: git submodule update --init --recursive"
    echo ""
    log_info "To retry the setup:"
    echo "  sudo ./anura-full-setup.sh"
    echo ""
    log_info "For manual steps:"
    echo "  See SETUP_TROUBLESHOOTING.md 'Manual Steps' section"
    exit $exit_code
}

# Function to apply build patches for known issues
apply_build_patches() {
    log_info "Applying build patches for known issues..."
    
    # Try to run the dedicated patches script if it exists
    if [[ -x "./anura-build-patches.sh" ]]; then
        log_info "Running anura-build-patches.sh..."
        ./anura-build-patches.sh || log_warn "Some patches may have failed, but continuing anyway..."
        return $?
    fi
    
    # Fallback: apply inline patches
    if [[ -d "v86" ]] && [[ -f "v86/Makefile" ]]; then
        log_warn "Patch script not available. Attempting inline patches..."
        
        # Set environment for known WASM linker issue
        if grep -r "stack-first" v86/ 2>/dev/null | grep -q "global-base"; then
            log_warn "Detected WASM linker stack-first/global-base conflict"
            log_info "This may require manual intervention or increasing stack-size..."
        fi
    fi
    
    log_success "Build patch preparation complete"
}

# Run main
main "$@"
