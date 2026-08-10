class apb_driver extends uvm_driver #(apb_seq_item);

    `uvm_component_utils(apb_driver)

    apb_cfg cfg_h;
    virtual apb_if apb_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(apb_cfg)::get(this, "", "apb_cfg", cfg_h))
            `uvm_fatal("APB_DRIVER", "Configuration object not found")

        apb_vif = cfg_h.apb_vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_transfer(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_transfer(apb_seq_item req);
        
        @(posedge apb_vif.PCLK);

        //setup phase
        apb_vif.PSEL <= 1'b1;
        apb_vif.PENABLE <= 1'b0;

        apb_vif.PADDR <= req.paddr;
        apb_vif.PWRITE <= req.pwrite;
        apb_vif.PWDATA <= req.pwdata;

        @(posedge apb_vif.PCLK);

        //Access phase
        apb_vif.PENABLE <= 1'b1;

        @(posedge apb_vif.PCLK);
        if (!req.pwrite) 
            req.prdata = apb_vif.PRDATA;

        //IDLE phase

        apb_vif.PSEL <= 1'b0;
        apb_vif.PENABLE <= 1'b0;
    endtask        

endclass