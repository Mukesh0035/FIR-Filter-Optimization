module fir_filter_serial_output_wrapper (
    input clk,
    input rst,
    input signed [15:0] parallel_data_in,
    input data_valid,
    output reg serial_bit_out,
    output reg busy
);
    reg [4:0] bit_index;
    reg [15:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            serial_bit_out <= 0;
            busy <= 0;
            bit_index <= 0;
            shift_reg <= 0;
        end else begin
            if (data_valid && !busy) begin
                shift_reg <= parallel_data_in;
                bit_index <= 15;
                busy <= 1;
                serial_bit_out <= parallel_data_in[15];
            end else if (busy) begin
                if (bit_index == 0) begin
                    busy <= 0;
                    serial_bit_out <= 0;
                end else begin
                    bit_index <= bit_index - 1;
                    shift_reg <= {1'b0, shift_reg[15:1]};
                    serial_bit_out <= shift_reg[14];
                end
            end else begin
                serial_bit_out <= 0;
            end
        end
    end
endmodule
