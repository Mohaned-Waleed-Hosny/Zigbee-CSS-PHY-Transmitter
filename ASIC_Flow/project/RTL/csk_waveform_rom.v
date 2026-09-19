`timescale 1ns / 1ps

module csk_waveform_rom (
    input  wire        clk,
    input  wire [1:0]  waveform_id,   // 0-3, selects one of 4 unique combinations
    input  wire [5:0]  sample_index,  // 0-37, position within subchirp
    output reg  signed [5:0] i_c,     // 6-bit signed TxDAC output
    output reg  signed [5:0] q_c
);

    wire [7:0] addr = (waveform_id * 8'd38) + {2'b00, sample_index};

    reg signed [5:0] rom_i_comb;
    reg signed [5:0] rom_q_comb;

    // Synthesizable lookup table replacing non-synthesizable file-read memory array
    always @(*) begin
        case (addr)
            8'd0, 8'd1, 8'd2, 8'd3: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000000; end
            8'd4: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd5: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000000; end
            8'd6: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b111111; end
            8'd7: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd8: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000000; end
            8'd9: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000001; end
            8'd10: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd11: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000000; end
            8'd12: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b111111; end
            8'd13: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd14, 8'd15: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000000; end
            8'd16, 8'd17: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd18: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000001; end
            8'd19: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000000; end
            8'd20: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b111111; end
            8'd21, 8'd22: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd23, 8'd24: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b111111; end
            8'd25, 8'd26, 8'd27: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000000; end
            8'd28, 8'd29, 8'd30: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000001; end
            8'd31, 8'd32, 8'd33: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd34, 8'd35, 8'd36, 8'd37, 8'd38, 8'd39, 8'd40, 8'd41, 8'd42: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000000; end
            8'd43, 8'd44, 8'd45: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd46, 8'd47, 8'd48: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000001; end
            8'd49, 8'd50, 8'd51: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000000; end
            8'd52, 8'd53: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b111111; end
            8'd54, 8'd55: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd56: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b111111; end
            8'd57: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000000; end
            8'd58: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000001; end
            8'd59, 8'd60: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd61, 8'd62: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000000; end
            8'd63: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd64: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b111111; end
            8'd65: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000000; end
            8'd66: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd67: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000001; end
            8'd68: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000000; end
            8'd69: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd70: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b111111; end
            8'd71: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000000; end
            8'd72: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd73, 8'd74, 8'd75, 8'd76, 8'd77, 8'd78, 8'd79: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000000; end
            8'd80: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd81: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000000; end
            8'd82: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000001; end
            8'd83: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd84: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000000; end
            8'd85: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b111111; end
            8'd86: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd87: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000000; end
            8'd88: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000001; end
            8'd89: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd90, 8'd91: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000000; end
            8'd92, 8'd93: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd94: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b111111; end
            8'd95: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000000; end
            8'd96: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000001; end
            8'd97, 8'd98: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd99, 8'd100: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000001; end
            8'd101, 8'd102, 8'd103: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000000; end
            8'd104, 8'd105, 8'd106: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b111111; end
            8'd107, 8'd108, 8'd109: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd110, 8'd111, 8'd112, 8'd113, 8'd114, 8'd115, 8'd116, 8'd117, 8'd118: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000000; end
            8'd119, 8'd120, 8'd121: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd122, 8'd123, 8'd124: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b111111; end
            8'd125, 8'd126, 8'd127: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000000; end
            8'd128, 8'd129: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000001; end
            8'd130, 8'd131: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd132: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000001; end
            8'd133: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000000; end
            8'd134: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b111111; end
            8'd135, 8'd136: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd137, 8'd138: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000000; end
            8'd139: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd140: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000001; end
            8'd141: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000000; end
            8'd142: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd143: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b111111; end
            8'd144: begin rom_i_comb = 6'b111111; rom_q_comb = 6'b000000; end
            8'd145: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000001; end
            8'd146: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000001; end
            8'd147: begin rom_i_comb = 6'b000001; rom_q_comb = 6'b000000; end
            8'd148: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b111111; end
            8'd149, 8'd150, 8'd151: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000000; end
            default: begin rom_i_comb = 6'b000000; rom_q_comb = 6'b000000; end
        endcase
    end

    // Sequential register output matching initial clock cycle timing behavior
    always @(posedge clk) begin
        i_c <= rom_i_comb;
        q_c <= rom_q_comb;
    end

endmodule