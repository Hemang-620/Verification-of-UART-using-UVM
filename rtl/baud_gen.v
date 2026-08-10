module baud_gen(
    input clk,
    input rst_n,
    input [15:0] baud_div_int,
    input [5:0] baud_div_frac,
    output reg baud_tick
);

reg [15:0] count;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        count <= 0;
        baud_tick <= 0;
    end
    else begin
        baud_tick <= 0;

        if (baud_div_int == 0) begin
            count <= 0;
        end
        else if(count == baud_div_int-1) begin
            count <= 0;
            baud_tick <= 1;
        end
        else begin
            count <= count + 1;
        end
    end
end

endmodule