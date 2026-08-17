`timescale 1ns/1ps

module tb_top;

  //---------------------------------------------------------
  // Imports
  //---------------------------------------------------------

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import apb_pkg::*;
  import uart_pkg::*;
  import env_pkg::*;
  import test_pkg::*;

  //---------------------------------------------------------
  // Clock
  //---------------------------------------------------------

  bit PCLK;

  initial
    PCLK = 0;

  always #5 PCLK = ~PCLK;

  //---------------------------------------------------------
  // Interfaces
  //---------------------------------------------------------

  apb_if  apb_if_h(PCLK);
  uart_if uart_if_h(PCLK);

  //assign uart_if_h.UARTRXD = uart_if_h.UARTTXD;

  //---------------------------------------------------------
  // Reset
  //---------------------------------------------------------

  initial begin

    apb_if_h.PRESETn  = 0;
    uart_if_h.PRESETn = 0;

    repeat(5) @(posedge PCLK);

    apb_if_h.PRESETn  = 1;
    uart_if_h.PRESETn = 1;
    $display("[%0t] RESET RELEASED", $time);

  end

  //---------------------------------------------------------
  // DUT
  //---------------------------------------------------------

  uart_top_apb dut (

    .PCLK       (PCLK),
    .PRESETn    (apb_if_h.PRESETn),

    .PSEL       (apb_if_h.PSEL),
    .PENABLE    (apb_if_h.PENABLE),
    .PWRITE     (apb_if_h.PWRITE),
    .PADDR      (apb_if_h.PADDR),
    .PWDATA     (apb_if_h.PWDATA),
    .PRDATA     (apb_if_h.PRDATA),
    .PREADY     (apb_if_h.PREADY),
    .PSLVERR    (apb_if_h.PSLVERR),

    .UARTTXD    (uart_if_h.UARTTXD),
    .UARTRXD    (uart_if_h.UARTRXD),

    .UARTRXINTR (uart_if_h.UARTRXINTR),
    .UARTTXINTR (uart_if_h.UARTTXINTR),
    .UARTRTINTR (uart_if_h.UARTRTINTR),
    .UARTEINTR  (uart_if_h.UARTEINTR)

  );

  //---------------------------------------------------------
  // UVM Configuration
  //---------------------------------------------------------

  initial begin

    uvm_config_db #(virtual apb_if)::set(
      null,
      "*",
      "apb_vif",
      apb_if_h
    );

    uvm_config_db #(virtual uart_if)::set(
      null,
      "*",
      "uart_vif",
      uart_if_h
    );

    run_test();

  end

endmodule