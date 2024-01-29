`timescale 1ns / 1ps


module miriscv_ic(
    input logic clk_i,
    input logic [31:0] mie_i,
    input logic [31:0] int_req_i,
    input logic INT_RST_i,
    
    output logic [31:0] mcause_o,
    output logic INT_o,
    output logic [31:0] int_fin_o    
);

logic [4:0] DC = 0;

logic INT_before;
logic INT_after;

logic [31:0] uniq_wire;
logic [31:0] comon_wire;

always_ff @(posedge clk_i) begin
    if (INT_RST_i)
        DC <= 0;
    else 
        if (!INT_before)
            DC <= DC + 1;
        else     
            DC <= DC;    
end

always_ff @(posedge clk_i or posedge INT_RST_i) begin
    if (INT_RST_i) begin 
        INT_after <= 0;
    end    
    else
        INT_after <= INT_before;   
end 

always_comb begin
    comon_wire <= 32'd1 << DC; 
end

always_comb begin
    for (int i = 0; i < 32; i = i + 1) begin
        int_fin_o[i] <= INT_RST_i & uniq_wire[i];
    end
end

assign uniq_wire = mie_i & int_req_i & comon_wire;  
assign mcause_o = {27'b0, DC};
assign INT_before = | uniq_wire;
assign INT_o = INT_after ^ INT_before; 

endmodule
