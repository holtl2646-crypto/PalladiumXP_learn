# PalladiumXP (PXP) project memory

Last updated: 2026-06-07

## Project context

- Hardware accelerator: PalladiumXP / PXP
- PXP IP: `<pxp-host>`
- Intermediate server / VNC workstation: `<jump-host>`
- Current Windows PC can VNC to `<jump-host>`.
- Current Windows PC cannot SSH to `<jump-host>:22` due to security policy.
- `<jump-host>` can SSH to PXP `<pxp-host>`.
- Practical access path:

```text
Current Windows PC --VNC--> <jump-host> --SSH--> <pxp-host> PXP
```

## Remote editing status

- VS Code is installed on `<jump-host>`.
- VS Code Remote SSH from `<jump-host>` to PXP connects far enough to start setup, but fails because PXP does not meet VS Code Server prerequisites for `glibc` / `libstdc++`.
- Do not upgrade `glibc` on PXP just for VS Code Server.
- Current practical workflow:

```bash
ssh <pxp-user>@<pxp-host>
cd /path/to/pxp/case_directory
emacs -nw .
```

## Case directory

Active PXP case directory:

```text
/path/to/pxp/case_directory
```

Hardware top:

```text
sc_idu_to_fxu
```

Important interface inputs:

```text
i_fxu_idu_opcd
i_fxu_idu_round
i_fxu_idu_conv_fma_vld
i_fxu_idu_opcd_vld
i_fxu_idu_oprd1
i_fxu_idu_oprd2
i_fxu_idu_oprd3
i_fxu_idu_waddr
i_idu_pc
i_reset_n
i_clk
```

Important outputs:

```text
o_fxu_frf_we
o_fxu_frf_waddr
o_fxu_frf_wdata
o_fxu_xrf_we_wb
o_fxu_xrf_waddr_wb
o_fxu_xrf_wdata_wb
o_fxu_csr_fflags_we
o_fxu_csr_fflags
o_fxu_pending
```

## Generated local files

Project-local files under:

```text
C:\Users\lih\Documents\PalladiumXP锛圥XP锛夌‖浠跺姞閫熷櫒
```

Useful files:

```text
PXP_remote_access.md
setup-pxp-jump.ps1
run_sw.sh
run_hw.sh
run_sw_legacy.sh
run_hw_legacy.sh
run_pxp_legacy.sh
run_pxp_stress_matrix.sh
tb_sc_idu_to_fxu_smoke.v
tb_sc_idu_to_fxu_legacy.v
tb_sc_idu_to_fxu.sv
tb_fxu_opcode_map.svh
tb_sc_idu_to_fxu_usage.md
sc_idu_to_fxu_case_plan.md
```

## Script behavior

`run_sw.sh`:

- Defaults to smoke testbench:

```text
TOP=tb_sc_idu_to_fxu_smoke
TB_FILE=tb_sc_idu_to_fxu_smoke.v
LOG_DIR=logs_sw
```

- Uses `irun -elaborate` for compile/elaboration only.
- Uses `irun -R` for the actual run.
- This avoids accidentally running the simulation twice.

`run_hw.sh`:

- Same structure as `run_sw.sh`, but uses `-hw`.

Legacy wrappers:

```bash
RUN_ARGS="+case=directed" ./run_sw_legacy.sh
RUN_ARGS="+case=stress +num_ops=100000 +seed=1" ./run_sw_legacy.sh
RUN_ARGS="+case=directed" ./run_hw_legacy.sh
```

## Verified results

Smoke testbench:

```text
[TB_SMOKE] version 2026-06-03-smoke-v1
[TB_SMOKE][PASS]
```

This confirms:

- `filelist` is usable.
- `springcore_pkg.v` is found.
- `sc_idu_to_fxu` top-level port instantiation works.
- Basic software `irun` compile/elaboration/run flow works.

Legacy directed testbench before NaN-boxing fix:

```text
[TB_LEGACY] version 2026-06-03-legacy-v1
[TB_LEGACY] case=directed
[TB_LEGACY] opcodes fadd=2 fsub=4 fmul=8 feq=40 flt=80 fle=100 round=0
[TB_LEGACY][FRF_WB] waddr=1 wdata=0xffffffff7fc00000 fflags_we=1 fflags=0x0
[TB_LEGACY][FRF_WB] waddr=2 wdata=0xffffffff7fc00000 fflags_we=1 fflags=0x0
[TB_LEGACY][FRF_WB] waddr=3 wdata=0xffffffff7fc00000 fflags_we=1 fflags=0x0
[TB_LEGACY][SUMMARY] issued=3 frf_wb=3 xrf_wb=0 csr_fflags=3 errors=0
[TB_LEGACY][PASS]
```

