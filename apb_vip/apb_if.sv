interface apb_if(input bit PCLK);

  //---------------------------------------------------------
  // Global Signals
  //---------------------------------------------------------

  logic        PRESETn;

  //---------------------------------------------------------
  // APB Signals
  //---------------------------------------------------------

  logic        PSEL;
  logic        PENABLE;
  logic        PWRITE;

  logic [9:0]  PADDR;
  logic [15:0] PWDATA;
  logic [15:0] PRDATA;

  // Slave Response Signals
  logic        PREADY;
  logic        PSLVERR;

  //---------------------------------------------------------
  // Driver Modport
  //---------------------------------------------------------

  modport DRV_MP (

    input  PCLK,
    input  PRESETn,

    output PSEL,
    output PENABLE,
    output PWRITE,
    output PADDR,
    output PWDATA,

    input  PRDATA,
    input  PREADY,
    input  PSLVERR

  );

  //---------------------------------------------------------
  // Monitor Modport
  //---------------------------------------------------------

  modport MON_MP (

    input PCLK,
    input PRESETn,

    input PSEL,
    input PENABLE,
    input PWRITE,
    input PADDR,
    input PWDATA,
    input PRDATA,

    input PREADY,
    input PSLVERR

  );

endinterface