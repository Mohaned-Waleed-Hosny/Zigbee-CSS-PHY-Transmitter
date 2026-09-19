`timescale 1ns / 1ps
// ============================================================================
// controller  (adapted to the ACTUAL streaming pipeline, not the buffered
// "I/Q Buffer RAM + Preamble/SFD ROM" architecture of the original file)
// ----------------------------------------------------------------------------
// Owns: the payload RAM, PHY header (PHR) construction, and sequencing of:
//   this controller -> zero_padding -> demux_iq -> symbol_mapper
//                    -> bit_interleaver -> form_ppdu -> qpsk_mapper
//
// WHY THE ORIGINAL PORTS/STATES ARE GONE:
//   - ram_read_addr/i_ram_data/q_ram_data : there is no pre-coded "I/Q Buffer
//     RAM" in this design - coding happens on the fly in symbol_mapper +
//     bit_interleaver as raw PHR/payload bits stream through zero_padding.
//   - rom_read_addr/rom_data (separate Preamble/SFD ROM) : form_ppdu already
//     generates preamble+SFD internally after start_frame; the controller
//     does not need to sequence a separate ROM for it.
//   - TX_PREAMBLE / TX_SFD states : dropped for the same reason - the
//     controller has no direct role in that phase, form_ppdu handles it
//     autonomously and even starts emitting BEFORE this controller finishes
//     feeding PHR/payload (see the frame_in_flight note below).
//   - TX_FLUSH (fixed 4 cycles) : replaced with actually counting
//     qpsk_mapper.valid_out pulses against an analytically-computed expected
//     total (preamble+SFD+coded payload chips), since 4 cycles is nowhere
//     near enough to drain the CSK generator's ~192-sample-per-4-symbols
//     output burst.
//
// WHAT'S KEPT, for drop-in compatibility with whatever already assumes this
// module is called `controller` with a `done_Tx` output:
//   - module name `controller`, port names start_Tx / data_rate / payload_len
//     / done_Tx.
//   - i_to_qpsk / q_to_qpsk / valid_to_qpsk are kept as pure pass-throughs of
//     form_ppdu's serial output (fp_i_out/fp_q_out/fp_valid_out, added as
//     inputs here) so any existing wiring to these three names still works,
//     even though the controller itself no longer computes them.
//
// SCOPE NOTE ON done_Tx: same caveat as before - this fires once the PHR+
// payload have been pushed all the way through qpsk_mapper. The DQPSK/CSK
// stage still has its own drain latency after the last qpsk_mapper sample;
// if that stage adds pipeline delay, the TE needs to extend this done_Tx
// (or add a further wait) before it is truly accurate for the top level.
//
// PHR bit order (confirmed from ChirpSpreadSpectrum_Tx.m) and payload byte
// order (ASSUMED MSB-first, unverified) are unchanged from css_tx_controller.v
// - see that file's header for the full derivation.
// ============================================================================
module controller (
    input  wire        clk,
    input  wire        reset,
    input  wire        start_Tx,
    input  wire        data_rate,       // 0: 1 Mbps, 1: 250 kbps
    input  wire [7:0]  payload_len,     // 1..127

    // ---- Payload RAM write port (replaces the old pre-coded I/Q buffer RAM) ----
    input  wire [7:0]  payload_addr,    // only bits [6:0] used (0..126)
    input  wire [7:0]  payload_din,
    input  wire        payload_wr_en,

    // ---- Drives the front-end pipeline ----
    output reg         start_frame,     // -> zero_padding/demux_iq/form_ppdu.start_frame
    output reg         valid_in,        // -> zero_padding.valid_in
    output reg         bit_in,          // -> zero_padding.bit_in

    // ---- Pass-through from form_ppdu's serial output to qpsk_mapper ----
    // (kept only to preserve the original i_to_qpsk/q_to_qpsk/valid_to_qpsk
    // names - wire form_ppdu directly to qpsk_mapper if you'd rather drop
    // this indirection.)
    input  wire        fp_i_out,
    input  wire        fp_q_out,
    input  wire        fp_valid_out,
    output wire        i_to_qpsk,
    output wire        q_to_qpsk,
    output wire        valid_to_qpsk,

    // ---- Completion tracking tap from the far end of the chain ----
    input  wire        qpsk_valid_out,  // -> qpsk_mapper.valid_out

    // ---- Status ----
    output reg         done_Tx,         // 1-cycle pulse, see SCOPE NOTE above
    output wire        busy
);

    assign i_to_qpsk     = fp_i_out;
    assign q_to_qpsk     = fp_q_out;
    assign valid_to_qpsk = fp_valid_out;

    // ------------------------------------------------------------------ //
    // Payload RAM: 127 bytes x 8 bits
    // ------------------------------------------------------------------ //
    reg [7:0] payload_ram [0:126];

    always @(posedge clk) begin
        if (payload_wr_en)
            payload_ram[payload_addr[6:0]] <= payload_din;
    end

    // ------------------------------------------------------------------ //
    // Combinational sizing: total PHR+payload bits, padding, expected chips
    // ------------------------------------------------------------------ //
    wire [10:0] total_data_bits_w = 11'd12 + ({3'd0, payload_len} * 11'd8);

    wire [10:0] rem6   = total_data_bits_w % 11'd6;
    wire [10:0] rem24  = total_data_bits_w % 11'd24;
    wire [10:0] pad6   = (rem6  == 0) ? 11'd6  : (11'd6  - rem6);
    wire [10:0] pad24  = (rem24 == 0) ? 11'd24 : (11'd24 - rem24);
    wire [10:0] padding_by  = data_rate ? pad24 : pad6;
    wire [10:0] padded_bits = total_data_bits_w + padding_by;

    wire [12:0] payload_chips_1m   = (padded_bits / 11'd6)  * 11'd4;
    wire [12:0] payload_chips_250k = (padded_bits / 11'd12) * 11'd32;
    wire [12:0] payload_chips      = data_rate ? payload_chips_250k : payload_chips_1m;
    wire [12:0] preamble_sfd_len   = data_rate ? 13'd96 : 13'd48;
    wire [12:0] expected_chip_count_w = preamble_sfd_len + payload_chips;

    // ------------------------------------------------------------------ //
    // FSM
    // ------------------------------------------------------------------ //
    localparam F_IDLE  = 2'd0;
    localparam F_START = 2'd1;
    localparam F_SEND  = 2'd2;

    reg [1:0]  feed_state;
    reg [7:0]  payload_length_reg;
    reg [10:0] total_bits_reg;
    reg [10:0] serial_idx;
    reg [12:0] expected_chip_count_reg;
    reg [12:0] chip_counter;
    reg        frame_in_flight;

    assign busy = frame_in_flight || (feed_state != F_IDLE);

    wire phr_bit_value = (serial_idx < 11'd7) ? payload_length_reg[serial_idx[2:0]] : 1'b0;

    wire [9:0] payload_bit_idx   = serial_idx[9:0] - 10'd12;
    wire [6:0] payload_byte_addr = payload_bit_idx[9:3];
    wire [2:0] payload_bit_pos   = payload_bit_idx[2:0];
    wire       payload_bit_value = payload_ram[payload_byte_addr][3'd7 - payload_bit_pos];

    wire data_bit_next = (serial_idx < 11'd12) ? phr_bit_value : payload_bit_value;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            feed_state              <= F_IDLE;
            frame_in_flight         <= 1'b0;
            start_frame             <= 1'b0;
            valid_in                <= 1'b0;
            bit_in                  <= 1'b0;
            done_Tx                 <= 1'b0;
            payload_length_reg      <= 8'd0;
            total_bits_reg          <= 11'd0;
            serial_idx              <= 11'd0;
            expected_chip_count_reg <= 13'd0;
            chip_counter            <= 13'd0;
        end else begin
            start_frame <= 1'b0;
            valid_in    <= 1'b0;
            done_Tx     <= 1'b0;

            if (frame_in_flight && qpsk_valid_out) begin
                if (chip_counter + 13'd1 == expected_chip_count_reg) begin
                    frame_in_flight <= 1'b0;
                    chip_counter    <= 13'd0;
                    done_Tx         <= 1'b1;
                end else begin
                    chip_counter <= chip_counter + 13'd1;
                end
            end

            case (feed_state)
                F_IDLE: begin
                    if (start_Tx && !frame_in_flight) begin
                        payload_length_reg      <= payload_len;
                        total_bits_reg          <= total_data_bits_w;
                        expected_chip_count_reg <= expected_chip_count_w;
                        serial_idx              <= 11'd0;
                        frame_in_flight          <= 1'b1;
                        feed_state               <= F_START;
                    end
                end

                F_START: begin
                    start_frame <= 1'b1;
                    feed_state  <= F_SEND;
                end

                F_SEND: begin
                    if (serial_idx < total_bits_reg) begin
                        bit_in     <= data_bit_next;
                        valid_in   <= 1'b1;
                        serial_idx <= serial_idx + 11'd1;
                    end else begin
                        feed_state <= F_IDLE;
                    end
                end

                default: feed_state <= F_IDLE;
            endcase
        end
    end

endmodule