module uart_rx (
    input clk,
    input rst,
    input rx_line,
    output reg [7:0] rx_data,
    output reg rx_done
);
    parameter CLKS_PER_BIT = 868;
    reg [15:0] clk_count;
    reg [3:0] bit_index;
    reg [7:0] rx_shift_reg;
    reg rx_busy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_busy <= 0;
            clk_count <= 0;
            bit_index <= 0;
            rx_data <= 0;
            rx_done <= 0;
        end else begin
            rx_done <= 0;
            if (!rx_busy && !rx_line) begin
                rx_busy <= 1;
                clk_count <= CLKS_PER_BIT / 2;
                bit_index <= 0;
            end else if (rx_busy) begin
                if (clk_count < CLKS_PER_BIT - 1)
                    clk_count <= clk_count + 1;
                else begin
                    clk_count <= 0;
                    rx_shift_reg[bit_index] <= rx_line;
                    bit_index <= bit_index + 1;
                    if (bit_index == 7) begin
                        rx_busy <= 0;
                        rx_data <= rx_shift_reg;
                        rx_done <= 1;
                    end
                end
            end
        end
    end
endmodule