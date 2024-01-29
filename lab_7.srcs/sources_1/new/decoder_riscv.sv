`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2023 17:24:20
// Design Name: 
// Module Name: decoder_riscv
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


module decoder_riscv (
  input  logic [31:0]  fetched_instr_i,
  input logic         stall_i,
  input logic         INT_i,
  
  output logic [1:0]   a_sel_o,
  output logic [2:0]   b_sel_o,
  output logic [4:0]   alu_op_o,
  output logic         mem_req_o,
  output logic         mem_we_o,
  output logic [2:0]   mem_size_o,
  output logic         gpr_we_o,
  output logic         wb_sel_o,        //write back selector
  output logic         illegal_instr_o,
  output logic         branch_o,
  output logic         jal_o,
  output logic [1:0]   jalr_o,
  output logic         enpc_o,
  output logic         INT_RST_o,
  output logic [2:0]   CSRop_o,
  output logic         csr_o
);
  import riscv_pkg::*;
  import alu_opcodes_pkg::*; 
  
  //func
    logic [6:2] OPCODE;
    assign OPCODE = fetched_instr_i[6:2];
    logic [1:0] TWO_ONES;
    assign TWO_ONES = fetched_instr_i[1:0];
    logic [2:0] FUNC_3;
    assign FUNC_3 = fetched_instr_i[14:12];
    logic [6:0] FUNC_7;
    assign FUNC_7 = fetched_instr_i[31:25];
    
    assign enpc_o = stall_i;
  
  always_comb begin
  
    INT_RST_o <= 0;
    CSRop_o <= 3'b000;
    csr_o <= 0;
    
    if (INT_i) begin
        jalr_o <= 3;
        CSRop_o <= 3'b100;
    end
    
    case (TWO_ONES)
     2'b11:begin
        
        case (OPCODE)
            OP_OPCODE: begin
            a_sel_o <= 0;
            b_sel_o <= 0;
            wb_sel_o <= 0;
            mem_req_o <= 0;
            mem_we_o <= 0;
            mem_size_o <= 0;
            gpr_we_o <= 1;    
            illegal_instr_o <= 0;
            branch_o <= 0;
            jal_o <= 0;
            jalr_o <= 0;
            case (FUNC_3)
                3'b000: 
                    case(FUNC_7)
                        7'b0: begin                            
                            alu_op_o <= ALU_ADD;                      
                        end
                        default: begin
                            illegal_instr_o <= 1;
                             mem_req_o <= 0;
                            mem_we_o <= 0;
                            gpr_we_o <= 0;
                        end
                        7'h20: begin
                            
                            alu_op_o <= ALU_SUB;
                            
                                end    
                    endcase
                3'b001: 
                    case(FUNC_7)
                        7'b0: begin
                            
                            alu_op_o <= ALU_SLL;
                            ;
                                end
                        default: begin
                            illegal_instr_o <= 1;
                             mem_req_o <= 0;
                            mem_we_o <= 0;
                            gpr_we_o <= 0;
                        end
                        
                    endcase
                3'b010:
                    case(FUNC_7)
                        7'b0: begin
                            
                            alu_op_o <= ALU_SLTS;
                            
                                end
                        default: begin
                            illegal_instr_o <= 1;
                             mem_req_o <= 0;
                            mem_we_o <= 0;
                            gpr_we_o <= 0;
                        end
                    endcase
                3'b011:
                    case(FUNC_7)
                        7'b0: begin
                            
                            alu_op_o <= ALU_SLTU;
                            
                                end
                        default: begin
                            illegal_instr_o <= 1;
                             mem_req_o <= 0;
                            mem_we_o <= 0;
                            gpr_we_o <= 0;
                        end    
                       
                    endcase
                3'b100:
                    case(FUNC_7)
                        7'b0: begin
                            
                            alu_op_o <= ALU_XOR;
                            
                                end
                        default: begin
                            illegal_instr_o <= 1;
                             mem_req_o <= 0;
                            mem_we_o <= 0;
                            gpr_we_o <= 0;
                        end     
                        
                    endcase
                3'b101:
                    case(FUNC_7)
                        7'b0: begin
                            
                            alu_op_o <= ALU_SRL;
                            
                                end
                        7'h20: begin
                            
                            alu_op_o <= ALU_SRA;
                            
                                end
                        default: begin
                            illegal_instr_o <= 1;
                             mem_req_o <= 0;
                            mem_we_o <= 0;
                            gpr_we_o <= 0;
                        end
                    endcase
                3'b110:
                    case(FUNC_7)
                        7'b0: begin
                            
                            alu_op_o <= ALU_OR;
                            
                                end
                        default: begin
                            illegal_instr_o <= 1;
                             mem_req_o <= 0;
                            mem_we_o <= 0;
                            gpr_we_o <= 0;
                        end
                    endcase
                3'b111:
                    case(FUNC_7)
                        7'b0: begin
                            
                            alu_op_o <= ALU_AND;
                            
                            end
                        default: begin
                            illegal_instr_o <= 1;
                             mem_req_o <= 0;
                            mem_we_o <= 0;
                            gpr_we_o <= 0;
                        end
                    endcase
            endcase
        end
        MISC_MEM_OPCODE:begin
            case (FUNC_3)
            3'b000:begin illegal_instr_o <= 0;
            mem_we_o <= 0;
            mem_req_o <= 0;
            end
            default: begin
                            illegal_instr_o <= 1;
                        end
            
            endcase 
            end
        OP_IMM_OPCODE  : begin
                   a_sel_o <= 0;
                            b_sel_o <= 3'b001;
                           
                            wb_sel_o <= 0;
                            mem_req_o <= 0;
                            mem_we_o <= 0;
                            mem_size_o <= 0;
                            gpr_we_o <= 1;    
                            illegal_instr_o <= 0;
                            branch_o <= 0;
                            jal_o <= 0;
                            jalr_o <= 0; 
                   case (FUNC_3)
                3'b000: begin
                            
                            alu_op_o <= ALU_ADD;
                            
                                end
                                default: begin
                            illegal_instr_o <= 1;
                            gpr_we_o <= 0; 
                        end   
                                
                3'b001: begin
                    case(FUNC_7)
                        7'b0: begin
                            
                            alu_op_o <= ALU_SLL;
                            
                                end
                                default: begin
                            illegal_instr_o <= 1;
                            gpr_we_o <= 0; 
                        end 
                       endcase
                       end
                3'b010: begin
                            
                            alu_op_o <= ALU_SLTS;
                            
                                end                  
                3'b011: begin
                            
                            alu_op_o <= ALU_SLTU;
                            
                            end 
                3'b100: begin
                            
                            alu_op_o <= ALU_XOR;
                            
                            end   
                3'b101: begin
                    case(FUNC_7)
                        7'b0:begin
                            
                            alu_op_o <= ALU_SRL;
                            
                            end
                            default: begin
                            illegal_instr_o <= 1;
                            gpr_we_o <= 0; 
                        end   
                        7'h20:begin
                            
                            alu_op_o <= ALU_SRA;
                            
                                end
                    endcase
                    end
                3'b110: begin
                            
                            alu_op_o <= ALU_OR;
                            
                                end
                    
                3'b111: begin
                           
                            alu_op_o <= ALU_AND;
                            
                            end   
          endcase
    end   
        AUIPC_OPCODE   :begin 
                            a_sel_o <= 1;
                            b_sel_o <= 2;
                            alu_op_o <= ALU_ADD;
                            wb_sel_o <= 0;
                            mem_req_o <= 0;
                            mem_we_o <= 0;
                            mem_size_o <= 0;
                            gpr_we_o <= 1;    
                            illegal_instr_o <= 0;
                            branch_o <= 0;
                            jal_o <= 0;
                            jalr_o <= 0;
        end
       STORE_OPCODE   :begin
                            
                            a_sel_o <= 0;
                            b_sel_o <= 3'b011;
                            alu_op_o <= ALU_ADD;
                            wb_sel_o <= 0;
                            mem_req_o <= 1;
                            mem_we_o <= 1;
                           
                            gpr_we_o <= 0;    
                            illegal_instr_o <= 0;
                            branch_o <= 0;
                            jal_o <= 0;
                            jalr_o <= 0;
                   case (FUNC_3)
                3'b000: begin
                            
                            mem_size_o <= 3'd0;
                            
                                end
                                default: begin
                            illegal_instr_o <= 1;
                            mem_we_o <= 0;
                            mem_req_o <= 0;
                            
                        end  
                    3'b001: begin
                            
                            mem_size_o <= 3'd1;
                            
                       end
                  3'b010: begin
                            
                            mem_size_o <= 3'd2;
                            
                                end 
                        
                        
                     endcase
                   end
        LOAD_OPCODE      : begin
                            
                            a_sel_o <= 0;
                            b_sel_o <= 1;
                            alu_op_o <= ALU_ADD;
                            wb_sel_o <= 1;
                            mem_req_o <= 1;
                            mem_we_o <= 0;
                            gpr_we_o <= 1;    
                            illegal_instr_o <= 0;
                            branch_o <= 0;
                            jal_o <= 0;
                            jalr_o <= 0;
            case (FUNC_3)
                3'b000: begin
                            
                            mem_size_o <= 3'd0;
                            
                                end
                                default: begin
                            illegal_instr_o <= 1;
                            gpr_we_o <=0;
                            mem_req_o <= 0;
                        end   
                 3'b001: begin
                            
                            mem_size_o <= 3'd1;
                            
                       end
                  3'b010: begin
                            
                            mem_size_o <= 3'd2;
                            
                                end     
                   3'b100: begin
                            
                            mem_size_o <= 3'd4;
                           
                            end   
                    3'b101: begin
                            
                            mem_size_o <= 3'd5;
                            
                            end
            endcase
         end
        LUI_OPCODE     :begin 
                            a_sel_o <= 2'b10;
                            b_sel_o <= 3'b10;
                            alu_op_o <= ALU_ADD;
                            wb_sel_o <= 0;
                            mem_req_o <= 0;
                            mem_we_o <= 0;
                            mem_size_o <= 0;
                            gpr_we_o <= 1;    
                            illegal_instr_o <= 0;
                            branch_o <= 0;
                            jal_o <= 0;
                            jalr_o <= 0;
        end
        BRANCH_OPCODE  :begin
                            a_sel_o <= 0;
                            b_sel_o <= 0;
                            wb_sel_o <= 0;
                            mem_req_o <= 0;
                            mem_we_o <= 0;
                            mem_size_o <= 0;
                            gpr_we_o <= 0;    
                            illegal_instr_o <= 0;
                            branch_o <= 1;
                            jal_o <= 0;
                            jalr_o <= 0;
                   case (FUNC_3)
                            
                3'b000: begin
                            
                            alu_op_o <= ALU_EQ;
                            
                                end
                                default: begin
                            illegal_instr_o <= 1;
                            branch_o <= 0;
                        end  
                    3'b001: begin
                            
                            alu_op_o <= ALU_NE;
                            
                       end
                    3'b100: begin
                            
                            alu_op_o <= ALU_LTS;
                            
                            end   
                    3'b101: begin
                            
                            alu_op_o <= ALU_GES;
                            
                            end
                     3'b110: begin
                            
                            alu_op_o <= ALU_LTU;
                            
                            end
                      3'b111: begin
                            
                            alu_op_o <= ALU_GEU;
                            
                            end
            endcase
          end
        JALR_OPCODE    :begin 
        case (FUNC_3)
                3'b000: begin
                            a_sel_o <= 1;
                            b_sel_o <= 4;
                            alu_op_o <= ALU_ADD;
                            wb_sel_o <= 0;
                            mem_req_o <= 0;
                            mem_we_o <= 0;
                            mem_size_o <= 0;
                            gpr_we_o <= 1;    
                            illegal_instr_o <= 0;
                            branch_o <= 0;
                            jal_o <= 0;
                            jalr_o <= 1;
                         end
                                 default: begin
                            illegal_instr_o <= 1;
                            jal_o <= 0;
                            gpr_we_o <= 0;  
                            jalr_o <= 0;
                            
                                           end 
           endcase
           end
        JAL_OPCODE    :begin 
                            a_sel_o <= 1;
                            b_sel_o <= 4;
                            alu_op_o <= ALU_ADD;
                            wb_sel_o <= 0;
                            mem_req_o <= 0;
                            mem_we_o <= 0;
                            mem_size_o <= 0;
                            gpr_we_o <= 1;    
                            illegal_instr_o <= 0;
                            branch_o <= 0;
                            jal_o <= 1;
                            jalr_o <= 0;
        end
         
        SYSTEM_OPCODE  :begin
            a_sel_o <= 0;
            b_sel_o <= 0;
            alu_op_o <= 0;
            wb_sel_o <= 0;
            mem_req_o <= 0;
            mem_we_o <= 0;
            mem_size_o <= 0;
            gpr_we_o <= 0;    
            illegal_instr_o <= 0;
            branch_o <= 0;
            jal_o <= 0;
            jalr_o <= 0;
            case (FUNC_3)
                0: begin
                       jalr_o <= 2;
                       CSRop_o <= 3'b000;
                       INT_RST_o <= 1;
                   end
                1: begin
                       CSRop_o <= 3'b001;
                       csr_o <= 1; 
                   end
                2: begin
                       CSRop_o <= 3'b011;
                       csr_o <= 1; 
                   end
                3: begin
                       CSRop_o <= 3'b010;
                       csr_o <= 1; 
                   end
            default: begin
                            illegal_instr_o <= 1;
                            jal_o <= 0;
                            gpr_we_o <=0;
                                           end 
            endcase
            end
            default: begin 
    illegal_instr_o <=1 ; 
    jal_o <= 0;
    gpr_we_o <=0;
    mem_we_o <= 0;
    mem_req_o <= 0;
    jalr_o <= 0;
    branch_o <= 0;
    end
    endcase
    end
    default: begin 
    illegal_instr_o <=1 ; 
    jal_o <= 0;
    gpr_we_o <=0;
    mem_we_o <= 0;
    mem_req_o <= 0;
    jalr_o <= 0;
    branch_o <= 0;
    end
    endcase
           
    end

endmodule
