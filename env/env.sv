class env extends uvm_env;

  `uvm_component_utils(env)

  env_cfg cfg_h;

  apb_agent          apb_agent_h;
  uart_agent         uart_agent_h;
  virtual_sequencer  v_seqr_h;
  uart_scoreboard    sb_h;
  uart_reg_block ral_h;
  uart_adapter adapter_h;

  function new(string name="env", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(env_cfg)::get(this,"","env_cfg",cfg_h))
      `uvm_fatal(get_type_name(),"Unable to get env_cfg")

    //-------------------------------------------------------
    // Pass configuration objects to agents and children
    //-------------------------------------------------------

    uvm_config_db#(apb_cfg)::set(
      this,
      "apb_agent_h*",
      "apb_cfg",
      cfg_h.apb_cfg_h
    );

    uvm_config_db#(uart_cfg)::set(
      this,
      "uart_agent_h*",
      "uart_cfg",
      cfg_h.uart_cfg_h
    );

    //-------------------------------------------------------
    // Create Components
    //-------------------------------------------------------

    apb_agent_h = apb_agent::type_id::create("apb_agent_h", this);
    uart_agent_h = uart_agent::type_id::create("uart_agent_h", this);
    v_seqr_h = virtual_sequencer::type_id::create("v_seqr_h", this);
    sb_h = uart_scoreboard::type_id::create("sb_h", this);


    ral_h     = cfg_h.ral_h;
   adapter_h = cfg_h.adapter_h;

   ral_h.print();

  endfunction


  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(cfg_h.apb_cfg_h.is_active == UVM_ACTIVE)
      v_seqr_h.apb_seqr = apb_agent_h.sequencer;

    if(cfg_h.uart_cfg_h.is_active == UVM_ACTIVE)
      v_seqr_h.uart_seqr = uart_agent_h.sequencer;

    v_seqr_h.uart_cfg_h = cfg_h.uart_cfg_h;
    v_seqr_h.ral_h = ral_h;

    apb_agent_h.monitor.mon_ap.connect(sb_h.apb_imp);

    uart_agent_h.tx_monitor.mon_ap.connect(sb_h.tx_imp);
    uart_agent_h.rx_monitor.mon_ap.connect(sb_h.rx_imp);

    ral_h.default_map.set_sequencer(apb_agent_h.sequencer,adapter_h);
    ral_h.default_map.set_auto_predict(1);

  endfunction

endclass