module fir_uart_top (
    input clk,
    input rst,
    input uart_rx_line,
    output uart_tx_line
);

    wire [7:0] uart_rx_data;
    wire uart_rx_done;
    wire serial_bit_in = uart_rx_data[0];
    wire serial_bit_out;
    wire busy;
    wire [15:0] fir_parallel_out;
    wire fir_out_valid;
    wire data_valid;
    reg [7:0] uart_tx_data;
    reg uart_tx_start;
    wire uart_tx_busy;

    uart_rx uart_receiver (
        .clk(clk),
        .rst(rst),
        .rx_line(uart_rx_line),
        .rx_data(uart_rx_data),
        .rx_done(uart_rx_done)
    );

    fir_filter_top fir_block (
        .clk(clk),
        .rst(rst),
        .serial_bit_in(serial_bit_in),
        .serial_bit_out(serial_bit_out),
        .busy(busy),
        .fir_parallel_out(fir_parallel_out),
        .fir_out_valid(fir_out_valid),
        .data_valid(data_valid)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            uart_tx_data <= 0;
            uart_tx_start <= 0;
        end else if (data_valid && !uart_tx_busy) begin
            uart_tx_data <= fir_parallel_out[15:8];
            uart_tx_start <= 1;
        end else begin
            uart_tx_start <= 0;
        end
    end

    uart_tx uart_transmitter (
        .clk(clk),
        .rst(rst),
        .tx_data(uart_tx_data),
        .tx_start(uart_tx_start),
        .tx_line(uart_tx_line),
        .tx_busy(uart_tx_busy)
    );

endmodule