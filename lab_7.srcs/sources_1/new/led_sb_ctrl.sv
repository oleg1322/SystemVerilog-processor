`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.12.2023 22:03:41
// Design Name: 
// Module Name: led_sb_ctrl
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


module led_sb_ctrl(

  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        req_i,
  input  logic        write_enable_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] write_data_i,
  output logic [31:0] read_data_o,

  output logic [15:0]  led_o
);

logic [15:0]  led_val;
logic         led_mode;
logic         led_rst;

logic [31:0] count = 0;

logic setter = 0;

always_ff @ (posedge clk_i) begin
    //ввод данных на led_mode
    if (req_i && write_enable_i && addr_i == 32'h4) begin
        if (write_data_i == 0 || write_data_i == 1) begin
            led_mode <= write_data_i;
        end
    end
    
    if (!led_mode) begin
        if (req_i && write_enable_i && addr_i == 0) begin
            if (write_data_i < 65535) begin
                led_val <= write_data_i;
            end
        end    
    end
    
    //режим моргания
    if (led_mode) begin
        count <= count + 1;
        if (count == 300000) begin
            if (setter) begin
                led_val <= 0;
            end
            else begin
                led_val <= write_data_i;
            end
            setter <= !setter;
            count <= 0;
        end 
    end
    
    //сброс 
    if (req_i && write_enable_i && addr_i == 32'h24) begin
        if (write_data_i == 1) begin
            led_rst <= 1;
        end
        else begin
            led_rst <= 0;
        end
    end
    if (led_rst) begin
         led_val <= 0;
         led_mode <= 0;
    end
end

assign led_o = led_val;

always_comb begin
    if (req_i && !write_enable_i && addr_i == 0) begin
        read_data_o <= {{16{1'b0}}, led_val}; 
    end
    if (req_i && !write_enable_i && addr_i == 32'h4) begin
        read_data_o <= {{16{1'b0}}, led_mode}; 
    end
end 

endmodule