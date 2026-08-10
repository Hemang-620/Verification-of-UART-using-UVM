class apb_read_seq extends apb_base_sequence;

  `uvm_object_utils(apb_read_seq)

  bit [31:0] addr;
  bit [31:0] data;

  function new(string name="apb_read_seq");
    super.new(name);
  endfunction

  task body();

    req = apb_seq_item::type_id::create("req");

    start_item(req);

      req.pwrite = 0;
      req.paddr  = addr;

    finish_item(req);

    data = req.prdata;

  endtask

endclass