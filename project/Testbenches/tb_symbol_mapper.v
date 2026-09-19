`timescale 1ns / 1ps
module tb_symbol_mapper;
    parameter DATA_RATE = 1; // 0: 1Mbps, 1: 250kbps

    reg clk, reset, valid_in, i_bit, q_bit;
    wire [0:31] i_mapped, q_mapped;
    wire valid_out;
    
    symbol_mapper dut (
        .clk(clk), .reset(reset), .data_rate(DATA_RATE[0]),
        .i_bit(i_bit), .q_bit(q_bit), .valid_in(valid_in),
        .i_mapped(i_mapped), .q_mapped(q_mapped), .valid_out(valid_out)
    );
    
    reg i_mem [0:1999]; reg q_mem [0:1999];
    integer i, file_i, file_q, num_bits;
    reg [1024*8-1:0] str_in_i, str_in_q, str_out_i, str_out_q;
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0; reset = 1; valid_in = 0; i_bit = 0; q_bit = 0;
        
        $sformat(str_in_i, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/I_matlab_rate%0d.txt", DATA_RATE);
        $sformat(str_in_q, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/Q_matlab_rate%0d.txt", DATA_RATE);
        $readmemb(str_in_i, i_mem);
        $readmemb(str_in_q, q_mem);
        
        #20 reset = 0;
        
        // Dynamically find EOF
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
        #200 $finish;
    end
    
    initial begin
        $sformat(str_out_i, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/I_mapped_verilog_rate%0d.txt", DATA_RATE);
        $sformat(str_out_q, "../Test_Vectors/Phase_2_SymbolMapper_PPDU/Q_mapped_verilog_rate%0d.txt", DATA_RATE);
        file_i = $fopen(str_out_i, "w");
        file_q = $fopen(str_out_q, "w");
    end
    
    always @(posedge clk) begin
        if (valid_out) begin
            if (DATA_RATE == 0) begin
                $fdisplay(file_i, "%b", i_mapped[0:3]);
                $fdisplay(file_q, "%b", q_mapped[0:3]);
            end else begin
                $fdisplay(file_i, "%b", i_mapped);
                $fdisplay(file_q, "%b", q_mapped);
            end
        end
    end
endmodule