module alu (a,b,aluc,s,z);
   input [31:0] a,b;
   input [3:0] aluc;
   output reg [31:0] s;
   output reg z;
   always @ (a or b or aluc) begin
      casex (aluc)
         4'bx000: s = a + b;
         4'bx100: s = a - b;
         4'bx001: s = a & b;
         4'bx101: s = a | b;
         4'bx010: s = a ^ b;
         4'bx110: s = {b[15:0], 15'b0};    // lui
         4'b0011: s = b << a;
         4'b0111: s = b >> a;
         4'b1111: s = $signed(b) >>> a;      // sra
         default: s = 0;
      endcase
      z = (s == 0);
   end
endmodule
