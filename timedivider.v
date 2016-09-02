// Created by wxk14, 2015.12
//   time divider

module timedivider(
	clk, multi,
	clk_out
);

// input & output
input clk;
input[31:0] multi;
output reg clk_out;

// counter
reg[31:0] cnt;

always @ (posedge clk)
begin
	cnt = cnt + 1;
	
	/**** TESTBENCH *** only! ***/
	//if (cnt > multi/10000)
	if (cnt > multi/2) 
    
	begin
		clk_out = ~ clk_out;
		cnt = 0;
	end
end

endmodule 

