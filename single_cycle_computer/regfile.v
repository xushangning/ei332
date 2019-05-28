/**
* rna: 1st register number
* rnb: 2nd register number
* d: Data to write into the register
* wn: The number of the register to write
* we: Register write signal from the CU
* qa: 1st data read
* qb: 2nd data read
*/
module regfile (rna,rnb,d,wn,we,clk,clrn,qa,qb);
   input [4:0] rna,rnb,wn;
   input [31:0] d;
   input we,clk,clrn;
   
   output [31:0] qa,qb;
   
   reg [31:0] register [1:31]; // r1 - r31
   
   assign qa = (rna == 0)? 0 : register[rna]; // read
   assign qb = (rnb == 0)? 0 : register[rnb]; // read

   always @(posedge clk or negedge clrn) begin
      // ModelSim does not allow declarations in an unamed block.
      if (clrn == 0) begin: my_block // reset
         integer i;
         for (i=1; i<32; i=i+1)
            register[i] <= 0;
      end else begin
         if ((wn != 0) && (we == 1))          // write
            register[wn] <= d;
      end
   end
endmodule
