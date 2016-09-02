// Created by wxk14, 2016.8
//   Driver for the Ultrasonic Module

module ultrasonic(
	clk0
	,trig
	,probe
	,result
);

// input & output
input clk0;
output trig;
input probe;
output[15:0] result;

// set the trig
wire clk_trig; 
timedivider(clk0, 5000000, clk_trig);
assign trig = clk_trig;

// translate probe to result
wire clk_probe;
timedivider(clk0, 294, clk_probe);
high_timer(clk_probe, probe, result);

endmodule
