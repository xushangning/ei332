/**
 * 32-bit D Flip-flop with enable port
 *
 * clrn: Clear on low
 */
module dffe32(
   input [31:0] d,
   input clk,
   input clrn,
   input e,
   output reg [31:0] q
);
   always @ (negedge clrn or posedge clk)
      if (clrn == 0)
         q <= 0;
      else if (e)
         q <= d;
endmodule
