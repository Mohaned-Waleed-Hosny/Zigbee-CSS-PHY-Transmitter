`timescale 1ns / 1ps

module zero_padding (
    input wire clk,
    input wire reset,
    input wire data_rate,       // 0 for 1 Mbps (N=6), 1 for 250 kbps (N=24)
    input wire [7:0] payload_len, 
    input wire bit_in,          
    input wire valid_in,        
    input wire start_frame,     
    
    output reg bit_out,         
    output reg valid_out,       
    output reg done_padding     
);

    localparam IDLE    = 2'b00;
    localparam DATA    = 2'b01;
    localparam PADDING = 2'b10;
    
    reg [1:0] state;
    reg [15:0] data_bit_count;  
    reg [15:0] total_data_bits; 
    reg [4:0]  mod_counter;     
    reg [4:0]  max_mod;         

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            data_bit_count <= 0;
            mod_counter <= 0;
            total_data_bits <= 0;
            max_mod <= 0;
            bit_out <= 0;
            valid_out <= 0;
            done_padding <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done_padding <= 0;
                    valid_out <= 0;
                    if (start_frame) begin
                        state <= DATA;
                        data_bit_count <= 0;
                        mod_counter <= 0;
                        total_data_bits <= 16'd12 + ({8'd0, payload_len} * 16'd8); 
                        max_mod <= (data_rate == 1'b0) ? 5 : 23; 
                    end
                end
                
                DATA: begin
                    valid_out <= 0; 
                    done_padding <= 0;
                    if (valid_in) begin
                        bit_out <= bit_in;
                        valid_out <= 1'b1;
                        data_bit_count <= data_bit_count + 1;
                        
                        if (mod_counter == max_mod) 
                            mod_counter <= 0;
                        else 
                            mod_counter <= mod_counter + 1;
                        
                        if (data_bit_count + 1 == total_data_bits) begin
                            if (mod_counter == max_mod) begin
                                state <= IDLE;
                                done_padding <= 1'b1; 
                            end else begin
                                state <= PADDING;
                            end
                        end
                    end
                end
                
                PADDING: begin
                    bit_out <= 1'b0;
                    valid_out <= 1'b1;
                    
                    if (mod_counter == max_mod) begin
                        mod_counter <= 0;
                        state <= IDLE;
                        done_padding <= 1'b1; 
                    end else begin
                        mod_counter <= mod_counter + 1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule