class uart_driver extends uvm_driver #(uart_seq_item);

  `uvm_component_utils(uart_driver)

  uart_cfg cfg_h;

  virtual uart_if uart_vif;

  function new(string name = "uart_driver",uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db #(uart_cfg)::get(this,"","uart_cfg",cfg_h))
      `uvm_fatal(get_type_name(),"Unable to get uart_cfg")
    uart_vif = cfg_h.uart_vif;

  endfunction

  task wait_bit();

    repeat(cfg_h.cycles_per_bit)
        @(posedge uart_vif.PCLK);

  endtask

  task run_phase(uvm_phase phase);

    forever begin

      seq_item_port.get_next_item(req);

      drive_frame(req);

      seq_item_port.item_done();

    end

  endtask

  task drive_frame(uart_seq_item req);

	drive_idle();
	drive_start_bit();
	drive_data(req);

	if(req.parity_en)
	 drive_parity(req);

	drive_stop_bits(req);
	drive_idle();

  endtask

  task drive_idle();

    uart_vif.UARTRXD <= 1'b1;

  endtask

  task drive_start_bit();

  uart_vif.UARTRXD <= 1'b0;
  wait_bit();

  endtask

  task drive_data(uart_seq_item req);

  int num_bits;

  case(req.wlen)
  2'b00: num_bits = 5;
  2'b01: num_bits = 6;
  2'b10: num_bits = 7;
  2'b11: num_bits = 8;
  endcase

  for (int i = 0; i < num_bits; i++) begin
	uart_vif.UARTRXD <= req.data[i];
	wait_bit();
  end
  endtask

  task drive_parity(uart_seq_item req);

  bit parity;

  case(req.wlen)
    2'b00: parity = ^req.data[4:0];
    2'b01: parity = ^req.data[5:0];
    2'b10: parity = ^req.data[6:0];
    2'b11: parity = ^req.data[7:0];
  endcase

  if(!req.even_parity)
    parity = ~parity;

  //-----------------------------------------
  // Inject parity error
  //-----------------------------------------

  if(cfg_h.inject_parity_error)
      parity = ~parity;

  uart_vif.UARTRXD <= parity;
  wait_bit();

endtask

  task drive_stop_bits(uart_seq_item req);

  //-----------------------------------------
  // First stop bit
  //-----------------------------------------

  if(cfg_h.inject_frame_error)
      uart_vif.UARTRXD <= 1'b0;
  else
      uart_vif.UARTRXD <= 1'b1;

  wait_bit();

  //-----------------------------------------
  // Second stop
  //-----------------------------------------

  if(req.stop2)
  begin
      uart_vif.UARTRXD <= 1'b1;
      wait_bit();
  end

endtask

endclass