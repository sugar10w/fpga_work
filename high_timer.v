// Created by wxk14
//   Count the time of high level

module high_timer(
	clk
	,probe
	,out_cnt
);

// input & output
input clk;
input probe;
output reg[15:0] out_cnt;

reg[15:0] cnt;
always @ (posedge clk)
begin
	if (probe)
	begin
		cnt <= cnt+1;
	end
	else if (cnt!=0) 
	begin
		out_cnt = cnt;
		cnt = 0;
	end
end

endmodule
