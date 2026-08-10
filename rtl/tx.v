`timescale 1ns/1ns

module UART_TX #(
    parameter CLKS_PER_BIT = 217
)(
    input  wire        i_Clk,
    input  wire        rst_n,
    input  wire        i_TX_DV,
    input  wire [7:0]  i_TX_Byte,
    input  wire        i_Parity_En,
    input  wire        i_Even_Parity,
    input  wire        i_Stick_Parity,
    input  wire        baud16_tick,
    input  wire        send_break,
    input  wire [1:0]  word_length,
    input  wire        i_Two_Stop_Bits,

    output reg         o_TX_Active,
    output reg         o_TX_Serial,
    output reg         o_TX_Done
);

typedef enum logic [2:0] {
    IDLE          = 3'd0,
    TX_START_BIT  = 3'd1,
    TX_DATA_BITS  = 3'd2,
    TX_PARITY_BIT = 3'd3,
    TX_STOP_BIT   = 3'd4,
    CLEANUP       = 3'd5
} state_t;

state_t state;

reg [3:0] r_Clk_Count;
reg [2:0] r_Bit_Index;
reg [7:0] r_TX_Data;
reg       r_Parity_Bit;
reg [2:0] data_bits;
reg [1:0] stop_bit_count;

always @(posedge i_Clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        state           <= IDLE;
        r_Clk_Count     <= 0;
        r_Bit_Index     <= 0;
        r_TX_Data       <= 0;
        r_Parity_Bit    <= 0;
        stop_bit_count  <= 0;

        o_TX_Active <= 0;
        o_TX_Serial <= 1;
        o_TX_Done   <= 0;
    end

    else
    begin

        o_TX_Done <= 0;

        //--------------------------------------
        // BREAK
        //--------------------------------------
        if(send_break)
        begin
            o_TX_Serial <= 0;
            o_TX_Active <= 1;
        end

        else
        begin

            case(state)

            //--------------------------------------
            // IDLE
            //--------------------------------------
            IDLE:
            begin
                o_TX_Active <= 0;
                o_TX_Serial <= 1;

                r_Clk_Count <= 0;
                r_Bit_Index <= 0;
                stop_bit_count <= 0;

                if(i_TX_DV)
                begin
                    r_TX_Data <= i_TX_Byte;

                    if(i_Parity_En)
                    begin
                        if(i_Stick_Parity)
                            r_Parity_Bit <= i_Even_Parity;
                        else
                            r_Parity_Bit <= i_Even_Parity ?
                                            ~(^i_TX_Byte) :
                                             (^i_TX_Byte);
                    end

                    state <= TX_START_BIT;
                end
            end

            //--------------------------------------
            // START BIT
            //--------------------------------------
            TX_START_BIT:
            begin
                o_TX_Active <= 1;
                o_TX_Serial <= 0;

                if(baud16_tick)
                begin
                    if(r_Clk_Count == 15)
                    begin
                        r_Clk_Count <= 0;
                        state <= TX_DATA_BITS;
                    end
                    else
                        r_Clk_Count <= r_Clk_Count + 1;
                end
            end

            //--------------------------------------
            // DATA BITS
            //--------------------------------------
            TX_DATA_BITS:
            begin
                o_TX_Serial <= r_TX_Data[r_Bit_Index];

                if(baud16_tick)
                begin
                    if(r_Clk_Count == 15)
                    begin
                        r_Clk_Count <= 0;

                        if(r_Bit_Index == data_bits)
                        begin
                            r_Bit_Index <= 0;

                            if(i_Parity_En)
                                state <= TX_PARITY_BIT;
                            else
                                state <= TX_STOP_BIT;
                        end
                        else
                            r_Bit_Index <= r_Bit_Index + 1;
                    end
                    else
                        r_Clk_Count <= r_Clk_Count + 1;
                end
            end

            //--------------------------------------
            // PARITY
            //--------------------------------------
            TX_PARITY_BIT:
            begin
                o_TX_Serial <= r_Parity_Bit;

                if(baud16_tick)
                begin
                    if(r_Clk_Count == 15)
                    begin
                        r_Clk_Count <= 0;
                        state <= TX_STOP_BIT;
                    end
                    else
                        r_Clk_Count <= r_Clk_Count + 1;
                end
            end

            //--------------------------------------
            // STOP
            //--------------------------------------
            TX_STOP_BIT:
            begin
                o_TX_Serial <= 1;

                if(baud16_tick)
                begin
                    if(r_Clk_Count == 15)
                    begin
                        r_Clk_Count <= 0;

                        if(!i_Two_Stop_Bits || stop_bit_count==1)
                        begin
                            stop_bit_count <= 0;
                            o_TX_Done <= 1;
                            state <= CLEANUP;
                        end
                        else
                            stop_bit_count <= stop_bit_count + 1;
                    end
                    else
                        r_Clk_Count <= r_Clk_Count + 1;
                end
            end

            //--------------------------------------
            // CLEANUP
            //--------------------------------------
            CLEANUP:
            begin
                o_TX_Active <= 0;
                state <= IDLE;
            end

            default:
                state <= IDLE;

            endcase
        end
    end
end

always @(*)
begin
    case(word_length)
        2'b00: data_bits = 3'd4; // 5 bits (index 0-4)
        2'b01: data_bits = 3'd5; // 6 bits
        2'b10: data_bits = 3'd6; // 7 bits
        2'b11: data_bits = 3'd7; // 8 bits
        default: data_bits = 3'd7;
    endcase
end

endmodule