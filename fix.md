warning: unnecessary `unsafe` block
   --> src/rust/softfloat.rs:115:47
    |
115 |     fn of_f64x(src: f64) -> F80 { F80::of_f64(unsafe { f64::to_bits(src) }) }
    |                                               ^^^^^^ unnecessary `unsafe` block
    |
    = note: `#[warn(unused_unsafe)]` (part of `#[warn(unused)]`) on by default

For more information about this error, try `rustc --explain E0308`.
warning: `v86` (lib) generated 2 warnings
error: could not compile `v86` (lib) due to 27 previous errors; 2 warnings emitted
make[1]: *** [Makefile:211: build/v86.wasm] Error 101
make[1]: Leaving directory '/root/anuraOS/v86'
make: *** [Makefile:153: build/lib/v86.wasm] Error 2
⚠ Initial build failed. Attempting with build patches...
ℹ Running anura-build-patches.sh...
ℹ Anura OS Build Patches

ℹ Preparing transmute patches for instructions_0f.rs...
✓ Added transmute warning suppression to instructions_0f.rs
ℹ Patching softfloat.rs transmute issues...
ℹ Checking WASM linker configuration...
✓ All patches prepared successfully!

ℹ Note: Transmute warnings are suppressed but safe. The build should now proceed.
ℹ You can now run: make all
ℹ Retrying build with patches applied...
git submodule update
cd v86; make build/libv86.js
make[1]: Entering directory '/root/anuraOS/v86'
make[1]: 'build/libv86.js' is up to date.
make[1]: Leaving directory '/root/anuraOS/v86'
cp v86/build/libv86.js build/lib/libv86.js
cd v86; make build/v86.wasm
make[1]: Entering directory '/root/anuraOS/v86'
mkdir -p build/
BLOCK_SIZE=K ls -l build/v86.wasm
ls: cannot access 'build/v86.wasm': No such file or directory
make[1]: [Makefile:210: build/v86.wasm] Error 2 (ignored)
cargo rustc --release --target wasm32-unknown-unknown -- -C linker=tools/rust-lld-wrapper -C link-args="--import-table --global-base=4096 " -C link-args="build/softfloat.o" -C link-args="build/zstddeclib.o" --verbose -C target-feature=+bulk-memory -C target-feature=+multivalue -C target-feature=+simd128
   Compiling v86 v0.1.0 (/root/anuraOS/v86)
error: an inner attribute is not permitted in this context
  --> src/rust/cpu/instructions_0f.rs:16:1
   |
16 | #![allow(unsafe_code)]
   | ^^^^^^^^^^^^^^^^^^^^^^
...
20 | use crate::config;
   | ------------------ the inner attribute doesn't annotate this `use` import
   |
   = note: inner attributes, like `#![no_std]`, annotate the item enclosing them, and are usually found at the beginning of source files
help: to annotate the `use` import, change the attribute from inner to outer style
   |
16 - #![allow(unsafe_code)]
16 + #[allow(unsafe_code)]
   |

error: an inner attribute is not permitted in this context
  --> src/rust/cpu/instructions_0f.rs:18:1
   |
18 | #![allow(unsafe_code)]
   | ^^^^^^^^^^^^^^^^^^^^^^
19 |
20 | use crate::config;
   | ------------------ the inner attribute doesn't annotate this `use` import
   |
   = note: inner attributes, like `#![no_std]`, annotate the item enclosing them, and are usually found at the beginning of source files
help: to annotate the `use` import, change the attribute from inner to outer style
   |
18 - #![allow(unsafe_code)]
18 + #[allow(unsafe_code)]
   |

warning: unnecessary parentheses around closure body
   --> src/rust/jit.rs:711:43
    |
711 |             .filter(|(_, previous_block)| (!previous_block.has_sti))
    |                                           ^                       ^
    |
    = note: `#[warn(unused_parens)]` (part of `#[warn(unused)]`) on by default
help: remove these parentheses
    |
711 -             .filter(|(_, previous_block)| (!previous_block.has_sti))
711 +             .filter(|(_, previous_block)| !previous_block.has_sti )
    |

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:1041:43
     |
1041 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i32; 2]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i32; 2]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:1057:43
     |
1057 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i32; 2]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i32; 2]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:2236:43
     |
2236 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:2362:43
     |
2362 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:2393:43
     |
2393 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected an array with a size of 8, found one with a size of 2
     |                        |
     |                        arguments to this function are incorrect
     |
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:2489:43
     |
2489 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:2550:43
     |
2550 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:2670:43
     |
2670 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:2912:43
     |
2912 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:2944:43
     |
2944 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected an array with a size of 8, found one with a size of 2
     |                        |
     |                        arguments to this function are incorrect
     |
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4080:43
     |
4080 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4198:43
     |
4198 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4311:43
     |
4311 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4463:43
     |
4463 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4493:43
     |
4493 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4524:43
     |
4524 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4627:43
     |
4625 |         result[i] = saturate_sd_to_sb(destination[i] as u32 - source[i] as u...
     |         ------ here the type of `result` is inferred to be `[i8; 8]`
4626 |     }
4627 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i8; 8]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i8; 8]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4658:43
     |
4658 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4689:43
     |
4689 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4741:43
     |
4739 |         result[i] = saturate_sd_to_sb(destination[i] as u32 + source[i] as u...
     |         ------ here the type of `result` is inferred to be `[i8; 8]`
4740 |     }
4741 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i8; 8]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i8; 8]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4772:43
     |
4772 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:4803:43
     |
4803 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5092:43
     |
5092 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5123:43
     |
5123 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i32; 2]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i32; 2]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5210:43
     |
5210 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5241:43
     |
5241 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i32; 2]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i32; 2]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

warning: unnecessary `unsafe` block
   --> src/rust/softfloat.rs:115:47
    |
115 |     fn of_f64x(src: f64) -> F80 { F80::of_f64(unsafe { f64::to_bits(src) }) }
    |                                               ^^^^^^ unnecessary `unsafe` block
    |
    = note: `#[warn(unused_unsafe)]` (part of `#[warn(unused)]`) on by default

For more information about this error, try `rustc --explain E0308`.
warning: `v86` (lib) generated 2 warnings
error: could not compile `v86` (lib) due to 28 previous errors; 2 warnings emitted
make[1]: *** [Makefile:211: build/v86.wasm] Error 101
make[1]: Leaving directory '/root/anuraOS/v86'
make: *** [Makefile:153: build/lib/v86.wasm] Error 2
✗ Build failed even with patches. Check the error messages above.
ℹ Full build log: setup-build.log
ℹ Error summary: setup-errors.txt
ℹ You can try manually running: ./anura-build-patches.sh && make all
root@vm9941:~/anuraOS# cat setup-errors.txt
tail -50 setup-build.log

========== INITIAL BUILD FAILURE ==========
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5090:43
     |
5090 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5121:43
     |
5121 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i32; 2]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i32; 2]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5208:43
     |
5208 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5239:43
     |
5239 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i32; 2]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i32; 2]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

warning: unnecessary `unsafe` block
   --> src/rust/softfloat.rs:115:47
    |
115 |     fn of_f64x(src: f64) -> F80 { F80::of_f64(unsafe { f64::to_bits(src) }) }
    |                                               ^^^^^^ unnecessary `unsafe` block
    |
    = note: `#[warn(unused_unsafe)]` (part of `#[warn(unused)]`) on by default

For more information about this error, try `rustc --explain E0308`.
warning: `v86` (lib) generated 2 warnings
error: could not compile `v86` (lib) due to 27 previous errors; 2 warnings emitted
make[1]: *** [Makefile:211: build/v86.wasm] Error 101
make[1]: Leaving directory '/root/anuraOS/v86'
make: *** [Makefile:153: build/lib/v86.wasm] Error 2

========== RETRY BUILD FAILURE ==========
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5092:43
     |
5092 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5123:43
     |
5123 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i32; 2]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i32; 2]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5210:43
     |
5210 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5241:43
     |
5241 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i32; 2]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i32; 2]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

warning: unnecessary `unsafe` block
   --> src/rust/softfloat.rs:115:47
    |
115 |     fn of_f64x(src: f64) -> F80 { F80::of_f64(unsafe { f64::to_bits(src) }) }
    |                                               ^^^^^^ unnecessary `unsafe` block
    |
    = note: `#[warn(unused_unsafe)]` (part of `#[warn(unused)]`) on by default

For more information about this error, try `rustc --explain E0308`.
warning: `v86` (lib) generated 2 warnings
error: could not compile `v86` (lib) due to 28 previous errors; 2 warnings emitted
make[1]: *** [Makefile:211: build/v86.wasm] Error 101
make[1]: Leaving directory '/root/anuraOS/v86'
make: *** [Makefile:153: build/lib/v86.wasm] Error 2
error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5210:43
     |
5210 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[u16; 4]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[u16; 4]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:5241:43
     |
5241 |     write_mmx_reg64(r, u64::from_ne_bytes(result));
     |                        ------------------ ^^^^^^ expected `[u8; 8]`, found `[i32; 2]`
     |                        |
     |                        arguments to this function are incorrect
     |
     = note: expected array `[u8; 8]`
                found array `[i32; 2]`
note: associated function defined here
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/uint_macros.rs:4028:21
    --> /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1274:4
    ::: /rustc/1ed488274bec5bf5cfe6bf7a1cc089abcc4ebd68/library/core/src/num/mod.rs:1298:5
     |
     = note: in this macro invocation
     = note: this error originates in the macro `uint_impl` (in Nightly builds, run with -Z macro-backtrace for more info)

warning: unnecessary `unsafe` block
   --> src/rust/softfloat.rs:115:47
    |
115 |     fn of_f64x(src: f64) -> F80 { F80::of_f64(unsafe { f64::to_bits(src) }) }
    |                                               ^^^^^^ unnecessary `unsafe` block
    |
    = note: `#[warn(unused_unsafe)]` (part of `#[warn(unused)]`) on by default

For more information about this error, try `rustc --explain E0308`.
warning: `v86` (lib) generated 2 warnings
error: could not compile `v86` (lib) due to 28 previous errors; 2 warnings emitted
make[1]: *** [Makefile:211: build/v86.wasm] Error 101
make[1]: Leaving directory '/root/anuraOS/v86'
make: *** [Makefile:153: build/lib/v86.wasm] Error 2