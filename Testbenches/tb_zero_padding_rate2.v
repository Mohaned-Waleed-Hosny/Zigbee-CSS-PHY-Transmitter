`timescale 1ns / 1ps

module tb_zero_padding_rate2;

    reg clk;
    reg reset;
    reg data_rate;
    reg [7:0] payload_len;
    reg bit_in;
    reg valid_in;
    reg start_frame;

    wire bit_out;
    wire valid_out;
    wire done_padding;

    integer file_in, file_out;
    integer bit_from_file, status;

    zero_padding uut (
        .clk(clk),
        .reset(reset),
        .data_rate(data_rate),
        .payload_len(payload_len),
        .bit_in(bit_in),
        .valid_in(valid_in),
        .start_frame(start_frame),
        .bit_out(bit_out),
        .valid_out(valid_out),
        .done_padding(done_padding)
    );

    always #10 clk = ~clk;

    always @(posedge clk) begin
        #1; 
        if (valid_out) begin
            $fdisplay(file_out, "%b", bit_out);
        end
    end

    initial begin
        clk = 0;
        reset = 1;
        data_rate = 1'b1;      
        payload_len = 8'd2;   
        bit_in = 0;
        valid_in = 0;
        start_frame = 0;

        file_in  = $fopen("../Test_Vectors/Phase_1_Start_Demux/data_before_padding.txt", "r");
        file_out = $fopen("../Test_Vectors/Phase_1_Start_Demux/data_after_padding_verilog_rate2.txt", "w");

        if (file_in == 0) begin
            $display("../Test_Vectors/Phase_1_Start_Demux/data_before_padding.txt not found!");
            #100;
            $stop;
        end

        #40;
        reset = 0;
        #20;

        start_frame = 1;
        @(posedge clk);
        #1;
        start_frame = 0;

        while (!$feof(file_in)) begin
            status = $fscanf(file_in, "%d\n", bit_from_file);
            if (status == 1) begin
                bit_in   = bit_from_file[0];
                valid_in = 1'b1;
                @(posedge clk);
            end
        end

        valid_in = 0;
        bit_in   = 0;

        wait (done_padding == 1'b1);
        @(posedge clk);

        $fclose(file_in);
        $fclose(file_out);

        #100;
        $stop;
    end

endmodule