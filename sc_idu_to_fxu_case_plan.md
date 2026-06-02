# sc_idu_to_fxu testcase plan

Target top:

```text
sc_idu_to_fxu
```

Main stimulus inputs:

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

Main check outputs:

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
o_fxu_frf_pc
o_fxu_xrf_pc
```

The exact opcode values should come from `springcore_pkg.v` and the existing FXU decoder definitions.

## Case 0: smoke reset and idle

Purpose:

- Confirm clock/reset behavior.
- Confirm no unexpected writeback when `i_fxu_idu_opcd_vld=0`.
- Confirm `o_fxu_pending` returns idle after reset.

Stimulus:

```text
reset low for 10 cycles
reset high
drive opcd_vld=0 for 100 cycles
```

Checks:

```text
o_fxu_frf_we == 0
o_fxu_xrf_we_wb == 0
o_fxu_csr_fflags_we == 0
```

This is a short bring-up case.

## Case 1: single FP32 add/sub/mul directed

Purpose:

- Prove the basic FMA datapath can accept one operation and produce one FRF writeback.

Operations:

```text
FADD.S: 1.0 + 2.0 = 3.0
FSUB.S: 5.0 - 2.0 = 3.0
FMUL.S: 1.5 * 2.0 = 3.0
```

Stimulus:

```text
i_fxu_idu_conv_fma_vld[0] = 1
i_fxu_idu_opcd_vld = 1 for one cycle per operation
i_fxu_idu_round = RNE
insert idle cycles between operations
```

Checks:

```text
o_fxu_frf_we eventually pulses
o_fxu_frf_waddr matches issued waddr
o_fxu_frf_wdata matches expected IEEE-754 bits
o_fxu_csr_fflags is zero for exact operations
```

## Case 2: compare/sign/minmax directed

Purpose:

- Exercise conversion/non-FMA side operations that may write XRF or FRF.

Operations:

```text
FEQ.S, FLT.S, FLE.S
FSGNJ.S, FSGNJX.S, FSGNJN.S
FMIN.S, FMAX.S
FMV.X.W, FMV.W.X
```

Stimulus:

```text
i_fxu_idu_conv_fma_vld[1] = 1
issue one operation every N cycles
```

Checks:

```text
compare operations write XRF result 0 or 1
sign/minmax operations write FRF result
fflags behavior is checked for NaN inputs
```

## Case 3: special IEEE-754 values

Purpose:

- Catch corner cases where accelerator/software simulation differences are easiest to see.

Values:

```text
+0.0, -0.0
+inf, -inf
quiet NaN
signaling NaN if supported
normal min/max
subnormal min/max
```

Operations:

```text
FADD.S
FMUL.S
FMIN.S/FMAX.S
FEQ.S/FLT.S/FLE.S
FCLASS.S
```

Checks:

```text
result bit pattern
invalid flag for signaling NaN or invalid comparisons
zero sign rules for min/max and arithmetic
```

## Case 4: rounding and conversion

Purpose:

- Exercise `i_fxu_idu_round` and CSR fflags.

Operations:

```text
FCVT.W.S
FCVT.WU.S
FCVT.S.W
FCVT.S.WU
```

Rounding modes:

```text
RNE
RTZ
RDN
RUP
RMM
```

Inputs:

```text
1.4, 1.5, 1.6
-1.4, -1.5, -1.6
large overflow values
NaN
inf
```

Checks:

```text
XRF or FRF result
inexact/invalid/overflow fflags
```

## Case 5: back-to-back issue and pending behavior

Purpose:

- Build a medium-length test that stresses pipeline scheduling.

Stimulus:

```text
issue one valid operation every cycle for 1000 to 10000 cycles
rotate opcodes among FADD.S, FSUB.S, FMUL.S, FSGNJ.S, FEQ.S, FCVT.*
rotate waddr from 1 to 31
increment i_idu_pc by 4 per issued operation
```

Checks:

```text
each issued operation eventually gets the expected writeback
writeback address matches scoreboard
o_fxu_pending eventually returns low after stimulus stops
no unexpected X/Z in outputs
```

This is the first useful case for measuring `irun -R` acceleration.

## Case 6: long-cycle deterministic stress

Purpose:

- Create a long run where hardware acceleration should matter.

Stimulus:

```text
repeat 100000 to 1000000 operations
use a deterministic LFSR seed for operands and opcode selection
avoid unsupported/random illegal opcodes
```

Recommended operation mix:

```text
40% FADD.S/FSUB.S/FMUL.S
20% compare operations
20% sign/minmax operations
20% conversions
```

Checks:

```text
scoreboard every transaction if software runtime is acceptable
or sample every Kth transaction and always check end-of-test counters
```

Use this case for real SW vs HW `irun -R` timing comparison.

## Case 7: replay multiple tests after one hardware compile

Purpose:

- Show the practical value of PXP: compile once, run many tests.

Flow:

```text
run_hw.sh compiles hardware image
run smoke, directed, corner, and long stress runs with different plusargs/seeds
measure only repeated irun -R runtime
```

Suggested plusargs:

```text
+case=smoke
+case=directed
+case=special
+case=stress
+seed=1
+seed=2
+seed=3
+num_ops=100000
+num_ops=1000000
```

The testbench should select behavior from plusargs, so the same compiled top can be reused.

## Suggested timing commands

Software:

```bash
chmod +x run_sw.sh
./run_sw.sh
```

Hardware:

```bash
chmod +x run_hw.sh
./run_hw.sh
```

Compare run stage:

```bash
echo "SW:"
grep -E "^(real|user|sys) " logs_sw/run_sw.log

echo "HW:"
grep -E "^(real|user|sys) " logs_hw/run_hw.log
```

Approximate speedup:

```text
speedup = SW real / HW real
```
