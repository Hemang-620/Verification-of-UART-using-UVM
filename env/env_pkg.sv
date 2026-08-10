package env_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import apb_pkg::*;
  import uart_pkg::*;
  import ral_pkg::*;   

 

  `include "env_cfg.sv"

  `include "virtual_sequencer.sv"


  `include "uart_scoreboard.sv"
  `include "env.sv"
  
endpackage