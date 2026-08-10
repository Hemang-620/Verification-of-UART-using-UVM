class apb_agent extends uvm_agent;

  `uvm_component_utils(apb_agent)

  apb_cfg cfg_h;

  apb_driver    driver;
  apb_monitor   monitor;
  apb_sequencer sequencer;

  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db #(apb_cfg)::get(this,"","apb_cfg",cfg_h))
      `uvm_fatal(get_type_name(),"Unable to get apb_cfg")
    monitor = apb_monitor::type_id::create("monitor", this);

    if(cfg_h.is_active == UVM_ACTIVE)
    begin
      driver = apb_driver::type_id::create("driver", this);
      sequencer = apb_sequencer::type_id::create("sequencer", this);
    end

  endfunction

  virtual function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    if(cfg_h.is_active == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);

  endfunction

endclass