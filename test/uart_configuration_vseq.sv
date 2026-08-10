class uart_configuration_vseq extends base_virtual_sequence;

  `uvm_object_utils(uart_configuration_vseq)

  uart_tx_sequence uart_seq_h;

  function new(string name="uart_configuration_vseq");
    super.new(name);
  endfunction


  //------------------------------------------------------------
  // Configure UART
  //------------------------------------------------------------

  task configure_uart(
      bit [1:0] wlen,
      bit parity_en,
      bit even_parity
  );

    uvm_status_e status;
    uvm_reg_data_t lcr;

    //--------------------------------------------------------
    // Baud Rate
    //--------------------------------------------------------

    p_sequencer.ral_h.UARTIBRD.write(status,16'd54);
    p_sequencer.ral_h.UARTFBRD.write(status,16'd16);

    //--------------------------------------------------------
    // UART VIP timing
    //--------------------------------------------------------

    p_sequencer.uart_cfg_h.ibdr = 54;
    p_sequencer.uart_cfg_h.fbdr = 16;
    p_sequencer.uart_cfg_h.calculate_timing();

    //--------------------------------------------------------
    // Configure UART VIP
    //--------------------------------------------------------

    p_sequencer.uart_cfg_h.wlen        = wlen;
    p_sequencer.uart_cfg_h.parity_en   = parity_en;
    p_sequencer.uart_cfg_h.even_parity = even_parity;
    p_sequencer.uart_cfg_h.stop2       = 0;

    //--------------------------------------------------------
    // UARTLCR_H
    //--------------------------------------------------------

    lcr = '0;

    lcr[6:5] = wlen;          // Word Length
    lcr[4]   = 1'b0;          // FIFO Disable
    lcr[3]   = 1'b0;          // One Stop Bit
    lcr[2]   = even_parity;   // EPS
    lcr[1]   = parity_en;     // PEN
    lcr[0]   = 1'b0;          // BRK

    p_sequencer.ral_h.UARTLCR_H.write(status,lcr);

    //--------------------------------------------------------
    // UART Enable + RX Enable
    //--------------------------------------------------------

    p_sequencer.ral_h.UARTCR.write(status,16'h201);

  endtask


  //------------------------------------------------------------
  // Send one UART Frame
  //------------------------------------------------------------

  task send_frame(bit [7:0] data);

    uart_seq_h = uart_tx_sequence::type_id::create("uart_seq_h");

    uart_seq_h.data = data;

    uart_seq_h.wlen = p_sequencer.uart_cfg_h.wlen;

    uart_seq_h.parity_en = p_sequencer.uart_cfg_h.parity_en;

    uart_seq_h.even_parity = p_sequencer.uart_cfg_h.even_parity;

    uart_seq_h.stop2 = 0;

    uart_seq_h.start(p_sequencer.uart_seqr);

    repeat(12*p_sequencer.uart_cfg_h.cycles_per_bit)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

  endtask


  //------------------------------------------------------------
  // Body
  //------------------------------------------------------------

  task body();

    #100ns;

    //--------------------------------------------------------
    // Scenario-1 : 5-bit
    //--------------------------------------------------------

    `uvm_info(get_type_name(),"CONFIG TEST : 5-BIT",UVM_LOW)

    configure_uart(2'b00,0,0);

    send_frame(8'h15);


    //--------------------------------------------------------
    // Scenario-2 : 6-bit
    //--------------------------------------------------------

    `uvm_info(get_type_name(),"CONFIG TEST : 6-BIT",UVM_LOW)

    configure_uart(2'b01,0,0);

    send_frame(8'h2A);


    //--------------------------------------------------------
    // Scenario-3 : 7-bit
    //--------------------------------------------------------

    `uvm_info(get_type_name(),"CONFIG TEST : 7-BIT",UVM_LOW)

    configure_uart(2'b10,0,0);

    send_frame(8'h55);


    //--------------------------------------------------------
    // Scenario-4 : 8-bit
    //--------------------------------------------------------

    `uvm_info(get_type_name(),"CONFIG TEST : 8-BIT",UVM_LOW)

    configure_uart(2'b11,0,0);

    send_frame(8'hA5);


    //--------------------------------------------------------
    // Scenario-5 : Even Parity
    //--------------------------------------------------------

    `uvm_info(get_type_name(),"CONFIG TEST : EVEN PARITY",UVM_LOW)

    configure_uart(2'b11,1,1);

    send_frame(8'h96);


    //--------------------------------------------------------
    // Scenario-6 : Odd Parity
    //--------------------------------------------------------

    `uvm_info(get_type_name(),"CONFIG TEST : ODD PARITY",UVM_LOW)

    configure_uart(2'b11,1,0);

    send_frame(8'h69);


    `uvm_info(get_type_name(),
              "UART CONFIGURATION TEST COMPLETED",
              UVM_LOW);

  endtask

endclass