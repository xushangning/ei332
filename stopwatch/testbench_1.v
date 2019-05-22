module tb;
   reg clk = 0, start_pause = 1, reset = 1;
   wire enable;
   wire [3:0] min_higher, min_lower, s_higher, s_lower, ms_higher, ms_lower;
   
   stopwatch_counter sc(
      clk, min_higher, min_lower, s_higher, s_lower,
      ms_higher, ms_lower, start_pause, reset, enable
   );
   
   always #5 clk = ~clk;
   
   initial begin
      #200 start_pause = 0;
      #201 start_pause = 1;
      $monitor($time, " Output enable = %d", enable);
   end

endmodule
