`timescale 1ns/1ps
`include "springcore_pkg.v"

// Default opcode placeholders. Override them with plusargs such as:
//   +tb_op_fadd_s=01 +tb_op_fsub_s=02 +tb_op_fmul_s=03
`ifndef TB_OP_FADD_S
`define TB_OP_FADD_S 0
`endif
`ifndef TB_OP_FSUB_S
`define TB_OP_FSUB_S 0
`endif
`ifndef TB_OP_FMUL_S
`define TB_OP_FMUL_S 0
`endif
`ifndef TB_OP_FEQ_S
`define TB_OP_FEQ_S 0
`endif
`ifndef TB_OP_FLT_S
`define TB_OP_FLT_S 0
`endif
`ifndef TB_OP_FLE_S
`define TB_OP_FLE_S 0
`endif
`ifndef TB_ROUND_RNE
`define TB_ROUND_RNE 0
`endif

module tb_sc_idu_to_fxu;

  initial begin
    $display("[TB] tb_sc_idu_to_fxu version 2026-06-03-legacy-compat-2");
  end

  localparam CLK_PERIOD_NS = 10;
  localparam DEFAULT_TIMEOUT_CYCLES = 1000000;

  reg i_clk;
  reg i_reset_n;

  reg [`FXU_OPCD_WIDTH-1:0] i_fxu_idu_opcd;
  reg [`FXU_ROUND_WIDTH-1:0] i_fxu_idu_round;
  reg [`FXU_SUBMODULE_VLD_WIDTH-1:0] i_fxu_idu_conv_fma_vld;
  reg i_fxu_idu_opcd_vld;
  reg [`FXU_DATA_WIDTH-1:0] i_fxu_idu_oprd1;
  reg [`FXU_DATA_WIDTH-1:0] i_fxu_idu_oprd2;
  reg [`FXU_DATA_WIDTH-1:0] i_fxu_idu_oprd3;
  reg [`FXU_WADDR_WIDTH-1:0] i_fxu_idu_waddr;

`ifdef PIPE_INFO_FOR_TEST
  reg [`FXU_PC_WIDTH-1:0] i_idu_pc;
  wire [`FXU_PC_WIDTH-1:0] o_fxu_xrf_pc;
  wire [`FXU_PC_WIDTH-1:0] o_fxu_frf_pc;
`endif

`ifdef TMU32
  reg [`FXU_UIMM1_EN_WIDTH-1:0] i_fxu_idu_uimm1_en;
  wire o_fxu_frf_pair_we;
  wire [`FXU_DATA_WIDTH-1:0] o_fxu_frf_pair_wdata;
