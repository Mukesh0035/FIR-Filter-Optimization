module fir_filter_top (
    input clk,
    input rst,
    input serial_bit_in,
    output serial_bit_out,
    output busy,
    output [15:0] fir_parallel_out,
    output fir_out_valid,
    output reg data_valid
);
    wire signed [15:0] fir_y;
    wire y_valid;

    fir_filter_serial_input_wrapper input_wrapper (
        .clk(clk),
        .rst(rst),
        .serial_bit_in(serial_bit_in),
        .yt_out(fir_y),
        .y_valid(y_valid)
    );

    fir_filter_serial_output_wrapper output_wrapper (
        .clk(clk),
        .rst(rst),
        .parallel_data_in(fir_y),
        .data_valid(data_valid),
        .serial_bit_out(serial_bit_out),
        .busy(busy)
    );

    assign fir_parallel_out = fir_y;
    assign fir_out_valid = y_valid;

    always @(posedge clk or posedge rst) begin
        if (rst)
            data_valid <= 0;
        else
            data_valid <= (y_valid && !busy);
    end
endmodule