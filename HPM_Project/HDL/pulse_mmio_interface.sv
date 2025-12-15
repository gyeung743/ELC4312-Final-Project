`timescale 1ns / 1ps

module pulse_mmio_interface
   (
    input logic clk,
    input logic reset,
    input logic cs,
    input logic wr,
    input logic [1:0] addr,
    input logic [31:0] wr_data,
    output logic led_out
   );

   logic [15:0] period_reg;
   logic wr_en;

   assign wr_en = cs && wr && (addr == 2'b00);

   always_ff @(posedge clk, posedge reset) begin
      if (reset)
         period_reg <= 0;
      else if (wr_en)
         period_reg <= wr_data[15:0];
   end

   simple_pulse #(.CNT_MAX(100_000)) pulse_unit
   (
      .clk(clk),
      .reset(reset),
      .period_ms(period_reg),
      .pulse_out(led_out)
   );

endmodule