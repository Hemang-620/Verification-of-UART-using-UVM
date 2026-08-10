class basic_rx_test extends base_test;

  `uvm_component_utils(basic_rx_test)

  uart_basic_rx_vseq vseq_h;

  function new(string name="basic_rx_test",uvm_component parent=null);
      super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      vseq_h = uart_basic_rx_vseq::type_id::create("vseq_h");
      vseq_h.start(env_h.v_seqr_h);
      phase.drop_objection(this);
  endtask

endclass