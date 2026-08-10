interface uart_if(input bit PCLK);

  logic PRESETn;

  logic UARTTXD;
  logic UARTRXD;

  logic UARTTXINTR;
  logic UARTRXINTR;
  logic UARTRTINTR;
  logic UARTEINTR;

  // Driver Modport
  modport DRV_MP (
    input  PCLK,
    input  PRESETn,

    output UARTRXD,

    input  UARTTXD,

    input  UARTTXINTR,
    input  UARTRXINTR,
    input  UARTRTINTR,
    input  UARTEINTR
  );

  // Monitor Modport
  modport MON_MP (
    input PCLK,
    input PRESETn,

    input UARTTXD,
    input UARTRXD,

    input UARTTXINTR,
    input UARTRXINTR,
    input UARTRTINTR,
    input UARTEINTR
  );

endinterface