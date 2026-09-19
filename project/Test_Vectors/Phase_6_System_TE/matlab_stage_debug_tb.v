`timescale 1ns / 1ps
// ============================================================
// MATLAB Stage Debug V3 - 1 Mbps
// Compares RTL against MATLAB vectors at every stage.
// Run from the verification directory. MATLAB vectors are in ../Matlab/.
// Payload is the 10-byte MATLAB payload used by runMe.m.
// ============================================================
module matlab_stage_debug_tb_v11;
    reg [31:0] int_i_rtl;
    reg [31:0] int_q_rtl;
    localparam integer CLK_NS=10;
    integer k;
    reg clk, reset, start_Tx, data_rate;
    reg [7:0] payloadLength, payload_addr, payload_din;
    reg payload_wr_en;
    wire signed [7:0] Tx_real, Tx_imag;
    wire done_Tx, busy;

    css_phy_tx_top #(.CSK_M(3'd1)) dut (
      .clk(clk), .reset(reset), .start_Tx(start_Tx), .data_rate(data_rate),
      .payloadLength(payloadLength), .payload_addr(payload_addr),
      .payload_din(payload_din), .payload_wr_en(payload_wr_en),
      .Tx_real(Tx_real), .Tx_imag(Tx_imag), .done_Tx(done_Tx), .busy(busy));

        reg [31:0] exp_ii[0:15], exp_iq[0:15];
    reg       exp_pi[0:111], exp_pq[0:111];
    integer exp_sr[0:111], exp_si[0:111];
    integer payload_mem[0:127];

    integer fd,ok,val;
    integer int_n,ppdu_n,dq_n;
    integer int_err,ppdu_err,dq_err;
    integer printed;

    initial begin clk=0; forever #(CLK_NS/2) clk=~clk; end

    task load_inter;
      integer idx; reg [31:0] s1,s2;
      begin
        fd=$fopen("../Matlab/I_interleaved_matlab_rate0.txt","r"); if(!fd)begin $display("ERROR open inter I");$finish;end
        for(idx=0;idx<16;idx=idx+1)begin ok=$fscanf(fd,"%s",s1);if(ok!=1)$finish;exp_ii[idx]=s1;end $fclose(fd);
        fd=$fopen("../Matlab/Q_interleaved_matlab_rate0.txt","r"); if(!fd)begin $display("ERROR open inter Q");$finish;end
        for(idx=0;idx<16;idx=idx+1)begin ok=$fscanf(fd,"%s",s2);if(ok!=1)$finish;exp_iq[idx]=s2;end $fclose(fd);
      end
    endtask

    task load_ppdu;
      integer idx; integer a,b;
      begin
        fd=$fopen("../Matlab/I_ppdu_matlab_rate0.txt","r");if(!fd)begin $display("ERROR open PPDU I");$finish;end
        for(idx=0;idx<112;idx=idx+1)begin ok=$fscanf(fd,"%d",a);if(ok!=1)$finish;exp_pi[idx]=a;end $fclose(fd);
        fd=$fopen("../Matlab/Q_ppdu_matlab_rate0.txt","r");if(!fd)begin $display("ERROR open PPDU Q");$finish;end
        for(idx=0;idx<112;idx=idx+1)begin ok=$fscanf(fd,"%d",b);if(ok!=1)$finish;exp_pq[idx]=b;end $fclose(fd);
      end
    endtask

    task load_dq;
      integer idx,a,b;
      begin
        fd=$fopen("../Matlab/S_real_matlab_rate0.txt","r");if(!fd)begin $display("ERROR open S real");$finish;end
        for(idx=0;idx<112;idx=idx+1)begin ok=$fscanf(fd,"%d",a);if(ok!=1)$finish;exp_sr[idx]=a;end $fclose(fd);
        fd=$fopen("../Matlab/S_imag_matlab_rate0.txt","r");if(!fd)begin $display("ERROR open S imag");$finish;end
        for(idx=0;idx<112;idx=idx+1)begin ok=$fscanf(fd,"%d",b);if(ok!=1)$finish;exp_si[idx]=b;end $fclose(fd);
      end
    endtask

    task load_payload;
      integer idx;
      reg [7:0] payload_bytes [0:9];
      begin
        // Exact 10-byte payload exported from the MATLAB runMe.m vectors.
        payload_bytes[0]=8'hF4; payload_bytes[1]=8'hC9;
        payload_bytes[2]=8'h1A; payload_bytes[3]=8'h3C;
        payload_bytes[4]=8'hDA; payload_bytes[5]=8'h2F;
        payload_bytes[6]=8'h16; payload_bytes[7]=8'h9B;
        payload_bytes[8]=8'h34; payload_bytes[9]=8'h09;
        for(idx=0;idx<10;idx=idx+1)begin
          @(negedge clk); payload_addr=idx; payload_din=payload_bytes[idx]; payload_wr_en=1;
          @(negedge clk); payload_wr_en=0;
        end
        payload_addr=0; payload_din=0;
      end
    endtask

    initial begin
      reset=1;start_Tx=0;data_rate=0;payloadLength=10;payload_addr=0;payload_din=0;payload_wr_en=0;
      int_n=0;ppdu_n=0;dq_n=0;int_err=0;ppdu_err=0;dq_err=0;printed=0;
      load_inter; load_ppdu; load_dq;
      repeat(5)@(posedge clk);reset=0;repeat(2)@(posedge clk);load_payload;
      @(negedge clk);start_Tx=1;@(negedge clk);start_Tx=0;
      repeat(10000)@(posedge clk);
      $display("\n================ V9 STAGE RESULT ================");
      $display("INTERLEAVER RTL=%0d EXP=16  ERR=%0d",int_n,int_err);
      $display("PPDU       RTL=%0d EXP=112 ERR=%0d",ppdu_n,ppdu_err);
      $display("DQPSK      RTL=%0d EXP=112 ERR=%0d",dq_n,dq_err);
      $display("==================================================");
      $finish;
    end

    always @(posedge clk) begin
      #1;
      if(dut.interleaver_valid) begin
        // RTL bus is declared [0:63]/[0:31]-style in the design, while
        // MATLAB file words are read into [31:0]. Build a normalized
        // 32-bit value before comparing, preserving the actual bit order.
        for (k=0; k<32; k=k+1) begin
          int_i_rtl[k] = dut.i_interleaved[k];
          int_q_rtl[k] = dut.q_interleaved[k];
        end

        // Compare the complete 32-bit 1-Mbps interleaved word.
        if(int_n<16 && (int_i_rtl !== exp_ii[int_n] ||
                        int_q_rtl !== exp_iq[int_n])) begin
          int_err=int_err+1;
          if(int_err<=10)
            $display("INT MISMATCH #%0d RTL=(%b,%b) MATLAB=(%b,%b)",
                     int_n,int_i_rtl,int_q_rtl,
                     exp_ii[int_n],exp_iq[int_n]);
        end
        if(int_n<4)
          $display("INT #%0d RTL=(%b,%b) MATLAB=(%b,%b)",
                   int_n,int_i_rtl,int_q_rtl,
                   exp_ii[int_n],exp_iq[int_n]);
        int_n=int_n+1;
      end
      if(dut.ppdu_valid) begin
        if(ppdu_n<112 && (dut.ppdu_i !== exp_pi[ppdu_n] || dut.ppdu_q !== exp_pq[ppdu_n])) begin
          ppdu_err=ppdu_err+1;if(ppdu_err<=12)$display("PPDU MISMATCH #%0d RTL=(%0d,%0d) MATLAB=(%0d,%0d)",ppdu_n,dut.ppdu_i,dut.ppdu_q,exp_pi[ppdu_n],exp_pq[ppdu_n]);
        end
        if(ppdu_n<52 || (ppdu_n>=48 && ppdu_n<58))$display("PPDU #%0d RTL=(%0d,%0d) MATLAB=(%0d,%0d)",ppdu_n,dut.ppdu_i,dut.ppdu_q,exp_pi[ppdu_n],exp_pq[ppdu_n]);
        ppdu_n=ppdu_n+1;
      end
      if(dut.dqpsk_valid) begin
        if(dq_n<112 && ($signed(dut.s_real)!==exp_sr[dq_n] || $signed(dut.s_imag)!==exp_si[dq_n])) begin
          dq_err=dq_err+1;if(dq_err<=15)$display("DQ MISMATCH #%0d RTL=(%0d,%0d) MATLAB=(%0d,%0d)",dq_n,$signed(dut.s_real),$signed(dut.s_imag),exp_sr[dq_n],exp_si[dq_n]);
        end
        dq_n=dq_n+1;
      end
    end
endmodule
