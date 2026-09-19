`timescale 1ns / 1ps

module nexys_phy_tx_wrapper (
    // Clock and Reset
    input  wire       CLK100MHZ,
    input  wire       BTNC,         // Used as System Reset

    // Control and Data Inputs
    input  wire       BTNU,         // start_Tx
    input  wire       BTND,         // payload_wr_en
    input  wire       SW_DATA_RATE, // data_rate (SW[15])
    input  wire [7:0] SW_DIN,       // payload_din (SW[7:0])

    // Multi-bit Configurations (PMODs as Inputs)
    input  wire [7:0] JA,           // payloadLength
    input  wire [7:0] JB,           // payload_addr

    // High-Speed Complex Outputs (PMODs as Outputs)
    output wire [7:0] JC,           // Tx_real
    output wire [7:0] JD,           // Tx_imag

    // Status Indicators
    output wire       LED_DONE,     // done_Tx
    output wire       LED_BUSY      // busy
);

    // --- Clock and Reset Domain ---
    wire clk_32mhz;
    
    // Instantiate Phase 1 PLL
    // Note: 'locked' was disabled in Phase 1; 'reset' was kept.
    clk_wiz_0 u_pll (
        .clk_in1 (CLK100MHZ),
        .reset   (BTNC),       // Raw asynchronous board reset
        .clk_out1(clk_32mhz)
    );

    // --- Synchronization Registers ---
    // Synchronize async button presses to the 32 MHz clock domain
    reg [1:0] sync_reset, sync_start, sync_wr_en;

    always @(posedge clk_32mhz or posedge BTNC) begin
        if (BTNC) begin
            sync_reset <= 2'b11;
            sync_start <= 2'b00;
            sync_wr_en <= 2'b00;
        end else begin
            sync_reset <= {sync_reset[0], 1'b0};
            sync_start <= {sync_start[0], BTNU};
            sync_wr_en <= {sync_wr_en[0], BTND};
        end
    end

    // --- Core PHY Instantiation ---
    css_phy_tx_top #(
        .CSK_M(3'd1) // Configurable as per core definition
    ) u_phy_core (
        .clk           (clk_32mhz),
        .reset         (sync_reset[1]),
        
        .start_Tx      (sync_start[1]),       // Synchronized
        .data_rate     (SW_DATA_RATE),        // Static switch, no sync needed
        .payloadLength (JA),                  // Mapped to PMOD JA
        
        .payload_addr  (JB),                  // Mapped to PMOD JB
        .payload_din   (SW_DIN),              // Mapped to SW[7:0]
        .payload_wr_en (sync_wr_en[1]),       // Synchronized
        
        .Tx_real       (JC),                  // Mapped to PMOD JC
        .Tx_imag       (JD),                  // Mapped to PMOD JD
        .done_Tx       (LED_DONE),            // Mapped to LED[0]
        .busy          (LED_BUSY)             // Mapped to LED[1]
    );

endmodule