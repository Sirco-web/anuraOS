# Understanding Setup Error Logs

When you run `sudo ./anura-full-setup.sh`, the script creates two important log files for debugging:

## Log Files Created

### 1. `setup-build.log` - Full Build Output
Contains everything printed during the build process:
- All compiler messages (warnings and errors)
- Build progress information
- Package manager output
- Dependency installation logs

### 2. `setup-errors.txt` - Error Summary
Contains a curated summary of errors organized by phase:
- Initial build failures
- Patch script failures  
- Retry build failures
- Any other critical errors

Each error block includes context and what was attempted.

## Quick Reference Commands

### View All Errors (Quick Summary)
```bash
cat setup-errors.txt
```

### View All Build Output
```bash
cat setup-build.log
```

### Search for Specific Errors
```bash
# Find all error messages
grep "^error\[" setup-build.log

# Count errors by type
grep "^error\[" setup-build.log | cut -d: -f1 | sort | uniq -c

# See warnings 
grep "^warning:" setup-build.log

# Find a specific error code (e.g., E0308)
grep "error\[E0308\]" setup-build.log
```

### Monitor Live Build
```bash
# View build log as it's being written
tail -f setup-build.log

# Follow with search for errors
tail -f setup-build.log | grep error
```

### Get Context Around Errors
```bash
# Show error with 5 lines before and after
grep -A 5 -B 5 "error\[E0308\]" setup-build.log

# Show first error with full context
grep -A 20 "^error\[" setup-build.log | head -30
```

## Common Error Patterns

### Transmute Type Mismatch
```
error[E0308]: mismatched types
    --> src/rust/cpu/instructions_0f.rs:XXXX:XX
     |
     expected `[u8; 8]`, found `[u16; 4]`
```
**Fix:** Run `./anura-build-patches.sh` again

### Link Error (WASM)
```
rust-lld: error: --global-base cannot be less than stack size
```
**Fix:** Patches script should handle this automatically

### Missing Dependencies
```
error: failed to build
  Compiling v86
  src/rust/... uses an undeclared crate
```
**Fix:** Run `git submodule update --init --recursive`

### Out of Disk Space
```
Insufficient space
write error
```
**Fix:** Run `df -h` to check, may need to clean cache: `cargo clean`

## Analyzing Error Logs for GitHub Issues

If you need to report a bug, include:

1. **The specific error:**
   ```bash
   grep -A 10 "^error\[" setup-build.log | head -20
   ```

2. **Your system info:**
   ```bash
   cat /etc/os-release
   rustc --version
   node --version
   ```

3. **Available resources:**
   ```bash
   df -h
   free -h
   ```

4. **Full error log:**
   ```bash
   # Create a clean copy for sharing
   tail -200 setup-build.log > error_context.txt
   tail -50 setup-errors.txt >> error_context.txt
   ```

## Troubleshooting Workflow

1. **Check if build passed:**
   ```bash
   grep -c "^error\[" setup-build.log
   # If 0, build succeeded (check systemd service section output)
   # If > 0, build failed
   ```

2. **Get error summary:**
   ```bash
   cat setup-errors.txt | head -50
   ```

3. **Identify error type:**
   ```bash
   # Most common error by line
   head -1 setup-errors.txt | grep -o "error\[[^]]*\]" | sort | uniq -c | sort -rn
   ```

4. **Find solutions:**
   - Search SETUP_TROUBLESHOOTING.md for your error
   - Check setup-build.log for the full context
   - See what patches were applied: `grep "Patching\|Patch" setup-errors.txt`

5. **Retry with increased diagnostics:**
   ```bash
   cargo clean
   ./anura-build-patches.sh
   RUST_BACKTRACE=1 make all 2>&1 | tee setup-build.log
   ```

## Saving Logs for Later Reference

```bash
# Create timestamped backup
mkdir -p logs.backup
cp setup-build.log logs.backup/build.$(date +%Y%m%d-%H%M%S).log
cp setup-errors.txt logs.backup/errors.$(date +%Y%m%d-%H%M%S).txt

# Create summary report
{
    echo "=== Build Log Summary ==="
    echo "Time: $(date)"
    echo "Errors: $(grep -c'^error\[' setup-build.log)"
    echo "Warnings: $(grep -c '^warning:' setup-build.log)"
    echo ""
    echo "=== First 5 Errors ==="
    grep "^error\[" setup-build.log | head -5
    echo ""
    echo "See setup-build.log for full output"
} | tee build-report.txt
```

## Log Location Reference

| File | Purpose | Size | Updates |
|------|---------|------|---------|
| `setup-build.log` | Full compiler output | Large | During build |
| `setup-errors.txt` | Error summary | Small | On errors |
| `setup.log` | (Manual) Build log if `make all 2>&1 \| tee setup.log` | Varies | During build |

## When to Check Logs

- ✅ Build fails and you want to see why
- ✅ Build succeeds but server doesn't start
- ✅ Reporting a bug on GitHub
- ✅ Understanding which patches were applied
- ✅ Verifying build completed successfully

## Privacy Note

These log files may contain:
- System paths
- Compiler version information
- Build flag details
- (Rarely) API keys if in environment

Remove sensitive info before sharing: `head -50 setup-build.log | less` to review first.

---

**Pro Tip:** Keep error logs for at least one successful build so you can compare when troubleshooting future builds!
