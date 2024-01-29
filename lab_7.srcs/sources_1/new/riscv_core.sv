`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2023 20:32:29
// Design Name: 
// Module Name: riscv_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module riscv_core(
    input logic clk_i,
    input logic rst_i,
    
    // interrupt controller
    input logic [31:0] mcause_i,
    input logic INT_i,
    output logic [31:0] mie_o,
    input logic INT_RST_o,
    
    // instruction memory interface
    input logic [31:0] instr_i,
    output logic [31:0] instr_addr_o,
    
    //memory protocol
    input logic [31:0] data_rdata_i,
    output logic data_req_o,
    output logic data_we_o,
    output logic [3:0] data_be_o,
    output logic [31:0] data_addr_o,
    output logic [31:0] data_wdata_o
);
logic [31:0] rd1_o;
logic [31:0] rd2_o;
logic [31:0] alu_a;
logic [31:0] alu_b;
logic [31:0] PC;
logic [31:0] pre_wb_data;
logic [31:0] wb_data;
logic [31:0] alu_o;
logic [31:0] imm_I;
logic [1:0]  a_sel;
logic [2:0]  b_sel;
logic [4:0]  alu_op;
logic [31:0] pc_res;

logic [31:0] mem_rd_i;
logic [31:0] data_addr;
logic [31:0] mem_wd_o;

logic [31:0] mtvec;
logic [31:0] mepc;
logic [31:0] RD;

logic wb_sel;
logic csr;
logic b;
logic [31:0] RES_IN_ASS;
logic jal;
logic [31:0] res_to_add;
logic flag;
logic jarl;
logic gpr_we;
logic mem_req;
logic mem_we;
logic [2:0] mem_size;
logic stall;
logic enpc;
logic [2:0] CSRop;

assign instr_addr_o = PC; 

always_comb begin
    case(a_sel)
    0: alu_a <= rd1_o;
    1: alu_a <= PC;
    2: alu_a <= 0;
    endcase
end

always_comb begin
    case(b_sel)
    0: alu_b <= rd2_o;
    1: alu_b <= {{20{instr_i[31]}}, instr_i[31:20]};
    2: alu_b <= {instr_i[31:12], 12'h000};
    3: alu_b <= {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
    4: alu_b <= 4; 
    endcase
end

always_comb begin
    case(wb_sel)
        0: pre_wb_data <= alu_o;
        1: pre_wb_data <= mem_rd_i;
    endcase
end

always_comb begin
    case(csr)
        0: wb_data <= pre_wb_data;
        1: wb_data <= RD;
    endcase
end

always_comb begin
    case(b)
        0: RES_IN_ASS <= {{11{instr_i[31]}}, instr_i[19:12], instr_i[20],instr_i[31:21],1'b0};
        1: RES_IN_ASS <= {{20{instr_i[31]}}, instr_i[7], instr_i[30:25],instr_i[11:8],1'b0};
    endcase
end

always_comb begin
    case(jal || b && flag)
        0: res_to_add <= 4; //возможно не 4;
        1: res_to_add <= RES_IN_ASS;
    endcase
end

always_comb begin
    case(jarl)
        0: pc_res <= PC + res_to_add;
        1: pc_res <= rd1_o + imm_I;
        2: pc_res <= mepc;
        3: pc_res <= mtvec;
    endcase
end

 always_ff @(posedge clk_i) begin
    if (!rst_i)
        PC <= 0;
    else begin
        if (enpc)
            PC <= PC;
        else 
            PC <= pc_res;
    end
 end
   
assign data_addr = alu_o;
assign imm_I = {{20{instr_i[31]}}, instr_i[31:20]};
    
rf_riscv reg_f (.clk_i(clk_i), 
               .write_enable_i(gpr_we), 
               .write_addr_i(instr_i[11:7]), 
               .read_addr1_i(instr_i[19:15]), 
               .read_addr2_i(instr_i[24:20]), 
               .write_data_i(wb_data), 
               .read_data1_o(rd1_o), 
               .read_data2_o(rd2_o)
);
   
alu_rscv alu (.a(alu_a), 
             .b(alu_b), 
             .alu_op(alu_op), 
             .flag(flag), 
             .result(alu_o)
);

decoder_riscv decoder (
                      .fetched_instr_i (instr_i),
                      .stall_i (stall),
                      .INT_i(INT_i),
                      .a_sel_o (a_sel), 
                      .b_sel_o (b_sel), 
                      .alu_op_o (alu_op), 
                      .mem_req_o (mem_req),
                      .mem_we_o (mem_we),
                      .mem_size_o (mem_size),
                      .gpr_we_o (gpr_we),
                      .wb_sel_o (wb_sel),    
                      .illegal_instr_o (),
                      .branch_o (b),
                      .jal_o (jal),
                      .jalr_o (jarl),
                      .enpc_o (enpc),
                      .INT_RST_o (INT_RST_o),
                      .CSRop_o (CSRop),
                      .csr_o (csr)
);

miriscv_lsu lsu (
                    .clk_i(clk_i),
                    .arstn_i(!rst_i),
                    .lsu_addr_i(data_addr),
                    .lsu_we_i(mem_we),
                    .lsu_size_i(mem_size),
                    .lsu_data_i(rd2_o),
                    .lsu_req_i(mem_req),
                    .lsu_data_o(mem_rd_i),
                    .lsu_stall_req_o(stall),
                    .data_rdata_i(data_rdata_i),
                    .data_req_o(data_req_o),
                    .data_we_o(data_we_o),
                    .data_be_o(data_be_o),
                    .data_addr_o(data_addr_o),
                    .data_wdata_o(data_wdata_o)
);

miriscv_csr csr_m (
                    .clk_i(clk_i),
                    .OP_i(CSRop),
                    .A_i(instr_i[31:20]),
                    .PC_i(PC),
                    .mcause_i(mcause_i),
                    .WD_i(rd1_o),
                    .mie_o(mie_o),
                    .mtvec_o(mtvec),
                    .mepc_o(mepc),
                    .RD_o(RD)
);
    
endmodule
