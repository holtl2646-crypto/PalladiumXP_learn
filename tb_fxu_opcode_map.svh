// Fill these values from springcore_pkg.v or the FXU decode table.
// They can also be overridden at runtime with plusargs, for example:
//   +tb_op_fadd_s=0x01 +tb_op_fsub_s=0x02 +tb_op_fmul_s=0x03

`ifndef TB_OP_FADD_S
`define TB_OP_FADD_S {20'b1, 1'b0}
`endif

`ifndef TB_OP_FSUB_S
`define TB_OP_FSUB_S {20'b10, 1'b0}
`endif

`ifndef TB_OP_FMUL_S
`define TB_OP_FMUL_S {20'b100, 1'b0}
`endif

`ifndef TB_OP_FEQ_S
`define TB_OP_FEQ_S {20'b100000, 1'b0}
`endif

`ifndef TB_OP_FLT_S
`define TB_OP_FLT_S {20'b1000000, 1'b0}
`endif

`ifndef TB_OP_FLE_S
`define TB_OP_FLE_S {20'b10000000, 1'b0}
`endif

`ifndef TB_ROUND_RNE
`define TB_ROUND_RNE '0
`endif