`timescale 1ns / 1ps

module tb_csk_waveform_rom;

    reg         clk;
    reg  [1:0]  waveform_id;
    reg  [5:0]  sample_index;
    wire signed [5:0] i_c, q_c;

    // ============================================================
    // DUT
    // ============================================================
    csk_waveform_rom dut (
        .clk          (clk),
        .waveform_id  (waveform_id),
        .sample_index (sample_index),
        .i_c          (i_c),
        .q_c          (q_c)
    );

    // ============================================================
    // Clock: 10 ns period
    // ============================================================
    always #5 clk = ~clk;

    // ============================================================
    // Independent golden copy of the ROM content
    // (own load, not sourced from the DUT's internal arrays)
    // ============================================================
    reg signed [5:0] gwave_i [0:151];
    reg signed [5:0] gwave_q [0:151];

    initial begin
        $readmemb("../Test_Vectors/Phase_4_DQPSK_CSK/csk_rom_i.txt", gwave_i);
        $readmemb("../Test_Vectors/Phase_4_DQPSK_CSK/csk_rom_q.txt", gwave_q);
    end

    // ============================================================
    // Test counters
    // ============================================================
    integer errors;
    integer addrs_checked;

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
    // Loop variables
    // ============================================================
    integer wid, sidx, addr;

    // ============================================================
    // Main test: exhaustive address sweep
    // ============================================================
    initial begin

        clk = 1'b0;
        waveform_id = 2'd0;
        sample_index = 6'd0;
        errors = 0;
        addrs_checked = 0;

        // let $readmemb settle before the first check
        @(negedge clk);
        @(negedge clk);

        $display("==============================================");
        $display("Sweeping all 152 ROM addresses (4 waveforms x 38 samples)");
        $display("==============================================");

        for (wid = 0; wid < 4; wid = wid + 1) begin
            for (sidx = 0; sidx < 38; sidx = sidx + 1) begin

                waveform_id  = wid[1:0];
                sample_index = sidx[5:0];
                addr         = wid * 38 + sidx;

                // one full cycle for the address to settle before the
                // capturing posedge, one more to safely sample the
                // registered output afterward
                @(negedge clk);
                @(negedge clk);

                check_int("i_c", $signed(i_c), $signed(gwave_i[addr]));
                check_int("q_c", $signed(q_c), $signed(gwave_q[addr]));

                addrs_checked = addrs_checked + 1;
            end
        end

        $display("");
        $display("==============================================");

        if (errors == 0) begin
            $display(
                "tb_csk_waveform_rom: PASSED - %0d addresses checked, no errors",
                addrs_checked
            );
        end else begin
            $display(
                "tb_csk_waveform_rom: FAILED - %0d errors found (%0d addresses checked)",
                errors,
                addrs_checked
            );
        end

        $display("==============================================");

        $finish;
    end

    // ============================================================
    // Timeout protection
    // ============================================================
    initial begin
        #50000;
        $display("tb_csk_waveform_rom: TIMEOUT");
        $finish;
    end

endmodule