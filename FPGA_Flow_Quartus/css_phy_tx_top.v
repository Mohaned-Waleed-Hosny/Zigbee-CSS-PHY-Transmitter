`timescale 1ns / 1ps
// ============================================================================
// CSS PHY Transmitter - Professional Top-Level Integration
// ----------------------------------------------------------------------------
// Architecture:
//   controller(new_controller)
//        -> zero_padding
//        -> demux_iq
//        -> symbol_mapper
//        -> bit_interleaver
//        -> form_ppdu
//        -> qpsk_mapper
//        -> dqpsk_encoder
//        -> DQPSK symbol buffer
//        -> CSK sequencer / waveform selector / waveform ROM
//        -> dqpsk_csk_multiplier
//        -> Tx_real / Tx_imag
//
// IMPORTANT:
//   The supplied csk_generator.v is intentionally not instantiated here.
//   Its current wrapper feeds every dqpsk_valid pulse directly into the
//   subchirp hold register, while the DQPSK stream is faster than the 38
//   samples/subchirp timing.  This top therefore performs the required
//   4-symbol buffering and supplies exactly one DQPSK symbol per subchirp.
//
//   The supplied csk_waveform_rom.v has a registered output.  The top uses
//   the same ROM module and compensates for its one-cycle latency by delaying
//   csk_sample_valid by two clocked stages relative to the sequencer.
//   This preserves the 38 samples/subchirp alignment at subchirp boundaries.
//
// CSK_M:
//   The supplied RTL exposes m as a chirp-sequence index (1..4), but the
//   project top-level interface does not define m as an external pin.
//   Therefore it is a parameter. Change CSK_M after confirming the intended
//   sequence selection with the MATLAB reference/instructor.
// ============================================================================

module css_phy_tx_top #(
    parameter [2:0] CSK_M = 3'd1
) (
    input  wire              clk,
    input  wire              reset,

    input  wire              start_Tx,
    input  wire              data_rate,       // 0 = 1 Mbps, 1 = 250 kbps
    input  wire [7:0]        payloadLength,

    // Payload RAM write interface
    input  wire [7:0]        payload_addr,
    input  wire [7:0]        payload_din,
    input  wire              payload_wr_en,

    // Final complex CSS output
    output wire signed [7:0] Tx_real,
    output wire signed [7:0] Tx_imag,
    output reg               done_Tx,

    // Useful for testbench / FPGA status
    output wire              busy
);

    // ------------------------------------------------------------------------
    // 1. Controller -> front-end
    // ------------------------------------------------------------------------
    wire ctrl_start_frame;
    wire ctrl_valid_in;
    wire ctrl_bit_in;

    wire ctrl_i_to_qpsk;
    wire ctrl_q_to_qpsk;
    wire ctrl_valid_to_qpsk;
    wire ctrl_done;
    wire ctrl_busy;

    // PPDU serial output (form_ppdu -> qpsk_mapper)
    wire ppdu_i;
    wire ppdu_q;
    wire ppdu_valid;

wire ctrl_fp_i_out;
wire ctrl_fp_q_out;
wire ctrl_fp_valid_out;

    // qpsk_valid_out is fed back to the supplied new_controller.
    wire qpsk_valid_out;

    // Do not accept a new frame while the previous frame is being converted
    // into CSS samples.
    wire start_cmd = start_Tx && !busy;

    controller u_controller (
        .clk              (clk),
        .reset            (reset),
        .start_Tx         (start_cmd),
        .data_rate        (data_rate),
        .payload_len      (payloadLength),

        .payload_addr     (payload_addr),
        .payload_din      (payload_din),
        .payload_wr_en    (payload_wr_en && !busy),

        .start_frame      (ctrl_start_frame),
        .valid_in         (ctrl_valid_in),
        .bit_in           (ctrl_bit_in),

.fp_i_out      (ctrl_fp_i_out),
.fp_q_out      (ctrl_fp_q_out),
.fp_valid_out  (ctrl_fp_valid_out),

        .i_to_qpsk        (ctrl_i_to_qpsk),
        .q_to_qpsk        (ctrl_q_to_qpsk),
        .valid_to_qpsk    (ctrl_valid_to_qpsk),

        .qpsk_valid_out   (qpsk_valid_out),

        .done_Tx          (ctrl_done),
        .busy             (ctrl_busy)
    );

    // ------------------------------------------------------------------------
    // 2. Zero padding
    // ------------------------------------------------------------------------
    wire padded_bit;
    wire padded_valid;
    wire padding_done;

    zero_padding u_zero_padding (
        .clk          (clk),
        .reset        (reset),
        .data_rate    (data_rate),
        .payload_len  (payloadLength),
        .bit_in       (ctrl_bit_in),
        .valid_in     (ctrl_valid_in),
        .start_frame  (ctrl_start_frame),

        .bit_out      (padded_bit),
        .valid_out    (padded_valid),
        .done_padding(padding_done)
    );

    // ------------------------------------------------------------------------
    // 3. I/Q demultiplexer
    // ------------------------------------------------------------------------
    wire i_bit;
    wire q_bit;
    wire demux_valid;

    demux_iq u_demux (
        .clk        (clk),
        .reset      (reset),
        .start_frame(ctrl_start_frame),
        .bit_in     (padded_bit),
        .valid_in   (padded_valid),

        .i_bit      (i_bit),
        .q_bit      (q_bit),
        .valid_out  (demux_valid)
    );

    // ------------------------------------------------------------------------
    // 4. Symbol mapper
    // ------------------------------------------------------------------------
    wire [0:31] i_mapped;
    wire [0:31] q_mapped;
    wire        mapper_valid;

    symbol_mapper u_symbol_mapper (
        .clk       (clk),
        .reset     (reset),
        .data_rate (data_rate),
        .i_bit     (i_bit),
        .q_bit     (q_bit),
        .valid_in  (demux_valid),

        .i_mapped  (i_mapped),
        .q_mapped  (q_mapped),
        .valid_out (mapper_valid)
    );

    // ------------------------------------------------------------------------
    // 5. Interleaver
    // ------------------------------------------------------------------------
    wire [0:63] i_interleaved;
    wire [0:63] q_interleaved;
    wire        interleaver_valid;

    bit_interleaver u_interleaver (
        .clk       (clk),
        .reset     (reset),
        .data_rate (data_rate),
        .i_mapped  (i_mapped),
        .q_mapped  (q_mapped),
        .valid_in  (mapper_valid),

        .i_out     (i_interleaved),
        .q_out     (q_interleaved),
        .valid_out (interleaver_valid)
    );

    // ------------------------------------------------------------------------
    // 6. PPDU framer: Preamble + SFD + encoded payload
    // ------------------------------------------------------------------------
    form_ppdu u_form_ppdu (
        .clk        (clk),
        .reset      (reset),
        .start_frame(ctrl_start_frame),
        .data_rate  (data_rate),

        .i_in       (i_interleaved),
        .q_in       (q_interleaved),
        .valid_in   (interleaver_valid),

        .i_out      (ppdu_i),
        .q_out      (ppdu_q),
        .valid_out  (ppdu_valid)
    );

    // ------------------------------------------------------------------------
    // 7. QPSK mapper
    // ------------------------------------------------------------------------
    wire signed [1:0] x_real;
    wire signed [1:0] x_imag;

    qpsk_mapper u_qpsk (
        .clk       (clk),
        .reset     (reset),
        .i_bit     (ppdu_i),
        .q_bit     (ppdu_q),
        .valid_in  (ppdu_valid),

        .x_real    (x_real),
        .x_imag    (x_imag),
        .valid_out (qpsk_valid_out)
    );

    // ------------------------------------------------------------------------
    // 8. DQPSK encoder
    // ------------------------------------------------------------------------
    wire signed [1:0] s_real;
    wire signed [1:0] s_imag;
    wire               dqpsk_valid;

    dqpsk_encoder u_dqpsk (
        .clk      (clk),
        .reset    (reset),
        .x_real   (x_real),
        .x_imag   (x_imag),
        .valid_in (qpsk_valid_out),

        .s_real   (s_real),
        .s_imag   (s_imag),
        .valid_out(dqpsk_valid)
    );

    // ------------------------------------------------------------------------
    // 9. DQPSK symbol capture buffer
    //
    // Maximum packet:
    //   127-byte payload + 12-bit PHR
    //   1 Mbps  -> 736 QPSK/DQPSK symbols including preamble/SFD
    //   250 kbps ->  ? (still below 1024 for the supported 127-byte payload)
    //
    // A 1024-entry buffer therefore provides comfortable headroom.
    // ------------------------------------------------------------------------
    reg signed [1:0] dqpsk_mem_real [0:1023];
    reg signed [1:0] dqpsk_mem_imag [0:1023];

    reg [10:0] dqpsk_wr_count;
    reg        capture_active;
    reg        csk_start_pending;

    // Expected number of DQPSK symbols, matching the sizing used by
    // new_controller.v.
    wire [10:0] total_data_bits =
        11'd12 + ({3'd0, payloadLength} * 11'd8);

    wire [10:0] rem6  = total_data_bits % 11'd6;
    wire [10:0] rem24 = total_data_bits % 11'd24;

    wire [10:0] pad6  = (rem6  == 0) ? 11'd6  : (11'd6  - rem6);
    wire [10:0] pad24 = (rem24 == 0) ? 11'd24 : (11'd24 - rem24);

    wire [10:0] padded_bits =
        total_data_bits + (data_rate ? pad24 : pad6);

    wire [12:0] payload_symbols_1m =
        (padded_bits / 11'd6) * 11'd4;

    wire [12:0] payload_symbols_250k =
        (padded_bits / 11'd12) * 11'd32;

    wire [12:0] expected_symbols =
        (data_rate ? 13'd96 : 13'd48) +
        (data_rate ? payload_symbols_250k : payload_symbols_1m);

    // Each CSK group contains exactly 4 DQPSK symbols / 4 subchirps.
    // Both rates produce an expected_symbols count divisible by 4.
    wire [10:0] expected_csk_groups =
        expected_symbols[12:0] / 13'd4;

    // Capture the DQPSK stream independently of the much slower CSK sample
    // stream. This is the key rate-domain crossing inside the transmitter.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            dqpsk_wr_count  <= 11'd0;
            capture_active  <= 1'b0;
            csk_start_pending <= 1'b0;
        end else begin

            if (start_cmd) begin
                dqpsk_wr_count <= 11'd0;
                capture_active <= 1'b1;
                csk_start_pending <= 1'b0;
            end

            if (capture_active && dqpsk_valid) begin
                dqpsk_mem_real[dqpsk_wr_count] <= s_real;
                dqpsk_mem_imag[dqpsk_wr_count] <= s_imag;

                if (dqpsk_wr_count + 11'd1 >= expected_symbols[10:0]) begin
                    dqpsk_wr_count    <= dqpsk_wr_count + 11'd1;
                    capture_active    <= 1'b0;
                    csk_start_pending <= 1'b1;
                end else begin
                    dqpsk_wr_count <= dqpsk_wr_count + 11'd1;
                end
            end

            // A pending start is converted into a one-cycle start pulse below.
            if (csk_start_pending)
                csk_start_pending <= 1'b0;
        end
    end

    // ------------------------------------------------------------------------
    // 10. CSK sequence generation
    //
    // We use the lower-level CSK blocks directly so the top can:
    //   a) buffer DQPSK symbols,
    //   b) present one symbol per subchirp boundary, and
    //   c) compensate the registered ROM timing.
    // ------------------------------------------------------------------------
    reg csk_start_pulse;
    reg csk_running;

    wire [1:0] k_index;
    wire [5:0] sample_index;
    wire       csk_sample_valid;
    wire       subchirp_tick;
    wire       seq_active;
    wire       csk_seq_finished;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            csk_start_pulse <= 1'b0;
            csk_running     <= 1'b0;
        end else begin
            csk_start_pulse <= 1'b0;

            if (csk_start_pending) begin
                csk_start_pulse <= 1'b1;
                csk_running     <= 1'b1;

                $display("[%0t] TOP CSK START: expected_symbols=%0d expected_groups=%0d",
                         $time, expected_symbols, expected_csk_groups);
            end

            if (csk_running && !seq_active)
                csk_running <= 1'b0;
        end
    end

    csk_sequencer u_csk_sequencer (
        .clk              (clk),
        .reset            (reset),
        .start            (csk_start_pulse),
        .m                (CSK_M),
        .num_groups       (expected_csk_groups),

        .k_index          (k_index),
        .sample_index     (sample_index),
        .csk_sample_valid (csk_sample_valid),
        .subchirp_tick    (subchirp_tick),
        .seq_active       (seq_active),
        .finished         (csk_seq_finished)
    );

    wire [1:0] waveform_id;

    csk_waveform_selector u_csk_selector (
        .m           (CSK_M),
        .k           (k_index),
        .waveform_id (waveform_id)
    );

    wire signed [5:0] i_c;
    wire signed [5:0] q_c;

    csk_waveform_rom u_csk_rom (
        .clk          (clk),
        .waveform_id  (waveform_id),
        .sample_index (sample_index),
        .i_c          (i_c),
        .q_c          (q_c)
    );

    // One DQPSK symbol is held for one complete subchirp.
    reg [10:0] csk_symbol_index;

    wire signed [1:0] csk_s_real =
        dqpsk_mem_real[csk_symbol_index];

    wire signed [1:0] csk_s_imag =
        dqpsk_mem_imag[csk_symbol_index];

    // subchirp_tick is produced at the boundary and remains high for the
    // following cycle. The multiplier samples the symbol on that boundary.
    wire multiplier_dqpsk_valid = subchirp_tick;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            csk_symbol_index <= 11'd0;
        end else begin
            if (csk_start_pulse)
                csk_symbol_index <= 11'd0;
            else if (subchirp_tick)
                csk_symbol_index <= csk_symbol_index + 11'd1;
        end
    end

    // The waveform ROM is registered. Two valid stages are used so the
    // multiplier consumes the ROM sample corresponding to the same
    // sample_index, including at subchirp boundaries.
    reg csk_valid_d1;
    reg csk_valid_d2;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            csk_valid_d1 <= 1'b0;
            csk_valid_d2 <= 1'b0;
        end else begin
            csk_valid_d1 <= csk_sample_valid;
            csk_valid_d2 <= csk_valid_d1;
        end
    end

    wire signed [7:0] css_i;
    wire signed [7:0] css_q;
    wire               css_valid;

    dqpsk_csk_multiplier u_dqpsk_csk_multiplier (
        .clk              (clk),
        .reset            (reset),

        .dqpsk_valid      (multiplier_dqpsk_valid),
        .s_real           (csk_s_real),
        .s_imag           (csk_s_imag),

        .csk_sample_valid (csk_valid_d2),
        .i_c              (i_c),
        .q_c              (q_c),

        .css_i            (css_i),
        .css_q            (css_q),
        .css_valid        (css_valid)
    );

    assign Tx_real = css_i;
    assign Tx_imag = css_q;

    // ------------------------------------------------------------------------
    // 11. Final transmitter completion
    //
    // done_Tx is a one-clock pulse after:
    //   1) CSK has finished (seq_active went low), and
    //   2) the delayed CSS-valid stream has drained.
    //
    // csk_running is cleared in a separate clocked block when seq_active goes
    // low. Therefore we latch the CSK completion explicitly instead of using
    // csk_running directly in the done condition.
    // ------------------------------------------------------------------------
    reg css_seen;
    reg csk_finished;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            css_seen     <= 1'b0;
            csk_finished <= 1'b0;
            done_Tx      <= 1'b0;
        end else begin
            done_Tx <= 1'b0;

            if (csk_start_pulse) begin
                css_seen     <= 1'b0;
                csk_finished <= 1'b0;
            end

            if (css_valid)
                css_seen <= 1'b1;

            // Latch the sequencer completion before csk_running is cleared.
            if (csk_seq_finished)
                csk_finished <= 1'b1;

            // Wait for the delayed CSS pipeline to drain.
            if (csk_finished && css_seen && !css_valid) begin
                done_Tx      <= 1'b1;
                css_seen     <= 1'b0;
                csk_finished <= 1'b0;
            end
        end
    end

    assign busy = ctrl_busy ||
                  capture_active ||
                  csk_start_pending ||
                  csk_running ||
                  css_seen ||
                  csk_finished;

endmodule

