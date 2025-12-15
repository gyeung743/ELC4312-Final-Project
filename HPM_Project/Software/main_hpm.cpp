#include "chu_init.h"
#include "gpio_cores.h"
#include "hpm_driver.h"

// Instantiate the HPM Core at Slot 5
HpmCore hpm(get_slot_addr(BRIDGE_BASE, S5_HPM));

// Benchmark 1: Arithmetic
// 1,000,000 iterations
void test_arithmetic() {
    uart.disp("\r\n[Running Arithmetic Benchmark]...\r\n");
    volatile int sum = 0;
    hpm.reset();
    hpm.start();
    
    for(int i=0; i<1000000; i++) {
        sum += i;
        sum = sum * 3;
        sum = sum / 3; 
    }
    
    hpm.stop();
    hpm.print_stats(uart);
}

// Benchmark 2: Memory
// Repeat copy 100,000 times
void test_memory() {
    uart.disp("\r\n[Running Memory Benchmark]...\r\n");
    
    volatile int array_a[100];
    volatile int array_b[100];
    
    hpm.reset();
    hpm.start();
    
    // Outer loop to force duration
    for(int k=0; k<100000; k++) {
        // Inner loop: Memory stress test
        for(int i=0; i<100; i++) {
            array_a[i] = i;        
            array_b[i] = array_a[i]; 
        }
    }
    
    hpm.stop();
    hpm.print_stats(uart);
}

int main() {    
    uart.disp("\r\n\r\n--------------------------------\r\n");
    uart.disp("   HPM: Ready   \r\n");
    uart.disp("--------------------------------\r\n");
    uart.disp("> Press 'a' for Arithmetic Test\r\n");
    uart.disp("> Press 'm' for Memory Test\r\n");

    while(1) {
        int data = uart.rx_byte();
        
        if (data != -1) {
            char c = (char)data;
            uart.disp(c); 
            uart.disp("\r\n");

            if (c == 'a' || c == 'A') {
                test_arithmetic();
                uart.disp("> Press 'a' or 'm' to run again\r\n");
            } 
            else if (c == 'm' || c == 'M') {
                test_memory();
                uart.disp("> Press 'a' or 'm' to run again\r\n");
            }
        }
    }
    
    return 0;

}
