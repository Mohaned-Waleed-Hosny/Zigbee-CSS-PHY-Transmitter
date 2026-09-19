`timescale 1ns / 1ps
module form_ppdu (
    input wire clk,
    input wire reset,
    input wire start_frame,
    input wire data_rate,
    input wire [0:63] i_in,
    input wire [0:63] q_in,
    input wire valid_in,
    output reg i_out,
    output reg q_out,
    output reg valid_out
);
    reg i_fifo [0:2047];
    reg q_fifo [0:2047];
    reg [11:0] wr_ptr, rd_ptr, total_out_cnt;
    reg packet_active;

    reg sfd_1m [0:15];
    reg sfd_250k [0:15];
    integer j;

    initial begin
        // SFD Bits based on MATLAB globalSettings mapping (-1 mapped to 0)
        sfd_1m[0]=0; sfd_1m[1]=1; sfd_1m[2]=1; sfd_1m[3]=1; sfd_1m[4]=0; sfd_1m[5]=1; sfd_1m[6]=0; sfd_1m[7]=0;
        sfd_1m[8]=1; sfd_1m[9]=0; sfd_1m[10]=0; sfd_1m[11]=1; sfd_1m[12]=1; sfd_1m[13]=1; sfd_1m[14]=0; sfd_1m[15]=0;
        
        sfd_250k[0]=0; sfd_250k[1]=1; sfd_250k[2]=1; sfd_250k[3]=1; sfd_250k[4]=1; sfd_250k[5]=0; sfd_250k[6]=1; sfd_250k[7]=0;
        sfd_250k[8]=0; sfd_250k[9]=0; sfd_250k[10]=1; sfd_250k[11]=0; sfd_250k[12]=0; sfd_250k[13]=0; sfd_250k[14]=1; sfd_250k[15]=1;
    end

    // Writing to the FIFO
    always @(posedge clk) begin
        if (start_frame) begin
            wr_ptr <= 0;
        end else if (valid_in) begin
            if (data_rate == 0) begin
                for (j = 0; j < 4; j = j + 1) begin
                    i_fifo[wr_ptr + j] <= i_in[j];
                    q_fifo[wr_ptr + j] <= q_in[j];
                end
                wr_ptr <= wr_ptr + 4;
            end else begin
                for (j = 0; j < 64; j = j + 1) begin
                    i_fifo[wr_ptr + j] <= i_in[j];
                    q_fifo[wr_ptr + j] <= q_in[j];
                end
                wr_ptr <= wr_ptr + 64;
            end
        end
    end

    // Output serialized Preamble -> SFD -> Payload frame
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            total_out_cnt <= 0; rd_ptr <= 0; valid_out <= 0;
            packet_active <= 0; i_out <= 0; q_out <= 0;
        end else if (start_frame) begin
            total_out_cnt <= 0; rd_ptr <= 0; valid_out <= 0;
            packet_active <= 1;
        end else if (packet_active) begin
            if (data_rate == 0) begin
                if (total_out_cnt < 32) begin // 32 Preamble Chips
                    valid_out <= 1; i_out <= 1; q_out <= 1;
                    total_out_cnt <= total_out_cnt + 1;
                end else if (total_out_cnt < 48) begin // 16 SFD Chips
                    valid_out <= 1; 
                    i_out <= sfd_1m[total_out_cnt - 32];
                    q_out <= sfd_1m[total_out_cnt - 32];
                    total_out_cnt <= total_out_cnt + 1;
                end else begin // Payload
                    if (rd_ptr < wr_ptr) begin
                        valid_out <= 1;
                        i_out <= i_fifo[rd_ptr]; q_out <= q_fifo[rd_ptr];
                        rd_ptr <= rd_ptr + 1;
                        total_out_cnt <= total_out_cnt + 1;
                    end else valid_out <= 0;
                end
            end else begin // 250 kbps
                if (total_out_cnt < 80) begin
                    valid_out <= 1; i_out <= 1; q_out <= 1;
                    total_out_cnt <= total_out_cnt + 1;
                end else if (total_out_cnt < 96) begin
                    valid_out <= 1; 
                    i_out <= sfd_250k[total_out_cnt - 80];
                    q_out <= sfd_250k[total_out_cnt - 80];
                    total_out_cnt <= total_out_cnt + 1;
                end else begin
                    if (rd_ptr < wr_ptr) begin
                        valid_out <= 1;
                        i_out <= i_fifo[rd_ptr]; q_out <= q_fifo[rd_ptr];
                        rd_ptr <= rd_ptr + 1;
                        total_out_cnt <= total_out_cnt + 1;
                    end else valid_out <= 0;
                end
            end
        end else valid_out <= 0;
    end
endmodule