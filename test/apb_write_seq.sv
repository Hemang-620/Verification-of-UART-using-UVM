class apb_write_seq extends apb_base_sequence;

  `uvm_object_utils(apb_write_seq)

    bit [31:0] addr;
    bit [31:0] data;
    
  function new(string name="apb_write_seq");
    super.new(name);
  endfunction

  task body();

    req = apb_seq_item::type_id::create("req");

    start_item(req);

      req.pwrite = 1;
      req.paddr = addr;
      req.pwdata = data;
    
    finish_item(req);

  endtask

endclass