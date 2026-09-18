`timescale 1ns / 1ps

module controller (
    input  wire        clk,
    input  wire        reset,
    input  wire        start_Tx,
    input  wire        data_rate,       // 0 for 1 Mbps rate, 1 for 250 kbps rate
    input  wire [7:0]  payload_len,     // payload size in bytes

    // Interface to read the data memories (I & Q Buffer RAMs)
    output reg  [12:0] ram_read_addr,
    input  wire        i_ram_data,
    input  wire        q_ram_data,

    // Interface to read the Preamble/SFD ROM
    output reg  [6:0]  rom_read_addr,
    input  wire        rom_data,

    // Outputs to the QPSK Mapper (through the internal MUX)
    output reg         i_to_qpsk,
    output reg         q_to_qpsk,
    output reg         valid_to_qpsk,

    // Completion signal
    output reg         done_Tx
);

    // State definitions
    localparam IDLE        = 3'd0;
    localparam TX_PREAMBLE = 3'd1;
    localparam TX_SFD      = 3'd2;
    localparam TX_DATA     = 3'd3;
    localparam TX_FLUSH    = 3'd4;
    localparam TX_DONE     = 3'd5;

    reg [2:0]  state, next_state;
    reg [12:0] counter;         // general-purpose step counter
    reg [12:0] total_ram_bits;  // number of bits to read from EACH (I and Q) buffer RAM

    // Pre-computation of how many bits will be read from the RAM
    wire [10:0] raw_bits = 12 + (payload_len * 8); // 12 bits for PHR + payload size
    wire [10:0] pad6  = (raw_bits % 6 == 0)  ? 0 : (6 - (raw_bits % 6));
    wire [10:0] pad24 = (raw_bits % 24 == 0) ? 0 : (24 - (raw_bits % 24));
    wire [10:0] padded_bits = raw_bits + (data_rate ? pad24 : pad6);

    // Combined I+Q coded bit count (before the Demux split across the two RAM paths)
    wire [12:0] coded_bits_1m_total   = (padded_bits / 3) * 4;   // 1M: every 3 bits become 4
    wire [12:0] coded_bits_250k_total = (padded_bits / 6) * 32;  // 250k: every 6 bits become 32

    wire [12:0] coded_bits_1m   = coded_bits_1m_total   >> 1;
    wire [12:0] coded_bits_250k = coded_bits_250k_total >> 1;


    // State register
    always @(posedge clk or posedge reset) begin
        if (reset) state <= IDLE;
        else       state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        next_state = state; // stay in the same state by default

        case (state)
            IDLE: begin
                if (start_Tx) next_state = TX_PREAMBLE;
            end

            TX_PREAMBLE: begin
                // Preamble is 32 bits for the high rate, 80 for the low rate
                if (counter == (data_rate ? 80 : 32) - 1) next_state = TX_SFD;
            end

            TX_SFD: begin
                // The Start Frame Delimiter is always 16 bits
                if (counter == 16 - 1) next_state = TX_DATA;
            end

            TX_DATA: begin
                // wait until the counter finishes reading the RAM content (per path)
                if (counter == total_ram_bits - 1) next_state = TX_FLUSH;
            end

            TX_FLUSH: begin
                // 4 cycles to flush the DQPSK delay line
                if (counter == 4 - 1) next_state = TX_DONE;
            end

            TX_DONE: begin
                next_state = IDLE;
            end
        endcase
    end

    // Counters and outputs (datapath)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter        <= 0;
            rom_read_addr  <= 0;
            ram_read_addr  <= 0;
            i_to_qpsk      <= 0;
            q_to_qpsk      <= 0;
            valid_to_qpsk  <= 0;
            done_Tx        <= 0;
            total_ram_bits <= 0;
        end else begin
            // default values to avoid signal glitches
            valid_to_qpsk <= 0;
            done_Tx       <= 0;

            case (state)
                IDLE: begin
                    counter       <= 0;
                    rom_read_addr <= 0;
                    ram_read_addr <= 0;
                    // when starting, latch the per-path bit count we will read in TX_DATA
                    if (start_Tx) begin
                        total_ram_bits <= data_rate ? coded_bits_250k : coded_bits_1m;
                    end
                end

                TX_PREAMBLE, TX_SFD: begin // merged here because both read from the ROM
                    valid_to_qpsk <= 1'b1;
                    i_to_qpsk     <= rom_data; 
                    q_to_qpsk     <= rom_data; // Preamble and SFD are identical on I and Q
                    rom_read_addr <= rom_read_addr + 1; // advance the ROM read pointer

                    if (counter == ((state == TX_PREAMBLE) ? (data_rate ? 80 : 32) : 16) - 1)
                        counter <= 0;
                    else
                        counter <= counter + 1;
                end

                TX_DATA: begin
                    valid_to_qpsk <= 1'b1;
                    i_to_qpsk     <= i_ram_data; // route the I path from RAM
                    q_to_qpsk     <= q_ram_data; // route the Q path from RAM
                    ram_read_addr <= ram_read_addr + 1; // advance the RAM read pointer

                    if (counter == total_ram_bits - 1)
                        counter <= 0;
                    else
                        counter <= counter + 1;
                end

                TX_FLUSH: begin
                    valid_to_qpsk <= 1'b0; // stop sending new data
                    if (counter == 4 - 1)
                        counter <= 0;
                    else
                        counter <= counter + 1;
                end

                TX_DONE: begin
                    done_Tx <= 1'b1; // send the completion pulse to the MAC
                end
            endcase
        end
    end

endmodule