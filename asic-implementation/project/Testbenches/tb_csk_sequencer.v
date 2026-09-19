`timescale 1ns / 1ps

module tb_csk_sequencer;

    reg         clk;
    reg         reset;
    reg         start;
    reg  [2:0]  m;

    wire [1:0]  k_index;
    wire [5:0]  sample_index;
    wire        csk_sample_valid;
    wire        subchirp_tick;
    wire        seq_active;

    // ============================================================
    // DUT
    // ============================================================
    csk_sequencer dut (
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

    // ============================================================
    // Clock: 10 ns period
    // ============================================================
    always #5 clk = ~clk;


    // ============================================================
    // Table 2-2: EVEN gap durations
    // ============================================================
    function [6:0] gap_even_of;
        input [2:0] mm;

        begin
            case (mm)
                3'd1: gap_even_of = 7'd10;
                3'd2: gap_even_of = 7'd20;
                3'd3: gap_even_of = 7'd30;
                3'd4: gap_even_of = 7'd40;
                default: gap_even_of = 7'd40;
            endcase
        end
    endfunction


    // ============================================================
    // Table 2-2: ODD gap durations
    // ============================================================
    function [6:0] gap_odd_of;
        input [2:0] mm;

        begin
            case (mm)
                3'd1: gap_odd_of = 7'd70;
                3'd2: gap_odd_of = 7'd60;
                3'd3: gap_odd_of = 7'd50;
                3'd4: gap_odd_of = 7'd40;
                default: gap_odd_of = 7'd40;
            endcase
        end
    endfunction


    // ============================================================
    // Test counters
    // ============================================================
    integer errors;
    integer groups_checked;


    // ============================================================
    // Integer check task
    // ============================================================
    task check_int;
        input [8*48-1:0] label;
        input integer got;
        input integer exp;

        begin
            if (got !== exp) begin
                errors = errors + 1;

                $display(
                    "[%0t] ERROR %0s: got=%0d expected=%0d",
                    $time,
                    label,
                    got,
                    exp
                );
            end
        end
    endtask


    // ============================================================
    // Bit check task
    // ============================================================
    task check_bit;
        input [8*48-1:0] label;
        input got;
        input exp;

        begin
            if (got !== exp) begin
                errors = errors + 1;

                $display(
                    "[%0t] ERROR %0s: got=%0b expected=%0b",
                    $time,
                    label,
                    got,
                    exp
                );
            end
        end
    endtask


    // ============================================================
    // Loop variables
    // ============================================================
    integer g;
    integer pos;
    integer gap_len;
    integer expected_gap;

    reg parity;


    // ============================================================
    // Run test for one value of m
    // ============================================================
    task run_one_m;

        input [2:0] mm;
        input integer num_groups;

        begin

            // ----------------------------------------------------
            // Apply reset
            // ----------------------------------------------------
            m     = mm;
            reset = 1'b1;
            start = 1'b0;

            @(negedge clk);
            @(negedge clk);

            reset = 1'b0;

            @(negedge clk);


            // ----------------------------------------------------
            // Check state before start
            // ----------------------------------------------------
            check_bit(
                "seq_active before start",
                seq_active,
                1'b0
            );

            check_bit(
                "csk_sample_valid before start",
                csk_sample_valid,
                1'b0
            );


            // ----------------------------------------------------
            // Start sequence
            // ----------------------------------------------------
            start = 1'b1;

            @(negedge clk);

            start = 1'b0;

            parity = 1'b0;


            // ====================================================
            // Groups
            // ====================================================
            for (g = 0; g < num_groups; g = g + 1) begin


                // ------------------------------------------------
                // Active burst
                // 4 subchirps
                // 38 samples/subchirp
                // Total = 152 samples
                // ------------------------------------------------
                for (pos = 0; pos < 152; pos = pos + 1) begin

                    check_bit(
                        "csk_sample_valid(active)",
                        csk_sample_valid,
                        1'b1
                    );

                    check_int(
                        "k_index",
                        k_index,
                        pos / 38
                    );

                    check_int(
                        "sample_index",
                        sample_index,
                        pos % 38
                    );

                    check_bit(
                        "seq_active(active)",
                        seq_active,
                        1'b1
                    );

                    check_bit(
                        "subchirp_tick",
                        subchirp_tick,
                        (pos % 38 == 0)
                    );

                    @(negedge clk);

                end


                groups_checked = groups_checked + 1;


                // ------------------------------------------------
                // Gap
                // ------------------------------------------------
                if (parity == 1'b0)
                    expected_gap = gap_even_of(mm);
                else
                    expected_gap = gap_odd_of(mm);

                parity = ~parity;


                for (
                    gap_len = 0;
                    gap_len < expected_gap;
                    gap_len = gap_len + 1
                ) begin

                    check_bit(
                        "csk_sample_valid(gap)",
                        csk_sample_valid,
                        1'b0
                    );

                    check_bit(
                        "subchirp_tick(gap)",
                        subchirp_tick,
                        1'b0
                    );

                    check_bit(
                        "seq_active(gap)",
                        seq_active,
                        1'b1
                    );

                    check_int(
                        "k_index(gap)",
                        k_index,
                        0
                    );

                    check_int(
                        "sample_index(gap)",
                        sample_index,
                        0
                    );

                    @(negedge clk);

                end

            end

        end

    endtask


    // ============================================================
    // Main test
    // ============================================================
    initial begin

        clk = 1'b0;
        reset = 1'b1;
        start = 1'b0;
        m = 3'd1;

        errors = 0;
        groups_checked = 0;


        // --------------------------------------------------------
        // Test m = 1
        // --------------------------------------------------------
        $display("==============================================");
        $display("Testing m = 1");
        $display("==============================================");

        run_one_m(3'd1, 3);


        // --------------------------------------------------------
        // Test m = 2
        // --------------------------------------------------------
        $display("==============================================");
        $display("Testing m = 2");
        $display("==============================================");

        run_one_m(3'd2, 3);


        // --------------------------------------------------------
        // Test m = 3
        // --------------------------------------------------------
        $display("==============================================");
        $display("Testing m = 3");
        $display("==============================================");

        run_one_m(3'd3, 3);


        // --------------------------------------------------------
        // Test m = 4
        // --------------------------------------------------------
        $display("==============================================");
        $display("Testing m = 4");
        $display("==============================================");

        run_one_m(3'd4, 3);


        // ========================================================
        // Final result
        // ========================================================
        $display("");
        $display("==============================================");

        if (errors == 0) begin

            $display(
                "tb_csk_sequencer: PASSED - %0d groups checked across m=1..4, no errors",
                groups_checked
            );

        end
        else begin

            $display(
                "tb_csk_sequencer: FAILED - %0d errors found (%0d groups checked)",
                errors,
                groups_checked
            );

        end

        $display("==============================================");

        $finish;

    end


    // ============================================================
    // Timeout protection
    // ============================================================
    initial begin

        #500000;

        $display("tb_csk_sequencer: TIMEOUT");

        $finish;

    end

endmodule