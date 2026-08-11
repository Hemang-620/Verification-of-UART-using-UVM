class uart_rx_interrupt_vseq extends base_virtual_sequence;

  `uvm_object_utils(uart_rx_interrupt_vseq)

  uart_tx_sequence rx_seq_h;

  function new(string name = "uart_rx_interrupt_vseq");
    super.new(name);
  endfunction


  //------------------------------------------------------------
  // Send one UART frame into DUT RX
  //
  // uart_tx_sequence drives UARTRXD through the UART VIP
  //------------------------------------------------------------

  task automatic send_rx_frame(input bit [7:0] data);

    rx_seq_h = uart_tx_sequence::type_id::create("rx_seq_h");

    rx_seq_h.data        = data;
    rx_seq_h.wlen        = 2'b11;     // 8-bit
    rx_seq_h.parity_en   = 0;
    rx_seq_h.even_parity = 0;
    rx_seq_h.stop2       = 0;

    `uvm_info(get_type_name(),
      $sformatf("Sending RX frame = %02h", data),
      UVM_LOW)

    rx_seq_h.start(p_sequencer.uart_seqr);

    // Wait for complete UART frame
    repeat(12 * p_sequencer.uart_cfg_h.cycles_per_bit)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

  endtask


  //------------------------------------------------------------
  // Read RIS
  //------------------------------------------------------------

  task automatic read_ris(output uvm_reg_data_t data);

    uvm_status_e status;

    p_sequencer.ral_h.UARTRIS.read(status, data);

    `uvm_info(get_type_name(),
      $sformatf("UARTRIS = %03h", data),
      UVM_LOW)

    if(status != UVM_IS_OK) begin
      `uvm_error(get_type_name(),
        "UARTRIS read failed")
    end

  endtask


  //------------------------------------------------------------
  // Read MIS
  //------------------------------------------------------------

  task automatic read_mis(output uvm_reg_data_t data);

    uvm_status_e status;

    p_sequencer.ral_h.UARTMIS.read(status, data);

    `uvm_info(get_type_name(),
      $sformatf("UARTMIS = %03h", data),
      UVM_LOW)

    if(status != UVM_IS_OK) begin
      `uvm_error(get_type_name(),
        "UARTMIS read failed")
    end

  endtask


  //------------------------------------------------------------
  // Clear RX interrupt
  //
  // UARTICR[4] = RXIC
  //------------------------------------------------------------

  task automatic clear_rx_interrupt();

    uvm_status_e status;

    `uvm_info(get_type_name(),
      "Clearing RX interrupt using UARTICR[4]",
      UVM_LOW)

    p_sequencer.ral_h.UARTICR.write(status, 16'h0010);

    if(status != UVM_IS_OK) begin
      `uvm_error(get_type_name(),
        "UARTICR write failed")
    end

  endtask


  //------------------------------------------------------------
  // BODY
  //------------------------------------------------------------

  task body();

    uvm_status_e   status;
    uvm_reg_data_t ris_data;
    uvm_reg_data_t mis_data;

    bit rx_intr;


    //----------------------------------------------------------
    // Initial delay
    //----------------------------------------------------------

    #100ns;


    //----------------------------------------------------------
    // Configure baud rate
    //----------------------------------------------------------

    `uvm_info(get_type_name(),
      "Configuring baud rate",
      UVM_LOW)

    p_sequencer.ral_h.UARTIBRD.write(status, 16'd54);

    p_sequencer.ral_h.UARTFBRD.write(status, 16'd16);

    // Keep UART VIP timing synchronized with DUT
    p_sequencer.uart_cfg_h.ibdr = 54;
    p_sequencer.uart_cfg_h.fbdr = 16;

    p_sequencer.uart_cfg_h.calculate_timing();


    //----------------------------------------------------------
    // Configure UART
    //
    // 8 data bits
    // No parity
    // 1 stop bit
    // FIFO ENABLED
    //
    // UARTLCR_H:
    // bit[6:5] = 11 -> 8 bit
    // bit[4]   = 1  -> FIFO enable
    //----------------------------------------------------------

    `uvm_info(get_type_name(),
      "Configuring UART LCR_H",
      UVM_LOW)

    p_sequencer.ral_h.UARTLCR_H.write(status, 16'h0070);


    //----------------------------------------------------------
    // Configure FIFO interrupt level
    //
    // RXIFLSEL [5:3] = 010
    // => RX interrupt at >= 1/2 FIFO
    //
    // TXIFLSEL [2:0] = 010
    //
    // UARTIFLS = 0x12
    //----------------------------------------------------------

    `uvm_info(get_type_name(),
      "Setting RX FIFO interrupt level to 1/2 full",
      UVM_LOW)

    p_sequencer.ral_h.UARTIFLS.write(status, 16'h0012);


    //----------------------------------------------------------
    // Enable UART + RX
    //
    // UARTCR:
    //
    // UARTEN = bit[0] = 1
    // RXE    = bit[9] = 1
    //
    // 0x201
    //----------------------------------------------------------

    `uvm_info(get_type_name(),
      "Enabling UART RX",
      UVM_LOW)

    p_sequencer.ral_h.UARTCR.write(status, 16'h0201);


    //----------------------------------------------------------
    // Enable ONLY RX interrupt
    //
    // UARTIMSC[4] = RXIM
    //
    // 0x010
    //----------------------------------------------------------

    `uvm_info(get_type_name(),
      "Enabling RX interrupt: UARTIMSC[4]",
      UVM_LOW)

    p_sequencer.ral_h.UARTIMSC.write(status, 16'h0010);


    //----------------------------------------------------------
    // Verify initial interrupt state
    //----------------------------------------------------------

    `uvm_info(get_type_name(),
      "Checking initial RX interrupt state",
      UVM_LOW)

    if(p_sequencer.uart_cfg_h.uart_vif.UARTRXINTR !== 1'b0) begin

      `uvm_error(get_type_name(),
        "RX interrupt is asserted before receiving data")

    end
    else begin

      `uvm_info(get_type_name(),
        "Initial RX interrupt is LOW",
        UVM_LOW)

    end


    //----------------------------------------------------------
    // Send RX FRAME 1
    //----------------------------------------------------------

    send_rx_frame(8'h11);


    //----------------------------------------------------------
    // Send RX FRAME 2
    //----------------------------------------------------------

    send_rx_frame(8'h22);


    //----------------------------------------------------------
    // Send RX FRAME 3
    //----------------------------------------------------------

    send_rx_frame(8'h33);


    //----------------------------------------------------------
    // Send RX FRAME 4
    //
    // FIFO should now reach 1/2 full
    //----------------------------------------------------------

    send_rx_frame(8'h44);


    //----------------------------------------------------------
    // Allow DUT to update interrupt logic
    //----------------------------------------------------------

    repeat(10)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);


    //----------------------------------------------------------
    // Check RX interrupt pin
    //----------------------------------------------------------

    rx_intr =
      p_sequencer.uart_cfg_h.uart_vif.UARTRXINTR;

    $display("-----------------------------------------------");
    $display("RX INTERRUPT TEST");
    $display("UARTIMSC[4]  = 1");
    $display("RX FIFO      = 4 bytes");
    $display("RXIFLSEL     = 1/2");
    $display("UARTRXINTR   = %b", rx_intr);
    $display("-----------------------------------------------");


    if(rx_intr !== 1'b1) begin

      `uvm_error(get_type_name(),
        "RX interrupt FAILED: UARTRXINTR did not assert")

    end
    else begin

      `uvm_info(get_type_name(),
        "RX interrupt ASSERTED successfully",
        UVM_LOW)

    end


    //----------------------------------------------------------
    // Read RIS
    //
    // Expected:
    //
    // RIS[4] = 1
    //----------------------------------------------------------

    read_ris(ris_data);

    if(ris_data[4] !== 1'b1) begin

      `uvm_error(get_type_name(),
        $sformatf(
          "RXRIS FAILED: expected RIS[4]=1, RIS=%03h",
          ris_data))

    end
    else begin

      `uvm_info(get_type_name(),
        "RXRIS[4] is correctly asserted",
        UVM_LOW)

    end


    //----------------------------------------------------------
    // Read MIS
    //
    // MIS[4] = RIS[4] & IMSC[4]
    //
    // RIS[4] = 1
    // IMSC[4] = 1
    //
    // Therefore MIS[4] = 1
    //----------------------------------------------------------

    read_mis(mis_data);

    if(mis_data[4] !== 1'b1) begin

      `uvm_error(get_type_name(),
        $sformatf(
          "RXMIS FAILED: expected MIS[4]=1, MIS=%03h",
          mis_data))

    end
    else begin

      `uvm_info(get_type_name(),
        "RXMIS[4] is correctly asserted",
        UVM_LOW)

    end


    //----------------------------------------------------------
    // Clear RX interrupt
    //
    // UARTICR[4] = 1
    //----------------------------------------------------------

    clear_rx_interrupt();


    //----------------------------------------------------------
    // Allow clear to propagate
    //----------------------------------------------------------

    repeat(5)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);


    //----------------------------------------------------------
    // Check interrupt after clear
    //----------------------------------------------------------

    rx_intr =
      p_sequencer.uart_cfg_h.uart_vif.UARTRXINTR;

    $display("-----------------------------------------------");
    $display("AFTER RX INTERRUPT CLEAR");
    $display("UARTICR[4]   = 1");
    $display("UARTRXINTR   = %b", rx_intr);
    $display("-----------------------------------------------");


    if(rx_intr !== 1'b0) begin

      `uvm_error(get_type_name(),
        "RX interrupt FAILED to clear")

    end
    else begin

      `uvm_info(get_type_name(),
        "RX interrupt cleared successfully",
        UVM_LOW)

    end


    //----------------------------------------------------------
    // Read RIS again
    //----------------------------------------------------------

    read_ris(ris_data);

    $display("RIS after clear = %03h", ris_data);


    //----------------------------------------------------------
    // Disable UART
    //----------------------------------------------------------

    p_sequencer.ral_h.UARTCR.write(status, 16'h0000);

    `uvm_info(get_type_name(),
      "RX interrupt test completed",
      UVM_LOW)

  endtask

endclass