class uart_tx_sequence extends uart_base_sequence;

  `uvm_object_utils(uart_tx_sequence)

  bit [7:0] data;          // <-- ADD THIS

  bit [1:0] wlen;
  bit       parity_en;
  bit       even_parity;
  bit       stop2;

  function new(string name="uart_tx_sequence");
    super.new(name);
  endfunction

  task body();

    req = uart_seq_item::type_id::create("req");

    start_item(req);

    assert(req.randomize() with
    {
      req.data        == local::data;        // <-- ADD THIS
      req.wlen        == local::wlen;
      req.parity_en   == local::parity_en;
      req.even_parity == local::even_parity;
      req.stop2       == local::stop2;
    });

    finish_item(req);

  endtask

endclass