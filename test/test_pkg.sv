package test_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import apb_pkg::*;
  import uart_pkg::*;
  import env_pkg::*;
  import ral_pkg::*;

  //---------------------------------------------------------
  // Register Definitions
  //---------------------------------------------------------

  `include "uart_reg_defs.svh"

  //---------------------------------------------------------
  // APB Sequences
  //---------------------------------------------------------

  `include "apb_base_sequence.sv"
  `include "apb_write_seq.sv"
  `include "apb_read_seq.sv"

  //---------------------------------------------------------
  // UART Sequences
  //---------------------------------------------------------

  `include "uart_base_sequence.sv"
  `include "uart_tx_sequence.sv"

  //---------------------------------------------------------
  // Virtual Sequences
  //---------------------------------------------------------

  `include "base_virtual_sequence.sv"
  `include "uart_basic_tx_vseq.sv"
  `include "uart_basic_rx_vseq.sv"
  `include "uart_configuration_vseq.sv"
  `include "uart_loopback_vseq.sv"
  `include "uart_interrupt_error_vseq.sv"
  `include "uart_register_rd_vseq.sv"
  `include "uart_register_write_read_vseq.sv"
  `include "uart_tx_interrupt_vseq.sv"
  //---------------------------------------------------------
  // Tests
  //---------------------------------------------------------
 
  
  `include "base_test.sv"
  `include "basic_tx_test.sv"
  `include "basic_rx_test.sv"
  `include "configuration_test.sv"
  `include "loopback_test.sv"
  `include "uart_interrupt_error_test.sv"
  `include "uart_register_rd_test.sv"
  `include "uart_register_write_read_test.sv"
  `include "uart_tx_interrupt_test.sv"
endpackage