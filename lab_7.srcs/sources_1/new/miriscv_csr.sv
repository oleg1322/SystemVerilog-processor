`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2023 18:36:50
// Design Name: 
// Module Name: CSR
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


module CSR(
    input logic clk_i,
    input logic [11:0]A_i,
    input logic [31:0]WD_i,
    input logic [31:0]mcause_i,
    input logic [31:0]PC_i,
    input logic [2:0]OP_i,
    
    output logic [31:0]RD_o,
    output logic [31:0]mie_o,
    output logic [31:0]mtvec_o,
    output logic [31:0]mepc_o
    );
    
    logic [31:0]RD_out;
    logic [31:0]en_data;
    logic [31:0]mscr;
    logic [31:0]mcause_reg;
    logic [31:0]pc_wire;
    logic [31:0]mcause_wire;
    
    logic en_304;
    logic en_305;
    logic en_340;
    logic en_341;
    logic en_342;
    
    always_comb begin 
        case(OP_i[1:0])
            0: en_data <= 32'b0;
            1: en_data <= WD_i;
            2: en_data <= (!WD_i && RD_o);
            3: en_data <= (WD_i || RD_o);
        endcase 
    end
    
    always_comb begin
        en_304 <= 0;
        en_305 <= 0;
        en_340 <= 0;
        en_341 <= 0;
        en_342 <= 0;
        case(A_i)
            12'h304: en_304 <= OP_i[1] || OP_i[0];
            12'h305: en_305 <= OP_i[1] || OP_i[0];
            12'h340: en_340 <= OP_i[1] || OP_i[0];
            12'h341: en_341 <= OP_i[1] || OP_i[0];
            12'h342: en_342 <= OP_i[1] || OP_i[0];
        endcase 
    end
    
    always_comb begin
        case(OP_i[2])
            1: pc_wire <= PC_i;
            0: pc_wire <= en_data;
        endcase
    end
    
    always_comb begin
        case(OP_i[2])
            1: mcause_wire <= mcause_i;
            0: mcause_wire <= en_data;
        endcase
    end
    
    always_ff @(posedge clk_i) begin
        if (en_304) mie_o <= en_data;
        if (en_305) mtvec_o <= en_data;
        if (en_340) mscr <= en_data;
        if (en_341 || OP_i[2]) mepc_o <= pc_wire;
        if (en_342 || OP_i[2]) mcause_reg <= mcause_wire;
    end
    
    always_comb begin
        case(A_i)
            12'h304: RD_o <= mie_o;
            12'h305: RD_o <= mtvec_o;
            12'h340: RD_o <= mscr;
            12'h341: RD_o <= mepc_o;
            12'h342: RD_o <= mcause_reg;
        endcase
    end
     
endmodule
