class uart_register_rd_vseq extends base_virtual_sequence;

  `uvm_object_utils(uart_register_rd_vseq)

  function new(string name="uart_register_rd_vseq");
    super.new(name);
  endfunction

  task body();

    uvm_status_e   status;
    uvm_reg_data_t rd_data;

    //---------------------------------------------
    // Wait until reset completes
    //---------------------------------------------

    #100ns;

    `uvm_info(get_type_name(),
      "Starting UART Register Reset Value Verification...",
      UVM_LOW)

    //---------------------------------------------
    // UARTDR
    //---------------------------------------------

    p_sequencer.ral_h.UARTDR.read(status, rd_data);

    if(rd_data !== 32'h0000_0000)
      `uvm_error(get_type_name(),
        $sformatf("UARTDR Reset Mismatch Exp=0x00000000 Act=0x%08h",rd_data))
    else
      `uvm_info(get_type_name(),"UARTDR Reset PASS",UVM_LOW);

    //---------------------------------------------
    // UARTFR
    //---------------------------------------------

    p_sequencer.ral_h.UARTFR.read(status, rd_data);

    if(rd_data !== 32'h0000_0090)
      `uvm_error(get_type_name(),
        $sformatf("UARTFR Reset Mismatch Exp=0x00000090 Act=0x%08h",rd_data))
    else
      `uvm_info(get_type_name(),"UARTFR Reset PASS",UVM_LOW);

    //---------------------------------------------
    // UARTIBRD
    //---------------------------------------------

    p_sequencer.ral_h.UARTIBRD.read(status, rd_data);

    if(rd_data !== 32'h0000_0000)
      `uvm_error(get_type_name(),
        $sformatf("UARTIBRD Reset Mismatch Exp=0x00000000 Act=0x%08h",rd_data))
    else
      `uvm_info(get_type_name(),"UARTIBRD Reset PASS",UVM_LOW);

    //---------------------------------------------
    // UARTFBRD
    //---------------------------------------------

    p_sequencer.ral_h.UARTFBRD.read(status, rd_data);

    if(rd_data !== 32'h0000_0000)
      `uvm_error(get_type_name(),
        $sformatf("UARTFBRD Reset Mismatch Exp=0x00000000 Act=0x%08h",rd_data))
    else
      `uvm_info(get_type_name(),"UARTFBRD Reset PASS",UVM_LOW);

    //---------------------------------------------
    // UARTLCR_H
    //---------------------------------------------

    p_sequencer.ral_h.UARTLCR_H.read(status, rd_data);

    if(rd_data !== 32'h0000_0000)
      `uvm_error(get_type_name(),
        $sformatf("UARTLCR_H Reset Mismatch Exp=0x00000000 Act=0x%08h",rd_data))
    else
      `uvm_info(get_type_name(),"UARTLCR_H Reset PASS",UVM_LOW);

    //---------------------------------------------
    // UARTCR
    //---------------------------------------------

    p_sequencer.ral_h.UARTCR.read(status, rd_data);

    if(rd_data !== 32'h0000_0000)
      `uvm_error(get_type_name(),
        $sformatf("UARTCR Reset Mismatch Exp=0x00000000 Act=0x%08h",rd_data))
    else
      `uvm_info(get_type_name(),"UARTCR Reset PASS",UVM_LOW);

    //---------------------------------------------
    // UARTIFLS
    //---------------------------------------------

    p_sequencer.ral_h.UARTIFLS.read(status, rd_data);

    if(rd_data !== 32'h0000_0000)
      `uvm_error(get_type_name(),
        $sformatf("UARTIFLS Reset Mismatch Exp=0x00000000 Act=0x%08h",rd_data))
    else
      `uvm_info(get_type_name(),"UARTIFLS Reset PASS",UVM_LOW);

    //---------------------------------------------
    // UARTIMSC
    //---------------------------------------------

    p_sequencer.ral_h.UARTIMSC.read(status, rd_data);

    if(rd_data !== 32'h0000_0000)
      `uvm_error(get_type_name(),
        $sformatf("UARTIMSC Reset Mismatch Exp=0x00000000 Act=0x%08h",rd_data))
    else
      `uvm_info(get_type_name(),"UARTIMSC Reset PASS",UVM_LOW);

    //---------------------------------------------
    // UARTRIS
    //---------------------------------------------

    p_sequencer.ral_h.UARTRIS.read(status, rd_data);

    if(rd_data !== 32'h0000_0000)
      `uvm_error(get_type_name(),
        $sformatf("UARTRIS Reset Mismatch Exp=0x00000000 Act=0x%08h",rd_data))
    else
      `uvm_info(get_type_name(),"UARTRIS Reset PASS",UVM_LOW);

    //---------------------------------------------
    // UARTMIS
    //---------------------------------------------

    p_sequencer.ral_h.UARTMIS.read(status, rd_data);

    if(rd_data !== 32'h0000_0000)
      `uvm_error(get_type_name(),
        $sformatf("UARTMIS Reset Mismatch Exp=0x00000000 Act=0x%08h",rd_data))
    else
      `uvm_info(get_type_name(),"UARTMIS Reset PASS",UVM_LOW);

    `uvm_info(get_type_name(),
      "UART Register Reset Verification Completed.",
      UVM_LOW)

  endtask

endclass