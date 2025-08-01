module fir_filter_optimized (
    input clk,
    input rst,
    input signed [7:0] x_in,
    output reg signed [15:0] y_out,
    output reg y_valid
);
    reg signed [7:0] x[0:6];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 7; i = i + 1)
                x[i] <= 0;
        end else begin
            for (i = 6; i > 0; i = i - 1)
                x[i] <= x[i - 1];
            x[0] <= x_in;
        end
    end

    wire signed [15:0] csr_out[0:6][0:3];

    genvar j;
    generate
        for (j = 0; j < 7; j = j + 1) begin : csr_instances
            csr_unit csr0 (.data_in(x[j]), .sel(2'b00), .result(csr_out[j][0]));
            csr_unit csr1 (.data_in(x[j]), .sel(2'b01), .result(csr_out[j][1]));
            csr_unit csr2 (.data_in(x[j]), .sel(2'b10), .result(csr_out[j][2]));
            csr_unit csr3 (.data_in(x[j]), .sel(2'b11), .result(csr_out[j][3]));
        end
    endgenerate

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y_out <= 0;
            y_valid <= 0;
        end else begin
            y_out <= csr_out[0][1] + csr_out[1][2] + (csr_out[2][0] + csr_out[2][1]) +
                     csr_out[3][3] + (csr_out[2][0] + csr_out[2][1]) + csr_out[1][2] + csr_out[0][1];
            y_valid <= 1;
        end
    end
endmodule