`timescale 1ns / 1ps

module matlab_golden_tb;
    localparam integer CLK_NS = 10;

    reg clk, reset, start_Tx, data_rate;
    reg [7:0] payloadLength, payload_addr, payload_din;
    reg payload_wr_en;
    wire signed [7:0] Tx_real, Tx_imag;
    wire done_Tx, busy;

    css_phy_tx_top #(.CSK_M(3'd1)) dut (
        .clk(clk), .reset(reset), .start_Tx(start_Tx), .data_rate(data_rate),
        .payloadLength(payloadLength), .payload_addr(payload_addr),
        .payload_din(payload_din), .payload_wr_en(payload_wr_en),
        .Tx_real(Tx_real), .Tx_imag(Tx_imag), .done_Tx(done_Tx), .busy(busy)
    );

    integer payload_mem [0:127];
    integer sreal0 [0:111], simag0 [0:111];
    integer sreal1 [0:351], simag1 [0:351];
    integer creal0 [0:4255], cimag0 [0:4255];
    integer creal1 [0:13375], cimag1 [0:13375];
    integer i, r, n, fd, scan;
    integer dq_count, css_count, dq_err, css_err, xz_err;
    integer expected_dq, expected_css;
    integer mismatch_printed;

    initial begin clk=0; forever #(CLK_NS/2) clk=~clk; end

    // Simpler explicit loaders for Verilog-2001 compatibility.
    task load_int_file;
        input [1023:0] fn;
        input integer count;
        input integer which;
        integer j, tmp, rc;
        begin
            fd=$fopen(fn,"r");
            if(fd==0) begin $display("ERROR opening %0s",fn); $finish; end
            for(j=0;j<count;j=j+1) begin
                rc=$fscanf(fd,"%d",tmp);
                if(rc!=1) begin $display("ERROR reading %0s at %0d",fn,j); $finish; end
                case(which)
                  0: sreal0[j]=tmp;
                  1: simag0[j]=tmp;
                  2: sreal1[j]=tmp;
                  3: simag1[j]=tmp;
                  4: creal0[j]=tmp;
                  5: cimag0[j]=tmp;
                  6: creal1[j]=tmp;
                  7: cimag1[j]=tmp;
                endcase
            end
            $fclose(fd);
        end
    endtask

    task load_payload;
        integer j, rc, tmp;
        begin
            fd=$fopen("payload_bytes.hex","r");
            if(fd==0) begin $display("ERROR opening payload_bytes.hex"); $finish; end
            for(j=0;j<10;j=j+1) begin
                rc=$fscanf(fd,"%h",tmp);
                if(rc!=1) begin $display("ERROR reading payload at %0d",j); $finish; end
                payload_mem[j]=tmp;
            end
            $fclose(fd);
            for(j=0;j<10;j=j+1) begin
                @(negedge clk);
                payload_addr=j; payload_din=payload_mem[j]; payload_wr_en=1'b1;
                @(negedge clk); payload_wr_en=1'b0;
            end
            payload_addr=0; payload_din=0;
        end
    endtask

    task run_rate;
        input integer rate;
        integer timeout;
        integer idx;
        reg [1023:0] srfn, sifn, crfn, cifn;
        begin
            expected_dq = (rate==0) ? 112 : 352;
            expected_css = expected_dq*38;
            if(rate==0) begin
                srfn="S_real_matlab_rate0.txt"; sifn="S_imag_matlab_rate0.txt";
                crfn="css_real_expected_rate0.txt"; cifn="css_imag_expected_rate0.txt";
            end else begin
                srfn="S_real_matlab_rate1.txt"; sifn="S_imag_matlab_rate1.txt";
                crfn="css_real_expected_rate1.txt"; cifn="css_imag_expected_rate1.txt";
            end

            // Reset counters and DUT.
            reset=1; start_Tx=0; data_rate=rate; payloadLength=10;
            payload_addr=0; payload_din=0; payload_wr_en=0;
            repeat(5) @(posedge clk); reset=0; repeat(2) @(posedge clk);
            load_payload;

            dq_count=0; css_count=0; dq_err=0; css_err=0; xz_err=0; mismatch_printed=0;

            @(negedge clk); data_rate=rate; payloadLength=10; start_Tx=1;
            @(negedge clk); start_Tx=0;

            timeout=(rate==0)?120000:220000;
            begin : wait_done
            for(idx=0; idx<timeout; idx=idx+1) begin
                @(posedge clk);
                if(dut.dqpsk_valid) begin
                    if(dq_count<expected_dq) begin
                        if(rate==0) begin
                            if($signed(dut.s_real)!==sreal0[dq_count] || $signed(dut.s_imag)!==simag0[dq_count]) begin
                                dq_err=dq_err+1;
                                if(mismatch_printed<5) begin $display("DQ mismatch rate%0d idx=%0d RTL=(%0d,%0d) MATLAB=(%0d,%0d)",rate,dq_count,$signed(dut.s_real),$signed(dut.s_imag),rate?sreal1[dq_count]:sreal0[dq_count],rate?simag1[dq_count]:simag0[dq_count]); mismatch_printed=mismatch_printed+1; end
                            end
                        end else begin
                            if($signed(dut.s_real)!==sreal1[dq_count] || $signed(dut.s_imag)!==simag1[dq_count]) begin
                                dq_err=dq_err+1;
                                if(mismatch_printed<5) begin $display("DQ mismatch rate%0d idx=%0d RTL=(%0d,%0d) MATLAB=(%0d,%0d)",rate,dq_count,$signed(dut.s_real),$signed(dut.s_imag),sreal1[dq_count],simag1[dq_count]); mismatch_printed=mismatch_printed+1; end
                            end
                        end
                    end
                    dq_count=dq_count+1;
                end
                if(dut.css_valid) begin
                    if (css_count < expected_css-1) begin

    if (rate == 0) begin

        if ($signed(Tx_real) !== creal0[css_count+1] ||
            $signed(Tx_imag) !== cimag0[css_count+1]) begin

            css_err = css_err + 1;

            if (mismatch_printed < 10) begin
                $display("CSS mismatch rate%0d idx=%0d RTL=(%0d,%0d) MATLAB=(%0d,%0d)",
                         rate, css_count,
                         $signed(Tx_real), $signed(Tx_imag),
                         creal0[css_count+1], cimag0[css_count+1]);
                mismatch_printed = mismatch_printed + 1;
            end

        end

    end
    else begin

        if ($signed(Tx_real) !== creal1[css_count+1] ||
            $signed(Tx_imag) !== cimag1[css_count+1]) begin

            css_err = css_err + 1;

            if (mismatch_printed < 10) begin
                $display("CSS mismatch rate%0d idx=%0d RTL=(%0d,%0d) MATLAB=(%0d,%0d)",
                         rate, css_count,
                         $signed(Tx_real), $signed(Tx_imag),
                         creal1[css_count+1], cimag1[css_count+1]);
                mismatch_printed = mismatch_printed + 1;
            end

        end

    end

end
                    if ((^Tx_real) === 1'bx || (^Tx_imag) === 1'bx) xz_err=xz_err+1;
                    css_count=css_count+1;
                end
                if(done_Tx) begin
                    // Allow one cycle for final counters to settle.
                    @(posedge clk); idx=timeout; disable wait_done;
                end
            end
            end

            $display("============================================================");
            $display("MATLAB GOLDEN CHECK rate=%0d (%s)",rate,rate?"250 kbps":"1 Mbps");
            $display("DQPSK: RTL=%0d MATLAB=%0d mismatches=%0d",dq_count,expected_dq,dq_err);
            $display("CSS  : RTL=%0d MATLAB-derived=%0d mismatches=%0d",css_count,expected_css,css_err);
            $display("X/Z errors=%0d",xz_err);
            if(dq_count==expected_dq && css_count==expected_css && dq_err==0 && css_err==0 && xz_err==0)
                $display("RESULT: PASS");
            else
                $display("RESULT: FAIL");
        end
    endtask

    initial begin
        // Load all MATLAB vectors.
        load_int_file("S_real_matlab_rate0.txt",112,0);
        load_int_file("S_imag_matlab_rate0.txt",112,1);
        load_int_file("S_real_matlab_rate1.txt",352,2);
        load_int_file("S_imag_matlab_rate1.txt",352,3);
        load_int_file("css_real_expected_rate0.txt",4256,4);
        load_int_file("css_imag_expected_rate0.txt",4256,5);
        load_int_file("css_real_expected_rate1.txt",13376,6);
        load_int_file("css_imag_expected_rate1.txt",13376,7);

        run_rate(0);
        run_rate(1);
        $display("============================================================");
        $display("MATLAB GOLDEN REGRESSION COMPLETE");
        $finish;
    end
endmodule