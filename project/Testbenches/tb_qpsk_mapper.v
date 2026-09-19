`timescale 1ns / 1ps

module tb_qpsk_mapper;
    parameter DATA_RATE = 0; // 0: 1Mbps, 1: 250kbps (selects stimulus/output files only)

    reg  clk, reset, valid_in;
    reg  i_bit, q_bit;
    wire signed [1:0] x_real, x_imag;
    wire valid_out;

    qpsk_mapper dut (
        .clk(clk), .reset(reset),
        .i_bit(i_bit), .q_bit(q_bit), .valid_in(valid_in),
        .x_real(x_real), .x_imag(x_imag), .valid_out(valid_out)
    );

    // ---------------- Stimulus memories (bit-serial, form_ppdu's domain) ---------------- //
    reg i_mem [0:8191];
    reg q_mem [0:8191];
    integer i, num_bits;
    integer file_real, file_imag;
    reg [1024*8-1:0] str_in_i, str_in_q, str_out_real, str_out_imag;

    // ---------------- Self-check bookkeeping ---------------- //
    reg signed [1:0] exp_real, exp_imag;
    reg              exp_valid;
    integer          sample_idx, error_count;

    always #5 clk = ~clk;

    // -------------------- Stimulus generation -------------------- //
    initial begin
        clk = 0; reset = 1; valid_in = 0; i_bit = 0; q_bit = 0;
        sample_idx = 0; error_count = 0;

        $sformat(str_in_i, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/I_ppdu_matlab_rate%0d.txt", DATA_RATE);
        $sformat(str_in_q, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/Q_ppdu_matlab_rate%0d.txt", DATA_RATE);
        $readmemb(str_in_i, i_mem);
        $readmemb(str_in_q, q_mem);

        #20 reset = 0;

        num_bits = 0;
        while (i_mem[num_bits] !== 1'bx && num_bits < 8192) begin
            num_bits = num_bits + 1;
        end
        $display("tb_qpsk_mapper: loaded %0d chips for DATA_RATE=%0d", num_bits, DATA_RATE);

        for (i = 0; i < num_bits; i = i + 1) begin
            i_bit    = i_mem[i];
            q_bit    = q_mem[i];
            valid_in = 1;
            #10 valid_in = 0; #50;   // same 60ns/sample cadence as tb_form_ppdu
        end

        #200;
        if (error_count == 0)
            $display("tb_qpsk_mapper: PASSED - all %0d samples matched", sample_idx);
        else
            $display("tb_qpsk_mapper: FAILED - %0d / %0d samples mismatched", error_count, sample_idx);

        $fclose(file_real);
        $fclose(file_imag);
        $finish;
    end

    // -------------------- Golden output dump (project convention) -------------------- //
    initial begin
        $sformat(str_out_real, "../Test_Vectors/Phase_3_QPSK_Controller/X_real_verilog_rate%0d.txt", DATA_RATE);
        $sformat(str_out_imag, "../Test_Vectors/Phase_3_QPSK_Controller/X_imag_verilog_rate%0d.txt", DATA_RATE);
        file_real = $fopen(str_out_real, "w");
        file_imag = $fopen(str_out_imag, "w");
    end

    always @(posedge clk) begin
        if (valid_out) begin
            $fdisplay(file_real, "%b", x_real);
            $fdisplay(file_imag, "%b", x_imag);
        end
    end

    // -------------------- Independent expected-value model -------------------- //
    // Derived directly from the reference formula, NOT copied from the DUT.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            exp_real <= 2'sd0; exp_imag <= 2'sd0; exp_valid <= 1'b0;
        end else begin
            exp_valid <= valid_in;
            if (valid_in) begin
                case ({i_bit, q_bit})
                    2'b11:   begin exp_real <=  2'sd1; exp_imag <=  2'sd0; end // I=+1,Q=+1
                    2'b10:   begin exp_real <=  2'sd0; exp_imag <= -2'sd1; end // I=+1,Q=-1
                    2'b01:   begin exp_real <=  2'sd0; exp_imag <=  2'sd1; end // I=-1,Q=+1
                    default: begin exp_real <= -2'sd1; exp_imag <=  2'sd0; end // I=-1,Q=-1
                endcase
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
            end else if (x_real !== exp_real || x_imag !== exp_imag) begin
                error_count = error_count + 1;
                $display("[%0t] sample %0d: MISMATCH  DUT=(%0d,%0d)  EXPECTED=(%0d,%0d)",
                          $time, sample_idx, x_real, x_imag, exp_real, exp_imag);
            end
        end
    end

endmodule