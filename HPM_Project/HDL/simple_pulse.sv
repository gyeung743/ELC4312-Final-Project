`timescale 1ns / 1ps

module simple_pulse
   #(
    parameter CNT_MAX = 100_000
   )
   (
    input logic clk,
    input logic reset,
    input logic [15:0] period_ms,
    output logic pulse_out
   );

   logic [31:0] ms_counter;
   logic [31:0] tick_counter;
   logic state_reg;
   
   always_ff @(posedge clk, posedge reset) begin
      if (reset) begin
         ms_counter <= 0;
         tick_counter <= 0;
         state_reg <= 0;
      end else begin
         if (period_ms != 0) begin
            if (tick_counter >= CNT_MAX) begin
               tick_counter <= 0;
               if (ms_counter >= period_ms) begin
                  ms_counter <= 0;
                  state_reg <= ~state_reg;
               end else begin
                  ms_counter <= ms_counter + 1;
               end
            end else begin
               tick_counter <= tick_counter + 1;
            end
         end else begin
            state_reg <= 0;
         end
      end
   end

   assign pulse_out = state_reg;

endmodule