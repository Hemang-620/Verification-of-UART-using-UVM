class uart_interrupt_error_test extends base_test;

  `uvm_component_utils(uart_interrupt_error_test)

  uart_interrupt_error_vseq vseq;

  function new(string name="uart_interrupt_error_test",
               uvm_component parent=null);

      super.new(name,parent);

  endfunction


  task run_phase(uvm_phase phase);

      phase.raise_objection(this);

      vseq = uart_interrupt_error_vseq::type_id::create("vseq");

      vseq.start(env_h.v_seqr_h);

      phase.drop_objection(this);

  endtask

endclass