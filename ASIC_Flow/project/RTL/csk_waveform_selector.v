module csk_waveform_selector (
    input  wire [2:0] m,           // 1 to 4
    input  wire [1:0] k,           // 0 to 3
    output reg  [1:0] waveform_id  // 0 to 3 -- see encoding below
);
    // waveform_id encoding (MUST match the order waveforms are stored
    // in the ROM -- this is a hard contract between these two modules):
    //   0: sign(f) = -, zeta = +1
    //   1: sign(f) = +, zeta = +1
    //   2: sign(f) = +, zeta = -1
    //   3: sign(f) = -, zeta = -1
    wire [1:0] m_idx = m - 3'd1;

    always @(*) begin
        case ({m_idx, k})
            4'b00_00: waveform_id = 2'd0; // m=1,k=0
            4'b00_01: waveform_id = 2'd1; // m=1,k=1
            4'b00_10: waveform_id = 2'd2; // m=1,k=2
            4'b00_11: waveform_id = 2'd3; // m=1,k=3
            4'b01_00: waveform_id = 2'd1; // m=2,k=0
            4'b01_01: waveform_id = 2'd3; // m=2,k=1
            4'b01_10: waveform_id = 2'd0; // m=2,k=2
            4'b01_11: waveform_id = 2'd2; // m=2,k=3
            4'b10_00: waveform_id = 2'd3; // m=3,k=0
            4'b10_01: waveform_id = 2'd2; // m=3,k=1
            4'b10_10: waveform_id = 2'd1; // m=3,k=2
            4'b10_11: waveform_id = 2'd0; // m=3,k=3
            4'b11_00: waveform_id = 2'd2; // m=4,k=0
            4'b11_01: waveform_id = 2'd0; // m=4,k=1
            4'b11_10: waveform_id = 2'd3; // m=4,k=2
            default:  waveform_id = 2'd1; // m=4,k=3
        endcase
    end
endmodule

