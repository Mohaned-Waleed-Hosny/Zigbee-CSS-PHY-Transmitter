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

    // 32 words of 64 bits = 2048 bits total capacity
    reg [0:63] i_fifo [0:31];
    reg [0:63] q_fifo [0:31];
    reg [11:0] wr_ptr, rd_ptr, total_out_cnt;
    reg packet_active;

    localparam [0:15] SFD_1M   = 16'b0111_0100_1001_1100;
    localparam [0:15] SFD_250K = 16'b0111_1010_0010_0011;

    // Explicit block write logic (Zero barrel-shifter complexity)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr <= 12'd0;
        end else if (start_frame) begin
            wr_ptr <= 12'd0;
        end else if (valid_in) begin
            if (data_rate == 1'b0) begin
                // 1M mode: Write 4 bits into 64-bit word at block index wr_ptr[10:6]
                case (wr_ptr[5:2])
                    4'd0:  begin i_fifo[wr_ptr[10:6]][0:3]   <= i_in[0:3]; q_fifo[wr_ptr[10:6]][0:3]   <= q_in[0:3]; end
                    4'd1:  begin i_fifo[wr_ptr[10:6]][4:7]   <= i_in[0:3]; q_fifo[wr_ptr[10:6]][4:7]   <= q_in[0:3]; end
                    4'd2:  begin i_fifo[wr_ptr[10:6]][8:11]  <= i_in[0:3]; q_fifo[wr_ptr[10:6]][8:11]  <= q_in[0:3]; end
                    4'd3:  begin i_fifo[wr_ptr[10:6]][12:15] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][12:15] <= q_in[0:3]; end
                    4'd4:  begin i_fifo[wr_ptr[10:6]][16:19] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][16:19] <= q_in[0:3]; end
                    4'd5:  begin i_fifo[wr_ptr[10:6]][20:23] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][20:23] <= q_in[0:3]; end
                    4'd6:  begin i_fifo[wr_ptr[10:6]][24:27] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][24:27] <= q_in[0:3]; end
                    4'd7:  begin i_fifo[wr_ptr[10:6]][28:31] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][28:31] <= q_in[0:3]; end
                    4'd8:  begin i_fifo[wr_ptr[10:6]][32:35] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][32:35] <= q_in[0:3]; end
                    4'd9:  begin i_fifo[wr_ptr[10:6]][36:39] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][36:39] <= q_in[0:3]; end
                    4'd10: begin i_fifo[wr_ptr[10:6]][40:43] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][40:43] <= q_in[0:3]; end
                    4'd11: begin i_fifo[wr_ptr[10:6]][44:47] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][44:47] <= q_in[0:3]; end
                    4'd12: begin i_fifo[wr_ptr[10:6]][48:51] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][48:51] <= q_in[0:3]; end
                    4'd13: begin i_fifo[wr_ptr[10:6]][52:55] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][52:55] <= q_in[0:3]; end
                    4'd14: begin i_fifo[wr_ptr[10:6]][56:59] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][56:59] <= q_in[0:3]; end
                    4'd15: begin i_fifo[wr_ptr[10:6]][60:63] <= i_in[0:3]; q_fifo[wr_ptr[10:6]][60:63] <= q_in[0:3]; end
                endcase
                wr_ptr <= wr_ptr + 12'd4;
            end else begin
                // 250K mode: Direct 64-bit word write
                i_fifo[wr_ptr[10:6]] <= i_in;
                q_fifo[wr_ptr[10:6]] <= q_in;
                wr_ptr <= wr_ptr + 12'd64;
            end
        end
    end

    // Output serialized Preamble -> SFD -> Payload frame
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            total_out_cnt <= 12'd0;
            rd_ptr        <= 12'd0;
            valid_out     <= 1'b0;
            packet_active <= 1'b0;
            i_out         <= 1'b0;
            q_out         <= 1'b0;
        end else if (start_frame) begin
            total_out_cnt <= 12'd0;
            rd_ptr        <= 12'd0;
            valid_out     <= 1'b0;
            packet_active <= 1'b1;
        end else if (packet_active) begin
            if (data_rate == 1'b0) begin
                if (total_out_cnt < 12'd32) begin // 32 Preamble Chips
                    valid_out     <= 1'b1;
                    i_out         <= 1'b1;
                    q_out         <= 1'b1;
                    total_out_cnt <= total_out_cnt + 12'd1;
                end else if (total_out_cnt < 12'd48) begin // 16 SFD Chips
                    valid_out     <= 1'b1;
                    i_out         <= SFD_1M[total_out_cnt - 12'd32];
                    q_out         <= SFD_1M[total_out_cnt - 12'd32];
                    total_out_cnt <= total_out_cnt + 12'd1;
                end else begin // Payload
                    if (rd_ptr < wr_ptr) begin
                        valid_out     <= 1'b1;
                        i_out         <= i_fifo[rd_ptr[10:6]][rd_ptr[5:0]];
                        q_out         <= q_fifo[rd_ptr[10:6]][rd_ptr[5:0]];
                        rd_ptr        <= rd_ptr + 12'd1;
                        total_out_cnt <= total_out_cnt + 12'd1;
                    end else begin
                        valid_out <= 1'b0;
                    end
                end
            end else begin // 250 kbps
                if (total_out_cnt < 12'd80) begin
                    valid_out     <= 1'b1;
                    i_out         <= 1'b1;
                    q_out         <= 1'b1;
                    total_out_cnt <= total_out_cnt + 12'd1;
                end else if (total_out_cnt < 12'd96) begin
                    valid_out     <= 1'b1;
                    i_out         <= SFD_250K[total_out_cnt - 12'd80];
                    q_out         <= SFD_250K[total_out_cnt - 12'd80];
                    total_out_cnt <= total_out_cnt + 12'd1;
                end else begin
                    if (rd_ptr < wr_ptr) begin
                        valid_out     <= 1'b1;
                        i_out         <= i_fifo[rd_ptr[10:6]][rd_ptr[5:0]];
                        q_out         <= q_fifo[rd_ptr[10:6]][rd_ptr[5:0]];
                        rd_ptr        <= rd_ptr + 12'd1;
                        total_out_cnt <= total_out_cnt + 12'd1;
                    end else begin
                        valid_out <= 1'b0;
                    end
                end
            end
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule