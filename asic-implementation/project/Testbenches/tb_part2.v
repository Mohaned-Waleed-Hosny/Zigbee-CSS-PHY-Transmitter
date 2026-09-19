`timescale 1ns / 1ps
module tb_part2;
    parameter DATA_RATE = 1; // 0: 1Mbps, 1: 250kbps

    reg clk, reset, start_frame, valid_in, i_bit, q_bit;
    wire i_ppdu_out, q_ppdu_out, valid_out;
    
    part2_top dut (
        .clk(clk), .reset(reset), .start_frame(start_frame),
        .data_rate(DATA_RATE[0]), .i_bit_in(i_bit), .q_bit_in(q_bit),
        .valid_in(valid_in), .i_ppdu_out(i_ppdu_out), .q_ppdu_out(q_ppdu_out), .valid_out(valid_out)
    );
    
    reg i_mem [0:1999]; reg q_mem [0:1999];
    integer i, file_i, file_q, num_bits;
    reg [1024*8-1:0] str_in_i, str_in_q, str_out_i, str_out_q;
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0; reset = 1; start_frame = 0; valid_in = 0; i_bit = 0; q_bit = 0;
        
        $sformat(str_in_i, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/I_matlab_rate%0d.txt", DATA_RATE);
        $sformat(str_in_q, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/Q_matlab_rate%0d.txt", DATA_RATE);
        $readmemb(str_in_i, i_mem);
        $readmemb(str_in_q, q_mem);
        
        #20 reset = 0;
        #10 start_frame = 1; #10 start_frame = 0;
        
        num_bits = 0;
        while (i_mem[num_bits] !== 1'bx && num_bits < 2000) begin
            num_bits = num_bits + 1;
        end
        
        for (i = 0; i < num_bits; i = i + 1) begin
            valid_in = 1;
            i_bit = i_mem[i];
            q_bit = q_mem[i];
            #10 valid_in = 0; #10;
        end
        
        #4000 $finish;
    end
    
    initial begin
        $sformat(str_out_i, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/I_ppdu_top_verilog_rate%0d.txt", DATA_RATE);
        $sformat(str_out_q, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/Q_ppdu_top_verilog_rate%0d.txt", DATA_RATE);
        file_i = $fopen(str_out_i, "w");
        file_q = $fopen(str_out_q, "w");
    end
    
    always @(posedge clk) begin
        if (valid_out) begin
            $fdisplay(file_i, "%b", i_ppdu_out);
            $fdisplay(file_q, "%b", q_ppdu_out);
        end
    end
endmodule