`endif

`ifdef RV32D
  wire o_fxu_xrf_pair_we_wb;
  wire [`XRF_DATA_WIDTH-1:0] o_fxu_xrf_pair_wdata_wb;
`endif

  wire [`FXU_CSR_FFLAGS_WIDTH-1:0] o_fxu_csr_fflags;
  wire o_fxu_csr_fflags_we;
  wire [`XRF_WADDR_WIDTH-1:0] o_fxu_xrf_waddr_wb;
  wire o_fxu_xrf_we_wb;
  wire [`XRF_DATA_WIDTH-1:0] o_fxu_xrf_wdata_wb;
  wire [`FXU_WADDR_WIDTH-1:0] o_fxu_frf_waddr;
  wire o_fxu_frf_we;
  wire [`FXU_DATA_WIDTH-1:0] o_fxu_frf_wdata;
  wire o_fxu_pending;

  integer error_count;
  integer issued_count;
  integer frf_wb_count;
  integer xrf_wb_count;
  integer csr_fflags_count;
  integer timeout_cycles;
  integer num_ops;
  integer seed;
  integer plusarg_found;
  reg [8*32-1:0] case_name;

  reg [`FXU_OPCD_WIDTH-1:0] op_fadd_s;
  reg [`FXU_OPCD_WIDTH-1:0] op_fsub_s;
  reg [`FXU_OPCD_WIDTH-1:0] op_fmul_s;
  reg [`FXU_OPCD_WIDTH-1:0] op_feq_s;
  reg [`FXU_OPCD_WIDTH-1:0] op_flt_s;
  reg [`FXU_OPCD_WIDTH-1:0] op_fle_s;
  reg [`FXU_ROUND_WIDTH-1:0] round_rne;

  always #(CLK_PERIOD_NS/2) i_clk = ~i_clk;

  sc_idu_to_fxu dut (
      .i_fxu_idu_opcd(i_fxu_idu_opcd),
      .i_fxu_idu_round(i_fxu_idu_round),
      .i_fxu_idu_conv_fma_vld(i_fxu_idu_conv_fma_vld),
      .i_fxu_idu_opcd_vld(i_fxu_idu_opcd_vld),
      .i_fxu_idu_oprd1(i_fxu_idu_oprd1),
      .i_fxu_idu_oprd2(i_fxu_idu_oprd2),
      .i_fxu_idu_oprd3(i_fxu_idu_oprd3),
      .i_fxu_idu_waddr(i_fxu_idu_waddr),
`ifdef PIPE_INFO_FOR_TEST
      .i_idu_pc(i_idu_pc),
`endif
      .o_fxu_csr_fflags(o_fxu_csr_fflags),
      .o_fxu_csr_fflags_we(o_fxu_csr_fflags_we),
      .o_fxu_xrf_waddr_wb(o_fxu_xrf_waddr_wb),
      .o_fxu_xrf_we_wb(o_fxu_xrf_we_wb),
      .o_fxu_xrf_wdata_wb(o_fxu_xrf_wdata_wb),
`ifdef RV32D
      .o_fxu_xrf_pair_we_wb(o_fxu_xrf_pair_we_wb),
      .o_fxu_xrf_pair_wdata_wb(o_fxu_xrf_pair_wdata_wb),
`endif
`ifdef PIPE_INFO_FOR_TEST
      .o_fxu_xrf_pc(o_fxu_xrf_pc),
`endif
      .o_fxu_frf_waddr(o_fxu_frf_waddr),
      .o_fxu_frf_we(o_fxu_frf_we),
      .o_fxu_frf_wdata(o_fxu_frf_wdata),
`ifdef TMU32
      .i_fxu_idu_uimm1_en(i_fxu_idu_uimm1_en),
      .o_fxu_frf_pair_we(o_fxu_frf_pair_we),
      .o_fxu_frf_pair_wdata(o_fxu_frf_pair_wdata),
`endif
`ifdef PIPE_INFO_FOR_TEST
      .o_fxu_frf_pc(o_fxu_frf_pc),
`endif
      .o_fxu_pending(o_fxu_pending),
      .i_reset_n(i_reset_n),
      .i_clk(i_clk)
  );

  initial begin
    i_clk = 1'b0;
  end

  initial begin
    error_count = 0;
    issued_count = 0;
    frf_wb_count = 0;
    xrf_wb_count = 0;
    csr_fflags_count = 0;

    case_name = "smoke";
    timeout_cycles = DEFAULT_TIMEOUT_CYCLES;
    num_ops = 1000;
    seed = 32'h1234_5678;

    op_fadd_s = `TB_OP_FADD_S;
    op_fsub_s = `TB_OP_FSUB_S;
    op_fmul_s = `TB_OP_FMUL_S;
    op_feq_s = `TB_OP_FEQ_S;
    op_flt_s = `TB_OP_FLT_S;
    op_fle_s = `TB_OP_FLE_S;
    round_rne = `TB_ROUND_RNE;

    plusarg_found = $value$plusargs("case=%s", case_name);
    plusarg_found = $value$plusargs("num_ops=%d", num_ops);
    plusarg_found = $value$plusargs("seed=%d", seed);
    plusarg_found = $value$plusargs("timeout_cycles=%d", timeout_cycles);
    plusarg_found = $value$plusargs("tb_op_fadd_s=%h", op_fadd_s);
    plusarg_found = $value$plusargs("tb_op_fsub_s=%h", op_fsub_s);
    plusarg_found = $value$plusargs("tb_op_fmul_s=%h", op_fmul_s);
    plusarg_found = $value$plusargs("tb_op_feq_s=%h", op_feq_s);
    plusarg_found = $value$plusargs("tb_op_flt_s=%h", op_flt_s);
    plusarg_found = $value$plusargs("tb_op_fle_s=%h", op_fle_s);
    plusarg_found = $value$plusargs("tb_round_rne=%h", round_rne);

    $display("[TB] case=%s num_ops=%0d seed=%0d timeout_cycles=%0d", case_name, num_ops, seed, timeout_cycles);
    $display("[TB] opcodes fadd=%0h fsub=%0h fmul=%0h feq=%0h flt=%0h fle=%0h round_rne=%0h",
             op_fadd_s, op_fsub_s, op_fmul_s, op_feq_s, op_flt_s, op_fle_s, round_rne);

    init_inputs();
    reset_dut();

    if (case_name == "smoke") begin
      run_smoke();
    end else if (case_name == "directed") begin
      run_directed();
    end else if (case_name == "compare") begin
      run_compare();
    end else if (case_name == "stress") begin
      run_stress(num_ops);
    end else begin
      $display("[TB][ERROR] Unknown case: %s", case_name);
      error_count = error_count + 1;
    end

    drain_pipeline(2000);
    check_minimum_activity();
    print_summary();

    if (error_count == 0) begin
      $display("[TB][PASS]");
      $finish;
    end else begin
      $display("[TB][FAIL] error_count=%0d", error_count);
      $finish;
    end
  end

  initial begin : watchdog
    #1;
    repeat (timeout_cycles) @(posedge i_clk);
    $display("[TB][ERROR] Global watchdog timeout");
    $finish;
  end

  always @(posedge i_clk) begin
    if (i_reset_n) begin
      if (o_fxu_frf_we) begin
        frf_wb_count <= frf_wb_count + 1;
        $display("[TB][FRF_WB] cycle=%0t waddr=%0d wdata=0x%0h fflags_we=%0b fflags=0x%0h",
                 $time, o_fxu_frf_waddr, o_fxu_frf_wdata, o_fxu_csr_fflags_we, o_fxu_csr_fflags);
      end

      if (o_fxu_xrf_we_wb) begin
        xrf_wb_count <= xrf_wb_count + 1;
        $display("[TB][XRF_WB] cycle=%0t waddr=%0d wdata=0x%0h",
                 $time, o_fxu_xrf_waddr_wb, o_fxu_xrf_wdata_wb);
      end

      if (o_fxu_csr_fflags_we) begin
        csr_fflags_count <= csr_fflags_count + 1;
      end
    end
  end

  task init_inputs;
    begin
      i_reset_n = 1'b0;
      i_fxu_idu_opcd = {`FXU_OPCD_WIDTH{1'b0}};
      i_fxu_idu_round = {`FXU_ROUND_WIDTH{1'b0}};
      i_fxu_idu_conv_fma_vld = {`FXU_SUBMODULE_VLD_WIDTH{1'b0}};
      i_fxu_idu_opcd_vld = 1'b0;
      i_fxu_idu_oprd1 = {`FXU_DATA_WIDTH{1'b0}};
      i_fxu_idu_oprd2 = {`FXU_DATA_WIDTH{1'b0}};
      i_fxu_idu_oprd3 = {`FXU_DATA_WIDTH{1'b0}};
      i_fxu_idu_waddr = {`FXU_WADDR_WIDTH{1'b0}};
`ifdef PIPE_INFO_FOR_TEST
      i_idu_pc = {`FXU_PC_WIDTH{1'b0}};
`endif
`ifdef TMU32
      i_fxu_idu_uimm1_en = {`FXU_UIMM1_EN_WIDTH{1'b0}};
`endif
    end
  endtask

  task reset_dut;
    begin
      repeat (10) @(posedge i_clk);
      i_reset_n <= 1'b1;
      repeat (10) @(posedge i_clk);
    end
  endtask

  task drive_idle;
    input integer cycles;
    integer i;
    begin
      i_fxu_idu_opcd_vld <= 1'b0;
      i_fxu_idu_conv_fma_vld <= {`FXU_SUBMODULE_VLD_WIDTH{1'b0}};
      for (i = 0; i < cycles; i = i + 1) begin
        @(posedge i_clk);
      end
    end
  endtask

  task issue_fma_op;
    input [`FXU_OPCD_WIDTH-1:0] opcd;
    input [`FXU_DATA_WIDTH-1:0] oprd1;
    input [`FXU_DATA_WIDTH-1:0] oprd2;
    input [`FXU_DATA_WIDTH-1:0] oprd3;
    input [`FXU_WADDR_WIDTH-1:0] waddr;
    begin
      @(posedge i_clk);
      i_fxu_idu_opcd <= opcd;
      i_fxu_idu_round <= round_rne;
      i_fxu_idu_conv_fma_vld <= {{(`FXU_SUBMODULE_VLD_WIDTH-1){1'b0}}, 1'b1};
      i_fxu_idu_opcd_vld <= 1'b1;
      i_fxu_idu_oprd1 <= oprd1;
      i_fxu_idu_oprd2 <= oprd2;
      i_fxu_idu_oprd3 <= oprd3;
      i_fxu_idu_waddr <= waddr;
`ifdef PIPE_INFO_FOR_TEST
      i_idu_pc <= i_idu_pc + 4;
`endif
      issued_count = issued_count + 1;
      @(posedge i_clk);
      i_fxu_idu_opcd_vld <= 1'b0;
      i_fxu_idu_conv_fma_vld <= {`FXU_SUBMODULE_VLD_WIDTH{1'b0}};
    end
  endtask

  task issue_conv_op;
    input [`FXU_OPCD_WIDTH-1:0] opcd;
    input [`FXU_DATA_WIDTH-1:0] oprd1;
    input [`FXU_DATA_WIDTH-1:0] oprd2;
    input [`FXU_DATA_WIDTH-1:0] oprd3;
    input [`FXU_WADDR_WIDTH-1:0] waddr;
    begin
      @(posedge i_clk);
      i_fxu_idu_opcd <= opcd;
      i_fxu_idu_round <= round_rne;
      i_fxu_idu_conv_fma_vld <= {{(`FXU_SUBMODULE_VLD_WIDTH-2){1'b0}}, 2'b10};
      i_fxu_idu_opcd_vld <= 1'b1;
      i_fxu_idu_oprd1 <= oprd1;
      i_fxu_idu_oprd2 <= oprd2;
      i_fxu_idu_oprd3 <= oprd3;
      i_fxu_idu_waddr <= waddr;
`ifdef PIPE_INFO_FOR_TEST
      i_idu_pc <= i_idu_pc + 4;
`endif
      issued_count = issued_count + 1;
      @(posedge i_clk);
      i_fxu_idu_opcd_vld <= 1'b0;
      i_fxu_idu_conv_fma_vld <= {`FXU_SUBMODULE_VLD_WIDTH{1'b0}};
    end
  endtask

  task run_smoke;
    begin
      $display("[TB] run_smoke");
      drive_idle(100);
      if (frf_wb_count != 0 || xrf_wb_count != 0 || csr_fflags_count != 0) begin
        $display("[TB][ERROR] Unexpected writeback during idle: frf=%0d xrf=%0d csr=%0d",
                 frf_wb_count, xrf_wb_count, csr_fflags_count);
        error_count = error_count + 1;
      end
    end
  endtask

  task run_directed;
    begin
      $display("[TB] run_directed");
      issue_fma_op(op_fadd_s, fp32(32'h3f800000), fp32(32'h40000000), {`FXU_DATA_WIDTH{1'b0}}, 5'd1);
      drive_idle(20);
      issue_fma_op(op_fsub_s, fp32(32'h40a00000), fp32(32'h40000000), {`FXU_DATA_WIDTH{1'b0}}, 5'd2);
      drive_idle(20);
      issue_fma_op(op_fmul_s, fp32(32'h3fc00000), fp32(32'h40000000), {`FXU_DATA_WIDTH{1'b0}}, 5'd3);
      drive_idle(200);
    end
  endtask

  task run_compare;
    begin
      $display("[TB] run_compare");
      issue_conv_op(op_feq_s, fp32(32'h3f800000), fp32(32'h3f800000), {`FXU_DATA_WIDTH{1'b0}}, 5'd4);
      drive_idle(20);
      issue_conv_op(op_flt_s, fp32(32'h3f800000), fp32(32'h40000000), {`FXU_DATA_WIDTH{1'b0}}, 5'd5);
      drive_idle(20);
      issue_conv_op(op_fle_s, fp32(32'h40000000), fp32(32'h40000000), {`FXU_DATA_WIDTH{1'b0}}, 5'd6);
      drive_idle(200);
    end
  endtask

  task run_stress;
    input integer count;
    integer i;
    reg [31:0] lfsr;
    reg [31:0] lfsr2;
    reg [`FXU_OPCD_WIDTH-1:0] opcd;
    begin
      $display("[TB] run_stress count=%0d seed=%0d", count, seed);
      lfsr = seed[31:0];

      for (i = 0; i < count; i = i + 1) begin
        lfsr = next_lfsr(lfsr);
        case (lfsr[2:0])
          3'd0: opcd = op_fadd_s;
          3'd1: opcd = op_fsub_s;
          3'd2: opcd = op_fmul_s;
          3'd3: opcd = op_feq_s;
          3'd4: opcd = op_flt_s;
          default: opcd = op_fle_s;
        endcase

        lfsr2 = next_lfsr(lfsr);

        if (lfsr[2:0] <= 3'd2) begin
          issue_fma_op(opcd, fp32({1'b0, lfsr[30:0]}), fp32({1'b0, lfsr2[30:0]}), {`FXU_DATA_WIDTH{1'b0}}, i[4:0]);
        end else begin
          issue_conv_op(opcd, fp32({1'b0, lfsr[30:0]}), fp32({1'b0, lfsr2[30:0]}), {`FXU_DATA_WIDTH{1'b0}}, i[4:0]);
        end

        if ((i % 1000) == 0) begin
          $display("[TB] stress progress issued=%0d", i);
        end
      end
    end
  endtask

  task drain_pipeline;
    input integer max_cycles;
    integer i;
    begin
      $display("[TB] drain_pipeline max_cycles=%0d", max_cycles);
      for (i = 0; i < max_cycles; i = i + 1) begin
        @(posedge i_clk);
        if (!o_fxu_pending && i > 20) begin
          i = max_cycles;
        end
      end

      if (o_fxu_pending) begin
        $display("[TB][ERROR] o_fxu_pending still high after drain");
        error_count = error_count + 1;
      end
    end
  endtask

  task check_minimum_activity;
    begin
      if (issued_count > 0 && (frf_wb_count + xrf_wb_count) == 0) begin
        $display("[TB][ERROR] Issued operations but observed no writeback");
        error_count = error_count + 1;
      end
    end
  endtask

  task print_summary;
    begin
      $display("[TB][SUMMARY] issued=%0d frf_wb=%0d xrf_wb=%0d csr_fflags=%0d errors=%0d",
               issued_count, frf_wb_count, xrf_wb_count, csr_fflags_count, error_count);
    end
  endtask

  function [`FXU_DATA_WIDTH-1:0] fp32;
    input [31:0] value;
    begin
      fp32 = {`FXU_DATA_WIDTH{1'b0}};
      fp32[31:0] = value;
    end
  endfunction

  function [31:0] next_lfsr;
    input [31:0] value;
    reg feedback;
    begin
      feedback = value[31] ^ value[21] ^ value[1] ^ value[0];
      next_lfsr = {value[30:0], feedback};
      if (next_lfsr == 32'h0) begin
        next_lfsr = 32'h1;
      end
    end
  endfunction

endmodule
