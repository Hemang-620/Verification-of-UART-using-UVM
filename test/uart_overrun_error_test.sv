class uart_overrun_error_test extends base_test;

  `uvm_component_utils(uart_overrun_error_test)

  uart_overrun_error_vseq vseq_h;

  function new(
    string name = "uart_overrun_error_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

  endfunction

  virtual task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    `uvm_info(get_type_name(),
      "==============================================",
      UVM_LOW)

    `uvm_info(get_type_name(),
      "Starting UART Overrun Error Test",
      UVM_LOW)

    `uvm_info(get_type_name(),
      "==============================================",
      UVM_LOW)

    vseq_h = uart_overrun_error_vseq::type_id::create(
      "vseq_h"
    );

    vseq_h.start(env_h.v_seqr_h);


    `uvm_info(get_type_name(),
      "UART Overrun Error Test Completed",
      UVM_LOW)


    phase.drop_objection(this);

  endtask

endclass