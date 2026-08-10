class uart_reg_block extends uvm_reg_block;

  `uvm_object_utils(uart_reg_block)

  //-----------------------------------------
  // Register Handles
  //-----------------------------------------

  uart_dr_reg      UARTDR;
  uart_ibrd_reg    UARTIBRD;
  uart_fbrd_reg    UARTFBRD;
  uart_lcr_h_reg   UARTLCR_H;
  uart_cr_reg      UARTCR;
  uart_fr_reg      UARTFR;
  uart_ifls_reg    UARTIFLS;
  uart_imsc_reg    UARTIMSC;
  uart_ris_reg     UARTRIS;
  uart_mis_reg     UARTMIS;
  uart_icr_reg     UARTICR;

  //-----------------------------------------
  // Address Map
  //-----------------------------------------

  function new(string name="uart_reg_block");

    super.new(name,UVM_NO_COVERAGE);

  endfunction

  virtual function void build();

    //------------------------------------------------
    // Create Address Map
    //------------------------------------------------

    default_map = create_map("default_map",
                         'h0,        // Base Address
                         2,          // Bus Width (4 bytes)
                         UVM_LITTLE_ENDIAN);

    //------------------------------------------------
    // UARTDR
    //------------------------------------------------

    UARTDR = uart_dr_reg::type_id::create("UARTDR");
    UARTDR.build();
    UARTDR.configure(this);
    default_map.add_reg(UARTDR,'h000,"RW");

    //------------------------------------------------
    // UARTFR
    //------------------------------------------------

    UARTFR = uart_fr_reg::type_id::create("UARTFR");
    UARTFR.build();
    UARTFR.configure(this);
    default_map.add_reg(UARTFR,'h018,"RO");

    //------------------------------------------------
    // UARTIBRD
    //------------------------------------------------

    UARTIBRD = uart_ibrd_reg::type_id::create("UARTIBRD");
    UARTIBRD.build();
    UARTIBRD.configure(this);
    default_map.add_reg(UARTIBRD,'h024,"RW");

    //------------------------------------------------
    // UARTFBRD
    //------------------------------------------------

    UARTFBRD = uart_fbrd_reg::type_id::create("UARTFBRD");
    UARTFBRD.build();
    UARTFBRD.configure(this);
    default_map.add_reg(UARTFBRD,'h028,"RW");

    //------------------------------------------------
    // UARTLCR_H
    //------------------------------------------------

    UARTLCR_H = uart_lcr_h_reg::type_id::create("UARTLCR_H");
    UARTLCR_H.build();
    UARTLCR_H.configure(this);
    default_map.add_reg(UARTLCR_H,'h02C,"RW");

    //------------------------------------------------
    // UARTCR
    //------------------------------------------------

    UARTCR = uart_cr_reg::type_id::create("UARTCR");
    UARTCR.build();
    UARTCR.configure(this);
    default_map.add_reg(UARTCR,'h030,"RW");

    //------------------------------------------------
    // UARTIFLS
    //------------------------------------------------

    UARTIFLS = uart_ifls_reg::type_id::create("UARTIFLS");
    UARTIFLS.build();
    UARTIFLS.configure(this);
    default_map.add_reg(UARTIFLS,'h034,"RW");

    //------------------------------------------------
    // UARTIMSC
    //------------------------------------------------

    UARTIMSC = uart_imsc_reg::type_id::create("UARTIMSC");
    UARTIMSC.build();
    UARTIMSC.configure(this);
    default_map.add_reg(UARTIMSC,'h038,"RW");

    //------------------------------------------------
    // UARTRIS
    //------------------------------------------------

    UARTRIS = uart_ris_reg::type_id::create("UARTRIS");
    UARTRIS.build();
    UARTRIS.configure(this);
    default_map.add_reg(UARTRIS,'h03C,"RO");

    //------------------------------------------------
    // UARTMIS
    //------------------------------------------------

    UARTMIS = uart_mis_reg::type_id::create("UARTMIS");
    UARTMIS.build();
    UARTMIS.configure(this);
    default_map.add_reg(UARTMIS,'h040,"RO");

    //------------------------------------------------
    // UARTICR
    //------------------------------------------------

    UARTICR = uart_icr_reg::type_id::create("UARTICR");
    UARTICR.build();
    UARTICR.configure(this);
    default_map.add_reg(UARTICR,'h044,"WO");

  endfunction

endclass