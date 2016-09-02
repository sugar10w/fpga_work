//   PWM based on percent

module PWM_per(
	clk0
	,percent
	,out
);

// input/output
input clk0;
input[15:0] percent;
output reg out;

// f = 1kHz ; clk = 100kHz;
wire clk_10k; 
timedivider(clk0, 500, clk);
 
// count
reg[15:0] cnt;

always @ (posedge clk)
begin
	cnt=cnt+1;
	if (cnt>=100) cnt=0;

	if (cnt<percent) out<=1; else out<=0;
end

endmodule
