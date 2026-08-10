class uart_loopback_vseq extends base_virtual_sequence;

  `uvm_object_utils(uart_loopback_vseq)

  function new(string name="uart_loopback_vseq");
    super.new(name);
  endfunction


task automatic send_and_check(
    input bit [7:0] tx_data
);

    uvm_status_e   status;
    uvm_reg_data_t rd_data;
    bit [7:0]      expected_data;

    //-------------------------------------------------------
    // Write UARTDR (starts DUT transmission)
    //-------------------------------------------------------

    `uvm_info(get_type_name(),
      $sformatf("Writing UARTDR = %02h", tx_data),
      UVM_LOW)

    p_sequencer.ral_h.UARTDR.write(status, tx_data);

    //-------------------------------------------------------
    // Wait for transmission + loopback reception
    //-------------------------------------------------------

    repeat(15 * p_sequencer.uart_cfg_h.cycles_per_bit)
      @(posedge p_sequencer.uart_cfg_h.uart_vif.PCLK);

    //-------------------------------------------------------
    // Read UARTDR (RX FIFO)
    //-------------------------------------------------------

    p_sequencer.ral_h.UARTDR.read(status, rd_data);

    //-------------------------------------------------------
    // Calculate expected RX data
    //-------------------------------------------------------

    expected_data = get_expected_data(
        tx_data,
        p_sequencer.uart_cfg_h.wlen
    );

    //-------------------------------------------------------
    // Compare
    //-------------------------------------------------------

    if(rd_data[7:0] == expected_data) begin

      `uvm_info(get_type_name(),
        $sformatf(
          "LOOPBACK PASS  TX=%02h RX=%02h EXPECTED=%02h",
          tx_data,
          rd_data[7:0],
          expected_data
        ),
        UVM_LOW
      )

    end
    else begin

      `uvm_error(get_type_name(),
        $sformatf(
          "LOOPBACK FAILED  TX=%02h RX=%02h EXPECTED=%02h",
          tx_data,
          rd_data[7:0],
          expected_data
        )
      )

    end

endtask

//------------------------------------------------------------
// Calculate expected RX data according to word length
//------------------------------------------------------------

function automatic bit [7:0] get_expected_data(
    input bit [7:0] data,
    input bit [1:0] wlen
);

    case (wlen)

        2'b00: begin
            // 5-bit mode
            get_expected_data = data & 8'h1F;
        end

        2'b01: begin
            // 6-bit mode
            get_expected_data = data & 8'h3F;
        end

        2'b10: begin
            // 7-bit mode
            get_expected_data = data & 8'h7F;
        end

        2'b11: begin
            // 8-bit mode
            get_expected_data = data;
        end

        default: begin
            get_expected_data = data;
        end

    endcase

endfunction


  task body();

  uvm_status_e status;

  //-------------------------------------------------------
  // Baud Configuration
  //-------------------------------------------------------
  #100ns;
  p_sequencer.ral_h.UARTIBRD.write(status,16'd54);
  p_sequencer.ral_h.UARTFBRD.write(status,16'd16);

  p_sequencer.uart_cfg_h.ibdr = 54;
  p_sequencer.uart_cfg_h.fbdr = 16;
  p_sequencer.uart_cfg_h.calculate_timing();

  //-------------------------------------------------------
  // Enable UART + Loopback + TX + RX
  //-------------------------------------------------------

  p_sequencer.ral_h.UARTCR.write(status,16'h381);

  //-------------------------------------------------------
  // 5-bit, No Parity, 1 Stop
  //-------------------------------------------------------

  `uvm_info(get_type_name(),"===== 5-BIT MODE =====",UVM_LOW)

  p_sequencer.uart_cfg_h.wlen        = 2'b00;
  p_sequencer.uart_cfg_h.parity_en   = 0;
  p_sequencer.uart_cfg_h.even_parity = 0;
  p_sequencer.uart_cfg_h.stop2       = 0;

  p_sequencer.ral_h.UARTLCR_H.write(status,16'h00);

  send_and_check(8'h15);
  send_and_check(8'h2A);

  //-------------------------------------------------------
  // 6-bit, Even Parity
  //-------------------------------------------------------

  `uvm_info(get_type_name(),"===== 6-BIT EVEN PARITY =====",UVM_LOW)

  p_sequencer.uart_cfg_h.wlen        = 2'b01;
  p_sequencer.uart_cfg_h.parity_en   = 1;
  p_sequencer.uart_cfg_h.even_parity = 1;
  p_sequencer.uart_cfg_h.stop2       = 0;

  p_sequencer.ral_h.UARTLCR_H.write(status,16'h46);

  send_and_check(8'h55);
  send_and_check(8'hA5);

  //-------------------------------------------------------
  // 7-bit, Odd Parity
  //-------------------------------------------------------

  `uvm_info(get_type_name(),"===== 7-BIT ODD PARITY =====",UVM_LOW)

  p_sequencer.uart_cfg_h.wlen        = 2'b10;
  p_sequencer.uart_cfg_h.parity_en   = 1;
  p_sequencer.uart_cfg_h.even_parity = 0;
  p_sequencer.uart_cfg_h.stop2       = 0;

  p_sequencer.ral_h.UARTLCR_H.write(status,16'h62);

  send_and_check(8'h96);
  send_and_check(8'h69);

  //-------------------------------------------------------
  // 8-bit, No Parity, 2 Stop Bits
  //-------------------------------------------------------

  `uvm_info(get_type_name(),"===== 8-BIT TWO STOP =====",UVM_LOW)

  p_sequencer.uart_cfg_h.wlen        = 2'b11;
  p_sequencer.uart_cfg_h.parity_en   = 0;
  p_sequencer.uart_cfg_h.even_parity = 0;
  p_sequencer.uart_cfg_h.stop2       = 1;

  p_sequencer.ral_h.UARTLCR_H.write(status,16'h68);

  send_and_check(8'h3C);
  send_and_check(8'hC3);

  //-------------------------------------------------------
  // Disable UART
  //-------------------------------------------------------

  p_sequencer.ral_h.UARTCR.write(status,16'h000);

endtask

endclass