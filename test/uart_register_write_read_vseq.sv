class uart_register_write_read_vseq extends base_virtual_sequence;

  `uvm_object_utils(uart_register_write_read_vseq)

  function new(string name="uart_register_write_read_vseq");
    super.new(name);
  endfunction

  //------------------------------------------------------------
  // Generic Register Check Task
  //------------------------------------------------------------

  task automatic check_register(
      input uvm_reg          reg_h,
      input string           reg_name,
      input uvm_reg_data_t   wr_data,
      input uvm_reg_data_t   exp_data
  );

    uvm_status_e   status;
    uvm_reg_data_t rd_data;

    //---------------------------------------
    // Write
    //---------------------------------------

    reg_h.write(status, wr_data);

    //---------------------------------------
    // Read
    //---------------------------------------

    reg_h.read(status, rd_data);

    //---------------------------------------
    // Compare
    //---------------------------------------

    if(rd_data !== exp_data)
      `uvm_error(get_type_name(),
        $sformatf("%s WRITE/READ FAILED Exp=0x%0h Act=0x%0h",
                  reg_name,
                  exp_data,
                  rd_data))
    else
      `uvm_info(get_type_name(),
        $sformatf("%s WRITE/READ PASS Value=0x%0h",
                  reg_name,
                  rd_data),
        UVM_LOW);

    //---------------------------------------
    // Mirror Check
    //---------------------------------------

    reg_h.mirror(status, UVM_CHECK);

  endtask


  //------------------------------------------------------------
  // Body
  //------------------------------------------------------------

  task body();

    #100ns;

    `uvm_info(get_type_name(),
      "Starting UART Register Write/Read Test",
      UVM_LOW)

    //--------------------------------------------------------
    // UARTIBRD
    //--------------------------------------------------------

    check_register(
      p_sequencer.ral_h.UARTIBRD,
      "UARTIBRD",
      16'd54,
      16'd54
    );

    //--------------------------------------------------------
    // UARTFBRD
    //--------------------------------------------------------

    check_register(
      p_sequencer.ral_h.UARTFBRD,
      "UARTFBRD",
      16'd16,
      16'd16
    );

    //--------------------------------------------------------
    // UARTLCR_H
    //--------------------------------------------------------

    check_register(
      p_sequencer.ral_h.UARTLCR_H,
      "UARTLCR_H",
      16'h76,
      16'h76
    );

    //--------------------------------------------------------
    // UARTCR
    //--------------------------------------------------------
    // Reserved bits should remain 0

    check_register(
      p_sequencer.ral_h.UARTCR,
      "UARTCR",
      16'hFFFF,
      16'h0381
    );

    //--------------------------------------------------------
    // UARTIFLS
    //--------------------------------------------------------

    check_register(
      p_sequencer.ral_h.UARTIFLS,
      "UARTIFLS",
      16'hFFFF,
      16'h003F
    );

    //--------------------------------------------------------
    // UARTIMSC
    //--------------------------------------------------------

    check_register(
      p_sequencer.ral_h.UARTIMSC,
      "UARTIMSC",
      16'hFFFF,
      16'h07FF
    );

    `uvm_info(get_type_name(),
      "UART Register Write/Read Test Completed",
      UVM_LOW)

//--------------------------------------------------------
// Give time for all APB transactions to complete
//--------------------------------------------------------

repeat(20)
  @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

`uvm_info(get_type_name(),
  "Register Write/Read Sequence Completed",
  UVM_LOW)

  endtask

endclass