`timescale 1ns / 1ps
module tb_bit_interleaver;
    parameter DATA_RATE = 1; // 0: 1Mbps, 1: 250kbps

    reg clk, reset, valid_in;
    reg [0:31] i_mapped, q_mapped;
    wire [0:63] i_out, q_out;
    wire valid_out;
    
    bit_interleaver dut (
        .clk(clk), .reset(reset), .data_rate(DATA_RATE[0]),
        .i_mapped(i_mapped), .q_mapped(q_mapped), .valid_in(valid_in),
        .i_out(i_out), .q_out(q_out), .valid_out(valid_out)
    );
    
    reg [0:31] i_mem [0:499]; reg [0:31] q_mem [0:499];
    integer i, file_i, file_q, num_words;
    reg [1024*8-1:0] str_in_i, str_in_q, str_out_i, str_out_q;
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0; reset = 1; valid_in = 0; i_mapped = 0; q_mapped = 0;
        
        $sformat(str_in_i, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/I_mapped_matlab_rate%0d.txt", DATA_RATE);
        $sformat(str_in_q, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/Q_mapped_matlab_rate%0d.txt", DATA_RATE);
        $readmemb(str_in_i, i_mem);
        $readmemb(str_in_q, q_mem);
        
        #20 reset = 0;
        
        num_words = 0;
        while (i_mem[num_words] !== 32'bx && num_words < 500) begin
            num_words = num_words + 1;
        end
        
        for (i = 0; i < num_words; i = i + 1) begin
            valid_in = 1;
            i_mapped = i_mem[i];
            q_mapped = q_mem[i];
            #10 valid_in = 0; #30;
        end
        #200 $finish;
    end
    
    initial begin
        $sformat(str_out_i, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/I_interleaved_verilog_rate%0d.txt", DATA_RATE);
        $sformat(str_out_q, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/Q_interleaved_verilog_rate%0d.txt", DATA_RATE);
        file_i = $fopen(str_out_i, "w");
        file_q = $fopen(str_out_q, "w");
    end
    
    always @(posedge clk) begin
        if (valid_out) begin
            if (DATA_RATE == 0) begin
                $fdisplay(file_i, "%b", i_out[28:31]);
                $fdisplay(file_q, "%b", q_out[28:31]);
            end else begin
                $fdisplay(file_i, "%b", i_out);
                $fdisplay(file_q, "%b", q_out);
            end
        end
    end
endmodule