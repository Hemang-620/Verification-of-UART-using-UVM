class apb_cfg extends uvm_object;

  // Virtual Interface
  virtual apb_if apb_vif;

  // Agent Mode
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  `uvm_object_utils_begin(apb_cfg)
    `uvm_field_enum(uvm_active_passive_enum,
                    is_active,
                    UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "apb_cfg");
    super.new(name);
  endfunction

endclass