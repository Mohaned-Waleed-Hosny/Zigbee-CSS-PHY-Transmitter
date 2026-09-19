module csk_waveform_rom (
    input  wire        clk,
    input  wire [1:0]  waveform_id,   // 0-3, selects one of the 4 unique
                                       // (sign f, zeta) combinations
    input  wire [5:0]  sample_index,  // 0-37, position within the subchirp

    output reg  signed [5:0] i_c,     // TxDACbitNumber=6 -> 6-bit signed
    output reg  signed [5:0] q_c
);

    reg signed [5:0] rom_i [0:151];   // 4 waveforms x 38 samples
    reg signed [5:0] rom_q [0:151];

    initial begin
        $readmemb("csk_rom_i.txt", rom_i);
        $readmemb("csk_rom_q.txt", rom_q);
    end

    
    wire [7:0] addr = waveform_id * 8'd38 + {2'b00, sample_index};

    always @(posedge clk) begin
        i_c <= rom_i[addr];
        q_c <= rom_q[addr];
    end

endmodule