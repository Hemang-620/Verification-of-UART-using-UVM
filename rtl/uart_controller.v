// Code your design here



`timescale 1ns / 1ns


module uart_controller #(
     parameter DATA_WIDTH = 8
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tx_write_en,
    input  wire [7:0]  tx_data_in,
    input  wire        rx_read_en,
    input  wire        parity_en,
    input  wire        even_parity,
    input  wire        stick_parity,
    input  wire        loopback_en,
    input  wire [15:0] baud_div_int,
    input  wire [5:0]  baud_div_frac,
    input  wire        send_break, 
    input  wire        two_stop_bits,
    input  wire [1:0]   word_length,
    input  wire [3:0] icr_clear_bits,
    input  wire        rx_serial_in,
    output wire        tx_done,
    output wire        tx_serial_out,
    output wire        rx_data_valid,
    output wire [7:0]  rx_byte_out,
    output wire [3:0]  rx_errors,
    output wire [11:0] rx_data_out,
    output wire        tx_active,
    output wire        tx_fifo_full,
    output wire        tx_fifo_empty,
    output wire        rx_fifo_full,
    output wire        rx_fifo_empty,
    output wire [3:0]  tx_fifo_count,
    output wire [3:0]  rx_fifo_count
);

    // Internal signals
    wire       baud16_tick;
    wire [7:0] tx_fifo_data_out;
    wire       tx_fifo_read_en;
    wire [3:0] count;
    //wire       tx_active;

    wire [11:0] rx_fifo_data_out;
    wire        rx_fifo_write_en;
  
   // reg tx_start;
      

//chnaged here

    
    //---------------------------------------------------------
// TX Controller FSM
//---------------------------------------------------------

typedef enum logic [2:0] {
    TX_IDLE,
    TX_READ_FIFO,
    TX_WAIT_DATA,
    TX_LOAD,
    TX_START,
    TX_WAIT
} tx_state_t;

tx_state_t tx_state;

reg        tx_start;
reg        tx_fifo_read_en_r;
reg [7:0]  tx_data_reg;

assign tx_fifo_read_en = tx_fifo_read_en_r;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        tx_state          <= TX_IDLE;
        tx_start          <= 1'b0;
        tx_fifo_read_en_r <= 1'b0;
        tx_data_reg       <= 8'h00;
    end
    else
    begin
        //----------------------------------------------------
        // Default outputs
        //----------------------------------------------------
        tx_start          <= 1'b0;
        tx_fifo_read_en_r <= 1'b0;

        case(tx_state)

        //----------------------------------------------------
        // Wait until FIFO contains data
        //----------------------------------------------------
        TX_IDLE:
        begin
            if(!tx_fifo_empty)
                tx_state <= TX_READ_FIFO;
        end

        //----------------------------------------------------
        // Assert FIFO read for one clock
        //----------------------------------------------------
        TX_READ_FIFO:
        begin
            tx_fifo_read_en_r <= 1'b1;
            tx_state <= TX_WAIT_DATA;
        end

        //----------------------------------------------------
        // Wait one clock for FIFO data_out to update
        //----------------------------------------------------
        TX_WAIT_DATA:
        begin
            tx_state <= TX_LOAD;
        end

        //----------------------------------------------------
        // Capture FIFO output
        //----------------------------------------------------
        TX_LOAD:
        begin
            tx_data_reg <= tx_fifo_data_out;

            $display("[%0t] Loaded TX Data = %02h",
                     $time, tx_fifo_data_out);

            tx_state <= TX_START;
        end

        //----------------------------------------------------
        // Pulse TX_DV for one cycle
        //----------------------------------------------------
        TX_START:
        begin
            tx_start <= 1'b1;
            tx_state <= TX_WAIT;
        end

        //----------------------------------------------------
        // Wait for UART transmitter to finish
        //----------------------------------------------------
        TX_WAIT:
        begin
            if(tx_done)
                tx_state <= TX_IDLE;
        end

        default:
            tx_state <= TX_IDLE;

        endcase
    end
end

    // Generate 16x baud tick
    baud_gen baud_gen_inst (
        .clk(clk),
        .rst_n(rst_n),
        .baud_div_int(baud_div_int),
        .baud_div_frac(baud_div_frac),
        .baud_tick(baud16_tick)
    );

    // TX FIFO
   fifo #(.DATA_WIDTH(8), .DEPTH(8)) tx_fifo_inst (
        .clk(clk),
        .rst_n(rst_n),
        .write_en(tx_write_en),
        .read_en(tx_fifo_read_en),
        .data_in(tx_data_in),
        .data_out(tx_fifo_data_out),
        .count(tx_fifo_count),
        .empty(tx_fifo_empty),
        .full(tx_fifo_full)
    );

    // RX FIFO      //depth_changed to 4 for testing rohit
   fifo #(.DATA_WIDTH(12), .DEPTH(8)) rx_fifo_inst (
      .clk(clk),
        .rst_n(rst_n),
        .write_en(rx_fifo_write_en),
        .read_en(rx_read_en),
        .data_in(rx_data_out),
        .data_out(rx_fifo_data_out),
        .count(rx_fifo_count),
        .empty(rx_fifo_empty),
        .full(rx_fifo_full)
    ); 

    assign rx_byte_out = rx_fifo_data_out[7:0];
    assign rx_errors   = rx_fifo_data_out[11:8];
    assign rx_data_valid = !rx_fifo_empty;
  
  
//    always @(posedge clk or negedge rst_n) begin
//       if (!rst_n)
//          tx_start <= 1'b0;
//      // else if (tx_fifo_empty == 0 && tx_active == 0)
//       else if (tx_active == 0)
//          tx_start <= 1'b1;
//       else 
//          tx_start <= 1'b0;
//      end 
  
  

    // UART Transmitter
  UART_TX uart_tx_inst (
        .i_Clk(clk),
        .rst_n(rst_n),
        .i_TX_DV(tx_start),
        // .i_TX_Byte(tx_fifo_data_out),
        .i_TX_Byte(tx_data_reg),
        .i_Parity_En(parity_en),
        .baud16_tick(baud16_tick),
        .send_break(send_break),
        .word_length(word_length),
        .i_Two_Stop_Bits(two_stop_bits),
        .i_Even_Parity(even_parity),
        .i_Stick_Parity(stick_parity),
        .o_TX_Active(tx_active),
        .o_TX_Serial(tx_serial_out),
        .o_TX_Done(tx_done)
    );
  


  // assign tx_fifo_read_en = (!tx_fifo_empty && !tx_active);
  
     // loop_back 
     wire rx_line_muxed;
    assign rx_line_muxed = loopback_en ? tx_serial_out : rx_serial_in;

  
    // UART Receiver
  UART_RX uart_rx_inst (
        .i_Clk(clk),
        .rst_n(rst_n),
        .i_RX_Serial(rx_line_muxed), // loopback internally
        .i_Parity_En(parity_en),
        .i_Even_Parity(even_parity),
        .i_FIFO_Full(rx_fifo_full),
        .baud16_tick(baud16_tick),
        .word_length(word_length),
        .i_Err_Clear(icr_clear_bits[3:0]),
        .o_RX_DV(rx_fifo_write_en),
        .o_RX_Byte(),
        .RX_DATA(rx_data_out),
        .o_RX_Errs()
    );

endmodule 
