module hpm_peripheral (
    input  logic clk,
    input  logic rst_n,
    // MMIO Interface
    input  logic cs,
    input  logic we,
    input  logic [4:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    // Probes (Inputs from CPU Trace)
    input  logic cpu_retired_inst,
    input  logic cpu_mem_rd,
    input  logic cpu_mem_wr
);

    // Register Map
    // 0x00: Control (Bit 0=Enable, Bit 1=Reset)
    // 0x04: Cycle Counter
    // 0x08: Instruction Counter
    // 0x0C: Mem Read Counter
    // 0x10: Mem Write Counter

    logic [31:0] r_ctrl;
    logic [31:0] r_cycle_cnt;
    logic [31:0] r_inst_cnt;
    logic [31:0] r_mem_rd_cnt;
    logic [31:0] r_mem_wr_cnt;

    // Control signal aliases
    logic hpm_enable, hpm_clear;
    assign hpm_enable = r_ctrl[0];
    assign hpm_clear  = r_ctrl[1];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_ctrl       <= 32'd0;
            r_cycle_cnt  <= 32'd0;
            r_inst_cnt   <= 32'd0;
            r_mem_rd_cnt <= 32'd0;
            r_mem_wr_cnt <= 32'd0;
        end else begin
            // Write Logic for Control Register
            if (cs && we && (addr[4:0] == 5'h00)) begin
                r_ctrl <= wdata;
            end else begin
                // Self-clearing reset bit
                r_ctrl[1] <= 1'b0; 
            end

            // Counter Logic
            if (hpm_clear) begin
                r_cycle_cnt  <= 32'd0;
                r_inst_cnt   <= 32'd0;
                r_mem_rd_cnt <= 32'd0;
                r_mem_wr_cnt <= 32'd0;
            end else if (hpm_enable) begin
                r_cycle_cnt <= r_cycle_cnt + 1;
                if (cpu_retired_inst) 
                    r_inst_cnt <= r_inst_cnt + 1;
                if (cpu_mem_rd)       
                    r_mem_rd_cnt <= r_mem_rd_cnt + 1;
                if (cpu_mem_wr)       
                    r_mem_wr_cnt <= r_mem_wr_cnt + 1;
            end
        end
    end

    // Read Logic
    always_comb begin
        if (cs) begin
            case (addr[4:0])
                5'h00: rdata = r_ctrl;
                5'h04: rdata = r_cycle_cnt;
                5'h08: rdata = r_inst_cnt;
                5'h0C: rdata = r_mem_rd_cnt;
                5'h10: rdata = r_mem_wr_cnt;
                default: rdata = 32'd0;
            endcase
        end else begin
            rdata = 32'd0;
        end
    end
endmodule