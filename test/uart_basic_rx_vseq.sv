class uart_basic_rx_vseq extends base_virtual_sequence;

  `uvm_object_utils(uart_basic_rx_vseq)

  uart_tx_sequence uart_seq_h;

  function new(string name="uart_basic_rx_vseq");
    super.new(name);
  endfunction

  task body();

    uvm_status_e   status;
    uvm_reg_data_t rd_data;

    //--------------------------------------------------
    // Configure UART
    //--------------------------------------------------

    #100ns;

    // Baud Rate
    p_sequencer.ral_h.UARTIBRD.write(status,16'd54);
    p_sequencer.ral_h.UARTFBRD.write(status,16'd16);

    //--------------------------------------------------
    // Configure UART VIP Timing
    //--------------------------------------------------

    p_sequencer.uart_cfg_h.ibdr = 54;
    p_sequencer.uart_cfg_h.fbdr = 16;
    p_sequencer.uart_cfg_h.calculate_timing();

    `uvm_info(get_type_name(),
      $sformatf("UART Timing : IBRD=%0d FBRD=%0d Cycles/Bit=%0d",
      p_sequencer.uart_cfg_h.ibdr,
      p_sequencer.uart_cfg_h.fbdr,
      p_sequencer.uart_cfg_h.cycles_per_bit),
      UVM_LOW)

    //--------------------------------------------------
    // 8-bit, No Parity, 1 Stop Bit
    //--------------------------------------------------

    p_sequencer.ral_h.UARTLCR_H.write(status,16'h60);

    //--------------------------------------------------
    // Enable UART + RX
    //--------------------------------------------------

    // UARTEN + RXE
    p_sequencer.ral_h.UARTCR.write(status,16'h201);

    //--------------------------------------------------
    // Send Serial Frame from UART VIP
    //--------------------------------------------------

    uart_seq_h = uart_tx_sequence::type_id::create("uart_seq_h");

    uart_seq_h.data          = 8'hA5;
    uart_seq_h.wlen          = 2'b11;
    uart_seq_h.parity_en     = 0;
    uart_seq_h.even_parity   = 1;
    uart_seq_h.stop2         = 0;

    uart_seq_h.start(p_sequencer.uart_seqr);

    //--------------------------------------------------
    // Wait for complete reception
    //--------------------------------------------------

    repeat(12 * p_sequencer.uart_cfg_h.cycles_per_bit)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

    //--------------------------------------------------
    // Read UARTDR through RAL
    //--------------------------------------------------

    p_sequencer.ral_h.UARTDR.read(status, rd_data);

    //--------------------------------------------------
    // Compare
    //--------------------------------------------------

    if(rd_data[7:0] == 8'hA5)
      `uvm_info(get_type_name(),
        $sformatf("RX PASS : Received = 0x%02h", rd_data[7:0]),
        UVM_LOW)
    else
      `uvm_error(get_type_name(),
        $sformatf("RX FAIL : Expected = 0xA5 Received = 0x%02h",
        rd_data[7:0]))

  endtask

endclass