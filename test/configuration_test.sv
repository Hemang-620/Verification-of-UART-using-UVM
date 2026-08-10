class configuration_test extends base_test;

  `uvm_component_utils(configuration_test)

  uart_configuration_vseq vseq_h;

  function new(string name="configuration_test",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    vseq_h = uart_configuration_vseq::type_id::create("vseq_h");

    vseq_h.start(env_h.v_seqr_h);

    phase.drop_objection(this);

  endtask

endclass