Interpretation:

- DUT accepts opcodes and produces FRF writeback.
- `0xffffffff7fc00000` is quiet NaN.
- Likely cause: FP32 operands must be NaN-boxed in the 64-bit FP register format.
- Local `tb_sc_idu_to_fxu_legacy.v` was updated to drive FP32 operands as NaN-boxed:

```text
upper 32 bits = 0xffffffff
lower 32 bits = fp32 value
```

Expected directed result after updating PXP with the latest `tb_sc_idu_to_fxu_legacy.v`:

```text
wdata low 32 bits = 0x40400000
```

This is FP32 value `3.0`.

## Opcode mapping currently used

Current legacy testbench defaults:

```verilog
`define TB_OP_FADD_S {20'b1, 1'b0}
`define TB_OP_FSUB_S {20'b10, 1'b0}
`define TB_OP_FMUL_S {20'b100, 1'b0}
`define TB_OP_FEQ_S  {20'b100000, 1'b0}
`define TB_OP_FLT_S  {20'b1000000, 1'b0}
`define TB_OP_FLE_S  {20'b10000000, 1'b0}
`define TB_ROUND_RNE 0
```

Observed print values:

```text
fadd=2 fsub=4 fmul=8 feq=40 flt=80 fle=100 round=0
```

## Cadence / irun notes

Tool version observed:

```text
irun(64): 13.10-s010
```

Old-tool compatibility issues already handled:

- Avoid `string`.
- Avoid `void'(...)`.
- Avoid `$fatal`.
- Avoid SystemVerilog `'0` and `'d4`.
- Avoid complex task/function-heavy testbench for first smoke.
- Use Verilog-2001 style where possible.

Important concepts:

- compile: parse/check source files.
- elaboration: expand hierarchy, parameters, generate blocks, and module instances.
- snapshot: saved elaborated simulation model, for example `worklib.tb_sc_idu_to_fxu_legacy:v`.
- run: load snapshot and advance simulation time.

## Current next steps

1. Copy latest local files to PXP case directory:

```text
run_sw.sh
run_hw.sh
run_sw_legacy.sh
run_hw_legacy.sh
tb_sc_idu_to_fxu_legacy.v
```

2. Re-run directed software test:

```bash
RUN_ARGS="+case=directed" ./run_sw_legacy.sh
```

3. Check whether directed writeback becomes:

```text
0xffffffff40400000
```

or at least:

```text
low 32 bits = 0x40400000
```

4. If directed passes with real numeric results, run stress:

```bash
RUN_ARGS="+case=stress +num_ops=100000 +seed=1" ./run_sw_legacy.sh
RUN_ARGS="+case=stress +num_ops=100000 +seed=1" ./run_hw_legacy.sh
```

5. Compare only `irun -R` runtime:

```bash
grep -E "^(real|user|sys) " logs_sw_legacy/run_sw.log
grep -E "^(real|user|sys) " logs_hw_legacy/run_hw.log
```

Speedup:

```text
SW real / HW real
```

## Runtime measurement notes

- Legacy stress now suppresses per-writeback `FRF_WB` / `XRF_WB` logs by default.
- Directed still prints writebacks for debug and exact result confirmation.
- Use `+verbose_wb` in `RUN_ARGS` if detailed writeback logs are needed during stress.
- This avoids timing results being dominated by `$display`, `tee`, and log-file I/O.

## PXP SA hardware acceleration bring-up, 2026-06-07

Important correction:

- `run_hw_legacy.sh` with plain `irun -R` can compile through IXCOM/UXE, but it does not by itself prove that the DUT is running on PalladiumXP.
- True PXP SA execution requires an explicit hot swap command:

```text
xc on -run -xt0
```

Evidence of true hardware execution:

```text
Starting swap into the emulator.
Finished swap into the emulator.
--- HW execs swapin in ...
--- HW execs ... evals ... in ... sec
```

`test_server` must show a real design on a domain during the run, for example:

```text
Domain 0  Owner lih  PID acc_eth1:<pid>  Design SA:tb_sc_idu_to_
```

