`timescale 1ns / 1ps
module part2_top (
    input wire clk,
    input wire reset,
    input wire start_frame,
    input wire data_rate,
    input wire i_bit_in,
    input wire q_bit_in,
    input wire valid_in,
    output wire i_ppdu_out,
    output wire q_ppdu_out,
    output wire valid_out
);
    wire [0:31] i_mapped, q_mapped;
    wire map_valid_out;
    
    symbol_mapper u_mapper (.clk(clk), .reset(reset), .data_rate(data_rate),
                            .i_bit(i_bit_in), .q_bit(q_bit_in), .valid_in(valid_in),
                            .i_mapped(i_mapped), .q_mapped(q_mapped), .valid_out(map_valid_out));
    
    wire [0:63] i_interleaved, q_interleaved;
    wire interleave_valid_out;
    
    bit_interleaver u_interleaver (.clk(clk), .reset(reset), .data_rate(data_rate),
                                   .i_mapped(i_mapped), .q_mapped(q_mapped), .valid_in(map_valid_out),
                                   .i_out(i_interleaved), .q_out(q_interleaved), .valid_out(interleave_valid_out));
    
    form_ppdu u_framer (.clk(clk), .reset(reset), .start_frame(start_frame), .data_rate(data_rate),
                        .i_in(i_interleaved), .q_in(q_interleaved), .valid_in(interleave_valid_out),
                        .i_out(i_ppdu_out), .q_out(q_ppdu_out), .valid_out(valid_out));
endmodule