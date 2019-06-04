module freq_divider(input clk_50m, output reg out_clk);
   parameter delay = 12_499_999;
   reg [24:0] counter = 0;

   initial out_clk <= 0;

   always @(posedge clk_50m)
      if (counter < delay)
         counter <= counter + 1'b1;
      else begin
         counter <= 0;
         out_clk <= ~out_clk;
      end
endmodule

module divide_by_two(input in_clk, output reg out_clk);
   initial out_clk = 0;

   always @(posedge in_clk) out_clk <= ~out_clk;
endmodule
