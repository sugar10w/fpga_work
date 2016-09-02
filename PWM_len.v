// Created by wxk14, 2016.8
//   PWM based on length ,length(us), max=10000us(100Hz)

module PWM_len(
	clk0
	,length
	,out
);

// input & output
input clk0;
input[15:0] length;
output reg out;

wire clk; 
timedivider(clk0, 50, clk); // clk: T=1us, 1MHz
 
// count
reg[15:0] cnt;

always @ (posedge clk)
begin
	if (cnt>=10000)
	begin
		out<=1;
		cnt<=0;
	end else if (cnt>length)
	begin
		out<=0;
		cnt=cnt+1;
	end else
	begin 
		cnt=cnt+1;
	end
end

endmodule
