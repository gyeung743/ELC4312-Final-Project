`ifndef _CHU_IO_MAP_INCLUDED
`define _CHU_IO_MAP_INCLUDED

`define SYS_CLK_FREQ 100

`define BRIDGE_BASE 0xc0000000

// Slot Definitions
`define S0_SYS_TIMER  0
`define S1_UART1      1
`define S2_LED        2
`define S3_SW         3
`define S4_USER       4
`define S5_HPM        5
`define S6_PWM        6
`define S7_BTN        7
`define S8_SSEG       8
`define S9_SPI        9
`define S10_I2C      10
`define S11_PS2      11
`define S12_DDFS     12
`define S13_ADSR     13

`define V0_SYNC      0
`define V1_MOUSE     1
`define V2_OSD       2
`define V3_GHOST     3
`define V4_USER4     4
`define V5_USER5     5
`define V6_GRAY      6
`define V7_BAR       7

`define FRAME_OFFSET 0x00c00000
`define FRAME_BASE   BRIDGE_BASE+FRAME_OFFSET

`endif //_CHU_IO_MAP