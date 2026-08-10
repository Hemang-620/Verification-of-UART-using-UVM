class uart_register_write_read_test extends base_test;

  `uvm_component_utils(uart_register_write_read_test)

  uart_register_write_read_vseq vseq_h;

  function new(string name="uart_register_write_read_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction


  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    vseq_h = uart_register_write_read_vseq::type_id::create("vseq_h");

    vseq_h.start(env_h.v_seqr_h);

    phase.drop_objection(this);

  endtask

endclass