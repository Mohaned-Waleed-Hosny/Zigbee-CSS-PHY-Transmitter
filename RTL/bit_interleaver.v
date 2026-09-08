`timescale 1ns / 1ps
module bit_interleaver (
    input wire clk,
    input wire reset,
    input wire data_rate,
    input wire [0:31] i_mapped,
    input wire [0:31] q_mapped,
    input wire valid_in,
    output reg [0:63] i_out,
    output reg [0:63] q_out,
    output reg valid_out
);
    reg [0:31] i_temp, q_temp;
    reg wait_second;

    wire [0:63] i_combined = {i_temp, i_mapped}; 
    wire [0:63] q_combined = {q_temp, q_mapped};

    integer k;
    reg [5:0] perm [0:63];

    initial begin
        // مصفوفة التوزيع المأخوذة مباشرة من bitInterleaver.m
        perm[0]=0; perm[1]=1; perm[2]=2; perm[3]=3; perm[4]=52; perm[5]=53; perm[6]=54; perm[7]=55;
        perm[8]=8; perm[9]=9; perm[10]=10; perm[11]=11; perm[12]=60; perm[13]=61; perm[14]=62; perm[15]=63;
        perm[16]=16; perm[17]=17; perm[18]=18; perm[19]=19; perm[20]=36; perm[21]=37; perm[22]=38; perm[23]=39;
        perm[24]=24; perm[25]=25; perm[26]=26; perm[27]=27; perm[28]=44; perm[29]=45; perm[30]=46; perm[31]=47;
        perm[32]=32; perm[33]=33; perm[34]=34; perm[35]=35; perm[36]=20; perm[37]=21; perm[38]=22; perm[39]=23;
        perm[40]=40; perm[41]=41; perm[42]=42; perm[43]=43; perm[44]=28; perm[45]=29; perm[46]=30; perm[47]=31;
        perm[48]=48; perm[49]=49; perm[50]=50; perm[51]=51; perm[52]=4; perm[53]=5; perm[54]=6; perm[55]=7;
        perm[56]=56; perm[57]=57; perm[58]=58; perm[59]=59; perm[60]=12; perm[61]=13; perm[62]=14; perm[63]=15;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wait_second <= 0;
            valid_out <= 0;
        end else begin
            valid_out <= 0;
            if (valid_in) begin
                if (data_rate == 0) begin // Pass-through for 1Mbps (32 bits)
                    i_out[0:31] <= i_mapped;
                    q_out[0:31] <= q_mapped;
                    i_out[32:63] <= 32'b0;
                    q_out[32:63] <= 32'b0;
                    valid_out <= 1;
                end else begin // Interleaving for 250kbps (64 bits)
                    if (!wait_second) begin
                        i_temp <= i_mapped;
                        q_temp <= q_mapped;
                        wait_second <= 1;
                    end else begin
                        for (k = 0; k < 64; k = k + 1) begin
                            i_out[k] <= i_combined[perm[k]];
                            q_out[k] <= q_combined[perm[k]];
                        end
                        wait_second <= 0;
                        valid_out <= 1;
                    end
                end
            end
        end
    end
endmodule