module stopwatch_counter(
   clock, min_higher, min_lower, s_higher, s_lower, ms_higher, ms_lower
);
   parameter delay = 500000;  // 500000 cycles of a 50 MHz clock make 10 ms
   input clock;
   output reg [3:0] min_higher, min_lower, s_higher, s_lower, ms_higher, ms_lower;
   reg [18:0] counter;        // count to 500000 before reset

   always @(posedge clock) begin
      counter = counter + 1'b1;
      if (counter == delay) begin
         counter = 0;
         ms_lower = ms_lower + 1'b1;

         if (ms_lower == 10) begin
            ms_lower = 0;
            ms_higher = ms_higher + 1'b1;

            if (ms_higher == 10) begin
               ms_higher = 0;
               s_lower = s_lower + 1'b1;

               if (s_lower == 10) begin
                  s_lower = 0;
                  s_higher = s_higher + 1'b1;

                  if (s_higher == 6) begin
                     s_higher = 0;
                     min_lower = min_lower + 1'b1;

                     if (min_lower == 10) begin
                        min_lower = 0;
                        min_higher = min_higher + 1'b1;

                        if (min_higher == 6)
                           min_higher = 0;
                     end
                  end
               end
            end
         end
      end
   end
endmodule

module ssd(digit, out);
   input [3:0] digit;
   output reg [6:0] out;
   always @(digit)
   case (digit)
      0: out <= 7'b1000000;
      1: out <= 7'b1111001;
      2: out <= 7'b0100100;
      3: out <= 7'b0110000;
      4: out <= 7'b0011001;
      5: out <= 7'b0010010;
      6: out <= 7'b0000010;
      7: out <= 7'b1111000;
      8: out <= 7'b0000000;
      9: out <= 7'b0010000;
      default: out <= 7'b1111111;
   endcase
endmodule
