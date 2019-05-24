module stopwatch_counter(
   clock, min_higher_display, min_lower_display, s_higher_display,
   s_lower_display, ms_higher_display, ms_lower_display, key_start_pause,
   key_reset, key_freeze_resume
);
   parameter delay = 500000;  // 500000 cycles of a 50 MHz clock make 10 ms
   parameter two_ms_delay = 100000;
   input clock, key_start_pause, key_reset, key_freeze_resume;
   // Display registers are connected to the 7-segment displays and store
   // the digits when the display is freezed.
   output reg [3:0] min_higher_display, min_lower_display, s_higher_display,
      s_lower_display, ms_higher_display, ms_lower_display;

   reg [18:0] counter;           // count to 500000 before reset
   reg counting_enable, display_frozen;
   // registers for debouncing
   // Key signals are sampled at clock edge.
   reg [31:0] enable_count, freeze_count;
   // These registers keep counting even the display is freezed.
   reg [3:0] min_higher, min_lower, s_higher, s_lower, ms_higher, ms_lower;

   initial begin
      counter <= 0;
      min_higher <= 0;
      min_lower <= 0;
      s_higher <= 0;
      s_lower <= 0;
      ms_higher <= 0;
      ms_lower <= 0;
      counting_enable <= 0;
      display_frozen <= 0;
   end

   always @(posedge clock) begin
      enable_count = key_start_pause ? 0 : enable_count + 1;
      freeze_count = key_freeze_resume ? 0 : freeze_count + 1;

      // if a key is pressed for more than 2 ms
      if (enable_count == two_ms_delay)
         counting_enable = ~counting_enable;
      if (freeze_count == two_ms_delay)
         display_frozen = ~display_frozen;
         
      if (~key_reset) begin
         counter = 0;
         counting_enable = 0;
         display_frozen = 0;
         min_higher = 0;
         min_lower = 0;
         s_higher = 0;
         s_lower = 0;
         ms_higher = 0;
         ms_lower = 0;
      end else begin
         counter = counter + counting_enable;
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

      if (~display_frozen) begin
         min_higher_display = min_higher;
         min_lower_display = min_lower;
         s_higher_display = s_higher;
         s_lower_display = s_lower;
         ms_higher_display = ms_higher;
         ms_lower_display = ms_lower;
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
