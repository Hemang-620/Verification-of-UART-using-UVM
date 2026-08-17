class uart_dr_reg extends uvm_reg;

  `uvm_object_utils(uart_dr_reg)

  rand uvm_reg_field DATA;

  function new(string name="uart_dr_reg");
      super.new(name,16,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();

      DATA = uvm_reg_field::type_id::create("DATA");

      DATA.configure(
          this,
          8,
          0,
          "RW",
          0,
          0,
          1,
          1,
          0
      );

  endfunction
endclass

class uart_ecr_reg extends uvm_reg;

  `uvm_object_utils(uart_ecr_reg)

  uvm_reg_field error_clear;

  function new(string name="uart_ecr_reg");
    super.new(name, 16, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();

    error_clear = uvm_reg_field::type_id::create("error_clear");
    error_clear.configure(
      this,
      4,         // size
      0,         // lsb
      "WO",
      0,
      4'h0,
      1,
      0,
      0
    );

  endfunction

endclass


class uart_ibrd_reg extends uvm_reg;

  `uvm_object_utils(uart_ibrd_reg)

  rand uvm_reg_field BAUD_DIV_INT;

  function new(string name="uart_ibrd_reg");
    super.new(name,16,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();

    BAUD_DIV_INT = uvm_reg_field::type_id::create("BAUD_DIV_INT");

    BAUD_DIV_INT.configure(
        this,
        16,                 // number of bits
        0,                  // lsb position
        "RW",               // access
        0,                  // volatile
        16'h0000,           // reset value
        1,                  // has reset
        1,                  // is rand
        0                   // individually accessible
    );

  endfunction

endclass

class uart_fbrd_reg extends uvm_reg;

  `uvm_object_utils(uart_fbrd_reg)

  rand uvm_reg_field BAUD_DIV_FRAC;

  function new(string name="uart_fbrd_reg");
    super.new(name,16,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();

    BAUD_DIV_FRAC = uvm_reg_field::type_id::create("BAUD_DIV_FRAC");

    BAUD_DIV_FRAC.configure(
        this,
        6,
        0,
        "RW",
        0,
        6'h00,
        1,
        1,
        0
    );

  endfunction

endclass

class uart_lcr_h_reg extends uvm_reg;

  `uvm_object_utils(uart_lcr_h_reg)

  rand uvm_reg_field BRK;
  rand uvm_reg_field PEN;
  rand uvm_reg_field EPS;
  rand uvm_reg_field STP2;
  rand uvm_reg_field FEN;
  rand uvm_reg_field WLEN;
  rand uvm_reg_field SPS;

  function new(string name="uart_lcr_h_reg");

    super.new(name,16,UVM_NO_COVERAGE);

  endfunction

  virtual function void build();

    //-------------------------------------------------
    // BRK
    //-------------------------------------------------

    BRK = uvm_reg_field::type_id::create("BRK");

    BRK.configure(
        this,
        1,
        0,
        "RW",
        0,
        0,
        1,
        1,
        0
    );

    //-------------------------------------------------
    // PEN
    //-------------------------------------------------

    PEN = uvm_reg_field::type_id::create("PEN");

    PEN.configure(
        this,
        1,
        1,
        "RW",
        0,
        0,
        1,
        1,
        0
    );

    //-------------------------------------------------
    // EPS
    //-------------------------------------------------

    EPS = uvm_reg_field::type_id::create("EPS");

    EPS.configure(
        this,
        1,
        2,
        "RW",
        0,
        0,
        1,
        1,
        0
    );

    //-------------------------------------------------
    // STP2
    //-------------------------------------------------

    STP2 = uvm_reg_field::type_id::create("STP2");

    STP2.configure(
        this,
        1,
        3,
        "RW",
        0,
        0,
        1,
        1,
        0
    );

    //-------------------------------------------------
    // FEN
    //-------------------------------------------------

    FEN = uvm_reg_field::type_id::create("FEN");

    FEN.configure(
        this,
        1,
        4,
        "RW",
        0,
        0,
        1,
        1,
        0
    );

    //-------------------------------------------------
    // WLEN
    //-------------------------------------------------

    WLEN = uvm_reg_field::type_id::create("WLEN");

    WLEN.configure(
        this,
        2,
        5,
        "RW",
        0,
        2'b11,
        1,
        1,
        0
    );

    //-------------------------------------------------
    // SPS
    //-------------------------------------------------

    SPS = uvm_reg_field::type_id::create("SPS");

    SPS.configure(
        this,
        1,
        7,
        "RW",
        0,
        0,
        1,
        1,
        0
    );

  endfunction

endclass

class uart_cr_reg extends uvm_reg;

  `uvm_object_utils(uart_cr_reg)

  rand uvm_reg_field UARTEN;
  rand uvm_reg_field LBE;
  rand uvm_reg_field TXE;
  rand uvm_reg_field RXE;

  function new(string name="uart_cr_reg");
    super.new(name,16,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();

    //-------------------------------------------------
    // UART Enable
    //-------------------------------------------------
    UARTEN = uvm_reg_field::type_id::create("UARTEN");

    UARTEN.configure(
        this,
        1,
        0,
        "RW",
        0,
        0,
        1,
        1,
        0
    );

    //-------------------------------------------------
    // Loopback Enable
    //-------------------------------------------------
    LBE = uvm_reg_field::type_id::create("LBE");

    LBE.configure(
        this,
        1,
        7,
        "RW",
        0,
        0,
        1,
        1,
        0
    );

    //-------------------------------------------------
    // TX Enable
    //-------------------------------------------------
    TXE = uvm_reg_field::type_id::create("TXE");

    TXE.configure(
        this,
        1,
        8,
        "RW",
        0,
        0,
        1,
        1,
        0
    );

    //-------------------------------------------------
    // RX Enable
    //-------------------------------------------------
    RXE = uvm_reg_field::type_id::create("RXE");

    RXE.configure(
        this,
        1,
        9,
        "RW",
        0,
        0,
        1,
        1,
        0
    );

  endfunction

endclass

class uart_fr_reg extends uvm_reg;

  `uvm_object_utils(uart_fr_reg)

  uvm_reg_field BUSY;
  uvm_reg_field RXFE;
  uvm_reg_field TXFF;
  uvm_reg_field RXFF;
  uvm_reg_field TXFE;

  function new(string name="uart_fr_reg");
    super.new(name,16,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();

    //-------------------------------------------------
    // BUSY
    //-------------------------------------------------
    BUSY = uvm_reg_field::type_id::create("BUSY");

    BUSY.configure(
        this,
        1,
        3,
        "RO",
        0,
        0,
        1,
        0,
        0
    );

    //-------------------------------------------------
    // RX FIFO EMPTY
    //-------------------------------------------------
    RXFE = uvm_reg_field::type_id::create("RXFE");

    RXFE.configure(
        this,
        1,
        4,
        "RO",
        0,
        1,
        1,
        0,
        0
    );

    //-------------------------------------------------
    // TX FIFO FULL
    //-------------------------------------------------
    TXFF = uvm_reg_field::type_id::create("TXFF");

    TXFF.configure(
        this,
        1,
        5,
        "RO",
        0,
        0,
        1,
        0,
        0
    );

    //-------------------------------------------------
    // RX FIFO FULL
    //-------------------------------------------------
    RXFF = uvm_reg_field::type_id::create("RXFF");

    RXFF.configure(
        this,
        1,
        6,
        "RO",
        0,
        0,
        1,
        0,
        0
    );

    //-------------------------------------------------
    // TX FIFO EMPTY
    //-------------------------------------------------
    TXFE = uvm_reg_field::type_id::create("TXFE");

    TXFE.configure(
        this,
        1,
        7,
        "RO",
        0,
        1,
        1,
        0,
        0
    );

  endfunction

endclass

class uart_ifls_reg extends uvm_reg;

  `uvm_object_utils(uart_ifls_reg)

  rand uvm_reg_field TXIFLSEL;
  rand uvm_reg_field RXIFLSEL;

  function new(string name = "uart_ifls_reg");
    super.new(name,16,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();

    //-------------------------------------------------
    // TX FIFO Interrupt Level Select
    //-------------------------------------------------

    TXIFLSEL = uvm_reg_field::type_id::create("TXIFLSEL");

    TXIFLSEL.configure(
        this,
        3,          // width
        0,          // lsb
        "RW",
        0,
        3'd2,       // reset value (matches your RTL)
        1,
        1,
        0
    );

    //-------------------------------------------------
    // RX FIFO Interrupt Level Select
    //-------------------------------------------------

    RXIFLSEL = uvm_reg_field::type_id::create("RXIFLSEL");

    RXIFLSEL.configure(
        this,
        3,
        3,
        "RW",
        0,
        3'd2,       // reset value (matches your RTL)
        1,
        1,
        0
    );

  endfunction

endclass

class uart_imsc_reg extends uvm_reg;

  `uvm_object_utils(uart_imsc_reg)

  rand uvm_reg_field IMSC_MASK;

  function new(string name="uart_imsc_reg");
    super.new(name,16,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();

    //-------------------------------------------------
    // Interrupt Mask Register
    //-------------------------------------------------

    IMSC_MASK = uvm_reg_field::type_id::create("IMSC_MASK");

    IMSC_MASK.configure(
        this,
        11,         // width
        0,          // lsb position
        "RW",
        0,          // non-volatile
        11'h000,    // reset value
        1,          // has reset
        1,          // rand
        0           // individually accessible
    );

  endfunction

endclass

class uart_ris_reg extends uvm_reg;

  `uvm_object_utils(uart_ris_reg)

  uvm_reg_field RIS;

  function new(string name="uart_ris_reg");
    super.new(name,16,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();

    RIS = uvm_reg_field::type_id::create("RIS");

    RIS.configure(
        this,
        11,
        0,
        "RO",
        0,
        11'h000,
        1,
        0,
        0
    );

  endfunction

endclass

class uart_mis_reg extends uvm_reg;

  `uvm_object_utils(uart_mis_reg)

  uvm_reg_field MIS;

  function new(string name="uart_mis_reg");
    super.new(name,16,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();

    MIS = uvm_reg_field::type_id::create("MIS");

    MIS.configure(
        this,
        11,
        0,
        "RO",
        0,
        11'h000,
        1,
        0,
        0
    );

  endfunction

endclass

class uart_icr_reg extends uvm_reg;

  `uvm_object_utils(uart_icr_reg)

  rand uvm_reg_field ICR;

  function new(string name="uart_icr_reg");
    super.new(name,16,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();

    ICR = uvm_reg_field::type_id::create("ICR");

    ICR.configure(
        this,
        11,
        0,
        "WO",
        0,
        11'h000,
        1,
        1,
        0
    );

  endfunction

endclass