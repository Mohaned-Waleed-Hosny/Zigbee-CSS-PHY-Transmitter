`timescale 1ns / 1ps
module tb_form_ppdu;
    parameter DATA_RATE = 1; // 0: 1Mbps, 1: 250kbps

    reg clk, reset, start_frame, valid_in;
    reg [0:63] i_in, q_in;
    wire i_out, q_out, valid_out;
    
    form_ppdu dut (
        .clk(clk), .reset(reset), .start_frame(start_frame), .data_rate(DATA_RATE[0]),
        .i_in(i_in), .q_in(q_in), .valid_in(valid_in),
        .i_out(i_out), .q_out(q_out), .valid_out(valid_out)
    );
    
    reg [0:63] i_mem [0:499]; reg [0:63] q_mem [0:499];
    integer i, file_i, file_q, num_words;
    reg [1024*8-1:0] str_in_i, str_in_q, str_out_i, str_out_q;
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0; reset = 1; start_frame = 0; valid_in = 0; i_in = 0; q_in = 0;
        
        $sformat(str_in_i, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/I_interleaved_matlab_rate%0d.txt", DATA_RATE);
        $sformat(str_in_q, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/Q_interleaved_matlab_rate%0d.txt", DATA_RATE);
        $readmemb(str_in_i, i_mem);
        $readmemb(str_in_q, q_mem);
        
        #20 reset = 0;
        #10 start_frame = 1; #10 start_frame = 0;
        
        num_words = 0;
        while (i_mem[num_words] !== 64'bx && num_words < 500) begin
            num_words = num_words + 1;
        end
        
        for (i = 0; i < num_words; i = i + 1) begin
            valid_in = 1;
            
            if (DATA_RATE == 0) begin
                // Shift the 4 valid bits from LSBs [60:63] to MSBs [0:3]
                i_in = i_mem[i] << 60;
                q_in = q_mem[i] << 60;
            end else begin
                // For data rate 1, all 64 bits are used
                i_in = i_mem[i];
                q_in = q_mem[i];
            end
            
            #10 valid_in = 0; #50;
        end
        #6000 $finish;
    end
    
    initial begin
        $sformat(str_out_i, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/I_ppdu_verilog_rate%0d.txt", DATA_RATE);
        $sformat(str_out_q, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/Q_ppdu_verilog_rate%0d.txt", DATA_RATE);
        file_i = $fopen(str_out_i, "w");
        file_q = $fopen(str_out_q, "w");
    end
    
    always @(posedge clk) begin
        if (valid_out) begin
            $fdisplay(file_i, "%b", i_out);
            $fdisplay(file_q, "%b", q_out);
        end
    end
endmodule