# PalladiumXP (PXP) project memory

Last updated: 2026-06-03

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
