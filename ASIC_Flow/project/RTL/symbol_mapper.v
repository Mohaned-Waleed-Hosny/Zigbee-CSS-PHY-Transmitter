`timescale 1ns / 1ps

module symbol_mapper (
    input  wire        clk,
    input  wire        reset,
    input  wire        data_rate,
    input  wire        i_bit,
    input  wire        q_bit,
    input  wire        valid_in,
    output reg  [0:31] i_mapped,
    output reg  [0:31] q_mapped,
    output reg         valid_out
);
    reg [0:5] i_shift, q_shift;
    reg [2:0] bit_cnt;

    wire [5:0] i_addr = {i_shift[0], i_shift[1], i_shift[2], i_shift[3], i_shift[4], i_bit};
    wire [5:0] q_addr = {q_shift[0], q_shift[1], q_shift[2], q_shift[3], q_shift[4], q_bit};

    // 1 Mbps lookup function (8 entries x 4 bits)
    function automatic [0:3] get_1mbs(input [2:0] addr);
        case (addr)
            3'b000:  get_1mbs = 4'b1111;
            3'b001:  get_1mbs = 4'b1010;
            3'b010:  get_1mbs = 4'b1100;
            3'b011:  get_1mbs = 4'b1001;
            3'b100:  get_1mbs = 4'b0000;
            3'b101:  get_1mbs = 4'b0101;
            3'b110:  get_1mbs = 4'b0011;
            3'b111:  get_1mbs = 4'b0110;
            default: get_1mbs = 4'b0000;
        endcase
    endfunction

    // 250 kbps lookup function (64 entries x 32 bits)
    function automatic [0:31] get_250kbs(input [5:0] addr);
        case (addr)
            6'd0:  get_250kbs = 32'hFFFFFFFF;
            6'd1:  get_250kbs = 32'hAAAAAAAA;
            6'd2:  get_250kbs = 32'hCCCCCCCC;
            6'd3:  get_250kbs = 32'h99999999;
            6'd4:  get_250kbs = 32'hF0F0F0F0;
            6'd5:  get_250kbs = 32'hA5A5A5A5;
            6'd6:  get_250kbs = 32'hC3C3C3C3;
            6'd7:  get_250kbs = 32'h96969696;
            6'd8:  get_250kbs = 32'hFF00FF00;
            6'd9:  get_250kbs = 32'hAA55AA55;
            6'd10: get_250kbs = 32'hCC33CC33;
            6'd11: get_250kbs = 32'h99669966;
            6'd12: get_250kbs = 32'hF00FF00F;
            6'd13: get_250kbs = 32'hA55AA55A;
            6'd14: get_250kbs = 32'hC33CC33C;
            6'd15: get_250kbs = 32'h96699669;
            6'd16: get_250kbs = 32'hFFFF0000;
            6'd17: get_250kbs = 32'hAAAA5555;
            6'd18: get_250kbs = 32'hCCCC3333;
            6'd19: get_250kbs = 32'h99996666;
            6'd20: get_250kbs = 32'hF0F00F0F;
            6'd21: get_250kbs = 32'hA5A55A5A;
            6'd22: get_250kbs = 32'hC3C33C3C;
            6'd23: get_250kbs = 32'h96966969;
            6'd24: get_250kbs = 32'hFF0000FF;
            6'd25: get_250kbs = 32'hAA5555AA;
            6'd26: get_250kbs = 32'hCC3333CC;
            6'd27: get_250kbs = 32'h99666699;
            6'd28: get_250kbs = 32'hF00F0FF0;
            6'd29: get_250kbs = 32'hA55A5AA5;
            6'd30: get_250kbs = 32'hC33C3CC3;
            6'd31: get_250kbs = 32'h96696996;
            6'd32: get_250kbs = 32'h00000000;
            6'd33: get_250kbs = 32'h55555555;
            6'd34: get_250kbs = 32'h33333333;
            6'd35: get_250kbs = 32'h66666666;
            6'd36: get_250kbs = 32'h0F0F0F0F;
            6'd37: get_250kbs = 32'h5A5A5A5A;
            6'd38: get_250kbs = 32'h3C3C3C3C;
            6'd39: get_250kbs = 32'h69696969;
            6'd40: get_250kbs = 32'h00FF00FF;
            6'd41: get_250kbs = 32'h55AA55AA;
            6'd42: get_250kbs = 32'h33CC33CC;
            6'd43: get_250kbs = 32'h66996699;
            6'd44: get_250kbs = 32'h0FF00FF0;
            6'd45: get_250kbs = 32'h5AA55AA5;
            6'd46: get_250kbs = 32'h3CC33CC3;
            6'd47: get_250kbs = 32'h69966996;
            6'd48: get_250kbs = 32'h0000FFFF;
            6'd49: get_250kbs = 32'h5555AAAA;
            6'd50: get_250kbs = 32'h3333CCCC;
            6'd51: get_250kbs = 32'h66669999;
            6'd52: get_250kbs = 32'h0F0FF0F0;
            6'd53: get_250kbs = 32'h5A5AA5A5;
            6'd54: get_250kbs = 32'h3C3CC3C3;
            6'd55: get_250kbs = 32'h69699696;
            6'd56: get_250kbs = 32'h00FFFF00;
            6'd57: get_250kbs = 32'h55AAAA55;
            6'd58: get_250kbs = 32'h33CCCC33;
            6'd59: get_250kbs = 32'h66999966;
            6'd60: get_250kbs = 32'h0FF0F00F;
            6'd61: get_250kbs = 32'h5AA5A55A;
            6'd62: get_250kbs = 32'h3CC3C33C;
            6'd63: get_250kbs = 32'h69969669;
            default: get_250kbs = 32'h00000000;
        endcase
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_cnt   <= 3'd0;
            valid_out <= 1'b0;
            i_mapped  <= 32'd0;
            q_mapped  <= 32'd0;
            i_shift   <= 6'd0;
            q_shift   <= 6'd0;
        end else begin
            valid_out <= 1'b0;
            if (valid_in) begin
                i_shift[bit_cnt] <= i_bit;
                q_shift[bit_cnt] <= q_bit;

                if (data_rate == 1'b0) begin // 1 Mbps
                    if (bit_cnt == 3'd2) begin
                        bit_cnt       <= 3'd0;
                        i_mapped[0:3] <= get_1mbs({i_shift[0], i_shift[1], i_bit});
                        q_mapped[0:3] <= get_1mbs({q_shift[0], q_shift[1], q_bit});
                        valid_out     <= 1'b1;
                    end else begin
                        bit_cnt <= bit_cnt + 3'd1;
                    end
                end else begin // 250 kbps
                    if (bit_cnt == 3'd5) begin
                        bit_cnt   <= 3'd0;
                        i_mapped  <= get_250kbs(i_addr);
                        q_mapped  <= get_250kbs(q_addr);
                        valid_out <= 1'b1;
                    end else begin
                        bit_cnt <= bit_cnt + 3'd1;
                    end
                end
            end
        end
    end

endmodule