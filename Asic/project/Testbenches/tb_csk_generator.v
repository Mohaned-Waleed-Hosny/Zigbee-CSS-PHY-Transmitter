`timescale 1ns / 1ps

module tb_csk_generator;
    parameter DATA_RATE = 0;     // 0: 1Mbps, 1: 250kbps (selects Sn stimulus file)
    parameter M_SEL     = 3'd1;  // chirp-sequence index under test, 1..4

    reg               clk, reset, start;
    reg  [2:0]        m;
    reg               dqpsk_valid;
    reg  signed [1:0] s_real, s_imag;
    wire              subchirp_tick, seq_active;
    wire signed [7:0] css_i, css_q;
    wire              css_valid;

    csk_generator dut (
        .clk(clk), .reset(reset), .start(start), .m(m),
        .dqpsk_valid(dqpsk_valid), .s_real(s_real), .s_imag(s_imag),
        .subchirp_tick(subchirp_tick), .seq_active(seq_active),
        .css_i(css_i), .css_q(css_q), .css_valid(css_valid)
    );

    // ---------------- Stimulus memories (Sn from the DQPSK stage) ---------------- //
    reg signed [1:0] sreal_mem [0:8191];
    reg signed [1:0] simag_mem [0:8191];
    integer num_symbols, sidx;          // no need for i (not used)
    integer real_in_file, imag_in_file, file_i, file_q;
    integer val_r, val_i, scan_r, scan_i;
    reg     more_data;
    reg [1024*8-1:0] str_in_real, str_in_imag, str_out_i, str_out_q;

    // ---------------- Self-check bookkeeping ---------------- //
    integer sample_idx, error_count, total_expected;

    always #5 clk = ~clk;

    // -------------------- Load Sn stimulus -------------------- //
    initial begin
        $sformat(str_in_real, "../Test_Vectors/Phase_4_DQPSK_CSK/S_real_matlab_rate%0d.txt", DATA_RATE);
        $sformat(str_in_imag, "../Test_Vectors/Phase_4_DQPSK_CSK/S_imag_matlab_rate%0d.txt", DATA_RATE);

        real_in_file = $fopen(str_in_real, "r");
        imag_in_file = $fopen(str_in_imag, "r");
        if (real_in_file == 0 || imag_in_file == 0) begin
            $display("tb_csk_generator: ERROR - could not open Sn stimulus files");
            $finish;
        end

        more_data = 1'b1;
        num_symbols = 0;
        while (more_data && num_symbols < 8192) begin
            scan_r = $fscanf(real_in_file, "%d", val_r);
            scan_i = $fscanf(imag_in_file, "%d", val_i);
            if (scan_r == 1 && scan_i == 1) begin
                sreal_mem[num_symbols] = val_r[1:0]; // two's-complement
                simag_mem[num_symbols] = val_i[1:0]; // truncation is exact
                num_symbols = num_symbols + 1;       // for values in {-1,0,1}
            end else begin
                more_data = 1'b0;
            end
        end
        $fclose(real_in_file);
        $fclose(imag_in_file);

        total_expected = num_symbols * 38; // one subchirp (38 samples) per Sn symbol
        $display("tb_csk_generator: loaded %0d Sn symbols for DATA_RATE=%0d, m=%0d (%0d expected CSS samples)",
                  num_symbols, DATA_RATE, M_SEL, total_expected);
    end

    // -------------------- Drive the DUT -------------------- //
    initial begin
        clk = 0; reset = 1; start = 0; m = M_SEL;
        dqpsk_valid = 0; s_real = 2'sd1; s_imag = 2'sd1;
        sample_idx = 0; error_count = 0; sidx = 0;

        #20 reset = 0;
        #10 start = 1;
        #10 start = 0;
    end

    // Feed the next Sn symbol shortly after each subchirp_tick -- mimics an
    // upstream dqpsk_encoder responding within a cycle, well inside the
    // ~38-cycle slack before the next subchirp needs its symbol. If your
    // real integration's response latency differs, this is the place to
    // adjust it.
    always @(posedge clk) begin
        if (!reset && subchirp_tick && sidx < num_symbols) begin
            s_real      <= sreal_mem[sidx];
            s_imag      <= simag_mem[sidx];
            dqpsk_valid <= 1'b1;
            sidx        <= sidx + 1;
        end else begin
            dqpsk_valid <= 1'b0;
        end
    end

    initial begin
        $sformat(str_out_i, "../Test_Vectors/Phase_5_CSS_Output/CSS_real_verilog_m%0d_rate%0d.txt", M_SEL, DATA_RATE);
        $sformat(str_out_q, "../Test_Vectors/Phase_5_CSS_Output/CSS_imag_verilog_m%0d_rate%0d.txt", M_SEL, DATA_RATE);
        file_i = $fopen(str_out_i, "w");
        file_q = $fopen(str_out_q, "w");
    end

    always @(posedge clk) begin
        if (css_valid) begin
            $fdisplay(file_i, "%0d", css_i);
            $fdisplay(file_q, "%0d", css_q);
        end
    end


    reg signed [5:0] gwave_i [0:151];
    reg signed [5:0] gwave_q [0:151];
    initial begin
// Just paths errors
        $readmemb("../Test_Vectors/Phase_4_DQPSK_CSK/csk_rom_i.txt", gwave_i);
        $readmemb("../Test_Vectors/Phase_4_DQPSK_CSK/csk_rom_q.txt", gwave_q);
    end

    function [1:0] indep_wid;
        input [2:0] mm;
        input [1:0] kk;
        reg signed [1:0] sf, zt; // sign(f_k,m), zeta_k,m -- straight from Tables 2-3/2-4
        begin
            case (mm)
                3'd1: sf = (kk==2'd0 || kk==2'd3) ? -2'sd1 :  2'sd1;
                3'd2: sf = (kk==2'd0 || kk==2'd3) ?  2'sd1 : -2'sd1;
                3'd3: sf = (kk==2'd0 || kk==2'd3) ? -2'sd1 :  2'sd1;
                default: sf = (kk==2'd0 || kk==2'd3) ?  2'sd1 : -2'sd1; // m=4
            endcase
            case (mm)
                3'd1: zt = (kk < 2'd2) ?  2'sd1 : -2'sd1;
                3'd2: zt = (kk==2'd0 || kk==2'd2) ?  2'sd1 : -2'sd1;
                3'd3: zt = (kk < 2'd2) ? -2'sd1 :  2'sd1;
                default: zt = (kk==2'd0 || kk==2'd2) ? -2'sd1 : 2'sd1; // m=4
            endcase
            if      (sf==-2'sd1 && zt== 2'sd1) indep_wid = 2'd0;
            else if (sf== 2'sd1 && zt== 2'sd1) indep_wid = 2'd1;
            else if (sf== 2'sd1 && zt==-2'sd1) indep_wid = 2'd2;
            else                                 indep_wid = 2'd3;
        end
    endfunction

    // ---- own free-running sequencer (Table 2-2 gap timing) ----
    localparam I_IDLE=2'd0, I_ACTIVE=2'd1, I_GAP=2'd2;
    reg [1:0] i_state;
    reg [1:0] i_k;
    reg [5:0] i_n;
    reg       i_parity;
    reg [6:0] i_gap_cnt;
    reg       i_valid;

    reg [6:0] teven, todd;
    always @(*) begin
        case (m)
            3'd1: begin teven = 7'd10; todd = 7'd70; end
            3'd2: begin teven = 7'd20; todd = 7'd60; end
            3'd3: begin teven = 7'd30; todd = 7'd50; end
            default: begin teven = 7'd40; todd = 7'd40; end // m=4
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            i_state <= I_IDLE; i_k <= 0; i_n <= 0;
            i_parity <= 1'b0; i_gap_cnt <= 0; i_valid <= 1'b0;
        end else begin
            case (i_state)
                I_IDLE: begin
                    i_valid <= 1'b0;
                    if (start) begin
                        i_state <= I_ACTIVE; i_k <= 0; i_n <= 0; i_valid <= 1'b1;
                    end
                end
// -------------------------------------------------------------------------
// BUG FIX EXPLANATION:
// Previously, i_valid was assigned '1' by default at the top of I_ACTIVE.
// This caused an issue when transitioning to I_GAP: i_valid remained '1'
// for one extra clock cycle, which mismatched the DUT's exact timing.
// To fix this, the default assignment was removed. Now, i_valid is 
// explicitly set to '0' exactly when entering the GAP state, and '1' 
// when staying in the ACTIVE state. This perfectly aligns with the DUT.
// -------------------------------------------------------------------------
                I_ACTIVE: begin
                    if (i_n == 6'd37) begin
                        i_n <= 0;
                        if (i_k == 2'd3) begin
                            i_k       <= 0;
                            i_gap_cnt <= i_parity ? todd : teven;
                            i_parity  <= ~i_parity;
                            i_state   <= I_GAP;
                            i_valid   <= 1'b0;      // Drop valid immediately on GAP entry
                        end else begin
                            i_k       <= i_k + 2'd1;
                            i_valid   <= 1'b1;      // Keep valid high for next subchirp
                        end
                    end else begin
                        i_n       <= i_n + 6'd1;
                        i_valid   <= 1'b1;          // Keep valid high for next sample
                    end
                end
                I_GAP: begin
                    i_valid <= 1'b0;
                    if (i_gap_cnt <= 7'd1) begin
                        i_state <= I_ACTIVE;
                        i_valid <= 1'b1;
                    end else begin
                        i_gap_cnt <= i_gap_cnt - 7'd1;
                    end
                end
                default: i_state <= I_IDLE;
            endcase
        end
    end

    // combinational waveform lookup for the CURRENT (i_k, i_n)
    wire [1:0] i_wid  = indep_wid(m, i_k);
    wire [7:0] i_addr = i_wid * 8'd38 + {2'b00, i_n};
    wire signed [5:0] i_wave_re = gwave_i[i_addr];
    wire signed [5:0] i_wave_im = gwave_q[i_addr];

    // ---- own symbol-hold register (watches the same stimulus as the DUT) ----
    reg signed [1:0] i_sym_real, i_sym_imag;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            i_sym_real <= 2'sd1; i_sym_imag <= 2'sd1;
        end else if (dqpsk_valid) begin
            i_sym_real <= s_real; i_sym_imag <= s_imag;
        end
    end

    // ---- pipeline stage 1: mirrors csk_waveform_rom's registered read ----
    reg signed [5:0] i_wave_re_d, i_wave_im_d;
    reg              i_valid_d1;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            i_wave_re_d <= 0; i_wave_im_d <= 0; i_valid_d1 <= 1'b0;
        end else begin
            i_wave_re_d <= i_wave_re;
            i_wave_im_d <= i_wave_im;
            i_valid_d1  <= i_valid;
        end
    end

    // ---- pipeline stage 2: mirrors dqpsk_csk_multiplier's combinational
    //      multiply (using whatever symbol is held AT THIS CYCLE, same as
    //      the DUT) followed by its registered output ----
    wire signed [6:0] a = i_sym_real[1] ? -i_wave_re_d : i_wave_re_d;
    wire signed [6:0] b = i_sym_imag[1] ? -i_wave_im_d : i_wave_im_d;
    wire signed [6:0] c = i_sym_real[1] ? -i_wave_im_d : i_wave_im_d;
    wire signed [6:0] d = i_sym_imag[1] ? -i_wave_re_d : i_wave_re_d;
    wire signed [7:0] stageB_re = a - b;
    wire signed [7:0] stageB_im = c + d;

    reg              exp_valid;
    reg signed [7:0] exp_css_i, exp_css_q;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            exp_valid <= 1'b0; exp_css_i <= 0; exp_css_q <= 0;
        end else begin
            exp_valid <= i_valid_d1;
            if (i_valid_d1) begin
                exp_css_i <= stageB_re;
                exp_css_q <= stageB_im;
            end
        end
    end

    // -------------------- Comparator -------------------- //
    always @(posedge clk) begin
        if (exp_valid) begin
            sample_idx = sample_idx + 1;
            if (css_valid !== 1'b1) begin
                error_count = error_count + 1;
                $display("[%0t] sample %0d: css_valid NOT asserted when expected", $time, sample_idx);
            end else if (css_i !== exp_css_i || css_q !== exp_css_q) begin
                error_count = error_count + 1;
                $display("[%0t] sample %0d: MISMATCH  DUT=(%0d,%0d)  EXPECTED=(%0d,%0d)",
                          $time, sample_idx, css_i, css_q, exp_css_i, exp_css_q);
            end

            if (sample_idx == total_expected) begin
                if (error_count == 0)
                    $display("tb_csk_generator: PASSED - all %0d samples matched", sample_idx);
                else
                    $display("tb_csk_generator: FAILED - %0d / %0d samples mismatched", error_count, sample_idx);
                $fclose(file_i);
                $fclose(file_q);
                $finish;
            end
        end
    end

    // -------------------- Safety timeout -------------------- //
    initial begin
        #2_000_000;
        $display("tb_csk_generator: TIMEOUT - only %0d / %0d expected samples seen", sample_idx, total_expected);
        $finish;
    end

endmodule