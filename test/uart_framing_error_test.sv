class uart_framing_error_test extends base_test;

  `uvm_component_utils(uart_framing_error_test)

  uart_framing_error_vseq vseq;

  function new(
    string name = "uart_framing_error_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction


  virtual task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    `uvm_info(
      get_type_name(),
      "Running UART framing error test",
      UVM_LOW
    )

    vseq = uart_framing_error_vseq::type_id::create(
      "vseq"
    );

    vseq.start(env_h.v_seqr_h);

    phase.drop_objection(this);

  endtask

endclass