If `test_server` only shows `RESERVED*`, the domain is reserved but the design has not been downloaded/running yet.

### Required PXP/UXE environment and files

Observed tool paths:

```text
irun  = /home/cadence/tools/INCISIV131010/tools/bin/64bit/irun
ixcom = /home/cadence/tools/UXE141/tools.lnx86/bin/ixcom
ixcc  = /home/cadence/tools/UXE141/tools.lnx86/bin/ixcc
```

Observed environment:

```bash
AXIS_HOME=/home/cadence/tools/UXE141/tools.lnx86
UXEHOME=/home/cadence/tools/UXE141
IESHOME=/home/cadence/tools/INCISIV131010
```

Useful runtime settings:

```bash
export DBE_HOST=acc
```

The IXCOM hardware database top generated in `dbFiles` is:

```text
xcva_top
```

Important generated files:

```text
.design
dbFiles/xcva_top.proto
dbFiles/xcva_top.et3confg
xc_work/
xc_ncwork/
```

If `.design` is missing, `xeDebug` fails with:

```text
ERROR (legacy-50795): Failed to read file ./.design
```

This can happen after running software scripts because `run_sw.sh` cleans old simulator/PXP outputs. Restore by rerunning the hardware compile/elaborate flow, for example:

```bash
RUN_ARGS="+case=stress +num_ops=1000 +seed=1" ./run_hw_legacy.sh
```

### Correct manual PXP SA run sequence

Reserve a domain:

```bash
echo "0.0" > xcva_top.bp
test_server xcva_top -reserve -timeout 300s
```

The reserve command returns a key, usually `34` in current tests:

```text
Emulator domains reserved with key 34 for 18000 seconds.
Reserved resources (boards/domains) are: 0.0
```

Then run:

```bash
irun -R +case=stress +num_ops=1000000 +seed=1 -xedebug
```

At the `XE>` prompt:

```text
xeset reserveKey 34
run 1ns
xc status
xc on -run -xt0
xc status
host -location
run 20ms
xc status
exit
```

Notes:

- `run 1ns` is a short software pre-run so the testbench initial block starts.
- `xc on -run` alone failed with `Back to SIM: found x values`.
- `xc on -run -xt0` succeeded. A/B tests showed `-xt0` is the key requirement, not `run 200ns`.
- `download` is not a valid manual command in this IXCOM SA mode. Download happens implicitly during `xc on`.
- `host -location` reports `NO_DOWNLOAD` before swap/download, and reports `0.0` after successful hardware setup.

### Common issues found

10M stress timeout:

- `10M` stress initially failed on both SW and PXP with:

```text
[TB_LEGACY][ERROR] timeout
```

- Cause: legacy testbench timeout was `TIMEOUT_CYCLES = 10000000`, while `10M` operations plus reset/flush exceed that limit.
- Local `tb_sc_idu_to_fxu_legacy.v` was updated to:

```verilog
parameter TIMEOUT_CYCLES = 20000000;
```

After copying this file to PXP, rerun hardware compile/elaborate before rerunning `10M`.

Wrong top name for `test_server`:

```bash
test_server tb_sc_idu_to_fxu_legacy -location
```

fails because the hardware database top is `xcva_top`, not the testbench module. Correct command:

```bash
test_server xcva_top -location -sahost acc
```

Reservation cleanup:

```bash
test_server -rmkey 34
```

Do not use:

```bash
test_server xcva_top -rmkey 34
```

that syntax is invalid.

Duplicate `.bp` files:

- Keep `./xcva_top.bp`.
- Remove `dbFiles/xcva_top.bp` to avoid the warning that the current-directory `.bp` overrides the other one.

`xeDebug -key` does not work:

```text
Option -key is not supported yet and successfully ignored.
```

Use:

```text
xeset reserveKey <key>
```

before `xc on -run -xt0`.

### Automation scripts

`run_pxp_legacy.sh`:

- Reserves `xcva_top`.
- Writes `xcva_top.bp`.
- Parses the reserve key.
- Generates an xeDebug command script.
- Runs:

```text
xeset reserveKey <key>
run <PRE_RUN_TIME>
xc on -run -xt0
run <HW_RUN_TIME>
```

Default usage:

```bash
chmod +x run_pxp_legacy.sh
./run_pxp_legacy.sh
```

Useful overrides:

