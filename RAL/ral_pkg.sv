package ral_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import apb_pkg::*;    
  `include "uart_reg.sv"
  `include "uart_reg_block.sv"
  `include "uart_adapter.sv"
  typedef uart_adapter uart_adapter_t;

endpackage