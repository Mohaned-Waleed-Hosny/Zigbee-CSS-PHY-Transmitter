`timescale 1ns / 1ps

module tb_dqpsk_csk_multiplier;

    reg               clk, reset;
    reg               dqpsk_valid;
    reg  signed [1:0] s_real, s_imag;
    reg               csk_sample_valid;
    reg  signed [5:0] i_c, q_c;

    wire signed [7:0] css_i, css_q;
    wire              css_valid;

    dqpsk_csk_multiplier dut (
        .clk(clk), .reset(reset),
        .dqpsk_valid(dqpsk_valid), .s_real(s_real), .s_imag(s_imag),
        .csk_sample_valid(csk_sample_valid), .i_c(i_c), .q_c(q_c),
        .css_i(css_i), .css_q(css_q), .css_valid(css_valid)
    );

    always #5 clk = ~clk;

    parameter MAX_VECTORS = 64;
    reg signed [1:0] sr_mem [0:MAX_VECTORS-1];
    reg signed [1:0] si_mem [0:MAX_VECTORS-1];
    reg signed [5:0] ic_mem [0:MAX_VECTORS-1];
    reg signed [5:0] qc_mem [0:MAX_VECTORS-1];
    reg signed [7:0] exp_i_mem [0:MAX_VECTORS-1];
    reg signed [7:0] exp_q_mem [0:MAX_VECTORS-1];

    integer f_sr, f_si, f_ic, f_qc, f_ei, f_eq;
    integer v_sr, v_si, v_ic, v_qc, v_ei, v_eq;
    integer s_sr, s_si, s_ic, s_qc, s_ei, s_eq;
    integer num_vectors;
    reg     more_data;

    integer errors, idx;

    initial begin
        clk = 0; reset = 1;
        dqpsk_valid = 0; csk_sample_valid = 0;
        s_real = 2'sd1; s_imag = 2'sd1; i_c = 0; q_c = 0;
        errors = 0;

        f_sr = $fopen("../Test_Vectors/Phase_4_DQPSK_CSK/s_real_mult_tb.txt", "r");
        f_si = $fopen("../Test_Vectors/Phase_4_DQPSK_CSK/s_imag_mult_tb.txt", "r");
        f_ic = $fopen("../Test_Vectors/Phase_4_DQPSK_CSK/ic_mult_tb.txt", "r");
        f_qc = $fopen("../Test_Vectors/Phase_4_DQPSK_CSK/qc_mult_tb.txt", "r");
        f_ei = $fopen("../Test_Vectors/Phase_4_DQPSK_CSK/css_real_expected.txt", "r");
        f_eq = $fopen("../Test_Vectors/Phase_4_DQPSK_CSK/css_imag_expected.txt", "r");

        if (f_sr==0 || f_si==0 || f_ic==0 || f_qc==0 || f_ei==0 || f_eq==0) begin
            $display("tb_dqpsk_csk_multiplier_matlab: ERROR - could not open one or more vector files");
            $finish;
        end

        more_data = 1'b1;
        num_vectors = 0;
        while (more_data && num_vectors < MAX_VECTORS) begin
            s_sr = $fscanf(f_sr, "%d", v_sr);
            s_si = $fscanf(f_si, "%d", v_si);
            s_ic = $fscanf(f_ic, "%d", v_ic);
            s_qc = $fscanf(f_qc, "%d", v_qc);
            s_ei = $fscanf(f_ei, "%d", v_ei);
            s_eq = $fscanf(f_eq, "%d", v_eq);

            if (s_sr==1 && s_si==1 && s_ic==1 && s_qc==1 && s_ei==1 && s_eq==1) begin
                sr_mem[num_vectors]    = v_sr[1:0];
                si_mem[num_vectors]    = v_si[1:0];
                ic_mem[num_vectors]    = v_ic[5:0];
                qc_mem[num_vectors]    = v_qc[5:0];
                exp_i_mem[num_vectors] = v_ei[7:0];
                exp_q_mem[num_vectors] = v_eq[7:0];
                num_vectors = num_vectors + 1;
            end else begin
                more_data = 1'b0;
            end
        end
        $fclose(f_sr); $fclose(f_si); $fclose(f_ic);
        $fclose(f_qc); $fclose(f_ei); $fclose(f_eq);

        $display("tb_dqpsk_csk_multiplier_matlab: loaded %0d MATLAB-generated vectors", num_vectors);

        @(negedge clk);
        @(negedge clk);
        reset = 0;
        @(negedge clk);

        for (idx = 0; idx < num_vectors; idx = idx + 1) begin
            // load this vector's Sn fresh each time -- these are directed
            // vectors, not a test of the 38-cycle hold, which belongs in
            // integration testing against the full csk_generator instead
            s_real = sr_mem[idx];
            s_imag = si_mem[idx];
            dqpsk_valid = 1'b1;
            @(negedge clk);
            dqpsk_valid = 1'b0;

            i_c = ic_mem[idx];
            q_c = qc_mem[idx];
            csk_sample_valid = 1'b1;
            @(negedge clk);

            if (css_valid !== 1'b1) begin
                errors = errors + 1;
                $display("[%0t] vector %0d: css_valid NOT asserted when expected", $time, idx);
            end else if (css_i !== exp_i_mem[idx] || css_q !== exp_q_mem[idx]) begin
                errors = errors + 1;
                $display("[%0t] vector %0d: MISMATCH DUT=(%0d,%0d) MATLAB expected=(%0d,%0d)",
                          $time, idx, $signed(css_i), $signed(css_q),
                          $signed(exp_i_mem[idx]), $signed(exp_q_mem[idx]));
            end

            csk_sample_valid = 1'b0;
            @(negedge clk);
        end

        if (errors == 0)
            $display("tb_dqpsk_csk_multiplier_matlab: PASSED - all %0d vectors matched MATLAB", num_vectors);
        else
            $display("tb_dqpsk_csk_multiplier_matlab: FAILED - %0d / %0d vectors mismatched", errors, num_vectors);

        $finish;
    end

endmodule