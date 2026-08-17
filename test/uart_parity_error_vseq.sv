class uart_parity_error_vseq extends base_virtual_sequence;

  `uvm_object_utils(uart_parity_error_vseq)

  uart_tx_sequence rx_seq_h;

  function new(string name = "uart_parity_error_vseq");
    super.new(name);
  endfunction


  //------------------------------------------------------------
  // Send UART frame with WRONG parity
  //
  // DUT will be configured for EVEN parity.
  // VIP will send ODD parity.
  //
  // Therefore DUT should detect PE.
  //------------------------------------------------------------

  task automatic send_parity_error_frame(input bit [7:0] data);

    rx_seq_h = uart_tx_sequence::type_id::create("rx_seq_h");

    rx_seq_h.data        = data;
    rx_seq_h.wlen        = 2'b11;     // 8-bit
    rx_seq_h.parity_en   = 1;         // parity enabled
    rx_seq_h.even_parity = 0;         // ODD parity from VIP
    rx_seq_h.stop2       = 0;         // 1 stop bit


    `uvm_info(get_type_name(),
      $sformatf(
        "Sending RX frame with WRONG parity: data=%02h, VIP parity=ODD",
        data),
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
  // Read UARTDR
  //
  // RX FIFO format:
  //
  // [11] OE
  // [10] BE
  // [9]  PE
  // [8]  FE
  // [7:0] DATA
  //------------------------------------------------------------

  task automatic read_uartdr(output uvm_reg_data_t data);

    uvm_status_e status;

    p_sequencer.ral_h.UARTDR.read(status, data);

    `uvm_info(get_type_name(),
      $sformatf("UARTDR = %03h", data),
      UVM_LOW)

    if(status != UVM_IS_OK) begin
      `uvm_error(get_type_name(),
        "UARTDR read failed")
    end

  endtask



  //------------------------------------------------------------
  // Clear parity error
  //
  // UARTECR[1] = PE
  //
  // Writing 1 clears parity error.
  //------------------------------------------------------------

   task automatic clear_parity_error();

  uvm_status_e status;

  `uvm_info(get_type_name(),
    "Clearing parity error using UARTECR[1]",
    UVM_LOW)

//   ecr = p_sequencer.ral_h.get_reg_by_name("UARTECR");

  if (p_sequencer.ral_h.UARTECR == null) begin
    `uvm_fatal("RAL",
      "UARTECR NOT FOUND IN RAL BLOCK")
  end

//   `uvm_info("RAL",
//     $sformatf("Found register: %s", ecr.get_full_name()),
//     UVM_LOW)

  p_sequencer.ral_h.UARTECR.write(status, 16'h0002);

  if (status != UVM_IS_OK) begin
    `uvm_error(get_type_name(),
      "UARTECR write failed")
  end

endtask



  //------------------------------------------------------------
  // BODY
  //------------------------------------------------------------

  task body();

    uvm_status_e   status;
    uvm_reg_data_t ris_data;
    uvm_reg_data_t mis_data;
    uvm_reg_data_t dr_data;

    bit error_intr;


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
    // EVEN parity
    // Parity ENABLED
    // 1 stop bit
    // FIFO ENABLED
    //
    // UARTLCR_H = 0x76
    //
    // bit[6:5] = 11 -> 8 bit
    // bit[4]   = 1  -> FIFO enable
    // bit[2]   = 1  -> EVEN parity
    // bit[1]   = 1  -> parity enable
    //----------------------------------------------------------

    `uvm_info(get_type_name(),
      "Configuring UART LCR_H for EVEN parity",
      UVM_LOW)

    p_sequencer.ral_h.UARTLCR_H.write(status, 16'h0076);



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
    // Enable ONLY parity error interrupt
    //
    // UARTIMSC[8] = PEIM
    //
    // 0x100
    //----------------------------------------------------------

    `uvm_info(get_type_name(),
      "Enabling parity error interrupt: UARTIMSC[8]",
      UVM_LOW)

    p_sequencer.ral_h.UARTIMSC.write(status, 16'h0100);



    //----------------------------------------------------------
    // Verify initial error interrupt state
    //----------------------------------------------------------

    `uvm_info(get_type_name(),
      "Checking initial error interrupt state",
      UVM_LOW)

    if(p_sequencer.uart_cfg_h.uart_vif.UARTEINTR !== 1'b0) begin

      `uvm_error(get_type_name(),
        "Error interrupt is asserted before parity error")

    end
    else begin

      `uvm_info(get_type_name(),
        "Initial error interrupt is LOW",
        UVM_LOW)

    end



    //----------------------------------------------------------
    // Send frame with WRONG parity
    //
    // DUT expects EVEN
    // VIP sends ODD
    //----------------------------------------------------------

    send_parity_error_frame(8'h55);



    //----------------------------------------------------------
    // Allow DUT to update error status
    //----------------------------------------------------------

    repeat(10)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);



    //----------------------------------------------------------
    // Check error interrupt
    //----------------------------------------------------------

    error_intr =
      p_sequencer.uart_cfg_h.uart_vif.UARTEINTR;


    $display("-----------------------------------------------");
    $display("PARITY ERROR TEST");
    $display("UARTIMSC[8]  = 1");
    $display("DUT PARITY   = EVEN");
    $display("VIP PARITY   = ODD");
    $display("DATA         = 55");
    $display("UARTEINTR    = %b", error_intr);
    $display("-----------------------------------------------");


    if(error_intr !== 1'b1) begin

      `uvm_error(get_type_name(),
        "PARITY ERROR FAILED: UARTEINTR did not assert")

    end
    else begin

      `uvm_info(get_type_name(),
        "PARITY ERROR INTERRUPT ASSERTED successfully",
        UVM_LOW)

    end



    //----------------------------------------------------------
    // Read RIS
    //
    // Expected:
    //
    // RIS[8] = 1
    //----------------------------------------------------------

    read_ris(ris_data);


    if(ris_data[8] !== 1'b1) begin

      `uvm_error(get_type_name(),
        $sformatf(
          "PARITY RIS FAILED: expected RIS[8]=1, RIS=%03h",
          ris_data))

    end
    else begin

      `uvm_info(get_type_name(),
        "RIS[8] is correctly asserted for parity error",
        UVM_LOW)

    end



    //----------------------------------------------------------
    // Read MIS
    //
    // MIS[8] = RIS[8] & IMSC[8]
    //
    // RIS[8]  = 1
    // IMSC[8] = 1
    //
    // Therefore MIS[8] = 1
    //----------------------------------------------------------

    read_mis(mis_data);


    if(mis_data[8] !== 1'b1) begin

      `uvm_error(get_type_name(),
        $sformatf(
          "PARITY MIS FAILED: expected MIS[8]=1, MIS=%03h",
          mis_data))

    end
    else begin

      `uvm_info(get_type_name(),
        "MIS[8] is correctly asserted for parity error",
        UVM_LOW)

    end



    //----------------------------------------------------------
    // Read UARTDR
    //
    // Expected:
    //
    // UARTDR[9] = PE
    //----------------------------------------------------------

    read_uartdr(dr_data);


    $display("-----------------------------------------------");
    $display("UARTDR PARITY STATUS");
    $display("UARTDR      = %03h", dr_data);
    $display("DATA        = %02h", dr_data[7:0]);
    $display("FE          = %b", dr_data[8]);
    $display("PE          = %b", dr_data[9]);
    $display("BE          = %b", dr_data[10]);
    $display("OE          = %b", dr_data[11]);
    $display("-----------------------------------------------");


    if(dr_data[9] !== 1'b1) begin

      `uvm_error(get_type_name(),
        $sformatf(
          "UARTDR FAILED: expected PE bit [9]=1, UARTDR=%03h",
          dr_data))

    end
    else begin

      `uvm_info(get_type_name(),
        "UARTDR[9] correctly indicates PARITY ERROR",
        UVM_LOW)

    end



    //----------------------------------------------------------
    // Clear parity error
    //
    // UARTECR[1] = 1
    //----------------------------------------------------------

    clear_parity_error();



    //----------------------------------------------------------
    // Allow clear to propagate
    //----------------------------------------------------------

    repeat(5)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);



    //----------------------------------------------------------
    // Check error interrupt after clear
    //----------------------------------------------------------

    error_intr =
      p_sequencer.uart_cfg_h.uart_vif.UARTEINTR;


    $display("-----------------------------------------------");
    $display("AFTER PARITY ERROR CLEAR");
    $display("UARTECR[1]   = 1");
    $display("UARTEINTR    = %b", error_intr);
    $display("-----------------------------------------------");


    if(error_intr !== 1'b0) begin

      `uvm_error(get_type_name(),
        "PARITY ERROR INTERRUPT FAILED to clear")

    end
    else begin

      `uvm_info(get_type_name(),
        "PARITY ERROR INTERRUPT cleared successfully",
        UVM_LOW)

    end



    //----------------------------------------------------------
    // Disable UART
    //----------------------------------------------------------

    p_sequencer.ral_h.UARTCR.write(status, 16'h0000);


    `uvm_info(get_type_name(),
      "Parity error test completed",
      UVM_LOW)

  endtask

endclass