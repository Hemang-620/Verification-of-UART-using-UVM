class uart_rx_monitor extends uart_base_monitor;

  `uvm_component_utils(uart_rx_monitor)

  function new(string name="uart_rx_monitor",
               uvm_component parent=null);

    super.new(name,parent);

  endfunction


  virtual function bit sample_line();

    return uart_vif.UARTRXD;

  endfunction

endclass