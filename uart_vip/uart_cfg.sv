class uart_cfg extends uvm_object;

  // Virtual Interface
  virtual uart_if uart_vif;

  // Agent Mode
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  // UART Frame Configuration
  bit [1:0] wlen        = 2'b11;
  bit       parity_en   = 0;
  bit       even_parity = 1;
  bit       stop2       = 0;

 // For Interrupt and Error Injection
  bit inject_parity_error = 0;
  bit inject_frame_error  = 0;

  //------------------------------------------------------
  // Baud Rate Configuration
  //------------------------------------------------------

  // Integer Baud Rate Divisor Register
  int unsigned ibdr = 1;

  // Fractional Baud Rate Divisor Register
  int unsigned fbdr = 0;

  // Baud Divisor = IBRD + (FBRD/64)
  real baud_div;

  // Number of PCLK cycles required for one UART bit
  int unsigned cycles_per_bit;

  `uvm_object_utils_begin(uart_cfg)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "uart_cfg");
    super.new(name);

  endfunction

  //------------------------------------------------------
  // Calculate UART Timing
  //------------------------------------------------------

  function void calculate_timing();

    baud_div = ibdr + (fbdr / 64.0);

    // One UART bit = 16 × BaudDiv PCLK cycles
    cycles_per_bit = (16 * ibdr) + (fbdr / 4);

  endfunction

endclass