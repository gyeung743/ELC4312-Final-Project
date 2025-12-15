`include "chu_io_map.svh"

module mmio_sys_vanilla 
#(
   parameter N_SW = 16,
   parameter N_LED = 16
)	
(
   input logic clk,
   input logic reset,
   // FPro bus 
   input logic mmio_cs,
   input logic mmio_wr,
   input logic mmio_rd,
   input logic [20:0] mmio_addr, 
   input logic [31:0] mmio_wr_data,
   output logic [31:0] mmio_rd_data,
   input  logic [N_SW-1:0] sw,
   output logic [N_LED-1:0] led,
   // UART
   input  logic rx,
   output logic tx,
   // Probes
   input logic probe_inst,
   input logic probe_mem_rd,
   input logic probe_mem_wr
);

   logic [63:0] mem_rd_array;
   logic [63:0] mem_wr_array;
   logic [63:0] cs_array;
   logic [4:0] reg_addr_array [63:0];
   logic [31:0] rd_data_array [63:0]; 
   logic [31:0] wr_data_array [63:0];

   // Instantiate MMIO controller 
   chu_mmio_controller ctrl_unit
   (.clk(clk),
    .reset(reset),
    .mmio_cs(mmio_cs),
    .mmio_wr(mmio_wr),
    .mmio_rd(mmio_rd),
    .mmio_addr(mmio_addr), 
    .mmio_wr_data(mmio_wr_data),
    .mmio_rd_data(mmio_rd_data),
    // Slot interface
    .slot_cs_array(cs_array),
    .slot_mem_rd_array(mem_rd_array),
    .slot_mem_wr_array(mem_wr_array),
    .slot_reg_addr_array(reg_addr_array),
    .slot_rd_data_array(rd_data_array), 
    .slot_wr_data_array(wr_data_array)
    );

   // Slot 0: System Timer 
   chu_timer timer_slot0 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S0_SYS_TIMER]),
    .read(mem_rd_array[`S0_SYS_TIMER]),
    .write(mem_wr_array[`S0_SYS_TIMER]),
    .addr(reg_addr_array[`S0_SYS_TIMER]),
    .rd_data(rd_data_array[`S0_SYS_TIMER]),
    .wr_data(wr_data_array[`S0_SYS_TIMER])
    );

   // Slot 1: UART
   chu_uart uart_slot1 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S1_UART1]),
    .read(mem_rd_array[`S1_UART1]),
    .write(mem_wr_array[`S1_UART1]),
    .addr(reg_addr_array[`S1_UART1]),
    .rd_data(rd_data_array[`S1_UART1]),
    .wr_data(wr_data_array[`S1_UART1]), 
    .tx(tx),
    .rx(rx)
    );

   // Slot 2: GPO 
   chu_gpo #(.W(12)) gpo_slot2 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S2_LED]),
    .read(mem_rd_array[`S2_LED]),
    .write(mem_wr_array[`S2_LED]),
    .addr(reg_addr_array[`S2_LED]),
    .rd_data(rd_data_array[`S2_LED]),
    .wr_data(wr_data_array[`S2_LED]),
    .dout(led[15:4])
    );

   // Slot 3: GPI 
   chu_gpi #(.W(N_SW)) gpi_slot3 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S3_SW]),
    .read(mem_rd_array[`S3_SW]),
    .write(mem_wr_array[`S3_SW]),
    .addr(reg_addr_array[`S3_SW]),
    .rd_data(rd_data_array[`S3_SW]),
    .wr_data(wr_data_array[`S3_SW]),
    .din(sw)
    );

   // Slot 4: Quad Blinker Core
    quad_pulse_core blinker_slot4 (
      .clk(clk),
      .reset(reset),
      .cs(cs_array[`S4_USER]),
      .wr(mem_wr_array[`S4_USER]),
      .addr(reg_addr_array[`S4_USER]), 
      .wr_data(wr_data_array[`S4_USER]),
      .led_vec(led[3:0])
    );
    
   // Slot 5: Hardware Performance Monitor (HPM)
   hpm_peripheral hpm_slot5 (
       .clk(clk),
       .rst_n(!reset),
       .cs(cs_array[`S5_HPM]),
       .we(mem_wr_array[`S5_HPM]),
       .addr(reg_addr_array[`S5_HPM]),
       .wdata(wr_data_array[`S5_HPM]),
       .rdata(rd_data_array[`S5_HPM]),
       .cpu_retired_inst(probe_inst),
       .cpu_mem_rd(probe_mem_rd),
       .cpu_mem_wr(probe_mem_wr)
   );

   // 0's to all unused slot rd_data signals
   generate
      genvar i;
      for (i=6; i<64; i=i+1) begin:  unused_slot_gen
         assign rd_data_array[i] = 32'hffffffff;
      end
   endgenerate
endmodule