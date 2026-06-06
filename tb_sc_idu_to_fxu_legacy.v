`timescale 1ns/1ps
`include "springcore_pkg.v"

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
`define TB_ROUND_RNE 0
`endif

module tb_sc_idu_to_fxu_legacy;

  parameter CLK_PERIOD_NS = 10;
  parameter TIMEOUT_CYCLES = 10000000;

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
  integer issued_count;
  integer frf_wb_count;
  integer xrf_wb_count;
  integer csr_fflags_count;
  integer num_ops;
  integer seed;
  integer plusarg_found;
  integer dump_vcd;
  integer verbose_issue;
  integer stress_progress_interval;
  reg [8*32-1:0] case_name;
  reg [31:0] lfsr;
  reg [31:0] lfsr2;
  integer i;
  reg [`FXU_OPCD_WIDTH-1:0] selected_opcd;

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
    $display("[TB_LEGACY] version 2026-06-05-legacy-v3-fast-stress");
    i_clk = 1'b0;
    forever #(CLK_PERIOD_NS/2) i_clk = ~i_clk;
  end

  initial begin
    error_count = 0;
    issued_count = 0;
    frf_wb_count = 0;
    xrf_wb_count = 0;
    csr_fflags_count = 0;
    cycle_count = 0;
    num_ops = 1000;
    seed = 32'h12345678;
    case_name = "directed";
    dump_vcd = 0;
    verbose_issue = 0;
    stress_progress_interval = 0;

    plusarg_found = $value$plusargs("case=%s", case_name);
    plusarg_found = $value$plusargs("num_ops=%d", num_ops);
    plusarg_found = $value$plusargs("seed=%d", seed);
    plusarg_found = $value$plusargs("progress=%d", stress_progress_interval);
    dump_vcd = $test$plusargs("dump_vcd");
    verbose_issue = $test$plusargs("verbose_issue");

    if (dump_vcd) begin
      $dumpfile("tb_sc_idu_to_fxu_legacy.vcd");
      $dumpvars(0, tb_sc_idu_to_fxu_legacy);
      $display("[TB_LEGACY] VCD dump enabled: tb_sc_idu_to_fxu_legacy.vcd");
    end

    i_reset_n = 1'b0;
    i_fxu_idu_opcd = {`FXU_OPCD_WIDTH{1'b0}};
    i_fxu_idu_round = `TB_ROUND_RNE;
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
    @(negedge i_clk);
    i_reset_n = 1'b1;
    repeat (10) @(posedge i_clk);

    $display("[TB_LEGACY] case=%s num_ops=%0d seed=%0d", case_name, num_ops, seed);
    $display("[TB_LEGACY] opcodes fadd=%0h fsub=%0h fmul=%0h feq=%0h flt=%0h fle=%0h round=%0h",
             `TB_OP_FADD_S, `TB_OP_FSUB_S, `TB_OP_FMUL_S, `TB_OP_FEQ_S, `TB_OP_FLT_S, `TB_OP_FLE_S, `TB_ROUND_RNE);

    if (case_name == "smoke") begin
      repeat (100) @(posedge i_clk);
    end else if (case_name == "directed") begin
      @(negedge i_clk);
      i_fxu_idu_opcd = `TB_OP_FADD_S;
      i_fxu_idu_round = `TB_ROUND_RNE;
      i_fxu_idu_conv_fma_vld = {{(`FXU_SUBMODULE_VLD_WIDTH-1){1'b0}}, 1'b1};
      i_fxu_idu_opcd_vld = 1'b1;
      i_fxu_idu_oprd1 = {`FXU_DATA_WIDTH{1'b1}};
      i_fxu_idu_oprd2 = {`FXU_DATA_WIDTH{1'b1}};
      i_fxu_idu_oprd3 = {`FXU_DATA_WIDTH{1'b1}};
      i_fxu_idu_oprd1[31:0] = 32'h3f800000;
      i_fxu_idu_oprd2[31:0] = 32'h3f800000;
      i_fxu_idu_oprd3[31:0] = 32'h40000000;
      i_fxu_idu_waddr = 5'd1;
`ifdef PIPE_INFO_FOR_TEST
      i_idu_pc = i_idu_pc + 4;
`endif
      $display("[TB_LEGACY][ISSUE] opcd=%0h waddr=%0d oprd1=0x%0h oprd2=0x%0h oprd3=0x%0h",
               i_fxu_idu_opcd, i_fxu_idu_waddr, i_fxu_idu_oprd1, i_fxu_idu_oprd2, i_fxu_idu_oprd3);
      issued_count = issued_count + 1;
      @(posedge i_clk);
      @(negedge i_clk);
      i_fxu_idu_opcd_vld = 1'b0;
      i_fxu_idu_conv_fma_vld = {`FXU_SUBMODULE_VLD_WIDTH{1'b0}};

      repeat (20) @(posedge i_clk);

      @(negedge i_clk);
      i_fxu_idu_opcd = `TB_OP_FSUB_S;
      i_fxu_idu_round = `TB_ROUND_RNE;
      i_fxu_idu_conv_fma_vld = {{(`FXU_SUBMODULE_VLD_WIDTH-1){1'b0}}, 1'b1};
      i_fxu_idu_opcd_vld = 1'b1;
      i_fxu_idu_oprd1 = {`FXU_DATA_WIDTH{1'b1}};
      i_fxu_idu_oprd2 = {`FXU_DATA_WIDTH{1'b1}};
      i_fxu_idu_oprd3 = {`FXU_DATA_WIDTH{1'b1}};
      i_fxu_idu_oprd1[31:0] = 32'h40a00000;
      i_fxu_idu_oprd2[31:0] = 32'h3f800000;
      i_fxu_idu_oprd3[31:0] = 32'hc0000000;
      i_fxu_idu_waddr = 5'd2;
`ifdef PIPE_INFO_FOR_TEST
      i_idu_pc = i_idu_pc + 4;
`endif
      $display("[TB_LEGACY][ISSUE] opcd=%0h waddr=%0d oprd1=0x%0h oprd2=0x%0h oprd3=0x%0h",
               i_fxu_idu_opcd, i_fxu_idu_waddr, i_fxu_idu_oprd1, i_fxu_idu_oprd2, i_fxu_idu_oprd3);
      issued_count = issued_count + 1;
      @(posedge i_clk);
      @(negedge i_clk);
      i_fxu_idu_opcd_vld = 1'b0;
      i_fxu_idu_conv_fma_vld = {`FXU_SUBMODULE_VLD_WIDTH{1'b0}};

      repeat (20) @(posedge i_clk);

      @(negedge i_clk);
      i_fxu_idu_opcd = `TB_OP_FMUL_S;
      i_fxu_idu_round = `TB_ROUND_RNE;
      i_fxu_idu_conv_fma_vld = {{(`FXU_SUBMODULE_VLD_WIDTH-1){1'b0}}, 1'b1};
      i_fxu_idu_opcd_vld = 1'b1;
      i_fxu_idu_oprd1 = {`FXU_DATA_WIDTH{1'b1}};
      i_fxu_idu_oprd2 = {`FXU_DATA_WIDTH{1'b1}};
      i_fxu_idu_oprd3 = {`FXU_DATA_WIDTH{1'b1}};
      i_fxu_idu_oprd1[31:0] = 32'h3fc00000;
      i_fxu_idu_oprd2[31:0] = 32'h40000000;
      i_fxu_idu_oprd3[31:0] = 32'h00000000;
      i_fxu_idu_waddr = 5'd3;
`ifdef PIPE_INFO_FOR_TEST
      i_idu_pc = i_idu_pc + 4;
`endif
      $display("[TB_LEGACY][ISSUE] opcd=%0h waddr=%0d oprd1=0x%0h oprd2=0x%0h oprd3=0x%0h",
               i_fxu_idu_opcd, i_fxu_idu_waddr, i_fxu_idu_oprd1, i_fxu_idu_oprd2, i_fxu_idu_oprd3);
      issued_count = issued_count + 1;
      @(posedge i_clk);
      @(negedge i_clk);
      i_fxu_idu_opcd_vld = 1'b0;
      i_fxu_idu_conv_fma_vld = {`FXU_SUBMODULE_VLD_WIDTH{1'b0}};

      repeat (200) @(posedge i_clk);
    end else if (case_name == "stress") begin
      lfsr = seed;
      @(negedge i_clk);
      i_fxu_idu_round = `TB_ROUND_RNE;
      i_fxu_idu_conv_fma_vld = {{(`FXU_SUBMODULE_VLD_WIDTH-1){1'b0}}, 1'b1};
      i_fxu_idu_opcd_vld = 1'b1;
      for (i = 0; i < num_ops; i = i + 1) begin
        lfsr2 = {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
        if (lfsr2 == 32'h0) begin
          lfsr2 = 32'h1;
        end
        lfsr = lfsr2;
        case (lfsr[1:0])
          2'd0: selected_opcd = `TB_OP_FADD_S;
          2'd1: selected_opcd = `TB_OP_FSUB_S;
          default: selected_opcd = `TB_OP_FMUL_S;
        endcase

        i_fxu_idu_opcd = selected_opcd;
        i_fxu_idu_oprd1 = {`FXU_DATA_WIDTH{1'b1}};
        i_fxu_idu_oprd2 = {`FXU_DATA_WIDTH{1'b1}};
        i_fxu_idu_oprd3 = {`FXU_DATA_WIDTH{1'b1}};
        i_fxu_idu_oprd1[31:0] = {1'b0, lfsr[30:0]};
        i_fxu_idu_oprd2[31:0] = {1'b0, lfsr2[30:0]};
        i_fxu_idu_oprd3[31:0] = {1'b0, lfsr2[30:0]};
        i_fxu_idu_waddr = i[4:0];
`ifdef PIPE_INFO_FOR_TEST
        i_idu_pc = i_idu_pc + 4;
`endif
        issued_count = issued_count + 1;

        if (stress_progress_interval > 0 && (i % stress_progress_interval) == 0) begin
          $display("[TB_LEGACY] stress progress issued=%0d", i);
        end

        @(negedge i_clk);
      end
      i_fxu_idu_opcd_vld = 1'b0;
      i_fxu_idu_conv_fma_vld = {`FXU_SUBMODULE_VLD_WIDTH{1'b0}};
      repeat (2000) @(posedge i_clk);
    end else begin
      $display("[TB_LEGACY][ERROR] unknown case=%s", case_name);
      error_count = error_count + 1;
    end

    if (o_fxu_pending) begin
      $display("[TB_LEGACY][ERROR] pending still high at finish");
      error_count = error_count + 1;
    end

    if (issued_count > 0 && (frf_wb_count + xrf_wb_count) == 0) begin
      $display("[TB_LEGACY][ERROR] issued operations but no writeback observed");
      error_count = error_count + 1;
    end

    if (case_name == "stress" && frf_wb_count != issued_count) begin
      $display("[TB_LEGACY][ERROR] stress writeback count mismatch: issued=%0d frf_wb=%0d",
               issued_count, frf_wb_count);
      error_count = error_count + 1;
    end

    $display("[TB_LEGACY][SUMMARY] issued=%0d frf_wb=%0d xrf_wb=%0d csr_fflags=%0d errors=%0d",
             issued_count, frf_wb_count, xrf_wb_count, csr_fflags_count, error_count);

    if (error_count == 0) begin
      $display("[TB_LEGACY][PASS]");
    end else begin
      $display("[TB_LEGACY][FAIL]");
    end
    $finish;
  end

  always @(posedge i_clk) begin
    cycle_count = cycle_count + 1;
    if (cycle_count > TIMEOUT_CYCLES) begin
      $display("[TB_LEGACY][ERROR] timeout");
      $finish;
    end

    if (i_reset_n) begin
      if (o_fxu_frf_we) begin
        frf_wb_count = frf_wb_count + 1;
        $display("[TB_LEGACY][FRF_WB] waddr=%0d wdata=0x%0h fflags_we=%0b fflags=0x%0h",
                 o_fxu_frf_waddr, o_fxu_frf_wdata, o_fxu_csr_fflags_we, o_fxu_csr_fflags);
        if (case_name == "directed") begin
          if (frf_wb_count == 1 && o_fxu_frf_waddr !== 5'd1) begin
            $display("[TB_LEGACY][ERROR] first directed writeback expected waddr=1, got %0d", o_fxu_frf_waddr);
            error_count = error_count + 1;
          end
          if (frf_wb_count == 2 && o_fxu_frf_waddr !== 5'd2) begin
            $display("[TB_LEGACY][ERROR] second directed writeback expected waddr=2, got %0d", o_fxu_frf_waddr);
            error_count = error_count + 1;
          end
          if (frf_wb_count == 3 && o_fxu_frf_waddr !== 5'd3) begin
            $display("[TB_LEGACY][ERROR] third directed writeback expected waddr=3, got %0d", o_fxu_frf_waddr);
            error_count = error_count + 1;
          end
          if (frf_wb_count >= 1 && frf_wb_count <= 3 && o_fxu_frf_wdata[31:0] !== 32'h40400000) begin
            $display("[TB_LEGACY][ERROR] directed writeback %0d expected 3.0/0x40400000, got 0x%0h",
                     frf_wb_count, o_fxu_frf_wdata);
            error_count = error_count + 1;
          end
        end
      end
      if (o_fxu_xrf_we_wb) begin
        xrf_wb_count = xrf_wb_count + 1;
        $display("[TB_LEGACY][XRF_WB] waddr=%0d wdata=0x%0h", o_fxu_xrf_waddr_wb, o_fxu_xrf_wdata_wb);
      end
      if (o_fxu_csr_fflags_we) begin
        csr_fflags_count = csr_fflags_count + 1;
      end
    end
  end

endmodule
