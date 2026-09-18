`timescale 1ns / 1ps

module csk_sequencer (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire [2:0]  m,
    input  wire [10:0] num_groups,

    output reg  [1:0]  k_index,
    output reg  [5:0]  sample_index,
    output reg         csk_sample_valid,
    output reg         subchirp_tick,
    output reg         seq_active,
    output reg         finished
);

    localparam SC_IDLE     = 2'd0;
    localparam SC_SUBCHIRP = 2'd1;
    localparam SC_GAP      = 2'd2;

    reg [1:0] state;
    reg       even_odd;
    reg [6:0] gap_counter;
    reg [6:0] gap_even, gap_odd;
    reg [10:0] group_count;

    always @(*) begin
        case (m)
            3'd1: begin gap_even = 7'd10; gap_odd = 7'd70; end
            3'd2: begin gap_even = 7'd20; gap_odd = 7'd60; end
            3'd3: begin gap_even = 7'd30; gap_odd = 7'd50; end
            default: begin gap_even = 7'd40; gap_odd = 7'd40; end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state            <= SC_IDLE;
            k_index          <= 2'd0;
            sample_index     <= 6'd0;
            csk_sample_valid <= 1'b0;
            subchirp_tick    <= 1'b0;
            seq_active       <= 1'b0;
            finished         <= 1'b0;
            even_odd         <= 1'b0;
            gap_counter      <= 7'd0;
            group_count      <= 11'd0;
        end else begin
            subchirp_tick <= 1'b0;
            finished      <= 1'b0;

            case (state)
                SC_IDLE: begin
                    csk_sample_valid <= 1'b0;
                    seq_active       <= 1'b0;

                    if (start && (num_groups != 11'd0)) begin
                        $display("[%0t] SEQUENCER START: num_groups=%0d m=%0d",
                                 $time, num_groups, m);
                        state            <= SC_SUBCHIRP;
                        k_index          <= 2'd0;
                        sample_index     <= 6'd0;
                        group_count      <= 11'd0;
                        subchirp_tick    <= 1'b1;
                        csk_sample_valid <= 1'b1;
                        seq_active       <= 1'b1;
                    end
                end

                SC_SUBCHIRP: begin
                    csk_sample_valid <= 1'b1;

                    if (sample_index == 6'd37) begin
                        sample_index <= 6'd0;

                        if (k_index == 2'd3) begin
                            $display("[%0t] GROUP END: group_count=%0d num_groups=%0d",
                                     $time, group_count, num_groups);

                            if (group_count + 11'd1 >= num_groups) begin
                                state            <= SC_IDLE;
                                k_index          <= 2'd0;
                                csk_sample_valid <= 1'b0;
                                seq_active       <= 1'b0;
                                group_count      <= group_count + 11'd1;
                                finished         <= 1'b1;
                            end else begin
                                k_index          <= 2'd0;
                                group_count      <= group_count + 11'd1;
                                csk_sample_valid <= 1'b0;
                                gap_counter      <= even_odd ? gap_odd : gap_even;
                                state            <= SC_GAP;
                            end
                        end else begin
                            k_index       <= k_index + 2'd1;
                            subchirp_tick <= 1'b1;
                        end
                    end else begin
                        sample_index <= sample_index + 6'd1;
                    end
                end

                SC_GAP: begin
                    if (gap_counter <= 7'd1) begin
                        even_odd         <= ~even_odd;
                        state            <= SC_SUBCHIRP;
                        k_index          <= 2'd0;
                        sample_index     <= 6'd0;
                        subchirp_tick    <= 1'b1;
                        csk_sample_valid <= 1'b1;
                    end else begin
                        gap_counter      <= gap_counter - 7'd1;
                        csk_sample_valid <= 1'b0;
                    end
                end

                default: begin
                    state            <= SC_IDLE;
                    csk_sample_valid <= 1'b0;
                    seq_active       <= 1'b0;
                end
            endcase
        end
    end
endmodule
