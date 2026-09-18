`timescale 1ns / 1ps

module zero_padding (
    input wire clk,
    input wire reset,
    input wire data_rate,       // 0 for 1 Mbps (N=6), 1 for 250 kbps (N=24)
    input wire [7:0] payload_len,
    input wire bit_in,
    input wire valid_in,
    input wire start_frame,

    output reg bit_out,
    output reg valid_out,
    output reg done_padding
);

    localparam IDLE    = 2'b00;
    localparam DATA    = 2'b01;
    localparam PADDING = 2'b10;

    reg [1:0]  state;
    reg [15:0] data_bit_count;
    reg [15:0] total_data_bits;
    reg [5:0]  block_size;
    reg [5:0]  padding_count;
    reg [5:0]  padding_total;

    // The MATLAB reference uses:
    //   pad = N - mod(total_bits,N)
    // Therefore an already-aligned frame gets one complete extra block.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state           <= IDLE;
            data_bit_count  <= 16'd0;
            total_data_bits <= 16'd0;
            block_size      <= 6'd0;
            padding_count   <= 6'd0;
            padding_total   <= 6'd0;
            bit_out         <= 1'b0;
            valid_out       <= 1'b0;
            done_padding    <= 1'b0;
        end else begin
            // Default pulse/control values for each clock.
            valid_out    <= 1'b0;
            done_padding <= 1'b0;

            case (state)
                IDLE: begin
                    if (start_frame) begin
                        state           <= DATA;
                        data_bit_count  <= 16'd0;
                        total_data_bits <= 16'd12 + ({8'd0, payload_len} * 16'd8);
                        block_size      <= (data_rate == 1'b0) ? 6'd6 : 6'd24;
                        padding_count   <= 6'd0;

                        // Calculate the exact padding required by the MATLAB model.
                        // If remainder == 0, padding_total = block_size.
                        if (data_rate == 1'b0) begin
                            case ((16'd12 + ({8'd0, payload_len} * 16'd8)) % 16'd6)
                                16'd0: padding_total <= 6'd6;
                                default: padding_total <= 6'd6 -
                                    ((16'd12 + ({8'd0, payload_len} * 16'd8)) % 16'd6);
                            endcase
                        end else begin
                            case ((16'd12 + ({8'd0, payload_len} * 16'd8)) % 16'd24)
                                16'd0: padding_total <= 6'd24;
                                default: padding_total <= 6'd24 -
                                    ((16'd12 + ({8'd0, payload_len} * 16'd8)) % 16'd24);
                            endcase
                        end
                    end
                end

                DATA: begin
                    if (valid_in) begin
                        bit_out        <= bit_in;
                        valid_out      <= 1'b1;
                        data_bit_count <= data_bit_count + 16'd1;

                        if (data_bit_count + 16'd1 == total_data_bits) begin
                            // Always enter PADDING, including the aligned case.
                            state         <= PADDING;
                            padding_count <= 6'd0;
                        end
                    end
                end

                PADDING: begin
                    bit_out   <= 1'b0;
                    valid_out <= 1'b1;

                    // Emit exactly padding_total zero bits.
                    if (padding_count + 6'd1 >= padding_total) begin
                        padding_count <= 6'd0;
                        state         <= IDLE;
                        done_padding  <= 1'b1;
                    end else begin
                        padding_count <= padding_count + 6'd1;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
