`timescale 1ns / 1ps

module tb_top_system_250k;


    reg clk;
    reg reset;
    reg data_rate;
    reg [7:0] payload_len;
    reg bit_in;
    reg valid_in;
    reg start_frame;

    wire zp_bit_out;
    wire zp_valid_out;
    wire zp_done_padding;

    wire i_bit;
    wire q_bit;
    wire demux_valid_out;

    integer i, idx_iq;
    reg raw_bits [0:255];

    zero_padding u_zero_padding (
        .clk(clk),
        .reset(reset),
        .data_rate(data_rate),
        .payload_len(payload_len),
        .bit_in(bit_in),
        .valid_in(valid_in),
        .start_frame(start_frame),
        .bit_out(zp_bit_out),
        .valid_out(zp_valid_out),
        .done_padding(zp_done_padding)
    );

    demux_iq u_demux_iq (
        .clk(clk),
        .reset(reset),
        .start_frame(start_frame),
        .bit_in(zp_bit_out),
        .valid_in(zp_valid_out),
        .i_bit(i_bit),
        .q_bit(q_bit),
        .valid_out(demux_valid_out)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        data_rate = 1'b1;      
        payload_len = 8'd2;    
        bit_in = 0;
        valid_in = 0;
        start_frame = 0;
        idx_iq = 0;

        $readmemb("../Test_Vectors/Phase_1_Start_Demux/data_before_padding.txt", raw_bits);

        #40;
        reset = 0;
        #20;

        start_frame = 1;
        #20;
        start_frame = 0;

        for (i = 0; i < 28; i = i + 1) begin
            @(posedge clk);
            bit_in <= raw_bits[i];
            valid_in <= 1'b1;
        end

        @(posedge clk);
        valid_in <= 1'b0;
        bit_in <= 1'b0;

        wait (zp_done_padding);
        #100;

        $display("--------------------------------------------------");
        $display("[INFO] Simulation finished for 250 kbps data rate.");
        $display("--------------------------------------------------");

        $stop;
    end

    always @(posedge clk) begin
        if (demux_valid_out) begin
            $display("Index %0d | I_bit = %b | Q_bit = %b", idx_iq, i_bit, q_bit);
            idx_iq = idx_iq + 1;
        end
    end

endmodule