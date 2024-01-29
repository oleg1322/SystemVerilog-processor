`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2023 22:30:43
// Design Name: 
// Module Name: riscv_unit
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



module riscv_unit#(
  parameter RAM_SIZE      = 256, // bytes
  parameter RAM_INIT_FILE = ""
)(
    input logic clk_i,
    input logic rst_i,
    // Входы и выходы периферии
    input  logic [15:0] sw_i,       // Переключатели
    output logic [15:0] led_o      // Светодиоды
   // input  logic        kclk_i,     // Тактирующий сигнал клавиатуры
   // input  logic        kdata_i,    // Сигнал данных клавиатуры
    //output logic [ 6:0] hex_led_o,  // Вывод семисегментных индикаторов
    //output logic [ 7:0] hex_sel_o,  // Селектор семисегментных индикаторов
   // input  logic        rx_i,       // Линия приема по UART
   //output logic        tx_o        // Линия передачи по UART
    
    //input logic [31:0] int_req_i,
    //output logic  [31:0] PC,
    //output logic [31:0]mem_wd_o,
    //output logic [31:0] data_addr_o,
    //output logic [31:0] instr_addr_o,
    //output logic [31:0] MEM_RD_I
    );
    
    logic sysclk, rst;
    sys_clk_rst_gen divider(.ex_clk_i(clk_i),.ex_areset_n_i(rst_i),.div_i(10),.sys_clk_o(sysclk), .sys_reset_o(rst));
    
    logic [31:0] instr_i;
    logic [31:0] mem_rd_i;
    
    //memory protocol
    logic [31:0] data_rdata;
    logic data_req;
    logic data_we;        
    logic [3:0] data_be;   
    logic [31:0] data_addr;
    logic [31:0] data_wdata;
    
    logic [31:0] instr_addr_o;
   // assign MEM_RD_I = mem_rd_i;
    
    logic stall;
    logic mem_we_o;
    logic mem_req_o;
    logic stall_i;
    
    logic [31:0] mcause;
    logic [31:0] mie;
    logic interrupt;
    logic INT_RST;
    
    logic [31:0] rdata_rm;
    logic [31:0] rdata_sw;
    logic [31:0] rdata_led;
   
    always_ff @ (posedge sysclk) begin
        if (rst) stall <= 0;
        else stall <= stall_i; 
    end
   
    assign stall_i = ~stall & mem_req_o;
   
    riscv_core core(.clk_i(sysclk),
                    .rst_i(!rst),
                    
                    // interrupt controller
                    .mcause_i(mcause),
                    .INT_i(interrupt),
                    .mie_o(mie),
                    .INT_RST_o(INT_RST),
                    
                    // instruction memory interface
                    .instr_i(instr_i),
                    .instr_addr_o(instr_addr_o),
                    
                    //memory protocol
                    .data_rdata_i(data_rdata),
                    .data_req_o(data_req),
                    .data_we_o(data_we),
                    .data_be_o(data_be),
                    .data_addr_o(data_addr),
                    .data_wdata_o(data_wdata)
                    );
                    
    miriscv_ram rm(
                    .clk_i(sysclk),
                    .rst_n_i(!rst),
                    .instr_rdata_o(instr_i),
                    .instr_addr_i(instr_addr_o),
                    .data_rdata_o(rdata_rm),
                    .data_req_i(data_req && out[0]),
                    .data_we_i(data_we),
                    .data_be_i(data_be),
                    .data_addr_i({8'd0, data_addr[23:0]}),
                    .data_wdata_i(data_wdata)
    );
    
    miriscv_ic ic(
                    .clk_i(sysclk),
                    .mie_i(mie),
                    .int_req_i(),
                    .INT_RST_i(INT_RST),
                    .mcause_o(mcause),
                    .INT_o(interrupt),
                    .int_fin_o()
    );
    
    logic [255:0] out; 
    
    always_comb begin
        case (data_addr[31:24])
            8'd0: out <= {{253{1'b0}}, 3'b001};
            8'd1: out <= {{253{1'b0}}, 3'b010};
            8'd2: out <= {{253{1'b0}}, 3'b100};
        endcase
    end
    
    sw_sb_ctrl sw(
          .clk_i(sysclk),
          .rst_i(rst),
          .req_i(data_req && out[1]),
          .write_enable_i(data_we),
          .addr_i({8'd0, data_addr[23:0]}),
          .write_data_i(data_wdata),             
          .read_data_o(rdata_sw),
          .sw_i(sw_i)
    );
    
    led_sb_ctrl led(
        .clk_i(sysclk),
        .rst_i(rst),
        .req_i(data_req && out[2]),
        .write_enable_i(data_we),
        .addr_i({8'd0, data_addr[23:0]}),
        .write_data_i(data_wdata),
        .read_data_o(rdata_led),
        .led_o(led_o)
    );
    
    always_comb begin
        case (data_addr[31:24]) 
            8'd0: data_rdata <= rdata_rm;
            8'd1: data_rdata <= rdata_sw;
            8'd2: data_rdata <= rdata_led;
        endcase
    end
            
endmodule