```bash
PRE_RUN_TIME=1ns USE_XT0=1 NUM_OPS=1000000 HW_RUN_TIME=20ms ./run_pxp_legacy.sh
NUM_OPS=10000000 HW_RUN_TIME=200ms ./run_pxp_legacy.sh
```

`run_pxp_stress_matrix.sh`:

- Runs a matrix of PXP hardware tests first.
- Then runs SW tests.
- This order matters because SW scripts clean `.design`; running SW first breaks PXP runs.
- Writes results to:

```text
pxp_stress_results/summary.tsv
```

Default matrix:

```text
1M:1000000:20ms 5M:5000000:100ms 10M:10000000:200ms
```

Recommended first run:

```bash
MATRIX="1M:1000000:20ms 5M:5000000:100ms" ./run_pxp_stress_matrix.sh
```

### Performance results

Validated stress matrix:

```text
label  num_ops   sw_real_s  pxp_real_s  hw_exec_s  end_to_end_speedup  sw_to_hw_exec_ratio  status
1M     1000000   281.85     133.67      38.17      2.109               7.384                PASS
5M     5000000   922.95     282.66      187.13     3.265               4.932                PASS
10M    10000000  1727.26    472.05      376.62     3.659               4.586                PASS
```

Definitions:

- `sw_real_s`: pure software `irun/ncsim` wall-clock runtime.
- `pxp_real_s`: end-to-end PXP runtime, including reserve, xeDebug startup, host connection, swap-in, hardware execution, and exit/cleanup.
- `hw_exec_s`: the hardware execution portion reported by `--- HW execs ... in ... sec`.
- `end_to_end_speedup = sw_real_s / pxp_real_s`; use this as the main report metric.
- `sw_to_hw_exec_ratio = sw_real_s / hw_exec_s`; useful to show hardware execution potential, but not a strict end-to-end comparison.

Current conclusion:

- True PXP hardware acceleration is working.
- `1M` stress gets about `2.11x` end-to-end speedup.
- `5M` stress gets about `3.27x` end-to-end speedup.
- `10M` stress gets about `3.66x` end-to-end speedup.
- Larger workloads better amortize reserve/xeDebug/swap overhead.

### Cycle/s estimates

Assumptions:

```text
CLK_PERIOD_NS = 10
cycles ~= simulation_time_ns / 10
```

For `1M` stress:

```text
simulation_time = 10020195 ns
cycles ~= 1,002,019
SW real = 281.85s
PXP HW exec = 38.17s
```

Estimated rates:

```text
SW ~= 1,002,019 / 281.85 ~= 3.56K cycles/s
PXP HW exec ~= 1,002,019 / 38.17 ~= 26.25K cycles/s
```

For `5M` stress:

```text
cycles ~= 5,002,019
SW real = 922.95s
PXP HW exec = 187.13s
```

Estimated rates:

```text
SW ~= 5.42K cycles/s
PXP HW exec ~= 26.73K cycles/s
```

For `10M` stress:

```text
cycles ~= 10,002,019
SW real = 1727.26s
PXP HW exec = 376.62s
```

Estimated rates:

```text
SW ~= 5.79K cycles/s
PXP HW exec ~= 26.56K cycles/s
```

Interpretation:

- Current pure software simulation is roughly `3.5K-5.8K cycles/s`.
- Current PXP hardware execution segment is roughly `26K-27K cycles/s`.
- PXP execution speed is stable across 1M/5M/10M.
- This is below the compiler-reported emulator maximum speed:

```text
INFO (qt2dadb-1086): Maximum emulator operating speed is 3378 kHz.
```

Reason:

- This is IXCOM SA, not full testbench-on-hardware emulation.
- `sc_idu_to_fxu` is on hardware, but the Verilog testbench remains in software.
- The testbench drives one operation per cycle, causing frequent host/PXP synchronization.
- Example log from `1M`:

```text
--- HW execs 2002000 evals ... 2002000 tbsyncs ...
--- HW execs 52646856 input events
--- HW execs 3568441 output events
```

So the measured PXP rate is dominated by SA boundary synchronization and event traffic, not the PalladiumXP silicon limit.

Visibility/debug impact:

- Runtime speed depends on visibility mode and probes.
- Current runs use DYNP through `xc on -run -xt0`.
- FullVision, more probes, waveform upload, assertion counters, and larger trace visibility can reduce speed and increase capacity/step-count overhead.
- Keep visibility minimal for performance runs.
