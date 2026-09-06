`timescale 1ns / 1ps

module demux_iq_tb;

    reg clk;
    reg reset;
    reg start_frame;
    reg bit_in;
    reg valid_in;

    wire i_bit;
    wire q_bit;
    wire valid_out;

    integer file_in, file_I, file_Q;
    integer status;
    reg bit_buf;

    reg expected_I [0:255];
    reg expected_Q [0:255];
    integer idx = 0;
    integer error_count = 0;

    demux_iq uut (
        .clk(clk),
        .reset(reset),
        .start_frame(start_frame),
        .bit_in(bit_in),
        .valid_in(valid_in),
        .i_bit(i_bit),
        .q_bit(q_bit),
        .valid_out(valid_out)
    );

    always #10 clk = ~clk;

    always @(posedge clk) begin
        #1; 
        if (valid_out) begin
          
            $fdisplay(file_I, "%b", i_bit);
            $fdisplay(file_Q, "%b", q_bit);

            if (i_bit !== expected_I[idx] || q_bit !== expected_Q[idx]) begin
                $display("[ERROR] Index %0d | I_got=%b (exp=%b) | Q_got=%b (exp=%b)",
                         idx, i_bit, expected_I[idx], q_bit, expected_Q[idx]);
                error_count = error_count + 1;
            end else begin
                $display("[PASS] Index %0d | I=%b | Q=%b", idx, i_bit, q_bit);
            end
            
            idx = idx + 1;
        end
    end

    initial begin
        clk = 0;
        reset = 1;
        start_frame = 0;
        bit_in = 0;
        valid_in = 0;

        $readmemb("../Test_Vectors/I_matlab.txt", expected_I);
        $readmemb("../Test_Vectors/Q_matlab.txt", expected_Q);

        file_in = $fopen("../Test_Vectors/data_after_padding.txt", "r");
        file_I  = $fopen("../Test_Vectors/I_verilog.txt", "w");
        file_Q  = $fopen("../Test_Vectors/Q_verilog.txt", "w");

        if (file_in == 0) begin
            $display("../Test_Vectors/data_after_padding.txt not found!");
            $finish;
        end

        #40;
        reset = 0;
        #20;

        start_frame = 1;
        #20;
        start_frame = 0;
        #20;

        while (!$feof(file_in)) begin
            status = $fscanf(file_in, "%b\n", bit_buf);
            if (status == 1) begin
                bit_in   <= bit_buf;
                valid_in <= 1'b1;
                @(posedge clk);
            end
        end

        valid_in <= 0;

        repeat (5) @(posedge clk);

        $fclose(file_in);
        $fclose(file_I);
        $fclose(file_Q);

        $display("--------------------------------------------------");
        if (error_count == 0) begin
            $display("[SUCCESS] All Demux outputs MATCH MATLAB Golden Model 100%%!");
        end else begin
            $display("[ERROR] Total mismatches found: %0d", error_count);
        end
        $display("--------------------------------------------------");

        $stop;
    end

endmodule