`ifndef UART_REG_DEFS_SVH
`define UART_REG_DEFS_SVH

//=========================================================
// UART Register Offsets
//=========================================================

`define UARTDR        32'h000
`define UARTRSR       32'h004
`define UARTECR       32'h004
`define UARTFR        32'h018
`define UARTIBRD      32'h024
`define UARTFBRD      32'h028
`define UARTLCR_H     32'h02C
`define UARTCR        32'h030
`define UARTIFLS      32'h034
`define UARTIMSC      32'h038
`define UARTRIS       32'h03C
`define UARTMIS       32'h040
`define UARTICR       32'h044

//=========================================================
// UARTCR Register Bit Positions
//=========================================================

`define UARTCR_UARTEN_POS    0
`define UARTCR_LBE_POS       7
`define UARTCR_TXE_POS       8
`define UARTCR_RXE_POS       9

//=========================================================
// UARTCR Register Bit Masks
//=========================================================

`define UARTCR_UARTEN_MSK    (1 << `UARTCR_UARTEN_POS)
`define UARTCR_LBE_MSK       (1 << `UARTCR_LBE_POS)
`define UARTCR_TXE_MSK       (1 << `UARTCR_TXE_POS)
`define UARTCR_RXE_MSK       (1 << `UARTCR_RXE_POS)

//=========================================================
// UARTLCR_H Register Bit Positions
//=========================================================

`define UARTLCR_H_BRK_POS        0
`define UARTLCR_H_PEN_POS        1
`define UARTLCR_H_EPS_POS        2
`define UARTLCR_H_STP2_POS       3
`define UARTLCR_H_FEN_POS        4
`define UARTLCR_H_WLEN_LSB       5
`define UARTLCR_H_WLEN_MSB       6
`define UARTLCR_H_SPS_POS        7

//=========================================================
// UARTLCR_H Register Bit Masks
//=========================================================

`define UARTLCR_H_BRK_MSK        (1 << `UARTLCR_H_BRK_POS)
`define UARTLCR_H_PEN_MSK        (1 << `UARTLCR_H_PEN_POS)
`define UARTLCR_H_EPS_MSK        (1 << `UARTLCR_H_EPS_POS)
`define UARTLCR_H_STP2_MSK       (1 << `UARTLCR_H_STP2_POS)
`define UARTLCR_H_FEN_MSK        (1 << `UARTLCR_H_FEN_POS)
`define UARTLCR_H_SPS_MSK        (1 << `UARTLCR_H_SPS_POS)

//=========================================================
// UART Word Length Encoding
//=========================================================

`define UART_WLEN_5              2'b00
`define UART_WLEN_6              2'b01
`define UART_WLEN_7              2'b10
`define UART_WLEN_8              2'b11

//=========================================================
// Default UART Configuration Values
//=========================================================

`define UART_ENABLE_TX_RX \
        (`UARTCR_UARTEN_MSK | \
         `UARTCR_TXE_MSK    | \
         `UARTCR_RXE_MSK)

`define UART_DISABLE        32'h00000000

`endif