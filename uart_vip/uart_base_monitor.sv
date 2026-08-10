class uart_base_monitor extends uvm_monitor;

`uvm_component_utils(uart_base_monitor)

  uart_cfg cfg_h;

  virtual uart_if uart_vif;

  uvm_analysis_port #(uart_seq_item) mon_ap;

  function new(string name="uart_base_monitor",
               uvm_component parent=null);

    super.new(name,parent);

    mon_ap = new("mon_ap",this);

  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db #(uart_cfg)::get(this,"","uart_cfg",cfg_h))
      `uvm_fatal(get_type_name(),"Cannot get uart_cfg")

    uart_vif = cfg_h.uart_vif;

  endfunction


  task run_phase(uvm_phase phase);

    forever
      collect_frame();

  endtask


  //-------------------------------------------------------
  // Child classes override this
  //-------------------------------------------------------

  virtual function bit sample_line();

  endfunction


  //-------------------------------------------------------
  // Wait Start Bit
  //-------------------------------------------------------

  task wait_start_bit();

    forever begin

      @(posedge uart_vif.PCLK);

      if(sample_line()==0)
        break;

    end

    repeat(cfg_h.cycles_per_bit/2)
      @(posedge uart_vif.PCLK);
    
    if(sample_line() != 1'b0)

      `uvm_warning("UART_MON","False start bit detected");

  endtask


  //-------------------------------------------------------
  // Collect Frame
  //-------------------------------------------------------

  task collect_frame();

    uart_seq_item xtn;

    xtn = uart_seq_item::type_id::create("xtn");

    wait_start_bit();

    collect_data(xtn);

    if(cfg_h.parity_en)
      collect_parity(xtn);

    collect_stop_bits(xtn);

    xtn.wlen         = cfg_h.wlen;
    xtn.parity_en    = cfg_h.parity_en;
    xtn.even_parity  = cfg_h.even_parity;
    xtn.stop2        = cfg_h.stop2;

    mon_ap.write(xtn);

    `uvm_info(get_type_name(),
      $sformatf("\n%s",xtn.sprint()),
      UVM_LOW);

  endtask


  //-------------------------------------------------------
  // Collect Data
  //-------------------------------------------------------

  task collect_data(uart_seq_item xtn);

    int num_bits;

    case(cfg_h.wlen)

      2'b00: num_bits=5;
      2'b01: num_bits=6;
      2'b10: num_bits=7;
      2'b11: num_bits=8;

    endcase

    repeat(cfg_h.cycles_per_bit)
      @(posedge uart_vif.PCLK);

    for(int i=0;i<num_bits;i++) begin

      xtn.data[i]=sample_line();

       `uvm_info("UART_MON",$sformatf("Sampled DATA[%0d] = %0b",i,sample_line()),UVM_HIGH);

      repeat(cfg_h.cycles_per_bit)
        @(posedge uart_vif.PCLK);

    end

  endtask


  //-------------------------------------------------------
  // Collect Parity
  //-------------------------------------------------------

  task collect_parity(uart_seq_item xtn);

    repeat(cfg_h.cycles_per_bit)
      @(posedge uart_vif.PCLK);

      xtn.parity_bit = sample_line();
      `uvm_info("UART_MON",$sformatf("Sampled PARITY = %0b",xtn.parity_bit),UVM_HIGH);
  endtask


  //-------------------------------------------------------
  // Collect Stop
  //-------------------------------------------------------

  task collect_stop_bits(uart_seq_item xtn);

    repeat(cfg_h.cycles_per_bit)
      @(posedge uart_vif.PCLK);

      xtn.stop_bit1 = sample_line();
      `uvm_info("UART_MON",$sformatf("Sampled STOP[0] = %0b",xtn.stop_bit1),UVM_HIGH);

    if(cfg_h.stop2) begin

      repeat(cfg_h.cycles_per_bit)
        @(posedge uart_vif.PCLK);

      xtn.stop_bit2 = sample_line();

      `uvm_info("UART_MON",$sformatf("Sampled STOP[1] = %0b",xtn.stop_bit2), UVM_HIGH);
    end
    else begin
      xtn.stop_bit2 = 1'b1;
    end

  endtask

endclass