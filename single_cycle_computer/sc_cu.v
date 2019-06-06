/**
* wmem: Enable memory write if true
* regrt: True if rt is the register to write
* m2reg: Data read from the data memory will be written to the register if true.
* aluc: Control signals for the ALU
* shift: The first operand of ALU comes from shamt (true) or rs
* aluimm: True if immediate value is supplied to the ALU
* jal: True if $ra will be written
* sext: sign extension if true
*/
module sc_cu (op, func, z, wmem, wreg, regrt, m2reg, aluc, shift,
              aluimm, pcsource, jal, sext);
   input  [5:0] op,func;
   input        z;
   output       wreg,regrt,jal,m2reg,shift,aluimm,sext,wmem;
   output [3:0] aluc;
   output [1:0] pcsource;
   wire r_type = ~|op;
   wire i_add = r_type & func[5] & ~func[4] & ~func[3] &
                ~func[2] & ~func[1] & ~func[0];          //100000
   wire i_sub = r_type & func[5] & ~func[4] & ~func[3] &
                ~func[2] &  func[1] & ~func[0];          //100010

   wire i_and = r_type & func[5] & ~func[4] & ~func[3] & func[2] & ~func[1] & ~func[0];
   wire i_or  = r_type & func[5] & ~func[4] & ~func[3] & func[2] & ~func[1] & func[0];

   wire i_xor = r_type & func[5] & ~func[4] & ~func[3] & func[2] & func[1] & ~func[0];
   wire i_sll = r_type & ~|func;
   wire i_srl = r_type & ~func[5] & ~func[4] & ~func[3] & ~func[2] & func[1] & ~func[0];
   wire i_sra = r_type & ~func[5] & ~func[4] & ~func[3] & ~func[2] & func[1] & func[0];
   wire i_jr  = r_type & ~func[5] & ~func[4] & func[3] & ~func[2] & ~func[1] & ~func[0];
                
   wire i_addi = ~op[5] & ~op[4] &  op[3] & ~op[2] & ~op[1] & ~op[0]; //001000
   wire i_andi = ~op[5] & ~op[4] &  op[3] &  op[2] & ~op[1] & ~op[0]; //001100
   
   wire i_ori  = ~op[5] & ~op[4] & op[3] & op[2] & ~op[1] & op[0];
   wire i_xori = ~op[5] & ~op[4] & op[3] & op[2] & op[1] & ~op[0];
   wire i_lw   = op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
   wire i_sw   = op[5] & ~op[4] & op[3] & ~op[2] & op[1] & op[0];
   wire i_beq  = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
   wire i_bne  = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & op[0];
   wire i_lui  = ~op[5] & ~op[4] & op[3] & op[2] & op[1] & op[0];
   wire i_j    = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & ~op[0];
   wire i_jal  = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];

   assign pcsource[1] = i_jr | i_j | i_jal;
   assign pcsource[0] = ( i_beq & z ) | (i_bne & ~z) | i_j | i_jal ;
   
   assign wreg = i_add | i_sub | i_and | i_or   | i_xor  |
                 i_sll | i_srl | i_sra | i_addi | i_andi |
                 i_ori | i_xori | i_lw | i_lui  | i_jal;

   assign aluc[3] = i_sra;
   assign aluc[2] = i_sub | i_or | i_ori | i_lui | i_srl | i_sra | i_beq | i_bne;
   assign aluc[1] = i_xor | i_xori | i_lui | shift;
   assign aluc[0] = i_and | i_andi | i_or | i_ori | shift;
   assign shift   = i_sll | i_srl | i_sra ;

   assign aluimm  = ~(r_type | i_beq | i_bne);
   assign sext    = ~(i_andi | i_ori | i_xori);
   assign wmem    = i_sw;
   assign m2reg   = i_lw;
   assign regrt   = ~r_type;
   assign jal     = i_jal;
endmodule
