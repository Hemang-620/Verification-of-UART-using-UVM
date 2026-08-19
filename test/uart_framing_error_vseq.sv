class uart_framing_error_vseq extends base_virtual_sequence;

  `uvm_object_utils(uart_framing_error_vseq)

  uvm_status_e status;

  function new(string name = "uart_framing_error_vseq");
    super.new(name);
  endfunction

  virtual task body();

    uart_tx_sequence tx_seq_h;
    uvm_reg_data_t read_data;

   

    `uvm_info(get_type_name(),
      "Starting UART framing error test",
      UVM_LOW)

    p_sequencer.uart_cfg_h.ibdr = 54;
    p_sequencer.uart_cfg_h.fbdr = 16;
    p_sequencer.uart_cfg_h.calculate_timing();

     #100ns;

    p_sequencer.ral_h.UARTIBRD.write(
      status,
      16'd54
    );

    p_sequencer.ral_h.UARTFBRD.write(
      status,
      16'd16
    );

    p_sequencer.ral_h.UARTCR.write(
      status,
      16'h0301
    );

    p_sequencer.ral_h.UARTIMSC.write(
      status,
      16'h0080
    );

    p_sequencer.ral_h.UARTLCR_H.write(
      status,
      16'h0070
    );

    p_sequencer.uart_cfg_h.inject_frame_error = 1'b1;

    tx_seq_h = uart_tx_sequence::type_id::create("tx_seq_h");

    tx_seq_h.data        = 8'h55;
    tx_seq_h.wlen        = 2'b11;
    tx_seq_h.parity_en   = 1'b0;
    tx_seq_h.even_parity = 1'b0;
    tx_seq_h.stop2       = 1'b0;

    tx_seq_h.start(p_sequencer.uart_seqr);

    repeat(12 * p_sequencer.uart_cfg_h.cycles_per_bit)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

    p_sequencer.ral_h.UARTRIS.read(
      status,
      read_data
    );

    `uvm_info(
      get_type_name(),
      $sformatf("UARTRIS = %03h", read_data),
      UVM_LOW
    )

    if(read_data[7] !== 1'b1)
      `uvm_error(
        get_type_name(),
        $sformatf(
          "Framing error not detected. UARTRIS[7] = %b",
          read_data[7]
        )
      )
    else
      `uvm_info(
        get_type_name(),
        "Framing error detected in UARTRIS[7]",
        UVM_LOW
      )

    p_sequencer.ral_h.UARTMIS.read(
      status,
      read_data
    );

    `uvm_info(
      get_type_name(),
      $sformatf("UARTMIS = %03h", read_data),
      UVM_LOW
    )

    if(read_data[7] !== 1'b1)
      `uvm_error(
        get_type_name(),
        $sformatf(
          "Framing error not detected. UARTMIS[7] = %b",
          read_data[7]
        )
      )
    else
      `uvm_info(
        get_type_name(),
        "Framing error detected in UARTMIS[7]",
        UVM_LOW
      )

    if(p_sequencer.uart_cfg_h.uart_vif.UARTEINTR !== 1'b1)
      `uvm_error(
        get_type_name(),
        "UARTEINTR was not asserted for framing error"
      )
    else
      `uvm_info(
        get_type_name(),
        "UARTEINTR asserted for framing error",
        UVM_LOW
      )

    `uvm_info(
      "RAL",
      "Clearing framing error using UARTECR[0]",
      UVM_LOW
    )

    p_sequencer.ral_h.UARTECR.write(
      status,
      16'h0001
    );

    if(status != UVM_IS_OK)
      `uvm_error(
        get_type_name(),
        "UARTECR write failed"
      );

    p_sequencer.uart_cfg_h.inject_frame_error = 1'b0;

    `uvm_info(
      get_type_name(),
      "UART framing error test completed",
      UVM_LOW
    )

  endtask

endclass