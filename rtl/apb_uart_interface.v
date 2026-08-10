

module apb_uart_interface (
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [9:0]  PADDR,
    input  wire [15:0] PWDATA,
    output reg  [15:0] PRDATA,
    output wire        PREADY,
    output reg         PSLVERR,

    output reg  [7:0]  tx_data_out,
    output reg         tx_write_en,
    input  wire [11:0] rx_data_in,
    input  wire        rx_valid,
    output reg         rx_read_en,
    output reg  [15:0] baud_div_int,
    output reg  [5:0]  baud_div_frac,
    output reg         parity_en,
    output reg         even_parity,
    output reg         stick_parity,
    output reg         two_stop_bits,
    output reg         fifo_enable,
    output reg         tx_enable,
    output reg         rx_enable,
    output reg         uart_enable,
    output reg  [2:0]  tx_fifo_level_sel,
    output reg  [2:0]  rx_fifo_level_sel,
    output reg  [10:0] imsc_mask,
    output reg         send_break,
    output reg [1:0]   word_length,
    output reg         loopback_en,  // LBE
    input  wire [10:0] ris_raw,
    input  wire [10:0] mis_masked,
    output reg  [10:0] icr_clear_bits,
    input  wire        tx_fifo_full,
    input  wire        tx_fifo_empty,
    input  wire        rx_fifo_full,
    input  wire        rx_fifo_empty,
    input  wire        uart_busy
);

    assign PREADY = 1'b1;

    localparam UARTDR     = 10'h000;
    localparam UARTECR    = 10'h004;
    localparam UARTFR     = 10'h018;
    localparam UARTIBRD   = 10'h024;
    localparam UARTFBRD   = 10'h028;
    localparam UARTLCR_H  = 10'h02C;
    localparam UARTCR     = 10'h030;
    localparam UARTIFLS   = 10'h034;
    localparam UARTIMSC   = 10'h038;
    localparam UARTRIS    = 10'h03C;
    localparam UARTMIS    = 10'h040;
    localparam UARTICR    = 10'h044;

    always @(*) begin
        PRDATA = 16'h0000;
        PSLVERR = 1'b0;

        if (PSEL && !PWRITE && PENABLE) begin
            $display("[%0t] APB READ PADDR=%03h",$time,PADDR);
            case (PADDR)
                UARTDR:    PRDATA = {4'b0, rx_data_in};
                UARTECR:   PRDATA = 16'h0000;
                UARTFR:    PRDATA = {8'b0, tx_fifo_empty, rx_fifo_full, tx_fifo_full, rx_fifo_empty, uart_busy, 3'b0};
                UARTIBRD:  PRDATA = baud_div_int;
                UARTFBRD:  PRDATA = {10'h0, baud_div_frac};
                UARTLCR_H: PRDATA = {8'h0, stick_parity, word_length, fifo_enable, two_stop_bits, even_parity, parity_en, send_break};
              UARTCR:    PRDATA = {5'b0, rx_enable, tx_enable, loopback_en, 4'b0, 2'b0, uart_enable};
                UARTIFLS:  PRDATA = {10'h0, rx_fifo_level_sel, tx_fifo_level_sel};
                UARTIMSC:  PRDATA = {5'b0, imsc_mask};
                UARTRIS:   PRDATA = ris_raw;
                UARTMIS:   PRDATA = mis_masked;
                default:   PRDATA = 16'h0000;
            endcase
        end
    end

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            $display("[%0t] RESET branch PRESETn=%b", $time, PRESETn);

            tx_write_en       <= 1'b0;
            rx_read_en        <= 1'b0;
            baud_div_int      <= 16'd0;
            baud_div_frac     <= 6'd0;
            parity_en         <= 1'b0;
            even_parity       <= 1'b0;
            stick_parity      <= 1'b0;
            two_stop_bits     <= 1'b0;
            fifo_enable       <= 1'b0;
            tx_enable         <= 1'b0;
            rx_enable         <= 1'b0;
            uart_enable       <= 1'b0;
            tx_fifo_level_sel <= 3'd2;
            rx_fifo_level_sel <= 3'd2;
            imsc_mask         <= 11'd0;
            icr_clear_bits    <= 11'd0;
        end else if (PSEL && PWRITE && PENABLE) begin
            $display("[%0t] WRITE branch PRESETn=%b", $time, PRESETn);
            $display("\n-----------------------------------------");
            $display("[%0t] APB WRITE DETECTED",$time);
            $display("PADDR   = %03h",PADDR);
            $display("PWDATA  = %04h",PWDATA);
            $display("IBRD(before) = %04h",baud_div_int);
            $display("FBRD(before) = %02h",baud_div_frac);
            tx_write_en   <= 1'b0;
            rx_read_en    <= 1'b0;
            icr_clear_bits <= 11'd0;

            case (PADDR)

10'h000: begin
    $display("MATCH : UARTDR");
    if (!tx_fifo_full) begin
        tx_data_out <= PWDATA[7:0];
        tx_write_en <= 1'b1;
    end
end

10'h004: begin
    $display("MATCH : UARTECR");
    icr_clear_bits <= PWDATA[3:0];
end

10'h024: begin
    $display("**************************************");
    $display("MATCH : UARTIBRD");
    $display("PADDR         = %03h", PADDR);
    $display("PWDATA        = %04h", PWDATA);
    $display("Old IBRD      = %04h", baud_div_int);

    baud_div_int <= PWDATA[15:0];

    $display("New IBRD Req  = %04h", PWDATA[15:0]);
    $display("**************************************");
end

10'h028: begin
    $display("MATCH : UARTFBRD");
    baud_div_frac <= PWDATA[5:0];
end

10'h02C: begin
    $display("MATCH : UARTLCR_H");

    send_break    <= PWDATA[0];
    parity_en     <= PWDATA[1];
    even_parity   <= PWDATA[2];
    two_stop_bits <= PWDATA[3];
    fifo_enable   <= PWDATA[4];
    word_length   <= PWDATA[6:5];
    stick_parity  <= PWDATA[7];
end

10'h030: begin
    $display("MATCH : UARTCR");

    uart_enable <= PWDATA[0];
    tx_enable   <= PWDATA[8];
    loopback_en <= PWDATA[7];
    rx_enable   <= PWDATA[9];
end

10'h034: begin
    $display("MATCH : UARTIFLS");

    tx_fifo_level_sel <= PWDATA[2:0];
    rx_fifo_level_sel <= PWDATA[5:3];
end

10'h038: begin
    $display("MATCH : UARTIMSC");

    imsc_mask <= PWDATA[10:0];
end

10'h044: begin
    $display("MATCH : UARTICR");

    icr_clear_bits <= PWDATA[10:0];
end

default: begin
    $display("######################################");
    $display("DEFAULT CASE HIT");
    $display("PADDR HEX = %03h", PADDR);
    $display("PADDR BIN = %010b", PADDR);
    $display("######################################");
end

endcase
        end else if (PSEL && !PWRITE && PENABLE && PADDR == UARTDR && rx_valid) begin
            rx_read_en <= 1'b1;
        end else begin
            tx_write_en <= 1'b0;
            rx_read_en  <= 1'b0;
        end
        // $strobe("[%0t] REGISTER STATE : IBRD=%04h FBRD=%02h UARTEN=%0b TXE=%0b RXE=%0b",
        // $time,
        // baud_div_int,
        // baud_div_frac,
        // uart_enable,
        // tx_enable,
        // rx_enable);
    end
  
     assign mis_masked = ris_raw & imsc_mask;
endmodule
