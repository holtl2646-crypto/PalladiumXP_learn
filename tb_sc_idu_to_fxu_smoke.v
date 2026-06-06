`timescale 1ns/1ps
`include "springcore_pkg.v"

module tb_sc_idu_to_fxu_smoke;

  parameter CLK_PERIOD_NS = 10;
  parameter TIMEOUT_CYCLES = 100000;

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

  integer cycle_count;
  integer error_count;

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
    $display("[TB_SMOKE] version 2026-06-03-smoke-v1");
    i_clk = 1'b0;
    forever #(CLK_PERIOD_NS/2) i_clk = ~i_clk;
  end

  initial begin
    error_count = 0;
    cycle_count = 0;

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

    repeat (10) @(posedge i_clk);
    i_reset_n = 1'b1;
    repeat (100) @(posedge i_clk);

    if (o_fxu_frf_we !== 1'b0) begin
      $display("[TB_SMOKE][ERROR] unexpected FRF writeback during idle");
      error_count = error_count + 1;
    end

    if (o_fxu_xrf_we_wb !== 1'b0) begin
      $display("[TB_SMOKE][ERROR] unexpected XRF writeback during idle");
      error_count = error_count + 1;
    end

    if (o_fxu_csr_fflags_we !== 1'b0) begin
      $display("[TB_SMOKE][ERROR] unexpected CSR fflags write during idle");
      error_count = error_count + 1;
    end

    if (error_count == 0) begin
      $display("[TB_SMOKE][PASS]");
    end else begin
      $display("[TB_SMOKE][FAIL] error_count=%0d", error_count);
    end
    $finish;
  end

  always @(posedge i_clk) begin
    cycle_count = cycle_count + 1;
    if (cycle_count > TIMEOUT_CYCLES) begin
      $display("[TB_SMOKE][ERROR] timeout");
      $finish;
    end
  end

endmodule
