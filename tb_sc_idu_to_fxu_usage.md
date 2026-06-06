# tb_sc_idu_to_fxu usage

Generated files:

```text
tb_sc_idu_to_fxu.sv
tb_fxu_opcode_map.svh
run_sw.sh
run_hw.sh
```

Copy these files into the PXP case directory:

```text
/path/to/pxp/case_directory
```

## 1. Fill opcode mapping

The testbench now contains safe default opcode placeholders, so `+case=smoke` can compile without `tb_fxu_opcode_map.svh`.

For real directed/stress runs, either edit `tb_sc_idu_to_fxu.sv` near the top or use runtime plusargs.

Optional mapping file:

```text
tb_fxu_opcode_map.svh
```

Fill the opcode values from `springcore_pkg.v` or the FXU decode table:

```systemverilog
`define TB_OP_FADD_S <value>
`define TB_OP_FSUB_S <value>
`define TB_OP_FMUL_S <value>
`define TB_OP_FEQ_S  <value>
`define TB_OP_FLT_S  <value>
`define TB_OP_FLE_S  <value>
`define TB_ROUND_RNE <value>
```

If you do not want to edit the file yet, you can pass values at compile time:

```bash
EXTRA_ARGS="+define+TB_OP_FADD_S=... +define+TB_OP_FSUB_S=..." ./run_sw.sh
```

Or pass runtime override plusargs:

```bash
RUN_ARGS="+case=directed +tb_op_fadd_s=... +tb_op_fsub_s=... +tb_op_fmul_s=..." ./run_sw.sh
```

## Known old-irun compatibility fixes

Cadence irun 13.10 may reject some newer SystemVerilog testbench style. This generated testbench avoids:

```text
string variables
void'(...) casts
$fatal outside assertions
mandatory external opcode include files
```

## 2. Run smoke test

Smoke only checks reset/idle behavior and does not need real opcode values:

```bash
chmod +x run_sw.sh run_hw.sh
RUN_ARGS="+case=smoke" ./run_sw.sh
RUN_ARGS="+case=smoke" ./run_hw.sh
```

Expected log:

```text
[TB][PASS]
```

## 3. Run directed FMA test

This needs valid FADD.S, FSUB.S, and FMUL.S opcodes:

```bash
RUN_ARGS="+case=directed" ./run_sw.sh
RUN_ARGS="+case=directed" ./run_hw.sh
```

The testbench issues:

```text
FADD.S: 1.0 + 2.0
FSUB.S: 5.0 - 2.0
FMUL.S: 1.5 * 2.0
```

Current checks:

```text
FRF/XRF writeback activity
pending eventually returns low
summary counters
```

The next improvement is to add exact result checking after opcode mapping is confirmed.

## 4. Run compare test

This needs FEQ.S, FLT.S, and FLE.S opcodes:

```bash
RUN_ARGS="+case=compare" ./run_sw.sh
RUN_ARGS="+case=compare" ./run_hw.sh
```

## 5. Run long stress test

Use this for SW vs HW runtime comparison:

```bash
RUN_ARGS="+case=stress +num_ops=100000 +seed=1 +timeout_cycles=2000000" ./run_sw.sh
RUN_ARGS="+case=stress +num_ops=100000 +seed=1 +timeout_cycles=2000000" ./run_hw.sh
```

For a longer run:

```bash
RUN_ARGS="+case=stress +num_ops=1000000 +seed=1 +timeout_cycles=10000000" ./run_sw.sh
RUN_ARGS="+case=stress +num_ops=1000000 +seed=1 +timeout_cycles=10000000" ./run_hw.sh
```

## 6. Compare runtime

```bash
echo "SW:"
grep -E "^(real|user|sys) " logs_sw/run_sw.log

echo "HW:"
grep -E "^(real|user|sys) " logs_hw/run_hw.log
```

Main metric:

```text
speedup = SW real / HW real
```

## 7. Notes

- VS Code Remote SSH cannot run on PXP if the PXP OS does not satisfy the VS Code Server glibc/libstdc++ requirements.
- Use VNC to `<jump-host>`, SSH to `<pxp-host>`, then edit with `emacs -nw`.
- Do not upgrade glibc on PXP just for VS Code Server.
- The first hardware run includes hardware compile overhead. PXP value is clearer when the same compiled design is reused for longer or repeated runs.
