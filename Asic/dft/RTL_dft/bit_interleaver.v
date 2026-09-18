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

    // Hardwired bit-permutation mapping replacing non-synthesizable initial RAM/LUT logic
    wire [0:63] i_interleaved = {
        i_combined[0:3],   i_combined[52:55], i_combined[8:11],  i_combined[60:63],
        i_combined[16:19], i_combined[36:39], i_combined[24:27], i_combined[44:47],
        i_combined[32:35], i_combined[20:23], i_combined[40:43], i_combined[28:31],
        i_combined[48:51], i_combined[4:7],   i_combined[56:59], i_combined[12:15]
    };

    wire [0:63] q_interleaved = {
        q_combined[0:3],   q_combined[52:55], q_combined[8:11],  q_combined[60:63],
        q_combined[16:19], q_combined[36:39], q_combined[24:27], q_combined[44:47],
        q_combined[32:35], q_combined[20:23], q_combined[40:43], q_combined[28:31],
        q_combined[48:51], q_combined[4:7],   q_combined[56:59], q_combined[12:15]
    };

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wait_second <= 1'b0;
            valid_out   <= 1'b0;
            i_temp      <= 32'd0;
            q_temp      <= 32'd0;
            i_out       <= 64'd0;
            q_out       <= 64'd0;
        end else begin
            valid_out <= 1'b0;
            if (valid_in) begin
                if (data_rate == 1'b0) begin // Pass-through for 1Mbps (32 bits)
                    i_out     <= {i_mapped, 32'b0};
                    q_out     <= {q_mapped, 32'b0};
                    valid_out <= 1'b1;
                end else begin // Interleaving for 250kbps (64 bits)
                    if (!wait_second) begin
                        i_temp      <= i_mapped;
                        q_temp      <= q_mapped;
                        wait_second <= 1'b1;
                    end else begin
                        i_out       <= i_interleaved;
                        q_out       <= q_interleaved;
                        wait_second <= 1'b0;
                        valid_out   <= 1'b1;
                    end
                end
            end
        end
    end

endmodule