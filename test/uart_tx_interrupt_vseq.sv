class uart_tx_interrupt_vseq extends base_virtual_sequence;

  `uvm_object_utils(uart_tx_interrupt_vseq)

  function new(string name="uart_tx_interrupt_vseq");
    super.new(name);
  endfunction


  task body();

    uvm_status_e   status;
    uvm_reg_data_t rd_data;

    //---------------------------------------------------------
    // Wait after reset
    //---------------------------------------------------------

    #100ns;

    //---------------------------------------------------------
    // Configure Baud Rate
    //---------------------------------------------------------

    p_sequencer.ral_h.UARTIBRD.write(status,16'd54);
    p_sequencer.ral_h.UARTFBRD.write(status,16'd16);

    p_sequencer.uart_cfg_h.ibdr = 54;
    p_sequencer.uart_cfg_h.fbdr = 16;
    p_sequencer.uart_cfg_h.calculate_timing();

    //---------------------------------------------------------
    // 8-bit, No parity, 1 stop
    //---------------------------------------------------------

    p_sequencer.ral_h.UARTLCR_H.write(status,16'h60);

    //---------------------------------------------------------
    // FIFO Interrupt Level
    // TX <= 1/8 Full
    //---------------------------------------------------------

    p_sequencer.ral_h.UARTIFLS.write(status,16'h0000);

    //---------------------------------------------------------
    // Enable UART + TX
    //---------------------------------------------------------

    p_sequencer.ral_h.UARTCR.write(status,16'h101);

    //---------------------------------------------------------
    // Enable ONLY TX Interrupt
    //---------------------------------------------------------

    p_sequencer.ral_h.UARTIMSC.write(status,16'h0020);

    //---------------------------------------------------------
    // Send one byte
    //---------------------------------------------------------

    `uvm_info(get_type_name(),
        "Writing UARTDR",
        UVM_LOW)

    p_sequencer.ral_h.UARTDR.write(status,8'h55);

    //---------------------------------------------------------
    // Wait for TX Completion
    //---------------------------------------------------------

    repeat(15*p_sequencer.uart_cfg_h.cycles_per_bit)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

    //---------------------------------------------------------
    // Check Interrupt Pin
    //---------------------------------------------------------

    if(!p_sequencer.uart_cfg_h.uart_vif.UARTTXINTR)
      `uvm_error(get_type_name(),
        "UARTTXINTR NOT ASSERTED")
    else
      `uvm_info(get_type_name(),
        "UARTTXINTR ASSERTED",
        UVM_LOW)

    //---------------------------------------------------------
    // Read RIS
    //---------------------------------------------------------

    p_sequencer.ral_h.UARTRIS.read(status,rd_data);

    `uvm_info(get_type_name(),
      $sformatf("RIS = %04h",rd_data),
      UVM_LOW)

    if(!rd_data[5])
      `uvm_error(get_type_name(),
        "TXRIS NOT SET")

    //---------------------------------------------------------
    // Read MIS
    //---------------------------------------------------------

    p_sequencer.ral_h.UARTMIS.read(status,rd_data);

    `uvm_info(get_type_name(),
      $sformatf("MIS = %04h",rd_data),
      UVM_LOW)

    if(!rd_data[5])
      `uvm_error(get_type_name(),
        "TXMIS NOT SET")

    //---------------------------------------------------------
    // Clear TX Interrupt
    //---------------------------------------------------------

    `uvm_info(get_type_name(),
      "Clearing TX Interrupt",
      UVM_LOW)

    p_sequencer.ral_h.UARTICR.write(status,16'h0020);

    repeat(5)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

    //---------------------------------------------------------
    // Verify Interrupt Cleared
    //---------------------------------------------------------

    if(p_sequencer.uart_cfg_h.uart_vif.UARTTXINTR)
      `uvm_error(get_type_name(),
        "UARTTXINTR NOT CLEARED")
    else
      `uvm_info(get_type_name(),
        "UARTTXINTR CLEARED",
        UVM_LOW)

    //---------------------------------------------------------
    // Read RIS Again
    //---------------------------------------------------------

    p_sequencer.ral_h.UARTRIS.read(status,rd_data);

    if(rd_data[5])
      `uvm_error(get_type_name(),
        "TXRIS NOT CLEARED")

    //---------------------------------------------------------
    // Read MIS Again
    //---------------------------------------------------------

    p_sequencer.ral_h.UARTMIS.read(status,rd_data);

    if(rd_data[5])
      `uvm_error(get_type_name(),
        "TXMIS NOT CLEARED")

    //---------------------------------------------------------
    // Disable UART
    //---------------------------------------------------------

    p_sequencer.ral_h.UARTCR.write(status,16'h0000);

    `uvm_info(get_type_name(),
      "UART TX Interrupt Test Completed",
      UVM_LOW);

  endtask

endclass