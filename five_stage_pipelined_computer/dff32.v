/**
* 32-bit D Flip-flop
*
* clrn: Clear on low
*/
module dff32 (d,clk,clrn,q);
   input  [31:0] d;
   input         clk,clrn;
   output [31:0] q;
   reg [31:0]    q;
   always @ (negedge clrn or posedge clk)
      q <= ~clrn ? 0 : d;
endmodule
