`timescale 10ns/10ns

module test_freq_divider;
   reg clk = 0;
   wire out;
   
   always #2 clk = ~clk;
   
   freq_divider inst(clk, out);
endmodule
