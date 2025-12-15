#ifndef HPM_DRIVER_H
#define HPM_DRIVER_H

#include "chu_io_map.h"
#include "uart_core.h" 
#include <stdint.h>

// Base address: Slot 5
#define HPM_BASE_ADDR  0xC0000500 

struct HPM_Regs {
    volatile uint32_t CTRL;       // 0x00
    volatile uint32_t REG_04;     // 0x04
    volatile uint32_t INST;       // 0x08
    volatile uint32_t MEM_RD;     // 0x0C
    volatile uint32_t REAL_TIME;  // 0x10
};

class HpmCore {
    HPM_Regs *regs;
public:
    HpmCore(uint32_t core_base_addr) {
        regs = (HPM_Regs *) core_base_addr;
    }

    void start() { regs->CTRL = 1; }
    void stop()  { regs->CTRL = 0; }
    void reset() { regs->CTRL = 2; }
    
    void print_stats(UartCore &uart) {
        // Swap: Reading the working counter (0x10) as Time/Cycles
        uint32_t total_time = regs->REAL_TIME; 
        
        uart.disp("\r\n=== HPM Benchmark Report ===\r\n");
        
        // Display the "Mem Write" value as "Total Cycles"
        uart.disp("Total Cycles:  "); uart.disp((int)total_time); uart.disp("\r\n");
        
        // Calculate Time in microseconds (100 MHz clock = 10ns period)
        // Time = Cycles / 100
        uint32_t time_us = total_time / 100;
        uart.disp("Time (us):     "); uart.disp((int)time_us); uart.disp("\r\n");

        uart.disp("============================\r\n");
    }
};

#endif