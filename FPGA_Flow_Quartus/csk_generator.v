module csk_generator (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,          // one-cycle pulse: begin generating chirp sequences
    input  wire [2:0]  m,              // 1..4, chirp-sequence index

    // ---- From the DQPSK stage ----
    input  wire               dqpsk_valid, // dqpsk_encoder's valid_out
    input  wire signed [1:0]  s_real,      // dqpsk_encoder's s_real
    input  wire signed [1:0]  s_imag,      // dqpsk_encoder's s_imag

    // ---- To whatever drives the DQPSK stage ----
    output wire        subchirp_tick,  // pulses once per subchirp boundary:
                                        // fetch/latch the next symbol now
    output wire        seq_active,     // high while a CSS burst is running

    // ---- CSS modulated output ----
    output wire signed [7:0] css_i,
    output wire signed [7:0] css_q,
    output wire              css_valid
);

 
    wire [1:0] k_index;
    wire [5:0] sample_index;
    wire       csk_sample_valid;

    csk_sequencer u_seq (
        .clk              (clk),
        .reset            (reset),
        .start            (start),
        .m                (m),
        .k_index          (k_index),
        .sample_index     (sample_index),
        .csk_sample_valid (csk_sample_valid),
        .subchirp_tick    (subchirp_tick),
        .seq_active       (seq_active)
    );

   
    wire [1:0] waveform_id;

    csk_waveform_selector u_sel (
        .m           (m),
        .k           (k_index),
        .waveform_id (waveform_id)
    );

    
    wire signed [5:0] i_c, q_c;

    csk_waveform_rom u_rom (
        .clk          (clk),
        .waveform_id  (waveform_id),
        .sample_index (sample_index),
        .i_c          (i_c),
        .q_c          (q_c)
    );

    reg csk_sample_valid_d;
    always @(posedge clk or posedge reset) begin
        if (reset) csk_sample_valid_d <= 1'b0;
        else       csk_sample_valid_d <= csk_sample_valid;
    end

    dqpsk_csk_multiplier u_mult (
        .clk              (clk),
        .reset            (reset),
        .dqpsk_valid      (dqpsk_valid),
        .s_real           (s_real),
        .s_imag           (s_imag),
        .csk_sample_valid (csk_sample_valid_d),
        .i_c              (i_c),
        .q_c              (q_c),
        .css_i            (css_i),
        .css_q            (css_q),
        .css_valid        (css_valid)
    );

endmodule