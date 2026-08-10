// UART top-level wrapper integrated with APB interface


`timescale 1ns / 1ns
// Top-level UART module integrating APB interface and UART controller

module uart_top_apb #(parameter FIFO_DEPTH = 8,
                     parameter CLKS_PER_BIT = 217
 ) (
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [9:0]  PADDR,
    input  wire [31:0] PWDATA,
    output wire [31:0] PRDATA,
    output wire        PREADY,
    output wire        PSLVERR,
    output wire        UARTTXD,
    input  wire        UARTRXD,
    output wire        UARTRXINTR,
    output wire        UARTTXINTR,
    output wire        UARTRTINTR,
    output wire        UARTEINTR
);

 
   localparam TIMEOUT_THRESHOLD = 32 * CLKS_PER_BIT;

    // Internal signals from APB interface
    wire        tx_write_en;
    wire [7:0]  tx_data_out;
    wire        rx_read_en;
    wire [15:0] baud_div_int;
    wire [5:0]  baud_div_frac;
    wire        parity_en;
    wire        even_parity;
    wire        stick_parity;
    wire        two_stop_bits;
    wire        fifo_enable;
    wire        tx_enable, rx_enable, uart_enable;
    wire [2:0]  tx_fifo_level_sel;
    wire [2:0]  rx_fifo_level_sel;
    wire [10:0] imsc_mask;
    wire [10:0] icr_clear_bits;

    wire        rx_valid;
    wire [10:0] ris_raw;
    wire [10:0] mis_masked;

    // FIFO status flags
    wire        tx_active;
    wire        tx_fifo_full;
    wire        tx_fifo_empty;
    wire        rx_fifo_full;
    wire        rx_fifo_empty;
    wire        uart_busy;
	
	wire [3:0] tx_fifo_count;
	wire [3:0] rx_fifo_count;


    // Outputs from UART controller
    wire        tx_done;
    wire        tx_serial_out;
    wire [7:0]  rx_byte_out;
    wire [3:0]  rx_errors;
    
    wire        send_break_w;
    wire [1:0]  word_length_w;
  
    //wire loopback;
    wire        loopback_en_w;
    
  
  
    wire [11:0] rx_data_out;
		
	  wire[15:0] PRDATA_reg;
      wire [15:0] wr_data;
	  assign PRDATA = {16'b0, PRDATA_reg};
      assign wr_data = PWDATA[15:0];
		

    // Instantiate APB interface
    apb_uart_interface apb_if (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(wr_data),
        .PRDATA(PRDATA_reg),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),

        .tx_data_out(tx_data_out),
        .tx_write_en(tx_write_en),
        .rx_data_in(rx_data_out),
        .rx_valid(rx_valid),
        .rx_read_en(rx_read_en),
        .baud_div_int(baud_div_int),
        .baud_div_frac(baud_div_frac),
        .parity_en(parity_en),
        .even_parity(even_parity),
        .stick_parity(stick_parity),
        .send_break(send_break_w),
        .word_length(word_length_w),
        .two_stop_bits(two_stop_bits),
        .loopback_en(loopback_en_w),
        .fifo_enable(fifo_enable),
        .tx_enable(tx_enable),
        .rx_enable(rx_enable),
        .uart_enable(uart_enable),
        .tx_fifo_level_sel(tx_fifo_level_sel),
        .rx_fifo_level_sel(rx_fifo_level_sel),
        .imsc_mask(imsc_mask),
        .ris_raw(ris_raw),
        .mis_masked(mis_masked),
        .icr_clear_bits(icr_clear_bits),
        .tx_fifo_full(tx_fifo_full),
        .tx_fifo_empty(tx_fifo_empty),
        .rx_fifo_full(rx_fifo_full),
        .rx_fifo_empty(rx_fifo_empty),
        .uart_busy(uart_busy)
    );

    // Instantiate UART controller
    uart_controller  uart_ctrl_inst (
        .clk(PCLK),
        .rst_n(PRESETn),
        .tx_write_en(tx_write_en),
        .tx_data_in(tx_data_out),
        .rx_read_en(rx_read_en),
        .parity_en(parity_en),
        .even_parity(even_parity),
        .stick_parity(stick_parity),
        .send_break(send_break_w),
        .word_length(word_length_w),
        .two_stop_bits(two_stop_bits),
        .loopback_en(loopback_en_w),
        .baud_div_int(baud_div_int),
        .baud_div_frac(baud_div_frac),
        .icr_clear_bits(icr_clear_bits[3:0]),
        .rx_serial_in(UARTRXD),
        .tx_done(tx_done),
        .tx_serial_out(tx_serial_out),
        .rx_data_valid(rx_valid),
        .rx_byte_out(rx_byte_out),
        .rx_errors(rx_errors),
        .rx_data_out(rx_data_out),
        .tx_active(tx_active),
        .tx_fifo_full(tx_fifo_full),
        .tx_fifo_empty(tx_fifo_empty),
        .rx_fifo_full(rx_fifo_full),
        .rx_fifo_empty(rx_fifo_empty),
        .tx_fifo_count(tx_fifo_count),
        .rx_fifo_count(rx_fifo_count)
    );

    // Connect serial output
   
    assign UARTTXD = tx_serial_out;
   
   // assign UARTTXINTR = tx_fifo_empty && imsc_mask[5];
   // assign UARTRXINTR = (!rx_fifo_empty) && imsc_mask[4];
    assign UARTEINTR  = (|rx_data_out[11:8]) && imsc_mask[10:8];
  
  
   assign ris_raw[4] = !rx_fifo_empty; // RX FIFO threshold
   assign ris_raw[5] = (tx_fifo_empty);  // TX FIFO empty enough
   assign ris_raw[6] = 1'b0;
   assign ris_raw[7] = rx_data_out[8]; 
   assign ris_raw[8] = rx_data_out[9];
   assign ris_raw[9] = rx_data_out[10];
   assign ris_raw[10] = rx_data_out[11];
   assign ris_raw[3:0] = 3'b000;
     
  
    reg [15:0] rx_timeout_counter;
    reg        rx_timeout_triggered;

  always @(posedge PCLK or negedge PRESETn) begin
     if (!PRESETn) begin
          rx_timeout_counter <= 0;
          rx_timeout_triggered <= 0;
     end else if (rx_valid) begin
          rx_timeout_counter <= 0;
          rx_timeout_triggered <= 0;
     end else if (!rx_fifo_empty) begin
          rx_timeout_counter <= rx_timeout_counter + 1;
     if (rx_timeout_counter >= TIMEOUT_THRESHOLD)
          rx_timeout_triggered <= 1;
     end else begin
          rx_timeout_counter <= 0;
          rx_timeout_triggered <= 0;
     end
   end

   assign UARTRTINTR = rx_timeout_triggered && imsc_mask[6];
  
   assign uart_busy = tx_active; 
  
  
   function [3:0] fifo_threshold(input [2:0] level_sel);
    case (level_sel)
        3'd0: fifo_threshold = 1;  // 1/8
        3'd1: fifo_threshold = 2;  // 1/4
        3'd2: fifo_threshold = 4;  // 1/2
        3'd3: fifo_threshold = 6;  // 3/4
        3'd4: fifo_threshold = 7;  // 7/8
        3'd5: fifo_threshold = 8;  // full
        default: fifo_threshold = 1;
    endcase
   endfunction

   wire [3:0] tx_fifo_thresh = fifo_threshold(tx_fifo_level_sel);
   wire [3:0] rx_fifo_thresh = fifo_threshold(rx_fifo_level_sel);
  
   assign UARTTXINTR = (tx_fifo_count <= tx_fifo_thresh) && imsc_mask[5];
   assign UARTRXINTR = (rx_fifo_count >= rx_fifo_thresh) && imsc_mask[4];

endmodule
