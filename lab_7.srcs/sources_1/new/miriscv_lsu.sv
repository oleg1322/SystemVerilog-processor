`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.11.2023 18:31:52
// Design Name: 
// Module Name: miriscv_lsu
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


module miriscv_lsu (
    // clock, reset
    input logic clk_i,
    input logic arstn_i,
    
    // core protocol
    input logic [31:0] lsu_addr_i,
    input logic lsu_we_i,
    input logic [2:0] lsu_size_i,
    input logic [31:0] lsu_data_i,
    input logic lsu_req_i,
    output logic [31:0] lsu_data_o,
    output logic lsu_stall_req_o,
    
    // memory protocol
    input logic [31:0] data_rdata_i,
    output logic data_req_o,
    output logic data_we_o,
    output logic [3:0] data_be_o,
    output logic [31:0] data_addr_o,
    output logic [31:0] data_wdata_o
); 

logic stall;
//write
assign data_req_o = lsu_req_i;
assign data_we_o = lsu_we_i;

assign data_addr_o = lsu_addr_i;

assign lsu_stall_req_o = ~stall & lsu_req_i;

always_ff @(posedge clk_i) begin
    if (arstn_i) 
        stall <= 0;
    else
        stall <= ~stall & lsu_req_i;
end

always_comb begin
    if (lsu_we_i) begin
        case(lsu_size_i)
            3'd0: 
                begin
                    data_wdata_o = {4{lsu_data_i[7:0]}};
                    case (lsu_addr_i[1:0])
                        2'b00:
                            data_be_o = 4'b0001;
                        2'b01:
                            data_be_o = 4'b0010;
                        2'b10:
                            data_be_o = 4'b0100;
                        2'b11:
                            data_be_o = 4'b1000;
                    endcase
                end
            3'd1:
                begin
                    data_wdata_o = {2{lsu_data_i[15:0]}};
                    case (lsu_addr_i[1:0])
                        2'b00:
                            data_be_o = 4'b0011;
                        2'b01:
                            data_be_o = 4'b1100;
                    endcase
                end 
            3'd2:
                begin
                    data_wdata_o = lsu_data_i[31:0];
                    data_be_o = 4'b1111;
                end
            3'd4:
                begin
                    data_wdata_o = {4{lsu_data_i[7:0]}};
                    case (lsu_addr_i[1:0])
                        2'b00:
                            data_be_o = 4'b0001;
                        2'b01:
                            data_be_o = 4'b0010;
                        2'b10:
                            data_be_o = 4'b0100;
                        2'b11:
                            data_be_o = 4'b1000;
                    endcase
                end
            3'd5:
                begin
                    data_wdata_o = {2{lsu_data_i[15:0]}};
                    case (lsu_addr_i[1:0])
                        2'b00:
                            data_be_o = 4'b0011;
                        2'b01:
                            data_be_o = 4'b1100;
                    endcase
                end
        endcase
    end
end

always_comb begin
    case(lsu_size_i)
        3'd0: 
            begin
                case (lsu_addr_i[1:0])
                    2'b00:
                        lsu_data_o = {{24{data_rdata_i[7]}}, data_rdata_i[7:0]};
                    2'b01:
                        lsu_data_o = {{24{data_rdata_i[15]}}, data_rdata_i[15:8]};
                    2'b10:
                        lsu_data_o = {{24{data_rdata_i[23]}}, data_rdata_i[23:16]};
                    2'b11:
                        lsu_data_o = {{24{data_rdata_i[31]}}, data_rdata_i[31:24]};
                endcase
            end
        3'd1:
            begin
                case (lsu_addr_i[1:0])
                    2'b00:
                        lsu_data_o = {{16{data_rdata_i[15]}}, data_rdata_i[15:0]};
                    2'b01:
                        lsu_data_o = {{16{data_rdata_i[31]}}, data_rdata_i[31:16]};
                endcase
            end 
        3'd2:
            begin
                lsu_data_o = data_rdata_i[31:0];
            end
        3'd4:
            begin
                case (lsu_addr_i[1:0])
                    2'b00:
                        lsu_data_o = {24'b0, data_rdata_i[7:0]};
                    2'b01:
                        lsu_data_o = {24'b0, data_rdata_i[15:8]};
                    2'b10:
                        lsu_data_o = {24'b0, data_rdata_i[23:16]};
                    2'b11:
                        lsu_data_o = {24'b0, data_rdata_i[31:24]};
                endcase
            end
        3'd5:
            begin
                case (lsu_addr_i[1:0])
                    2'b00:
                        lsu_data_o = {16'b0, data_rdata_i[15:0]};
                    2'b01:
                        lsu_data_o = {16'b0, data_rdata_i[31:16]};
                endcase
            end
    endcase
end
endmodule
