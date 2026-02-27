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

patch_transmute_warnings() {
    local file="$1"
    local count=0
    
    if [[ ! -f "$file" ]]; then
        return
    fi
    
    log_info "Patching transmute warnings in $(basename $file)..."
    
    # Patch u64::from_ne_bytes
    if grep -q "std::mem::transmute(result)" "$file"; then
        sed -i 's/write_mmx_reg64(r, std::mem::transmute(result));/write_mmx_reg64(r, u64::from_ne_bytes(result));/g' "$file"
        ((count++)) || true
    fi
    
    # Patch u64::to_ne_bytes for destination
    if grep -q 'let destination: \[u8; 8\] = std::mem::transmute(read_mmx64s' "$file"; then
        sed -i 's/let destination: \[u8; 8\] = std::mem::transmute(read_mmx64s(r));/let destination: [u8; 8] = u64::to_ne_bytes(read_mmx64s(r));/g' "$file"
        ((count++)) || true
    fi
    
    # Patch u64::to_ne_bytes for source
    if grep -q 'let source: \[u8; 8\] = std::mem::transmute(source);' "$file"; then
        sed -i 's/let source: \[u8; 8\] = std::mem::transmute(source);/let source: [u8; 8] = u64::to_ne_bytes(source);/g' "$file"
        ((count++)) || true
    fi
    
    # Patch read_mmx64s source
    if grep -q 'let source: \[u8; 8\] = std::mem::transmute(read_mmx64s' "$file"; then
        sed -i 's/let source: \[u8; 8\] = std::mem::transmute(read_mmx64s(r2));/let source: [u8; 8] = u64::to_ne_bytes(read_mmx64s(r2));/g' "$file"
        ((count++)) || true
    fi
    
    # Patch f32::from_bits
    if grep -q 'let source: f32 = std::mem::transmute(source);' "$file"; then
        sed -i 's/let source: f32 = std::mem::transmute(source);/let source: f32 = f32::from_bits(source as u32);/g' "$file"
        ((count++)) || true
    fi
    
    if [[ $count -gt 0 ]]; then
        log_success "Patched transmute warnings in $(basename $file)"
    fi
}

patch_softfloat() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return
    fi
    
    log_info "Patching softfloat.rs transmute issues..."
    
    # Patch f64::to_bits
    if grep -q "F80::of_f64(unsafe { std::mem::transmute(src) })" "$file"; then
        sed -i 's/F80::of_f64(unsafe { std::mem::transmute(src) })/F80::of_f64(unsafe { f64::to_bits(src) })/g' "$file"
        log_success "Patched f64::to_bits conversion"
    fi
    
    # Patch f64::from_bits
    if grep -q "unsafe { std::mem::transmute(extF80M_to_f64(self)) }" "$file"; then
        sed -i 's/unsafe { std::mem::transmute(extF80M_to_f64(self)) }/unsafe { f64::from_bits(extF80M_to_f64(self)) }/g' "$file"
        log_success "Patched f64::from_bits conversion"
    fi
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
        patch_transmute_warnings "v86/src/rust/cpu/instructions_0f.rs"
    fi
    
    if [[ -f "v86/src/rust/softfloat.rs" ]]; then
        patch_softfloat "v86/src/rust/softfloat.rs"
    fi
    
    patch_wasm_linker
    
    log_success "All patches applied successfully!"
    echo ""
    log_info "You can now run: make all"
}

main "$@"
