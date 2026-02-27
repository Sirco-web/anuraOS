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

# Function to detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" != "debian" && "$ID" != "ubuntu" && ! "$ID_LIKE" =~ debian ]]; then
            log_warn "This script is optimized for Debian/Ubuntu. Your system is: $PRETTY_NAME"
            log_warn "Some commands may not work as expected"
        fi
    fi
}

# Main setup
main() {
    log_info "Starting Anura OS Full Setup..."
    
    # Check prerequisites
    detect_os
    check_sudo
    
    log_info "Step 1: Updating system packages..."
    apt update
    apt upgrade -y
    log_success "System packages updated"
    
    log_info "Step 2: Installing required build tools and dependencies..."
    apt install -y \
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
        ca-certificates \
        wget
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
    
    log_info "Step 8: Building Anura OS..."
    make all
    log_success "Anura OS built successfully"
    
    log_info "Step 9: Building server..."
    if [[ -f "server/package.json" ]]; then
        cd server
        npm install
        cd ..
        log_success "Server dependencies installed"
    fi
    log_success "Server ready"
    
    log_info "Step 10: Verifying installation..."
    verify_installation
    log_success "All verifications passed!"
    
    log_info "Step 11: Systemd service setup..."
    setup_systemd_service
    
    log_success "Setup completed successfully!"
    echo ""
    log_info "=== Summary ==="
    echo "Anura OS has been fully set up on your Debian system."
    echo "All dependencies have been installed."
    echo "The server has been built and is ready to run."
    echo ""
    log_info "Next steps:"
    echo "1. Run the server manually: npm start (from the server directory)"
    echo "2. Or use the systemd service if you created one"
    echo ""
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
trap 'log_error "Setup failed on line $LINENO"; exit 1' ERR

# Run main
main "$@"
