module csr_unit (
    input signed [7:0] data_in,
    input [1:0] sel,
    output reg signed [15:0] result
);
    always @(*) begin
        case (sel)
            2'b00: result = (data_in <<< 6) - (data_in <<< 5);
            2'b01: result = (data_in <<< 3) - data_in;
            2'b10: result = (data_in <<< 5) + (data_in <<< 4) + data_in;
            2'b11: result = (data_in <<< 6) - (data_in <<< 2);
            default: result = 0;
        endcase
    end
endmodule