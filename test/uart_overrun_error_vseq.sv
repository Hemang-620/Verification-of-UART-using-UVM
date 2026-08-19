class uart_overrun_error_vseq extends base_virtual_sequence;

  `uvm_object_utils(uart_overrun_error_vseq)

  uart_tx_sequence tx_seq_h;

  function new(string name = "uart_overrun_error_vseq");
    super.new(name);
  endfunction

  task automatic send_frame(input bit [7:0] data);

    tx_seq_h = uart_tx_sequence::type_id::create("tx_seq_h");

    tx_seq_h.data        = data;
    tx_seq_h.wlen        = 2'b11;   // 8-bit
    tx_seq_h.parity_en   = 0;
    tx_seq_h.even_parity = 1;
    tx_seq_h.stop2       = 0;

    tx_seq_h.start(p_sequencer.uart_seqr);

    repeat(12 * p_sequencer.uart_cfg_h.cycles_per_bit)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

  endtask
  
  task automatic read_ris(output uvm_reg_data_t data);

    uvm_status_e status;

    p_sequencer.ral_h.UARTRIS.read(status, data);

    `uvm_info(get_type_name(),
      $sformatf("UARTRIS = %03h", data),
      UVM_LOW)

  endtask

  task automatic read_mis(output uvm_reg_data_t data);

    uvm_status_e status;

    p_sequencer.ral_h.UARTMIS.read(status, data);

    `uvm_info(get_type_name(),
      $sformatf("UARTMIS = %03h", data),
      UVM_LOW)

  endtask

  task automatic read_uartdr(output uvm_reg_data_t data);

    uvm_status_e status;

    p_sequencer.ral_h.UARTDR.read(status, data);

    `uvm_info(get_type_name(),
      $sformatf("UARTDR = %03h", data),
      UVM_LOW)

  endtask

  task automatic clear_overrun_error();

    uvm_status_e status;

    `uvm_info(get_type_name(),
      "Clearing overrun error using UARTECR[3]",
      UVM_LOW)

    // Bit [3] = Overrun Error Interrupt Clear
    p_sequencer.ral_h.UARTECR.write(status, 16'h0008);

    if (status != UVM_IS_OK) begin
      `uvm_error(get_type_name(),
        "UARTECR write failed while clearing OE")
    end

  endtask

  task body();

    uvm_status_e status;
    uvm_reg_data_t rd_data;

    int fifo_depth;
    int i;

    #100ns;

    `uvm_info(get_type_name(),
      "Configuring UART baud rate",
      UVM_LOW)

    p_sequencer.ral_h.UARTIBRD.write(
      status,
      16'd54
    );

    p_sequencer.ral_h.UARTFBRD.write(
      status,
      16'd16
    );

    p_sequencer.uart_cfg_h.ibdr = 54;
    p_sequencer.uart_cfg_h.fbdr = 16;

    p_sequencer.uart_cfg_h.calculate_timing();

    p_sequencer.ral_h.UARTLCR_H.write(
      status,
      16'h70
    );

    p_sequencer.ral_h.UARTCR.write(
      status,
      16'h301
    );

   p_sequencer.ral_h.UARTIMSC.write(
      status,
      16'h400
    );

    `uvm_info(get_type_name(),
      "Overrun Error Interrupt Enabled",
      UVM_LOW)

    fifo_depth = 8;

    `uvm_info(get_type_name(),
      $sformatf("RX FIFO depth = %0d", fifo_depth),
      UVM_LOW)


    `uvm_info(get_type_name(),
      "Filling RX FIFO...",
      UVM_LOW)

    for (i = 0; i < fifo_depth; i++) begin

      `uvm_info(get_type_name(),
        $sformatf("Sending FIFO fill frame %0d / %0d",
                  i + 1,
                  fifo_depth),
        UVM_LOW)

      send_frame(8'hA0 + i);

    end

    repeat(10)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);


   `uvm_info(get_type_name(),
  "RX FIFO fill frames sent.",
  UVM_LOW)


    //======================================================
    // Send ONE MORE frame
    //
    // FIFO is already full.
    //
    // DUT UART_RX receives this frame and at STOP:
    //
    // if(i_FIFO_Full)
    //     o_RX_Errs[3] <= 1'b1;
    //
    // Therefore OE should become asserted.
    //======================================================

    `uvm_info(get_type_name(),
      "Sending additional frame to generate Overrun Error",
      UVM_LOW)

    send_frame(8'hFF);

    repeat(20)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

    $display("");
    $display("==============================================");
    $display("        OVERRUN ERROR STATUS");
    $display("==============================================");

    $display("UARTTXINTR = %b",
      p_sequencer.uart_cfg_h.uart_vif.UARTTXINTR);

    $display("UARTRXINTR = %b",
      p_sequencer.uart_cfg_h.uart_vif.UARTRXINTR);

    $display("UARTRTINTR = %b",
      p_sequencer.uart_cfg_h.uart_vif.UARTRTINTR);

    $display("UARTEINTR  = %b",
      p_sequencer.uart_cfg_h.uart_vif.UARTEINTR);

    $display("==============================================");

    // OE = RIS[10]
   
    read_ris(rd_data);

    $display("RIS = %03h", rd_data);
    $display("RIS[10] OE = %b", rd_data[10]);


    if (rd_data[10] !== 1'b1) begin

      `uvm_error(get_type_name(),
        $sformatf(
          "Overrun Error NOT detected. RIS[10] = %b",
          rd_data[10]
        ))

    end
    else begin

      `uvm_info(get_type_name(),
        "Overrun Error detected in RIS[10]",
        UVM_LOW)

    end


    // OE = MIS[10]

    read_mis(rd_data);

    $display("MIS = %03h", rd_data);
    $display("MIS[10] OE = %b", rd_data[10]);


    if (rd_data[10] !== 1'b1) begin

      `uvm_error(get_type_name(),
        $sformatf(
          "Overrun Error NOT detected in MIS. MIS[10] = %b",
          rd_data[10]
        ))

    end
    else begin

      `uvm_info(get_type_name(),
        "Overrun Error detected in MIS[10]",
        UVM_LOW)

    end


    if (p_sequencer.uart_cfg_h.uart_vif.UARTEINTR !== 1'b1) begin

      `uvm_error(get_type_name(),
        "UARTEINTR was not asserted for Overrun Error")

    end
    else begin

      `uvm_info(get_type_name(),
        "UARTEINTR asserted for Overrun Error",
        UVM_LOW)

    end


    // OE is RX_DATA[11], mapped into UARTDR[11]

    read_uartdr(rd_data);

    $display("UARTDR = %03h", rd_data);
    $display("UARTDR[11] OE = %b", rd_data[11]);


    if (rd_data[11] !== 1'b1) begin

      `uvm_error(get_type_name(),
        $sformatf(
          "UARTDR OE bit not set. UARTDR[11] = %b",
          rd_data[11]
        ))

    end
    else begin

      `uvm_info(get_type_name(),
        "UARTDR[11] indicates Overrun Error",
        UVM_LOW)

    end

    clear_overrun_error();

    repeat(10)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

    read_ris(rd_data);

    $display("RIS AFTER CLEAR = %03h", rd_data);

    if (rd_data[10] === 1'b0) begin

      `uvm_info(get_type_name(),
        "Overrun Error successfully cleared",
        UVM_LOW)

    end
    else begin

      `uvm_warning(get_type_name(),
        "RIS[10] is still asserted after UARTECR[3] clear")
    end

    p_sequencer.ral_h.UARTCR.write(
      status,
      16'h0000
    );


    $display("");
    $display("==============================================");
    $display("       OVERRUN ERROR TEST COMPLETE");
    $display("==============================================");

  endtask

endclass