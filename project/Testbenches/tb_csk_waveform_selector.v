`timescale 1ns / 1ps

module tb_csk_waveform_selector;

    reg  [2:0] m;
    reg  [1:0] k;
    wire [1:0] waveform_id;

    // ============================================================
    // DUT
    // ============================================================
    csk_waveform_selector dut (
        .m           (m),
        .k           (k),
        .waveform_id (waveform_id)
    );

    // ============================================================
    // Clock: 10 ns period (used only to settle combinational stimulus)
    // ============================================================
    reg clk;
    always #5 clk = ~clk;

    // ============================================================
    // Independent reference: Table 2-3 (sign of f_k,m), transcribed
    // directly from the standard, not derived from the DUT's own
    // case statement.
    // ============================================================
    function signed [1:0] sign_f_table;
        input [2:0] mm;
        input [1:0] kk;
        begin
            case ({mm, kk})
                // m=1:  -  +  +  -
                {3'd1,2'd0}: sign_f_table = -2'sd1;
                {3'd1,2'd1}: sign_f_table =  2'sd1;
                {3'd1,2'd2}: sign_f_table =  2'sd1;
                {3'd1,2'd3}: sign_f_table = -2'sd1;
                // m=2:  +  -  -  +
                {3'd2,2'd0}: sign_f_table =  2'sd1;
                {3'd2,2'd1}: sign_f_table = -2'sd1;
                {3'd2,2'd2}: sign_f_table = -2'sd1;
                {3'd2,2'd3}: sign_f_table =  2'sd1;
                // m=3:  -  +  +  -
                {3'd3,2'd0}: sign_f_table = -2'sd1;
                {3'd3,2'd1}: sign_f_table =  2'sd1;
                {3'd3,2'd2}: sign_f_table =  2'sd1;
                {3'd3,2'd3}: sign_f_table = -2'sd1;
                // m=4:  +  -  -  +
                {3'd4,2'd0}: sign_f_table =  2'sd1;
                {3'd4,2'd1}: sign_f_table = -2'sd1;
                {3'd4,2'd2}: sign_f_table = -2'sd1;
                default:     sign_f_table =  2'sd1;   // m=4,k=3
            endcase
        end
    endfunction

    // ============================================================
    // Independent reference: Table 2-4 (value of zeta_k,m)
    // ============================================================
    function signed [1:0] zeta_table;
        input [2:0] mm;
        input [1:0] kk;
        begin
            case ({mm, kk})
                // m=1: +1 +1 -1 -1
                {3'd1,2'd0}: zeta_table =  2'sd1;
                {3'd1,2'd1}: zeta_table =  2'sd1;
                {3'd1,2'd2}: zeta_table = -2'sd1;
                {3'd1,2'd3}: zeta_table = -2'sd1;
                // m=2: +1 -1 +1 -1
                {3'd2,2'd0}: zeta_table =  2'sd1;
                {3'd2,2'd1}: zeta_table = -2'sd1;
                {3'd2,2'd2}: zeta_table =  2'sd1;
                {3'd2,2'd3}: zeta_table = -2'sd1;
                // m=3: -1 -1 +1 +1
                {3'd3,2'd0}: zeta_table = -2'sd1;
                {3'd3,2'd1}: zeta_table = -2'sd1;
                {3'd3,2'd2}: zeta_table =  2'sd1;
                {3'd3,2'd3}: zeta_table =  2'sd1;
                // m=4: -1 +1 -1 +1
                {3'd4,2'd0}: zeta_table = -2'sd1;
                {3'd4,2'd1}: zeta_table =  2'sd1;
                {3'd4,2'd2}: zeta_table = -2'sd1;
                default:     zeta_table =  2'sd1;    // m=4,k=3
            endcase
        end
    endfunction

    // ============================================================
    // waveform_id encoding, per csk_waveform_selector.v's own
    // documented contract with the ROM:
    //   0: sign(f) = -, zeta = +1
    //   1: sign(f) = +, zeta = +1
    //   2: sign(f) = +, zeta = -1
    //   3: sign(f) = -, zeta = -1
    // ============================================================
    function [1:0] expected_waveform_id;
        input [2:0] mm;
        input [1:0] kk;
        reg signed [1:0] sf, zt;
        begin
            sf = sign_f_table(mm, kk);
            zt = zeta_table(mm, kk);

            if      (sf == -2'sd1 && zt ==  2'sd1) expected_waveform_id = 2'd0;
            else if (sf ==  2'sd1 && zt ==  2'sd1) expected_waveform_id = 2'd1;
            else if (sf ==  2'sd1 && zt == -2'sd1) expected_waveform_id = 2'd2;
            else                                    expected_waveform_id = 2'd3;
        end
    endfunction

    // ============================================================
    // Test counters
    // ============================================================
    integer errors;
    integer combos_checked;

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
    integer mm, kk;

    // ============================================================
    // Main test: exhaustive sweep of all (m,k) combinations
    // ============================================================
    initial begin

        clk = 1'b0;
        m = 3'd1;
        k = 2'd0;
        errors = 0;
        combos_checked = 0;

        @(negedge clk);

        $display("==============================================");
        $display("Sweeping all 16 (m,k) combinations, m=1..4, k=0..3");
        $display("==============================================");

        for (mm = 1; mm <= 4; mm = mm + 1) begin
            for (kk = 0; kk <= 3; kk = kk + 1) begin

                m = mm[2:0];
                k = kk[1:0];

                @(negedge clk);

                check_int(
                    "waveform_id",
                    waveform_id,
                    expected_waveform_id(mm[2:0], kk[1:0])
                );

                combos_checked = combos_checked + 1;
            end
        end

        $display("");
        $display("==============================================");

        if (errors == 0) begin
            $display(
                "tb_csk_waveform_selector: PASSED - %0d combinations checked, no errors",
                combos_checked
            );
        end else begin
            $display(
                "tb_csk_waveform_selector: FAILED - %0d errors found (%0d combinations checked)",
                errors,
                combos_checked
            );
        end

        $display("==============================================");

        $finish;
    end

    // ============================================================
    // Timeout protection
    // ============================================================
    initial begin
        #5000;
        $display("tb_csk_waveform_selector: TIMEOUT");
        $finish;
    end

endmodule