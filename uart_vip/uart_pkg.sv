package uart_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "uart_seq_item.sv"

  `include "uart_cfg.sv"

  `include "uart_sequencer.sv"

  `include "uart_driver.sv"

  `include "uart_base_monitor.sv"

  `include "uart_tx_monitor.sv"

  `include "uart_rx_monitor.sv"

  `include "uart_agent.sv"

endpackage