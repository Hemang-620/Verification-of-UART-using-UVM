class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  env_cfg  env_cfg_h;
  apb_cfg  apb_cfg_h;
  uart_cfg uart_cfg_h;

  virtual apb_if  apb_vif;
  virtual uart_if uart_vif;

  uart_reg_block ral_h;
  uart_adapter   adapter_h;

  env env_h;

  function new(string name="base_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    //-------------------------------------------------------
    // Create Config Objects
    //-------------------------------------------------------

    env_cfg_h  = env_cfg::type_id::create("env_cfg_h");
    apb_cfg_h  = apb_cfg::type_id::create("apb_cfg_h");
    uart_cfg_h = uart_cfg::type_id::create("uart_cfg_h");
    //------------------------------------
    // Create Register Model
    //------------------------------------

    ral_h = uart_reg_block::type_id::create("ral_h");
    ral_h.build();
    ral_h.lock_model();
    ral_h.reset();

    adapter_h = uart_adapter::type_id::create("adapter_h");

    //-------------------------------------------------------
    // Get Virtual Interfaces
    //-------------------------------------------------------

    if(!uvm_config_db#(virtual apb_if)::get(this,"","apb_vif",apb_vif))
      `uvm_fatal("BASE_TEST","Unable to get APB Virtual Interface")

    if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif))
      `uvm_fatal("BASE_TEST","Unable to get UART Virtual Interface")

    //-------------------------------------------------------
    // Fill Configuration Objects
    //-------------------------------------------------------

    apb_cfg_h.apb_vif   = apb_vif;
    uart_cfg_h.uart_vif = uart_vif;

    apb_cfg_h.is_active  = UVM_ACTIVE;
    uart_cfg_h.is_active = UVM_ACTIVE;

    env_cfg_h.apb_cfg_h  = apb_cfg_h;
    env_cfg_h.uart_cfg_h = uart_cfg_h;

    env_cfg_h.ral_h      = ral_h;
    env_cfg_h.adapter_h  = adapter_h;

    //-------------------------------------------------------
    // Pass env_cfg to Environment
    //-------------------------------------------------------

    uvm_config_db#(env_cfg)::set(
      this,
      "*",
      "env_cfg",
      env_cfg_h
    );

    //-------------------------------------------------------
    // Create Environment
    //-------------------------------------------------------

    env_h = env::type_id::create("env_h", this);

  endfunction

endclass