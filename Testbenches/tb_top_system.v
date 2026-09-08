`timescale 1ns / 1ps

module tb_top_system;

    reg clk;
    reg reset;
    reg data_rate;
    reg [7:0] payload_len;
    reg bit_in;
    reg valid_in;
    reg start_frame;

    wire zp_bit_out;
    wire zp_valid_out;
    wire zp_done_padding;

    wire i_bit;
    wire q_bit;
    wire demux_valid_out;

    integer file_i, file_q;
    integer i, idx_iq;
    integer error_count;
    
    reg raw_bits [0:255];
    reg expected_I [0:255];
    reg expected_Q [0:255];

    zero_padding u_zero_padding (
        .clk(clk),
        .reset(reset),
        .data_rate(data_rate),
        .payload_len(payload_len),
        .bit_in(bit_in),
        .valid_in(valid_in),
        .start_frame(start_frame),
        .bit_out(zp_bit_out),
        .valid_out(zp_valid_out),
        .done_padding(zp_done_padding)
    );

    demux_iq u_demux_iq (
        .clk(clk),
        .reset(reset),
        .start_frame(start_frame),
        .bit_in(zp_bit_out),
        .valid_in(zp_valid_out),
        .i_bit(i_bit),
        .q_bit(q_bit),
        .valid_out(demux_valid_out)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        data_rate = 1'b0;      
        payload_len = 8'd2;    
        bit_in = 0;
        valid_in = 0;
        start_frame = 0;
        idx_iq = 0;
        error_count = 0;

        $readmemb("../Test_Vectors/Phase_1_Start_Demux/data_before_padding.txt", raw_bits);
        $readmemb("../Test_Vectors/Phase_1_Start_Demux/I_matlab.txt", expected_I);
        $readmemb("../Test_Vectors/Phase_1_Start_Demux/Q_matlab.txt", expected_Q);

        file_i = $fopen("../Test_Vectors/Phase_1_Start_Demux/I_verilog_top.txt", "w");
        file_q = $fopen("../Test_Vectors/Phase_1_Start_Demux/Q_verilog_top.txt", "w");

        #40;
        reset = 0;
        #20;

        start_frame = 1;
        #20;
        start_frame = 0;

        for (i = 0; i < 28; i = i + 1) begin
            @(posedge clk);
            bit_in <= raw_bits[i];
            valid_in <= 1'b1;
        end

        @(posedge clk);
        valid_in <= 1'b0;
        bit_in <= 1'b0;

        wait (zp_done_padding);
        #100;

        $fclose(file_i);
        $fclose(file_q);

        $display("--------------------------------------------------");
        if (error_count == 0) begin
            $display("[SUCCESS] All Verilog outputs MATCH MATLAB Golden Model 100%%!");
        end else begin
            $display("[ERROR] Mismatches found: %0d", error_count);
        end
        $display("--------------------------------------------------");

        $stop;
    end

    always @(posedge clk) begin
        if (demux_valid_out) begin
            $fwrite(file_i, "%b\n", i_bit);
            $fwrite(file_q, "%b\n", q_bit);

            if (i_bit !== expected_I[idx_iq] || q_bit !== expected_Q[idx_iq]) begin
                $display("[FAIL] Index %0d | I_got=%b (exp=%b) | Q_got=%b (exp=%b)",
                         idx_iq, i_bit, expected_I[idx_iq], q_bit, expected_Q[idx_iq]);
                error_count = error_count + 1;
            end else begin
                $display("[PASS] Index %0d | I=%b | Q=%b", idx_iq, i_bit, q_bit);
            end

            idx_iq = idx_iq + 1;
        end
    end

endmodule