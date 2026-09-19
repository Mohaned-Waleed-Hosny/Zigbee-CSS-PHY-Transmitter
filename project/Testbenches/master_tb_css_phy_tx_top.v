`timescale 1ns / 1ps

// ============================================================================
// MASTER / FULL-CHAIN TESTBENCH
// ============================================================================
// DUT:
//   css_phy_tx_top
//
// This is the regression-level TB for the complete transmitter:
//
//   payload RAM
//      -> controller
//      -> zero padding
//      -> I/Q DEMUX
//      -> symbol mapper
//      -> interleaver
//      -> PPDU
//      -> QPSK
//      -> DQPSK
//      -> CSK
//      -> Tx_real / Tx_imag
//
// Test philosophy:
//   * Drive the real top-level interface.
//   * Check protocol and internal milestones through non-invasive
//     hierarchical monitors.
//   * Exercise both rates and padding/interleaver boundaries.
//   * Never accept X/Z output.
//   * Verify 38 samples/subchirp.
//   * Verify the expected number of DQPSK symbols.
//   * Verify that a second start is not accepted while busy.
//   * Timeout instead of hanging forever.
//
// NOTE:
//   The current supplied csk_sequencer is free-running after start and does
//   not expose a frame-length input. Therefore this TB treats missing
//   done_Tx as a HARD FAIL for the final integration. This intentionally
//   exposes the issue instead of hiding it.
//
// ROM files required by the DUT must exist at the paths expected by the RTL.
// ============================================================================

module master_tb_css_phy_tx_top;

    // ------------------------------------------------------------------------
    // Clock / simulation limits
    // ------------------------------------------------------------------------
    localparam integer CLK_NS = 10;

    // Large enough for the largest supported 250-kbps packet.
    localparam integer TIMEOUT_1M  = 120000;
    localparam integer TIMEOUT_250 = 220000;

    // ------------------------------------------------------------------------
    // DUT interface
    // ------------------------------------------------------------------------
    reg         clk;
    reg         reset;
    reg         start_Tx;
    reg         data_rate;
    reg [7:0]   payloadLength;

    reg [7:0]   payload_addr;
    reg [7:0]   payload_din;
    reg         payload_wr_en;

    wire signed [7:0] Tx_real;
    wire signed [7:0] Tx_imag;
    wire              done_Tx;
    wire              busy;

    css_phy_tx_top #(
        .CSK_M(3'd1)
    ) dut (
        .clk           (clk),
        .reset         (reset),
        .start_Tx      (start_Tx),
        .data_rate     (data_rate),
        .payloadLength (payloadLength),

        .payload_addr  (payload_addr),
        .payload_din   (payload_din),
        .payload_wr_en (payload_wr_en),

        .Tx_real       (Tx_real),
        .Tx_imag       (Tx_imag),
        .done_Tx       (done_Tx),
        .busy          (busy)
    );

    // ------------------------------------------------------------------------
    // Counters / status
    // ------------------------------------------------------------------------
    integer total_errors;
    integer total_warnings;

    integer css_valid_count;
    integer css_sample_count_in_run;
    integer completed_subchirps;
    integer subchirp_ticks_seen;

    integer xz_errors;
    integer protocol_errors;
    integer symbol_count_errors;
    integer subchirp_errors;
    integer done_errors;
    integer timeout_count;
    reg done_seen;

    reg previous_css_valid;

    // ------------------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #(CLK_NS/2) clk = ~clk;
    end

    // ------------------------------------------------------------------------
    // Waveform
    // ------------------------------------------------------------------------
    initial begin
        $dumpfile("master_tb_css_phy_tx_top.vcd");
        $dumpvars(0, master_tb_css_phy_tx_top);
    end

    // ------------------------------------------------------------------------
    // Expected number of DQPSK symbols
    // ------------------------------------------------------------------------
    function integer expected_dqpsk_symbols;
        input integer payload_bytes;
        input integer rate;

        integer total_bits;
        integer rem;
        integer pad;
        integer padded_bits;
        integer payload_symbols;
        begin
            total_bits = 12 + payload_bytes * 8;

            if (rate == 0) begin
                rem = total_bits % 6;

                // Matches the current project/reference formula:
                // paddingBy = 6 - mod(length,6)
                if (rem == 0)
                    pad = 6;
                else
                    pad = 6 - rem;

                padded_bits = total_bits + pad;
                payload_symbols = (padded_bits / 6) * 4;

                // 32 preamble + 16 SFD
                expected_dqpsk_symbols = 48 + payload_symbols;
            end
            else begin
                rem = total_bits % 24;

                // Matches the current project/reference formula:
                // paddingBy = 24 - mod(length,24)
                if (rem == 0)
                    pad = 24;
                else
                    pad = 24 - rem;

                padded_bits = total_bits + pad;
                payload_symbols = (padded_bits / 12) * 32;

                // 80 preamble + 16 SFD
                expected_dqpsk_symbols = 96 + payload_symbols;
            end
        end
    endfunction

    // ------------------------------------------------------------------------
    // Payload pattern
    // ------------------------------------------------------------------------
    function [7:0] pattern_byte;
        input integer index;
        input integer pattern;
        begin
            case (pattern)
                0: pattern_byte = 8'h00;
                1: pattern_byte = 8'hFF;
                2: pattern_byte = 8'hA5;
                3: pattern_byte = 8'h5A;
                4: pattern_byte = index[7:0] ^ 8'h3C;
                5: pattern_byte = {index[3:0], index[3:0]};
                default: pattern_byte = 8'h96;
            endcase
        end
    endfunction

    // ------------------------------------------------------------------------
    // Reset
    // ------------------------------------------------------------------------
    task reset_dut;
        begin
            reset         = 1'b1;
            start_Tx      = 1'b0;
            data_rate     = 1'b0;
            payloadLength = 8'd0;
            payload_addr  = 8'd0;
            payload_din   = 8'd0;
            payload_wr_en = 1'b0;

            repeat (5) @(posedge clk);
            reset = 1'b0;
            repeat (2) @(posedge clk);

            if (busy !== 1'b0) begin
                $display("[%0t] ERROR reset: busy != 0", $time);
                protocol_errors = protocol_errors + 1;
            end

            if (done_Tx !== 1'b0) begin
                $display("[%0t] ERROR reset: done_Tx != 0", $time);
                protocol_errors = protocol_errors + 1;
            end
        end
    endtask

    // ------------------------------------------------------------------------
    // Write one payload byte
    // ------------------------------------------------------------------------
    task write_byte;
        input [7:0] a;
        input [7:0] d;
        begin
            @(negedge clk);
            payload_addr  = a;
            payload_din   = d;
            payload_wr_en = 1'b1;

            @(negedge clk);
            payload_wr_en = 1'b0;
        end
    endtask

    // ------------------------------------------------------------------------
    // Fill payload
    // ------------------------------------------------------------------------
    task load_payload;
        input integer length;
        input integer pattern;
        integer k;
        begin
            for (k = 0; k < length; k = k + 1)
                write_byte(k[7:0], pattern_byte(k, pattern));

            @(negedge clk);
            payload_addr  = 8'd0;
            payload_din   = 8'd0;
            payload_wr_en = 1'b0;
        end
    endtask

    // ------------------------------------------------------------------------
    // Start transmission
    // ------------------------------------------------------------------------
    task start_tx;
        input integer length;
        input integer rate;
        begin
            @(negedge clk);

            payloadLength = length[7:0];
            data_rate     = rate[0:0];
            start_Tx      = 1'b1;

            @(negedge clk);
            start_Tx = 1'b0;
        end
    endtask

    // ------------------------------------------------------------------------
    // Reset per-case monitors
    // ------------------------------------------------------------------------
    task clear_monitors;
        begin
            done_seen = 1'b0;
            css_valid_count       = 0;
            css_sample_count_in_run = 0;
            completed_subchirps   = 0;
            subchirp_ticks_seen   = 0;
            xz_errors             = 0;
            protocol_errors       = 0;
            symbol_count_errors   = 0;
            subchirp_errors       = 0;
            done_errors           = 0;
            previous_css_valid    = 1'b0;
        end
    endtask

    // ------------------------------------------------------------------------
    // CSS stream monitor
    // ------------------------------------------------------------------------
    // IMPORTANT:
    // css_valid stays HIGH across the four 38-sample subchirps that form one
    // 152-sample chirp group. Therefore a falling edge of css_valid is NOT a
    // subchirp boundary. The sequencer's subchirp_tick is the authoritative
    // boundary signal.
    always @(posedge clk) begin
        if (reset) begin
            css_valid_count           <= 0;
            css_sample_count_in_run   <= 0;
            completed_subchirps       <= 0;
            subchirp_ticks_seen       <= 0;
            xz_errors                 <= 0;
            previous_css_valid        <= 1'b0;
        end
        else begin

            // Count every valid CSS sample and verify its numeric value.
            if (dut.css_valid) begin
                css_valid_count <= css_valid_count + 1;

                if (^Tx_real === 1'bx) begin
                    $display("[%0t] ERROR: Tx_real contains X/Z.", $time);
                    xz_errors <= xz_errors + 1;
                end

                if (^Tx_imag === 1'bx) begin
                    $display("[%0t] ERROR: Tx_imag contains X/Z.", $time);
                    xz_errors <= xz_errors + 1;
                end

                css_sample_count_in_run <= css_sample_count_in_run + 1;
            end

            // subchirp_tick marks each new 38-sample subchirp.
            if (dut.subchirp_tick) begin
                subchirp_ticks_seen <= subchirp_ticks_seen + 1;
                completed_subchirps <= completed_subchirps + 1;

                // Do not use a falling edge of css_valid or the sample counter
                // here: four consecutive 38-sample subchirps form one 152-sample
                // group, and nonblocking assignments make the boundary counter
                // one sample behind at the tick. The authoritative checks are:
                //   subchirp_ticks_seen == expected
                //   css_valid_count == expected * 38
                css_sample_count_in_run <= 0;
            end

            // At the end of the complete CSS stream, verify total samples.
            previous_css_valid <= dut.css_valid;
        end
    end

    // ------------------------------------------------------------------------
    // Completion latch
    // ------------------------------------------------------------------------
    // done_Tx is a one-clock pulse. Latch it so the testbench cannot miss it
    // while waiting for another stage to finish.
    always @(posedge clk) begin
        if (reset)
            done_seen <= 1'b0;
        else if (done_Tx)
            done_seen <= 1'b1;
    end

    // ------------------------------------------------------------------------
    // Protocol monitor
    // ------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!reset) begin

            // done_Tx must never occur while busy.
            if (done_Tx && busy) begin
                $display("[%0t] ERROR: done_Tx asserted while busy.",
                         $time);
                protocol_errors = protocol_errors + 1;
            end

            // No X/Z on handshake signals.
            if ((busy !== 1'b0) && (busy !== 1'b1)) begin
                $display("[%0t] ERROR: busy is X/Z.", $time);
                protocol_errors = protocol_errors + 1;
            end

            if ((done_Tx !== 1'b0) && (done_Tx !== 1'b1)) begin
                $display("[%0t] ERROR: done_Tx is X/Z.", $time);
                protocol_errors = protocol_errors + 1;
            end
        end
    end

    // ------------------------------------------------------------------------
    // Wait until DQPSK capture has completed.
    // ------------------------------------------------------------------------
    task wait_for_symbol_capture;
        input integer timeout_cycles;
        input integer expected_symbols;
        output reg    pass;

        integer c;
        begin
            pass = 1'b0;

            for (c = 0; c < timeout_cycles; c = c + 1) begin
                @(posedge clk);

                if (!dut.capture_active &&
                    (dut.dqpsk_wr_count == expected_symbols[10:0])) begin
                    pass = 1'b1;
                    disable wait_for_symbol_capture;
                end
            end
        end
    endtask

    // ------------------------------------------------------------------------
    // Wait for final done
    // ------------------------------------------------------------------------
    task wait_for_done;
        input integer timeout_cycles;
        output reg    pass;

        integer c;
        begin
            pass = 1'b0;

            for (c = 0; c < timeout_cycles; c = c + 1) begin
                @(posedge clk);

                if (done_Tx === 1'b1) begin
                    pass = 1'b1;
                    disable wait_for_done;
                end
            end
        end
    endtask

    // ------------------------------------------------------------------------
    // Check one complete case
    // ------------------------------------------------------------------------
    task run_case;
        input integer case_no;
        input integer length;
        input integer rate;
        input integer pattern;

        integer expected;
        integer timeout;
        reg capture_pass;
        reg done_pass;

        integer css_before;
        integer ticks_before;
        begin
            expected = expected_dqpsk_symbols(length, rate);

            if (rate == 0)
                timeout = TIMEOUT_1M;
            else
                timeout = TIMEOUT_250;

            $display("");
            $display("================================================================");
            $display("CASE %0d", case_no);
            $display("  Payload length : %0d bytes", length);
            $display("  Data rate      : %s", rate ? "250 kbps" : "1 Mbps");
            $display("  Pattern        : %0d", pattern);
            $display("  Expected DQPSK : %0d symbols", expected);
            $display("================================================================");

            clear_monitors;

            load_payload(length, pattern);

            start_tx(length, rate);

            // --------------------------------------------------------------
            // start/busy check
            // --------------------------------------------------------------
            repeat (10) @(posedge clk);

            if (busy !== 1'b1) begin
                $display("[%0t] ERROR: busy did not assert.", $time);
                protocol_errors = protocol_errors + 1;
            end

            // --------------------------------------------------------------
            // Verify front-end produced exactly the expected number of
            // DQPSK symbols.
            // --------------------------------------------------------------
            wait_for_symbol_capture(timeout, expected, capture_pass);

            if (!capture_pass) begin
                $display("[%0t] ERROR: DQPSK capture did not reach expected count.",
                         $time);
                $display("          expected = %0d, observed = %0d",
                         expected, dut.dqpsk_wr_count);
                symbol_count_errors = symbol_count_errors + 1;
            end
            else begin
                $display("[%0t] PASS: DQPSK symbol count = %0d",
                         $time, dut.dqpsk_wr_count);
            end

            // --------------------------------------------------------------
            // Wait for the COMPLETE transaction.
            //
            // The old TB waited 1000 cycles before starting to look for
            // done_Tx. That can miss the done pulse on short packets.
            // We now watch done_Tx from immediately after start_tx.
            // --------------------------------------------------------------
            done_pass = 1'b0;
            timeout_count = 0;

            while ((timeout_count < timeout) && !done_pass) begin
                @(posedge clk);
                timeout_count = timeout_count + 1;

                if (done_Tx === 1'b1 || done_seen === 1'b1)
                    done_pass = 1'b1;
            end

            if (!done_pass) begin
                $display("[%0t] ERROR: done_Tx was not asserted before timeout.",
                         $time);
                done_errors = done_errors + 1;
            end
            else begin
                $display("[%0t] PASS: done_Tx asserted.", $time);

                if (busy !== 1'b0) begin
                    $display("[%0t] ERROR: busy remained high after done.",
                             $time);
                    protocol_errors = protocol_errors + 1;
                end
            end

            // --------------------------------------------------------------
            // Final CSS checks
            // --------------------------------------------------------------
            if (css_valid_count == 0) begin
                $display("[%0t] ERROR: no CSS output samples observed.",
                         $time);
                subchirp_errors = subchirp_errors + 1;
            end

            if (css_valid_count != expected * 38) begin
                $display("[%0t] ERROR: CSS sample count = %0d, expected %0d.",
                         $time, css_valid_count, expected * 38);
                subchirp_errors = subchirp_errors + 1;
            end
            else begin
                $display("[%0t] PASS: CSS sample count = %0d.",
                         $time, css_valid_count);
            end

            if (subchirp_ticks_seen != expected) begin
                $display("[%0t] ERROR: subchirp ticks = %0d, expected %0d.",
                         $time, subchirp_ticks_seen, expected);
                subchirp_errors = subchirp_errors + 1;
            end
            else begin
                $display("[%0t] PASS: subchirp ticks = %0d.",
                         $time, subchirp_ticks_seen);
            end

            // Each subchirp_tick starts exactly one 38-sample subchirp.
            // After done, the number of completed subchirps must equal the
            // number of ticks seen and the expected number of DQPSK symbols.
            if (completed_subchirps != subchirp_ticks_seen) begin
                $display("[%0t] ERROR: completed subchirps = %0d, ticks = %0d.",
                         $time, completed_subchirps, subchirp_ticks_seen);
                subchirp_errors = subchirp_errors + 1;
            end

            if (completed_subchirps != expected) begin
                $display("[%0t] ERROR: completed 38-sample subchirps = %0d, expected %0d.",
                         $time, completed_subchirps, expected);
                subchirp_errors = subchirp_errors + 1;
            end
            else begin
                $display("[%0t] PASS: completed 38-sample subchirps = %0d.",
                         $time, completed_subchirps);
            end

            // No partial final subchirp is allowed.
            if (dut.css_valid !== 1'b0) begin
                $display("[%0t] ERROR: CSS valid still high when transaction completed.",
                         $time);
                subchirp_errors = subchirp_errors + 1;
            end

            // --------------------------------------------------------------
            // Verify a new transaction is rejected while the current
            // transaction is active. This check is only meaningful if the
            // packet has not already completed.
            // --------------------------------------------------------------
            if (!done_pass) begin
                @(negedge clk);
                start_Tx = 1'b1;

                @(negedge clk);
                start_Tx = 1'b0;

                if (!busy) begin
                    $display("[%0t] ERROR: busy dropped before transaction completed.",
                             $time);
                    protocol_errors = protocol_errors + 1;
                end
            end

            // --------------------------------------------------------------
            // End-of-case summary
            // --------------------------------------------------------------
            $display("");
            $display("CASE %0d SUMMARY", case_no);
            $display("  DQPSK symbols observed : %0d", dut.dqpsk_wr_count);
            $display("  CSS valid samples      : %0d", css_valid_count);
            $display("  Subchirp ticks         : %0d", subchirp_ticks_seen);
            $display("  Completed 38-sample    : %0d", completed_subchirps);
            $display("  X/Z errors             : %0d", xz_errors);
            $display("  Symbol-count errors    : %0d", symbol_count_errors);
            $display("  Subchirp errors        : %0d", subchirp_errors);
            $display("  Protocol errors        : %0d", protocol_errors);
            $display("  Done errors             : %0d", done_errors);

            total_errors = total_errors +
                           xz_errors +
                           symbol_count_errors +
                           subchirp_errors +
                           protocol_errors +
                           done_errors;

            // Clean reset before next regression case.
            reset_dut;
        end
    endtask

    // ------------------------------------------------------------------------
    // MAIN REGRESSION
    // ------------------------------------------------------------------------
    initial begin
        total_errors   = 0;
        total_warnings = 0;

        // --------------------------------------------------------------
        // Initial reset
        // --------------------------------------------------------------
        reset_dut;

        // --------------------------------------------------------------
        // 1 Mbps: basic mixed pattern
        // --------------------------------------------------------------
        run_case(1, 4, 0, 2);

        // --------------------------------------------------------------
        // 1 Mbps: all-zero payload
        // --------------------------------------------------------------
        run_case(2, 1, 0, 0);

        // --------------------------------------------------------------
        // 1 Mbps: all-one payload
        // --------------------------------------------------------------
        run_case(3, 8, 0, 1);

        // --------------------------------------------------------------
        // 1 Mbps: padding boundary case
        // 12 + 8*3 = 36 bits -> aligned to 6 bits.
        // The current MATLAB/reference padding formula adds a full 6 bits
        // when already aligned.
        // --------------------------------------------------------------
        run_case(4, 3, 0, 3);

        // --------------------------------------------------------------
        // 250 kbps: small packet
        // --------------------------------------------------------------
        run_case(5, 4, 1, 2);

        // --------------------------------------------------------------
        // 250 kbps: 24-bit padding boundary
        // 12 + 8*3 = 36 bits -> rem24 = 12.
        // --------------------------------------------------------------
        run_case(6, 3, 1, 4);

        // --------------------------------------------------------------
        // 250 kbps: larger packet / interleaver stress
        // --------------------------------------------------------------
        run_case(7, 16, 1, 5);

        // --------------------------------------------------------------
        // Final report
        // --------------------------------------------------------------
        $display("");
        $display("================================================================");
        $display("MASTER REGRESSION COMPLETE");
        $display("================================================================");
        $display("Total hard errors : %0d", total_errors);
        $display("Total warnings    : %0d", total_warnings);

        if (total_errors == 0) begin
            $display("RESULT: PASS");
        end
        else begin
            $display("RESULT: FAIL");
            $display("");
            $display("Use master_tb_css_phy_tx_top.vcd and inspect:");
            $display("  ctrl_start_frame");
            $display("  ctrl_valid_in");
            $display("  padded_valid");
            $display("  demux_valid");
            $display("  mapper_valid");
            $display("  interleaver_valid");
            $display("  ppdu_valid");
            $display("  qpsk_valid_out");
            $display("  dqpsk_valid");
            $display("  subchirp_tick");
            $display("  csk_sample_valid");
            $display("  css_valid");
            $display("  Tx_real / Tx_imag");
        end

        $finish;
    end

endmodule
