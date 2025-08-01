module uart_tx (
    input clk,
    input rst,
    input [7:0] tx_data,
    input tx_start,
    output reg tx_line,
    output reg tx_busy
);
    parameter CLKS_PER_BIT = 868;
    reg [9:0] tx_shift_reg;
    reg [3:0] bit_index;
    reg [15:0] clk_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_line <= 1;
            tx_busy <= 0;
            tx_shift_reg <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            if (tx_start && !tx_busy) begin
                tx_shift_reg <= {1'b1, tx_data, 1'b0};
                tx_busy <= 1;
                clk_count <= 0;
                bit_index <= 0;
            end else if (tx_busy) begin
                if (clk_count < CLKS_PER_BIT - 1)
                    clk_count <= clk_count + 1;
                else begin
                    clk_count <= 0;
                    tx_line <= tx_shift_reg[0];
                    tx_shift_reg <= {1'b0, tx_shift_reg[9:1]};
                    bit_index <= bit_index + 1;
                    if (bit_index == 9)
                        tx_busy <= 0;
                end
            end else begin
                tx_line <= 1;
            end
        end
    end
endmodule