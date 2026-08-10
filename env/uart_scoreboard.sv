`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_tx)
`uvm_analysis_imp_decl(_rx)

class uart_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(uart_scoreboard)

  //----------------------------------------------------------
  // Analysis Imports
  //----------------------------------------------------------

  uvm_analysis_imp_apb #(apb_seq_item , uart_scoreboard) apb_imp;
  uvm_analysis_imp_tx  #(uart_seq_item, uart_scoreboard) tx_imp;
  uvm_analysis_imp_rx  #(uart_seq_item, uart_scoreboard) rx_imp;

  //----------------------------------------------------------
  // Queues
  //----------------------------------------------------------

  uart_seq_item tx_q[$];
  uart_seq_item rx_q[$];

  //----------------------------------------------------------
  // Statistics
  //----------------------------------------------------------

  int pass_count;
  int fail_count;

  //----------------------------------------------------------
  // Constructor
  //----------------------------------------------------------

  function new(string name="uart_scoreboard", uvm_component parent=null);
    super.new(name,parent);

    apb_imp = new("apb_imp",this);
    tx_imp  = new("tx_imp",this);
    rx_imp  = new("rx_imp",this);

  endfunction

  //----------------------------------------------------------
  // APB Transactions
  //----------------------------------------------------------

  function void write_apb(apb_seq_item xtn);

    `uvm_info(get_type_name(),$sformatf("\nAPB Transaction\n%s",xtn.sprint()),UVM_HIGH);

  endfunction

  //----------------------------------------------------------
  // TX Frame
  //----------------------------------------------------------

  function void write_tx(uart_seq_item xtn);

    uart_seq_item tx_copy;

    $cast(tx_copy,xtn.clone());

    tx_q.push_back(tx_copy);

    `uvm_info(get_type_name(),
      $sformatf("TX Frame Captured : %02h",tx_copy.data),
      UVM_LOW);

    compare_frames();

  endfunction

  //----------------------------------------------------------
  // RX Frame
  //----------------------------------------------------------

  function void write_rx(uart_seq_item xtn);

    uart_seq_item rx_copy;

    $cast(rx_copy,xtn.clone());

    rx_q.push_back(rx_copy);

    `uvm_info(get_type_name(),
      $sformatf("RX Frame Captured : %02h",rx_copy.data),
      UVM_LOW);

    compare_frames();

  endfunction

  //----------------------------------------------------------
  // Compare
  //----------------------------------------------------------
  function bit compare_uart_frame(
      uart_seq_item tx,
      uart_seq_item rx
  );

    bit match;

    match = 1'b1;

    //--------------------------------------------------------
    // DATA
    //--------------------------------------------------------

    if(tx.data != rx.data)
    begin

      `uvm_error(get_type_name(),
        $sformatf(
          "DATA MISMATCH : TX = %02h  RX = %02h",
          tx.data,
          rx.data))

      match = 1'b0;

    end


    //--------------------------------------------------------
    // WORD LENGTH
    //--------------------------------------------------------

    if(tx.wlen != rx.wlen)
    begin

      `uvm_error(get_type_name(),
        $sformatf(
          "WLEN MISMATCH : TX = %0d  RX = %0d",
          tx.wlen,
          rx.wlen))

      match = 1'b0;

    end


    //--------------------------------------------------------
    // PARITY ENABLE
    //--------------------------------------------------------

    if(tx.parity_en != rx.parity_en)
    begin

      `uvm_error(get_type_name(),
        $sformatf(
          "PARITY ENABLE MISMATCH : TX = %0b  RX = %0b",
          tx.parity_en,
          rx.parity_en))

      match = 1'b0;

    end


    //--------------------------------------------------------
    // PARITY TYPE
    //--------------------------------------------------------

    if(tx.even_parity != rx.even_parity)
    begin

      `uvm_error(get_type_name(),
        $sformatf(
          "PARITY TYPE MISMATCH : TX = %0b  RX = %0b",
          tx.even_parity,
          rx.even_parity))

      match = 1'b0;

    end

   if(tx.parity_en)
   begin

    if(tx.parity_bit != rx.parity_bit)
    begin

      `uvm_error(get_type_name(),
        $sformatf(
          "PARITY BIT MISMATCH : TX=%0b RX=%0b",
          tx.parity_bit,
          rx.parity_bit
        )
      )

      match = 1'b0;

    end

  end

    //--------------------------------------------------------
    // STOP BITS
    //--------------------------------------------------------

    if(tx.stop2 != rx.stop2)
    begin

      `uvm_error(get_type_name(),
        $sformatf(
          "STOP BIT MISMATCH : TX = %0b  RX = %0b",
          tx.stop2,
          rx.stop2))

      match = 1'b0;

    end

  //--------------------------------------------------------
  // ACTUAL FIRST STOP BIT
  //--------------------------------------------------------

  if(tx.stop_bit1 != rx.stop_bit1)
  begin

    `uvm_error(get_type_name(),
      $sformatf(
        "STOP BIT 1 MISMATCH : TX=%0b RX=%0b",
        tx.stop_bit1,
        rx.stop_bit1
      )
    )

    match = 1'b0;

  end


  //--------------------------------------------------------
  // ACTUAL SECOND STOP BIT
  //--------------------------------------------------------

  if(tx.stop2)
  begin

    if(tx.stop_bit2 != rx.stop_bit2)
    begin

      `uvm_error(get_type_name(),
        $sformatf(
          "STOP BIT 2 MISMATCH : TX=%0b RX=%0b",
          tx.stop_bit2,
          rx.stop_bit2
        )
      )

      match = 1'b0;

    end

  end


    //--------------------------------------------------------
    // Return Result
    //--------------------------------------------------------

    return match;

  endfunction

  function void compare_frames();

    uart_seq_item tx_xtn; 
    uart_seq_item rx_xtn;

    //------------------------------------------------------

    if(tx_q.size()==0)
      return;

    if(rx_q.size()==0)
      return;

    //------------------------------------------------------

    tx_xtn = tx_q.pop_front();
    rx_xtn = rx_q.pop_front();

    //------------------------------------------------------

     if(compare_uart_frame(tx_xtn,rx_xtn))
    begin

      pass_count++;

      `uvm_info(get_type_name(),
  $sformatf("UART LOOPBACK PASS: DATA=%02h WLEN=%0d PARITY_EN=%0b EVEN_PARITY=%0b STOP2=%0b",
            tx_xtn.data,
            tx_xtn.wlen,
            tx_xtn.parity_en,
            tx_xtn.even_parity,
            tx_xtn.stop2),
  UVM_LOW)

    end
    else
    begin

      fail_count++;

      `uvm_error(get_type_name(),
        "UART LOOPBACK FRAME COMPARISON FAILED")

    end

  endfunction


  //----------------------------------------------------------
  // Report
  //----------------------------------------------------------

  function void report_phase(uvm_phase phase);

  super.report_phase(phase);

  `uvm_info(get_type_name(),
  $sformatf("UART SCOREBOARD SUMMARY: PASS=%0d FAIL=%0d TX_QUEUE=%0d RX_QUEUE=%0d",
            pass_count,
            fail_count,
            tx_q.size(),
            rx_q.size()),
  UVM_NONE)

endfunction

endclass