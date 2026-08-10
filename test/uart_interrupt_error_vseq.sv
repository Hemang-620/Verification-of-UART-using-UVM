class uart_interrupt_error_vseq extends base_virtual_sequence;

  `uvm_object_utils(uart_interrupt_error_vseq)

  uart_tx_sequence tx_seq_h;

  function new(string name="uart_interrupt_error_vseq");
    super.new(name);
  endfunction


  //------------------------------------------------------------
  // Send one UART frame from UART VIP
  //------------------------------------------------------------

  task automatic send_frame(
      input bit [7:0] data,
      input bit parity_err = 0,
      input bit frame_err  = 0
  );

      p_sequencer.uart_cfg_h.inject_parity_error = parity_err;
      p_sequencer.uart_cfg_h.inject_frame_error  = frame_err;

      tx_seq_h = uart_tx_sequence::type_id::create("tx_seq_h");

      tx_seq_h.data          = data;
      tx_seq_h.wlen          = 2'b11;
      tx_seq_h.parity_en     = 1;
      tx_seq_h.even_parity   = 1;
      tx_seq_h.stop2         = 0;

      tx_seq_h.start(p_sequencer.uart_seqr);

      repeat(12*p_sequencer.uart_cfg_h.cycles_per_bit)
        @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

      p_sequencer.uart_cfg_h.inject_parity_error = 0;
      p_sequencer.uart_cfg_h.inject_frame_error  = 0;

  endtask


  //------------------------------------------------------------
  // Wait for interrupt
  //------------------------------------------------------------

  task automatic wait_for_interrupt(input string intr);

      case(intr)

      "TX":
      begin
          wait(p_sequencer.uart_cfg_h.uart_vif.UARTTXINTR);
          `uvm_info(get_type_name(),
          "TX Interrupt Asserted",
          UVM_LOW)
      end

      "RX":
      begin
          wait(p_sequencer.uart_cfg_h.uart_vif.UARTRXINTR);
          `uvm_info(get_type_name(),
          "RX Interrupt Asserted",
          UVM_LOW)
      end

      "RT":
      begin
          wait(p_sequencer.uart_cfg_h.uart_vif.UARTRTINTR);
          `uvm_info(get_type_name(),
          "RX Timeout Interrupt Asserted",
          UVM_LOW)
      end

      "ERR":
      begin
          wait(p_sequencer.uart_cfg_h.uart_vif.UARTEINTR);
          `uvm_info(get_type_name(),
          "Error Interrupt Asserted",
          UVM_LOW)
      end

      endcase

  endtask


  //------------------------------------------------------------
  // Read RIS
  //------------------------------------------------------------

  task automatic read_ris();

      uvm_status_e status;
      uvm_reg_data_t data;

      p_sequencer.ral_h.UARTRIS.read(status,data);

      `uvm_info(get_type_name(),
      $sformatf("RIS = %03h",data),
      UVM_LOW);

  endtask


  //------------------------------------------------------------
  // Read MIS
  //------------------------------------------------------------

  task automatic read_mis();

      uvm_status_e status;
      uvm_reg_data_t data;

      p_sequencer.ral_h.UARTMIS.read(status,data);

      `uvm_info(get_type_name(),
      $sformatf("MIS = %03h",data),
      UVM_LOW);

  endtask


  //------------------------------------------------------------
  // Clear Interrupts
  //------------------------------------------------------------

  task automatic clear_interrupts();

      uvm_status_e status;

      p_sequencer.ral_h.UARTICR.write(status,16'h7FF);

      `uvm_info(get_type_name(),
      "UARTICR Cleared",
      UVM_LOW);

  endtask


  //------------------------------------------------------------
  // BODY
  //------------------------------------------------------------

  task body();

    uvm_status_e status;
    uvm_reg_data_t rd_data;

    #100ns;

    //-----------------------------------------
    // Configure Baud
    //-----------------------------------------

    p_sequencer.ral_h.UARTIBRD.write(status,16'd54);
    p_sequencer.ral_h.UARTFBRD.write(status,16'd16);

    p_sequencer.uart_cfg_h.ibdr = 54;
    p_sequencer.uart_cfg_h.fbdr = 16;
    p_sequencer.uart_cfg_h.calculate_timing();

    //-----------------------------------------
    // Configure UART
    //-----------------------------------------

    p_sequencer.ral_h.UARTLCR_H.write(status,16'h60);

    //-----------------------------------------
    // Enable UART
    //-----------------------------------------

    p_sequencer.ral_h.UARTCR.write(status,16'h301);

    //-----------------------------------------
    // Enable TX Interrupt ONLY
    //-----------------------------------------

    p_sequencer.ral_h.UARTIMSC.write(status,16'h20);

    //-----------------------------------------
    // Write one byte
    //-----------------------------------------

    p_sequencer.ral_h.UARTDR.write(status,8'h55);

    //-----------------------------------------
    // Wait
    //-----------------------------------------

    repeat(1000)
        @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

    //-----------------------------------------
    // Print Interrupt Pin
    //-----------------------------------------

    $display("--------------------------------------");
    $display("UARTTXINTR = %b",
        p_sequencer.uart_cfg_h.uart_vif.UARTTXINTR);

    $display("UARTRXINTR = %b",
        p_sequencer.uart_cfg_h.uart_vif.UARTRXINTR);

    $display("UARTRTINTR = %b",
        p_sequencer.uart_cfg_h.uart_vif.UARTRTINTR);

    $display("UARTEINTR = %b",
        p_sequencer.uart_cfg_h.uart_vif.UARTEINTR);

    //-----------------------------------------
    // Read RIS
    //-----------------------------------------

    p_sequencer.ral_h.UARTRIS.read(status,rd_data);

    $display("RIS = %03h",rd_data);

    //-----------------------------------------
    // Read MIS
    //-----------------------------------------

    p_sequencer.ral_h.UARTMIS.read(status,rd_data);

    $display("MIS = %03h",rd_data);

    //-----------------------------------------
    // End
    //-----------------------------------------

    p_sequencer.ral_h.UARTCR.write(status,16'h000);

endtask

endclass