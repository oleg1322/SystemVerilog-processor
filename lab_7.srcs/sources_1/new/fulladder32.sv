`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.09.2023 13:39:19
// Design Name: 
// Module Name: fulladder32
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


module fulladder32(
    input  logic [31:0] a32,
    input  logic [31:0] b32,
    input  logic        cin32,
    output logic [31:0] sum32,
    output logic        cout32
);
logic [32:0] carry;
genvar i;
generate
    assign carry[0] = cin32; 
    for(i = 0; i < 32; i = i +1) begin : newgen
        fulladder new_adder (
            .a(a32[i]),
            .b(b32[i]),
            .cin(carry[i]),
            .sum(sum32[i]),
            .cout(carry[i + 1])
        );
    end
    assign cout32 = carry[32]; 
endgenerate
endmodule
