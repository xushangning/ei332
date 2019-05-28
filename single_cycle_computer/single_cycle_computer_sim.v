`timescale 10ns/10ns

module single_cycle_computer_sim;
   reg clk, half_freq_clk, reset;
   single_cycle_computer computer(.resetn(reset), .clock(half_freq_clk), .mem_clk(clk));
   
   initial begin
      reset = 0;
      clk <= 0;
      half_freq_clk <= 0;
      #1 reset = 1;
   end
   
   always #1 clk <= ~clk;
   always @(posedge clk) half_freq_clk <= ~half_freq_clk;
endmodule
