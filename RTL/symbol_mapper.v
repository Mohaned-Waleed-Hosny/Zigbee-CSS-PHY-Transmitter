`timescale 1ns / 1ps
module symbol_mapper (
    input wire clk,
    input wire reset,
    input wire data_rate,
    input wire i_bit,
    input wire q_bit,
    input wire valid_in,
    output reg [0:31] i_mapped,
    output reg [0:31] q_mapped,
    output reg valid_out
);
    reg [0:5] i_shift, q_shift;
    reg [2:0] bit_cnt;

    reg [0:3] rom_1mbs [0:7];
    reg [0:3] rom_250kbs [0:511]; // Expanded to 512 4-bit entries

    initial begin
        $readmemb("../rtl/rom/codeword_1Mbs.txt", rom_1mbs);
        $readmemb("../rtl/rom/codeword_250kbs.txt", rom_250kbs);
    end

    wire [5:0] i_addr = {i_shift[0], i_shift[1], i_shift[2], i_shift[3], i_shift[4], i_bit};
    wire [5:0] q_addr = {q_shift[0], q_shift[1], q_shift[2], q_shift[3], q_shift[4], q_bit};

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_cnt <= 0;
            valid_out <= 0;
            i_mapped <= 0;
            q_mapped <= 0;
            i_shift <= 0;
            q_shift <= 0;
        end else begin
            valid_out <= 0;
            if (valid_in) begin
                i_shift[bit_cnt] <= i_bit;
                q_shift[bit_cnt] <= q_bit;

                if (data_rate == 0) begin // 1 Mbps
                    if (bit_cnt == 2) begin
                        bit_cnt <= 0;
                        i_mapped[0:3] <= rom_1mbs[{i_shift[0], i_shift[1], i_bit}];
                        q_mapped[0:3] <= rom_1mbs[{q_shift[0], q_shift[1], q_bit}];
                        valid_out <= 1;
                    end else bit_cnt <= bit_cnt + 1;
                end else begin // 250 kbps
                    if (bit_cnt == 5) begin
                        bit_cnt <= 0;
                        i_mapped <= { rom_250kbs[{i_addr, 3'd0}], rom_250kbs[{i_addr, 3'd1}], 
                                       rom_250kbs[{i_addr, 3'd2}], rom_250kbs[{i_addr, 3'd3}], 
                                       rom_250kbs[{i_addr, 3'd4}], rom_250kbs[{i_addr, 3'd5}], 
                                       rom_250kbs[{i_addr, 3'd6}], rom_250kbs[{i_addr, 3'd7}] };
                        
                        q_mapped <= { rom_250kbs[{q_addr, 3'd0}], rom_250kbs[{q_addr, 3'd1}], 
                                       rom_250kbs[{q_addr, 3'd2}], rom_250kbs[{q_addr, 3'd3}], 
                                       rom_250kbs[{q_addr, 3'd4}], rom_250kbs[{q_addr, 3'd5}], 
                                       rom_250kbs[{q_addr, 3'd6}], rom_250kbs[{q_addr, 3'd7}] };
                        valid_out <= 1;
                    end else bit_cnt <= bit_cnt + 1;
                end
            end
        end
    end
endmodule