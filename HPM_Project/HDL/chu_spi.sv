// Based on Listing 16.1 and 16.2 from Chu, Pong P. - FPGA Prototyping by SystemVerilog Examples

//======================================================================
// Module: spi
// Description: Basic SPI controller FSMD
//======================================================================
module spi
   (
    input  logic clk, reset,
    input  logic [7:0] din,
    input  logic [15:0] dvsr,  // divisor for SPI clock frequency
    input  logic start, cpol, cpha,
    output logic [7:0] dout,
    output logic spi_done_tick, ready,
    output logic sclk,
    input  logic miso,
    output logic mosi
   );

   // fsm state type
   typedef enum {idle, cpha_delay, p0, p1} state_type;

   // signal declaration
   state_type state_reg, state_next;
   logic p_clk;
   logic [15:0] c_reg, c_next;
   logic spi_clk_reg, ready_i, spi_done_tick_i;
   logic spi_clk_next;
   logic [2:0] n_reg, n_next;
   logic [7:0] si_reg, si_next;
   logic [7:0] so_reg, so_next;

   // body
   // fsmd for transmitting one byte
   // register
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         state_reg <= idle;
         si_reg <= 0;
         so_reg <= 0;
         n_reg <= 0;
         c_reg <= 0;
         spi_clk_reg <= 0;
      end
      else begin
         state_reg <= state_next;
         si_reg <= si_next;
         so_reg <= so_next;
         n_reg <= n_next;
         c_reg <= c_next;
         spi_clk_reg <= spi_clk_next;
      end

   // next-state logic
   always_comb
   begin
      state_next = state_reg; // default state: the same
      ready_i = 0;
      spi_done_tick_i = 0;
      si_next = si_reg;
      so_next = so_reg;
      n_next = n_reg;
      c_next = c_reg;
      
      case (state_reg)
         idle: begin
            ready_i = 1;
            if (start) begin
               so_next = din;
               n_next = 0;
               c_next = 0;
               if (cpha)
                  state_next = cpha_delay;
               else
                  state_next = p0;
            end
         end

         cpha_delay: begin
            if (c_reg == dvsr) begin
               state_next = p0;
               c_next = 0;
            end
            else
               c_next = c_reg + 1;
         end

         p0: begin
            if (c_reg == dvsr) begin // sclk 0-to-1 transition
               state_next = p1;
               si_next = {si_reg[6:0], miso}; // shift in
               c_next = 0;
            end
            else
               c_next = c_reg + 1;
         end

         p1: begin
            if (c_reg == dvsr) begin
               if (n_reg == 7) begin
                  spi_done_tick_i = 1;
                  state_next = idle;
               end
               else begin
                  so_next = {so_reg[6:0], 1'b0}; // shift out
                  state_next = p0;
                  n_next = n_reg + 1;
                  c_next = 0;
               end
            end
            else
               c_next = c_reg + 1;
         end
      endcase
   end

   assign ready = ready_i;
   assign spi_done_tick = spi_done_tick_i;

   // lookahead output decoding
   assign p_clk = (state_next == p1 && ~cpha) || (state_next == p0 && cpha);
   assign spi_clk_next = (cpol) ? ~p_clk : p_clk;

   // output
   assign dout = si_reg;
   assign mosi = so_reg[7];
   assign sclk = spi_clk_reg;

endmodule

//======================================================================
// Module: chu_spi
// Description: MMIO Wrapper for the SPI controller
//======================================================================
module chu_spi
   #(parameter S = 1) // width (# bits) of output port (number of slaves)
   (
    input  logic clk,
    input  logic reset,
    // slot interface
    input  logic cs,
    input  logic read,
    input  logic write,
    input  logic [4:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data,
    // external signal
    output logic spi_sclk,
    output logic spi_mosi,
    input  logic spi_miso,
    output logic [S-1:0] spi_ss_n
   );

   // signal declaration
   logic wr_en, wr_ss, wr_spi, wr_ctrl;
   logic [17:0] ctrl_reg;
   logic [S-1:0] ss_n_reg;
   logic [7:0] spi_out;
   logic spi_ready, cpol, cpha;
   logic [15:0] dvsr;

   // instantiate spi controller
   spi spi_unit(
      .clk(clk),
      .reset(reset),
      .din(wr_data[7:0]),
      .dvsr(dvsr),
      .start(wr_spi),
      .cpol(cpol),
      .cpha(cpha),
      .dout(spi_out),
      .sclk(spi_sclk),
      .miso(spi_miso),
      .mosi(spi_mosi),
      .spi_done_tick(),
      .ready(spi_ready)
   );

   // registers
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         ctrl_reg <= 18'h0_0200; // default (to get 50KHz sclk approx)
         ss_n_reg <= {S{1'b1}};  // de-assert all ss_n
      end
      else begin
         if (wr_ctrl)
            ctrl_reg <= wr_data[17:0];
         if (wr_ss)
            ss_n_reg <= wr_data[S-1:0];
      end

   // decoding
   assign wr_en = cs && write;
   assign wr_ss = wr_en && addr[1:0]==2'b01;
   assign wr_spi = wr_en && addr[1:0]==2'b10;
   assign wr_ctrl = wr_en && addr[1:0]==2'b11;

   // control signals
   assign dvsr = ctrl_reg[15:0];
   assign cpol = ctrl_reg[16];
   assign cpha = ctrl_reg[17];
   assign spi_ss_n = ss_n_reg;

   // read multiplexing
   assign rd_data = {23'b0, spi_ready, spi_out};

endmodule