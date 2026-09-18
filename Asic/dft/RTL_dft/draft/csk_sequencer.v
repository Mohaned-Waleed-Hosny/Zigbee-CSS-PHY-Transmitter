module csk_sequencer (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire [2:0]  m,             // 1 to 4

    output reg  [1:0]  k_index,       // 0 to 3 -- current subchirp position
    output reg  [5:0]  sample_index,  // 0 to 37 -- position within subchirp
    output reg          csk_sample_valid, // low during the time gap
    output reg          subchirp_tick,    // one pulse per new subchirp
    output reg          seq_active
);

    localparam SC_IDLE = 2'd0, SC_SUBCHIRP = 2'd1, SC_GAP = 2'd2;
    reg [1:0] state;
    reg       even_odd;    // 0 = even chirp sequence, 1 = odd
    reg [6:0] gap_counter;
    reg [6:0] gap_even, gap_odd;

    // Table 2-2: time gap durations per m, in samples
    always @(*) begin
        case (m)
            3'd1: begin gap_even = 7'd10; gap_odd = 7'd70; end
            3'd2: begin gap_even = 7'd20; gap_odd = 7'd60; end
            3'd3: begin gap_even = 7'd30; gap_odd = 7'd50; end
            default: begin gap_even = 7'd40; gap_odd = 7'd40; end // m=4
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= SC_IDLE; k_index <= 2'd0; sample_index <= 6'd0;
            csk_sample_valid <= 1'b0; subchirp_tick <= 1'b0;
            even_odd <= 1'b0; gap_counter <= 7'd0; seq_active <= 1'b0;
        end else begin
            subchirp_tick <= 1'b0; // default: single-cycle pulse

            case (state)
                SC_IDLE: begin
                    csk_sample_valid <= 1'b0;
                    seq_active       <= 1'b0;
                    if (start) begin
                        state <= SC_SUBCHIRP;
                        k_index <= 2'd0; sample_index <= 6'd0;
                        subchirp_tick <= 1'b1;      // first subchirp
                        csk_sample_valid <= 1'b1;
                        seq_active <= 1'b1;
                    end
                end

                SC_SUBCHIRP: begin
                    csk_sample_valid <= 1'b1;
                    if (sample_index == 6'd37) begin
                        sample_index <= 6'd0;
                        if (k_index == 2'd3) begin
                            k_index <= 2'd0;
                            csk_sample_valid <= 1'b0;
                            gap_counter <= even_odd ? gap_odd : gap_even;
                            state <= SC_GAP;
                        end else begin
                            k_index <= k_index + 2'd1;
                            subchirp_tick <= 1'b1;  // next subchirp begins
                        end
                    end else begin
                        sample_index <= sample_index + 6'd1;
                    end
                end

                SC_GAP: begin
                    
                    if (gap_counter <= 7'd1) begin
                        even_odd         <= ~even_odd;
                        state            <= SC_SUBCHIRP;
                        subchirp_tick    <= 1'b1;   // next sequence begins
                        csk_sample_valid <= 1'b1;   // *** FIX: sample_index=0
                                                     // is real data, not a gap
                    end else begin
                        gap_counter <= gap_counter - 7'd1;
						csk_sample_valid <= 1'b0;
                    end
                end

                default: state <= SC_IDLE;
            endcase
        end
    end
endmodule

