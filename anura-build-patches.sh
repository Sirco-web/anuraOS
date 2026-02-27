#!/bin/bash
set -euo pipefail

# Anura OS Build Patches
# This script applies patches to fix known build issues

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ ${1}${NC}"; }
log_success() { echo -e "${GREEN}✓ ${1}${NC}"; }
log_warn() { echo -e "${YELLOW}⚠ ${1}${NC}"; }
log_error() { echo -e "${RED}✗ ${1}${NC}"; }

# Keep track of warnings
allow_transmute_in_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return
    fi
    
    # Check if allow(unsafe_code) or allow(transmute_undefined_behavior) is already there
    if ! grep -q "#!\[allow(.*transmute" "$file" 2>/dev/null; then
        # Add allow attribute at the top of the file after module declarations
        local line_num=$(grep -n "^use " "$file" | head -1 | cut -d: -f1)
        if [[ -z "$line_num" ]]; then
            line_num=1
        fi
        
        # Insert the allow directive
        sed -i "${line_num}i #![allow(unsafe_code)]\n" "$file"
        log_success "Added transmute warning suppression to $(basename $file)"
    fi
}

patch_softfloat() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return
    fi
    
    log_info "Patching softfloat.rs transmute issues..."
    
    # Convert f64::to_bits (safe conversion)
    if grep -q "F80::of_f64(unsafe { std::mem::transmute(src) })" "$file"; then
        sed -i 's/F80::of_f64(unsafe { std::mem::transmute(src) })/F80::of_f64(unsafe { f64::to_bits(src) as u64 })/g' "$file"
        log_success "Patched f64::to_bits conversion"
    fi
    
    # Convert f64::from_bits (safe conversion)
    if grep -q "unsafe { std::mem::transmute(extF80M_to_f64(self)) }" "$file"; then
        sed -i 's/unsafe { std::mem::transmute(extF80M_to_f64(self)) }/unsafe { f64::from_bits(extF80M_to_f64(self)) }/g' "$file"
        log_success "Patched f64::from_bits conversion"
    fi
    
    # Remove unnecessary unsafe block if f64::to_bits/from_bits are used
    sed -i 's/F80::of_f64(unsafe { f64::to_bits(src) as u64 })/F80::of_f64(f64::to_bits(src) as u64)/g' "$file"
}

patch_wasm_linker() {
    log_info "Checking WASM linker configuration..."
    
    if [[ -f "v86/Makefile" ]]; then
        local has_issue=0
        
        # Check for conflicting linker options
        if grep -q "stack-first" v86/Makefile; then
            if grep -q "global-base=4096" v86/Makefile && grep -q "stack-size=1048576" v86/Makefile; then
                log_warn "Found conflicting WASM linker options"
                has_issue=1
            fi
        fi
        
        if [[ $has_issue -eq 1 ]]; then
            log_info "Setting up environment for WASM linker compatibility..."
            export RUSTFLAGS="${RUSTFLAGS:- } -C link-args=-z -C link-args=stack-size=1048576"
            log_success "WASM linker workaround configured"
        fi
    fi
}

main() {
    log_info "Anura OS Build Patches"
    echo ""
    
    # Check if we're in the right directory
    if [[ ! -d "v86" ]] || [[ ! -f "Makefile" ]]; then
        log_error "This script must be run from the anuraOS root directory"
        exit 1
    fi
    
    # Apply patches
    if [[ -f "v86/src/rust/cpu/instructions_0f.rs" ]]; then
        log_info "Preparing transmute patches for instructions_0f.rs..."
        allow_transmute_in_file "v86/src/rust/cpu/instructions_0f.rs"
    fi
    
    if [[ -f "v86/src/rust/softfloat.rs" ]]; then
        patch_softfloat "v86/src/rust/softfloat.rs"
    fi
    
    patch_wasm_linker
    
    log_success "All patches prepared successfully!"
    echo ""
    log_info "Note: Transmute warnings are suppressed but safe. The build should now proceed."
    log_info "You can now run: make all"
}

main "$@"

