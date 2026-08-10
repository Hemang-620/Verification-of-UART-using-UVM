module fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 16,
    parameter PTR_WIDTH  = $clog2(DEPTH)
)(
    input  wire                  clk,
    input  wire                  rst_n,

    input  wire                  write_en,
    input  wire                  read_en,

    input  wire [DATA_WIDTH-1:0] data_in,
    output reg  [DATA_WIDTH-1:0] data_out,

    output reg  [PTR_WIDTH:0]    count,

    output wire                  empty,
    output wire                  full
);

    //----------------------------------------------------------
    // Memory
    //----------------------------------------------------------

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [PTR_WIDTH-1:0] wr_ptr;
    reg [PTR_WIDTH-1:0] rd_ptr;

    assign empty = (count == 0);
    assign full  = (count == DEPTH);

    //----------------------------------------------------------
    // FIFO
    //----------------------------------------------------------

    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            wr_ptr   <= '0;
            rd_ptr   <= '0;
            count    <= '0;
            data_out <= '0;
        end
        else
        begin

            //--------------------------------------------------
            // WRITE ONLY
            //--------------------------------------------------
            if(write_en && !read_en && !full)
            begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;
                count  <= count + 1'b1;
            end

            //--------------------------------------------------
            // READ ONLY
            //--------------------------------------------------
            else if(read_en && !write_en && !empty)
            begin
                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
                count  <= count - 1'b1;
            end

            //--------------------------------------------------
            // SIMULTANEOUS READ + WRITE
            //--------------------------------------------------
            else if(read_en && write_en && !empty && !full)
            begin
                data_out <= mem[rd_ptr];
                mem[wr_ptr] <= data_in;

                rd_ptr <= rd_ptr + 1'b1;
                wr_ptr <= wr_ptr + 1'b1;

                // count unchanged
            end

        end
    end

endmodule