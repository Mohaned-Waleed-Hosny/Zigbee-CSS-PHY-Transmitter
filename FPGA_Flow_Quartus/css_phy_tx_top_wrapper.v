module css_phy_tx_top_wrapper (
    input  wire       clk,
    input  wire       reset,
    input  wire       start_Tx,
    input  wire       data_rate,
    input  wire [7:0] payloadLength,
    input  wire       payload_wr_en,

    output wire signed [7:0] Tx_real,
    output wire signed [7:0] Tx_imag,
    output wire              done_Tx,
    output wire              busy
);

    // 16-bit virtual sources bus from ISSP (8-bit Addr + 8-bit Data)
    wire [15:0] issp_sources;

    // Intel/Altera ISSP IP Instantiation
    altsource_probe #(
        .sld_auto_instance_index ("YES"),
        .sld_instance_index      (0),
        .instance_id             ("DATA"),
        .probe_width             (0),
        .source_width            (16),
        .source_initial_value    ("0")
    ) u_issp (
        .source (issp_sources),
        .probe  ()
    );

    // Instantiate your original Design Core
    css_phy_tx_top u_css_phy_tx_top (
        .clk            (clk),
        .reset          (reset),
        .start_Tx       (start_Tx),
        .data_rate      (data_rate),
        .payloadLength  (payloadLength),
        .payload_addr   (issp_sources[7:0]),   // Controlled via Laptop (Bits 7:0)
        .payload_din    (issp_sources[15:8]),  // Controlled via Laptop (Bits 15:8)
        .payload_wr_en (payload_wr_en),
        .Tx_real        (Tx_real),
        .Tx_imag        (Tx_imag),
        .done_Tx        (done_Tx),
        .busy           (busy)
    );

endmodule