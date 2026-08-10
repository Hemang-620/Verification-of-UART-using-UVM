class uart_agent extends uvm_agent;

  `uvm_component_utils(uart_agent)

  uart_cfg cfg_h;

  uart_driver    driver;
  uart_tx_monitor  tx_monitor;
  uart_rx_monitor  rx_monitor;
  uart_sequencer sequencer;

  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db #(uart_cfg)::get(this,"","uart_cfg",cfg_h))
      `uvm_fatal(get_type_name(),"Unable to get uart_cfg")
    tx_monitor = uart_tx_monitor::type_id::create("tx_monitor", this);
    rx_monitor = uart_rx_monitor::type_id::create("rx_monitor", this);

    if(cfg_h.is_active == UVM_ACTIVE)
    begin
      uvm_config_db#(uart_cfg)::set(this,"sequencer","uart_cfg",cfg_h);
      driver = uart_driver::type_id::create("driver", this);
      sequencer = uart_sequencer::type_id::create("sequencer", this);
    end

  endfunction

  virtual function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    if(cfg_h.is_active == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);

  endfunction

endclass