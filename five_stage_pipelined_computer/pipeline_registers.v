module if_id_reg(
   input clk,
   input resetn,
   input enable,
   input [31:0] pc4_in,
   input [31:0] instruction_in,
   output reg [31:0] pc4,
   output reg [31:0] instruction
);
   always @(posedge clk)
      if (~resetn) begin
         pc4 <= 0;
         instruction <= 0;
      end else if (enable) begin
         pc4 <= pc4_in;
         instruction <= instruction_in;
      end
endmodule

module id_ex_reg(
   input clk, input resetn, input wreg_in, input m2reg_in, input wmem_in, input jal_in,
   input [3:0] aluc_in, input aluimm_in, input shift_in, input [31:0] pc4_in,
   input [31:0] alu_a_in, input [31:0] alu_b_in, input [31:0] imm_in,
   input [4:0] write_reg_num_in,
   output reg wreg, output reg m2reg, output reg wmem, output reg jal,
   output reg [3:0] aluc, output reg aluimm, output reg shift,
   output reg [31:0] pc4, output reg [31:0] alu_a, output reg [31:0] alu_b,
   output reg [31:0] imm, output reg [4:0] write_reg_num
);
   always @(posedge clk) begin
      // control signals
      if (~resetn) begin
         wreg <= 0;
         m2reg <= 0;
         wmem <= 0;
         jal <= 0;
         aluc <= 0;
         aluimm <= 0;
         shift <= 0;

         pc4 <= 0;
         alu_a <= 0;
         alu_b <= 0;
         imm <= 0;
         write_reg_num <= 0;
      end else begin
         wreg <= wreg_in;
         m2reg <= m2reg_in;
         wmem <= wmem_in;
         jal <= jal_in;
         aluc <= aluc_in;
         aluimm <= aluimm_in;
         shift <= shift_in;

         pc4 <= pc4_in;
         alu_a <= alu_a_in;
         alu_b <= alu_b_in;
         imm <= imm_in;
         write_reg_num <= write_reg_num_in;
      end
   end
endmodule

module ex_mem_reg(
   input clk, input wreg_in, input m2reg_in, input wmem_in,
   input [31:0] alu_result_in, input [31:0] mem_write_data_in, input [4:0] write_reg_num_in,
   output reg wreg, output reg m2reg, output reg wmem, output reg [31:0] alu_result,
   output reg [31:0] mem_write_data, output reg [4:0] write_reg_num
);
   always @(posedge clk) begin
      wreg <= wreg_in;
      m2reg <= m2reg_in;
      wmem <= wmem_in;
      alu_result <= alu_result_in;
      mem_write_data <= mem_write_data_in;
      write_reg_num <= write_reg_num_in;
   end
endmodule

module mem_wb_reg(
   input clk, input wreg_in, input m2reg_in, input [31:0] alu_result_in,
   input [31:0] mem_data_in, input [4:0] write_reg_num_in,
   output reg wreg, output reg m2reg, output reg [31:0] alu_result,
   output reg [31:0] mem_data, output reg [4:0] write_reg_num
);
   always @(posedge clk) begin
      wreg <= wreg_in;
      m2reg <= m2reg_in;
      alu_result <= alu_result_in;
      mem_data <= mem_data_in;
      write_reg_num <= write_reg_num_in;
   end
endmodule
