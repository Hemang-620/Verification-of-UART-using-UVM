module UART_RX #(
    parameter CLKS_PER_BIT = 16
)(
    input  wire        i_Clk,
    input  wire        rst_n,
    input  wire        i_RX_Serial,
    input  wire        i_Parity_En,
    input  wire        i_Even_Parity,
    input  wire        i_FIFO_Full,
    input  wire        baud16_tick,
    input  wire [1:0]  word_length,
    input  wire [3:0]  i_Err_Clear,

    output reg         o_RX_DV,
    output reg [7:0]   o_RX_Byte,
    output reg [11:0]  RX_DATA,
    output reg [3:0]   o_RX_Errs
);

typedef enum logic [2:0] {
    s_Idle         = 3'd0,
    s_RX_Start_Bit = 3'd1,
    s_RX_Data_Bits = 3'd2,
    s_RX_Parity    = 3'd3,
    s_RX_Stop_Bit  = 3'd4,
    s_Cleanup      = 3'd5,
    s_Break        = 3'd6
} state_t;

state_t state;

reg [3:0] r_Clk_Count;
reg [2:0] r_Bit_Index;
reg [7:0] r_RX_Byte;
reg       r_Parity_Calc;
reg [3:0] r_Break_Counter;
reg [2:0] data_bits;

always @(posedge i_Clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        state            <= s_Idle;
        r_Clk_Count      <= 0;
        r_Bit_Index      <= 0;
        r_RX_Byte        <= 0;
        r_Parity_Calc    <= 0;
        r_Break_Counter  <= 0;

        o_RX_DV          <= 0;
        o_RX_Byte        <= 0;
        RX_DATA          <= 0;
        o_RX_Errs        <= 0;
    end
    else if(baud16_tick)
    begin

        o_RX_DV <= 1'b0;

        case(state)

        //-------------------------------------------------
        // IDLE
        //-------------------------------------------------
        s_Idle:
        begin
            r_Clk_Count   <= 0;
            r_Bit_Index   <= 0;
            r_Parity_Calc <= 0;

            if(i_RX_Serial == 1'b0)
            begin
                state <= s_RX_Start_Bit;
            end
        end

        //-------------------------------------------------
        // START BIT
        //-------------------------------------------------
        s_RX_Start_Bit:
        begin
            if(r_Clk_Count == 7)
            begin
                if(i_RX_Serial == 1'b0)
                begin
                    r_Clk_Count <= 0;
                    state <= s_RX_Data_Bits;
                end
                else
                begin
                    state <= s_Idle;
                end
            end
            else
            begin
                r_Clk_Count <= r_Clk_Count + 1;
            end
        end

        //-------------------------------------------------
        // DATA BITS
        //-------------------------------------------------
        s_RX_Data_Bits:
        begin
            if(r_Clk_Count == 15)
            begin
                r_Clk_Count <= 0;

                r_RX_Byte[r_Bit_Index] <= i_RX_Serial;
                r_Parity_Calc <= r_Parity_Calc ^ i_RX_Serial;

                if(r_Bit_Index == data_bits)
                begin
                    r_Bit_Index <= 0;

                    if(i_Parity_En)
                        state <= s_RX_Parity;
                    else
                        state <= s_RX_Stop_Bit;
                end
                else
                begin
                    r_Bit_Index <= r_Bit_Index + 1;
                end
            end
            else
            begin
                r_Clk_Count <= r_Clk_Count + 1;
            end
        end

        //-------------------------------------------------
        // PARITY
        //-------------------------------------------------
        s_RX_Parity:
        begin
            if(r_Clk_Count == 15)
            begin
                r_Clk_Count <= 0;

                if(i_Even_Parity)
                    o_RX_Errs[1] <= (i_RX_Serial != r_Parity_Calc);
                else
                    o_RX_Errs[1] <= (i_RX_Serial != ~r_Parity_Calc);

                state <= s_RX_Stop_Bit;
            end
            else
            begin
                r_Clk_Count <= r_Clk_Count + 1;
            end
        end

        //-------------------------------------------------
        // STOP BIT
        //-------------------------------------------------
        s_RX_Stop_Bit:
        begin
            if(r_Clk_Count == 15)
            begin
                r_Clk_Count <= 0;

                o_RX_Errs[0] <= (i_RX_Serial != 1'b1);

                if(i_FIFO_Full)
                    o_RX_Errs[3] <= 1'b1;

                o_RX_Byte <= r_RX_Byte;

                RX_DATA <= {o_RX_Errs[3],
                            o_RX_Errs[2],
                            o_RX_Errs[1],
                            o_RX_Errs[0],
                            r_RX_Byte};

                o_RX_DV <= 1'b1;

                state <= s_Cleanup;
            end
            else
            begin
                r_Clk_Count <= r_Clk_Count + 1;
            end
        end

        //-------------------------------------------------
        // CLEANUP
        //-------------------------------------------------
        s_Cleanup:
        begin
            state <= s_Idle;
        end

        //-------------------------------------------------
        // BREAK
        //-------------------------------------------------
        s_Break:
        begin
            if(i_RX_Serial)
                state <= s_Idle;
        end

        default:
            state <= s_Idle;

        endcase
    end
end

//---------------------------------------------------------
// Error clear
//---------------------------------------------------------

always @(posedge i_Clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        o_RX_Errs <= 0;
    end
    else
    begin
        if(i_Err_Clear[0]) o_RX_Errs[0] <= 0;
        if(i_Err_Clear[1]) o_RX_Errs[1] <= 0;
        if(i_Err_Clear[2]) o_RX_Errs[2] <= 0;
        if(i_Err_Clear[3]) o_RX_Errs[3] <= 0;
    end
end

//---------------------------------------------------------
// Word length
//---------------------------------------------------------

always @(*)
begin
    case(word_length)
        2'b00: data_bits = 3'd4;   // 5 bits
        2'b01: data_bits = 3'd5;   // 6 bits
        2'b10: data_bits = 3'd6;   // 7 bits
        2'b11: data_bits = 3'd7;   // 8 bits
        default:data_bits = 3'd7;
    endcase
end

endmodule