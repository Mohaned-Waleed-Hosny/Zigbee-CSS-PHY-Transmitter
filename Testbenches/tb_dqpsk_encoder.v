`timescale 1ns / 1ps

module tb_dqpsk_encoder;
    parameter DATA_RATE = 0; // 0: 1Mbps, 1: 250kbps (selects stimulus/output files only)

    reg               clk, reset, valid_in;
    reg  signed [1:0] x_real, x_imag;
    wire signed [1:0] s_real, s_imag;
    wire              valid_out;

    dqpsk_encoder dut (
        .clk(clk), .reset(reset), .valid_in(valid_in),
        .x_real(x_real), .x_imag(x_imag),
        .s_real(s_real), .s_imag(s_imag), .valid_out(valid_out)
    );

    // ---------------- Stimulus memories (Xn from QPSK Mapper stage) ---------------- //
    reg signed [1:0] xreal_mem [0:8191];
    reg signed [1:0] ximag_mem [0:8191];
    integer i, num_symbols;
    integer real_in_file, imag_in_file, file_real, file_imag;
    integer val_r, val_i, scan_r, scan_i;
    reg     more_data;
    reg [1024*8-1:0] str_in_real, str_in_imag, str_out_real, str_out_imag;

    // ---------------- Self-check bookkeeping ---------------- //
    reg signed [1:0] exp_real, exp_imag;
    reg              exp_valid;
    integer          sample_idx, error_count;

    always #5 clk = ~clk;

    // -------------------- Stimulus generation -------------------- //
    initial begin
        clk = 0; reset = 1; valid_in = 0; x_real = 2'sd0; x_imag = 2'sd0;
        sample_idx = 0; error_count = 0;

        $sformat(str_in_real, "../Test_Vectors/Phase_3_QPSK_Controller/X_real_matlab_rate%0d.txt", DATA_RATE);
        $sformat(str_in_imag, "../Test_Vectors/Phase_3_QPSK_Controller/X_imag_matlab_rate%0d.txt", DATA_RATE);

        real_in_file = $fopen(str_in_real, "r");
        imag_in_file = $fopen(str_in_imag, "r");
        if (real_in_file == 0 || imag_in_file == 0) begin
            $display("tb_dqpsk_encoder: ERROR - could not open input files");
            $finish;
        end

        // Plain signed-decimal parser: replaces $readmemb, which requires
        // literal binary digits and cannot handle a '-' sign in the file.
        more_data   = 1'b1;
        num_symbols = 0;
        while (more_data && num_symbols < 8192) begin
            scan_r = $fscanf(real_in_file, "%d", val_r);
            scan_i = $fscanf(imag_in_file, "%d", val_i);
            if (scan_r == 1 && scan_i == 1) begin
                xreal_mem[num_symbols] = val_r[1:0]; // two's-complement
                ximag_mem[num_symbols] = val_i[1:0]; // truncation is exact
                num_symbols = num_symbols + 1;       // for values in {-1,0,1}
            end else begin
                more_data = 1'b0;
            end
        end
        $fclose(real_in_file);
        $fclose(imag_in_file);

        $display("tb_dqpsk_encoder: loaded %0d symbols for DATA_RATE=%0d", num_symbols, DATA_RATE);

        #20 reset = 0;

        for (i = 0; i < num_symbols; i = i + 1) begin
            x_real   = xreal_mem[i];
            x_imag   = ximag_mem[i];
            valid_in = 1;
            #10 valid_in = 0; #50;
        end

        #200;
        if (error_count == 0)
            $display("tb_dqpsk_encoder: PASSED - all %0d samples matched", sample_idx);
        else
            $display("tb_dqpsk_encoder: FAILED - %0d / %0d samples mismatched", error_count, sample_idx);

        $fclose(file_real);
        $fclose(file_imag);
        $finish;
    end

    // -------------------- Golden output dump (project convention) -------------------- //
    initial begin
        $sformat(str_out_real, "../Test_Vectors/Phase_4_DQPSK_CSK/S_real_verilog_rate%0d.txt", DATA_RATE);
        $sformat(str_out_imag, "../Test_Vectors/Phase_4_DQPSK_CSK/S_imag_verilog_rate%0d.txt", DATA_RATE);
        file_real = $fopen(str_out_real, "w");
        file_imag = $fopen(str_out_imag, "w");
    end

    always @(posedge clk) begin
        if (valid_out) begin
            $fdisplay(file_real, "%b", s_real);
            $fdisplay(file_imag, "%b", s_imag);
        end
    end

    // -------------------- Independent expected-value model -------------------- //
    reg signed [1:0] g_real [0:3];
    reg signed [1:0] g_imag [0:3];
    reg signed [1:0] pr, pi, sr, si;
    integer          k;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            g_real[0] <= 2'sd1; g_real[1] <= 2'sd1; g_real[2] <= 2'sd1; g_real[3] <= 2'sd1;
            g_imag[0] <= 2'sd1; g_imag[1] <= 2'sd1; g_imag[2] <= 2'sd1; g_imag[3] <= 2'sd1;
            exp_real  <= 2'sd0; exp_imag <= 2'sd0; exp_valid <= 1'b0;
        end else begin
            exp_valid <= valid_in;
            if (valid_in) begin
                pr = g_real[3];
                pi = g_imag[3];

                if      (x_real ==  2'sd1 && x_imag ==  2'sd0) k = 0;
                else if (x_real ==  2'sd0 && x_imag ==  2'sd1) k = 1;
                else if (x_real == -2'sd1 && x_imag ==  2'sd0) k = 2;
                else                                            k = 3;

                case (k)
                    0: begin sr =  pr; si =  pi; end
                    1: begin sr = -pi; si =  pr; end
                    2: begin sr = -pr; si = -pi; end
                    default: begin sr = pi; si = -pr; end
                endcase

                exp_real <= sr;
                exp_imag <= si;

                g_real[3] <= g_real[2]; g_real[2] <= g_real[1];
                g_real[1] <= g_real[0]; g_real[0] <= sr;
                g_imag[3] <= g_imag[2]; g_imag[2] <= g_imag[1];
                g_imag[1] <= g_imag[0]; g_imag[0] <= si;
            end
        end
    end

    // -------------------- Comparator -------------------- //
    always @(posedge clk) begin
        if (exp_valid) begin
            sample_idx = sample_idx + 1;
            if (valid_out !== 1'b1) begin
                error_count = error_count + 1;
                $display("[%0t] sample %0d: valid_out NOT asserted when expected", $time, sample_idx);
            end else if (s_real !== exp_real || s_imag !== exp_imag) begin
                error_count = error_count + 1;
                $display("[%0t] sample %0d: MISMATCH  DUT=(%0d,%0d)  EXPECTED=(%0d,%0d)",
                          $time, sample_idx, s_real, s_imag, exp_real, exp_imag);
            end
        end
    end

endmodule