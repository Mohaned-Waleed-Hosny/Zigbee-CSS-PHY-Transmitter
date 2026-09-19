module dqpsk_csk_multiplier (
    input  wire              clk,
    input  wire              reset,

    input  wire               dqpsk_valid,  // valid_out from dqpsk_encoder
    input  wire signed [1:0]  s_real,       // Sn real part, in {-1, +1}
    input  wire signed [1:0]  s_imag,       // Sn imag part, in {-1, +1}

    input  wire               csk_sample_valid,
    input  wire signed [5:0]  i_c,          // chirp sample real (6-bit)
    input  wire signed [5:0]  q_c,          // chirp sample imag (6-bit)

    output reg  signed [7:0]  css_i,
    output reg  signed [7:0]  css_q,
    output reg                css_valid
);

    // ---------------- Sn hold register ----------------
    // Updated once per subchirp (on dqpsk_valid), held across the 38
    // csk samples of that subchirp.
    reg signed [1:0] s_real_held, s_imag_held;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            s_real_held <= 2'sd1;   // matches dqpsk_encoder's reset state
            s_imag_held <= 2'sd1;   // (phase 0, (1,1) constellation point)
        end else if (dqpsk_valid) begin
            s_real_held <= s_real;
            s_imag_held <= s_imag;
        end
    end

    wire signed [6:0] a = s_real_held[1] ? -i_c : i_c;   // s_real * Ic
    wire signed [6:0] b = s_imag_held[1] ? -q_c : q_c;   // s_imag * Qc
    wire signed [6:0] c = s_real_held[1] ? -q_c : q_c;   // s_real * Qc
    wire signed [6:0] d = s_imag_held[1] ? -i_c : i_c;   // s_imag * Ic  (fixed)

    wire signed [7:0] css_i_comb = a - b;   // Re: s_real*Ic - s_imag*Qc
    wire signed [7:0] css_q_comb = c + d;   // Im: s_real*Qc + s_imag*Ic

    // ---------------- Output register ----------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            css_i     <= 8'sd0;
            css_q     <= 8'sd0;
            css_valid <= 1'b0;
        end else begin
            css_valid <= csk_sample_valid;
            if (csk_sample_valid) begin
                css_i <= css_i_comb;
                css_q <= css_q_comb;
            end
        end
    end

endmodule