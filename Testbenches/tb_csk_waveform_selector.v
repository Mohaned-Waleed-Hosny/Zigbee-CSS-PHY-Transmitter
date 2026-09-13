`timescale 1ns/1ps
module tb_csk_waveform_selector;
    reg  [2:0] m;
    reg  [1:0] k;
    wire [1:0] waveform_id;
    integer errors = 0;

    csk_waveform_selector dut (.m(m), .k(k), .waveform_id(waveform_id));

    reg [1:0] expected [1:4][0:3];
    
    integer m_test, k_test; 

    initial begin
        // Populate expected values based on RTL contract
        expected[1][0]=0; expected[1][1]=1; expected[1][2]=2; expected[1][3]=3;
        expected[2][0]=1; expected[2][1]=3; expected[2][2]=0; expected[2][3]=2;
        expected[3][0]=3; expected[3][1]=2; expected[3][2]=1; expected[3][3]=0;
        expected[4][0]=2; expected[4][1]=0; expected[4][2]=3; expected[4][3]=1;

        for (m_test = 1; m_test <= 4; m_test = m_test + 1) begin
            for (k_test = 0; k_test <= 3; k_test = k_test + 1) begin
                m = m_test; k = k_test;
                #10;
                if (waveform_id !== expected[m_test][k_test]) begin
                    $display("ERROR: m=%0d, k=%0d. Got %0d, Expected %0d", m, k, waveform_id, expected[m_test][k_test]);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0) $display("tb_csk_waveform_selector: PASSED");
        else $display("tb_csk_waveform_selector: FAILED with %0d errors", errors);
        $finish;
    end
endmodule