`timescale 1ns / 1ps

module alu_rscv (
  input logic [31:0] a,
  input  logic [31:0]  b,
  input  logic [4:0]   alu_op,
  output logic         flag,
  output logic [31:0]  result
);

import alu_opcodes_pkg::*;      // импорт параметров,
logic [31:0] result_sum;
fulladder32 add (.a32(a), .b32(b), .cin32(0), .sum32(result_sum), .cout32());                           // коды операций для АЛУ
always_comb begin
    case(alu_op)
    //logic
    ALU_ADD: result = result_sum;
    ALU_SUB: result = a - b; 
    ALU_XOR: result = a ^ b;  
    ALU_OR: result = a | b;
    ALU_AND: result = a & b;
    //shifts
    ALU_SRA: result = $signed(a) >>> b[4:0];
    ALU_SRL: result = $signed(a) >> b[4:0];
    ALU_SLL: result = $signed(a) << b[4:0];
    // set lower than operations
    ALU_SLTS: result = $signed(a) < $signed(b);
    ALU_SLTU: result = a < b;
    default: result = 0;
    endcase
end

always_comb begin
    case(alu_op)
    // comparisons
     ALU_LTS: flag = $signed(a) < $signed(b);
     ALU_LTU: flag = a < b;
     ALU_GES: flag = $signed(a) >= $signed(b);
     ALU_GEU: flag = a >= b;
     ALU_EQ: flag = a == b;
     ALU_NE: flag = a != b;
     default: flag = 0;
     endcase
end

endmodule
