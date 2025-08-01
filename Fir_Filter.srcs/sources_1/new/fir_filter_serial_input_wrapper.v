module fir_filter_serial_input_wrapper (
    input clk,
    input rst,
    input serial_bit_in,
    output reg signed [15:0] yt_out,
    output reg y_valid
);
    reg [7:0] shift_reg;
    reg [2:0] bit_count;
    wire signed [7:0] parallel_sample = shift_reg;
    wire signed [15:0] fir_y_out;
    wire fir_y_valid;

    fir_filter_optimized fir_inst (
        .clk(clk),
        .rst(rst),
        .x_in(parallel_sample),
        .y_out(fir_y_out),
        .y_valid(fir_y_valid)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 0;
            bit_count <= 0;
            yt_out <= 0;
            y_valid <= 0;
        end else begin
            shift_reg <= {shift_reg[6:0], serial_bit_in};
            bit_count <= (bit_count == 7) ? 0 : bit_count + 1;
            if (fir_y_valid) begin
                yt_out <= fir_y_out;
                y_valid <= 1;
            end else begin
                y_valid <= 0;
            end
        end
    end
endmodule