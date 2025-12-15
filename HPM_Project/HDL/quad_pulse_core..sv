`timescale 1ns / 1ps

module quad_pulse_core
   (
    input logic clk,
    input logic reset,
    input logic cs,
    input logic wr,
    input logic [4:0] addr, 
    input logic [31:0] wr_data,
    output logic [3:0] led_vec
   );

   genvar i;
   generate
      for (i = 0; i < 4; i = i + 1) begin : blinker_gen
         pulse_mmio_interface unit
         (
            .clk(clk),
            .reset(reset),
            .cs(cs),
            .wr(wr && (addr[4:2] == i)), 
            .addr(addr[1:0]),
            .wr_data(wr_data),
            .led_out(led_vec[i])
         );
      end
   endgenerate

endmodule