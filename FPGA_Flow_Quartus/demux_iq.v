`timescale 1ns / 1ps

module demux_iq (
    input wire clk,
    input wire reset,
    input wire start_frame, 
    
    input wire bit_in,      
    input wire valid_in,    
    
    output reg i_bit,       
    output reg q_bit,       
    output reg valid_out    
);

    reg toggle; 
    reg i_temp; 

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            toggle <= 1'b0;
            i_temp <= 1'b0;
            i_bit <= 1'b0;
            q_bit <= 1'b0;
            valid_out <= 1'b0;
        end else if (start_frame) begin
            toggle <= 1'b0;
            valid_out <= 1'b0;
        end else begin
            if (valid_in) begin
                if (toggle == 1'b0) begin
                    i_temp <= bit_in;
                    toggle <= 1'b1;
                    valid_out <= 1'b0; 
                end else begin
                    i_bit <= i_temp;
                    q_bit <= bit_in;
                    toggle <= 1'b0;
                    valid_out <= 1'b1; 
                end
            end else begin
                valid_out <= 1'b0; 
            end
        end
    end
endmodule