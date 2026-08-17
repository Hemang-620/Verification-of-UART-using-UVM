class uart_parity_error_test extends base_test;

  `uvm_component_utils(uart_parity_error_test)

  function new(
      string name = "uart_parity_error_test",uvm_component parent = null);

    super.new(name, parent);

  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

  endfunction

  task run_phase(uvm_phase phase);

    uart_parity_error_vseq vseq_h;

    phase.raise_objection(this);

    vseq_h = uart_parity_error_vseq::type_id::create("vseq_h");

    `uvm_info(get_type_name(),
      "Starting UART Parity Error Test",
      UVM_LOW)

    vseq_h.start(env_h.v_seqr_h);

    `uvm_info(get_type_name(),
      "UART Parity Error Test Completed",
      UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass