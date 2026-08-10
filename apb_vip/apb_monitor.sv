class apb_monitor extends uvm_monitor;

  `uvm_component_utils(apb_monitor)

  apb_cfg cfg_h;
  virtual apb_if apb_vif;

  uvm_analysis_port #(apb_seq_item) mon_ap;

  function new(string name = "apb_monitor",uvm_component parent = null);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db #(apb_cfg)::get(this,"","apb_cfg",cfg_h))
      `uvm_fatal(get_type_name(),"Unable to get apb_cfg")
      apb_vif = cfg_h.apb_vif;
  endfunction

  task run_phase(uvm_phase phase);

    forever begin
      collect_transfer();
    end

  endtask

  task collect_transfer();

    apb_seq_item xtn;

    @(posedge apb_vif.PCLK);

    if(apb_vif.PSEL && apb_vif.PENABLE)
    begin

      xtn = apb_seq_item::type_id::create("xtn");

      xtn.pwrite = apb_vif.PWRITE;
      xtn.paddr  = apb_vif.PADDR;

      if(apb_vif.PWRITE)
        xtn.pwdata = apb_vif.PWDATA;
      else
        xtn.prdata = apb_vif.PRDATA;

      `uvm_info("APB MONITOR",$sformatf("APB MONITOR CAPTURED:\n%s",xtn.sprint()),UVM_LOW)
      mon_ap.write(xtn);

    end

  endtask

endclass