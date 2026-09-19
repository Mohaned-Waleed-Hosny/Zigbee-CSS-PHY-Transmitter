module dqpsk_encoder (

input wire              clk,
input wire              reset,           //active high asynchronous reset
input wire signed [1:0] x_real,         //real part of the qpsk_mapper signal
input wire signed [1:0] x_imag,        //imaginary part of the qpsk_mapper signal
input wire              valid_in,

output reg signed [1:0] s_real,       //real part of dqpsk encoder
output reg signed [1:0] s_imag,      //imaginary part of dqpsk encoder
output reg              valid_out    // qualifies s_real and s_imag for CSK stage
);

// Z^-4 delay lines, such that index 0 is the most recent while index 3 is the most delayed version (Sn-4)

reg signed [1:0] s_real_d [0:3];
reg signed [1:0] s_imag_d [0:3];

wire swap = x_imag[0] ;     //for swaping branchs I and Q 
wire negate_q_pre = x_real[1] | x_imag[1] ;
wire negate_i_pre = negate_q_pre ^ swap ;

wire signed [1:0] i_pre = swap ? s_imag_d[3] : s_real_d[3];
wire signed [1:0] q_pre = swap ? s_real_d[3] : s_imag_d[3];

wire signed [1:0] i_new = {negate_i_pre ^ i_pre[1] , i_pre[0]};
wire signed [1:0] q_new = {negate_q_pre ^ q_pre[1] , q_pre[0]};

always @(posedge clk or posedge reset) begin
if(reset) begin

valid_out <= 1'b0;

s_real_d[0] <= 2'sd1; s_imag_d[0] <= 2'sd1;
s_real_d[1] <= 2'sd1; s_imag_d[1] <= 2'sd1; 
s_real_d[2] <= 2'sd1; s_imag_d[2] <= 2'sd1;
s_real_d[3] <= 2'sd1; s_imag_d[3] <= 2'sd1;

s_real <= 2'sd1;      s_imag <= 2'sd1;  //reseted to phase 0 (1,1) constellation point

end else begin 

valid_out <= valid_in;  

if(valid_in) begin

// generating Sn (required symbol output)

s_real <= i_new;      s_imag <= q_new;     

// shfiting to have the Z^-4 delay line
s_real_d[3] <= s_real_d[2];  s_imag_d[3] <= s_imag_d[2];
s_real_d[2] <= s_real_d[1];  s_imag_d[2] <= s_imag_d[1];
s_real_d[1] <= s_real_d[0];  s_imag_d[1] <= s_imag_d[0];
s_real_d[0] <= i_new;  s_imag_d[0] <= q_new;
end
end
end


endmodule