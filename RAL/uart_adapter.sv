
class uart_adapter extends uvm_reg_adapter;

  `uvm_object_utils(uart_adapter)

  function new(string name="uart_adapter");
    super.new(name);

    // APB does not support byte enables
    supports_byte_enable = 0;

    // APB provides a response for reads
    provides_responses = 0;
  endfunction


  //---------------------------------------------------------
  // RAL --> APB
  //---------------------------------------------------------
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

    apb_seq_item bus;

    bus = apb_seq_item::type_id::create("bus");

    bus.paddr  = rw.addr;
    bus.pwrite = (rw.kind == UVM_WRITE);
    bus.pwdata = rw.data;

    return bus;

  endfunction


  //---------------------------------------------------------
  // APB --> RAL
  //---------------------------------------------------------
  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);

    apb_seq_item bus;

    if(!$cast(bus, bus_item))
      `uvm_fatal(get_type_name(),
                 "Failed to cast apb_seq_item")

    rw.addr = bus.paddr;

    if(bus.pwrite)
      rw.kind = UVM_WRITE;
    else
      rw.kind = UVM_READ;

    if(rw.kind == UVM_WRITE)
      rw.data = bus.pwdata;
    else
      rw.data = bus.prdata;

    rw.status = UVM_IS_OK;

  endfunction

endclass