`timescale 1ns / 1ps

module qpsk_mapper (
    input  wire              clk,
    input  wire              reset,
    input  wire              i_bit,      // binary chip, I path (1 -> +1, 0 -> -1)
    input  wire              q_bit,      // binary chip, Q path (1 -> +1, 0 -> -1)
    input  wire              valid_in,   // pulses when i_bit/q_bit are valid

    output reg  signed [1:0] x_real,     // Xn real part, in {-1, 0, +1}
    output reg  signed [1:0] x_imag,     // Xn imag part, in {-1, 0, +1}
    output reg               valid_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_real    <= 2'sd0;
            x_imag    <= 2'sd0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;

            if (valid_in) begin
                case ({i_bit, q_bit})
                    2'b11:   begin x_real <=  2'sd1; x_imag <=  2'sd0; end // I=+1,Q=+1
                    2'b10:   begin x_real <=  2'sd0; x_imag <= -2'sd1; end // I=+1,Q=-1
                    2'b01:   begin x_real <=  2'sd0; x_imag <=  2'sd1; end // I=-1,Q=+1
                    default: begin x_real <= -2'sd1; x_imag <=  2'sd0; end // I=-1,Q=-1 (2'b00)
                endcase
            end
        end
    end

endmodule