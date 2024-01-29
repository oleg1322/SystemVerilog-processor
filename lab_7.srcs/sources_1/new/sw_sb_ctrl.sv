`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.12.2023 21:05:08
// Design Name: 
// Module Name: sw_sb_ctrl
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


module sw_sb_ctrl(

  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        req_i,
  input  logic        write_enable_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] write_data_i,  // не используется, добавлен для
                                     // совместимости с системной шиной
  output logic [31:0] read_data_o,

  input logic [15:0]  sw_i
);

always_comb begin    
        if (req_i && !write_enable_i && addr_i == 32'h0) begin
            read_data_o <= {{16{1'b0}}, sw_i};
        end
end

endmodule
