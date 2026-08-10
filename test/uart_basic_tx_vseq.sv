class uart_basic_tx_vseq extends base_virtual_sequence;

  `uvm_object_utils(uart_basic_tx_vseq)

  apb_write_seq wr_seq_h;

  function new(string name="uart_basic_tx_vseq");
    super.new(name);
  endfunction

  task body();

  uvm_status_e   status;
  uvm_reg_data_t data;
    //--------------------------------------------------
    // Program Baud Rate
    //--------------------------------------------------
#100ns;
    // UARTIBRD = 54
    // wr_seq_h = apb_write_seq::type_id::create("wr_seq_h");
    // wr_seq_h.addr = `UARTIBRD;
    // wr_seq_h.data = 54;
    // wr_seq_h.start(p_sequencer.apb_seqr); 

    p_sequencer.ral_h.UARTIBRD.write(status,16'd54);

    // UARTFBRD = 16
    // wr_seq_h = apb_write_seq::type_id::create("wr_seq_h");
    // wr_seq_h.addr = `UARTFBRD;
    // wr_seq_h.data = 16;
    // wr_seq_h.start(p_sequencer.apb_seqr);

    p_sequencer.ral_h.UARTFBRD.write(status,16'd16);

    //--------------------------------------------------
    // Calculate timing for UART VIP
    //--------------------------------------------------

    p_sequencer.uart_cfg_h.ibdr = 54;
    p_sequencer.uart_cfg_h.fbdr = 16;
    p_sequencer.uart_cfg_h.calculate_timing();

    `uvm_info(get_type_name(),$sformatf("UART Timing: IBRD=%0d FBRD=%0d Cycles/Bit=%0d",
        p_sequencer.uart_cfg_h.ibdr,
        p_sequencer.uart_cfg_h.fbdr,
        p_sequencer.uart_cfg_h.cycles_per_bit),
      UVM_LOW)

    //--------------------------------------------------
    // Configure Line Control
    //--------------------------------------------------

    // wr_seq_h = apb_write_seq::type_id::create("wr_seq_h");
    // wr_seq_h.addr = `UARTLCR_H;
    // wr_seq_h.data = 32'h60;      // 8-bit, FIFO enabled
    // wr_seq_h.start(p_sequencer.apb_seqr);

    p_sequencer.ral_h.UARTLCR_H.write(status,16'h60);

    //--------------------------------------------------
    // Enable UART
    //--------------------------------------------------

    // wr_seq_h = apb_write_seq::type_id::create("wr_seq_h");
    // wr_seq_h.addr = `UARTCR;
    // wr_seq_h.data = 32'h301;     // UARTEN | TXE | RXE
    // wr_seq_h.start(p_sequencer.apb_seqr);

    p_sequencer.ral_h.UARTCR.write(status,16'h301);

    //--------------------------------------------------
    // Write Data Register
    //--------------------------------------------------

    // wr_seq_h = apb_write_seq::type_id::create("wr_seq_h");
    // wr_seq_h.addr = `UARTDR;
    // wr_seq_h.data = 8'h55;       // Test pattern
    // wr_seq_h.start(p_sequencer.apb_seqr);

    p_sequencer.ral_h.UARTDR.write(status,16'h55);

    //--------------------------------------------------
    // Wait long enough for complete transmission
    //--------------------------------------------------
    // #500ns;
    repeat(12 * p_sequencer.uart_cfg_h.cycles_per_bit)
    @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

  endtask

endclass