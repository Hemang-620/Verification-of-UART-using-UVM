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

    if(tx_xtn.compare(rx_xtn))
    begin

      pass_count++;

      `uvm_info(get_type_name(),
      $sformatf(
      "\nLOOPBACK PASS\nTX = %02h\nRX = %02h",
      tx_xtn.data,
      rx_xtn.data),
      UVM_LOW);

    end

    else
    begin

      fail_count++;

      `uvm_error(get_type_name(),
      $sformatf(
      "\nLOOPBACK FAIL\nTX = %02h\nRX = %02h",
      tx_xtn.data,
      rx_xtn.data));

    end

  endfunction

  //----------------------------------------------------------
  // Report
  //----------------------------------------------------------

  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info(get_type_name(),
      $sformatf("\n======================================\n\
UART SCOREBOARD SUMMARY\n\
--------------------------------------\n\
PASS = %0d\n\
FAIL = %0d\n\
======================================",
      pass_count,
      fail_count),
      UVM_NONE);

  endfunction

endclass