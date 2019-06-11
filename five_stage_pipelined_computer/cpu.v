/**
* alu: ALU result
* mem: Data read from the data memory
*/
module cpu (
   input clock, input resetn, input [31:0] inst, input [31:0] mem,
   output [31:0] pc, output wmem, output [31:0] alu, output [31:0] data
);
   // IF stage
   wire [31:0] p4 = pc + 4;
   wire [31:0] branch_addr, jump_addr,
      npc;        // Next value of the PC, selected from 4 inputs
   reg [31:0] new_ra, new_rb;                   // forwarded ra and rb
   wire [31:0] id_p4, id_inst;                  // wires used in the ID stage
   wire [1:0] pcsource;
   wire stall;
   wire stall_inv = ~stall;
   dffe32 pc_reg(npc, clock, resetn, stall_inv, pc);        // define a D flip-flop for PC
   // select next pc
   mux4x32 next_pc(p4, branch_addr, new_ra, jump_addr, pcsource, npc);

   // handle control hazards
   wire control_hazard_stall_inv = pcsource == 2'b00,
      if_id_reg_resetn = resetn & control_hazard_stall_inv;
   if_id_reg if_id_reg_inst(clock, if_id_reg_resetn, stall_inv, p4, inst, id_p4, id_inst);

   // ID stage
   wire [15:0] imm = id_inst[15:0];
   // control signals
   wire id_wmem, id_wreg, regrt, id_m2reg, id_shift,
      id_aluimm, id_jal, sext;
   wire [3:0] id_aluc;
   // the number of the register to write, selected from rt and rd
   wire [4:0] id_write_reg_num = (regrt ? id_inst[20:16] : id_inst[15:11]);
   wire extension_bit = imm[15] & sext;
   wire [31:0] reg_data_in;                  // Data to write to the register
   wire [31:0] id_imm = {{16{extension_bit}}, imm};   // extended immmediate value
   wire ra_rb_equal = new_ra == new_rb;

   assign branch_addr = id_p4 + {{14{imm[15]}}, imm, 2'b00};
   assign jump_addr = {id_p4[31:28], id_inst[25:0], 2'b00};
   cu cu_inst(
      id_inst[31:26], id_inst[5:0], ra_rb_equal,
      id_wmem, id_wreg, regrt, id_m2reg, id_aluc, id_shift, id_aluimm,
      pcsource, id_jal, sext);

   // signals from the WB stage
   wire [4:0] wb_write_reg_num;
   // Register file is fed an inverse clock
   wire clock_inv = ~clock;
   wire [31:0] ra, rb;     // 1st and 2nd value read from the register file
   wire wb_wreg;
   regfile regfile_inst(
      id_inst[25:21], id_inst[20:16], reg_data_in, wb_write_reg_num,
      wb_wreg, clock_inv, resetn, ra, rb);

   // wires used during the EX stage
   wire ex_wreg, ex_m2reg, ex_wmem, ex_jal, ex_aluimm, ex_shift;
   wire [3:0] ex_aluc;
   wire [31:0] ex_p4, ex_new_ra, ex_new_rb, ex_imm;
   wire [4:0] ex_write_reg_num;
   wire id_ex_reg_resetn = resetn & stall_inv;
   id_ex_reg id_ex_reg_inst(
      clock, id_ex_reg_resetn, id_wreg, id_m2reg, id_wmem, id_jal, id_aluc, id_aluimm, id_shift,
      id_p4, new_ra, new_rb, id_imm, id_write_reg_num,
      ex_wreg, ex_m2reg, ex_wmem, ex_jal, ex_aluc, ex_aluimm, ex_shift,
      ex_p4, ex_new_ra, ex_new_rb, ex_imm, ex_write_reg_num);
   
   // EX stage
   wire [31:0] ex_alu_result;
   wire [31:0] shamt = {27'b0, ex_imm[10:6]},   // shift amount
      alu_a = ex_shift ? shamt : ex_new_ra,
      alu_b = ex_aluimm ? ex_imm : ex_new_rb,
      ex_alu_result_updated = ex_jal ? ex_p4 : ex_alu_result;
   // the number of the register to write, with jal considered
   wire [4:0] ex_write_reg_num_updated = ex_write_reg_num | {5{ex_jal}};
   // z port of ALU is not connected.
   alu alu_inst(alu_a, alu_b, ex_aluc, ex_alu_result);

   // stall if lw is follwed by an instruction that will uses the register
   // value at EX or earlier
   // sw is excluded
   assign stall = ex_m2reg && ~id_wmem && (id_inst[25:21] == ex_write_reg_num_updated
         || id_inst[20:16] == ex_write_reg_num_updated);

   wire mem_wreg, mem_m2reg;
   wire [4:0] mem_write_reg_num;
   // data to write to the memory, with forwarding
   wire [31:0] mem_write_data = (mem_m2reg & ex_wmem
      & (mem_write_reg_num == ex_write_reg_num)) ? mem : new_rb;
   ex_mem_reg ex_mem_reg_inst(
      clock, ex_wreg, ex_m2reg, ex_wmem, ex_alu_result_updated,
      mem_write_data, ex_write_reg_num_updated,
      mem_wreg, mem_m2reg, wmem, alu, data, mem_write_reg_num);
   // MEM stage happens in the data memory
   
   wire wb_m2reg;
   wire [31:0] wb_alu_result, wb_mem_data;
   mem_wb_reg mem_wb_reg_inst(
      clock, mem_wreg, mem_m2reg, alu, mem, mem_write_reg_num,
      wb_wreg, wb_m2reg, wb_alu_result, wb_mem_data, wb_write_reg_num);
   
   // WB stage
   assign reg_data_in = wb_m2reg ? wb_mem_data : wb_alu_result;
   
   always @(*) begin
      // forward to ra of ID
      // check whether inst[25:21] == 0 with |inst[25:21]
      if (ex_wreg & ~ex_m2reg & id_inst[25:21] == ex_write_reg_num_updated & (|id_inst[25:21]))
         new_ra <= ex_alu_result_updated;
      else if (mem_wreg & id_inst[25:21] == mem_write_reg_num & (|id_inst[25:21]))
         if (mem_m2reg)
            new_ra <= mem;
         else
            new_ra <= alu;
      else
         new_ra <= ra;
      // forward to rb of ID
      if (ex_wreg & ~ex_m2reg & id_inst[20:16] == ex_write_reg_num_updated & (|id_inst[20:16]))
         new_rb <= ex_alu_result_updated;
      else if (mem_wreg & id_inst[20:16] == mem_write_reg_num & (|id_inst[20:16]))
         if (mem_m2reg)
            new_rb <= mem;
         else
            new_rb <= alu;
      else
         new_rb <= rb;
   end
endmodule
